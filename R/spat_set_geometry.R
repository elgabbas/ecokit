## |------------------------------------------------------------------------| #
# set_geometry ----
## |------------------------------------------------------------------------| #

#' Set the geometry column of a simple feature (sf) data frame in the pipe
#' pipeline.
#'
#' Set the geometry column of a simple feature (sf) data frame, making it
#' particularly useful in data processing pipelines. By specifying the name of
#' the geometry column, users can ensure that spatial operations utilise the
#' correct data.
#' @param sf_object simple feature (sf) data frame. This is the data frame whose
#'   geometry column will be set or changed.
#' @param geometry_column Character. Name of the geometry column to be used or
#'   set in the `sf_object` data frame.
#' @name set_geometry
#' @return The modified simple feature (sf) data frame with the updated geometry
#'   column. The function returns the original data frame `sf_object` with its
#'   geometry column set to `Name`.
#' @author Ahmed El-Gabbas
#' @export

set_geometry <- function(sf_object, geometry_column) {
  sf::st_geometry(sf_object) <- geometry_column
  return(sf_object)
}
