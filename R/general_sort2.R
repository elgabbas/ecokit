## |------------------------------------------------------------------------| #
# sort2 ----
## |------------------------------------------------------------------------| #

#' Sort alphanumeric strings with enhanced options
#'
#' This function extends the sorting capabilities for alphanumeric strings by
#' allowing for sorting of mixed numeric and character strings, with additional
#' control over sorting direction, treatment of `NA` and blank values, and
#' handling of numeric values represented as either decimal numbers or Roman
#' numerals. This function is a wrapper function for the [gtools::mixedsort]
#' function.
#' @inheritParams gtools::mixedsort
#' @name sort2
#' @return A vector of sorted alphanumeric strings.
#' @examples
#' # example code
#' (AA <- paste0("V", seq_len(12)))
#'
#' sort(x = AA)
#'
#' ecokit::sort2(x = AA)
#'
#' @export

sort2 <- function(
    x, decreasing = FALSE, na.last = TRUE, blank.last = FALSE,
    numeric.type = c("decimal", "roman"),
    roman.case = c("upper", "lower", "both")) {

  if (is.null(x) || is.null(numeric.type) || is.null(roman.case)) {
    ecokit::stop_ctx(
      "x, numeric.type, and roman.case cannot be NULL",
      x = x, numeric.type = numeric.type, roman.case = roman.case)
  }

  numeric.type <- numeric.type[1]
  roman.case <- roman.case[1]

  if (!numeric.type %in% c("decimal", "roman")) {
    ecokit::stop_ctx(
      "numeric.type must be either 'decimal' or 'roman'",
      numeric.type = numeric.type)
  }

  if (!roman.case %in% c("upper", "lower", "both")) {
    ecokit::stop_ctx(
      "roman.case must be one of 'upper', 'lower', or 'both'",
      roman.case = roman.case)
  }

  gtools::mixedsort(
    x = x, decreasing = decreasing, na.last = na.last,
    blank.last = blank.last, numeric.type = numeric.type,
    roman.case = roman.case)
}
