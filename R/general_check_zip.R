## |------------------------------------------------------------------------| #
# check_zip ----
## |------------------------------------------------------------------------| #

#' Check the Integrity of a ZIP File
#'
#' Tests the integrity of a ZIP file using the `unzip -t` system command.
#' Verifies that the file exists, is non-empty, has a `.zip` extension, and
#' passes the integrity check. Returns `FALSE` with a warning if the file is
#' invalid or if `unzip` is unavailable.
#'
#' @author Ahmed El-Gabbas
#' @param file Character. Path to a ZIP file. Must be a single, non-empty
#'   string.
#' @return Logical: `TRUE` if the file exists, is non-empty, and passes the
#'   integrity check; `FALSE` otherwise, accompanied by a warning explaining the
#'   failure.
#' @name check_zip
#' @export
#' @note Requires the `unzip` system command.
#' @examples
#' # |||||||||||||||||||||||||||||||||||||||
#' # Create ZIP files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # valid ZIP file
#' temp_dir <- tempdir()
#' temp_file <- file.path(temp_dir, "test.txt")
#' writeLines("Hello, world!", temp_file)
#' zip_file <- file.path(temp_dir, "valid.zip")
#' zip(zip_file, temp_file, flags = "-jq")
#'
#' # invalid ZIP file (corrupted)
#' bad_zip <- file.path(temp_dir, "invalid.zip")
#' writeLines("Not a ZIP file", bad_zip)
#'
#' # empty ZIP file
#' empty_zip <- file.path(temp_dir, "empty.zip")
#' fs::file_create(empty_zip)
#'
#' # non-ZIP file
#' non_zip_file <- file.path(temp_dir, "test.txt")
#' writeLines("Hello, world!", non_zip_file)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Check ZIP files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' check_zip(zip_file)                              # TRUE
#'
#' check_zip(bad_zip)                               # FALSE, with warning
#'
#' # non-existent file
#' check_zip("nonexistent.zip")                     # FALSE, with warning
#'
#' check_zip(empty_zip)                             # FALSE, with warning
#'
#' check_zip(non_zip_file)                          # FALSE, with warning
#'
#' # clean up
#' unlink(c(zip_file, bad_zip, empty_zip, temp_file))

check_zip <- function(file = NULL) {

  # Check for unzip command
  if (isFALSE(ecokit::check_system_command("unzip"))) {
    ecokit::stop_ctx("The 'unzip' command is not available")
  }

  # Validate input
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be missing")
  }

  if (length(file) != 1L || !is.character(file) || !nzchar(file)) {
    ecokit::stop_ctx(
      "`file` must be a single non-empty character string",
      file = ecokit::normalize_path(file))
  }

  # Verify the file exists
  if (!file.exists(file)) {
    warning(
      "File does not exist: ", ecokit::normalize_path(file), call. = FALSE)
    return(FALSE)
  }

  # Verify the file is not empty
  if (file.info(file)$size == 0L) {
    warning("File is empty: ", ecokit::normalize_path(file), call. = FALSE)
    return(FALSE)
  }

  in_file_type <- ecokit::file_type(file)
  if (!startsWith(in_file_type, "Zip archive")) {
    warning(
      "Not a valid ZIP file: ", ecokit::normalize_path(file), call. = FALSE)
    return(FALSE)
  }

  # Validate the ZIP file
  file_okay <- tryCatch(
    expr = {
      ecokit::system_command(stringr::str_glue("unzip -t {file}")) %>%
        stringr::str_detect("No errors detected in compressed data") %>%
        any()
    },
    warning = function(w) {
      message(
        "Warning during file validation: ", conditionMessage(w), call. = FALSE)
      FALSE
    },
    error = function(e) {
      message(
        "Error during file validation: ", conditionMessage(e), call. = FALSE)
      FALSE
    })

  # Ensure the result is a logical value
  return(file_okay)
}
