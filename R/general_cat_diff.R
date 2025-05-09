## |------------------------------------------------------------------------| #
# cat_diff ----
## |------------------------------------------------------------------------| #
#
#' Print time difference
#'
#' This function calculates the time difference from a given initial time to the
#' current time and prints it with a specified prefix. Optionally, it can also
#' print a session summary.
#'
#' @name cat_diff
#' @author Ahmed El-Gabbas
#' @param init_time `POSIXct`. The initial time from which the difference is
#'   calculated.
#' @param chunk_text Character. The message printed as chunk info. Default
#'   value: `Session summary`. See: [info_chunk] for more information.
#' @param prefix Character. prefix to prepend to the printed time difference.
#'   Defaults to "Completed in ".
#' @param cat_info Logical. If `TRUE`, prints a session summary using
#'   [ecokit::info_chunk] ("Session summary"). Defaults to `FALSE`.
#' @param ... Additional arguments for [cat_time].
#' @return The function is used for its side effect of printing to the console
#'   and does not return any value.
#' @inheritParams cat_time
#' @export
#' @examples
#' # basic usage
#' reference_time <- (lubridate::now() - lubridate::seconds(45))
#'
#' cat_diff(reference_time)
#'
#' # custom prefix text
#' cat_diff(reference_time, prefix = "Finished in ")
#'
#' # level = 1
#' cat_diff(reference_time, prefix = "Finished in ", level = 1L)
#'
#' # print date
#' cat_diff(reference_time, prefix = "Finished in ", cat_timestamp = TRUE)
#'
#' # print date and time
#' cat_diff(reference_time, prefix = "Finished in ", cat_date = TRUE)
#'
#' # show chunk info
#' cat_diff(reference_time, cat_info = TRUE, prefix = "Finished in ")
#'
#' # custom chunk info text
#' cat_diff(
#'   reference_time, cat_info = TRUE, chunk_text = "Summary of task",
#'   prefix = "Finished in ")
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' reference_time <- (lubridate::now() -
#'     (lubridate::minutes(50) + lubridate::seconds(45)))
#' cat_diff(reference_time)
#'
#' reference_time <- (lubridate::now() - lubridate::minutes(50))
#' cat_diff(reference_time)
#'
#' reference_time <- (lubridate::now() - lubridate::minutes(70))
#' cat_diff(reference_time)
#'
#' reference_time <- (lubridate::now() - lubridate::hours(4))
#' cat_diff(reference_time)
#'
#' reference_time <- lubridate::now() -
#'   (lubridate::hours(4) + lubridate::minutes(50) + lubridate::seconds(45))
#' cat_diff(reference_time)

cat_diff <- function(
    init_time, chunk_text = "Session summary", prefix = "Completed in ",
    cat_info = FALSE, level = 0L, cat_timestamp = FALSE, ...) {

  if (is.null(init_time)) {
    ecokit::stop_ctx("`init_time` cannot be NULL", init_time = init_time)
  }

  if (cat_info) {
    ecokit::info_chunk(message = chunk_text)
    prefix <- paste0("\n", prefix)
  }

  period <- lubridate::time_length(
    lubridate::now(tzone = "CET") - init_time) %>%
    lubridate::seconds_to_period()
  period_hours <- stringr::str_pad(
    (lubridate::hour(period) + 24L * lubridate::day(period)),
    width = 2L, pad = "0")
  period_minutes <- stringr::str_pad(
    lubridate::minute(period), width = 2L, pad = "0")
  period_seconds <- stringr::str_pad(
    round(lubridate::second(period)), width = 2L, pad = "0")

  paste0(period_hours, ":", period_minutes, ":", period_seconds) %>%
    paste0(prefix, .) %>%
    ecokit::cat_time(level = level, cat_timestamp = cat_timestamp, ...)

  return(invisible(NULL))
}
