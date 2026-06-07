#' Create a tar archive from files in a directory
#'
#' Creates a tar archive (optionally compressed) containing the specified files
#' from a directory. The function uses the system `tar` executable and passes
#' the file list via a temporary file, avoiding command-line length limitations
#' when archiving large numbers of files.
#'
#' @param files Character vector of file names relative to `dir_source`. Must be
#'   non-`NULL`, non-empty, and contain no `NA` values or absolute paths. All
#'   named files must exist and be non-empty within `dir_source`.
#' @param dir_source Character scalar. Directory containing the files to
#'   archive. The parent directory of `path_tar` is created if it does not
#'   exist.
#' @param path_tar Character scalar. Path to the output tar archive.
#' @param compress Character scalar controlling compression. One of `"none"`
#'   (default, plain `.tar`), `"gzip"` (`.tar.gz`), `"bzip2"` (`.tar.bz2`), or
#'   `"xz"` (`.tar.xz`). The archive extension is not checked against this
#'   choice; the caller is responsible for using a consistent file name.
#' @param chmod Character scalar. Optional Unix file permissions to set on the
#'   created archive, as a three-digit octal string (e.g. `"644"`). If `NULL`
#'   (the default) permissions are determined by the system. Values outside the
#'   range `"000"`-`"777"` are rejected.
#' @param overwrite Logical scalar. Should an existing archive at `path_tar` be
#'   overwritten? Defaults to `FALSE`.
#'
#' @return Invisibly returns `path_tar`.
#'
#' @details The function requires a `tar` executable to be available on the
#'   system `PATH`. File names in `files` must be relative to `dir_source`;
#'   absolute paths are not supported.
#'
#'   Compression support depends on the `tar` implementation and the presence of
#'   the corresponding compressor (`gzip`, `bzip2`, or `xz`) on the system.
#'
#' @examples
#' ecokit::load_packages(fs, archive, purrr, dplyr)
#'
#' # Create non-empty example files in a temporary directory
#' tmp <- fs::path_temp("example_files")
#' fs::dir_create(tmp)
#' files <- c("a.qs2", "b.qs2", "c.qs2")
#' purrr::walk(file.path(tmp, files), .f = ~ writeLines("test content", .x))
#'
#' # Create an uncompressed tar archive
#' tar_file <- fs::path(tmp, "archive.tar")
#' create_tar(
#'   files = files, dir_source = tmp, path_tar = tar_file, overwrite = TRUE)
#'
#' # Verify the created archive
#' archive::archive(tar_file)
#'
#' ecokit::file_type(tar_file)
#'
#' # Create a gzip-compressed archive
#' tar_gz_file <- fs::path(tmp, "archive.tar.gz")
#' create_tar(
#'   files = files, dir_source = tmp, path_tar = tar_gz_file,
#'   compress = "gzip", overwrite = TRUE)
#'
#' # Compare the two archives
#' fs::file_info(c(tar_file, tar_gz_file)) %>%
#'  dplyr::select(path, size, type)
#'
#' @export
#' @author Ahmed El-Gabbas

create_tar <- function(
    files, dir_source, path_tar, compress  = c("none", "gzip", "bzip2", "xz"),
    chmod = NULL, overwrite = FALSE) {


  # # |||||||||||||||||||||||||||||||||||||||
  # early scalar-type checks
  # # |||||||||||||||||||||||||||||||||||||||

  ecokit::check_args(
    args_to_check = c("dir_source", "path_tar"), args_type = "character")
  ecokit::check_args(args_to_check = "overwrite", args_type = "logical")

  compress <- match.arg(compress)

  # # |||||||||||||||||||||||||||||||||||||||
  # validate chmod (only when supplied)
  # # |||||||||||||||||||||||||||||||||||||||

  if (!is.null(chmod)) {
    ecokit::check_args(args_to_check = "chmod", args_type = "character")

    if (!grepl("^[0-7]{3}$", chmod)) {
      ecokit::stop_ctx(
        "Invalid chmod value. Must be a 3-digit octal string ('000'-'777').",
        chmod = chmod)
    }
  }

  # # |||||||||||||||||||||||||||||||||||||||
  # require tar early (before any I/O work)
  # # |||||||||||||||||||||||||||||||||||||||

  if (!ecokit::check_system_command("tar", warning = FALSE)) {
    ecokit::stop_ctx("The 'tar' command is not available on this system.")
  }

  tar_exe <- Sys.which("tar")

  # # |||||||||||||||||||||||||||||||||||||||
  # check compressor availability
  # # |||||||||||||||||||||||||||||||||||||||

  if (compress != "none") {
    compressor <- switch(compress, gzip = "gzip", bzip2 = "bzip2", xz = "xz")
    if (!ecokit::check_system_command(compressor, warning = FALSE)) {
      ecokit::stop_ctx(
        paste0(
          "Compression '", compress, "' was requested but the '",
          compressor, "' executable is not available on this system."),
        compress = compress, compressor = compressor)
    }
  }

  # # |||||||||||||||||||||||||||||||||||||||
  # validate files vector
  # # |||||||||||||||||||||||||||||||||||||||

  if (!is.character(files)) {
    ecokit::stop_ctx("'files' must be a character vector.")
  }

  if (is.null(files)) {
    ecokit::stop_ctx("'files' cannot be NULL.")
  }

  if (length(files) == 0L) {
    ecokit::stop_ctx("'files' must contain at least one file name.")
  }

  if (anyNA(files)) {
    ecokit::stop_ctx(
      "'files' cannot contain NA values.", na_count = sum(is.na(files)))
  }

  if (any(fs::is_absolute_path(files))) {
    ecokit::stop_ctx(
      "'files' must contain paths relative to 'dir_source'.",
      absolute_files = files[fs::is_absolute_path(files)])
  }

  # # |||||||||||||||||||||||||||||||||||||||
  # check that all files exist and are non-empty
  # # |||||||||||||||||||||||||||||||||||||||

  path_abs <- fs::path(dir_source, files)
  files_exist <- fs::file_exists(path_abs)

  if (!all(files_exist)) {
    ecokit::stop_ctx(
      "Some files listed in 'files' do not exist in 'dir_source'.",
      missing_count = sum(!files_exist), missing_files = files[!files_exist])
  }

  file_info <- fs::file_info(path_abs)
  non_regular <- file_info$type != "file"
  empty_files <- file_info$size == 0L

  if (any(non_regular) || any(empty_files)) {
    ecokit::stop_ctx(
      "All files in 'files' must be regular (non-directory) and non-empty.",
      non_regular_count = sum(non_regular),
      non_regular_files = files[non_regular], empty_count = sum(empty_files),
      empty_files = files[empty_files])
  }

  # # |||||||||||||||||||||||||||||||||||||||
  # guard against accidental overwrite
  # # |||||||||||||||||||||||||||||||||||||||

  if (fs::file_exists(path_tar) && !overwrite) {
    ecokit::stop_ctx(
      paste0(
        "The file specified by 'path_tar' already exists. ",
        "Set 'overwrite = TRUE' to overwrite it."),
      path = path_tar)
  }

  # build tar command
  compress_flag <- switch(
    compress,
    none = "", gzip = "-z", bzip2 = "-j", xz = "-J")

  # Write the file list to a temp file to avoid shell-argument length limits.
  file_list <- fs::file_temp(pattern = "file_list_", ext = "txt")
  withr::defer(try(fs::file_delete(file_list), silent = TRUE))
  writeLines(files, file_list)

  # Ensure the output directory exists.
  fs::dir_create(fs::path_dir(path_tar))

  # Remove a pre-existing archive only when overwrite is allowed.
  if (fs::file_exists(path_tar) && overwrite) {
    fs::file_delete(path_tar)
  }

  tar_command <- paste(
    shQuote(tar_exe),
    # create new archive
    "-c",
    # optional compression flag
    compress_flag,
    # output archive file
    "-f",  shQuote(path_tar),
    # relative-path anchor
    "-C",  shQuote(fs::path_abs(dir_source)),
    # file list via temp file
    "-T",  shQuote(file_list))

  # # |||||||||||||||||||||||||||||||||||||||
  # run tar and verify output
  # # |||||||||||||||||||||||||||||||||||||||

  exit_code <- system(tar_command)

  if (!identical(exit_code, 0L)) {
    ecokit::stop_ctx("Failed to create tar archive.", exit_code = exit_code)
  }

  if (!fs::file_exists(path_tar) || fs::file_info(path_tar)$size == 0L) {
    ecokit::stop_ctx("Tar archive was not created as expected.")
  }

  # # |||||||||||||||||||||||||||||||||||||||
  # optional chmod
  # # |||||||||||||||||||||||||||||||||||||||

  if (!is.null(chmod)) {
    fs::file_chmod(path = path_tar, mode = chmod)
  }

  try(fs::file_delete(file_list), silent = TRUE)

  invisible(path_tar)
}
