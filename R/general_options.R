## |------------------------------------------------------------------------| #
# extract_options ----
## |------------------------------------------------------------------------| #

#' Extract Options Matching a Pattern
#'
#' Returns a subset of the current R session options whose names match a given
#' pattern.
#'
#' @param pattern Character string. Pattern to search for in option names. If
#'   empty (`""`), all options are returned.
#' @param case_sensitive Logical. If TRUE, pattern matching is case-sensitive.
#'   Default is FALSE.
#' @return A list of matched options, or all options if pattern is `""`. If no
#'   matches are found, returns `NULL` (invisibly) and prints a message.
#' @export
#' @author Ahmed El-Gabbas
#' @examples
#' # all options with "warn" in the name (case-insensitive)
#' ecokit::extract_options("warn")
#'
#' # options starting with "r" (case-sensitive)
#' ecokit::extract_options("^r", TRUE)

extract_options <- function(pattern = "", case_sensitive = FALSE) {

  ecokit::check_args(
    args_to_check = "case_sensitive", args_type = "logical",
    cat_timestamp = FALSE)

  if (!is.character(pattern) || length(pattern) != 1L) {
    ecokit::stop_ctx(
      "`pattern` has to be character of length 1", pattern = pattern,
      include_backtrace = TRUE)
  }

  # If pattern is empty, return all current options
  if (pattern == "") return(options())

  existing_options <- names(options())
  if (case_sensitive) {
    matched <- stringr::str_detect(existing_options, pattern)
  } else {
    matched <- stringr::str_detect(
      stringr::str_to_lower(existing_options),
      stringr::str_to_lower(pattern))
  }

  if (!any(matched)) {
    message("No options found with the specified pattern")
    return(invisible(NULL))
  }
  names_to_extract <- existing_options[matched]
  return(options()[names_to_extract])
}


## |------------------------------------------------------------------------| #
# remove_options ----
## |------------------------------------------------------------------------| #

#' Remove Options by Name or Pattern
#'
#' Removes options from the current R session by name or regular expression
#' pattern.
#'
#' @param pattern Character vector of option names to remove, or a pattern
#'   string if `regex = TRUE.`
#' @param regex Logical. If `TRUE`, treat `pattern` as a regular expression to
#'   match option names. Default is `FALSE`.
#' @param case_sensitive Logical. If `TRUE`, matching is case-sensitive. Default
#'   is `FALSE`.
#'
#' @return Invisibly returns `NULL`. Removes specified options if found.
#' @export
#' @author Ahmed El-Gabbas
#' @examples
#'  # removes option named "my_option"
#'  options(my_option = 42)
#'  ecokit::extract_options("my_option")
#'  ecokit::remove_options("my_option")
#'  ecokit::extract_options("my_option")
#'
#'  options(plot1 = 42, plot2 = "yes", plot_extra = TRUE)
#'  ecokit::remove_options("plot_", regex = FALSE)
#'  ecokit::extract_options("plot")
#'  ecokit::remove_options("plot_", regex = TRUE)
#'  ecokit::extract_options("plot")

remove_options <- function(
    pattern = NULL, regex = FALSE, case_sensitive = FALSE) {

  ecokit::check_args(
    args_to_check = "pattern", args_type = "character", cat_timestamp = FALSE)
  ecokit::check_args(
    args_to_check = c("regex", "case_sensitive"),
    args_type = "logical", cat_timestamp = FALSE)

  existing_options <- names(options())

  if (regex) {
    if (case_sensitive) {
      to_remove <- stringr::str_detect(existing_options, pattern)
    } else {
      to_remove <- stringr::str_detect(
        stringr::str_to_lower(existing_options), stringr::str_to_lower(pattern))
    }
    to_remove <- existing_options[to_remove]
  } else {
    to_remove <- intersect(pattern, existing_options)
  }

  if (length(to_remove) == 0L) return(invisible(NULL))
  for (opt in to_remove) {
    options(stats::setNames(list(NULL), opt))
  }
  invisible(NULL)
}
