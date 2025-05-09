#' Add Geometric Features to Spatial Grid Cells
#'
#' Creates `multilinestring` sf objects representing geometric features (crosses
#' or diagonals) within the centre of each grid cell in an input spatial grid.
#'
#' @details The following functions are included:
#' - `add_cross_to_grid`: Creates a `multilinestring` sf object with crosses
#'   (horizontal and vertical lines) in the centre of each grid cell.
#' - `add_diagonals_to_grid`: Creates a `multilinestring` sf object with
#'   diagonal and off-diagonal lines for each grid cell.
#'
#' @param sf_object An `sf` object (tibble) with polygon geometries representing
#'   grid cells. If `NULL`, the function stops with an error.
#' @return
#' - `add_cross_to_grid`: An `sf` object with `multilinestring` geometries
#' representing crosses in the centre of each grid cell, retaining the input
#' CRS.
#' - `add_diagonals_to_grid`: An `sf` object with `multilinestring` geometries
#' representing diagonal and off-diagonal lines for each grid cell, retaining
#' the input CRS.
#'
#' @author Ahmed El-Gabbas
#' @note The functions require the `sf`, `dplyr`, `purrr`, `tibble`, and `tidyr`
#'   packages to be installed and loaded.
#' @examples
#' # loading packages
#' ecokit::load_packages(dplyr, sf, ggplot2)
#'
#' # ---------------------------------------------
#' # Create a 5x5 grid
#' # ---------------------------------------------
#'
#' grid_original <- sf::st_make_grid(
#'     sf::st_bbox(c(xmin = 0, ymin = 0, xmax = 10, ymax = 10), crs = 4326),
#'     n = c(5, 5)) %>%
#'   sf::st_sf(geometry = .)
#'
#' # ---------------------------------------------
#' # Add crosses to grid
#' # ---------------------------------------------
#'
#' grid_cross <- add_cross_to_grid(grid_original)
#' ggplot2::ggplot() +
#'   ggplot2::geom_sf(
#'     data = grid_original, mapping = ggplot2::aes(), color = "black",
#'     linewidth = 0.75, fill = "transparent") +
#'   ggplot2::geom_sf(
#'     data = grid_cross, mapping = ggplot2::aes(), color = "red",
#'     linewidth = 0.75, inherit.aes = TRUE, linetype = 3) +
#'   ggplot2::scale_x_continuous(expand = c(0, 0, 0, 0), limits = c(0, 10)) +
#'   ggplot2::scale_y_continuous(expand = c(0, 0, 0, 0), limits = c(0, 10)) +
#'   ggplot2::theme_minimal()
#'
#' # ---------------------------------------------
#' # Add diagonals to grid
#' # ---------------------------------------------
#'
#' grid_diagonals <- add_diagonals_to_grid(grid_original)
#' ggplot2::ggplot() +
#'   ggplot2::geom_sf(
#'     data = grid_original, mapping = ggplot2::aes(), color = "black",
#'     linewidth = 0.75, fill = "transparent") +
#'   ggplot2::geom_sf(
#'     data = grid_diagonals, mapping = ggplot2::aes(), color = "red",
#'     linewidth = 0.75, inherit.aes = TRUE, linetype = 3) +
#'   ggplot2::scale_x_continuous(expand = c(0, 0, 0, 0), limits = c(0, 10)) +
#'   ggplot2::scale_y_continuous(expand = c(0, 0, 0, 0), limits = c(0, 10)) +
#'   ggplot2::theme_minimal()


## |------------------------------------------------------------------------| #
# add_cross_to_grid ------
## |------------------------------------------------------------------------| #

#' @export
#' @rdname add_geometric_features
#' @name add_geometric_features
#' @order 1

add_cross_to_grid <- function(sf_object = NULL) {

  id <- NULL

  if (is.null(sf_object)) {
    ecokit::stop_ctx(
      "Input sf_object cannot be NULL",
      sf_object = sf_object, class_sf_object = class(sf_object))
  }

  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "Input sf_object must be of class sf",
      sf_object = sf_object, class_sf_object = class(sf_object))
  }

  sf_object <- sf_object %>%
    dplyr::mutate(id = dplyr::row_number()) %>%
    dplyr::group_by(id) %>%
    dplyr::group_map(
      .f = ~{
        geom <- .x$geometry
        bbox <- sf::st_bbox(geom)
        xmid <- (bbox["xmin"] + bbox["xmax"]) / 2L
        ymid <- (bbox["ymin"] + bbox["ymax"]) / 2L

        horizontal <- matrix(
          c(bbox["xmin"], ymid, bbox["xmax"], ymid),
          nrow = 2L, byrow = TRUE) %>%
          sf::st_linestring()

        vertical <- matrix(
          c(xmid, bbox["ymin"], xmid, bbox["ymax"]),
          nrow = 2L, byrow = TRUE) %>%
          sf::st_linestring()

        output <- list(horizontal, vertical) %>%
          sf::st_multilinestring() %>%
          sf::st_sfc(crs = sf::st_crs(sf_object)) %>%
          sf::st_intersection(geom) %>%
          sf::st_geometry()

        return(tibble::tibble(geometry = output))
      }) %>%
    dplyr::bind_rows() %>%
    sf::st_as_sf()

  return(sf_object)
}

## |------------------------------------------------------------------------| #
# add_diagonals_to_grid ------
## |------------------------------------------------------------------------| #

#' @export
#' @rdname add_geometric_features
#' @name add_geometric_features
#' @order 2

add_diagonals_to_grid <- function(sf_object = NULL) {

  id <- NULL

  if (is.null(sf_object)) {
    ecokit::stop_ctx(
      "Input sf_object  cannot be NULL",
      sf_object = sf_object, class_sf_object = class(sf_object))
  }

  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "Input sf_object must be of class sf",
      sf_object = sf_object, class_sf_object = class(sf_object))
  }

  sf_object <- sf_object %>%
    dplyr::mutate(id = dplyr::row_number()) %>%
    dplyr::group_by(id) %>%
    dplyr::group_map(
      .f = ~{
        geom <- .x$geometry
        bbox <- sf::st_bbox(geom)

        off_diag <- matrix(
          c(bbox["xmin"], bbox["ymax"], bbox["xmax"], bbox["ymin"]),
          nrow = 2L, byrow = TRUE) %>%
          sf::st_linestring()

        diag <- matrix(
          c(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"]),
          nrow = 2L, byrow = TRUE) %>%
          sf::st_linestring()

        output <- list(off_diag, diag) %>%
          sf::st_multilinestring() %>%
          sf::st_sfc(crs = sf::st_crs(sf_object)) %>%
          sf::st_intersection(geom) %>%
          sf::st_geometry()

        return(tibble::tibble(geometry = output))
      }) %>%
    dplyr::bind_rows() %>%
    sf::st_as_sf()

  return(sf_object)

}
