## |------------------------------------------------------------------------| #
# polygon_centroid ----
## |------------------------------------------------------------------------| #

#' Replace the geometry of a polygon with its centroid point
#'
#' This function replaces the geometry of a simple feature (`sf`) polygon object
#' with the geometry of its centroid point. It can optionally rename the
#' geometry column of the modified `sf` object.
#' @param sf_object A simple feature (`sf`) object; the polygon whose geometry
#'   is to be replaced with its centroid. Cannot be `NULL`.
#' @param rename Logical. Whether to rename the geometry column of the sf
#'   object. Defaults to `FALSE`.
#' @param new_name Character. New name for the geometry column. Only valid if
#'   `rename = TRUE`.
#' @name polygon_centroid
#' @author Ahmed El-Gabbas
#' @references [Click here](https://github.com/r-spatial/sf/issues/480)
#' @return The modified sf object with its geometry replaced by the centroid of
#'   the original polygon geometry. If rename is `TRUE`, the geometry column
#'   will also be renamed as specified by NewName.
#' @export

polygon_centroid <- function(
  sf_object = NULL, rename = FALSE, new_name = NULL) {

  if (is.null(sf_object)) {
    ecokit::stop_ctx("Input sf object cannot be NULL", sf_object = sf_object)
  }

  suppressWarnings({
    new_geom <- sf::st_geometry(sf::st_centroid(sf_object))
    sf::st_geometry(sf_object) <- new_geom
  })

  if (rename) {
    if (is.null(new_name)) {
      ecokit::stop_ctx("new_name cannot be NULL", new_name = new_name)
    }

    sf_object <- rename_geometry(sf_object = sf_object, new_name = new_name)
  }

  return(sf_object)
}
