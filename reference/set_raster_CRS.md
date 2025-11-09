# Set CRS for a SpatRaster in a Pipeline

Sets the coordinate reference system (CRS) of a `SpatRaster` object
using a specified CRS string, designed for use in data processing
pipelines (e.g., with `%>%`). Wraps `terra::crs<-` to assign a valid
CRS, such as an EPSG code.

## Usage

``` r
set_raster_crs(raster = NULL, crs = NULL)
```

## Arguments

- raster:

  A `SpatRaster` or `PackedSpatRaster` object whose CRS is to be set.
  Cannot be `NULL` or non-`SpatRaster`.

- crs:

  Character. A valid CRS string (e.g., EPSG code, WKT, or PROJ4) to set
  for the `raster`.

## Value

The modified `SpatRaster` object with the updated CRS.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(terra)

# Create a sample SpatRaster, with missing CRS
r <- terra::rast(nrows = 10, ncols = 10, vals = 1:100)
terra::crs(r) <- NULL
print(r)
#> class       : SpatRaster 
#> size        : 10, 10, 1  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> name        : lyr.1 
#> min value   :     1 
#> max value   :   100 

terra::crs(r, describe = TRUE)$code
#> [1] NA


# Set CRS to EPSG:4326
(r_modified <- set_raster_crs(r, "epsg:4326"))
#> class       : SpatRaster 
#> size        : 10, 10, 1  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source(s)   : memory
#> name        : lyr.1 
#> min value   :     1 
#> max value   :   100 
terra::crs(r_modified, describe = TRUE)$code
#> [1] "4326"
```
