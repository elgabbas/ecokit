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

cat_time <- function(
    text = "", msg_n_lines = 1L, cat_timestamp = TRUE, cat_bold = FALSE,
    cat_red = FALSE, cat_date = FALSE, time_zone = "CET", level = 0L, ...) {

  # Validate inputs
  all_arguments <- ls(envir = environment())
  all_arguments <- purrr::map(
    all_arguments,
    function(x) get(x, envir = parent.env(env = environment()))) %>%
    stats::setNames(all_arguments)
  ecokit::check_args(
    args_all = all_arguments, args_type = "logical",
    args_to_check = c("cat_timestamp", "cat_bold", "cat_red", "cat_date"))
  ecokit::check_args(
    args_all = all_arguments, args_type = "numeric",
    args_to_check = c("msg_n_lines", "level"))
  rm(all_arguments, envir = environment())

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
