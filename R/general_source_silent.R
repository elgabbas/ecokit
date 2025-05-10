## |------------------------------------------------------------------------| #
# source_silent ----
## |------------------------------------------------------------------------| #

#' Silently source R script with optional message and warning suppression
#'
#' Sources an R script file with options to suppress messages and/or warnings.
#' Useful for running scripts that generate unwanted console output.
#' @param file Character. Path to the R script file to be sourced.
#' @param messages Logical. If `TRUE` (default), messages are shown. If `FALSE`,
#'   messages are suppressed.
#' @param warnings Logical. If `TRUE` (default), warnings are shown. If `FALSE`,
#'   warnings are suppressed.
#' @param ... Additional arguments passed to [base::source()].
#' @return Invisible `NULL`. Used for its side effect of sourcing the file.
#' @export
#' @name source_silent
#' @author Ahmed El-Gabbas
#' @examples
#' # Create a temporary R script
#' script_file <- tempfile(fileext = ".R")
#' writeLines(
#'   c("message('This is a message')", "warning('This is a warning')",
#'     "print('Output')"),
#'     script_file)
#'
#' # -------------------------------------------
#'
#' # source with default settings (show messages and warnings)
#' source_silent(script_file)
#'
#' # suppress messages only
#' source_silent(script_file, messages = FALSE)
#'
#' # suppress warnings only
#' source_silent(script_file, warnings = FALSE)
#'
#' # suppress both messages and warnings
#' source_silent(script_file, messages = FALSE, warnings = FALSE)
#'
#' # clean up
#' fs::file_delete(script_file)

source_silent <- function(file = NULL, messages = TRUE, warnings = TRUE, ...) {

  # Input validation
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL", file = file)
  }
  if (!is.character(file) || length(file) != 1L) {
    ecokit::stop_ctx("`file` must be a single character string")
  }
  if (!file.exists(file)) {
    ecokit::stop_ctx("`file` does not exist", file = file)
  }

  if (messages && warnings) {
    file %>%
      source(...) %>%
      utils::capture.output(file = nullfile())
  }

  if (isFALSE(messages) && isFALSE(warnings)) {
    file %>%
      source(...) %>%
      utils::capture.output(file = nullfile()) %>%
      suppressMessages() %>%
      suppressWarnings()
  }

  if (messages && isFALSE(warnings)) {
    file %>%
      source(...) %>%
      utils::capture.output(file = nullfile()) %>%
      suppressWarnings()
  }

  if (isFALSE(messages) && warnings) {
    file %>%
      source(...) %>%
      utils::capture.output(file = nullfile()) %>%
      suppressMessages()
  }

  return(invisible(NULL))

}
