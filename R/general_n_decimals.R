## |------------------------------------------------------------------------| #
# n_decimals ----
## |------------------------------------------------------------------------| #

#' Number of decimal places in a numeric value
#'
#' This function calculates the number of decimal places in a numeric value. It
#' is designed to work with numeric inputs that can be coerced to character
#' format.
#'
#' @param x Numeric (or character) numeric value.
#' @name n_decimals
#' @author Ahmed El-Gabbas
#' @return An integer representing the number of decimal places in the input
#'   value. If the input value does not have any decimal places, the function
#'   returns 0.
#' @examples
#' n_decimals(x = "13.45554545")
#'
#' # -------------------------------------------
#'
#' n_decimals(x = 15.01500)
#'
#' n_decimals(x = '15.01500')
#'
#' # -------------------------------------------
#'
#' n_decimals(x = 13.45554545)
#' @export

n_decimals <- function(x = NULL) {

  if (is.null(x)) {
    ecokit::stop_ctx("x cannot be NULL", x = x)
  }

  data_split <- x %>%
    as.character() %>%
    format(scientific = FALSE) %>%
    stringr::str_split(pattern = "\\.", n = Inf, simplify = TRUE)

  if (ncol(data_split) == 2) {
    output <- data_split %>%
      as.vector() %>%
      utils::tail(1) %>%
      nchar() %>%
      as.integer()
    return(output)
  } else {
    return(0L)
  }
}
