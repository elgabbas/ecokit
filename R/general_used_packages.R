## |------------------------------------------------------------------------| #
# used_packages ----
## |------------------------------------------------------------------------| #

#' Extract package names used with :: in an R script
#'
#' Reads an R script file and extracts unique package names used with the `::`
#' operator (e.g., `dplyr` from `dplyr::arrange`). Ignores entire lines that are
#' comments (starting with `#`, ignoring whitespace) and text after `#` within
#' lines.
#'
#' @param file_path Character string specifying the path to the R script file.
#' @return A character vector of unique package names used with `::`. Returns
#'   `character(0)` if none are found.
#' @export
#' @examples
#' # Example with a script from GitHub
#' dplyr_select_url <- paste0(
#'   "https://raw.githubusercontent.com/elgabbas/ecokit/",
#'   "refs/heads/main/R/spat_split_raster.R")
#' example_script <- fs::file_temp("Example_script_", ext = "R")
#' download.file(dplyr_select_url, destfile = example_script, quiet = TRUE)
#'
#' used_packages(example_script)
#'
#' # cleanup
#' fs::file_delete(example_script)

used_packages <- function(file_path) {

  # Input validation
  if (!is.character(file_path) || length(file_path) != 1L) {
    ecokit::stop_ctx("file_path must be a single character string")
  }
  if (!file.exists(file_path)) {
    ecokit::stop_ctx("File does not exist: ", file_path = file_path)
  }
  if (!stringr::str_detect(file_path, ".R|.r")) {
    ecokit::stop_ctx(
      "File does not have a .R or .r extension", file_path = file_path)
  }

  # Read file
  packages <- tryCatch(
    readLines(file_path, warn = FALSE),
    error = function(e) {
      ecokit::stop_ctx("Failed to read file: ", message = e$message)
    })
  packages <- stringr::str_trim(packages) %>%
    stringr::str_subset("^\\s*[^#]*::") %>%
    stringr::str_extract_all(
      pattern = "([a-zA-Z0-9._]+)\\s*::\\s*[a-zA-Z0-9._]+",
      simplify = TRUE) %>%
    as.vector() %>%
    stringr::str_subset("^\\s*$", negate = TRUE) %>%
    # extract package names
    stringr::str_extract("^[^:]+") %>%
    unique() %>%
    sort()

  if (length(packages) == 0L) {
    message("No packages with :: found in ", file_path)
  }
  packages
}
