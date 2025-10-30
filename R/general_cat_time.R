## |------------------------------------------------------------------------| #
# cat_time ----
## |------------------------------------------------------------------------| #

#' Print text with time stamp
#'
#' This function prints a given text followed by the current time (and
#' optionally the date) to the console. It allows for customization of the time
#' zone, the inclusion of the date, and the number of newline characters to
#' print after the message.
#' @param text character; the text to print before the timestamp. If empty
#'   (default), only the timestamp is printed.
#' @param msg_n_lines integer; the number of newline characters to print after
#'   the message. Default is 1.
#' @param cat_timestamp logical; whether to include the time in the timestamp.
#'   Default is `TRUE`. If `FALSE`, only the text is printed.
#' @param cat_date logical; whether to include the date in the timestamp. Only
#'   effective if `time` is `TRUE`. Default is `FALSE`, meaning only the time is
#'   printed. If `TRUE`, the date is printed in the format `%d/%m/%Y %X`.
#' @param time_zone character; the time zone to use for the timestamp. Default
#'   is `CET`.
#' @param level integer; the level at which the message will be printed. If e.g.
#'   `level = 1L`, the following string will be printed at the beginning of the
#'   message: "   >>>   ". Default is `0`.
#' @param cat_bold logical; whether to print the text in bold. Default is
#'   `FALSE`.
#' @param cat_red logical; whether to print the text in red. Default is `FALSE`.
#' @param verbose logical; whether to print output to console. Default is
#'   `TRUE`. If `FALSE`, the function does nothing. This is useful to suppress
#'   the function output in certain contexts.
#' @param ... additional arguments passed to `cat`.
#' @name cat_time
#' @author Ahmed El-Gabbas
#' @return The function is called for its side effect of printing to the
#'   console.
#' @export
#' @examples
#' cat_time()
#'
#' cat_time(cat_date = TRUE)
#'
#' cat_time("time now")
#'
#' cat_time("\n\nTime now", msg_n_lines = 2L, level = 1L)
#'
#' cat_time(
#'   "\ntime now", cat_date = TRUE, cat_bold = TRUE, cat_red = TRUE,
#'   msg_n_lines = 2L, level = 1L)
#'
#' # The use of levels
#' {
#'   cat_time("Task 1")
#'   cat_time("subtask L1", level = 1L)
#'   cat_time("subtask L2", level = 2L)
#'   cat_time("subtask L3", level = 3L)
#' }
#'
#' # disabling the function output
#' cat_time(verbose = FALSE)


cat_time <- function(
    text = "", msg_n_lines = 1L, cat_timestamp = TRUE, cat_bold = FALSE,
    cat_red = FALSE, cat_date = FALSE, time_zone = "CET", level = 0L,
    verbose = TRUE, ...) {

  # return NULL if verbose is FALSE
  if (!is.logical(verbose) || length(verbose) != 1L) {
    ecokit::stop_ctx("`verbose` has to be logic of length 1", verbose = verbose)
  }
  if (!verbose) {
    return(invisible(NULL))
  }
  if (!is.character(text) || length(text) != 1L) {
    ecokit::stop_ctx(
      "`text` has to be character of length 1",
      text = text, include_backtrace = TRUE)
  }

  # Validate inputs
  ecokit::check_args(
    args_to_check = c("cat_timestamp", "cat_bold", "cat_red", "cat_date"),
    args_type = "logical")
  ecokit::check_args(
    args_to_check = c("msg_n_lines", "level"), args_type = "numeric")

  # Current time
  time_now <- lubridate::now(tzone = time_zone)

  # Format date / time
  if (cat_date && cat_timestamp) {
    time_now <- format(time_now, "%d/%m/%Y %X") #nolint: nonportable_path_lintr
    time_now_2 <- paste0(" - ", time_now)
  } else if (cat_date) {
    time_now <- format(time_now, "%d/%m/%Y") #nolint: nonportable_path_lintr
    time_now_2 <- paste0(" - ", time_now)
  } else if (cat_timestamp) {
    time_now <- format(time_now, "%X")
    time_now_2 <- paste0(" - ", time_now)
  } else {
    time_now <- time_now_2 <- ""
  }

  n_lines_before <- stringr::str_extract(text, "^\\n+") %>% #nolint: nonportable_path_lintr
    stringr::str_count("\n")
  if (is.na(n_lines_before)) {
    n_lines_before <- 0L
  }

  text <- stringr::str_remove(text, "^\\n+") #nolint: nonportable_path_lintr

  if (text == "") {
    if (n_lines_before > 0L) {
      text <- paste0(strrep("\n", n_lines_before), text)
    }
    text <- paste0(text, time_now)
  } else {
    if (level > 0L) {
      prefix <- rep("  >>>", each = level) %>%
        paste(collapse = "") %>%
        paste0("  ")
      text <- paste0(prefix, text)
    }

    if (n_lines_before > 0L) {
      text <- paste0(strrep("\n", n_lines_before), text)
    }
    text <- paste0(text, time_now_2)

  }

  if (cat_bold) {
    text <- crayon::bold(text)
  }
  if (cat_red) {
    text <- crayon::red(text)
  }

  cat(text, ...)
  cat(rep("\n", msg_n_lines))

  return(invisible(NULL))
}


# # ********************************************************************** #
# # ********************************************************************** #


# # format_number ------

#' Format a numbers with thousands separator and crayon styles
#'
#' Format numeric input using a specified thousands separator and optionally
#' apply crayon styling (`blue`, `red`, `underline`, `bold`). If multiple
#' numbers are provided they are formatted individually then collapsed into a
#' single comma-separated string.
#'
#' @param number Numeric vector to format.
#' @param big_mark Character of length 1 used as the thousands separator (passed
#'   to `format(..., big.mark = big_mark)`). Must be non-NULL, non-empty, and of
#'   length 1. Default: `","`.
#' @param blue Logical; if `TRUE` (default) the formatted output is wrapped with
#'   [crayon::blue()].
#' @param red Logical; if `TRUE` the formatted output is wrapped with
#'   [crayon::red()]. Default: `FALSE`.
#' @param bold Logical; if `TRUE` the formatted output is wrapped with
#'   [crayon::bold()]. Default: `FALSE`.
#' @param underline Logical; if `TRUE` the formatted output is wrapped with
#'   [crayon::underline()]. Default: `FALSE`.
#'
#' @details Input validation performed by the function:
#' - `big_mark` must not be `NULL`, must be a character of length 1,
#'   and must be non-empty.
#' - `number` must be numeric; otherwise an error is raised.
#' - `blue` and `red` cannot both be `TRUE` (mutually exclusive).
#'
#'   The function first formats numbers using `format(..., big.mark =
#'   big_mark)`, which returns a character vector. If the numeric input has
#'   length greater than one, it collapses the formatted values into a single
#'   string using `toString()`. Finally, the selected `crayon` styles are
#'   applied in sequence (`blue`, `red`, `underline`, `bold`) to the resulting
#'   character value.
#'
#' @return A character scalar containing the formatted number(s) with the
#'   requested `crayon` styling applied.
#'
#' @examples
#' # Single number (default: blue)
#' cat(format_number(1234567))
#'
#' # Multiple numbers collapsed to a single string
#' cat(format_number(c(1000, 2000000)))
#'
#' # Use a space as the thousands separator and apply red + bold
#' cat(
#'   format_number(
#'     1234567, big_mark = " ", blue = FALSE, red = TRUE, bold = TRUE))
#'
#' @author Ahmed El-Gabbas
#' @export

format_number <- function(
    number = NULL, big_mark = ",", blue = TRUE, red = FALSE,
    bold = FALSE, underline = FALSE) {

  # temporarily disable scientific annotations for formatting
  result <- withr::with_options(
    list(scipen = 999L),
    {
      # Validate inputs
      ecokit::check_args(
        args_to_check = c("blue", "red", "bold", "underline"),
        args_type = "logical")

      if (is.null(big_mark)) {
        ecokit::stop_ctx("`big_mark` cannot be NULL", big_mark = big_mark)
      }
      if (length(big_mark) != 1L || !is.character(big_mark) ||
          !nzchar(big_mark)) {
        ecokit::stop_ctx(
          "`big_mark` must be a character of length 1", big_mark = big_mark)
      }

      if (blue && red) {
        ecokit::stop_ctx("`blue` and `red` cannot both be TRUE")
      }
      if (!is.numeric(number)) {
        ecokit::stop_ctx("`number` must be numeric", number = number)
      }

      # Format number with big mark
      formatted_number <- format(number, big.mark = big_mark)

      # Collapse if length > 1
      if (length(formatted_number) > 1L) {
        formatted_number <- toString(formatted_number)
      }

      # Apply crayon styles in the following order:
      # blue/red (mutually exclusive) -> underline -> bold
      # Each style wraps the previous one if TRUE.
      if (blue) {
        formatted_number <- crayon::blue(formatted_number)
      }
      if (red) {
        formatted_number <- crayon::red(formatted_number)
      }
      if (underline) {
        formatted_number <- crayon::underline(formatted_number)
      }
      if (bold) {
        formatted_number <- crayon::bold(formatted_number)
      }

      formatted_number
    })

  result
}
