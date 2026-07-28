## |------------------------------------------------------------------------| #
# check_rstudio ----
## |------------------------------------------------------------------------| #

#' Check if the installed RStudio version is up to date
#'
#' This function checks the current installed version of RStudio against the
#' latest version available online. If the versions do not match, it suggests
#' updating RStudio.
#' @name check_rstudio
#' @author Ahmed El-Gabbas
#' @return Side effects include printing messages to the console regarding the
#'   status of RStudio version.
#' @note This function requires internet access to check the latest version of
#'   RStudio online. If called outside of RStudio, it will only fetch and
#'   display the latest version without comparing. If posit has changed the
#'   structure of their webpage and the online version can not be parsed, the
#'   function reports this clearly and, when possible, still shows the installed
#'   version.
#' @export
#' @examples
#' check_rstudio()

check_rstudio <- function() {

  Download <- NULL

  ecokit::check_packages(
    c("rvest", "xml2", "rstudioapi", "stringr", "crayon", "purrr"))

  posit_url <- "https://docs.posit.co/ide/user/"

  # --- Try to retrieve and parse the online version ---

  # Wrapped in tryCatch because a change in the posit webpage structure (e.g. no
  # table, renamed column, different download-link format) would otherwise throw
  # an error or silently return an empty/invalid result

  online_version <- tryCatch(
    {
      online_table <- xml2::read_html(posit_url) %>%
        rvest::html_table()

      if (length(online_table) == 0L) {
        NULL
      } else {
        dplyr::bind_rows(online_table) %>%
          dplyr::filter(stringr::str_detect(Download, "RStudio-2")) %>%
          dplyr::pull(Download) %>%
          stringr::str_remove_all("RStudio-|....$") %>%
          unique() %>%
          stringr::str_replace_all("-", ".")
      }
    },
    error = function(e) NULL)

  # --- Flag whether the online lookup actually succeeded ---

  # `online_version` can be NULL (page/table missing) or character(0) (table
  # found, but no row matched the expected "RStudio-2..." pattern), both of
  # which indicate the posit page layout has likely changed
  online_ok <- !is.null(online_version) && length(online_version) > 0L

  if (!online_ok) {
    cat(
      crayon::red(
        "Could not retrieve the latest RStudio version online.\n",
        "The posit website structure may have changed; please check ",
        "manually:\n", posit_url, "\n", sep = ""))
  }

  if (Sys.getenv("RSTUDIO") == "1" && rstudioapi::isAvailable()) {

    installed_version <- rstudioapi::versionInfo() %>%
      purrr::pluck("long_version") %>%
      stringr::str_replace_all("\\+", "\\.")

    if (!online_ok) {

      # Online version unknown, but we can still report what is installed
      cat(
        crayon::blue(
          "Installed R-Studio version:",
          crayon::red(crayon::bold(installed_version)), ".",
          sep = ""))

    } else if (identical(online_version, installed_version)) {

      cat(
        crayon::blue(
          "You are using the most recent version of R-Studio: v",
          crayon::red(crayon::bold(installed_version)), ".",
          sep = ""))

    } else {

      cat(
        crayon::blue(
          "R-Studio version:",
          crayon::red(crayon::bold(online_version)),
          "is available.\nInstalled R-studio version:",
          crayon::red(crayon::bold(installed_version)),
          "\nPlease consider updating R-Studio.\n"))
    }

  } else if (online_ok) {
    cat(
      paste0(
        "Not called from RStudio. The most recent version of RStudio is ",
        crayon::red(crayon::bold(online_version)), ".\n"))
  } else {
    cat(
      paste0(
        "Not called from RStudio, and the installed version can not be ",
        "determined outside of RStudio.\n"))
  }

  invisible(NULL)
}
