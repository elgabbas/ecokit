## |------------------------------------------------------------------------| #
# cc ----
## |------------------------------------------------------------------------| #

#' Concatenate without quotes
#'
#' This function takes one or more expressions and concatenates them into a
#' single string without quotes. It is particularly useful for creating strings
#' from variable names or expressions without including the usual quotes.
#'
#' @param ... strings to be concatenated.
#' @author Ahmed El-Gabbas
#' @return A character string representing the concatenated values of the input
#'   expressions.
#' @export
#' @name cc
#' @examples
#' cc(A, B, C)
#'
#' cc(A, B, "A and B")
#'
#' cc(A, B, "A and B", 10)

cc <- function(...) {

  rlang::enexprs(...) %>%
    purrr::map_chr(
      .f = ~ {
        item_class <- class(.x)
        if (inherits(.x, "name")) {
          rlang::as_string(.x)
        } else {
          as.character(.x)
        }
      }) %>%
    stringr::str_remove_all("`")
}
