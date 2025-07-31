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
#' @param n_threads Number of threads to use when reading `qs2` files. See
#'   [qs2::qs_read].
#' @param timeout integer; time in seconds before the download times out.
#'   Default 300 seconds; see [download.file].
#' @param load_packages Logical. If TRUE (default), attempt to load R packages
#'   that correspond to the main classes of the loaded object(s).
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
#'
#' (load(file))
#'
#' ls()
#'
#' tibble::tibble(culcita_dat)
#'
#' # ---------------------------------------------------------
#' # Loading as custom object name
#' # ---------------------------------------------------------
#'
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
#' # loading as a single list  with 3 items, keeping original order
#' mtcars_all_1 <- load_as(TempFile_1)
#' str(mtcars_all_1, 1)
#'
#' mtcars_all_2 <- load_as(TempFile_2)
#' str(mtcars_all_2, 1)

load_as <- function(
    file = NULL, n_threads = 1L, timeout = 300L, load_packages = TRUE, ...) {

  if (is.null(file)) ecokit::stop_ctx("file or URL cannot be NULL")

  if (!is.numeric(n_threads) || n_threads < 1L) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads)
  }

  if (!is.numeric(timeout) || timeout < 1L) {
    ecokit::stop_ctx("`timeout` must be a positive integer", timeout = timeout)
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
      output_file
    },
    rds = readRDS(file, ...),
    feather = arrow::read_feather(file = file, ...),
    ecokit::stop_ctx(
      "Unknown file extension", file = file, extension = extension))
  
  if (inherits(output_file, "PackedSpatRaster")) {
    output_file <- terra::unwrap(output_file)
  }
  
  # ***********************************************************************

  # Optionally load required packages as determined by object class

  if (isFALSE(load_packages)) return(output_file)

  # Mapping of object classes to required packages
  class_to_package <- list(
    sdmModels = "sdm", sdmdata = "sdm", maxent = c("dismo", "rJava"),
    domain.dismo = "dismo", bioclim.dismo = "dismo", brt = "gbm", gam = "mgcv",
    ranger = "ranger", rbf = "RSNNS", mlp = "RSNNS", cart = "tree",
    mda = "mda", fda = "mda", glmnet = "glmnet", mars = "earth", rbf = "RSNNS",
    maxNet = "maxnet", rf = "randomForest", svm = "kernlab", rpart = "rpart",
    fs_path = "fs", sf = "sf", sfc = "sf", SpatVector = "terra",
    SpatRaster = "terra", SpatExtent = "terra", PackedSpatRaster = "terra",
    Extent = "raster", Raster = "raster", RasterLayer = "raster",
    RasterStack = "raster", RasterBrick = "raster", data.table = "data.table",
    tbl_df = "tibble", SpatialPoints = "sp", SpatialPolygons = "sp",
    SpatialLines = "sp")

  classes <- class(output_file)

  if (inherits(output_file, "sdmModels")) {

    classes <- c(as.character(output_file@run.info$method), classes)

  } else if (inherits(output_file, "tbl_df") && nrow(output_file) > 0L) {

    classes <- purrr::map(
      .x = seq_len(ncol(output_file)),
      .f = ~ {
        col <- dplyr::pull(output_file, .x)
        unlist(class(col[[1L]]))
      }) %>%
      unlist() %>%
      c(classes)

    if ("sdmModels" %in% classes) {
      classes <- c(as.character(output_file@run.info$method), classes)
    }

  } else if (inherits(output_file, "list") && length(output_file) > 0L) {
    classes <- purrr::map(
      .x = output_file,
      .f = ~ {
        if (length(.x) == 0L || is.null(.x[[1L]])) {
          return(character(0L))
        }
        class(.x[[1L]])
      }) %>%
      unlist() %>%
      c(classes)
  }

  class_to_package[unname(unique(classes))] %>%
    unlist() %>%
    unique() %>%
    purrr::walk(
      .f  = ~{
        if (requireNamespace(.x, quietly = TRUE)) {
          library( # nolint: undesirable_function_linter
            package = .x, character.only = TRUE, quietly = TRUE,
            warn.conflicts = FALSE)
        }
      }) %>%
    suppressWarnings() %>%
    suppressMessages()

  # ***********************************************************************

  return(output_file)
}
