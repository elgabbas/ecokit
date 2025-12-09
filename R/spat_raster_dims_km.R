# # |------------------------------------------------------------------------| #
# raster_dims_km ----
## |------------------------------------------------------------------------| #

#' Raster dimensions in kilometres for lon/lat SpatRaster
#'
#' Compute approximate cell size (east–west and north–south) in kilometres at
#' the raster centre, and the raster extent width/height in kilometres, for an
#' unprojected longitude/latitude `SpatRaster`.
#'
#' @details The function uses [terra::distance] and includes an anti-meridian
#'   guard: if the longitudinal span exceeds 180 degrees (e.g., a global extent
#'   `-180, 180`), the shortest geodesic between `xmin` and `xmax` collapses to
#'   zero. In that case, the extent width is estimated as `ncol(r) *
#'   cell_width` (cell width evaluated at the raster centre).
#' - East-west cell width varies with latitude; width is calculated at the
#'   raster's centre latitude for a single representative value.
#' - North-south cell height varies slightly with latitude; the centre value
#'   is reported.
#' - The CRS must be a geographic lon/lat CRS (e.g., EPSG:4326).
#'
#' @param r A `terra::SpatRaster` in longitude/latitude coordinates (degrees).
#'
#' @return A tibble with:
#' - `ncol`, `nrow`: raster dimensions (cells).
#' - `cell_width`, `cell_height`: centre cell size (km).
#' - `extent_width`, `extent_height`: extent size (km).
#'
#' @examples
#' require(terra)
#'
#' # Global lon/lat raster (1-degree)
#' r1 <- terra::rast()
#' raster_dims_km(r1)
#'
#' # Regional raster over Europe
#' r2 <- terra::rast(
#'   ncols = 400, nrows = 200, xmin = -10, xmax = 30, ymin = 35, ymax = 55)
#' raster_dims_km(r2)
#'
#' @export
#' @author Ahmed El-Gabbas

raster_dims_km <- function(r) {


  # Validate input -------

  if (!inherits(r, "SpatRaster")) {
    ecokit::stop_ctx("`r` must be a terra SpatRaster.")
  }
  if (is.na(terra::crs(r))) {
    ecokit::stop_ctx(
      "CRS is missing. Set a lon/lat CRS (e.g., 'EPSG:4326') before use."
    )
  }
  if (!terra::is.lonlat(r)) {
    ecokit::stop_ctx(
      "`r` must be in lon/lat (geographic degrees) projection" # nolint
    )
  }

  # Basic geometry -------

  # Raster extent and resolution
  e <- terra::ext(r)
  rs <- terra::res(r)
  # centre longitude
  cx <- (e$xmin + e$xmax) / 2L
  # centre latitude
  cy <- (e$ymin + e$ymax) / 2L
  # longitudinal span (deg)
  dx <- e$xmax - e$xmin

  # Convert to a SpatVector ------

  pts <- rbind(
    # 1=centre
    c(cx, cy),
    # 2=one cell east
    c(cx + rs[1L], cy),
    # 3=one cell north
    c(cx, cy + rs[2L]),
    # 4=west edge at centre lat
    c(e$xmin, cy),
    # 5=east edge at centre lat
    c(e$xmax, cy),
    # 6=south edge at centre lon
    c(cx, e$ymin),
    # 7=north edge at centre lon
    c(cx, e$ymax)
  )
  v <- terra::vect(pts, type = "points", crs = terra::crs(r))

  # Cell size at raster centre (km) -------

  # East–west distance across one cell at the centre latitude.
  cell_w <- as.numeric(terra::distance(v[1L], v[2L])) / 1000L
  # North–south distance across one cell at the centre longitude.
  cell_h <- as.numeric(terra::distance(v[1L], v[3L])) / 1000L

  # Extent height (km) along the centre longitude
  extent_h <- as.numeric(terra::distance(v[6L], v[7L])) / 1000L

  # Extent width (km) with anti-meridian guard
  if (dx <= 180L) {
    extent_w <- as.numeric(terra::distance(v[4L], v[5L])) / 1000L
  } else {
    # For spans > 180°, the shortest path wraps and yields ~0.
    # Use number of columns times centre cell width as a robust estimate.
    extent_w <- ncol(r) * cell_w
  }

  # Fallback in case endpoints numerically coincide (e.g., -180 vs 180)
  if (extent_w == 0L && dx > 0L) {
    extent_w <- ncol(r) * cell_w
  }

  # Assemble result as a tibble -------
  tibble::tibble(
    ncol = ncol(r),
    nrow = nrow(r),
    cell_width = cell_w,
    cell_height = cell_h,
    extent_width = extent_w,
    extent_height = extent_h
  )
}
