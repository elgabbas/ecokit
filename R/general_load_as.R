## |------------------------------------------------------------------------| #
# load_as ----
## |------------------------------------------------------------------------| #

#' Load objects from `RData` / `qs2` / `rds` / `feather` file
#'
#' This function loads an `RData` file specified by the `file` parameter. If the
#' `RData` file contains a single object, that object is returned directly. If
#' the file contains multiple objects, they are returned as a list with each
#' object accessible by its name. This allows for flexible handling of loaded
#' data without needing to know the names of the objects stored within the RData
#' file ahead of time. The function also supports loading `feather`, `qs2` and
#' `rds` files.
#' @param file Character. the file path or URL of the file to be loaded. If
#'   `file` is a URL, the function will download the file from the URL to a
#'   temporary file and load it.
#' @param timeout integer; time in seconds before the download times out.
#'   Default 300 seconds; see [download.file].
#' @param n_threads Number of threads to use when reading `qs2` files. See
#'   [qs2::qs_read].
#' @param ... Additional arguments to be passed to the respective load
#'   functions. [base::load] for `RData` files; [qs2::qs_read] for `qs2` files;
#'   [arrow::read_feather] for `feather` files; and [base::readRDS] for `rds`
#'   files.
#' @author Ahmed El-Gabbas
#' @return Depending on the contents of the `RData` file, this function returns
#'   either a single R object or a named list of R objects. The names of the
#'   list elements (if a list is returned) correspond to the names of the
#'   objects stored within the `RData` file.
#' @export
#' @name load_as
#' @examples
#'
#' file <- system.file("testdata", "culcita_dat.RData", package = "lme4")
#'
#' # ---------------------------------------------------------
#' # loading RData using base::load
#' # ---------------------------------------------------------
#' (load(file))
#'
#' ls()
#'
#' tibble::tibble(culcita_dat)
#'
#' # ---------------------------------------------------------
#' # Loading as custom object name
#' # ---------------------------------------------------------
#' NewObj <- load_as(file = file)
#'
#' ls()
#'
#' print(tibble::tibble(NewObj))
#'
#' # ---------------------------------------------------------
#' # Loading multiple objects stored in single RData file
#' # ---------------------------------------------------------
#'
#' # store three objects to single RData file
#' mtcars2 <- mtcars3 <- mtcars
#'
#' # save in the order of mtcars2, mtcars3, mtcars
#' TempFile_1 <- tempfile(pattern = "mtcars_", fileext = ".RData")
#' save(mtcars2, mtcars3, mtcars, file = TempFile_1)
#'
#' # save in another order: mtcars, mtcars2, mtcars3
#' TempFile_2 <- tempfile(pattern = "mtcars_", fileext = ".RData")
#' save(mtcars, mtcars2, mtcars3, file = TempFile_2)
#'
#'
#' # loading as a single list  with 3 items, keeping original order
#' mtcars_all_1 <- load_as(TempFile_1)
#' str(mtcars_all_1, 1)
#'
#' mtcars_all_2 <- load_as(TempFile_2)
#' str(mtcars_all_2, 1)

load_as <- function(file = NULL, n_threads = 1L, timeout = 300L, ...) {

  if (is.null(file)) {
    ecokit::stop_ctx("file or URL cannot be NULL", file = file)
  }

  if (startsWith(file, "http")) {
    if (isFALSE(ecokit::check_url(file))) {
      ecokit::stop_ctx("URL is not valid", file = file)
    }

    withr::local_options(list(timeout = timeout))

    # Download file to temporary location
    temp_file <- tempfile(fileext = paste0(".", tools::file_ext(file)))
    utils::download.file(file, destfile = temp_file, mode = "wb", quiet = TRUE)
    file <- temp_file

    # remove the temporary file at the end of the function execution
    on.exit(file.remove(temp_file), add = TRUE)
  }

  if (!file.exists(file)) {
    ecokit::stop_ctx("`file` does not exist", file = file)
  }

  # file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  output_file <- switch(
    extension,
    qs2 = qs2::qs_read(file = file, nthreads = n_threads, ...),
    rdata = {
      # Load the .RData file and capture the names of loaded objects
      in_file_0 <- load(file, ...)

      if (length(in_file_0) == 1L) {
        output_file <- get(paste0(in_file_0))
      } else {
        output_file <- lapply(in_file_0, function(x) {
          get(paste0(x))
        })
        names(output_file) <- in_file_0
      }
      return(output_file)
    },
    rds = readRDS(file, ...),
    feather = arrow::read_feather(file = file, ...),
    ecokit::stop_ctx(
      "Unknown file extension", file = file, extension = tools::file_ext(file)))

  return(output_file)
}
