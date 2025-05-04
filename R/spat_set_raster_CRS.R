## |------------------------------------------------------------------------| #
# set_raster_CRS  ------
## |------------------------------------------------------------------------| #

#' sets CRS for a SpatRaster
#'
#' This function sets the coordinate reference system (CRS) for a SpatRaster
#' object using the specified EPSG code. This is a wrapper function for
#' `terra::crs(raster) <- CRS` but allowing to set the CRS in the pipe.
#' @name set_raster_CRS
#' @param raster A SpatRaster object whose CRS needs to be set.
#' @param CRS Character. CRS value to be set, default is "epsg:3035".
#' @return The SpatRaster object with the updated CRS.
#' @author Ahmed El-Gabbas
#' @export

set_raster_CRS <- function(raster, CRS = "epsg:3035") {
  terra::crs(raster) <- CRS
  return(raster)
}
