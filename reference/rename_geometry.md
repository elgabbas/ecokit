# Rename Active Geometry Column of an `sf` Object

Renames the active geometry column of a simple feature (`sf`) object to
a user-specified name.

## Usage

``` r
rename_geometry(sf_object = NULL, new_name = NULL)
```

## Arguments

- sf_object:

  An `sf` object with an active geometry column. Cannot be `NULL`.

- new_name:

  Character. A single, non-empty name for the geometry column. Cannot be
  `NULL` or match an existing non-geometry column name.

## Value

The modified `sf` object with the geometry column renamed to `new_name`.

## Note

The `sf_object` must have a valid geometry column, and `new_name` must
not conflict with existing column names.

## References

[Click here](https://gis.stackexchange.com/a/386589/30390)

## Examples

``` r
load_packages(sf)

# example data
(nc <- sf::st_read(
  dsn = system.file("shape/nc.shp", package = "sf"), quiet = TRUE) %>%
  dplyr::select(AREA))
#> Simple feature collection with 100 features and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> Geodetic CRS:  NAD27
#> First 10 features:
#>     AREA                       geometry
#> 1  0.114 MULTIPOLYGON (((-81.47276 3...
#> 2  0.061 MULTIPOLYGON (((-81.23989 3...
#> 3  0.143 MULTIPOLYGON (((-80.45634 3...
#> 4  0.070 MULTIPOLYGON (((-76.00897 3...
#> 5  0.153 MULTIPOLYGON (((-77.21767 3...
#> 6  0.097 MULTIPOLYGON (((-76.74506 3...
#> 7  0.062 MULTIPOLYGON (((-76.00897 3...
#> 8  0.091 MULTIPOLYGON (((-76.56251 3...
#> 9  0.118 MULTIPOLYGON (((-78.30876 3...
#> 10 0.124 MULTIPOLYGON (((-80.02567 3...

# Rename geometry column
(nc_renamed <- rename_geometry(nc, "new_geom"))
#> Simple feature collection with 100 features and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> Geodetic CRS:  NAD27
#> First 10 features:
#>     AREA                       new_geom
#> 1  0.114 MULTIPOLYGON (((-81.47276 3...
#> 2  0.061 MULTIPOLYGON (((-81.23989 3...
#> 3  0.143 MULTIPOLYGON (((-80.45634 3...
#> 4  0.070 MULTIPOLYGON (((-76.00897 3...
#> 5  0.153 MULTIPOLYGON (((-77.21767 3...
#> 6  0.097 MULTIPOLYGON (((-76.74506 3...
#> 7  0.062 MULTIPOLYGON (((-76.00897 3...
#> 8  0.091 MULTIPOLYGON (((-76.56251 3...
#> 9  0.118 MULTIPOLYGON (((-78.30876 3...
#> 10 0.124 MULTIPOLYGON (((-80.02567 3...

names(nc)
#> [1] "AREA"     "geometry"
names(nc_renamed)
#> [1] "AREA"     "new_geom"

attr(nc, "sf_column")
#> [1] "geometry"
attr(nc_renamed, "sf_column")
#> [1] "new_geom"
```
