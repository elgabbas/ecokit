# # |------------------------------------------------------------------------| #
# cat_names ----
## |------------------------------------------------------------------------| #

#' Print Names of an Object with Optional Sorting
#'
#' Prints the names of an object to the console, with an option to sort them.
#' Supports custom separators and handles various edge cases.
#'
#' @param x An R object with names attribute (e.g., vector, list, data frame).
#' @param sort Logical. Whether to sort names using mixed alphanumeric sorting.
#'   Defaults to `FALSE`.
#' @param sep Character. Separate names in output. Defaults to newline (`"\n"`).
#' @param na_rm Logical. Whether to removes `NA` values from names before
#'   printing. Defaults to `TRUE`.
#' @param prefix Character. string to prepend to each name. Defaults to `NULL`.
#' @param ... Additional arguments passed to [base::cat()].
#'
#' @return Invisibly returns the vector of names (sorted if `sort = TRUE`).
#' @export
#' @author Ahmed El-Gabbas
#' @examples
#' # Basic usage
#' vec <- c(a1 = 1, b = 2, a2 = 3)
#' cat_names(vec)
#'
#' # Sorted names
#' cat_names(vec, sort = TRUE)
#'
#' # Custom separator and prefix
#' cat_names(vec, sep = ", ", prefix = "- ")
#'
#' # Handle NA names
#' vec_na <- c(a = 1, NA, c = 3)
#' cat_names(vec_na, na_rm = TRUE)
#' cat_names(vec_na, na_rm = TRUE, sort = TRUE)
#'
#' # Example with data frames
#' cat_names(mtcars)
#' cat_names(iris)

cat_names <- function(
    x, sort = FALSE, sep = "\n", na_rm = TRUE, prefix = NULL, ...) {

  # Input validation
  if (is.null(x)) {
    ecokit::stop_ctx("Input 'x' cannot be NULL")
  }

  # Extract names
  names_x <- names(x)

  # Check if names exist
  if (is.null(names_x)) {
    return(invisible(NULL))
  }

  # Handle NA names
  if (na_rm) {
    names_x <- names_x[!is.na(names_x)]
  }

  # Check if names are empty after NA removal
  if (length(names_x) == 0L) {
    return(invisible(NULL))
  }

  # Validate names are character
  if (!is.character(names_x)) {
    ecokit::stop_ctx("Names must be character strings")
  }

  # Apply prefix if provided
  if (!is.null(prefix)) {
    if (!is.character(prefix) || length(prefix) != 1L) {
      ecokit::stop_ctx("Prefix must be a single character string")
    }
    names_x <- paste0(prefix, names_x)
  }

  # Sort names if requested
  if (sort) {
    names_x <- gtools::mixedsort(names_x)
  }

  # Validate separator
  if (!is.character(sep) || length(sep) != 1L) {
    ecokit::stop_ctx("Separator must be a single character string")
  }

  # Print names
  cat(names_x, sep = sep, ...)

  # Invisible return
  invisible(NULL)
}
