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

  ecokit::check_args(args_to_check = "case_sensitive", args_type = "logical")

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

  ecokit::check_args(args_to_check = "pattern", args_type = "character")
  ecokit::check_args(
    args_to_check = c("regex", "case_sensitive"), args_type = "logical")

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

## |------------------------------------------------------------------------| #
# get_option_with_default ----
## |------------------------------------------------------------------------| #

#' Retrieve Option Value with Function Argument Default Fallback
#'
#' This function returns the value of a specified R option if it is set;
#' otherwise, it falls back to the default value of a specified argument of a
#' given function. The function can be identified by name only or with package
#' qualification (e.g., `"pkg::fun"`). It supports arguments with default values
#' that are constants or quoted expressions.
#'
#' **Important:** This function only works for standard R functions whose
#' default argument values are accessible via `formals()`. It does **not** work
#' for primitive functions (such as `max`, `mean`), functions implemented in
#' C/C++, S4 methods, or functions whose defaults are not accessible
#' programmatically.
#'
#' @param option_name Character. The name of the R option to retrieve (e.g.,
#'   `"my_pkg_option"`).
#' @param fun_name Character. The name of the function, optionally qualified
#'   with a package (e.g., `"my_fun"` or `"mypkg::my_fun"`).
#' @param arg_name Character. The name of the argument whose default value
#'   should be used as a fallback.
#'
#' @return The value of the option if set, otherwise the default value of the
#'   specified function argument. Returns `NULL` if the default is not
#'   accessible (e.g., for primitive or non-standard functions).
#'
#' @examples
#' # No option is called `.add_changed`
#' getOption(".add_changed")
#'
#' # return the default value of the `.add` argument of `dplyr::group_by()`
#' get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#'
#' # Setting and retrieving the option
#' options(.add_changed = TRUE)
#' get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#'
#' # Removing the option, should fall back to default again
#' ecokit::remove_options(".add_changed")
#' get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#'
#' # Will return NULL for primitives:
#' get_option_with_default("base_max_na.rm", "base::max", "na.rm")
#'
#' @export
#' @author Ahmed El-Gabbas

get_option_with_default <- function(option_name, fun_name, arg_name) {

  # Get function object, handling package qualification if present
  fn <- if (grepl("::", fun_name)) {
    parts <- strsplit(fun_name, "::")[[1L]]
    get(parts[2L], envir = asNamespace(parts[1L]))
  } else {
    get(fun_name, mode = "function")
  }

  # Get default argument value; will be NULL for primitives/C++/S4/non-standard
  default <- tryCatch(formals(fn)[[arg_name]], error = function(e) NULL)

  # Evaluate default if it's a language object (e.g., expression, call)
  default <- if (is.language(default)) eval(default) else default

  # Get option or default
  val <- getOption(option_name, default = default)

  # Evaluate if it's still a language object (e.g., default was quote(expr))
  if (is.language(val)) eval(val) else val
}
