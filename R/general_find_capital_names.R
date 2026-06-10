## |------------------------------------------------------------------------| #
# find_capital_names ----
## |------------------------------------------------------------------------| #

#' Find files and directories with uppercase letters in their names
#'
#' Recursively searches a directory tree and reports files and directories whose
#' names contain one or more uppercase letters. This is useful for enforcing
#' project-wide naming conventions that require lowercase file and directory
#' names, especially when working on case-sensitive file systems such as Linux
#' or HPC environments.
#'
#' By default, paths are returned relative to the search root. Absolute paths
#' can be returned by setting `full_paths = TRUE`.
#'
#' @param path Character scalar. Root directory to search recursively.
#' @param extension Optional character vector of file extensions to include
#'   (case-insensitive). If `NULL` (default), all file types are searched.
#'   Extensions may be supplied with or without a leading `"."`.
#' @param exclude_extension Optional character vector of file extensions to
#'   exclude. Matching is case-insensitive.
#' @param exclude_dirs Character vector of directory names to exclude together
#'   with all of their contents.
#' @param full_paths Logical scalar. If `TRUE`, absolute paths are returned.
#'   Otherwise, paths are returned relative to `path` (default).
#'
#' @return A named list with elements:
#' - `files`: Files whose filenames contain uppercase letters.
#' - `directories`: Directories whose own names contain uppercase letters.
#' - `directories_anywhere_in_path`: Directories whose relative paths contain
#'   uppercase letters anywhere in the path hierarchy.
#'
#' @details This function is useful for identifying violations of lowercase
#'   naming conventions in projects. Detecting uppercase letters early helps
#'   avoid problems caused by case-sensitive file systems and promotes
#'   consistent project structure.
#'
#' @examples
#' \dontrun{
#'   # Search entire working directory ---
#'   find_capital_names()
#'
#'   # Restrict to specific file extensions ---
#'   find_capital_names(extension = c("R", "Rmd", "RData")
#'
#'   # Exclude file extensions ---
#'   find_capital_names(exclude_extension = c("RData", "qs2", "feather"))
#'
#'   # Exclude directories ---
#'   find_capital_names(
#'       exclude_dirs = c(".git", ".Rproj.user", ".vscode", "renv"))
#'
#'   # Return absolute paths ---
#'   find_capital_names(full_paths = TRUE)
#' }
#' @export
#' @author Ahmed El-Gabbas

find_capital_names <- function(
    path = ".", extension = NULL, exclude_extension = NULL,
    exclude_dirs = c(".git", ".Rproj.user"), full_paths = FALSE) {

  relative_path <- is_dir <- name <- NULL

  if (is.null(path)) {
    ecokit::stop_ctx("`path` must be a non-missing character scalar.")
  }

  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    ecokit::stop_ctx("`path` must be a non-missing character scalar.")
  }

  if (!fs::dir_exists(path)) {
    ecokit::stop_ctx("`path` does not exist", path = path)
  }

  if (!is.null(extension) &&
      (!is.character(extension) || length(extension) < 1L ||
       anyNA(extension))) {
    ecokit::stop_ctx(
      "`extension` must be NULL or a non-missing character vector.")
  }

  if (
    !is.null(exclude_extension) &&
    (!is.character(exclude_extension) || length(exclude_extension) < 1L ||
     anyNA(exclude_extension))) {
    ecokit::stop_ctx(
      "`exclude_extension` must be NULL or a non-missing character vector.")
  }

  ecokit::check_args(args_to_check = "full_paths", args_type = "logical")

  root_path <- fs::path_real(path)

  all_paths <- fs::dir_ls(
    path = root_path, recurse = TRUE, type = "any", all = TRUE, fail = FALSE)

  if (length(all_paths) == 0L) {
    return(
      list(
        files = character(), directories = character(),
        directories_anywhere_in_path = character()))
  }

  paths_tbl <- tibble::tibble(path = as.character(all_paths)) %>%
    dplyr::mutate(
      relative_path = fs::path_rel(path, start = root_path),
      name = fs::path_file(path),
      is_dir = fs::is_dir(path))

  if (!is.null(exclude_dirs) && length(exclude_dirs) > 0L) {

    exclude_dirs <- sub("/+$", "", exclude_dirs)

    exclude_pattern <- paste0(
      "(^|/)(",
      paste(stringr::str_escape(exclude_dirs), collapse = "|"), ")(/|$)")

    paths_tbl <- dplyr::filter(
      paths_tbl, !stringr::str_detect(relative_path, exclude_pattern))
  }

  files_tbl <- dplyr::filter(paths_tbl, !is_dir)
  dirs_tbl <- dplyr::filter(paths_tbl, is_dir)

  if (!is.null(extension)) {

    extension <- sub("^\\.", "", extension)

    files_tbl <- files_tbl %>%
      dplyr::filter(
        stringr::str_detect(
          string = name,
          pattern = stringr::regex(
            paste0(
              "\\.(",
              paste(stringr::str_escape(extension), collapse = "|"), ")$"),
            ignore_case = TRUE)))
  }

  if (!is.null(exclude_extension)) {

    exclude_extension <- sub("^\\.", "", exclude_extension)

    files_tbl <- files_tbl %>%
      dplyr::filter(
        !stringr::str_detect(
          string = name,
          pattern = stringr::regex(
            paste0(
              "\\.(",
              paste(stringr::str_escape(exclude_extension), collapse = "|"),
              ")$"),
            ignore_case = TRUE)))
  }

  files_caps <- dplyr::filter(files_tbl, stringr::str_detect(name, "[A-Z]"))
  dirs_caps <- dplyr::filter(dirs_tbl, stringr::str_detect(name, "[A-Z]"))

  dirs_caps_anywhere <- dplyr::filter(
    dirs_tbl, stringr::str_detect(relative_path, "[A-Z]"))

  path_column <- if (full_paths) "path" else "relative_path"


  l_files <- files_caps %>%
    dplyr::pull(path_column) %>%
    sort()
  l_directories <- dirs_caps %>%
    dplyr::pull(path_column) %>%
    sort()
  l_directories_anywhere_in_path <- dirs_caps_anywhere %>%
    dplyr::pull(path_column) %>%
    sort()

  list(
    files = l_files, directories = l_directories,
    directories_anywhere_in_path = l_directories_anywhere_in_path)
}
