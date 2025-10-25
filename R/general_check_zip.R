## |------------------------------------------------------------------------| #
# check_zip ----
## |------------------------------------------------------------------------| #

#' Check the Integrity of ZIP Files
#'
#' Tests the integrity of ZIP files using the `unzip -t` system command.
#' Verifies that files exist, non-empty, have a `.zip` extension, and
#' pass the integrity check.
#'
#' @author Ahmed El-Gabbas
#' @param file Character. Path to a ZIP file. Must be a single, non-empty
#'   string.
#' @param warning Logical. If `TRUE`, issues a warning if the file does not
#'   exist, is empty, or fails the integrity check. Default is `TRUE`.
#' @param all_okay Logical. If `TRUE` (default), returns a single logical output
#'   indicating the validity of all ZIP files; if `FALSE`, returns a logical
#'   vector for each ZIP file.
#' @return Logical: `TRUE` if all checks pass; `FALSE` otherwise.
#' @name check_zip
#' @export
#' @note Requires the `unzip` system command.
#' @examples
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Create ZIP files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # valid ZIP file
#' temp_dir <- fs::path_temp("check_zip")
#' fs::dir_create(temp_dir)
#' temp_file <- fs::path(temp_dir, "test.txt")
#' writeLines("Hello, world!", temp_file)
#' zip_file <- fs::path(temp_dir, "valid.zip")
#' zip(zip_file, temp_file, flags = "-jq")
#' check_zip(zip_file)
#'
#' # invalid ZIP file (corrupted)
#' bad_zip <- fs::path(temp_dir, "invalid.zip")
#' writeLines("Not a ZIP file", bad_zip)
#' check_zip(bad_zip)
#' check_zip(bad_zip, warning = FALSE)
#'
#' # empty ZIP file
#' empty_zip <- fs::path(temp_dir, "empty.zip")
#' fs::file_create(empty_zip)
#' check_zip(empty_zip)
#' check_zip(empty_zip, warning = FALSE)
#'
#' # non-ZIP file
#' non_zip_file <- fs::path(temp_dir, "test.txt")
#' writeLines("Hello, world!", non_zip_file)
#' check_zip(non_zip_file)
#' check_zip(non_zip_file, warning = FALSE)
#'
#' # non-existent file
#' check_zip("nonexistent.zip")
#' check_zip("nonexistent.zip", warning = FALSE)
#'
#' # Check multiple files
#' zip_files <- c(zip_file, bad_zip, empty_zip, temp_file)
#'
#' check_zip(zip_files)
#'
#' check_zip(zip_files, warning = FALSE)
#'
#' check_zip(zip_files, all_okay = FALSE)
#'
#' check_zip(zip_files, all_okay = FALSE, warning = FALSE)
#'
#' # clean up
#' fs::file_delete(zip_files)
#' fs::dir_delete(temp_dir)

check_zip <- function(file = NULL, warning = TRUE, all_okay = TRUE) {

  # Check for unzip command
  if (isFALSE(ecokit::check_system_command("unzip"))) {
    ecokit::stop_ctx("The 'unzip' command is not available")
  }

  # Validate input
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be missing")
  }
  purrr::walk(
    .x = file,
    .f = ~{
      if (!is.character(.x) || length(.x) != 1L || !nzchar(.x)) {
        ecokit::stop_ctx("`file` must be a character string", file = .x)
      }
    })

  zip_check <- purrr::map_lgl(
    .x = file,
    .f = ~{

      # Verify the file exists
      if (!fs::file_exists(.x)) {
        if (warning) {
          warning(
            "File does not exist: ", ecokit::normalize_path(.x), call. = FALSE)
        }
        return(FALSE)
      }

      # Verify the file is not empty
      if (file.info(.x)$size == 0L) {
        if (warning) {
          warning("File is empty: ", ecokit::normalize_path(.x), call. = FALSE)
        }
        return(FALSE)
      }

      # Validate the ZIP file
      file_okay <- tryCatch(
        expr = {
          stringr::str_glue("unzip -t {shQuote(.x)}") %>%
            ecokit::system_command() %>%
            stringr::str_detect("No errors detected in compressed data") %>%
            any()
        },
        warning = function(w) {
          if (warning) {
            warning(
              "Warning during file validation: ",
              conditionMessage(w), call. = FALSE)
          }
          FALSE
        },
        error = function(e) {
          if (warning) {
            warning(
              "Error during file validation: ",
              conditionMessage(e), call. = FALSE)
          }
          FALSE
        })
    })

  if (all_okay) zip_check <- all(zip_check)

  zip_check

}
