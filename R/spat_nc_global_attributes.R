## |------------------------------------------------------------------------| #
# nc_global_attributes ------
## |------------------------------------------------------------------------| #

#' Get global attributes for `NetCDF` files
#'
#' This function opens a `NetCDF` file, extracts all global attributes, and
#' returns them as a character vector where each element is an attribute
#' name-value pair.
#' @name nc_global_attributes
#' @param nc Character. Path to the `NetCDF` file. If
#'   `NULL`, the function will stop with an error message.
#' @return A character vector where each element is a global attribute.
#' @references [Click here](https://github.com/rspatial/terra/issues/1443)
#' @export
#' @examples
#' require(ecokit)
#' ecokit::load_packages(stars, sf, fs)
#'
#' nc_example_1 <- system.file("nc/sub.nc", package = "stars")
#' if (fs::file_exists(nc_example_1)) nc_global_attributes(nc = nc_example_1)
#'
#' nc_example_2 <- system.file("nc/timeseries.nc", package = "stars")
#' if (fs::file_exists(nc_example_2)) nc_global_attributes(nc = nc_example_2)
#'
#' nc_example_3 <- system.file("nc/cropped.nc", package = "sf")
#' if (fs::file_exists(nc_example_3)) nc_global_attributes(nc = nc_example_3)

nc_global_attributes <- function(nc = NULL) {

  # Input Validation
  if (is.null(nc)) {
    ecokit::stop_ctx("Input file cannot be NULL", nc = nc)
  }

  if (!is.character(nc) || length(nc) != 1L) {
    ecokit::stop_ctx("`nc` must be a single character string", nc = nc)
  }

  if (!fs::file_exists(nc)) {
    ecokit::stop_ctx("NetCDF file does not exist", nc = nc)
  }

  if (tolower(tools::file_ext(nc)) != "nc") {
    ecokit::stop_ctx("File must have a `.nc` extension", nc = nc)
  }

  is_nc <- ecokit::file_type(nc)
  if (!startsWith(is_nc, "NetCDF Data Format data")) {
    ecokit::stop_ctx("File is not a valid NetCDF file", nc = nc)
  }

  if (!requireNamespace("RNetCDF", quietly = TRUE)) {
    ecokit::stop_ctx("The `RNetCDF` package is required to read NetCDF files.")
  }

  # Open the NetCDF File
  nc_handle <- RNetCDF::open.nc(nc)
  on.exit(RNetCDF::close.nc(nc_handle), add = TRUE)

  # Extracting Global Attributes
  ngatt <- RNetCDF::file.inq.nc(nc_handle)$ngatt
  if (ngatt == 0L) {
    return(character(0L))
  }
  global_attributes <- purrr::map_chr(
    .x = (seq_len(ngatt) - 1L),
    .f = ~{
      attribute_name <- RNetCDF::att.inq.nc(nc_handle, "NC_GLOBAL", .x)$name
      attribute_value <- RNetCDF::att.get.nc(nc_handle, "NC_GLOBAL", .x)
      paste0(attribute_name, "=", attribute_value)
    })

  # Closing the NetCDF File
  RNetCDF::close.nc(nc_handle)

  return(global_attributes)
}
