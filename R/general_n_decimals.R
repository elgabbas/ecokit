## |------------------------------------------------------------------------| #
# n_decimals ----
## |------------------------------------------------------------------------| #

#' Number of decimal places in a numeric or character value
#'
#' This function calculates the number of decimal places in a numeric or
#' character value by counting all digits after the decimal point in the string
#' representation, including trailing zeros for characters. It is vectorized and
#' designed to work with numeric inputs or character strings representing
#' numbers, making it suitable for use with `dplyr::mutate`.
#'
#' @param x Numeric or character vector representing numeric values.
#' @return An integer vector of the same length as `x`, where each element
#'   represents the number of decimal places in the corresponding input value.
#' @author Ahmed El-Gabbas
#' @examples
#' # Character input with trailing zeros
#' n_decimals(c("1.35965", "65.5484900000", "0.11840000"))
#'
#' # Numeric input with trailing zeros
#' n_decimals(c(1.35965, 65.5484900000, 0.11840000))
#'
#' # Use with dplyr
#' library(dplyr)
#' mtcars %>%
#'   dplyr::select(wt) %>%
#'   dplyr::mutate(n_decimals = n_decimals(wt))
#' @export

n_decimals <- function(x = NULL) {

  # Input validation
  if (is.null(x)) {
    ecokit::stop_ctx("x cannot be NULL")
  }

  # Split strings at decimal point, limit to 2 parts
  data_split <- stringr::str_split(
    as.character(x), pattern = "\\.", n = 2L, simplify = TRUE)

  # Count characters in decimal part; return 0 if no decimal part
  ifelse(
    (ncol(data_split) == 1L | !nzchar(data_split[, 2L])),
    0L, nchar(data_split[, 2L]))
}
