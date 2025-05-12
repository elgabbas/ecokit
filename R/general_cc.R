## |------------------------------------------------------------------------| #
# cc ----
## |------------------------------------------------------------------------| #

#' Concatenate without quotes
#'
#' Concatenates one or more inputs into a single string without quotes. Inputs
#' can be unquoted symbols (e.g., variable names), quoted strings, numbers, or
#' simple expressions. Useful for creating strings from variable names or data
#' without including quotes.
#'
#' @param ... One or more inputs: unquoted symbols (e.g., `A`, `B`), quoted
#'   strings (e.g., `"text"`), numbers (e.g., `10`), or simple expressions
#'   (e.g., `1:3`). Invalid R symbols (e.g., `12a`) will cause an error unless
#'   quoted.
#' @param collapse An optional single character string to separate concatenated
#'   elements (e.g., `""`, " "` or `","`). If `NULL` (default), returns a
#'   character vector of individual elements.
#' @param unique Logical. If `TRUE`, returns only unique values. Default is
#'   `FALSE`.
#' @param sort Logical. If `TRUE`, sorts the result alphanumerically using
#'   [gtools::mixedsort]. Default is `FALSE`.
#' @return A single character string with concatenated inputs (if `collapse` is
#'   a string) or a character vector (if `collapse = NULL``).
#' @author Ahmed El-Gabbas
#' @export
#' @name cc
#' @examples
#' # Concatenate symbols
#' cc(A, B, C)
#'
#' # Concatenate symbols into a single string
#' cc(A, B, C, collapse = "")
#' cc(A, B, C, collapse = " ")
#' cc(A, B, C, collapse = "|")
#'
#' # Mix symbols and strings
#' cc(A, B, "A and B")
#'
#' # Include numbers
#' cc(A, B, 10)
#'
#' # Handle vectors
#' cc(1:3, "test")
#'
#' cc(1:3, cc(test1, test2), names(iris))
#'
#' # remove duplicates
#' cc(10:3, 3:5, 5:8, unique = TRUE)
#'
#' # sort alphanumerically
#' cc(A1, A2, A10, A010, A25, sort = TRUE)
#' sort(c("A1", "A2", "A10", "A010", "A25")) # base sort
#'
#' \dontrun{
#'   # Invalid symbol (will error)
#'   cc(12a)
#'   # Valid when quoted or backticked
#'   cc("12a")
#'   cc(`12a`)
#' }

cc <- function(..., collapse = NULL, unique = FALSE, sort = FALSE) {

  # Validate collapse argument
  if (!is.null(collapse) &&
      (!is.character(collapse) || length(collapse) != 1L)) {
    ecokit::stop_ctx(
      "`collapse` must be `NULL` or a single character string.",
      collapse = collapse)
  }

  # Capture all inputs as expressions
  inputs <- tryCatch(
    rlang::enexprs(...),
    error = function(e) {
      ecokit::stop_ctx(
        paste0(
          "Invalid input: ", e$message,
          ". Ensure inputs are valid R symbols, quoted strings, ",
          "or simple expressions."))
    })

  result <- inputs %>%
    purrr::map(
      .f = ~ {

        item_class <- class(.x)

        if (inherits(.x, "name")) {
          # Unquoted symbols (e.g., A, B)
          rlang::as_string(.x)
        } else {
          # Strings, numbers, or expressions
          tryCatch(
            expr = {
              # Evaluate if possible (e.g., 1:3, numbers)
              evaluated <- eval(.x, envir = parent.frame())
              # Convert to string
              as.character(evaluated)
            },
            error = function(e) {
              deparse(.x)
            })
        }
      }) %>%
    unlist() %>%
    stringr::str_remove_all("`")

  if (unique) {
    result <- unique(result)
  }

  if (sort) {
    result <- gtools::mixedsort(result)
  }

  if (is.null(collapse)) {
    result
  } else {
    paste(result, collapse = collapse)
  }
}
