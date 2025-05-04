## |------------------------------------------------------------------------| #
# normalize_path ----
## |------------------------------------------------------------------------| #

#' Normalise and quote file paths
#'
#' This function ensures that file paths are expressed in a consistent and
#' canonical form. It first converts paths to absolute form using
#' [fs::path_abs()], then tidies them with [fs::path_tidy()], and finally quotes
#' them correctly based on the operating system. By default,
#' [base::normalizePath()] behaves differently on Windows and Linux when a file
#' does not exist. On Windows, it tries to construct an absolute path, while on
#' Linux, it returns the input path as-is (relative). To maintain consistency
#' across platforms, this function uses [fs::path_abs()] instead of
#' [base::normalizePath()].
#' @param path Character vector. file path(s).
#' @param must_work Logical; if `TRUE`, the function errors for non-existing
#'   paths.
#' @return A character vector of absolute, tidied, and shell-quoted paths.
#' @export
#' @author Ahmed El-Gabbas

normalize_path <- function(path, must_work = FALSE) {

  # Validate input
  if (is.null(path)) {
    ecokit::stop_ctx("`path` cannot be NULL.", path = path)
  }
  if (!is.character(path)) {
    ecokit::stop_ctx(
      "`path` must be a character vector.",
      path = path, class_path = class(path))
  }
  if (length(path) == 0) {
    ecokit::stop_ctx(
      "`path` cannot be an empty character vector.",
      path = path, length_path = length(path))
  }

  # Check path existence before transformation (if must_work = TRUE)
  if (must_work) {
    dir_exist <- dplyr::if_else(
      fs::is_dir(path), fs::dir_exists(path), fs::file_exists(path))

    if (isFALSE(dir_exist)) {
      ecokit::stop_ctx(
        "`path` does not exist", path = path, dir_exist = dir_exist)
    }
  }

  # Process and return normalised path
  output <- fs::path_abs(path) %>%
    fs::path_tidy()

  return(output)
}
