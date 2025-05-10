#' File Information Utilities
#'
#' A collection of functions to extract information about files, including their
#' extension, size, and type.
#'
#' @details The following functions are included:
#' - `file_extension`: Extracts the file extension from a file path using
#'   [tools::file_ext]. It does not verify file existence or content, only
#'   parsing the extension from the file name.
#' - `file_size`: Returns the file size in a human-readable format (e.g., KB,
#'   MB, GB) using [gdata::humanReadable].
#' - `file_type`: Determines the file type using the system's `file` command,
#'   returning a description of the file type.
#' @param file A character string representing the file path. Must not be `NULL`
#'   and must be a character string. For `file_type`, the file must exist.
#' @param ... Additional arguments passed to [gdata::humanReadable] for
#'   customizing the output format (for `file_size` only).
#' @return
#' - `file_extension`: A character string with the file extension (e.g., "txt").
#' Returns an empty string if no extension is present.
#' - `file_size`: A character string representing the file size in a
#' human-readable format (e.g., "1.2 MB").
#' - `file_type`: A character string describing the file type (e.g., "ASCII
#' text").
#' @author Ahmed El-Gabbas
#' @note
#' - `file_extension` does not check file existence or content, only parsing the
#' extension from the file name.
#' - `file_type` relies on the system's `file` command, so results may vary
#' across platforms.
#' @examples
#' load_packages(terra)
#'
#' f <- system.file("ex/elev.tif", package = "terra")
#'
#' file_extension(f)                         # "tif"
#'
#' file_size(f)                              # "7.8 KiB"
#'
#' file_type(f)                              # e.g., "TIFF image data ..."

## |------------------------------------------------------------------------| #
# file_extension ----
## |------------------------------------------------------------------------| #

#' @export
#' @rdname file_operations
#' @name file_operations
#' @order 1

file_extension <- function(file) {

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL", file = file)
  }

  # Ensure file is a character string
  if (!is.character(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }

  tools::file_ext(file)
}


## |------------------------------------------------------------------------| #
# file_size ----
## |------------------------------------------------------------------------| #

#' @export
#' @rdname file_operations
#' @name file_operations
#' @order 2

file_size <- function(file, ...) {

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL", file = file)
  }

  gdata::humanReadable(fs::file_size(file), ...)
}

## |------------------------------------------------------------------------| #
# file_type ----
## |------------------------------------------------------------------------| #

#' @export
#' @rdname file_operations
#' @name file_operations
#' @order 3

file_type <- function(file) {

  # Check `file` system command
  if (isFALSE(ecokit::check_system_command("file"))) {
    ecokit::stop_ctx("The system command 'file' is not available")
  }

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL", file = file)
  }

  # Ensure file is a character string
  if (!is.character(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }

  # Ensure file exists
  if (!file.exists(file)) {
    ecokit::stop_ctx("File does not exist", file = file)
  }

  output <- paste0('file "', ecokit::normalize_path(file), '"') %>%
    system(intern = TRUE) %>%
    stringr::str_extract_all(": .+", simplify = TRUE) %>%
    as.vector() %>%
    stringr::str_remove("^: ")

  output
}
