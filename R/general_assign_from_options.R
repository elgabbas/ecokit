## |------------------------------------------------------------------------| #
# assign_from_options ----
## |------------------------------------------------------------------------| #

#' Assign Argument Value from Option if NULL or Missing
#'
#' This utility function is designed to be called from within another function.
#' If a function argument is missing or `NULL`, this function attempts to assign
#' a value from a global option. If neither the argument nor the option is set,
#' an informative error is thrown. Optionally, it checks that the resulting
#' value inherits from a specified class.
#'
#' @param arg Bare name of the argument to check and (potentially) assign.
#'   Should be unquoted.
#' @param option_name Character. The name of the global option (as in
#'   `getOption()` to use as a fallback value.
#' @param expected_class Character vector or `NULL`; if not `NULL`, the result
#'   must inherit from one of these classes, otherwise an error is thrown.
#' @author Ahmed El-Gabbas
#' @details This function is intended for use inside another function's body to
#'   help set default argument values using global options.
#'
#' - If the argument is missing, it assigns the value from
#'   `getOption(option_name)`, if available.
#' - If the argument is explicitly supplied but is `NULL`, it will also assign
#'   the value from the option if available.
#' - If neither the argument nor the option is set, an error is thrown.
#' - If `expected_class` is provided, the final value is checked for class
#'   inheritance.
#' @return Invisibly returns the final value of the argument (after assignment,
#'   if performed).
#' @export
#' @examples
#' my_fun <- function(x = NULL) {
#'   ecokit::assign_from_options(x, "my_x_option", expected_class = "numeric")
#'   x  # x is now set from option if not provided
#' }
#' options(my_x_option = 42)
#'
#' # returns 42
#' my_fun()
#'
#' # returns 1.5
#' my_fun(1.5)
#'
#' ecokit::remove_options("my_x_option")
#'
#' # error: Argument `x` is missing/NULL and option `my_x_option` is not set.
#' try(my_fun())

assign_from_options <- function(arg, option_name, expected_class = NULL) {

  if (sys.parent() == 0L) {
    ecokit::stop_ctx(
      "assign_if_options_null() must be called from inside another function.",
      cat_timestamp = FALSE)
  }

  if (missing(option_name) || !rlang::is_string(option_name) ||
      is.na(option_name) || !nzchar(option_name)) {
    ecokit::stop_ctx(
      "`option_name` must be a non-empty character scalar.",
      cat_timestamp = FALSE)
  }

  pf <- parent.frame()

  arg_sym <- tryCatch(rlang::ensym(arg), error = function(e) NULL)
  if (is.null(arg_sym)) {
    ecokit::stop_ctx(
      paste0(
        "`arg` must be a bare argument name or a single character ",
        "string naming the argument."),
      cat_timestamp = FALSE)
  }
  arg_name <- rlang::as_name(arg_sym)

  if (!rlang::env_has(pf, arg_name)) {
    ecokit::stop_ctx(
      paste0(
        "Argument `", arg_name,
        "` was not found in the calling function's environment."))
  }

  # Was the argument supplied by the caller (even if it has a default)?
  arg_missing <- eval(
    substitute(missing(ARG), list(ARG = as.name(arg_name))), envir = pf)

  # Get value without forcing a missing binding to error
  val <- rlang::env_get(pf, arg_name, default = rlang::missing_arg())

  # Option value (may be NULL)
  opt_val <- getOption(option_name, default = NULL)

  # Overwrite defaults with options when the arg is not supplied by the caller.
  if (isTRUE(arg_missing)) {
    if (!is.null(opt_val)) {
      val <- opt_val
      rlang::env_poke(pf, arg_name, val)
    } else if (is.null(val)) {
      ecokit::stop_ctx(
        paste0(
          "Argument `", arg_name, "` is NULL and option `",
          option_name, "` is not set. Provide `", arg_name,
          "` or set options(", option_name, " = ...)."),
        cat_timestamp = FALSE)
    }
  } else if (is.null(val)) {
    if (is.null(opt_val)) {
      ecokit::stop_ctx(
        paste0(
          "Argument `", arg_name, "` is NULL and option `", option_name,
          "` is not set. Provide `", arg_name,
          "` or set options(", option_name, " = ...)."),
        cat_timestamp = FALSE)
    }
    val <- opt_val
    rlang::env_poke(pf, arg_name, val)
  }

  if (!is.null(expected_class)) {
    expected_class <- base::trimws(expected_class)
    if (!is.character(expected_class) || length(expected_class) < 1L ||
        anyNA(expected_class)) {
      ecokit::stop_ctx(
        "`expected_class` must be a non-empty character vector of class names.",
        cat_timestamp = FALSE)
    }
    if (!inherits(val, expected_class)) {
      ecokit::stop_ctx(
        paste0(
          "Argument `", arg_name, "` must inherit from class [",
          toString(expected_class), "], but has class [",
          toString(base::class(val)), "]."),
        cat_timestamp = FALSE)
    }
  }

  invisible(val)
}
