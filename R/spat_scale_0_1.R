## |------------------------------------------------------------------------| #
# scale_0_1 ----
## |------------------------------------------------------------------------| #

#' Scale a raster object’s values to a range between 0 and 1
#'
#' Scales the values of a `SpatRaster` (from the `terra` package), `Raster*`
#' (from the `raster` package), or a raster file loaded via `terra::rast()` to a
#' range between 0 and 1.
#'
#' @param raster A `SpatRaster`, `RasterLayer`, `RasterStack`, `RasterBrick`
#'   object, or a character string specifying the path to a raster file that can
#'   be loaded with `terra::rast()` (e.g., GeoTIFF, NetCDF).
#' @return A `SpatRaster` object with all values scaled between 0 and 1.
#' @note This function accepts a `SpatRaster`, `Raster*` object, or a file path.
#'   `Raster*` objects are coerced to `SpatRaster` using `terra::rast()`, and
#'   file paths are loaded as `SpatRaster`. It calculates the minimum and
#'   maximum values and scales all values between 0 and 1.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' ecokit::load_packages(terra, raster, fs, ggplot2, tidyterra)
#'
#' # Setup temporary directory
#' temp_dir <- tempdir()
#' on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)
#'
#' # Example with SpatRaster
#' r <- terra::rast(ncols = 10, nrows = 10)
#' terra::values(r) <- rnorm(terra::ncell(r))
#' r_scaled <- scale_0_1(r)
#' c(r, r_scaled)
#'
#' # Example with RasterLayer
#' r_raster <- raster::raster(ncol = 10, nrow = 10)
#' raster::values(r_raster) <- rnorm(raster::ncell(r_raster))
#' r_raster_scaled <- scale_0_1(r_raster)
#' c(r_raster, r_raster_scaled)
#'
#' # Example with file path
#' r_file <- fs::path(temp_dir, "raster.tif")
#' terra::writeRaster(r, r_file, overwrite = TRUE)
#' r_file_scaled <- scale_0_1(r_file)
#' c(terra::rast(r_file), r_file_scaled)
#'
#' # Visualize results
#' ggplot2::ggplot() +
#'   tidyterra::geom_spatraster(data = r, maxcell = Inf) +
#'   ggplot2::theme_minimal()
#'
#' ggplot2::ggplot() +
#'   tidyterra::geom_spatraster(data = r_scaled, maxcell = Inf) +
#'   ggplot2::theme_minimal()

scale_0_1 <- function(raster) {

  # Input validation
  accepted_classes <- c(
    "SpatRaster", "RasterLayer", "RasterStack", "RasterBrick")
  if (!is.character(raster) && !inherits(raster, accepted_classes)) {
    ecokit::stop_ctx(
      paste0(
        "`raster` must be a SpatRaster, RasterLayer, RasterStack, ",
        "RasterBrick, or a file path loadable by terra::rast()"))
  }

  # Handle file path input
  if (is.character(raster)) {
    if (!file.exists(raster)) {
      ecokit::stop_ctx(
        "File does not exist", file = ecokit::normalize_path(raster))
    }

    tryCatch({
      raster <- terra::rast(raster)
    }, error = function(e) {
      ecokit::stop_ctx(
        "Failed to load raster file with terra::rast()",
        file = ecokit::normalize_path(raster))
    })
  }

  # Coerce Raster* to SpatRaster if necessary
  if (inherits(raster, c("RasterLayer", "RasterStack", "RasterBrick"))) {
    raster <- terra::rast(raster)
  }

  # Calculate minimum and maximum values
  min_value <- terra::global(raster, "min", na.rm = TRUE)$min
  max_value <- terra::global(raster, "max", na.rm = TRUE)$max

  # Check for valid range
  if (max_value == min_value) {
    ecokit::stop_ctx(
      "Raster has constant values; cannot scale to [0, 1]", raster = raster)
  }

  # Scale to [0, 1]
  scaled <- terra::app(raster, fun = function(v) {
    (v - min_value) / (max_value - min_value)
  })

  scaled
}
