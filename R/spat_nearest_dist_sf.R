## |------------------------------------------------------------------------| #
# nearest_dist_sf ----
## |------------------------------------------------------------------------| #

#' Calculate Nearest Neighbour Distances for Spatial Features
#'
#' This function calculates the nearest neighbour distance for each feature in
#' an sf object. It rasterizes the input data at a specified resolution,
#' converts to polygons, and then computes the distance to the nearest neighbour
#' for each feature.
#'
#' @param sf_object An sf object with CRS `EPSG:4326`. Must contain at least 2
#'   features.
#' @param resolution Numeric. The resolution for rasterization in degrees.
#'   Default is 0.25. Must be a single positive numeric value. The smaller the
#'   resolution, the more accurate the distance calculations, but also the more
#'   computationally intensive.
#' @param n_cores Integer. The number of cores to use for parallel processing.
#'   Default is `6L`.
#'
#' @return An sf object identical to the input `sf_object` with an additional
#'   column `nearest_dist` containing the distance (in kilometres) to the
#'   nearest neighbour for each feature.
#'
#' @details The function performs the following steps:
#'  - Validates that the input is an sf object with CRS `EPSG:4326` and
#'   contains at least 2 features
#'  - Rasterizes the input data at the specified resolution
#'  - Converts raster cells to polygons
#'  - Calculates centroids for faster distance computation
#'  - Computes the distance to the second nearest neighbour (the first is the
#'   feature itself)
#'  - Joins the calculated distances back to the original sf object
#'
#' @examples
#' # Create sample sf object
#' ecokit:::load_packages(sf, dismo, fs, dplyr, tibble, rworldmap)
#'
#' map <- rworldmap::getMap(resolution = "low") %>%
#'   sf::st_as_sf()
#'
#' occurrence <- system.file(package = "dismo") %>%
#'   fs::path("ex", "bradypus.csv") %>%
#'   read.table(header = TRUE, sep = ",") %>%
#'   tibble::tibble() %>%
#'   st_as_sf(crs = 4326L, coords = c("lon", "lat"))
#' head(occurrence)
#'
#' plot(occurrence["species"], key.pos = NULL, pch = 20, col = "blue")
#'
#' # Calculate nearest distances
#' result <- nearest_dist_sf(occurrence, resolution = 0.25, n_cores = 2)
#' head(result)
#'
#' plot(result["nearest_dist"], pch = 20)
#' plot(map$geometry, add = TRUE, border = "darkgrey")
#'
#' @author Ahmed El-Gabbas
#' @export

nearest_dist_sf <- function(sf_object, resolution = 0.25, n_cores = 6L) {

  geometry <- NULL

  # Check `sf_object` argument
  if (!inherits(sf_object, "sf")) {
    ecokit::stop_ctx(
      "The `sf_object` argument must be an sf object.",
      class_sf_object = class(sf_object), cat_timestamp = FALSE)
  }
  if (nrow(sf_object) < 2L) {
    ecokit::stop_ctx(
      "The `sf_object` argument must have > 2 features",
      cat_timestamp = FALSE)
  }
  epsg_val <- sf::st_crs(sf_object)$epsg
  if (is.null(epsg_val) || epsg_val != 4326L) {
    ecokit::stop_ctx(
      "The `sf_object` argument must have CRS EPSG:4326.",
      crs_sf_object = sf::st_crs(sf_object), cat_timestamp = FALSE)
  }
  if (sf::st_crs(sf_object)$epsg != 4326L) {
    ecokit::stop_ctx(
      "The `sf_object` argument must have CRS EPSG:4326.",
      crs_sf_object = sf::st_crs(sf_object), cat_timestamp = FALSE)
  }

  # resolution
  ecokit::check_args("resolution", "numeric")
  if (length(resolution) != 1L || resolution <= 0L) {
    ecokit::stop_ctx(
      "The `resolution` argument must be a single positive numeric value.",
      resolution = resolution, cat_timestamp = FALSE)
  }
  # n_cores
  ecokit::check_args("n_cores", "numeric")
  if (length(n_cores) != 1L || n_cores <= 0L) {
    ecokit::stop_ctx(
      "The `n_cores` argument must be a single positive numeric value.",
      n_cores = n_cores, cat_timestamp = FALSE)
  }

  if (!requireNamespace("nngeo", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `nngeo` package is required but not installed.",
      cat_timestamp = FALSE)
  }

  # Rasterize input data and convert to polygons
  data_r <- terra::rast(resolution = resolution) %>%
    terra::rasterize(x = sf_object, y = ., field = 1L) %>%
    terra::trim() %>%
    terra::as.polygons(aggregate = FALSE) %>%
    sf::st_as_sf() %>%
    # Add another geometry for centroids; nngeo::st_nn is faster for points
    dplyr::mutate(
      geometry_centroid = sf::st_centroid(geometry), last = NULL) %>%
    # set the active geometry to `geometry_centroid`
    ecokit::set_geometry("geometry_centroid")

  # Calculate nearest neighbour distances
  nearest_dist <- nngeo::st_nn(
    data_r, data_r, k = 2L, progress = FALSE, parallel = n_cores,
    returnDist = TRUE) %>%
    suppressMessages()

  # Combine nearest distances with original data
  result_sf <- tibble::tibble(
    data_r,
    nearest_dist = (do.call(rbind, nearest_dist$dist)[, 2L]) / 1000L) %>%
    sf::st_as_sf() %>%
    dplyr::select(-tidyselect::all_of("geometry_centroid")) %>%
    sf::st_join(x = sf_object, y = ., join = sf::st_nearest_feature)

  result_sf

}
