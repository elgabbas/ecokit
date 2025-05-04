## |------------------------------------------------------------------------| #
# list_to_RData ----
## |------------------------------------------------------------------------| #

#' Split list items into separate `.RData` files
#'
#' This function takes a named list and saves each element of the list as a
#' separate `.RData` file. The names of the list elements are used as the base
#' for the filenames, optionally prefixed. Files are saved in the specified
#' directory, with an option to overwrite existing files.
#'
#' @param list A named list object to be split into separate `.RData` files.
#' @param prefix Character. prefix to each filename. If empty (default), no
#'   prefix is added.
#' @param directory The directory where the `.RData` files will be saved.
#'   Defaults to the current working directory.
#' @param overwrite A logical indicating whether to overwrite existing files.
#'   Defaults to `FALSE`, in which case files that already exist will not be
#'   overwritten, and a message will be printed for each such file.
#' @name list_to_RData
#' @author Ahmed El-Gabbas
#' @return The function is called for its side effect of saving files and does
#'   not return a value.
#' @export
#' @examples
#' # split iris data by species name
#' iris2 <- iris %>%
#'   tibble::tibble() %>%
#'   split(~Species)
#'
#' str(iris2, 1)
#'
#' (TMP_Folder <- ecokit::path(tempdir(), stringi::stri_rand_strings(1, 5)))
#' list.files(TMP_Folder)
#'
#' list_to_RData(list = iris2, directory = TMP_Folder)
#' list.files(TMP_Folder)

list_to_RData <- function(
  list, prefix = "", directory = getwd(), overwrite = FALSE) {

  # Validation Checks
  if (is.null(list) || length(list) == 0) {
    ecokit::stop_ctx("`list` cannot be NULL or empty.", list = list)
  }

  if (is.null(names(list))) {
    ecokit::stop_ctx("`list` names cannot be NULL.", list = list)
  }

  # Directory Creation
  fs::dir_create(directory)

  # file Saving Loop --- iterates over each element in the list and writes it to
  # a separate RData file. The filename is the element's name

  ecokit::lapply_(
    X = seq_along(list),
    FUN = function(x) {

      # construct filename using the element's name and the optional prefix
      file_name <- if (prefix == "") {
        names(list)[x]
      } else {
        paste0(prefix, "_", names(list)[x])
      }
      file <- ecokit::path(directory, paste0(file_name, ".RData"))

      # check if the file already exists. If it does and overwrite is FALSE, it
      # prints a message indicating that the file already exists and will not be
      # overwritten.
      if (file.exists(file) && isFALSE(overwrite)) {
        stringr::str_glue(
          "\n\nFile: {file} already exists. No files were created.") %>%
          ecokit::cat_time()
      } else {
        # If the file does not exist or overwrite is TRUE, saves the list
        # element as an RData file
        ecokit::save_as(
          object = list[[x]], object_name = file_name,  out_path = file)
      }
    })

  return(invisible(NULL))
}
