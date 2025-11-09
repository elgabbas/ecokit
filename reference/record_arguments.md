# Capture and record evaluated function arguments

`record_arguments()` is a utility function that captures and records the
evaluated forms of arguments passed to the parent function. It returns a
tibble with columns named after the arguments, containing their
evaluated values only.

## Usage

``` r
record_arguments(out_path = NULL)
```

## Arguments

- out_path:

  Character. The path to an `.RData` file where the output tibble will
  be exported. If `NULL` (default), the tibble is returned without
  saving. If provided, the tibble is saved to the specified file and
  `NULL` is returned invisibly.

## Value

A `tibble` containing the evaluated forms of the parent function’s
arguments and any additional named arguments passed via `...`, with
columns named after the arguments (e.g., `w`, `x`, `y`, `extra1`).
Evaluated values are presented as scalars (e.g., `8`) or list columns
for complex objects (e.g., `<SpatRaster>`). If `out_path` is provided,
the tibble is saved to the specified `.RData` file and `NULL` is
returned invisibly.

## Details

This function evaluates all arguments in the grandparent environment
(two frames up), with a fallback to the global environment if evaluation
fails. This ensures correct evaluation in iterative contexts like
`lapply`. It handles:

- Scalars (e.g., numbers, strings) as single values.

- Multi-element vectors or complex objects (e.g., `SpatRaster`) as list
  columns.

- `NULL` values are converted to the string `"NULL"`.

- Failed evaluations result in `NA`.

- Additional named arguments passed via `...` in the parent function are
  also recorded.

The function must be called from within another function, as it relies
on `sys.call(-1)` to capture the parent call.

## Author

Ahmed El-Gabbas

## Examples

``` r
a <- 5
b <- 3
w_values <- 1:3
x_values <- c(a + b, 10, 15)
y_values <- c("ABCD", "XYZ123", "TEST")

Function1 <- function(w = 5, x, y, z = c(1, 2), ...) {
  Args <- record_arguments()
  return(Args)
}

# ----------------------------------------------------
# Example 1: Simple function call with scalar and expression
# ----------------------------------------------------

Function1(x = a + b, y = 2)
#> # A tibble: 1 × 4
#>       w     x     y z        
#>   <dbl> <dbl> <dbl> <list>   
#> 1     5     8     2 <dbl [2]>

# ----------------------------------------------------
# Example 2: Using lapply with indexed arguments
# ----------------------------------------------------

lapply(
  X = 1:3,
  FUN = function(Z) {
    Function1(
      w = w_values[Z],
      x = x_values[Z],
      y = stringr::str_extract(y_values[Z], "B.+$"),
      z = Z)
}) %>%
dplyr::bind_rows() %>%
print()
#> # A tibble: 3 × 4
#>       w     x y         z
#>   <int> <dbl> <chr> <int>
#> 1     1     8 BCD       1
#> 2     2    10 NA        2
#> 3     3    15 NA        3

# ----------------------------------------------------
# Example 3: Using pmap with mixed argument types
# ----------------------------------------------------

purrr::pmap(
  .l = list(w = w_values, x = x_values, y = y_values),
  .f = function(w, x, y) {
    Function1(
      w = w,
      x = x,
      y = stringr::str_extract(y, "B.+$"),
      z = terra::rast(system.file("ex/elev.tif", package = "terra")))
  }) %>%
  dplyr::bind_rows() %>%
  print()
#> # A tibble: 3 × 4
#>       w     x y     z         
#>   <int> <dbl> <chr> <list>    
#> 1     1     8 BCD   <PckdSptR>
#> 2     2    10 NA    <PckdSptR>
#> 3     3    15 NA    <PckdSptR>

# ----------------------------------------------------
# Example 4: Using additional arguments via ...
# ----------------------------------------------------

Function1(x = a + b, y = "test", extra1 = "hello", extra2 = 42)
#> # A tibble: 1 × 6
#>       w     x y     z         extra1 extra2
#>   <dbl> <dbl> <chr> <list>    <chr>   <dbl>
#> 1     5     8 test  <dbl [2]> hello      42
```
