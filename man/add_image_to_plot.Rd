% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_add_image_to_plot.R
\name{add_image_to_plot}
\alias{add_image_to_plot}
\title{Add an image to an existing plot in R}
\source{
The source code of this function was taken from this
\href{https://stackoverflow.com/questions/27800307/}{stackoverflow} question.
}
\usage{
add_image_to_plot(image_object, x, y, width, interpolate = TRUE)
}
\arguments{
\item{image_object}{The image object to be added to the plot, expected to be
an array-like structure (e.g., as read by \link[png:readPNG]{png::readPNG} or
\link[jpeg:readJPEG]{jpeg::readJPEG}).}

\item{x, y}{Numeric, the x-coordinate or y-coordinate (in plot units) at which
the centre of the image should be placed.}

\item{width}{Numeric, the desired width of the image in plot units (not
pixels or inches). The function will calculate the corresponding height to
preserve the image's aspect ratio.}

\item{interpolate}{Logical, whether to apply linear interpolation to the
image when drawing. Defaults to \code{TRUE}. Passed directly to
\link[graphics:rasterImage]{graphics::rasterImage}. Interpolation can improve image quality but may
take longer to render.}
}
\value{
This function does not return a value but modifies the current plot
by adding an image.
}
\description{
This function allows the user to add an image to an existing plot in R by
specifying the image object, its position, and its size. The function
calculates the necessary dimensions and places the image accordingly. The
function uses the existing plot's coordinate system and accounts for the
current plot dimensions to ensure accurate placement of the image. It also
allows for interpolation, which can improve the visual quality of the image.
}
\note{
The function will stop with an error message if any of the required
arguments (\code{image_object}, \code{x}, \code{y}, \code{width}) are \code{NULL}.
}
\examples{
load_packages(png)

URL <- paste0("https://upload.wikimedia.org/wikipedia/commons/",
    "e/e1/Jupiter_\%28transparent\%29.png")
z <- tempfile()
utils::download.file(URL, z, mode = "wb", quiet = TRUE)
pic <- png::readPNG(z)
file.remove(z) # cleanup

image(volcano)
add_image_to_plot(pic, x = 0.3, y = 0.5, width = 0.2)
add_image_to_plot(pic, x = 0.7, y = 0.7, width = 0.2)
add_image_to_plot(pic, x = 0.7, y = 0.2, width = 0.1)

# clean up
unlink(z)
}
