#' Jump Up Parent Directories
#'
#' Returns the n<sup>th</sup> ancestor directory of a given path.
#'
#' @param path Character. The file or directory path to start from. If
#'   `check_dir = TRUE` and `path` exists as a file or has a file extension, its
#'   parent directory is used as the starting point. If `check_dir = FALSE`, a
#'   file path is treated as a directory name.
#' @param levels Integer. Number of parent levels to jump up. Must be a single,
#'   non-negative integer.
#' @param check_dir Logical. If `TRUE`, checks `path` is a valid directory and
#'   uses its parent if `path` is a file. If `FALSE`, does not check existence
#'   and uses the input as-is.
#' @param extract_full Logical. If `TRUE` and `levels` exceeds the number of
#'   path components minus one, returns the root of the path. If `FALSE`, an
#'   error is thrown when `levels` exceeds the available ancestors.
#' @param warning Logical. If `TRUE`, prints a warning message when `path` is a
#'   file or has an extension, indicating that the parent directory is being
#'   used instead. Defaults to `TRUE`.
#' @param ... Additional arguments passed to [ecokit::stop_ctx] for error
#'   reporting.
#' @return Character. The resulting path after jumping. If `extract_full = TRUE`
#'   and `levels` exceeds the available ancestors, returns the root of the path;
#'   otherwise, returns the ancestor path or throws an error.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' example_path <- "/home/user/projects/data"
#' {
#'   cat(parent_dir(example_path, levels = 0), "\n")
#'   cat(parent_dir(example_path, levels = 1), "\n")
#'   cat(parent_dir(example_path, levels = 2), "\n")
#'   cat(parent_dir(example_path, levels = 3), "\n")
#'   cat(parent_dir(example_path, levels = 4), "\n")
#' }
#'
#' # input as file
#' example_file <- "/home/user/projects/data/file.txt"
#' parent_dir(example_file, levels = 2)
#' # suppress warning
#' parent_dir(example_file, levels = 2, warning = FALSE)
#'
#' # not enough levels; this will give an error
#' try(parent_dir("/home/user", levels = 4, extract_full = TRUE))

parent_dir <- function(
    path = NULL, levels = 1L, check_dir = FALSE,
    extract_full = FALSE, warning = TRUE, ...) {

  # Check path --------
  if (is.null(path) || !is.character(path) || length(path) != 1L) {
    ecokit::stop_ctx(
      "`path` must be a single character string.",
      path = path, class_path = class(path), ...)
  }

  if (!nzchar(path)) {
    ecokit::stop_ctx("`path` cannot be an empty string.", path = path, ...)
  }

  # If path is a file or has extension, use its parent directory
  if (fs::is_file(path) || nzchar(fs::path_ext(path))) {
    if (warning) {
      cat(
        crayon::blue(
          paste0(
            "  >>>  Input `path` appears to be a file (exists as file or has ",
            "extension), using its parent directory.\n  >>>  ", path, "\n")))
    }
    path <- fs::path_dir(path)
  }

  if (check_dir && !fs::dir_exists(path)) {
    ecokit::stop_ctx("`path` does not exist.", path = path, ...)
  }

  # Check levels ----
  if (!is.numeric(levels) || levels < 0L || length(levels) != 1L ||
      levels != as.integer(levels)) {
    ecokit::stop_ctx(
      "`levels` must be a single non-negative integer.",
      levels = levels, class_levels = class(levels), ...)
  }
  levels <- as.integer(levels)

  # Check extract_full/check_dir ----
  if (!is.logical(extract_full) || length(extract_full) != 1L) {
    ecokit::stop_ctx(
      "`extract_full` must be a single logical value.",
      extract_full = extract_full, class_extract_full = class(extract_full),
      ...)
  }
  if (!is.logical(check_dir) || length(check_dir) != 1L) {
    ecokit::stop_ctx(
      "`check_dir` must be a single logical value.",
      check_dir = check_dir, class_check_dir = class(check_dir), ...)
  }

  # No jumping needed if levels == 0
  if (levels == 0L) return(path)

  # Split into components
  components <- fs::path_split(path)[[1L]]
  depth <- length(components)

  if (check_dir && (levels == depth)) return(getwd())

  if (levels < depth) {
    return(fs::path_join(components[seq_len(depth - levels)]))
  } else if (extract_full) {
    abs_components <- fs::path_split(fs::path_abs(path))[[1L]]
    abs_depth <- length(abs_components)
    if (levels > abs_depth) {
      ecokit::stop_ctx(
        paste0("`levels` > available ancestors (max = ", abs_depth - 1L, ")."),
        levels = levels, abs_depth = abs_depth,
        extract_full = extract_full, ...)
    }
    return(fs::path_join(abs_components[seq_len(abs_depth - levels)]))
  } else {
    ecokit::stop_ctx(
      paste0(
        "`levels` > available ancestors (max = ", depth - 1L, "). ",
        "Set `extract_full = TRUE` to return the root."),
      levels = levels, depth = depth, extract_full = extract_full, ...)
  }
}
