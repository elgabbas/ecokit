## |------------------------------------------------------------------------| #
# scale_0_1 ----
## |------------------------------------------------------------------------| #

#' Scale a `SpatRaster` object values to a range between 0 and 1
#'
#' Scale a `SpatRaster` object (from the `terra` R package in) values to a range
#' between 0 and 1.
#' @param raster SpatRaster; The SpatRaster object to be scaled.
#' @name scale_0_1
#' @author Ahmed El-Gabbas
#' @export
#' @return SpatRaster; A SpatRaster object with all values scaled between 0 and
#'   1.
#' @note This function takes a SpatRaster object as input, calculates its
#'   minimum and maximum values, and scales all its values to a range between 0
#'   and 1. This is useful for normalisation purposes in spatial analysis and
#'   modelling. The function relies on the `terra` package for spatial data
#'   manipulation.
#' @examples
#' library(terra)
#' r <- rast(ncols = 10, nrows = 10)
#' values(r) <- seq_len(terra::ncell(r))
#'
#' (r2 <- scale_0_1(r))
#'
#' plot(c(r, r2), main = c("Original", "Scaled"), axes = FALSE)

scale_0_1 <- function(raster) {
  # ensure raster is indeed a SpatRaster object
  stopifnot(
    "raster should be a SpatRaster object" = inherits(raster, "SpatRaster"))

  # Minimum and Maximum Values
  min_value <- terra::global(raster, "min", na.rm = TRUE)$min
  max_value <- terra::global(raster, "max", na.rm = TRUE)$max

  # Scaling between 0 and 1
  scaled <- terra::app(raster, fun = function(v) {
    (v - min_value) / (max_value - min_value)
  })

  return(scaled)
}
