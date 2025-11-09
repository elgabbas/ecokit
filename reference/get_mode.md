# Calculate the mode of a numeric vector

This function calculates the mode of a given numeric vector.

## Usage

``` r
get_mode(x)
```

## Source

The source of this function was taken from this
[link](https://www.tutorialspoint.com/r/r_mean_median_mode.htm).

## Arguments

- x:

  Numeric vector. It must not be `NULL` or empty.

## Value

The mode of the vector as a single value. If the vector has a uniform
distribution (all values appear with the same frequency), the function
returns the first value encountered.

## Examples

``` r
get_mode(c(seq_len(10), 1, 1, 3, 3, 3, 3))
#> [1] 3

get_mode(c(1, 2, 2, 3, 4))
#> [1] 2

get_mode(c(1, 1, 2, 3, 3))
#> [1] 1
```
