## |------------------------------------------------------------------------| #
# replace_space ----
## |------------------------------------------------------------------------| #

#' Replace space with underscore in a string
#'
#' A simple wrapper function for `stringr::str_replace_all` that replaces all
#' spaces with underscores. It is useful for formatting strings to be used in
#' contexts where spaces are not allowed or desired.
#'
#' @param x Character. The string in which spaces will be replaced with
#'   underscores.
#' @name replace_space
#' @return A character string with all spaces replaced by underscores.
#' @examples
#' replace_space("Genus species")
#'
#' replace_space("Genus species subspecies")
#' @export

replace_space <- function(x) {

  if (is.null(x)) {
    ecokit::stop_ctx("x name cannot be NULL", x = x)
  }

  return(stringr::str_replace_all(as.character(x), " ", "_"))
}
