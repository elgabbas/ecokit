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
#'   display the latest version without comparing.
#' @export
#' @examples
#' check_rstudio()

check_rstudio <- function() {

  if (!requireNamespace("rvest", quietly = TRUE)) {
    ecokit::stop_ctx("The `rvest` package is required to scrape web content.")
  }

  if (!requireNamespace("xml2", quietly = TRUE)) {
    ecokit::stop_ctx("The `xml2` package is required to read XML files.")
  }

  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `rstudioapi` package is required to check RStudio version.")
  }
  online_version <- "https://posit.co/download/rstudio-desktop/" %>%
    xml2::read_html() %>%
    rvest::html_node(".flex-inhe:nth-child(8)") %>%
    rvest::html_text2() %>%
    stringr::str_remove_all("RStudio-|.exe") %>%
    stringr::str_replace_all("-", ".")

  if (Sys.getenv("RSTUDIO") == "1" && rstudioapi::isAvailable()) {

    installed_version <- rstudioapi::versionInfo() %>%
      purrr::pluck("long_version") %>%
      stringr::str_replace_all("\\+", "\\.")

    if (identical(online_version, installed_version)) {
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

  } else {
    cat(
      paste0(
        "Not called from RStudio. The most recent version of RStudio is ",
        crayon::red(crayon::bold(online_version)), ".\n"))
  }

  invisible(NULL)
}
