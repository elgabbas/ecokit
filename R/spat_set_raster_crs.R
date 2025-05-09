## |------------------------------------------------------------------------| #
# set_raster_crs  ------
## |------------------------------------------------------------------------| #

#' Set CRS for a SpatRaster in a Pipeline
#'
#' Sets the coordinate reference system (CRS) of a `SpatRaster` object using a
#' specified CRS string, designed for use in data processing pipelines (e.g.,
#' with `%>%`). Wraps `terra::crs<-` to assign a valid CRS, such as an EPSG
#' code.
#' @name set_raster_crs
#' @param raster A `SpatRaster` object whose CRS is to be set. Cannot be `NULL`
#'   or non-`SpatRaster`.
#' @param crs Character. A valid CRS string (e.g., EPSG code, WKT, or PROJ4) to
#'   set for the `raster`.
#' @author Ahmed El-Gabbas
#' @export
#' @return The modified `SpatRaster` object with the updated CRS.
#' @examples
#' load_packages(terra)
#'
#' # Create a sample SpatRaster, with missing CRS
#' r <- terra::rast(nrows = 10, ncols = 10, vals = 1:100)
#' terra::crs(r) <- NULL
#' print(r)
#'
#' terra::crs(r, describe = TRUE)$code
#'
#'
#' # Set CRS to EPSG:4326
#' (r_modified <- set_raster_crs(r, "epsg:4326"))
#' terra::crs(r_modified, describe = TRUE)$code

set_raster_crs <- function(raster = NULL, crs = NULL) {

  # Validate raster
  if (is.null(raster)) {
    ecokit::stop_ctx("`raster` cannot be NULL", raster = raster)
  }
  if (!inherits(raster, "SpatRaster")) {
    ecokit::stop_ctx(
      "`raster` must be a `SpatRaster` object", class_raster = class(raster))
  }

  # Validate crs
  if (is.null(crs)) {
    ecokit::stop_ctx("`crs` cannot be NULL", crs = crs)
  }
  if (!is.character(crs) || length(crs) != 1L || !nzchar(crs)) {
    ecokit::stop_ctx(
      "`crs` must be a single non-empty character string", crs = crs)
  }

  # Check if crs is the same as current
  current_crs <- terra::crs(raster, describe = TRUE)$code
  if (!is.na(current_crs) && current_crs == crs) {
    warning("`crs` is already set to the specified value: ", crs, call. = FALSE)
  }

  # Validate crs by attempting to set it on a temporary raster
  tryCatch(
    {
      temp_raster <- terra::rast(raster)
      terra::crs(temp_raster) <- crs
    },
    error = function(e) {
      ecokit::stop_ctx(
        paste0("Invalid `crs` value: ", conditionMessage(e)),
        crs = crs, error = e)
    })

  # Set crs
  terra::crs(raster) <- crs

  return(raster)
}
