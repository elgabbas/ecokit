## |------------------------------------------------------------------------| #
# sf_add_coords ------
## |------------------------------------------------------------------------| #

#' Add longitude and latitude coordinates to an sf object
#'
#' Add longitude and latitude coordinates as new columns to an sf object
#' (`sf_object`). It extracts the coordinates from the sf object, converts them
#' into a tibble, and appends them to the original sf object as new columns. If
#' `name_x` or `name_y`, provided as arguments respectively, already exist in
#' the sf object, the function either  1) overwrites these columns if
#' `overwrite` is set to `TRUE` or 2) appends a suffix to the new column names
#' to avoid overwrite if `overwrite` is set to `FALSE`.
#' @name sf_add_coords
#' @param sf_object An `sf` object to which longitude and latitude columns will
#'   be added.
#' @param name_x,name_y Character. Name of the longitude column to be added.
#'   Defaults to `Long` and `Lat`.
#' @param overwrite Logical. Whether to overwrite existing columns with names
#'   specified by `name_x` and `name_y`. If `FALSE` and columns with these names
#'   exist, new columns are appended with a suffix. Defaults to `FALSE`.
#' @param suffix Character. Suffix to be appended to the new column names in
#'   cases of conflict and `overwrite` is `FALSE`. Defaults to `_NEW`.
#' @return An sf object with added longitude and latitude columns.
#' @author Ahmed El-Gabbas
#' @export
#' @note If the overwrite parameter is `FALSE` (default) and columns with the
#'   specified names already exist, the function will issue a warning and append
#'   suffix to the names of the new columns to avoid overwriting.
#' @examples
#' load_packages(sf)
#'
#' # Example sf object
#' pt1 = sf::st_point(c(0, 1))
#' pt2 = sf::st_point(c(1, 1))
#' d = data.frame(a = c(1, 2))
#' d$geom = sf::st_sfc(pt1, pt2)
#' (df = sf::st_as_sf(d))
#'
#' # |||||||||||||||||||||||||||||||||||||||||||
#'
#' # add coordinates to the sf object and overwrite existing object
#' (df <- sf_add_coords(df))
#'
#' # add coordinates again
#' sf_add_coords(df)
#'
#' # add coordinates again, using custom suffix
#' sf_add_coords(df, suffix = "new")
#'
#' # |||||||||||||||||||||||||||||||||||||||||||
#'
#' # jitter the coordinates a little
#' set.seed(100)
#' (df2 <- sf::st_jitter(df, amount = 0.1))
#'
#' sf_add_coords(df2, overwrite = FALSE)
#'
#' sf_add_coords(df2, overwrite = TRUE)

sf_add_coords <- function(
    sf_object, name_x = "Long", name_y = "Lat", overwrite = FALSE,
    suffix = "_NEW") {

  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "`sf_object` must be an sf object",
      sf_object = sf_object, class_sf_object = class(sf_object))
  }

  if (!is.character(name_x) || !is.character(name_y) || !is.character(suffix) ||
      !nzchar(name_x) || !nzchar(name_y) || !nzchar(suffix)) {
    ecokit::stop_ctx(
      "`name_x` and `name_y` must be non-empty strings",
      name_x = name_x, name_y = name_y)
  }

  column_names <- names(sf_object)

  # Ensure suffix starts with a single underscore
  suffix <- ifelse(startsWith(suffix, "_"), suffix, paste0("_", suffix)) %>%
    stringr::str_replace_all("__+", "_")

  # Coordinate Extraction
  # extract the coordinates from the sf object and converts them into a tibble,
  # naming the columns according to name_x and name_y
  coordinates <- sf::st_coordinates(sf_object) %>%
    tibble::as_tibble() %>%
    stats::setNames(c(name_x, name_y))

  # Column Name Check
  # Before adding the new columns, check if columns with the
  # names name_x and name_y already exist. If they do, it either 1) Overwrites
  # these columns if overwrite is TRUE, after issuing a warning. 2) Appends
  # suffix to the new column names to avoid overwriting, if overwrite is FALSE.

  if (any(c(name_x, name_y) %in% column_names)) {
    if (overwrite) {
      warning(
        "long/lat column names already exist in the data: overwritten",
        call. = FALSE)
      sf_object <- dplyr::select(sf_object, -dplyr::all_of(c(name_x, name_y)))
    } else {
      warning(
        "long/lat column names already exist in the data: ",
        suffix, " is used as suffix",
        call. = FALSE)
      coordinates <- coordinates %>%
        stats::setNames(c(paste0(name_x, suffix), paste0(name_y, suffix)))
    }
  } else {
    coordinates <- stats::setNames(coordinates, c(name_x, name_y))
  }
  return(dplyr::bind_cols(sf_object, coordinates))
}
