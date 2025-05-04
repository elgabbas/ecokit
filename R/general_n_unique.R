## |------------------------------------------------------------------------| #
# n_unique ----
## |------------------------------------------------------------------------| #

#' Number of unique values for all columns of a data frame
#'
#' This function calculates the number of unique values for each column in a
#' given data frame and returns a data frame with two columns: `Variable` and
#' `n_unique`. The `Variable` column lists the names of the original columns,
#' and the `n_unique` column lists the corresponding number of unique values in
#' each column. The result is sorted by the number of unique values in ascending
#' order.
#'
#' @name n_unique
#' @param data A data frame for which the number of unique values per column
#'   will be calculated.
#' @source The source code of the function was copied from this
#'   [stackoverflow](https://stackoverflow.com/q/22196078) question.
#' @export
#' @author Ahmed El-Gabbas
#' @return A data frame with two columns: `Variable` and `n_unique`. The
#'   Variable column lists the names of the original columns, and the `n_unique`
#'   column lists the number of unique values in each column. The result is
#'   sorted by `n_unique` in ascending order.
#' @examples
#' n_unique(mtcars)
#'
#' n_unique(iris)

n_unique <- function(data) {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL", data = data)
  }

  data <- data %>%
    dplyr::summarise(
      dplyr::across(tidyselect::everything(), dplyr::n_distinct)) %>%
    tidyr::pivot_longer(cols = tidyselect::everything(),
        names_to = "Variable", values_to = "n_unique") %>%
    dplyr::arrange(n_unique)

  return(data)
}
