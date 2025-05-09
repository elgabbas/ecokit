## |------------------------------------------------------------------------| #
# set_geometry ----
## |------------------------------------------------------------------------| #

#' Set Geometry Column of an `sf` Object in a Pipeline
#'
#' Sets the active geometry column of a simple feature (`sf`) object to a
#' specified column, designed for use in data processing pipelines (e.g., with
#' `%>%`). Ensures spatial operations use the correct geometry column.
#' @param sf_object An `sf` object with at least one geometry (`sfc`) column.
#'   Cannot be `NULL` or non-`sf`.
#' @param geometry_column Character. Name of an existing `sfc` geometry column
#'   in `sf_object` to set as the active geometry. Must be a single, non-empty
#'   character string.
#' @name set_geometry
#' @return The modified `sf` object with the active geometry column set to
#'   `geometry_column`.
#' @author Ahmed El-Gabbas
#' @export
#' @note The `geometry_column` must be an existing `sfc` column in `sf_object`.
#'   Use with caution to avoid overwriting the active geometry unintentionally.
#' @examples
#' load_packages(sf, dplyr, ggplot2)
#'
#' # example data with multiple geometry columns
#' nc <- sf::st_read(
#'   dsn = system.file("shape/nc.shp", package = "sf"), quiet = TRUE) %>%
#'   dplyr::select(AREA)
#' # add a new geometry column
#' nc$centroid <- sf::st_centroid(st_geometry(nc))
#' nc
#'
#' # set centroid as active geometry in a pipeline
#' nc_modified <- set_geometry(nc, "centroid")
#' nc_modified
#'
#' attr(nc, "sf_column")
#' attr(nc_modified, "sf_column")
#'
#' ggplot2::ggplot() +
#'   ggplot2::geom_sf(data = nc, aes(fill = NULL)) +
#'   ggplot2::geom_sf(data = nc_modified, colour = "red") +
#'   ggplot2::theme_minimal()

set_geometry <- function(sf_object = NULL, geometry_column = NULL) {

  # Validate sf_object
  if (is.null(sf_object)) {
    ecokit::stop_ctx("`sf_object` cannot be NULL", sf_object = sf_object)
  }
  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "`sf_object` must be an `sf` object", class_sf_object = class(sf_object))
  }

  # Validate geometry_column
  if (is.null(geometry_column)) {
    ecokit::stop_ctx(
      "`geometry_column` cannot be NULL or missing",
      geometry_column = geometry_column)
  }
  if (!is.character(geometry_column) || length(geometry_column) != 1L ||
      !nzchar(geometry_column)) {
    ecokit::stop_ctx(
      "`geometry_column` must be a single non-empty character string",
      geometry_column = geometry_column)
  }

  # Check if geometry_column exists
  if (!geometry_column %in% names(sf_object)) {
    ecokit::stop_ctx(
      "`geometry_column` must be an existing column in `sf_object`",
      geometry_column = geometry_column, columns = names(sf_object))
  }

  # Check if geometry_column is an sfc column
  if (!inherits(sf_object[[geometry_column]], "sfc")) {
    ecokit::stop_ctx(
      "`geometry_column` must be an `sfc` geometry column",
      column_class = class(sf_object[[geometry_column]]))
  }

  # Warn if setting to current geometry column
  current_geom <- attr(sf_object, "sf_column")
  if (geometry_column == current_geom) {
    warning(
      "`geometry_column` is already the active geometry column", call. = FALSE)
  }

  # Set geometry column
  sf::st_geometry(sf_object) <- geometry_column

  return(sf_object)
}
