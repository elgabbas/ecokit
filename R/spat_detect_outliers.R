#' Detect spatially isolated occupied raster cells
#'
#' Identify raster cells with value `1` whose nearest neighbouring occupied cell
#' is farther than a specified distance threshold.
#'
#' This function is designed for large spatial rasters and uses an efficient
#' nearest-neighbour search based on a kd-tree implementation (`RANN::nn2()`),
#' making it suitable for datasets containing thousands of occupied cells.
#'
#' Spatial outlier detection is particularly useful in species distribution
#' modelling (SDMs), biodiversity analyses, and ecological cleaning workflows,
#' where isolated records may represent:
#'
#' - georeferencing errors,
#' - accidental introductions,
#' - strong sampling artefacts,
#' - implausible dispersal events,
#' - or genuinely isolated populations requiring further inspection.
#'
#' Removing or reviewing extreme spatial outliers before model fitting can
#' substantially improve SDM realism, reduce extrapolation artefacts, and
#' prevent inflated environmental niche estimates.
#'
#' @param r A `terra::SpatRaster`. Cells with value `1` are treated as
#'   occupied/presence cells.
#' @param threshold Numeric. Minimum nearest-neighbour distance (in kilometers)
#'   required for a cell to be classified as a spatial outlier. For example:
#'   `threshold = 100` identifies occupied cells located more than 100 km from
#'   any other occupied cell.
#' @param plot_outliers Logical. If `TRUE` (default), plots the raster and
#'   highlights detected spatial outliers in red.
#'
#' @author Ahmed El-Gabbas
#'
#' @return A tibble with one row per detected outlier containing:
#'
#' - `cell`: Raster cell index.
#' - `x`: x coordinate of the cell center.
#' - `y`: y coordinate of the cell center.
#' - `dist_km`: Distance (km) to the nearest occupied neighbouring cell.
#'
#'   Returned rows are ordered from most isolated to least isolated.
#'
#' @details The function performs the following steps: 1) extracts raster cells
#'   with value `1`; 2) converts cells to coordinates; 3) computes
#'   nearest-neighbour distances using a kd-tree search; and 4) identifies cells
#'   whose nearest occupied neighbour exceeds the specified distance threshold.
#'
#'   Computational complexity is approximately: \deqn{O(n \log n)}, making the
#'   approach feasible for very large rasters.
#'
#'   Unlike full pairwise distance matrices, this implementation avoids
#'   quadratic memory growth and remains memory efficient even for large
#'   occupancy datasets.
#'
#'   Distances are computed using raster coordinate units. Therefore, rasters
#'   should generally use a projected CRS with metric units (e.g. meters).
#'
#'   Geographic rasters (longitude/latitude) should typically be projected
#'   before use:
#'
#' @examples
#' library(terra)
#'
#' r <- terra::rast(
#'   nrows = 200, ncols = 200, xmin = 4000000, xmax = 5000000,
#'   ymin = 2500000, ymax = 3500000, crs = "EPSG:3035", vals = NA_real_)
#'
#' # Simulated occupied cells
#' set.seed(100)
#' occ <- sample(terra::ncell(r), size = 2000)
#' r[occ] <- 1
#'
#' # Detect cells isolated by >20 km
#' detect_outliers(r, threshold = 30)
#' @export

detect_outliers <- function(r, threshold = 100L, plot_outliers = TRUE) {

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Check required packages
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  ecokit::check_packages("RANN", "terra", "tibble", "dplyr")

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Unwrap PackedSpatRaster if needed
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  if (inherits(r, "PackedSpatRaster")) {
    r <- terra::unwrap(r)
  }

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Validate input
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  if (!inherits(r, "SpatRaster")) {
    ecokit::stop_ctx("`r` must be a SpatRaster", class_r = class(r))
  }

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Extract occupied cells
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  vals <- terra::values(x = r, mat = FALSE)
  idx <- which(vals == 1L)

  if (length(idx) < 2L) {
    stop("Need at least two occupied cells", call. = FALSE)
  }

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Convert occupied cells to coordinates
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  xy <- terra::xyFromCell(r, idx)

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Compute nearest-neighbour distances
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  #
  # k = 2 because:
  #   neighbour 1 = the point itself
  #   neighbour 2 = nearest OTHER occupied cell
  #
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  nn <- RANN::nn2(data = xy, query = xy, k = 2L)
  nn <- nn$nn.dists[, 2L]

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Identify spatial outliers
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  keep <- nn > (threshold * 1000L)

  out <- tibble::tibble(
    cell = idx[keep], x = xy[keep, 1L], y = xy[keep, 2L],
    dist_km = nn[keep] / 1000L) %>%
    dplyr::arrange(dplyr::desc(dist_km))

  # ||||||||||||||||||||||||||||||||||||||||||||||||||||
  # Optional plotting
  # ||||||||||||||||||||||||||||||||||||||||||||||||||||

  if (plot_outliers && nrow(out) > 0L) {
    plot(r)
    points(out$x, out$y, pch = 16L, cex = 1.5, col = "red")
  }

  out
}
