## |------------------------------------------------------------------------| #
# rename_geometry ----
## |------------------------------------------------------------------------| #

#' Rename active geometry column of an `sf` object.
#'
#' This function renames the active geometry column of a simple feature (`sf`)
#' object to a new name provided by the user.
#' @param sf_object `sf` object; the simple feature object whose geometry column
#'   name is to be changed.
#' @param new_name `character`; the new name for the geometry column.
#' @name rename_geometry
#' @return The modified `sf` object with the renamed geometry column.
#' @references [Click here](https://gis.stackexchange.com/a/386589/30390)
#' @export

rename_geometry <- function(sf_object = NULL, new_name = NULL) {

  if (any(is.null(sf_object) | is.null(new_name))) {
    ecokit::stop_ctx(
      "The input sf object or new_name cannot be 'NULL'.",
      sf_object = sf_object, new_name = new_name)
  }

  current <- attr(sf_object, "sf_column")
  names(sf_object)[names(sf_object) == current] <- new_name
  sf::st_geometry(sf_object) <- new_name
  return(sf_object)
}
