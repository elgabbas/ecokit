## |------------------------------------------------------------------------| #
# save_session_info ----
## |------------------------------------------------------------------------| #

#' Save session information to a text file
#'
#' Saves R session information, including platform details, package versions,
#' and optionally, a summary of objects in the session, to a text file.
#' @param out_directory Character. Directory path where the output file is
#'   saved. Defaults to the current working directory ([base::getwd()]).
#' @param session_info An optional tibble or data frame with object details
#'   (e.g., from [ecokit::save_session()]). If provided, details of objects
#'   (e.g., names and sizes in MB) are appended to the output file. Defaults to
#'   `NULL`.
#' @param prefix Character. Prefix for the output file name. Defaults to `"S"`.
#' @return Invisible `NULL`. Used for its side effect of writing session
#'   information to a file.
#' @export
#' @name save_session_info
#' @examples
#' load_packages(fs)
#'
#' # Save session info without object details
#' temp_dir <- fs::path(tempdir(), "temp_dir")
#' fs::dir_create(temp_dir)
#' save_session_info(out_directory = temp_dir)
#'
#' saved_file <- list.files(
#'   temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
#'   ecokit::normalize_path()
#' (saved_file <- saved_file[length(saved_file)])
#'
#' cat(readLines(saved_file), sep = "\n")
#'
#' # |||||||||||||||||||||||||||||||||||||||||||||||||
#'
#' # Save session info with object details
#' # Create sample objects
#' df <- data.frame(a = 1:1000)
#' vec <- rnorm(1000)
#'
#' # Simulate output from save_session()
#' session_data <- tibble::tibble(object = c("df", "vec"), size = c(0.1, 0.1))
#' save_session_info(out_directory = temp_dir, session_info = session_data)
#'
#' saved_file <- list.files(
#'   temp_dir, pattern = "S_.+txt$", full.names = TRUE) %>%
#'   ecokit::normalize_path()
#' (saved_file <- saved_file[length(saved_file)])
#'
#' cat(readLines(saved_file), sep = "\n")
#'
#' # Clean up
#' unlink(temp_dir, recursive = TRUE)

save_session_info <- function(
    out_directory = getwd(), session_info = NULL, prefix = "S") {

  # Input validation
  if (!is.character(out_directory) || length(out_directory) != 1L) {
    ecokit::stop_ctx("`out_directory` must be a single character string")
  }
  if (!is.character(prefix) || length(prefix) != 1L) {
    ecokit::stop_ctx("`prefix` must be a single character string")
  }

  # Create output directory if it doesn't exist
  fs::dir_create(out_directory)

  # Generate timestamped file name
  timestamp <- format(lubridate::now(tzone = "CET"), "%Y%m%d_%H%M")
  file_name <- fs::path(out_directory, paste0(prefix, "_", timestamp, ".txt"))

  # Write session information
  utils::capture.output(
    ecokit::info_chunk("Session Info", cat_date = FALSE),
    file = file_name, append = FALSE)
  utils::capture.output(
    sessioninfo::session_info(), file = file_name, append = TRUE)

  # Append object details if provided
  if (!is.null(session_info)) {
    utils::capture.output(
      ecokit::info_chunk(
        paste0(
          "Objects in the current session\n(except functions and ",
          "pre-selected objects; Size in megabytes)"),
        cat_date = FALSE),
      file = file_name, append = TRUE)

    sink(file_name, append = TRUE)
    print.data.frame(tibble::tibble(session_info), row.names = FALSE)
    sink()
  }

  message("Saving session info to:\n", crayon::blue(file_name))

  return(invisible(NULL))
}
