#' Write a SpatRaster to a NetCDF File with Multiple Variables
#'
#' This function takes a `terra::SpatRaster` object and writes it to a NetCDF
#' file. Each layer of the input raster is saved as a separate, correctly named
#' variable in the output file. This function uses the `ncdf4` package for
#' robust, low-level control over the NetCDF creation process, ensuring that
#' layer names, CRS, and other metadata are preserved and compression is applied
#' correctly.
#'
#' @param input_raster A `terra::SpatRaster` object with one or more layers. The
#'   names of the layers will be used as the variable names in the `NetCDF`
#'   file.
#' @param filename Character. The file path for the output NetCDF file. It is
#'   recommended to use a `.nc` extension.
#' @param overwrite Logical. If `TRUE`, an existing file at the specified
#'   `filename` will be overwritten. Defaults to `FALSE`.
#' @param compression_level An integer between 0 (no compression) and 9 (maximum
#'   DEFLATE compression). Defaults to `9`.
#' @param missval Numeric. Value for missing values in the NetCDF file. Defaults
#'   to `-9999`.
#' @param var_units A character string or a vector of character strings
#'   specifying the units for each variable. If a single string is provided, it
#'   will be applied to all variables. If a vector, its length must match the
#'   number of layers in `input_raster`. Defaults to `"unknown"`.
#'
#' @return This function does not return a value. It is called for its side
#'   effect of writing a file to disk.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#'
#' require(terra)
#' require(ncdf4)
#' require(dismo)
#'
#' fnames <- list.files(
#'   path = paste(system.file(package = "dismo"), "/ex", sep = ""),
#'   pattern = "grd", full.names = TRUE)
#'
#' predictors <- terra::toMemory(terra::rast(fnames))
#' names(predictors)
#'
#' # Define an output file path
#' output_file <- tempfile(fileext = ".nc")
#'
#' # Use the function to write the SpatRaster to a NetCDF file
#' write_terra_to_nc(
#'   input_raster = predictors,
#'   filename = output_file,
#'   overwrite = TRUE,
#'   compression_level = 7)
#'
#' # Verify the result
#' predictors2 <- terra::rast(output_file)
#' print(identical(names(predictors), names(predictors2)))
#'
#' difference_raster <- predictors - predictors2
#' print(terra::minmax(difference_raster))
#'
#' # Clean up the temporary file
#' unlink(output_file)

write_terra_to_nc <- function(
    input_raster = NULL, filename = NULL, overwrite = FALSE,
    compression_level = 9L, missval = -9999L, var_units = "unknown") {


  # Input Validation -------

  if (!inherits(input_raster, "SpatRaster")) {
    ecokit::stop_ctx(
      "`input_raster` must be a SpatRaster object from the 'terra' package.",
      class_input_raster = class(input_raster), cat_timestamp = FALSE)
  }

  n_layers <- terra::nlyr(input_raster)

  if (terra::nlyr(input_raster) == 0L) {
    ecokit::stop_ctx(
      "`input_raster` must have at least one layer.", cat_timestamp = FALSE)
  }

  if (file.exists(filename) && !overwrite) {
    ecokit::stop_ctx(
      paste0(
        "File already exists: ", filename,
        " - Use `overwrite = TRUE` to replace it."),
      filename = filename, overwrite = overwrite, cat_timestamp = FALSE)
  }

  if (!is.numeric(compression_level) || compression_level < 0L ||
      compression_level > 9L || (compression_level %% 1L != 0L)) {
    ecokit::stop_ctx(
      "`compression_level` must be an integer between 0 and 9.",
      cat_timestamp = FALSE)
  }

  if (length(var_units) > 1L && length(var_units) != n_layers) {
    ecokit::stop_ctx(
      paste0(
        "`var_units` must be a single string or a character vector of ",
        "the same length as the number of layers in `input_raster`."),
      var_units = var_units, n_layers = n_layers, cat_timestamp = FALSE)
  }

  original_names <- names(input_raster)
  if (any(is.null(original_names)) || !all(nzchar(original_names))) {
    ecokit::stop_ctx(
      "All layers in `input_raster` must have valid names.",
      original_names = original_names, cat_timestamp = FALSE)
  }

  # Recycle var_units if it's a single value
  if (length(var_units) == 1L) {
    var_units <- rep(var_units, n_layers)
  }

  # Define NetCDF Dimensions and Variables -----

  xvals <- terra::xFromCol(input_raster, seq_len(ncol(input_raster)))
  yvals <- terra::yFromRow(input_raster, seq_len(nrow(input_raster)))
  lon_dim <- ncdf4::ncdim_def("longitude", "degrees_east", xvals)
  lat_dim <- ncdf4::ncdim_def("latitude", "degrees_north", yvals)

  var_list <- list()
  for (i in seq_len(n_layers)) {
    var_list[[i]] <- ncdf4::ncvar_def(
      name = original_names[i],
      units = var_units[i],
      dim = list(lon_dim, lat_dim),
      missval = missval,
      prec = "double",
      compression = if (compression_level > 0L) compression_level else NA
    )
  }

  # Define a dummy variable to hold CRS metadata
  crs_var <- ncdf4::ncvar_def(
    name = "crs", units = "", dim = list(), missval = NULL, prec = "integer")
  var_list[[n_layers + 1L]] <- crs_var


  # Create File and Write Data ------

  if (overwrite && fs::file_exists(filename)) {
    suppressWarnings(fs::file_delete(filename))
  }

  nc_file <- ncdf4::nc_create(filename, var_list, force_v4 = TRUE)

  # Get the WKT string (using proj=FALSE for compatibility with older terra)
  # and add it as an attribute to the 'crs' variable.
  crs_wkt <- terra::crs(input_raster, proj = FALSE)
  if (!is.null(crs_wkt) && nzchar(crs_wkt)) {
    ncdf4::ncatt_put(nc_file, "crs", "crs_wkt", crs_wkt)
  }

  tryCatch({
    for (i in seq_len(n_layers)) {
      # Link each data variable to the 'crs' variable if a CRS exists
      if (!is.null(crs_wkt) && nzchar(crs_wkt)) {
        ncdf4::ncatt_put(nc_file, original_names[i], "grid_mapping", "crs")
      }

      # Extract data and transpose to align with (lon, lat) dimension order
      layer_data <- terra::as.matrix(input_raster[[i]], wide = TRUE)
      ncdf4::ncvar_put(nc_file, var_list[[i]], t(layer_data))
    }
  }, finally = {
    # Ensure the file is closed even if an error occurs during writing
    ncdf4::nc_close(nc_file)
  })

  invisible(NULL)
}
