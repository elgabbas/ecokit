## |------------------------------------------------------------------------| #
# check_tiff ----
## |------------------------------------------------------------------------| #

#' Check if a tiff file corrupted
#'
#' This function checks if the provided tiff file is corrupted by attempting to
#' describe it using the `terra` package and searching for the presence of a
#' "Driver" string in the description, which indicates a valid tiff file. If the
#' string is found, the function returns `TRUE` and `FALSE` otherwise. The
#' function works also for reading netCDF files with the `terra` package.
#' @param x Character; the file path of the tiff file to be checked. The
#'   function will stop with an error if `x` is `NULL` or if the file does not
#'   exist.
#' @param warning Logical. If `TRUE`, the function will issue a warning if the
#'   file does not exist.
#' @name check_tiff
#' @author Ahmed El-Gabbas
#' @return Logical; returns `TRUE` if the tiff file is not corrupted (i.e., it
#'   can be described and contains "Driver" in its description), and `FALSE`
#'   otherwise.
#' @export
#' @examples
#' (f <- system.file("ex/elev.tif", package="terra"))
#'
#' check_tiff(x = f)
#'
#' # a temp file ends with .tif (not a valid tiff file)
#' (temp_file <- tempfile(fileext = ".tif"))
#' fs::file_create(temp_file)
#' check_tiff(x = temp_file)

check_tiff <- function(x = NULL, warning = TRUE) {

  # Check input argument
  if (is.null(x)) {
    ecokit::stop_ctx("Input file cannot be NULL", x = x)
  }

  # # ..................................................................... ###

  # Check if file exists
  if (!file.exists(x)) {
    if (warning) {
      warning("Input file does not exist", call. = FALSE)
    }
    return(FALSE)
  }

  # # ..................................................................... ###

  # Check file metadata using terra's describe

  metadata_okay <- terra::describe(x = x) %>%
    as.character() %>%
    stringr::str_detect("Driver") %>%
    any() %>%
    # suppress known warnings that could happen in some cases
    # https://github.com/rspatial/terra/issues/1212
    # https://github.com/rspatial/terra/issues/1832
    # https://stackoverflow.com/questions/78098166
    #   Warning messages:
    #   1: In .gdalinfo(x, options, open_opt) :
    #   GDAL Message 1: dimension #1 (easting) is not a Longitude/X dimension.
    #   2: In .gdalinfo(x, options, open_opt) :
    #   GDAL Message 1: dimension #0 (northing) is not a Latitude/Y dimension.
    suppressWarnings()

  if (isFALSE(metadata_okay)) {
    return(FALSE)
  }

  out_value <- terra::rast(x) %>%
    terra::hasValues() %>%
    suppressWarnings()

  # # ..................................................................... ###

  return(out_value)
}
