# # |------------------------------------------------------------------------| #
# raster_dims_km ----
## |------------------------------------------------------------------------| #

#' Raster dimensions in kilometres for lon/lat SpatRaster
#'
#' Compute approximate cell size (east–west and north–south) in kilometres at
#' the raster centre, and the raster extent width/height in kilometres, for an
#' unprojected longitude/latitude `SpatRaster`.
#'
#' @details
#' - The function uses [terra::distance] for width/height calculations, and
#' includes an anti-meridian guard: if the longitudinal span exceeds 180 degrees
#' (global extents like `-180, 180`), the geodesic between `xmin` and `xmax`
#' collapses to zero. In that case, the extent width is estimated as `ncol(r) *
#' cell_width`.
#' - East-west cell width varies with latitude; width is calculated at the
#' raster's centre latitude.
#' - North-south cell height varies slightly with latitude; centre value is
#' reported.
#' - The CRS must be a geographic lon/lat CRS (e.g., EPSG:4326).
#' - Optionally, you can exclude any row or column that is completely NA (not
#' just outer cells, but *any* row or column that consists entirely of NA
#' values), by using the `exclude_na = TRUE` argument. When enabled, returns
#' additional columns `extent_width_occupied` and `extent_height_occupied`,
#' which are calculated as the number of internal columns/rows **not completely
#' NA** times the cell size at raster centre. This is useful when a raster
#' contains large internal regions (rows, columns) of missing data (e.g., ocean
#' bands between landmasses).
#' - If `exclude_na = TRUE` and `r` has multiple layers, only the first layer is
#' used for determining non-NA rows and columns.
#'
#' @param r A `terra::SpatRaster` in longitude/latitude coordinates (degrees).
#' @param exclude_na Logical. If `TRUE`, also return `extent_width_occupied` and
#'   `extent_height_occupied`, after excluding all columns/rows that are only
#'   `NA`. Default is `FALSE`.
#' @param warning Logical. If `TRUE`, prints warning for multi-layer rasters and
#'   for other checks. Default is `TRUE`.
#'
#' @return A tibble with:
#' - `ncol`, `nrow`: raster dimensions (cells).
#' - `cell_width`, `cell_height`: centre cell size (km).
#' - `extent_width`, `extent_height`: extent size (km).
#' - If `exclude_na` is `TRUE`, also `extent_width_occupied`,
#' `extent_height_occupied`.
#'
#' @examples
#' require(terra)
#' require(dismo)
#'
#' # Global lon/lat raster (1-degree)
#' r1 <- terra::rast()
#' raster_dims_km(r1)
#' # This gives error as input raster has no values:
#' # raster_dims_km(r1, exclude_na = TRUE)
#'
#' # Regional raster over Europe
#' r2 <- terra::rast(
#'   ncols = 40, nrows = 40, xmin = 10, xmax = 20,
#'   ymin = 10, ymax = 20, vals = 1L)
#' # make some rows and columns NA
#' r2[15:25, ] <- NA
#' r2[, 10:15] <- NA
#' plot(r2)
#' raster_dims_km(r2)
#' raster_dims_km(r2, exclude_na = TRUE)
#'
#' # Example with real multi-layer raster files from dismo package
#' fnames <- list.files(
#'   path = fs::path(system.file(package = "dismo"), "ex"),
#'   pattern = "grd", full.names = TRUE)
#' r3 <- terra::rast(fnames)
#' raster_dims_km(r3)
#'
#' # a single column is completely NA in the first layer
#' # raster_dims_km uses the first layer to check for NA rows/columns
#' raster_dims_km(r3, exclude_na = TRUE, warning = FALSE)
#' # the same as previous
#' raster_dims_km(r3[[1]], exclude_na = TRUE, warning = FALSE)
#'
#' raster_dims_km(r3[[2]], exclude_na = TRUE, warning = FALSE)
#'
#' @export
#' @author Ahmed El-Gabbas

raster_dims_km <- function(r, exclude_na = FALSE, warning = TRUE) {

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

  if (exclude_na) {
    if (!terra::hasValues(r)) {
      ecokit::stop_ctx(
        "`exclude_na = TRUE` cannot be used with rasters that have no values.")
    }
    if (terra::nlyr(r) > 1L) {
      if (warning) {
        warning(
          "`exclude_na = TRUE` with multi-layer rasters: NA check is done on",
          " all layers combined (cell is non-NA if any layer is non-NA).",
          call. = FALSE)
      }
      r <- r[[1L]]
    }
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
  if (exclude_na) {
    r_matrix <- as.matrix(r, wide = TRUE) %>%
      as.data.frame() %>%
      tibble::tibble() %>%
      dplyr::select(tidyselect::where(~!all(is.na(.)))) %>%
      dplyr::filter(!apply(., 1L, function(x) all(is.na(x))))

    tibble::tibble(
      ncol = ncol(r), nrow = nrow(r),
      cell_width = cell_w, cell_height = cell_h,
      extent_width = extent_w, extent_height = extent_h,
      extent_width_occupied = ncol(r_matrix) * cell_w,
      extent_height_occupied = nrow(r_matrix) * cell_h
    )

  } else {
    tibble::tibble(
      ncol = ncol(r), nrow = nrow(r),
      cell_width = cell_w, cell_height = cell_h,
      extent_width = extent_w, extent_height = extent_h)
  }
}
