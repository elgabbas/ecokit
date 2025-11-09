# Assign a value to a variable if it does not already exist in the specified environment

This function checks if a given variable exists in the specified
environment (global environment by default). If the variable does not
exist, it assigns a given value to it. If the variable already exists,
it prints the current value of the variable. The function is designed to
prevent overwriting existing variables unintentionally.

## Usage

``` r
assign_if_not_exist(variable, value, environment = globalenv())
```

## Arguments

- variable:

  Character; the name of the variable to be checked and potentially
  assigned a value.

- value:

  any; the value to be assigned to the variable if it does not already
  exist.

- environment:

  environment; the environment in which to check for the existence of
  the variable and potentially assign the value. Defaults to the global
  environment.

## Value

The function explicitly returns `NULL`, but its primary effect is the
side-effect of assigning a value to a variable in an environment or
printing the current value of an existing variable.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(terra)

exists("x")
#> [1] FALSE
assign_if_not_exist(variable = "x", value = TRUE)
exists("x")
#> [1] TRUE
print(x)
#> [1] TRUE

# --------------------------------------------------

y <- 10
# y exists and thus its value was not changed
assign_if_not_exist(variable = "y", value = TRUE)
print(y)
#> [1] 10

# --------------------------------------------------

assign_if_not_exist(
  variable = "R", value = terra::rast(nrows = 10, ncols = 10))
print(R)
#> class       : SpatRaster 
#> size        : 10, 10, 1  (nrow, ncol, nlyr)
#> resolution  : 36, 18  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84) 
```
