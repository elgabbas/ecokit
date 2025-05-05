## |------------------------------------------------------------------------| #
# check_args ----
## |------------------------------------------------------------------------| #

#' Check function arguments for specific types
#'
#' This function checks if the specified arguments of a function match the
#' expected type. It is useful for validating function inputs.
#'
#' @name check_args
#' @author Ahmed El-Gabbas
#' @param args_all Character vector. Input parameters of the function.
#'   Usually as a result of `formals()` function
#' @param args_to_check Character vector. Names of the arguments to be
#'   checked.
#' @param args_type Character. The expected type of the arguments. Must be
#'   one of "character", "logical", or "numeric".
#' @return The function does not return a value but will stop execution and
#'   throw an error if any of the specified arguments do not match the expected
#'   type.
#' @export
#' @examples
#' f1 <- function(x = "AA", y = "BB", z = 1) {
#'   all_arguments <- ls(envir = environment())
#'   all_arguments <- purrr::map(
#'     all_arguments,
#'     function(x) get(x, envir = parent.env(env = environment()))) %>%
#'     stats::setNames(all_arguments)
#'
#'  # Check if x and y are a character
#'  check_args(
#'     args_all = all_arguments, args_type = "character",
#'     args_to_check = c("x", "y"))
#'
#'  # Check if z is a numeric
#'  check_args(
#'     args_all = all_arguments, args_type = "numeric",
#'     args_to_check = "z")
#'
#'  # the rest of the function
#'  }
#'
#'  # no output as x is a character
#'  f1(x = "X")
#'
#'  # no output as z is a numeric
#'  f1(z = 20)
#'
#'  # error as x is not a character
#'  try(f1(x = 1))

check_args <- function(args_all, args_to_check, args_type) {

  if (is.null(args_all) || is.null(args_to_check) || is.null(args_type)) {
    ecokit::stop_ctx(
      "`args_all`, `args_to_check`, or `args_type` cannot be NULL",
      args_all = args_all, args_to_check = args_to_check,
      args_type = args_type)
  }

  args_type <- match.arg(
    arg = args_type, choices = c("character", "logical", "numeric"))

  if (args_type == "character") {
    missing_arguments <- args_all[args_to_check] %>%
      purrr::map(~inherits(.x, "character") && all(nzchar(.x))) %>%
      purrr::keep(.p = Negate(isTRUE)) %>%
      names() %>%
      sort()

    if (length(missing_arguments) > 0) {
      ecokit::stop_ctx(
        paste0(
          "The following character argument(s) must be character\n  >>  ",
          paste(missing_arguments, collapse = " | ")),
        length_MissingArgs = length(missing_arguments))
    }
  }

  if (args_type == "logical") {
    missing_arguments <- args_all[args_to_check] %>%
      purrr::map(.f = inherits, what = "logical") %>%
      purrr::keep(.p = Negate(isTRUE)) %>%
      names() %>%
      sort()

    if (length(missing_arguments) > 0) {
      ecokit::stop_ctx(
        paste0(
          "The following argument(s) must be logical\n  >>  ",
          paste(missing_arguments, collapse = " | ")),
        length_MissingArgs = length(missing_arguments))
    }
  }

  if (args_type == "numeric") {
    missing_arguments <- args_all[args_to_check] %>%
      purrr::map(~(inherits(.x, "numeric") || inherits(.x, "integer"))) %>%
      purrr::keep(.p = Negate(isTRUE)) %>%
      names() %>%
      sort()

    if (length(missing_arguments) > 0) {
      ecokit::stop_ctx(
        paste0(
          "The following argument(s) must be numeric or integer\n  >>  ",
          paste(missing_arguments, collapse = " | ")),
        length_MissingArgs = length(missing_arguments))
    }
  }

  return(invisible(NULL))
}
