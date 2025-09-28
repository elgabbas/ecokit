## |------------------------------------------------------------------------| #
# cat_sep ----
## |------------------------------------------------------------------------| #

#' Print separator(s) to the console
#'
#' This function prints customizable separator lines to the console, optionally
#' preceded and followed by empty lines. It is useful for improving the
#' readability of console output in R scripts or during interactive sessions.
#' @param n_separators integer; the number of separator lines to print. Default
#'   is `1`.
#' @param sep_lines_before,sep_lines_after integer; the number of extra empty
#'   lines to print before and after the separator lines. Default is `0` and
#'   `1`, respectively.
#' @param line_char character; the character used to construct the separator
#'   line. Default is `"-"`.
#' @param line_char_rep integer; the number of times the character is repeated
#'   to form a separator line. Default is `50`.
#' @param verbose logical; whether to print output to console. Default is
#'   `TRUE`. If `FALSE`, the function does nothing. This is useful to suppress
#'   the function output in certain contexts.
#' @param ... additional arguments to be passed to [base::cat()].
#' @name cat_sep
#' @inheritParams cat_time
#' @author Ahmed El-Gabbas
#' @return The function is called for its side effect (printing to the console)
#'   and does not return a meaningful value.
#' @examples
#' cat_sep()
#'
#' cat_sep(n_separators = 2)
#'
#' cat_sep(n_separators = 2, sep_lines_before = 2, sep_lines_after = 3)
#'
#' cat_sep(
#'   n_separators = 2, sep_lines_before = 2,
#'   sep_lines_after = 3, line_char = "*")
#'
#' cat_sep(
#'   n_separators = 2, sep_lines_before = 2,
#'   sep_lines_after = 3, line_char = "*", line_char_rep = 20)
#' @export

cat_sep <- function(
    n_separators = 1L, sep_lines_before = 0L, sep_lines_after = 1L,
    line_char = "-", line_char_rep = 50L, cat_bold = FALSE, cat_red = FALSE,
    verbose = TRUE, ...) {

  # Check input arguments
  ecokit::check_args(
    args_to_check = "verbose", args_type = "logical", cat_timestamp = FALSE)
  if (!verbose) return(invisible(NULL))

  numeric_arguments <- c(
    "n_separators", "sep_lines_before", "sep_lines_after", "line_char_rep")
  ecokit::check_args(
    args_to_check = numeric_arguments, args_type = "numeric",
    cat_timestamp = FALSE)
  ecokit::check_args(
    args_to_check = "line_char", args_type = "character", cat_timestamp = FALSE)

  # ****************************************************************

  if (cat_bold) line_char <- crayon::bold(line_char)
  if (cat_red) line_char <- crayon::red(line_char)
  if (sep_lines_before > 0L)  cat(strrep("\n", sep_lines_before), ...)

  paste(rep(line_char, line_char_rep), collapse = "") %>%
    rep(n_separators) %>%
    paste(collapse = "\n") %>%
    cat(...)

  if (sep_lines_after > 0L)  cat(strrep("\n", sep_lines_after), ...)
  return(invisible(NULL))
}
