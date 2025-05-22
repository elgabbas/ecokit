# # |------------------------------------------------------------------------| #
# check_gbif ----
## |------------------------------------------------------------------------| #

#' Check and Load GBIF Credentials from .Renviron
#'
#' Checks if [GBIF](https://www.gbif.org/) access credentials (`GBIF_EMAIL`,
#' `GBIF_PWD`, `GBIF_USER`) are available in the environment. If not, attempts
#' to read them from the specified `.Renviron` file. If the credentials are
#' still missing after reading the file, an error is thrown with details about
#' which credentials are missing.
#'
#' @param r_environ Character string specifying the path to the `.Renviron` file
#'   where GBIF credentials are stored. Defaults to `".Renviron"` in the current
#'   working directory.
#' @return Returns `NULL` invisibly if the GBIF credentials are successfully
#'   validated or loaded. Stops with an error if the credentials cannot be found
#'   or loaded.
#' @details This function ensures that the necessary GBIF credentials are loaded
#'   into the R environment for accessing GBIF services, e.g. using `rgbif` R
#'   package. It first checks if the credentials are already set as environment
#'   variables. If any are missing, it attempts to read them from the specified
#'   `.Renviron` file. If the file does not exist, is not readable, or does not
#'   contain all required credentials, the function stops with an informative
#'   error message. The function is designed to be used in workflows requiring
#'   GBIF API access, such as downloading occurrence data. It returns `NULL`
#'   invisibly on success, indicating that the credentials are properly set.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' \dontrun{
#'   # Check GBIF credentials using the default .Renviron file
#'   check_gbif()
#'
#'   # Specify a custom .Renviron file
#'   check_gbif(r_environ = "~/.Renviron")
#' }
#' @name check_gbif

check_gbif <- function(r_environ = ".Renviron") {

  required_vars <- c("GBIF_EMAIL", "GBIF_PWD", "GBIF_USER")

  # Check if the accessing information already read
  missing_vars <- purrr::map_lgl(
    .x = required_vars, .f = ~ !nzchar(Sys.getenv(.x))) %>%
    any()

  # If access information already read, return NULL invisible
  if (!missing_vars) {
    return(invisible(NULL))
  }

  # If access information not read, try to read it from r_environ file

  # Validate input
  if (!is.character(r_environ) || !nzchar(r_environ)) {
    ecokit::stop_ctx(
      "The 'r_environ' parameter must be a non-empty character string",
      include_backtrace = TRUE
    )
  }
  # Check if the .Renviron file exists and is readable
  if (!file.exists(r_environ)) {
    ecokit::stop_ctx(
      "`.Renviron` file does not exist", r_environ = r_environ,
      include_backtrace = TRUE)
  }
  if (file.access(r_environ, mode = 4L) < 0L) {
    ecokit::stop_ctx(
      "The specified `.Renviron` file is not readable",
      r_environ = r_environ, include_backtrace = TRUE)
  }

  # Read the `.Renviron` file
  r_environ_loaded <- readRenviron(r_environ)

  if (isFALSE(r_environ_loaded)) {
    ecokit::stop_ctx(
      "Failed to read the `.Renviron` file",
      r_environ = r_environ, include_backtrace = TRUE)
  }

  missing_vars <- purrr::map_lgl(
    .x = required_vars, .f = ~ !nzchar(Sys.getenv(.x))) %>%
    which()

  if (length(missing_vars) > 1L) {
    missing_vars <- required_vars[missing_vars]
    ecokit::stop_ctx(
      paste0(
        "The following GBIF log in credentials  are missing",
        "from the environment ", "after reading ", r_environ, ": ",
        toString(missing_vars)),
      include_backtrace = TRUE)
  }

  return(invisible(NULL))
}
