## |------------------------------------------------------------------------| #
# check_quarto ----
## |------------------------------------------------------------------------| #

#' Check if the installed Quarto version is up to date
#'
#' This function compares the installed Quarto version on the user's system with
#' the latest version available online. If the versions differ, it suggests the
#' user to update Quarto. It uses web scraping to find the latest version
#' available on the Quarto GitHub releases page and the system command to find
#' the installed version.
#' @name check_quarto
#' @author Ahmed El-Gabbas
#' @param pre_release Logical. Whether to check for pre-release versions.
#'   Default is `FALSE`.
#' @return A message indicating whether the installed Quarto version is up to
#'   date or suggesting an update if it is not.
#' @note If GitHub has changed the structure of the releases page and the online
#'   version can not be parsed, the function reports this clearly and, when
#'   possible, still shows the installed version.
#' @export
#' @examples
#' check_quarto()
#'
#' check_quarto(pre_release = TRUE)

check_quarto <- function(pre_release = FALSE) {

  quarto_version <- labels <- NULL

  ecokit::check_packages(c("rvest", "stringr", "crayon"))

  # URL of the Quarto releases page
  release_url <- "https://github.com/quarto-dev/quarto-cli/releases/"

  # --- Try to retrieve and parse the latest online version ---
  # Wrapped in tryCatch because a change in the GitHub page structure (e.g.
  # no "Box" blocks, renamed selectors, no "Latest" label) would otherwise
  # throw an error or silently return an empty/invalid result
  version_latest <- tryCatch(
    {
      # Extract all release blocks (adjust selector based on current structure)
      release_blocks <- release_url %>%
        # Read the HTML content of the page
        rvest::read_html() %>%
        rvest::html_nodes("div.Box")

      # Extract version and label for each release
      releases <- release_blocks %>%
        lapply(function(block) {
          # Get the version number from the <h2><a> or <a> tag
          quarto_version <- block %>%
            # Targets release tag links or titles
            rvest::html_node("h2 a, a[href*='/tag/v']") %>%
            rvest::html_text(trim = TRUE)

          # Get all labels (<span> tags with class "Label" or similar)
          labels <- block %>%
            rvest::html_nodes(
              "span.Label, span.Label--success, span.Label--orange") %>%
            rvest::html_text(trim = TRUE) %>%
            unique() %>%
            # Combine multiple labels if present
            paste(collapse = ", ")

          # Return a data frame row
          if (is.na(quarto_version)) {
            # Skip if no version found
            NULL
          } else {
            tibble::tibble(
              quarto_version = quarto_version,
              labels = dplyr::if_else(nzchar(labels), labels, "None"))
          }
        }) %>%
        # Combine into a single data frame
        dplyr::bind_rows() %>%
        dplyr::filter(startsWith(quarto_version, "v"))

      releases %>%
        dplyr::filter(stringr::str_detect(labels, "Latest")) %>%
        dplyr::pull("quarto_version")
    },
    error = function(e) character(0L))

  # --- Flag whether the online lookup actually succeeded ---
  # `version_latest` is `character(0)` both on a caught error and when the
  # page was read but no row was tagged "Latest" any more - either way this
  # signals that the GitHub page structure has likely changed
  online_ok <- length(version_latest) > 0L

  if (!online_ok) {
    cat(
      crayon::red(
        "Could not retrieve the latest Quarto version online.\n",
        "The GitHub releases page structure may have changed; please ",
        "check manually:\n", release_url, "\n", sep = ""))
  }

  # # ..................................................................... ###

  # Check `quarto` system command
  if (ecokit::check_system_command("quarto", warning = FALSE)) {
    installed_version <- system("quarto --version", intern = TRUE)
  } else {
    cat(crayon::blue("Quarto is not available in the system.\n"))
    installed_version <- NA_character_
  }

  if (!online_ok) {

    # Online version unknown, but we can still report what is installed
    cat(
      crayon::blue(
        "Installed Quarto version: ",
        crayon::red(crayon::bold(installed_version)), ".",
        sep = ""))

  } else if (isFALSE(identical(version_latest, installed_version))) {

    if (pre_release) {

      if (!requireNamespace("gtools", quietly = TRUE)) {
        ecokit::stop_ctx(
          "The `gtools` package is required for alphanumeric sorting.")
      }

      version_pre_release <- releases %>%
        dplyr::slice(gtools::mixedorder(quarto_version)) %>%
        dplyr::slice_tail(n = 1L) %>%
        dplyr::pull("quarto_version")

      cat(
        crayon::blue(
          paste0(
            "Available pre-release version is: ",
            crayon::red(crayon::bold(version_pre_release)), " [installed: ",
            crayon::red(crayon::bold(installed_version)), "]\n")))

    } else {
      cat(
        crayon::blue(
          paste0(
            "Latest quarto version is ",
            crayon::red(crayon::bold(version_latest)), " [installed: ",
            crayon::red(crayon::bold(installed_version)), "]\n")))

    }
  } else {
    cat(
      crayon::blue(
        "You are using the most recent version of Quarto: v",
        crayon::red(crayon::bold(installed_version)), ".",
        sep = ""))
  }

  return(invisible(NULL))
}
