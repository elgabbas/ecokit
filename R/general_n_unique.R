## |------------------------------------------------------------------------| #
# n_unique ----
## |------------------------------------------------------------------------| #

#' Number of unique values for all columns of a data frame
#'
#' This function calculates the number of unique values for each column in a
#' given data frame and returns a data frame with two columns: `variable` and
#' `n_unique`. The `variable` column lists the names of the original columns,
#' and the `n_unique` column lists the corresponding number of unique values in
#' each column.
#' @name n_unique
#' @param data A data frame for which the number of unique values per column
#'   will be calculated.
#' @param arrange Logical. Whether to arrange the result in descending order of
#'   the number of unique values. Defaults to `TRUE`.
#' @source The source code of the function was copied from this
#'   [stackoverflow](https://stackoverflow.com/q/22196078) question.
#' @export
#' @author Ahmed El-Gabbas
#' @return A data frame with two columns: `variable` and `n_unique`. The
#'   variable column lists the names of the original columns, and the `n_unique`
#'   column lists the number of unique values in each column.
#' @examples
#' # arranged by n_unique
#' n_unique(mtcars)
#'
#' # not arranged (keep original data order)
#' n_unique(mtcars, arrange = FALSE)
#'
#' n_unique(iris)
#'
#' n_unique(iris, arrange = FALSE)

n_unique <- function(data, arrange = TRUE) {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL", data = data)
  }

  data <- data %>%
    dplyr::summarise(
      dplyr::across(tidyselect::everything(), dplyr::n_distinct)) %>%
    tidyr::pivot_longer(cols = tidyselect::everything(),
        names_to = "variable", values_to = "n_unique")

  if (arrange) {
    return(dplyr::arrange(data, dplyr::desc(n_unique)))
  } else {
    return(data)
  }
}
