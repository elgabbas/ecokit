## |------------------------------------------------------------------------| #
# add_image_to_plot ----
## |------------------------------------------------------------------------| #

#' Add an image to an existing plot in R
#'
#' This function allows the user to add an image to an existing plot in R by
#' specifying the image object, its position, and its size. The function
#' calculates the necessary dimensions and places the image accordingly. The
#' function uses the existing plot's coordinate system and accounts for the
#' current plot dimensions to ensure accurate placement of the image. It also
#' allows for interpolation, which can improve the visual quality of the image.
#' @name add_image_to_plot
#' @source The source code of this function was taken from this
#'   [stackoverflow](https://stackoverflow.com/questions/27800307/) question.
#' @export
#' @param image_object The image object to be added to the plot, expected to be
#'   an array-like structure (e.g., as read by [png::readPNG] or
#'   [jpeg::readJPEG]).
#' @param x,y Numeric, the x-coordinate or y-coordinate (in plot units) at which
#'   the centre of the image should be placed.
#' @param width Numeric, the desired width of the image in plot units (not
#'   pixels or inches). The function will calculate the corresponding height to
#'   preserve the image's aspect ratio.
#' @param interpolate Logical, whether to apply linear interpolation to the
#'   image when drawing. Defaults to `TRUE`. Passed directly to
#'   [graphics::rasterImage]. Interpolation can improve image quality but may
#'   take longer to render.
#' @return This function does not return a value but modifies the current plot
#'   by adding an image.
#' @note The function will stop with an error message if any of the required
#'   arguments (`image_object`, `x`, `y`, `width`) are `NULL`.
#' @examples
#' library(png)
#' URL <- paste0("https://upload.wikimedia.org/wikipedia/commons/",
#'     "e/e1/Jupiter_%28transparent%29.png")
#' z <- tempfile()
#' utils::download.file(URL, z, mode = "wb", quiet = TRUE)
#' pic <- png::readPNG(z)
#' file.remove(z) # cleanup
#'
#' image(volcano)
#' add_image_to_plot(pic, x = 0.3, y = 0.5, width = 0.2)
#' add_image_to_plot(pic, x = 0.7, y = 0.7, width = 0.2)
#' add_image_to_plot(pic, x = 0.7, y = 0.2, width = 0.1)

add_image_to_plot <- function(image_object, x, y, width, interpolate = TRUE) {

  if (is.null(image_object) || is.null(x) || is.null(y) || is.null(width)) {
    ecokit::stop_ctx(
      "Must provide args `image_object`, `x`, `y`, and `width`",
      image_object = image_object, x = x, y = y, width = width)
  }

  # A vector of the form c(x1, x2, y1, y2) giving the extremes of the user
  # coordinates of the plotting region
  par_user <- graphics::par()$usr

  # The current plot dimensions (width, height), in inches
  plot_dimensions <- graphics::par()$pin

  # number of x-y pixels for the image_object
  image_dimension <- dim(image_object)

  # pixel aspect ratio (y/x)
  aspect_ratio <- image_dimension[1L] / image_dimension[2L]

  # convert width units to inches
  width_inches <- width / (par_user[2L] - par_user[1L]) * plot_dimensions[1L]

  # height in inches
  height_in_inches <- width_inches * aspect_ratio

  # height in units
  height_in_units <- height_in_inches / plot_dimensions[2L] *
    (par_user[4L] - par_user[3L])

  graphics::rasterImage(
    image = image_object, xleft = x - (width / 2L), xright = x + (width / 2L),
    ybottom = y - (height_in_units / 2L), ytop = y + (height_in_units / 2L),
    interpolate = interpolate)
}
