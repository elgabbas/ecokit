#' Load a File from a Tar Archive
#'
#' Extracts a single file from a tar archive into a temporary directory, loads
#' it, and returns the in-memory object. The temporary directory is always
#' deleted on exit, so file-backed objects such as `SpatRaster` are read fully
#' into memory before the directory is removed.
#'
#' For TIFF files (extensions `.tif` or `.tiff`), the function always uses
#' [terra::rast()] followed by [terra::toMemory()] to ensure the raster is fully
#' in memory before the temporary extraction directory is deleted. The
#' `load_fun` argument is therefore **ignored** for TIFF files. If `wrap_r =
#' TRUE` (the default), the in-memory `SpatRaster` is additionally wrapped with
#' [terra::wrap()] to make it serialisable for parallel or inter-process
#' transfer.
#'
#' For files with extensions recognised by [ecokit::load_as()] (`.rdata`,
#' `.qs2`, `.rds`, `.feather`), that function is called directly and `load_fun`
#' is ignored.
#'
#' For all other file types, the function calls `load_fun` on the extracted file
#' path.
#'
#' @param tar_file Character. Path to the tar archive file. Supported
#'   extensions: `.tar`, `.tar.gz`, `.tgz`, `.tar.bz2`, `.tbz2`.
#' @param file_to_extract Character. Path of the file to extract from the
#'   archive, exactly as it appears in the archive listing (may include
#'   subdirectory components).
#' @param load_fun Either a function or a character string naming a function
#'   (optionally namespace-qualified, e.g. `"readr::read_csv"`) used to load the
#'   extracted file for non-TIFF, non-`ecokit::load_as`-handled types. Defaults
#'   to [ecokit::load_as]. Ignored for TIFF files and for files whose extension
#'   is handled natively by [ecokit::load_as()].
#' @param wrap_r Logical. Only relevant when the extracted file is a TIFF. If
#'   `TRUE` (default), the in-memory `SpatRaster` is wrapped with
#'   [terra::wrap()] before being returned, making it safe for serialisation
#'   (e.g. passing across parallel workers). Set to `FALSE` to return a plain
#'   `SpatRaster`.
#' @param ... Additional arguments passed to `load_fun` (ignored for TIFF
#'   files).
#'
#' @return For TIFF files: a `PackedSpatRaster` (when `wrap_r = TRUE`) or a
#'   `SpatRaster` fully loaded into memory (when `wrap_r = FALSE`). For all
#'   other types: the object returned by `load_fun` or [ecokit::load_as()], as
#'   appropriate.
#'
#' @author Ahmed El-Gabbas
#' @examples
#' ecokit::load_packages(terra, stringr, fs)
#'
#' # Build an example tar file containing 3 files
#' tif_file <- system.file("ex/elev.tif", package = "terra")
#' rds_file <- fs::file_temp(ext = ".rds")
#' ecokit::save_as(mtcars, out_path = rds_file)
#' csv_file <- tempfile(fileext = ".csv")
#' write.csv(iris, csv_file, row.names = FALSE)
#' tmp_tar <- fs::file_temp(ext = ".tar")
#' file_list <- c(tif_file, csv_file, rds_file)
#' base_names <- basename(file_list)
#' dirs <- dirname(file_list)
#' for (i in seq_along(file_list)) {
#'   tar_flag <- ifelse(i == 1L, "c", "r")
#'   tar_args <- stringr::str_glue(
#'     "tar -{tar_flag}f {shQuote(tmp_tar)} -C {shQuote(dirs[i])} \\
#'     {shQuote(base_names[i])}")
#'   invisible(system(tar_args))
#' }
#'
#' # List contents of the tar file
#' print(system2("tar", c("-tf", tmp_tar), stdout = TRUE))
#'
#' # TIFF: returned fully in memory (wrapped by default)
#' r <- load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = "elev.tif")
#'
#' # TIFF: unwrapped SpatRaster
#' r2 <- load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = "elev.tif", wrap_r = FALSE)
#' terra::sources(r2)  # should be "" (in memory)
#'
#' # CSV via base read.csv
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = basename(csv_file),
#'   load_fun = "read.csv") %>%
#'   head()
#'
#' # RDS (handled automatically by ecokit::load_as)
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = basename(rds_file)) %>%
#'   head()
#'
#' \dontrun{
#' # Invalid load_fun: errors with a clear message
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = basename(csv_file),
#'   load_fun = "function_name")
#' }
#'
#' # clean up
#' fs::file_delete(tmp_tar)
#' @export

load_tar_file <- function(
    tar_file, file_to_extract, load_fun = "ecokit::load_as",
    wrap_r = TRUE, ...) {

  ecokit::check_args(args_to_check = "tar_file", args_type = "character")
  ecokit::check_args(args_to_check = "wrap_r",   args_type = "logical")

  # Validate tar_file: must exist and be a regular file
  if (!fs::file_exists(tar_file) || !fs::is_file(tar_file)) {
    ecokit::stop_ctx(
      "The specified `tar_file` does not exist or is not a file",
      tar_file = tar_file)
  }

  # Validate tar_file extension
  valid_extensions <- c(".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz2")
  if (!any(endsWith(tar_file, valid_extensions))) {
    ecokit::stop_ctx(
      "Unsupported tar file extension",
      tar_file = basename(tar_file),
      valid_extensions = toString(valid_extensions))
  }

  # Validate file_to_extract
  if (!is.character(file_to_extract) || length(file_to_extract) != 1L ||
      nchar(trimws(file_to_extract)) < 1L) {
    ecokit::stop_ctx(
      "`file_to_extract` must be a non-empty character string of length 1",
      file_to_extract = file_to_extract)
  }

  # Validate load_fun type early (before doing any I/O)
  if (!is.character(load_fun) && !is.function(load_fun)) {
    ecokit::stop_ctx(
      "`load_fun` must be a function or a character string naming a function",
      load_fun_class = class(load_fun))
  }

  # Check whether file_to_extract is present in the archive
  archive_contents <- system2("tar", c("-tf", shQuote(tar_file)), stdout = TRUE)
  if (!file_to_extract %in% archive_contents) {
    ecokit::stop_ctx(
      "The specified `file_to_extract` does not exist in the tar archive",
      file_to_extract = file_to_extract,
      tar_file = tar_file, tar_dir = dirname(tar_file),
      archive_contents = archive_contents)
  }

  # Create temporary extraction directory; always clean up on exit
  tmpdir <- tempfile("tar_extract_")
  if (!dir.create(tmpdir, recursive = TRUE)) {
    ecokit::stop_ctx("Failed to create temporary directory", tmpdir = tmpdir)
  }
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Extract the target file
  utils::untar(tar_file, files = file_to_extract, exdir = tmpdir)

  # Full path to extracted file
  extracted_path <- fs::path(tmpdir, file_to_extract)
  if (!fs::file_exists(extracted_path)) {
    ecokit::stop_ctx(
      "Extraction appeared to succeed but the output file was not found",
      file_to_extract = file_to_extract, expected_path = extracted_path,
      tar_file = tar_file)
  }

  file_ext <- tools::file_ext(extracted_path) %>%
    stringr::str_to_lower()

  # -- TIFF: force in-memory load regardless of load_fun --
  if (file_ext %in% c("tif", "tiff")) {
    ecokit::check_packages("terra")
    if (!ecokit::check_tiff(extracted_path)) {
      ecokit::stop_ctx(
        "The extracted file is not a valid TIFF",
        file_to_extract = file_to_extract, tar_dir = dirname(tar_file))
    }
    out_r <- terra::rast(extracted_path) %>%
      terra::toMemory()
    if (wrap_r) {
      out_r <- terra::wrap(out_r)
    }
    return(out_r)
  }

  # -- ecokit::load_as-handled types: delegate directly --
  if (file_ext %in% c("rdata", "qs2", "rds", "feather")) {
    if (file_ext == "qs2") ecokit::check_packages("qs")
    if (file_ext == "feather") ecokit::check_packages("arrow")
    return(ecokit::load_as(extracted_path, ...))
  }

  # -- All other types: resolve and call load_fun --
  if (is.character(load_fun)) {
    if (grepl("::", load_fun, fixed = TRUE)) {
      pkg_fun <- strsplit(load_fun, "::", fixed = TRUE)[[1L]]
      if (length(pkg_fun) != 2L) {
        ecokit::stop_ctx(
          "Invalid namespace-qualified function name",
          load_fun = load_fun)
      }
      ecokit::check_packages(pkg_fun[1L])
      load_fun_obj <- tryCatch(
        get(pkg_fun[2L], envir = asNamespace(pkg_fun[1L]), inherits = FALSE),
        error = function(e) {
          ecokit::stop_ctx(
            "Function not found in package",
            package = pkg_fun[1L], function_ = pkg_fun[2L], load_fun = load_fun)
        })
    } else {
      load_fun_obj <- tryCatch(
        get(load_fun, mode = "function"),
        error = function(e) {
          ecokit::stop_ctx(
            "Function not found in the search path", load_fun = load_fun)
        })
    }
  } else {
    load_fun_obj <- load_fun
  }

  load_fun_obj(extracted_path, ...)
}
