# Determine the boundaries of the requested GBIF data

This function constructs a Well-Known Text (WKT) string representing a
polygon that outlines the specified boundaries. It is used to define the
area of interest for downloading GBIF data through the
`rgbif::pred_within()` function.

## Usage

``` r
boundary_to_wkt(left = NULL, right = NULL, bottom = NULL, top = NULL)
```

## Arguments

- left, right, bottom, top:

  Numeric, the left, right, bottom, and top boundary of the area.

## Value

A character string representing the WKT of the polygon that outlines the
specified boundaries.

## Author

Ahmed El-Gabbas

## Examples

``` r
boundary_to_wkt(left = 20, right = 30, bottom = 40, top = 50)
#> [1] "POLYGON((20 40,30 40,30 50,20 50,20 40))"
```
