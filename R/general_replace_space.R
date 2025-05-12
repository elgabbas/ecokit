## |------------------------------------------------------------------------| #
# replace_space ----
## |------------------------------------------------------------------------| #

#' Replace whitespace with underscores
#'
#' Replaces all whitespace characters (spaces, tabs, etc.) with underscores in a
#' character vector. This is a wrapper around [stringr::str_replace_all()] for
#' formatting strings in contexts where whitespace is not allowed (e.g., file
#' names, variable names). Optionally, a custom replacement character can be
#' specified.
#'
#' @param x A character vector. Each element is processed to replace whitespace
#'   with underscores. Missing values (`NA`) are preserved.
#' @param replacement A single character string to replace whitespace. Defaults
#'   to `"_"` (underscore). Must be of length 1.
#' @name replace_space
#' @return A character vector of the same length as `x`, with all whitespace
#'   characters replaced by `replacement`. Missing values (`NA`) are returned
#'   unchanged.
#' @export
#' @seealso [stringr::str_replace_all()] for the underlying function, [gsub()]
#'   for base R alternative.
#' @examples
#' # Basic usage
#' replace_space("Genus species")
#'
#' # Vector input
#' replace_space(c("Genus species1", "Genus species2"))
#' replace_space(c("Genus species 1", "Genus species 2"))
#'
#' # Multiple whitespace types
#' replace_space("Genus   species\tname")
#'
#' # Custom replacement
#' replace_space("Genus species", replacement = "-")
#'
#' # Handle missing values
#' replace_space(c("Genus species 1", NA, "Genus species 2"))
#'
#' # Empty strings
#' replace_space("")

replace_space <- function(x, replacement = "_") {

  # Validate inputs
  if (is.null(x)) {
    ecokit::stop_ctx("Argument 'x' cannot be NULL.")
  }

  if (!is.character(x)) {
    ecokit::stop_ctx("Argument 'x' must be a character vector.", x = x)
  }

  if (!is.character(replacement) || length(replacement) != 1L) {
    ecokit::stop_ctx(
      "Argument 'replacement' must be a single character string.",
      replacement = replacement)
  }

  # Replace all whitespace with replacement
  stringr::str_replace_all(x, "\\s+", replacement)
}
