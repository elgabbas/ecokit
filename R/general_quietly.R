# # ========================================================================= #
# quietly ------
# # ========================================================================= #

#' Quietly Evaluate an Expression with Custom Warning Patterns
#'
#' Evaluates an R expression while suppressing package startup messages and
#' selected warnings. By default, warnings containing "was built under R
#' version" or "Loading required namespace" are muffled. Additional warning
#' patterns can be provided via `...`.
#'
#' @param expr An R expression to be evaluated quietly. This can be a single
#'   expression or a block of code wrapped in curly brackets.
#' @param ...  Additional character strings. Each value will be treated as a
#'   pattern to match in warning messages to muffle. For example, `quietly(expr,
#'   "Picked up JAVA_TOOL_OPTIONS", "Couldn't flush user prefs")`.
#'
#' @return The result of evaluating `expr`, with specified messages and warnings
#'   suppressed.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' # Suppress a package startup message and a version warning
#' quietly({
#'   warning("This package was built under R version 4.3.1", call. = FALSE)
#' })
#'
#' # Suppress a custom warning pattern (e.g., JAVA_TOOL_OPTIONS)
#' quietly({
#'  warning(
#'    "Picked up JAVA_TOOL_OPTIONS: -Djava.util.prefs.userRoot=/tmp/.java1234",
#'    call. = FALSE)
#' },
#' "Picked up JAVA_TOOL_OPTIONS")
#'
#' # Suppress multiple custom warning patterns
#' quietly({
#'   warning("Couldn't flush user prefs", call. = FALSE)
#'   warning("java.util.prefs.FileSystemPreferences error", call. = FALSE)
#' },
#' "Couldn't flush user prefs", "java.util.prefs.FileSystemPreferences")
#'
#' # Show that a non-matching warning still prints
#' quietly({
#'   warning("This is a normal warning and should be displayed", call. = FALSE)
#' },
#' "Picked up JAVA_TOOL_OPTIONS")
#'
#' # Use a code block with multiple lines, some of which trigger warnings
#' quietly({
#'   # suppressed by default
#'   warning("Loading required namespace: foo", call. = FALSE)
#'   # suppressed by default
#'   warning("was built under R version 4.3.0", call. = FALSE)
#'   # not suppressed, will be shown
#'   warning("Something else", call. = FALSE)
#' })
#'
#' if (FALSE) {
#'   # Error if ... is not character
#'   quietly({ warning("test", call. = FALSE) }, 1L)
#'
#'   # Error if expr is not a language object
#'   quietly("not an expression")
#' }

quietly <- function(expr, ...) {

  dots <- list(...)
  # Check ... are all character (length 1 or vector)
  if (!all(vapply(dots, is.character, logical(1L)))) {
    ecokit::stop_ctx(
      "All `...` arguments to `quietly` must be character strings.",
      class_dots = toString(sapply(dots, class))) # nolint: undesirable_function_linter
  }

  # Capture the unevaluated expression
  expr_sub <- substitute(expr)

  # Check expr is a language object (expression or call), not a vector of length
  # > 1
  if (!is.language(expr_sub)) {
    ecokit::stop_ctx(
      paste0(
        "Argument `expr` must be an R expression (code ",
        "or block wrapped in curly brackets)."),
      class_expr = class(expr_sub))
  }

  patterns <- c(
    "was built under R version", "Loading required namespace",
    unlist(dots))

  withCallingHandlers(
    suppressPackageStartupMessages(eval(expr_sub, parent.frame())),
    warning = function(w) {
      warnings_to_hide <- paste(patterns, collapse = "|")
      if (grepl(warnings_to_hide, conditionMessage(w))) {
        invokeRestart("muffleWarning")
      }
    }
  )
}
