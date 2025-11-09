# Keep only specified objects in the environment, removing all others.

This function selectively retains the objects specified in the `objects`
parameter in the current environment, removing all other objects. It is
useful for memory management by clearing unnecessary objects from the
environment. The function also provides an option to print the names of
the kept and removed variables.

## Usage

``` r
keep_only(objects, verbose = TRUE)
```

## Arguments

- objects:

  Character vector. Names of the objects to be kept in the environment.

- verbose:

  Logical. Whether to print the names of kept and removed variables.
  Default to `TRUE`.

## Value

No return value, called for side effects.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(terra)

A <- B <- C <- 15
ls()
#> [1] "A" "B" "C"

keep_only("A")
#> Removed Variables (2): 1:B ||  2:C
#> Kept Variables (1): 1:A

ls()
#> [1] "A"
rm(list = ls())


A <- B <- C <- 15
keep_only(c("A","B"))
#> Removed Variables (1): 1:C
#> Kept Variables (2): 1:A ||  2:B
ls()
#> [1] "A" "B"

# -------------------------------------------

# use inside a function
function1 <- function(a = 1, b = 2, c = 3) {
  z <- terra::rast()
  print(paste0("available objects before keep_only: ", toString(ls())))

  keep_only(c("a", "b"), verbose = FALSE)
  print(paste0("available objects after keep_only: ", toString(ls())))

  return(invisible(NULL))
}
function1()
#> [1] "available objects before keep_only: a, b, c, z"
#> [1] "available objects after keep_only: a, b"
```
