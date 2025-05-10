## |------------------------------------------------------------------------| #
# list_to_rdata ----
## |------------------------------------------------------------------------| #

#' Split list items into separate `.RData` files
#'
#' This function takes a named list and saves each element of the list as a
#' separate `.RData` file. The names of the list elements are used as the base
#' for the filenames, optionally prefixed. Files are saved in the specified
#' directory, with an option to overwrite existing files.
#'
#' @param list A named list object to be split into separate `.RData` files.
#' @param prefix Character. Prefix to each filename. If empty (default), no
#'   prefix is added.
#' @param directory The directory where the `.RData` files will be saved.
#'   Defaults to the current working directory.
#' @param overwrite A logical indicating whether to overwrite existing files.
#'   Defaults to `FALSE`, in which case files that already exist will not be
#'   overwritten, and a message will be printed for each such file.
#' @name list_to_rdata
#' @author Ahmed El-Gabbas
#' @return The function is called for its side effect of saving files and does
#'   not return a value.
#' @export
#' @examples
#' load_packages(dplyr, fs)
#'
#' # split iris data by species name
#' iris2 <- iris %>%
#'   tibble::tibble() %>%
#'   split(~Species)
#'
#' str(iris2, 1)
#'
#' # save each species as a separate RData file
#' temp_dir <- fs::path_temp("list_to_rdata")
#' fs::dir_create(temp_dir)
#' list.files(temp_dir)
#'
#' list_to_rdata(list = iris2, directory = temp_dir)
#' list.files(temp_dir)
#'
#' # loading data
#' setosa <- load_as(fs::path(temp_dir, "setosa.RData"))
#' str(setosa, 1)
#'
#' versicolor <- load_as(fs::path(temp_dir, "versicolor.RData"))
#' str(versicolor, 1)
#'
#' virginica <- load_as(fs::path(temp_dir, "virginica.RData"))
#' str(virginica, 1)
#'
#' # load multiple files in a single R object
#' loaded_data <- load_multiple(
#'   files = fs::path(
#'   temp_dir, c("setosa.RData", "versicolor.RData", "virginica.RData")),
#'   verbose = TRUE)
#' str(loaded_data, 1)
#'
#' # clean up
#' fs::dir_delete(temp_dir)

list_to_rdata <- function(
  list, prefix = "", directory = getwd(), overwrite = FALSE) {

  # Validation Checks
  if (is.null(list) || length(list) == 0L) {
    ecokit::stop_ctx("`list` cannot be NULL or empty.", list = list)
  }

  if (is.null(names(list))) {
    ecokit::stop_ctx("`list` names cannot be NULL.", list = list)
  }

  # Directory Creation
  fs::dir_create(directory)

  # file Saving Loop --- iterates over each element in the list and writes it to
  # a separate RData file. The filename is the element's name

  purrr::walk(
    .x = seq_along(list),
    .f = function(x) {

      # construct filename using the element's name and the optional prefix
      file_name <- if (prefix == "") {
        names(list)[x]
      } else {
        paste0(prefix, "_", names(list)[x])
      }
      file <- fs::path(directory, paste0(file_name, ".RData"))

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
