## |------------------------------------------------------------------------| #
# file_size ----
## |------------------------------------------------------------------------| #

#' File size in a human-readable format
#'
#' This function takes the path to a file and returns its size in a format that
#' is easy to read (e.g., KB, MB, GB), using the [gdata::humanReadable]
#' function.
#' @param file character; the path to the file whose size you want to check.
#' @param ... additional arguments passed to the [gdata::humanReadable]
#'   function, allowing for further customization of the output format.
#' @return A character string representing the size of the file in a
#'   human-readable format.
#' @name file_size
#' @export
#' @examples
#' (f <- system.file("ex/elev.tif", package="terra"))
#'
#' file_size(file = f)

file_size <- function(file, ...) {

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL", file = file)
  }

  return(gdata::humanReadable(fs::file_size(file), ...))
}
