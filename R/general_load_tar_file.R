#' Load a File from a Tar Archive
#'
#' This function extracts a specified file from a tar archive to a temporary
#' directory, loads it using a provided loading function, and returns the loaded
#' object.
#' @param tar_file Character. Path to the tar archive file.
#' @param file_to_extract Character. Path of the file to extract from the tar
#'   archive (can include directories within the archive).
#' @param load_fun Either a function or a character string naming a function
#'   (possibly with package namespace like "package::function") to load the
#'   extracted file. Defaults to [ecokit::load_as].
#' @param ... Additional arguments passed to the loading function.
#'
#' @return The object returned by the loading function applied to the extracted
#'   file.
#' @author Ahmed El-Gabbas
#' @examples
#' ecokit::load_packages(terra, stringr, fs)
#'
#' # example tar file containing 3 files
#'
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
#' tar_flag <- ifelse(i == 1, "c", "r")
#'   tar_args <- str_glue(
#'     'tar -{tar_flag}f {shQuote(tmp_tar)} -C {shQuote(dirs[i])} \\
#'     {shQuote(base_names[i])}')
#'   invisible(system(tar_args))
#' }
#'
#' # List contents of the tar file
#' print(system2("tar", c("-tf", tmp_tar), stdout = TRUE))
#'
#' # example SpatRaster
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = "elev.tif",
#'   load_fun = "terra::rast")
#'
#' # example CSV file using readr
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = basename(csv_file),
#'   load_fun = "read.csv") %>%
#'   head()
#'
#' # example rds file
#' load_tar_file(
#'   tar_file = tmp_tar, file_to_extract = basename(rds_file),
#'   load_fun = readRDS) %>%
#'   head()
#' @export

load_tar_file <- function(
    tar_file, file_to_extract, load_fun = "ecokit::load_as", ...) {

  # Check if tar_file exists and is a file
  if (!fs::file_exists(tar_file) || !fs::is_file(tar_file)) {
    ecokit::stop_ctx(
      "The specified `tar_file` does not exist or is not a file",
      tar_file = tar_file)
  }

  # Validate file_to_extract: character of length 1 with at least 1 character
  if (!is.character(file_to_extract) || length(file_to_extract) != 1L ||
      nchar(file_to_extract) < 1L) {
    ecokit::stop_ctx(
      "`file_to_extract` must be a non-empty character string of length 1",
      file_to_extract = file_to_extract)
  }

  # Check if file_to_extract exists in the tar archive
  archive_contents <- system2("tar", c("-tf", tar_file), stdout = TRUE)

  if (!file_to_extract %in% archive_contents) {
    ecokit::stop_ctx(
      "The specified `file_to_extract` does not exist in the tar archive",
      file_to_extract = file_to_extract, tar_file = tar_file)
  }

  # Create temporary directory
  tmpdir <- tempfile("tar_extract_")
  if (!dir.create(tmpdir, recursive = TRUE)) {
    ecokit::stop_ctx("Failed to create temporary directory: ", tmpdir = tmpdir)
  }
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Extract the file using utils::untar for cross-platform compatibility
  utils::untar(tar_file, files = file_to_extract, exdir = tmpdir)

  # Construct the full path to the extracted file
  extracted_path <- fs::path(tmpdir, file_to_extract)

  # Check if extraction succeeded
  if (!fs::file_exists(extracted_path)) {
    ecokit::stop_ctx(
      paste0(
        "Failed to extract the file: ", file_to_extract, " from ", tar_file))
  }

  # Resolve load_fun to a function object
  if (is.character(load_fun)) {
    if (grepl("::", load_fun, fixed = TRUE)) {
      pkg_fun <- strsplit(load_fun, "::", fixed = TRUE)[[1L]]
      if (length(pkg_fun) != 2L) {
        ecokit::stop_ctx(
          paste0("Invalid namespace-qualified function name: ", load_fun))
      }
      load_fun_obj <- get(pkg_fun[2L], envir = asNamespace(pkg_fun[1L]))
    } else {
      load_fun_obj <- get(load_fun, mode = "function")
    }
  } else if (is.function(load_fun)) {
    load_fun_obj <- load_fun
  } else {
    ecokit::stop_ctx(
      paste0(
        "load_fun must be a function or a character",
        "string referring to a function"))
  }

  # Call the loader function
  load_fun_obj(extracted_path, ...)
}
