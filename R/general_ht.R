## |------------------------------------------------------------------------| #
# ht ----
## |------------------------------------------------------------------------| #

#' Print head and tail of a data frame or vector with indices
#'
#' Prints the first and last few rows of a data frame or elements of a vector,
#' displaying row numbers for data frames or indices for vectors in a style
#' similar to `data.table`. Useful for quickly inspecting the structure and
#' contents of large data frames or vectors, with explicit row or index numbers.
#'
#' @name ht
#' @author Ahmed El-Gabbas
#' @return The function is used for its side effect (printing) and returns
#'   `invisible(NULL)`.
#' @param data A data frame or vector (numeric, character, or other atomic
#'   types). This parameter cannot be `NULL`.
#' @param n_rows Integer. Number of rows (for data frames) or elements (for
#'   vectors) to print from both the head and tail. Defaults to 5.
#' @export
#' @examples
#' # Data frame examples
#'
#' ht(mtcars)
#'
#' ht(data = mtcars, n_rows = 2)
#'
#' ht(data = mtcars, n_rows = 6)
#'
#' # -------------------------------------------
#'
#' # Vector examples
#'
#' ht(1:100)
#'
#' ht(letters)
#'
#' colour_vect <- colours()
#' colour_vect <- seq_along(colour_vect) %>%
#'   stats::setNames(paste0("colour:", colour_vect))
#' head(colour_vect)
#' ht(colour_vect)

ht <- function(data = NULL, n_rows = 5L) {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL")
  }
  if (is.list(data) && !is.data.frame(data)) {
    ecokit::stop_ctx(
      "`data` cannot be a list unless it is a data frame",
      class_data = class(data))
  }
  if (!is.numeric(n_rows) || !is.finite(n_rows) || n_rows < 0L) {
    ecokit::stop_ctx(
      "`n_rows` must be non-negative finite number", n_rows = n_rows)
  }

  n_rows <- as.integer(ceiling(n_rows))

  # Handle empty inputs
  if ((is.data.frame(data) && nrow(data) == 0L) ||
      (is.atomic(data) && length(data) == 0L)) {
    cat("Empty input\n")
    return(invisible(NULL))
  }

  if (is.vector(data)) {
    if (is.null(names(data))) {
      data2 <- tibble::tibble(value = data)
    } else {
      data2 <- tibble::tibble(name = names(data), value = data)
    }
  } else if (is.data.frame(data)) {
    data2 <- data
  } else {
    ecokit::stop_ctx(
      "`data` must be a data frame or atomic vector",
      data = data, class_data = class(data))
  }

  if (!requireNamespace("data.table", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `data.table` package is required to print data frames.")
  }

  data.table::data.table(data2) %>%
    print(topn = n_rows)

  return(invisible(NULL))
}
