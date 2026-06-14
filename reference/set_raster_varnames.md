# Set the variable name of a SpatRaster within a pipe

A small wrapper function that assigns a single variable name `varnames`
to a `SpatRaster` and returns the object, making it suitable for use in
a `magrittr` pipe without breaking the chain.

## Usage

``` r
set_raster_varnames(rast, var_name)
```

## Arguments

- rast:

  `[SpatRaster]` A `SpatRaster` object whose variable name is to be set.
  Must not be `NULL`.

- var_name:

  `[character(1)]` or `NULL`. A single non-empty string to assign as the
  variable name. If `NULL`, the variable name is reset to `""` (terra's
  default empty state).

## Value

The input `SpatRaster` with an updated `varnames` slot.

## `names` vs `varnames`

`terra` stores two distinct name slots:

- **`names`** (per-layer) – used in plots,
  [`as.data.frame()`](https://rspatial.github.io/terra/reference/as.data.frame.html),
  and subsetting. Set via `names(x) <- ...` or
  [`terra::set.names()`](https://rspatial.github.io/terra/reference/inplace.html).

- **`varnames`** (per-data-source) – a single string inherited from the
  source file variable name (e.g. NetCDF). For any in-memory or derived
  `SpatRaster` there is always exactly one data source regardless of the
  number of layers, so `varnames` only ever holds **one** value.

## Author

Ahmed El-Gabbas

## Examples

``` r
library(terra)

r <- terra::rast(
  ncols = 10, nrows = 10, nlyr = 3, vals = 1L, names = c("l1", "l2", "l3"))

# setting variable names directly with terra
terra::varnames(r) <- "v1"
r
#> class       : SpatRaster
#> size        : 10, 10, 3  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source      : spat_22522097a335_8786_BnO3HOrWuPceBcV.tif
#> varname     : v1
#> names       : l1, l2, l3
#> min values  :  1,  1,  1
#> max values  :  1,  1,  1

# Set variable name within a pipe
(r2 <- set_raster_varnames(r, "temperature"))
#> class       : SpatRaster
#> size        : 10, 10, 3  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source      : spat_22522097a335_8786_BnO3HOrWuPceBcV.tif
#> varname     : temperature
#> names       : l1, l2, l3
#> min values  :  1,  1,  1
#> max values  :  1,  1,  1

# Reset variable name to empty
(r3 <- set_raster_varnames(r, NULL))
#> class       : SpatRaster
#> size        : 10, 10, 3  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source      : spat_22522097a335_8786_BnO3HOrWuPceBcV.tif
#> names       : l1, l2, l3
#> min values  :  1,  1,  1
#> max values  :  1,  1,  1
```
