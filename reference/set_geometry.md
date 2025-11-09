# Set Geometry Column of an `sf` Object in a Pipeline

Sets the active geometry column of a simple feature (`sf`) object to a
specified column, designed for use in data processing pipelines (e.g.,
with `%>%`). Ensures spatial operations use the correct geometry column.

## Usage

``` r
set_geometry(sf_object = NULL, geometry_column = NULL)
```

## Arguments

- sf_object:

  An `sf` object with at least one geometry (`sfc`) column. Cannot be
  `NULL` or non-`sf`.

- geometry_column:

  Character. Name of an existing `sfc` geometry column in `sf_object` to
  set as the active geometry. Must be a single, non-empty character
  string.

## Value

The modified `sf` object with the active geometry column set to
`geometry_column`.

## Note

The `geometry_column` must be an existing `sfc` column in `sf_object`.
Use with caution to avoid overwriting the active geometry
unintentionally.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(sf, dplyr, ggplot2)

# example data with multiple geometry columns
nc <- sf::st_read(
  dsn = system.file("shape/nc.shp", package = "sf"), quiet = TRUE) %>%
  dplyr::select(AREA)
# add a new geometry column
nc$centroid <- sf::st_centroid(st_geometry(nc))

nc
#> Simple feature collection with 100 features and 1 field
#> Active geometry column: geometry
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> Geodetic CRS:  NAD27
#> First 10 features:
#>     AREA                       geometry                   centroid
#> 1  0.114 MULTIPOLYGON (((-81.47276 3...  POINT (-81.49823 36.4314)
#> 2  0.061 MULTIPOLYGON (((-81.23989 3... POINT (-81.12513 36.49111)
#> 3  0.143 MULTIPOLYGON (((-80.45634 3... POINT (-80.68573 36.41252)
#> 4  0.070 MULTIPOLYGON (((-76.00897 3... POINT (-76.02719 36.40714)
#> 5  0.153 MULTIPOLYGON (((-77.21767 3... POINT (-77.41046 36.42236)
#> 6  0.097 MULTIPOLYGON (((-76.74506 3... POINT (-76.99472 36.36142)
#> 7  0.062 MULTIPOLYGON (((-76.00897 3... POINT (-76.23402 36.40122)
#> 8  0.091 MULTIPOLYGON (((-76.56251 3... POINT (-76.70446 36.44428)
#> 9  0.118 MULTIPOLYGON (((-78.30876 3... POINT (-78.11042 36.39693)
#> 10 0.124 MULTIPOLYGON (((-80.02567 3... POINT (-80.23429 36.40042)

# set centroid as active geometry in a pipeline
nc_modified <- set_geometry(nc, "centroid")
nc_modified
#> Simple feature collection with 100 features and 1 field
#> Active geometry column: centroid
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -84.05986 ymin: 34.07671 xmax: -75.8095 ymax: 36.49111
#> Geodetic CRS:  NAD27
#> First 10 features:
#>     AREA                       geometry                   centroid
#> 1  0.114 MULTIPOLYGON (((-81.47276 3...  POINT (-81.49823 36.4314)
#> 2  0.061 MULTIPOLYGON (((-81.23989 3... POINT (-81.12513 36.49111)
#> 3  0.143 MULTIPOLYGON (((-80.45634 3... POINT (-80.68573 36.41252)
#> 4  0.070 MULTIPOLYGON (((-76.00897 3... POINT (-76.02719 36.40714)
#> 5  0.153 MULTIPOLYGON (((-77.21767 3... POINT (-77.41046 36.42236)
#> 6  0.097 MULTIPOLYGON (((-76.74506 3... POINT (-76.99472 36.36142)
#> 7  0.062 MULTIPOLYGON (((-76.00897 3... POINT (-76.23402 36.40122)
#> 8  0.091 MULTIPOLYGON (((-76.56251 3... POINT (-76.70446 36.44428)
#> 9  0.118 MULTIPOLYGON (((-78.30876 3... POINT (-78.11042 36.39693)
#> 10 0.124 MULTIPOLYGON (((-80.02567 3... POINT (-80.23429 36.40042)

attr(nc, "sf_column")
#> [1] "geometry"
attr(nc_modified, "sf_column")
#> [1] "centroid"

ggplot2::ggplot() +
  ggplot2::geom_sf(data = nc, aes(fill = NULL)) +
  ggplot2::geom_sf(data = nc_modified, colour = "red") +
  ggplot2::theme_minimal()
```
