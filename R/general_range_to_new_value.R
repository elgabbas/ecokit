## |------------------------------------------------------------------------| #
# range_to_new_value ----
## |------------------------------------------------------------------------| #

#' Changes values within a specified range, or greater than or less than a
#' specific value to a new value in a vector, data.frame, or raster
#'
#' This function modifies values in the input object `x` based on the specified
#' conditions. It can operate on vectors, data.frames, or RasterLayer objects.
#' The function allows for changing values within a specified range (`between`),
#' greater than or equals to (`greater_than`) or  less than or equals to
#' (`less_than`) a specified value to a new value (`new_value`). An option to
#' invert the selection is also available for ranges.
#' @name range_to_new_value
#' @author Ahmed El-Gabbas
#' @param x A numeric `vector`, `data.frame`, `RasterLayer`, `SpatRaster`, or
#'   `PackedSpatRaster` object whose values are to be modified.
#' @param between Numeric. A numeric vector of length 2 specifying the range of
#'   values to be changed or kept. If specified, `greater_than` and `less_than`
#'   are ignored.
#' @param greater_than,less_than Numeric. Threshold larger than or equal to/less
#'   than or equal to which values in `x` will be changed to `new_value`. Only
#'   applied if `between` is not specified.
#' @param new_value The new value to assign to the selected elements in `x`.
#' @param invert Logical. Whether to invert the selection specified by
#'   `between`. If `TRUE`, values outside the specified range are changed to
#'   `new_value`. Default is `FALSE`.
#' @return The modified object `x` with values changed according to the
#'   specified conditions.
#' @export
#' @examples
#' ecokit::load_packages(dplyr, raster, terra, tibble, ggplot2, tidyr)
#'
#' # ---------------------------------------------
#'
#' # Vector
#'
#' (VV <- seq_len(10))
#'
#' range_to_new_value(x = VV, between = c(5, 8), new_value = NA)
#'
#' range_to_new_value(x = VV, between = c(5, 8), new_value = NA, invert = TRUE)
#'
#' # greater_than is ignored as `between` is specified
#' range_to_new_value(
#'    x = VV, between = c(5, 8), new_value = NA, greater_than = 4)
#' range_to_new_value(x = VV, new_value = NA, greater_than = 4)
#'
#' range_to_new_value(x = VV, new_value = NA, less_than = 4)
#'
#' # `invert` argument works only when `between` is specified
#' range_to_new_value(x = VV, new_value = NA, greater_than = 4, invert = TRUE)
#'
#' # ---------------------------------------------
#'
#' # tibble
#'
#' iris2 <- iris %>%
#'   tibble::as_tibble() %>%
#'   dplyr::slice_head(n = 50) %>%
#'   dplyr::select(-Sepal.Length, -Petal.Length, -Petal.Width) %>%
#'   dplyr::arrange(Sepal.Width)
#'
#' iris2 %>%
#'  dplyr::mutate(
#'    Sepal.Width.New = range_to_new_value(
#'       x = Sepal.Width, between = c(3, 3.5),
#'       new_value = NA, invert = FALSE),
#'    Sepal.Width.Rev = range_to_new_value(
#'       x = Sepal.Width, between = c(3, 3.5),
#'       new_value = NA, invert = TRUE)) %>%
#'  print(n = 50)
#'
#' # ---------------------------------------------
#'
#' # RasterLayer
#'
#' grd_file <- system.file("external/test.grd", package = "raster")
#' R_raster <- raster::raster(grd_file)
#'
#' # set the theme for ggplot2
#' ggplot2::theme_set(
#'   ggplot2::theme_minimal() +
#'   ggplot2::theme(
#'     legend.position = "right",
#'     strip.text = ggplot2::element_text(size = 16),
#'     legend.title = ggplot2::element_blank(),
#'     axis.title = ggplot2::element_blank(),
#'     axis.text = ggplot2::element_blank()))
#'
#' # Convert values less than 500 to NA
#' R_raster2 <- range_to_new_value(
#'   x = R_raster, less_than = 500, new_value = NA)
#' # Convert values greater than 600 to NA
#' R_raster3 <- range_to_new_value(
#'    x = R_raster, greater_than = 600, new_value = NA)
#' (R_rasters <- raster::stack(R_raster, R_raster2, R_raster3))
#'
#'
#' as.data.frame(R_rasters, xy = TRUE, na.rm = FALSE) %>%
#'   stats::setNames(c("x", "y", "R_raster", "R_raster2", "R_raster3")) %>%
#'   tidyr::pivot_longer(
#'     cols = -c("x", "y"), names_to = "layer", values_to = "value") %>%
#'   ggplot2::ggplot() +
#'   ggplot2::geom_tile(mapping = ggplot2::aes(x = x, y = y, fill = value)) +
#'   ggplot2::facet_grid(~layer) +
#'   ggplot2::scale_fill_gradientn(
#'     colours = c("blue", "green", "yellow", "red"),
#'     na.value = "transparent") +
#'   ggplot2::labs(title = NULL, x = NULL, y = NULL) +
#'   ggplot2::coord_cartesian(expand = FALSE, clip = "off")
#'
#' # ---------------------------------------------
#'
#' # SpatRaster
#'
#' R_terra <- terra::rast(grd_file)
#' R_terra2 <- range_to_new_value(x = R_terra, less_than = 500, new_value = NA)
#' R_terra3 <- range_to_new_value(
#'     x = R_terra, greater_than = 600, new_value = NA)
#' (R_terras <- c(R_terra, R_terra2, R_terra3))
#'
#' as.data.frame(R_terras, xy = TRUE, na.rm = FALSE) %>%
#'   stats::setNames(c("x", "y", "R_terra", "R_terra2", "R_terra3")) %>%
#'   tidyr::pivot_longer(
#'     cols = -c("x", "y"), names_to = "layer", values_to = "value") %>%
#'   ggplot2::ggplot() +
#'   ggplot2::geom_tile(mapping = ggplot2::aes(x = x, y = y, fill = value)) +
#'   ggplot2::facet_grid(~layer) +
#'   ggplot2::scale_fill_gradientn(
#'     colours = c("blue", "green", "yellow", "red"),
#'     na.value = "transparent") +
#'   ggplot2::labs(title = NULL, x = NULL, y = NULL) +
#'   ggplot2::coord_cartesian(expand = FALSE, clip = "off")

range_to_new_value <- function(
    x = NULL, between = NULL, greater_than = NULL, less_than = NULL,
    new_value = NULL, invert = FALSE) {

  if (is.null(x) || is.null(new_value)) {
    ecokit::stop_ctx(
      "x and new_value cannot be NULL", x = x, new_value = new_value)
  }

  if (all(is.null(greater_than), is.null(less_than), is.null(between))) {
    ecokit::stop_ctx(
      paste0(
        "At least one of `greater_than`, `less_than`, and `between` ",
        "should be not NULL"),
      greater_than = greater_than, between = between, less_than = less_than)
  }

  if (inherits(x, "PackedSpatRaster")) {
    x <- terra::unwrap(x)
  }

  if (!is.null(between)) {

    if (length(between) != 2L) {
      ecokit::stop_ctx(
        "`between` should have exactly two values: a minimum and a maximum.",
        between = between, length_between = length(between))
    }

    min_value <- between[1L]
    max_value <- between[2L]

    if (max_value <= min_value) {
      ecokit::stop_ctx(
        "max_value must be greater than min_value.",
        max_value = max_value, min_value = min_value)
    }

    if (inherits(x, "RasterLayer")) {
      x_1 <- x_2 <- x
      x_1[x_1 >= max_value] <- NA
      x_1[!is.na(x_1)] <- 1L
      x_2[x_2 <= min_value] <- NA
      x_2[!is.na(x_2)] <- 1L
      x_3 <- sum(x_1, x_2, na.rm = TRUE)

      if (invert) {
        x[x_3 == 1L] <- new_value
      } else {
        x[x_3 == 2L] <- new_value
      }

    } else if (invert) {
      x[!(x >= min_value & x <= max_value)] <- new_value
    } else {
      x[x >= min_value & x <= max_value] <- new_value
    }

  } else {

    if (!is.null(greater_than)) {
      x[x >= greater_than] <- new_value
    }

    if (!is.null(less_than)) {
      x[x <= less_than] <- new_value
    }
  }
  return(x)
}
