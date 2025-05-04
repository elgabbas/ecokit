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
#' @param ... additional arguments to be passed to [base::cat()].
#' @name cat_sep
#' @inheritParams cat_time
#' @author Ahmed El-Gabbas
#' @return The function is called for its side effect (printing to the console)
#'   and does not return a meaningful value.
#' @examples
#' cat_sep()
#'
#' cat_sep(2)
#'
#' cat_sep(2,2,3)
#'
#' cat_sep(2,2,3, line_char = "*")
#'
#' cat_sep(2,2,3, line_char = "*", line_char_rep = 20)
#' @export

cat_sep <- function(
    n_separators = 1L, sep_lines_before = 0L, sep_lines_after = 1L,
    line_char = "-", line_char_rep = 50L, cat_bold = FALSE, cat_red = FALSE,
    ...) {

  # ****************************************************************

  # Check input arguments
  all_arguments <- ls(envir = environment())
  all_arguments <- purrr::map(
    all_arguments,
    function(x) get(x, envir = parent.env(env = environment()))) %>%
    stats::setNames(all_arguments)
  numeric_arguments <- c(
    "n_separators", "sep_lines_before", "sep_lines_after", "line_char_rep")
  ecokit::check_args(
    args_all = all_arguments,
    args_to_check = numeric_arguments, args_type = "numeric")
  ecokit::check_args(
    args_all = all_arguments,
    args_to_check = "line_char", args_type = "character")

  # ****************************************************************

  if (cat_bold) {
    line_char <- crayon::bold(line_char)
  }
  if (cat_red) {
    line_char <- crayon::red(line_char)
  }

  if (sep_lines_before > 0L) {
    cat(strrep("\n", sep_lines_before), ...)
  }

  paste(rep(line_char, line_char_rep), collapse = "") %>%
    rep(n_separators) %>%
    paste(collapse = "\n") %>%
    cat(...)

  if (sep_lines_after > 0L) {
    cat(strrep("\n", sep_lines_after), ...)
  }
  return(invisible(NULL))
}
