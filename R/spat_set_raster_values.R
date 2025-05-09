## |------------------------------------------------------------------------| #
# set_raster_values ----
## |------------------------------------------------------------------------| #

#' Load Values for `SpatRaster` Objects into Memory
#'
#' Ensures a `SpatRaster` object has its values loaded into memory, processing
#' inputs as a `SpatRaster` object, a file path to a raster, or a `raster`
#' package object (`RasterLayer`, `RasterStack`, `RasterBrick`). Converts and
#' unpacks inputs as needed.
#' @param raster A `SpatRaster` object, a file path to a raster file, or an
#'   object from the `raster` package (e.g., `RasterLayer`, `RasterStack`,
#'   `RasterBrick`).
#' @param raster A `SpatRaster` object, a file path to a raster file (e.g.,
#'   `.tif`, `.nc`), or a `raster` package object (`RasterLayer`, `RasterStack`,
#'   `RasterBrick`). Cannot be `NULL` or missing.
#' @name set_raster_values
#' @author Ahmed El-Gabbas
#' @details The function handles various types of input:
#'   - If a file path is provided, it attempts to load the raster using
#'   [terra::rast()].
#'   - If the input is a packed `SpatRaster`, it unpacks the raster using
#'   [terra::unwrap()].
#'   - If the input is a raster object from the `raster` package, it is
#'   converted to `SpatRaster`.
#' @export
#' @return The `SpatRaster` object with all values loaded into memory.
#' @examples
#' load_packages(terra, raster)
#'
#' f <- system.file("ex/elev.tif", package="terra")
#'
#' # SpatRaster
#' r <- terra::rast(f)
#' terra::inMemory(r)
#' r_mem <- set_raster_values(r)
#' terra::inMemory(r_mem)
#'
#' # PackedSpatRaster
#' r2 <- terra::wrap(terra::rast(f))
#' r2_mem <- set_raster_values(r2)
#' terra::inMemory(r2_mem)
#'
#' # raster
#' r3 <- raster::raster(f)
#' raster::inMemory(r3)
#' r3_mem <- set_raster_values(r3)
#' terra::inMemory(r3_mem)

set_raster_values <- function(raster = NULL) {

  # Validate input
  if (is.null(raster)) {
    ecokit::stop_ctx("`raster` cannot be NULL", raster = raster)
  }

  # Handle character input (file path)
  if (is.character(raster)) {
    if (!file.exists(raster)) {
      ecokit::stop_ctx("Input file path does not exist", raster = raster)
    }
    raster <- tryCatch(
      terra::rast(raster),
      error = function(e) {
        ecokit::stop_ctx(
          paste0("Failed to load raster from file: ", conditionMessage(e)),
          file_path = raster, error = e)
      })
  }

  # Unwrap PackedSpatRaster if necessary
  raster <- tryCatch(
    terra::unwrap(raster),
    error = function(e) {
      ecokit::stop_ctx(
        paste0("Failed to unwrap raster: ", conditionMessage(e)),
        error = e)
    }
  )

  # Convert raster package objects to SpatRaster
  if (inherits(raster, c("RasterLayer", "RasterStack", "RasterBrick"))) {
    raster <- tryCatch(
      terra::rast(raster),
      error = function(e) {
        ecokit::stop_ctx(
          paste0(
            "Failed to convert raster object to SpatRaster: ",
            conditionMessage(e)),
          class_raster = class(raster), error = e)
      })
  }

  if (terra::nlyr(raster) == 0L) {
    ecokit::stop_ctx("`SpatRaster` has no layers", raster = raster)
  }

  # Load values into memory if not already
  if (!all(terra::inMemory(raster))) {
    terra::values(raster) <- terra::values(raster)
  }

  return(raster)
}
