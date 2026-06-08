# Sort raster layers by name using natural ordering

Sorts the layers of a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
according to their layer names using natural (mixed) ordering. Numeric
components of layer names are ordered numerically rather than
lexicographically (e.g. `"layer2"` is placed before `"layer10"`).

## Usage

``` r
sort_raster_layers(r)
```

## Arguments

- r:

  A
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Value

A
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
with layers reordered according to natural sorting of layer names.

## Details

If duplicate layer names are detected, a warning is issued because the
resulting order of layers with identical names cannot be distinguished
by name alone. Layer order is preserved among duplicated names according
to their original positions.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(terra, dplyr, dismo)

fnames <- list.files(
  path = paste(system.file(package = "dismo"), "/ex", sep = ""),
  pattern = "grd", full.names = TRUE)
(r <- terra::rast(fnames))
#> class       : SpatRaster
#> size        : 192, 186, 9  (nrow, ncol, nlyr)
#> resolution  : 0.5, 0.5  (x, y)
#> extent      : -125, -32, -56, 40  (xmin, xmax, ymin, ymax)
#> coord. ref. : +proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs
#> sources     : bio1.grd
#>               bio12.grd
#>               bio16.grd
#>               ... and 6 more sources
#> names       : bio1, bio12, bio16, bio17, bio5, bio6, ...
#> min values  :  -23,     0,     0,     0,   61, -212, ...
#> max values  :  289,  7682,  2458,  1496,  422,  242, ...
names(r)
#> [1] "bio1"  "bio12" "bio16" "bio17" "bio5"  "bio6"  "bio7"  "bio8"  "biome"

(r2 <- sort_raster_layers(r))
#> class       : SpatRaster
#> size        : 192, 186, 9  (nrow, ncol, nlyr)
#> resolution  : 0.5, 0.5  (x, y)
#> extent      : -125, -32, -56, 40  (xmin, xmax, ymin, ymax)
#> coord. ref. : +proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs
#> sources     : bio1.grd
#>               bio5.grd
#>               bio6.grd
#>               ... and 6 more sources
#> names       : bio1, bio5, bio6, bio7, bio8, bio12, ...
#> min values  :  -23,   61, -212,   60,  -66,     0, ...
#> max values  :  289,  422,  242,  461,  323,  7682, ...
names(r2)
#> [1] "bio1"  "bio5"  "bio6"  "bio7"  "bio8"  "bio12" "bio16" "bio17" "biome"

# ---------------------------------------------------

r <- terra::rast(nrows = 10, ncols = 10, nlyrs = 4, vals = 1) %>%
   stats::setNames(c("layer10", "layer2", "layer10", "layer1"))
r
#> class       : SpatRaster
#> size        : 10, 10, 4  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source      : spat_22846d02d639_8836_IpQM0ozIAA6UNCC.tif
#> names       : layer10, layer2, layer10, layer1
#> min values  :       1,      1,       1,      1
#> max values  :       1,      1,       1,      1

sort_raster_layers(r)
#> Warning: Duplicated layer names detected: 'layer10'. Layers will be sorted by name, but duplicated names cannot be uniquely distinguished.
#> class       : SpatRaster
#> size        : 10, 10, 4  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source      : spat_22846d02d639_8836_IpQM0ozIAA6UNCC.tif
#> names       : layer1, layer2, layer10, layer10
#> min values  :      1,      1,       1,       1
#> max values  :      1,      1,       1,       1
```
