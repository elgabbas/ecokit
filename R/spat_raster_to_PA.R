## |------------------------------------------------------------------------| #
# raster_to_PA ------
## |------------------------------------------------------------------------| #

#' Convert raster map into binary (1/0)
#'
#' This function converts raster values into a binary format where positive
#' values are set to 1 (presence) and zeros remain 0 (absence). Additionally, it
#' allows for the conversion of NA values to 0, and/or 0 values to NA, based on
#' the user's choice.
#' @name raster_to_PA
#' @param raster The input raster map. It must be of class `PackedSpatRaster`,
#'   `RasterLayer`, or `SpatRaster`. This parameter cannot be NULL.
#' @param NA_to_0 A logical value indicating whether NA values should be
#'   converted to 0. Defaults to `TRUE`.
#' @param zero_to_NA A logical value indicating whether 0 values should be
#'   converted to NA. Defaults to `FALSE`.
#' @return A raster map where values have been converted according to the
#'   specified parameters. This object is of the same class as the input object.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' ecokit::load_packages(
#'    package_list = c("dplyr", "raster", "ggplot2", "tidyterra"))
#'
#' r <- r2 <- raster::raster(
#'   system.file("external/test.grd", package = "raster"))
#'
#' # change some values to 0
#' r[5000:6000] <- 0
#' r <- raster::mask(r, r2)
#'
#' ggplot2::ggplot() +
#'   tidyterra::geom_spatraster(data = terra::rast(r), maxcell = Inf) +
#'   ggplot2::theme_minimal()
#'
#' r_2 <- raster::stack(
#'   # NA replaced with 0
#'   raster_to_PA(raster = r),
#'   # NA is kept as NA
#'   raster_to_PA(raster = r, NA_to_0 = FALSE),
#'   # 0 replaced with NA in the second map
#'   raster_to_PA(raster = raster_to_PA(r), zero_to_NA = TRUE))
#'
#' ggplot2::ggplot() +
#'   tidyterra::geom_spatraster(
#'     data = terra::as.factor(terra::rast(r_2)), maxcell = Inf) +
#'   ggplot2::facet_wrap(~lyr) +
#'   ggplot2::scale_fill_manual(values = c("grey30", "red"),
#'     na.value = "transparent") +
#'   ggplot2::theme_minimal()

raster_to_PA <- function(raster = NULL, NA_to_0 = TRUE, zero_to_NA = FALSE) {

  if (is.null(raster)) {
    ecokit::stop_ctx("raster can not be NULL", raster = raster)
  }

  if (inherits(raster, "PackedSpatRaster")) {
    raster <- terra::unwrap(raster)
  }

  if (inherits(raster, "RasterLayer")) {
    max_value <- raster::cellStats(raster, max)
    if (max_value > 0L) raster[raster > 0L] <- 1L
    if (NA_to_0) raster <- raster::reclassify(raster, cbind(NA, 0L))
    if (zero_to_NA) raster <- raster::reclassify(raster, cbind(0L, NA))
  } else {

    if (!inherits(raster, "SpatRaster")) {
      ecokit::stop_ctx(
        paste0(
          "Input map should be either PackedSpatRaster, ",
          "RasterLayer, or SpatRaster"),
        raster = raster, class_raster = class(raster))
    }

    raster <- terra::classify(raster, cbind(0L, Inf, 1L))
    if (NA_to_0) raster <- terra::classify(raster, cbind(NA, 0L))
    if (zero_to_NA) raster <- terra::classify(raster, cbind(0L, NA))
  }
  return(raster)
}
