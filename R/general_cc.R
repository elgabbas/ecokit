## |------------------------------------------------------------------------| #
# cc ----
## |------------------------------------------------------------------------| #

#' Concatenate without quotes
#'
#' This function takes one or more expressions and concatenates them into a
#' single string without quotes. It is particularly useful for creating strings
#' from variable names or expressions without including the usual quotes.
#'
#' @param ... strings to be concatenated. Note that numeric values should be
#'   converted to strings before being passed.
#' @author Ahmed El-Gabbas
#' @return A character string representing the concatenated values of the input
#'   expressions.
#' @export
#' @name cc
#' @examples
#' cc(A, B, C)
#'
#' # -------------------------------------------
#'
#' cc(A, B, "A and B")
#'
#' # -------------------------------------------
#'
#' # this does not work
#' try(cc(A, B, "A and B", 10))
#'
#' # this works
#' cc(A, B, "A and B", "10")

cc <- function(...) {
  rlang::ensyms(...) %>%
    purrr::map_chr(rlang::as_string) %>%
    stringr::str_remove_all("`")
}
