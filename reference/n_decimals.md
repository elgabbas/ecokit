# Number of decimal places in a numeric or character value

This function calculates the number of decimal places in a numeric or
character value by counting all digits after the decimal point in the
string representation, including trailing zeros for characters. It is
vectorized and designed to work with numeric inputs or character strings
representing numbers, making it suitable for use with
[`dplyr::mutate`](https://dplyr.tidyverse.org/reference/mutate.html).

## Usage

``` r
n_decimals(x = NULL)
```

## Arguments

- x:

  Numeric or character vector representing numeric values.

## Value

An integer vector of the same length as `x`, where each element
represents the number of decimal places in the corresponding input
value.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Character input with trailing zeros
n_decimals(c("1.35965", "65.5484900000", "0.11840000"))
#> [1]  5 10  8

# Numeric input with trailing zeros
n_decimals(c(1.35965, 65.5484900000, 0.11840000))
#> [1] 5 5 4

# Use with dplyr
library(dplyr)
mtcars %>%
  dplyr::select(wt) %>%
  dplyr::mutate(n_decimals = n_decimals(wt))
#>                        wt n_decimals
#> Mazda RX4           2.620          2
#> Mazda RX4 Wag       2.875          3
#> Datsun 710          2.320          2
#> Hornet 4 Drive      3.215          3
#> Hornet Sportabout   3.440          2
#> Valiant             3.460          2
#> Duster 360          3.570          2
#> Merc 240D           3.190          2
#> Merc 230            3.150          2
#> Merc 280            3.440          2
#> Merc 280C           3.440          2
#> Merc 450SE          4.070          2
#> Merc 450SL          3.730          2
#> Merc 450SLC         3.780          2
#> Cadillac Fleetwood  5.250          2
#> Lincoln Continental 5.424          3
#> Chrysler Imperial   5.345          3
#> Fiat 128            2.200          1
#> Honda Civic         1.615          3
#> Toyota Corolla      1.835          3
#> Toyota Corona       2.465          3
#> Dodge Challenger    3.520          2
#> AMC Javelin         3.435          3
#> Camaro Z28          3.840          2
#> Pontiac Firebird    3.845          3
#> Fiat X1-9           1.935          3
#> Porsche 914-2       2.140          2
#> Lotus Europa        1.513          3
#> Ford Pantera L      3.170          2
#> Ferrari Dino        2.770          2
#> Maserati Bora       3.570          2
#> Volvo 142E          2.780          2
```
