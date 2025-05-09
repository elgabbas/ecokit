## |------------------------------------------------------------------------| #
# clear_console ----
## |------------------------------------------------------------------------| #
#
#' Clear the console
#'
#' function clears the console in RStudio by sending a form feed character. If
#' not run in RStudio, it prints a message indicating the function is not
#' supported.
#' @return An invisible `NULL` to indicate the function has completed without
#'   returning any meaningful value.
#' @name clear_console
#' @note This function checks if it is being run in RStudio by examining the
#'   `RSTUDIO` environment variable. If the function is not run in RStudio, it
#'   will not clear the console and instead print a message.
#' @export
#' @examples
#' clear_console()

clear_console <- function() {

  if (Sys.getenv("RSTUDIO") == "") {
    cat("This function does not work outside of RStudio.\n")

  } else {
    # Clear the console in RStudio
    cat("\014")
  }

  invisible(NULL)
}
