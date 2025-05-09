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
#' @export
#' @name clip_raster_by_polygon
#' @author Ahmed El-Gabbas
#' @examples
#' load_packages(raster, sp, rworldmap, ggplot2)
#'
#' # example Polygon
#' SPDF <- rworldmap::getMap(resolution = "low") %>%
#'    subset(NAME == "Germany")
#'
#' # example raster
#' r <- raster::raster(
#'   xmn = 2, xmx = 18, ymn = 45, ymx = 58, resolution = 0.125)
#' r[] <- seq_len(length(r))
#' r
#'
#' # plotting example data
#' ggplot2::ggplot() +
#'   ggplot2::geom_raster(
#'     data = as.data.frame(r, xy = TRUE),
#'     ggplot2::aes(x = x, y = y, fill = layer)) +
#'   ggplot2::geom_sf(
#'     data = sf::st_as_sf(SPDF), fill = NA, color = "black", linewidth = 0.5) +
#'   ggplot2::scale_fill_viridis_c() +
#'   ggplot2::theme_minimal() +
#'   ggplot2::labs(x = NULL, y = NULL) +
#'   ggplot2::theme(axis.text = ggplot2::element_blank())
#'
#' # ----------------------------------
#'
#' SPDF_DE <- clip_raster_by_polygon(r, SPDF)
#'
#' ggplot2::ggplot() +
#'   ggplot2::geom_tile(
#'     data = as.data.frame(SPDF_DE, xy = TRUE),
#'     ggplot2::aes(x = x, y = y, fill = layer)) +
#'   ggplot2::geom_sf(
#'     data = sf::st_as_sf(SPDF), fill = NA, color = "black", linewidth = 0.5) +
#'   ggplot2::scale_fill_viridis_c() +
#'   ggplot2::theme_minimal() +
#'   ggplot2::labs(x = NULL, y = NULL) +
#'   ggplot2::theme(axis.text = ggplot2::element_blank())

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
