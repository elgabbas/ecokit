#' Sort raster layers by name using natural ordering
#'
#' Sorts the layers of a `terra::SpatRaster` according to their layer names
#' using natural (mixed) ordering. Numeric components of layer names are ordered
#' numerically rather than lexicographically (e.g. `"layer2"` is placed before
#' `"layer10"`).
#'
#' If duplicate layer names are detected, a warning is issued because the
#' resulting order of layers with identical names cannot be distinguished by
#' name alone. Layer order is preserved among duplicated names according to
#' their original positions.
#'
#' @param r A `terra::SpatRaster`.
#' @return A `terra::SpatRaster` with layers reordered according to natural
#'   sorting of layer names.
#' @author Ahmed El-Gabbas
#' @examples
#' ecokit::load_packages(terra, dplyr, dismo)
#'
#' fnames <- list.files(
#'   path = paste(system.file(package = "dismo"), "/ex", sep = ""),
#'   pattern = "grd", full.names = TRUE)
#' (r <- terra::rast(fnames))
#' names(r)
#'
#' (r2 <- sort_raster_layers(r))
#' names(r2)
#'
#' # ---------------------------------------------------
#'
#' r <- terra::rast(nrows = 10, ncols = 10, nlyrs = 4, vals = 1) %>%
#'    stats::setNames(c("layer10", "layer2", "layer10", "layer1"))
#' r
#'
#' sort_raster_layers(r)
#' @export

sort_raster_layers <- function(r) {

  if (!inherits(r, "SpatRaster")) {
    ecokit::stop_ctx("Input must be a SpatRaster object.", class_r = class(r))
  }

  if (terra::nlyr(r) <= 1L) {
    return(r)
  }

  layer_names <- names(r)
  duplicated_names <- unique(layer_names[duplicated(layer_names)])

  if (length(duplicated_names) > 0L) {
    warning(
      "Duplicated layer names detected: ", toString(shQuote(duplicated_names)),
      ". Layers will be sorted by name, but duplicated names ",
      "cannot be uniquely distinguished.", call. = FALSE)
  }

  idx <- gtools::mixedorder(layer_names)
  r[[idx]]
}
