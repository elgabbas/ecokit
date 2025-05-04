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
#' @param x A numeric `vector`, `data.frame`, `RasterLayer`, or `SpatRaster`
#'   object whose values are to be modified.
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
#' library(raster)
#' library(terra)
#' par(mar = c(0.5, 0.5, 1, 2.5), oma = c(0.5, 0.5, 0.5, 1))
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
#' # greater_than is ignored as between is specified
#' range_to_new_value(
#'    x = VV, between = c(5, 8), new_value = NA, greater_than = 4)
#'
#' range_to_new_value(x = VV, new_value = NA, greater_than = 4)
#'
#' range_to_new_value(x = VV, new_value = NA, less_than = 4)
#'
#' # ---------------------------------------------
#'
#' # tibble
#'
#' iris2 <- iris %>%
#'   tibble::as_tibble() %>%
#'   dplyr::slice_head(n = 50) %>%
#'   dplyr::select(-Sepal.Length, -Petal.Length, -Petal.Width) %>%
#'   dplyr::arrange(-Sepal.Width)
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
#' # RasterLayer / SpatRaster
#'
#' grd_file <- system.file("external/test.grd", package = "raster")
#' R_raster <- raster::raster(grd_file)
#' R_terra <- terra::rast(grd_file)
#'
#' # Convert values less than 500 to NA
#' R_raster2 <- range_to_new_value(
#' x = R_raster, less_than = 500, new_value = NA)
#' plot(
#'    raster::stack(R_raster, R_raster2), nr = 1,
#'    main = c("\nOriginal", "\n<500 to NA"),
#'    box = FALSE, axes = FALSE, legend.width = 2, colNA = "lightgrey",
#'    xaxs = "i", yaxs = "i")
#'
#' R_terra2 <- range_to_new_value(x = R_terra, less_than = 500, new_value = NA)
#' plot(
#'    c(R_terra, R_terra2), nr = 1, main = c("\nOriginal", "\n<500 to NA"),
#'    box = FALSE, axes = FALSE, colNA = "lightgrey", xaxs = "i", yaxs = "i")
#'
#'
#' # Convert values greater than 700 to NA
#' R_raster2 <- range_to_new_value(
#'    x = R_raster, greater_than = 700, new_value = NA)
#' plot(
#'    raster::stack(R_raster, R_raster2), nr = 1,
#'    main = c("\nOriginal", "\n>700 to NA"),
#'    box = FALSE, axes = FALSE, legend.width = 2, colNA = "lightgrey",
#'    xaxs = "i", yaxs = "i")
#'
#' R_terra2 <- range_to_new_value(
#'     x = R_terra, greater_than = 700, new_value = NA)
#' plot(
#'    c(R_terra, R_terra2), nr = 1, main = c("\nOriginal", "\n>700 to NA"),
#'    box = FALSE, axes = FALSE, colNA = "lightgrey", xaxs = "i", yaxs = "i")

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

  if (!is.null(between)) {

    if (length(between) != 2) {
      ecokit::stop_ctx(
        "`between` should have exactly two values: a minimum and a maximum.",
        between = between, length_between = length(between))
    }

    min_value <- between[1]
    max_value <- between[2]

    if (max_value <= min_value) {
      ecokit::stop_ctx(
        "max_value must be greater than min_value.",
        max_value = max_value, min_value = min_value)
    }

    if (inherits(x, "RasterLayer")) {
      x_1 <- x_2 <- x
      x_1[x_1 >= max_value] <- NA
      x_1[!is.na(x_1)] <- 1
      x_2[x_2 <= min_value] <- NA
      x_2[!is.na(x_2)] <- 1
      x_3 <- sum(x_1, x_2, na.rm = TRUE)

      if (invert) {
        x[x_3 == 1] <- new_value
      } else {
        x[x_3 == 2] <- new_value
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
