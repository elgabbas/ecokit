## |------------------------------------------------------------------------| #
# create_directory ----
## |------------------------------------------------------------------------| #
#
#' Create or verify the existence of a directory
#'
#' This function creates a directory at the specified path. If the directory
#' already exists, it can optionally print a message indicating so. The creation
#' is recursive, meaning it will create any necessary parent directories.
#' @param path character; the path where the directory is to be created. Cannot
#'   be `NULL`.
#' @param verbose Logical. Whether to print messages about the
#'   operation's outcome. Defaults to `TRUE`.
#' @name create_directory
#' @author Ahmed El-Gabbas
#' @return The function is used for its side effect (creating a directory or
#'   printing a message) rather than any return value.
#' @examples
#' # create a new folder (random name) in the temporary folder
#' Path2Create <- ecokit::path(tempdir(), stringi::stri_rand_strings(1, 5))
#' file.exists(Path2Create)
#'
#' create_directory(Path2Create)
#' create_directory(Path2Create)
#' create_directory(Path2Create, verbose = FALSE)
#' file.exists(Path2Create)
#'
#' @keywords internal
#' @noRd
#' @references This function is currently not exported. I use `fs::dir_create()`
#'   instead.

create_directory <- function(path, verbose = TRUE) {

  if (is.null(path)) {
    ecokit::stop_ctx("path cannot be NULL", path = path)
  }

  # nolint start
  Path2 <- gsub("\\\\", "/", path)
  # nolint end

  if (dir.exists(path) && verbose) {
    ecokit::cat_time(
      stringr::str_glue("path: {crayon::bold(Path2)} - already exists"),
      cat_date = TRUE)
  } else {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    if (verbose) {
      "path: {crayon::bold(Path2)} created" %>%
        stringr::str_glue() %>%
        ecokit::cat_time(cat_date = TRUE)
    }
  }
  return(invisible(NULL))
}
