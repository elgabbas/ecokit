## |------------------------------------------------------------------------| #
# set_raster_varnames ----
## |------------------------------------------------------------------------| #

#' Set the variable name of a SpatRaster within a pipe
#'
#' A small wrapper function that assigns a single variable name `varnames` to a
#' `SpatRaster` and returns the object, making it suitable for use in a
#' `magrittr` pipe without breaking the chain.
#'
#' @param rast `[SpatRaster]` A `SpatRaster` object whose variable name is to be
#'   set. Must not be `NULL`.
#' @param var_name `[character(1)]` or `NULL`. A single non-empty string to
#'   assign as the variable name. If `NULL`, the variable name is reset to `""`
#'   (terra's default empty state).
#'
#' @return The input `SpatRaster` with an updated `varnames` slot.
#' @section `names` vs `varnames`: `terra` stores two distinct name slots:
#' - **`names`** (per-layer) – used in plots, `as.data.frame()`, and
#'   subsetting. Set via `names(x) <- ...` or [terra::set.names()].
#' - **`varnames`** (per-data-source) – a single string inherited from the
#'   source file variable name (e.g. NetCDF). For any in-memory or derived
#'   `SpatRaster` there is always exactly one data source regardless of the
#'   number of layers, so `varnames` only ever holds **one** value.
#'
#' @author Ahmed El-Gabbas
#' @export
#'
#' @examples
#' library(terra)
#'
#' r <- terra::rast(
#'   ncols = 10, nrows = 10, nlyr = 3, vals = 1L, names = c("l1", "l2", "l3"))
#'
#' # setting variable names directly with terra
#' terra::varnames(r) <- "v1"
#' r
#'
#' # Set variable name within a pipe
#' (r2 <- set_raster_varnames(r, "temperature"))
#'
#' # Reset variable name to empty
#' (r3 <- set_raster_varnames(r, NULL))

set_raster_varnames <- function(rast, var_name) {

  if (is.null(rast)) {
    ecokit::stop_ctx("Input raster cannot be NULL")
  }

  if (!inherits(rast, "SpatRaster")) {
    ecokit::stop_ctx("Input must be a SpatRaster", class_rast = class(rast))
  }

  if (is.null(var_name)) {
    terra::varnames(rast) <- ""
    return(invisible(rast))
  }

  if (!is.character(var_name) || length(var_name) != 1L || !nzchar(var_name)) {
    ecokit::stop_ctx(
      "var_name must be a single non-empty string or NULL",
      var_name = var_name, class_var_name = class(var_name))
  }

  terra::varnames(rast) <- var_name
  return(rast)
}
