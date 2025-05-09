## |------------------------------------------------------------------------| #
# rename_geometry ----
## |------------------------------------------------------------------------| #

#' Rename Active Geometry Column of an `sf` Object
#'
#' Renames the active geometry column of a simple feature (`sf`) object to a
#' user-specified name.
#' @param sf_object An `sf` object with an active geometry column. Cannot be
#'   `NULL`.
#' @param new_name Character. A single, non-empty name for the geometry column.
#'   Cannot be `NULL` or match an existing non-geometry column name.
#' @name rename_geometry
#' @references [Click here](https://gis.stackexchange.com/a/386589/30390)
#' @export
#' @return The modified `sf` object with the geometry column renamed to
#'   `new_name`.
#' @note The `sf_object` must have a valid geometry column, and `new_name` must
#'   not conflict with existing column names.
#' @examples
#' load_packages(sf)
#'
#' # example data
#' (nc <- sf::st_read(
#'   dsn = system.file("shape/nc.shp", package = "sf"), quiet = TRUE) %>%
#'   dplyr::select(AREA))
#'
#' # Rename geometry column
#' (nc_renamed <- rename_geometry(nc, "new_geom"))
#'
#' names(nc)
#' names(nc_renamed)
#'
#' attr(nc, "sf_column")
#' attr(nc_renamed, "sf_column")

rename_geometry <- function(sf_object = NULL, new_name = NULL) {

  # Validate inputs
  if (is.null(sf_object)) {
    ecokit::stop_ctx("`sf_object` cannot be NULL", sf_object = sf_object)
  }
  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "`sf_object` must be an `sf` object", class_sf_object = class(sf_object))
  }
  if (is.null(new_name)) {
    ecokit::stop_ctx("`new_name` cannot be NULL", new_name = new_name)
  }
  if (!is.character(new_name) || length(new_name) != 1L || !nzchar(new_name)) {
    ecokit::stop_ctx(
      "`new_name` must be a single non-empty character string",
      new_name = new_name)
  }

  # Validate active geometry column
  current <- attr(sf_object, "sf_column")
  if (is.null(current) || !current %in% names(sf_object)) {
    ecokit::stop_ctx(
      "`sf_object` lacks a valid active geometry column", sf_column = current)
  }

  # Check for column name conflict
  if (new_name %in% names(sf_object) && new_name != current) {
    ecokit::stop_ctx(
      "`new_name` cannot match an existing non-geometry column name",
      new_name = new_name, existing_columns = names(sf_object))
  }

  # Rename geometry column
  names(sf_object)[names(sf_object) == current] <- new_name
  sf::st_geometry(sf_object) <- new_name
  return(sf_object)
}
