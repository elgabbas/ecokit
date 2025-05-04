## |------------------------------------------------------------------------| #
# file_type ----
## |------------------------------------------------------------------------| #
#
#' Determine the file type of a given file path
#'
#' This function uses the system's `file` command to determine the type of the
#' file specified by the `path` parameter. It returns a character string
#' describing the file type.
#' @param path Character. The path to the file whose type is to be determined.
#'   The path must not be `NULL`, and the file must exist.
#' @return A character string describing the file type.
#' @name file_type
#' @export
#' @note This function relies on the system's `file` command and therefore
#'    might produce different outputs on different platforms.
#' @author Ahmed El-Gabbas
#' @examples
#' (f <- system.file("ex/elev.tif", package="terra"))
#'
#' file_type(path = f)

file_type <- function(path) {

  # Check `file` system command
  if (isFALSE(ecokit::check_system_command("file"))) {
    ecokit::stop_ctx("The system command 'file' is not available")
  }

  if (is.null(path)) {
    ecokit::stop_ctx("`path` cannot be NULL", path = path)
  }

  # Ensure path is a character string
  if (!is.character(path)) {
    ecokit::stop_ctx("`path` must be a character string", path = path)
  }

  # Ensure file exists
  if (!file.exists(path)) {
    ecokit::stop_ctx("File does not exist", path = path)
  }

  output <- paste0("file ", ecokit::normalize_path(path)) %>%
    system(intern = TRUE) %>%
    stringr::str_extract_all(": .+", simplify = TRUE) %>%
    as.vector() %>%
    stringr::str_remove("^: ")

  return(output)
}
