## |------------------------------------------------------------------------| #
# file_extension ----
## |------------------------------------------------------------------------| #
#
#' Get the file extension from a file path
#'
#' This function extracts the file extension from a given file path. It first
#' checks if the input is not NULL and is a character string. If these
#' conditions are met, it then uses the [tools::file_ext] function to extract
#' and return the file extension. The function does not check the existence of
#' the file or explicitly get the file type from its content. It merely guess
#' file extension from the file name.
#' @name file_extension
#' @author Ahmed El-Gabbas
#' @return A character string representing the file extension of the given file
#'   path. If the path does not have an extension, an empty string is returned.
#' @param path A character string representing the file path from which the file
#'   extension is to be extracted. It must not be `NULL` and has to be a
#'   character string.
#' @seealso [ecokit::file_type()]
#' @examples
#' file_extension(path = "File.doc")
#'
#' file_extension(path = "D:/File.doc")
#'
#' file_extension(path = "File.1.doc")
#'
#' file_extension(path = "D:/Files.All")
#'
#' file_extension(path = "D:/Files.All/")
#'
#' file_extension("example.txt") # returns "txt"
#'
#' file_extension("archive.tar.gz") # returns "gz"
#' @export

file_extension <- function(path) {
  if (is.null(path)) {
    ecokit::stop_ctx("`path` cannot be NULL", path = path)
  }

  # Ensure path is a character string
  if (!is.character(path)) {
    ecokit::stop_ctx("`path` must be a character string", path = path)
  }

  return(tools::file_ext(path))
}
