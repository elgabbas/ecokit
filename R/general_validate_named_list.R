#' Validate a Named List Against Required Elements
#'
#' Checks that `x` is a named list whose elements match `valid_names`. A
#' contextual error is raised via [ecokit::stop_ctx()] if any check fails,
#' reporting missing or unexpected names where relevant.
#'
#' @param x A named list to validate.
#' @param valid_names Character vector of required element names. Order is
#'   ignored; validation uses set equality.
#' @param object_name Character string used in error messages to identify `x`.
#'   Defaults to the unevaluated name of `x`.
#' @param exact_length Logical. If `TRUE` (default), `x` must contain exactly
#'   `length(valid_names)` elements. If `FALSE`, only names are checked.
#'
#' @return Invisibly returns `TRUE` if all checks pass.
#'
#' @examples
#' valid_names <- c("a", "b", "c")
#' validate_named_list(list(a = 1, b = 2, c = 3), valid_names)
#'
#' \dontrun{
#' validate_named_list(list(a = 1, b = 2), valid_names)
#' validate_named_list(list(a = 1, b = 2, d = 3), valid_names)
#' }
#'
#' @seealso [ecokit::stop_ctx()]
#' @author Ahmed El-Gabbas
#' @export

validate_named_list <- function(
    x, valid_names, object_name = deparse(substitute(x)), exact_length = TRUE) {

  ecokit::check_args(args_to_check = "exact_length", args_type = "logical")

  if (!inherits(x, "list")) {
    ecokit::stop_ctx(
      sprintf("`%s` must be a list", object_name),
      class_x = class(x))
  }

  if (!is.character(valid_names)) {
    ecokit::stop_ctx("`valid_names` must be character vector.")
  }

  if (length(valid_names) == 0L) {
    ecokit::stop_ctx("`valid_names` must be character vector of length > 0.")
  }

  if (exact_length && length(x) != length(valid_names)) {
    ecokit::stop_ctx(
      sprintf(
        "`%s` must contain exactly %d elements", object_name,
        length(valid_names)),
      expected_length = length(valid_names), actual_length = length(x),
      names_x = names(x))
  }

  if (!setequal(names(x), valid_names)) {
    ecokit::stop_ctx(
      sprintf(
        "`%s` must be a list with elements: %s", object_name,
        toString(valid_names)),
      additional_names = setdiff(names(x), valid_names),
      missing_names = setdiff(valid_names, names(x)))
  }

  invisible(TRUE)
}
