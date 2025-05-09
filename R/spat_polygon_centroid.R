## |------------------------------------------------------------------------| #
# polygon_centroid ----
## |------------------------------------------------------------------------| #

#' Replace Polygon Geometry with Centroid Point
#'
#' Replaces the geometry of a simple feature (`sf`) polygon object with its
#' centroid point. Optionally renames the geometry column of the modified `sf`
#' object.
#' @param sf_object A simple feature (`sf`) object with polygon or multipolygon
#'   geometry. Cannot be `NULL`.
#' @param rename Logical. Whether to rename the geometry column. Defaults to
#'   `FALSE`.
#' @param new_name Character. New name for the geometry column. Must be a
#'   single, non-empty character string if `rename = TRUE`. Defaults to `NULL`.
#' @name polygon_centroid
#' @author Ahmed El-Gabbas
#' @references [Click here](https://github.com/r-spatial/sf/issues/480)
#' @return The modified `sf` object with its geometry replaced by the centroid
#'   points of the original polygon geometries. If `rename = TRUE`, the geometry
#'   column is renamed to `new_name`.
#' @export
#' @examples
#' load_packages(sf, ggplot2, dplyr)
#'
#' # example data
#' (nc <- sf::st_read(
#'   dsn = system.file("shape/nc.shp", package = "sf"), quiet = TRUE) %>%
#'   dplyr::select(AREA))
#'
#' # Replace polygon geometry with centroids
#' (nc_centroid <- polygon_centroid(nc))
#'
#' ggplot2::ggplot() +
#'   ggplot2::geom_sf(data = nc, aes(fill = NULL)) +
#'   ggplot2::geom_sf(data = nc_centroid, colour = "red") +
#'   ggplot2::theme_minimal()
#'
#' # Rename geometry column
#' (nc_centroid_renamed <- polygon_centroid(
#'   sf_object = nc, rename = TRUE, new_name = "centroid"))
#'
#' attr(nc, "sf_column")
#' attr(nc_centroid, "sf_column")
#' attr(nc_centroid_renamed, "sf_column")

polygon_centroid <- function(
  sf_object = NULL, rename = FALSE, new_name = NULL) {

  # Validate sf_object
  if (is.null(sf_object)) {
    ecokit::stop_ctx("`sf_object` cannot be NULL", sf_object = sf_object)
  }
  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "`sf_object` must be an `sf` object", class_sf_object = class(sf_object))
  }

  # Validate geometry type
  geom_types <- unique(sf::st_is(sf_object, c("POLYGON", "MULTIPOLYGON")))
  if (!all(geom_types)) {
    ecokit::stop_ctx(
      "`sf_object` must have POLYGON or MULTIPOLYGON geometries",
      geometry_types = geom_types)
  }

  # Check for empty geometries
  if (any(sf::st_is_empty(sf_object))) {
    ecokit::stop_ctx("`sf_object` contains empty geometries")
  }

  # Compute centroids and assign geometry
  tryCatch(
    {
      new_geom <- sf::st_geometry(sf::st_centroid(sf_object)) %>%
        suppressWarnings()
    },
    error = function(e) {
      ecokit::stop_ctx(
        paste0("Error computing centroids: ", conditionMessage(e)),
        error = e)
    })
  sf::st_geometry(sf_object) <- new_geom

  if (rename) {
    if (is.null(new_name) || !is.character(new_name) ||
        length(new_name) != 1L || !nzchar(new_name)) {
      ecokit::stop_ctx(
        "`new_name` must be a single non-empty character string",
        new_name = new_name)
    }

    sf_object <- ecokit::rename_geometry(
      sf_object = sf_object, new_name = new_name)
  }

  return(sf_object)
}
