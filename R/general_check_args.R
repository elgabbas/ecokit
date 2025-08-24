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
#' @param args_to_check Character vector. Names of the arguments to be checked.
#' @param args_type Character. The expected type of the arguments. Must be one
#'   of "character", "logical", or "numeric".
#' @param arg_length Numeric vector. Expected length of each argument in
#'   `args_to_check`. Default is 1L.
#' @param ... Additional arguments passed to [ecokit::stop_ctx].
#' @return The function does not return a value but will stop execution and
#'   throw an error if any of the specified arguments do not match the expected
#'   type.
#' @export
#' @examples
#' f1 <- function(x = "AA", y = "BB", z = 1) {
#'  # Check if x and y are a character
#'  check_args(args_to_check = c("x", "y"), args_type = "character")
#'
#'  # Check if z is a numeric
#'  check_args(args_to_check = "z", args_type = "numeric")
#' }
#'
#' f1(x = "X", z = 20)
#' try(f1(x = 1))
#'
#' try(f1(x = c("X1", "x2", "x3"), y = c(20, 30)))
#'
#' f2 <- function(x = "AA", y = "BB", z = 1) {
#'  check_args(
#'   args_to_check = c("x", "y"), args_type = "character", arg_length = c(3, 2))
#' }
#' f2(x = c("X1", "x2", "x3"), y = c("20", "30"))

check_args <- function(
    args_to_check = NULL, args_type = NULL, arg_length = 1L, ...) {

  if (is.null(sys.call(-1L))) {
    ecokit::stop_ctx(
      "`check_args` function must be called from within another function",
      cat_timestamp = FALSE, ...)
  }

  if (is.null(args_to_check) || is.null(args_type)) {
    ecokit::stop_ctx(
      "`args_to_check` or `args_type` cannot be NULL",
      args_to_check = args_to_check, args_type = args_type, ...)
  }
  if (!is.character(args_to_check) || length(args_to_check) < 1L ||
      !all(nzchar(args_to_check))) {
    ecokit::stop_ctx(
      "`args_to_check` must be a character vector of length >= 1",
      args_to_check = args_to_check, ...)
  }
  if (!is.numeric(arg_length) || !all(arg_length == as.integer(arg_length))) {
    ecokit::stop_ctx(
      "`arg_length` must be a numeric value", arg_length = arg_length, ...)
  }
  if (length(arg_length) == 1L && length(args_to_check) > 1L) {
    arg_length <- rep(arg_length, length(args_to_check))
  }
  if (length(args_to_check) != length(arg_length)) {
    ecokit::stop_ctx(
      "`args_to_check` must have length equal to `arg_length`",
      args_to_check = args_to_check, arg_length = arg_length, ...)
  }

  if (!is.character(args_type) || length(args_type) != 1L ||
      !nzchar(args_type)) {
    ecokit::stop_ctx(
      "`args_type` must be a character vector of length 1",
      args_type = args_type, ...)
  }
  if (!args_type %in% c("character", "logical", "numeric")) {
    ecokit::stop_ctx(
      "`args_type` must be one of 'character', 'logical', or 'numeric'",
      args_type = args_type, ...)
  }

  arg_list <- mget(
    args_to_check, envir = parent.frame(), ifnotfound = list(NULL))

  length_mismatches <- purrr::map_lgl(
    .x = seq_len(length(arg_list)),
    .f = ~ length(arg_list[[.x]]) != arg_length[.x])
  if (any(length_mismatches)) {
    ecokit::stop_ctx(
      "`arg_length` must match the length of the arguments",
      arguments = args_to_check[length_mismatches],
      lengths = lengths(arg_list[length_mismatches]),
      required_lengths = arg_length[length_mismatches], ...)
  }

  # Check for missing arguments in argument list
  args_missing <- purrr::map_lgl(arg_list, is.null)
  missing_arguments <- args_to_check[args_missing]
  if (length(missing_arguments) > 0L) {
    ecokit::stop_ctx(
      "Some arguments are missing", missing_arguments = missing_arguments, ...)
  }

  switch(
    args_type,
    character = {
      invalid_arguments <- purrr::map_lgl(
        .x = arg_list, .f = ~ !inherits(.x, "character") || !all(nzchar(.x)))
      invalid_arguments <- sort(args_to_check[invalid_arguments])
      if (length(invalid_arguments) > 0L) {
        ecokit::stop_ctx(
          "The following argument(s) must be character",
          invalid_arguments = invalid_arguments,
          length_MissingArgs = length(invalid_arguments), ...)
      }
    },
    logical = {
      invalid_arguments <- purrr::map_lgl(
        .x = arg_list, .f = ~ !inherits(.x, "logical"))
      invalid_arguments <- sort(args_to_check[invalid_arguments])
      if (length(invalid_arguments) > 0L) {
        ecokit::stop_ctx(
          "The following argument(s) must be logical",
          invalid_arguments = invalid_arguments,
          length_MissingArgs = length(invalid_arguments), ...)
      }

    },
    numeric = {
      invalid_arguments <- purrr::map_lgl(
        .x = arg_list,
        .f = ~ !(inherits(.x, "numeric") || inherits(.x, "integer")))
      invalid_arguments <- sort(args_to_check[invalid_arguments])
      if (length(invalid_arguments) > 0L) {
        ecokit::stop_ctx(
          "The following argument(s) must be numeric",
          invalid_arguments = invalid_arguments,
          length_MissingArgs = length(invalid_arguments), ...)
      }
    })

  return(invisible(NULL))
}
