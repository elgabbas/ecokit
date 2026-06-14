## |------------------------------------------------------------------------| #
# normalize_path ----
## |------------------------------------------------------------------------| #

#' Normalise file paths to a consistent absolute form
#'
#' Converts one or more file paths to their absolute, tidied canonical form
#' using [fs::path_abs()] and [fs::path_tidy()]. Optionally errors if any path
#' does not exist on disk or has a size of zero bytes.
#'
#' @param path Character vector. One or more file or directory paths to
#'   normalise. Empty strings and `NULL` trigger an error. Default: `"."`
#'   (current working directory).
#' @param must_work Logical. If `TRUE`, the function errors for any path in
#'   `path` that does not exist on disk (checked after normalisation). Default:
#'   `FALSE`.
#' @param check_size Logical. If `TRUE` and `must_work = TRUE`, the function
#'   additionally errors if any of the (existing) paths points to a file of
#'   zero bytes. Ignored when `must_work = FALSE` or when any path refers to a
#'   directory rather than a file. Default: `FALSE`.
#' @return A character vector of the same length as `path`, containing absolute,
#'   tidied paths. Redundant separators, `.` and `..` components, and
#'   mixed-style slashes are all resolved.
#' @details
#'   [base::normalizePath()] behaves inconsistently across platforms when a path
#'   does not exist: on Windows it attempts to construct an absolute path, while
#'   on Linux/macOS it returns the input unchanged (i.e. relative paths stay
#'   relative). This function uses [fs::path_abs()] instead, which always
#'   returns an absolute path regardless of whether the path exists or which
#'   platform is used.
#'
#'   Path tidying via [fs::path_tidy()] normalises directory separators to
#'   forward slashes and removes redundant separators and trailing slashes,
#'   making the output safe to use in both R and shell contexts across
#'   platforms.
#'
#'   When `must_work = TRUE`, existence is checked **after** normalisation so
#'   that relative inputs such as `"."` or `"../"` resolve correctly before the
#'   check is applied. The `check_size` check is subordinate to `must_work`:
#'   it only runs once all paths are confirmed to exist.
#' @export
#' @author Ahmed El-Gabbas
#' @seealso [fs::path_abs()], [fs::path_tidy()], [base::normalizePath()]
#' @examples
#' # Current working directory
#' normalize_path(".")
#'
#' # Parent directory
#' normalize_path("../")
#'
#' # First file in the working directory (if any)
#' if (length(list.files()) > 0L) {
#'   normalize_path(list.files()[[1L]])
#' }
#'
#' # Vectorised: multiple paths at once
#' normalize_path(c(".", "../"))
#'
#' # Windows-style separators are normalised on all platforms
#' normalize_path("D://Folder1//Folder2//file.txt")
#'
#' \dontrun{
#'   # Errors when must_work = TRUE and the path does not exist
#'   normalize_path("D://Folder1//Folder2//file.txt", must_work = TRUE)
#'
#'   # Errors when must_work = TRUE, check_size = TRUE, and the file is empty
#'   empty_file <- fs::file_temp(pattern = "empty_")
#'   fs::file_create(empty_file)
#'   normalize_path(empty_file, must_work = TRUE, check_size = TRUE)
#' }

normalize_path <- function(path = ".", must_work = FALSE, check_size = FALSE) {

  # Input validation ------

  ecokit::check_args(
    args_to_check = c("must_work", "check_size"), args_type = "logical")

  if (is.null(path) || !all(is.character(path))) {
    ecokit::stop_ctx(
      "`path` must be a character vector.",
      path = path, include_backtrace = TRUE)
  }

  if (!all(nzchar(path))) {
    ecokit::stop_ctx(
      "`path` must not contain empty strings.",
      path = path, include_backtrace = TRUE)
  }

  # ..................................................................... ###

  # Normalise paths ------

  out <- fs::path_abs(path) %>%
    fs::path_tidy()

  # ..................................................................... ###

  # Check existence after normalisation (if must_work = TRUE) ------

  if (must_work) {
    missing_paths <- out[!fs::file_exists(out) & !fs::dir_exists(out)]
    if (length(missing_paths) > 0L) {
      ecokit::stop_ctx(
        paste0(length(missing_paths), " path(s) do not exist."),
        missing_paths = missing_paths, include_backtrace = TRUE)
    }

    # Check file sizes (only when all paths are files, not directories) ------

    if (check_size && all(fs::is_file(out))) {
      zero_size <- out[fs::file_info(out)$size == 0L]
      if (length(zero_size) > 0L) {
        ecokit::stop_ctx(
          paste0(
            length(zero_size), " file(s) have a size of 0 bytes:"),
          zero_size_paths = zero_size, include_backtrace = TRUE)
      }
    }
  }

  # ..................................................................... ###

  return(out)
}
