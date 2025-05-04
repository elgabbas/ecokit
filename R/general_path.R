## |------------------------------------------------------------------------| #
# path ----
## |------------------------------------------------------------------------| #

#' Construct path to a file or directory
#'
#' A wrapper around [fs::path()] that constructs file paths from input
#' components and returns them as a character string instead of an `"fs_path"`
#' object.
#'
#' @return A character vector representing the constructed file path(s).
#' @inheritParams fs::path
#' @export
#' @name path
#' @rdname path
#' @examples
#' # Basic usage
#' ecokit::path("datasets", "processed", "model_fitting")
#'
#' # Adding a file extension
#' ecokit::path("results", "output", ext = "csv")
#'
#' # Handling multiple components
#' ecokit::path("home", "user", "documents", "report", ext = "pdf")
#'
#' # Using vectorized input
#' ecokit::path("folder", c("file1", "file2"), ext = "txt")

path <- function(..., ext = "") {
  as.character(fs::path(..., ext = ext))
}
