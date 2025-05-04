## |------------------------------------------------------------------------| #
# check_system_command ----
## |------------------------------------------------------------------------| #

#' Check system commands availability
#'
#' This function checks if a list of system commands are available on the user's
#' PATH. If any commands are missing, it stops execution and returns an
#' informative error message.
#' @param commands A character vector of system command names to check (e.g.,
#'   `c("git", "Rscript", "unzip")`).
#' @return The function returns `TRUE` if all specified commands are available
#'   on the system, `FALSE` if any is not available.
#' @param warning Logical. Whether to issue a warning if any command is missing.
#'   Defaults to `TRUE`.
#' @export
#' @name check_system_command
#' @author Ahmed El-Gabbas
#' @examples
#' # Check for the availability of system commands
#' check_system_command(c("unzip", "head"))
#'
#' # return FALSE, with a warning for a missing command
#' check_system_command(c("unzip", "head", "curl", "missing"))
#'
#' # return FALSE, without a warning for a missing command
#' check_system_command(c("unzip", "head", "curl", "missing"), warning = FALSE)
#' @export

check_system_command <- function(commands, warning = TRUE) {

  # Check the availability of each command in the list
  command_okay <- purrr::map_lgl(.x = commands, .f = ~ nzchar(Sys.which(.x)))

  # Identify missing tools
  missing_tools <- commands[!command_okay]

  # If any tools are missing, stop with an informative error message
  if (length(missing_tools) > 0) {
    if (warning) {
      warning(
        "The following tool(s) are missing: ", toString(missing_tools),
        call. = FALSE)
    }
    return(FALSE)
  } else {
    return(TRUE)
  }
}
