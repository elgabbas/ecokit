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

nc_global_attributes <- function(nc = NULL) {

  # Input Validation
  if (is.null(nc)) {
    ecokit::stop_ctx("Input file cannot be NULL", nc = nc)
  }

  # Open the NetCDF File
  nc <- RNetCDF::open.nc(nc)

  # Extracting Global Attributes
  global_attributes <- purrr::map_chr(
    .x = (seq_len(RNetCDF::file.inq.nc(nc)$ngatt) - 1L),
    .f = ~{
      attributes_n <- RNetCDF::att.inq.nc(nc, "NC_GLOBAL", .x)$name
      attributes_v <- RNetCDF::att.get.nc(nc, "NC_GLOBAL", .x)
      paste0(attributes_n, "=", attributes_v)
    })

  # Closing the NetCDF File
  RNetCDF::close.nc(nc)

  return(global_attributes)
}
