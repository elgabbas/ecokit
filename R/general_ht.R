## |------------------------------------------------------------------------| #
# ht ----
## |------------------------------------------------------------------------| #

#' Print head and tail of data frame
#'
#' This function takes a data frame and an optional number of rows to print from
#' both the top (head) and bottom (tail) of the data frame. It is useful for
#' quickly inspecting the first few and last few rows of a large data frame to
#' understand its structure and contents.
#' @name ht
#' @author Ahmed El-Gabbas
#' @return The function is used for its side effect (printing) and does not
#'   return any value.
#' @param data `data.frame`. A data frame to print. This parameter cannot be
#'   `NULL`.
#' @param n_rows Integer. Number of rows to print from both the head and tail of
#'   the data frame. Defaults to 5.
#' @examples
#' ht(mtcars)
#'
#' # -------------------------------------------
#'
#' ht(data = mtcars, n_rows = 2)
#'
#' # -------------------------------------------
#'
#' ht(data = mtcars, n_rows = 6)
#' @export

ht <- function(data = NULL, n_rows = 5L) {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL", data = data)
  }

  data %>%
    data.table::data.table() %>%
    print(topn = n_rows)

  return(invisible(NULL))
}
