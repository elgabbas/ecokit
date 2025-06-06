% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spat_scale_0_1.R
\name{scale_0_1}
\alias{scale_0_1}
\title{Scale a raster object’s values to a range between 0 and 1}
\usage{
scale_0_1(raster)
}
\arguments{
\item{raster}{A \code{SpatRaster}, \code{RasterLayer}, \code{RasterStack}, \code{RasterBrick}
object, or a character string specifying the path to a raster file that can
be loaded with \code{terra::rast()} (e.g., GeoTIFF, NetCDF).}
}
\value{
A \code{SpatRaster} object with all values scaled between 0 and 1.
}
\description{
Scales the values of a \code{SpatRaster} (from the \code{terra} package), \verb{Raster*}
(from the \code{raster} package), or a raster file loaded via \code{terra::rast()} to a
range between 0 and 1.
}
\note{
This function accepts a \code{SpatRaster}, \verb{Raster*} object, or a file path.
\verb{Raster*} objects are coerced to \code{SpatRaster} using \code{terra::rast()}, and
file paths are loaded as \code{SpatRaster}. It calculates the minimum and
maximum values and scales all values between 0 and 1.
}
\examples{
ecokit::load_packages(terra, raster, fs, ggplot2, tidyterra)

# Setup temporary directory
temp_dir <- fs::path_temp("scale_0_1")
fs::dir_create(temp_dir)

# Example with SpatRaster
r <- terra::rast(ncols = 10, nrows = 10)
terra::values(r) <- rnorm(terra::ncell(r))
r_scaled <- scale_0_1(r)
c(r, r_scaled)

# Example with RasterLayer
r_raster <- raster::raster(ncol = 10, nrow = 10)
raster::values(r_raster) <- rnorm(raster::ncell(r_raster))
r_raster_scaled <- scale_0_1(r_raster)
c(r_raster, r_raster_scaled)

# Example with file path
r_file <- fs::path(temp_dir, "raster.tif")
terra::writeRaster(r, r_file, overwrite = TRUE)
r_file_scaled <- scale_0_1(r_file)
c(terra::rast(r_file), r_file_scaled)

# Visualize results
ggplot2::ggplot() +
  tidyterra::geom_spatraster(data = r, maxcell = Inf) +
  ggplot2::theme_minimal()

ggplot2::ggplot() +
  tidyterra::geom_spatraster(data = r_scaled, maxcell = Inf) +
  ggplot2::theme_minimal()

# clean up
fs::dir_delete(temp_dir)
}
\author{
Ahmed El-Gabbas
}
