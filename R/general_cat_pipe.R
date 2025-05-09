## |------------------------------------------------------------------------| #
# cat_pipe ----
## |------------------------------------------------------------------------| #

#' print a message with the current time in the middle of the pipe
#'
#' This function is designed to be used within a pipe operation to print a
#' custom message along with the current time, without interrupting the flow of
#' data through the pipe. It is useful for debugging or monitoring the progress
#' of data processing in a pipeline.
#' @param x The input object to be passed through the pipe. This parameter is
#'   required and cannot be NULL.
#' @param message Character. The message to be printed.
#' @return The same object passed as input (`x`), allowing the pipe operation to
#'   continue uninterrupted.
#' @name cat_pipe
#' @author Ahmed El-Gabbas
#' @keywords internal
#' @references This function is currently not exported. See
#'   [here](https://stackoverflow.com/q/76722921) for more details
#' @noRd

cat_pipe <- function(x, message) {

  if (is.null(x) || is.null(message)) {
    ecokit::stop_ctx("x or message cannot be NULL", message = message, x = x)
  }
  ecokit::cat_time(message)
  x
}
