## |------------------------------------------------------------------------| #
# clip_raster_by_polygon ------
## |------------------------------------------------------------------------| #

#' Clip a raster layer by a spatial polygon
#'
#' This function clips a raster layer using a specified spatial polygon,
#' effectively masking the raster outside the polygon area. The resulting
#' clipped raster retains the original raster's properties and values within the
#' polygon's bounds.
#' @param raster A `RasterLayer` object to be clipped. This is the raster layer
#'   that will be masked by the polygon.
#' @param shape Extent object, or any object from which an Extent object can be
#'   extracted.
#' @return A RasterLayer object representing the portion of the input raster
#'   that falls within the specified polygon. The returned raster contains the
#'   same data as the original within the polygon's bounds but is masked (set to
#'   NA) outside of it.
#' @note This function requires the 'raster' and 'sp' packages.
#' @export
#' @name clip_raster_by_polygon
#' @author Ahmed El-Gabbas
#' @examples
#' library(sp)
#' library(raster)
#' library(rworldmap)
#'
#' # Example Polygon
#' SPDF <- getMap(resolution = "low") %>%
#'    subset(NAME == "Germany")
#'
#' # Example RasterLayer
#' r <- raster::raster(nrow = 1e3, ncol = 1e3, crs = proj4string(SPDF))
#' r[] <- seq_len(length(r))
#' plot(r)
#' plot(SPDF, add = TRUE)
#'
#' # ----------------------------------
#'
#' SPDF_DE <- clip_raster_by_polygon(r, SPDF)
#' plot(raster::extent(SPDF_DE), axes = FALSE, xlab = "", ylab = "")
#' plot(SPDF_DE, add = TRUE)
#' plot(SPDF, add = TRUE)

clip_raster_by_polygon <- function(raster = NULL, shape = NULL) {

  if (is.null(raster) || is.null(shape)) {
    ecokit::stop_ctx(
      "Input raster or shape cannot be NULL", raster = raster, shape = shape)
  }

  a1_crop <- raster::crop(raster, shape)
  step1 <- raster::rasterize(shape, a1_crop, field = 1L)
  clipped_raster <- a1_crop * step1
  names(clipped_raster) <- names(raster)

  return(clipped_raster)
}
