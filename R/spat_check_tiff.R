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
#' @return Logical; returns `TRUE` if the TIFF file is not corrupted (i.e., the
#'   file exists, can be described with a "Driver" in its metadata, has values,
#'   and its data can be read without errors or warnings), and `FALSE`
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
#'
#' # clean up
#' fs::file_delete(temp_file)

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

  # suppress known warnings that could happen in some cases
  # https://github.com/rspatial/terra/issues/1212
  # https://github.com/rspatial/terra/issues/1832
  # https://stackoverflow.com/questions/78098166
  #   Warning messages:
  #   1: In .gdalinfo(x, options, open_opt) :
  #   GDAL Message 1: dimension #1 (easting) is not a Longitude/X dimension.
  #   2: In .gdalinfo(x, options, open_opt) :
  #   GDAL Message 1: dimension #0 (northing) is not a Latitude/Y dimension.

  metadata_okay <- ecokit::quietly({
    terra::describe(x = x) %>%
      as.character() %>%
      stringr::str_detect("Driver") %>%
      any()
  },
  "is not a Latitude/Y dimension.",
  "is not a Longitude/X dimension.")

  if (isFALSE(metadata_okay)) {
    return(FALSE)
  }

  out_value <- ecokit::quietly(
    terra::hasValues(terra::rast(x)),
    "is not a Latitude/Y dimension.",
    "is not a Longitude/X dimension.")

  # # ..................................................................... ###
  # # ..................................................................... ###

  # Test reading data from multiple rows

  # terra::hasValues() alone is insufficient, as some TIFF files may report
  # values but contain corrupted data, triggering warnings (e.g.,
  # "TIFFFillStrip" errors) or errors when reading. The following test reads the
  # first, middle, and last rows to detect such issues.

  if (out_value) {

    r <- ecokit::quietly(
      terra::rast(x),
      "is not a Latitude/Y dimension.",
      "is not a Longitude/X dimension.")

    rows_to_check <- c(1L, floor(terra::nrow(r) / 2L), terra::nrow(r))

    # Apply a function to each row in rows_to_check to test data reading
    out_value <- purrr::map(
      .x = rows_to_check,
      .f = ~ {
        # Initialize a flag to track if a warning occurs during the read
        warned <- FALSE
        # Attempt to read the row, capturing errors and warnings
        success <- tryCatch(
          expr = {
            # Handle warnings without interrupting the read operation
            withCallingHandlers(
              expr = {
                # Read one row of data from the raster using terra::values()
                v <- terra::values(r, row = .x, nrows = 1L)
                # Return TRUE if the read succeeds
                TRUE
              },
              # Define a handler for warnings during the read
              warning = function(w) {
                # Set the warned flag to TRUE if a warning occurs
                warned <- TRUE
                # Muffle the warning to prevent console output
                invokeRestart("muffleWarning")
              })
          },
          # Define a handler for errors during the read
          error = function(e) {
            # Return FALSE if an error occurs (read failure)
            FALSE
          })
        # Return a named list with success and warned states for the row
        list(success = success, warned = warned)
      }) %>%
      # Check if any row has an error (success = FALSE) or warning (warned =
      # TRUE)
      purrr::some(~ !.x$success || .x$warned) %>%
      # Invert the result: TRUE if no errors/warnings, FALSE if any occur
      magrittr::not()
  }

  return(out_value)
}
