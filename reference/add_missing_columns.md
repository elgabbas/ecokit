# Add missing columns to a data frame with specified fill values

This function checks a data frame for missing columns specified by the
user. If any are missing, it adds these columns to the data frame,
filling them with a specified value.

## Usage

``` r
add_missing_columns(data, fill_value = NA_character_, ...)
```

## Arguments

- data:

  A data frame to which missing columns will be added. This parameter
  cannot be `NULL`.

- fill_value:

  The value to fill the missing columns with. This parameter defaults to
  `NA_character_`, but can be changed to any scalar value as required.

- ...:

  Column names as character strings.

## Value

a data frame with the missing columns added, if any were missing.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(dplyr, tibble)

# example data
(mtcars2 <- dplyr::select(mtcars, seq_len(3)) %>%
  head() %>%
  tibble::as_tibble())
#> # A tibble: 6 × 3
#>     mpg   cyl  disp
#>   <dbl> <dbl> <dbl>
#> 1  21       6   160
#> 2  21       6   160
#> 3  22.8     4   108
#> 4  21.4     6   258
#> 5  18.7     8   360
#> 6  18.1     6   225

mtcars2 %>%
 add_missing_columns(fill_value = NA_character_, A, B, C) %>%
 add_missing_columns(fill_value = as.integer(10), D)
#> # A tibble: 6 × 7
#>     mpg   cyl  disp A     B     C         D
#>   <dbl> <dbl> <dbl> <chr> <chr> <chr> <int>
#> 1  21       6   160 NA    NA    NA       10
#> 2  21       6   160 NA    NA    NA       10
#> 3  22.8     4   108 NA    NA    NA       10
#> 4  21.4     6   258 NA    NA    NA       10
#> 5  18.7     8   360 NA    NA    NA       10
#> 6  18.1     6   225 NA    NA    NA       10

AddCols <- c("Add1", "Add2")
mtcars2 %>%
 add_missing_columns(fill_value = NA_real_, AddCols)
#> # A tibble: 6 × 5
#>     mpg   cyl  disp  Add1  Add2
#>   <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21       6   160    NA    NA
#> 2  21       6   160    NA    NA
#> 3  22.8     4   108    NA    NA
#> 4  21.4     6   258    NA    NA
#> 5  18.7     8   360    NA    NA
#> 6  18.1     6   225    NA    NA
```
