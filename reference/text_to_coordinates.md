# Extract longitude and latitude from string

Extract longitude and latitude from string representing a geographical
point in the format `"POINT (longitude latitude)"` and converts it into
a two-column tibble containing the longitude and latitude as numeric
values. The names of the columns in the resulting tibble can be
customized. The default names for the longitude and latitude columns are
"Longitude" and "Latitude", respectively.

## Usage

``` r
text_to_coordinates(text = NULL, name_x = "Longitude", name_y = "Latitude")
```

## Arguments

- text:

  Character. Coordinates in the format `"POINT (longitude latitude)"`.
  This parameter is required and cannot be `NULL`.

- name_x, name_y:

  Character. Name to be used for the longitude and Longitude columns in
  the output tibble. Defaults to "Longitude" and "Latitude".

## Value

A tibble with two columns containing the longitude and latitude values
extracted from the input string. The names of these columns are
determined by the `name_x` and `name_y` parameters. If no names are
provided, the default names ("Longitude" and "Latitude") are used.

## Author

Ahmed El-Gabbas

## Examples

``` r
c("POINT (11.761 46.286)", "POINT (14.8336 42.0422)",
  "POINT (16.179999 38.427214)") %>%
 purrr::map(text_to_coordinates) %>%
 dplyr::bind_rows()
#> # A tibble: 3 × 2
#>   Longitude Latitude
#>       <dbl>    <dbl>
#> 1      11.8     46.3
#> 2      14.8     42.0
#> 3      16.2     38.4

c("POINT (11.761 46.286)", "POINT (14.8336 42.0422)",
  "POINT (16.179999 38.427214)") %>%
 purrr::map(text_to_coordinates, name_x = "Long", name_y = "Lat") %>%
 dplyr::bind_rows()
#> # A tibble: 3 × 2
#>    Long   Lat
#>   <dbl> <dbl>
#> 1  11.8  46.3
#> 2  14.8  42.0
#> 3  16.2  38.4
```
