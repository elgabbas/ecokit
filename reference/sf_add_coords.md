# Add longitude and latitude coordinates to an sf object

Add longitude and latitude coordinates as new columns to an sf object
(`sf_object`). It extracts the coordinates from the sf object, converts
them into a tibble, and appends them to the original sf object as new
columns. If `name_x` or `name_y`, provided as arguments respectively,
already exist in the sf object, the function either 1) overwrites these
columns if `overwrite` is set to `TRUE` or 2) appends a suffix to the
new column names to avoid overwrite if `overwrite` is set to `FALSE`.

## Usage

``` r
sf_add_coords(
  sf_object,
  name_x = "longitude",
  name_y = "latitude",
  overwrite = FALSE,
  suffix = "_NEW"
)
```

## Arguments

- sf_object:

  An `sf` object to which longitude and latitude columns will be added.

- name_x, name_y:

  Character. Name of the longitude column to be added. Defaults to
  `Long` and `Lat`.

- overwrite:

  Logical. Whether to overwrite existing columns with names specified by
  `name_x` and `name_y`. If `FALSE` and columns with these names exist,
  new columns are appended with a suffix. Defaults to `FALSE`.

- suffix:

  Character. Suffix to be appended to the new column names in cases of
  conflict and `overwrite` is `FALSE`. Defaults to `_NEW`.

## Value

An sf object with added longitude and latitude columns.

## Note

If the overwrite parameter is `FALSE` (default) and columns with the
specified names already exist, the function will issue a warning and
append suffix to the names of the new columns to avoid overwriting.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(sf)

# Example sf object
pt1 = sf::st_point(c(0, 1))
pt2 = sf::st_point(c(1, 1))
d = data.frame(a = c(1, 2))
d$geom = sf::st_sfc(pt1, pt2)
(df = sf::st_as_sf(d))
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 1 xmax: 1 ymax: 1
#> CRS:           NA
#>   a        geom
#> 1 1 POINT (0 1)
#> 2 2 POINT (1 1)

# |||||||||||||||||||||||||||||||||||||||||||

# add coordinates to the sf object and overwrite existing object
(df <- sf_add_coords(df))
#> Simple feature collection with 2 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 1 xmax: 1 ymax: 1
#> CRS:           NA
#>   a longitude latitude        geom
#> 1 1         0        1 POINT (0 1)
#> 2 2         1        1 POINT (1 1)

# add coordinates again
sf_add_coords(df)
#> Warning: long/lat column names already exist in the data: _NEW is used as suffix
#> Simple feature collection with 2 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 1 xmax: 1 ymax: 1
#> CRS:           NA
#>   a longitude latitude longitude_NEW latitude_NEW        geom
#> 1 1         0        1             0            1 POINT (0 1)
#> 2 2         1        1             1            1 POINT (1 1)

# add coordinates again, using custom suffix
sf_add_coords(df, suffix = "new")
#> Warning: long/lat column names already exist in the data: _new is used as suffix
#> Simple feature collection with 2 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 1 xmax: 1 ymax: 1
#> CRS:           NA
#>   a longitude latitude longitude_new latitude_new        geom
#> 1 1         0        1             0            1 POINT (0 1)
#> 2 2         1        1             1            1 POINT (1 1)

# |||||||||||||||||||||||||||||||||||||||||||

# jitter the coordinates a little
set.seed(100)
(df2 <- sf::st_jitter(df, amount = 0.1))
#> Simple feature collection with 2 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -0.03844678 ymin: 0.9112766 xmax: 1.010464 ymax: 0.9515345
#> CRS:           NA
#>   a longitude latitude                          geom
#> 1 1         0        1 POINT (-0.03844678 0.9515345)
#> 2 2         1        1    POINT (1.010464 0.9112766)

sf_add_coords(df2, overwrite = FALSE)
#> Warning: long/lat column names already exist in the data: _NEW is used as suffix
#> Simple feature collection with 2 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -0.03844678 ymin: 0.9112766 xmax: 1.010464 ymax: 0.9515345
#> CRS:           NA
#>   a longitude latitude longitude_NEW latitude_NEW                          geom
#> 1 1         0        1   -0.03844678    0.9515345 POINT (-0.03844678 0.9515345)
#> 2 2         1        1    1.01046449    0.9112766    POINT (1.010464 0.9112766)

sf_add_coords(df2, overwrite = TRUE)
#> Warning: long/lat column names already exist in the data: overwritten
#> Simple feature collection with 2 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -0.03844678 ymin: 0.9112766 xmax: 1.010464 ymax: 0.9515345
#> CRS:           NA
#>   a   longitude  latitude                          geom
#> 1 1 -0.03844678 0.9515345 POINT (-0.03844678 0.9515345)
#> 2 2  1.01046449 0.9112766    POINT (1.010464 0.9112766)
```
