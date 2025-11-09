# Print function Arguments

This function takes another function as input and prints its arguments
in the format `ArgumentName = DefaultValue`. The function can optionally
assign the formatted arguments to the global environment and can load a
specified package before processing.

## Usage

``` r
function_arguments(function_name, assign = FALSE, package = NULL)
```

## Arguments

- function_name:

  A function whose arguments you want to print. Must be a valid R
  function.

- assign:

  Logical. Whether to assign the arguments as variables in the global
  environment. Defaults to `FALSE`.

- package:

  Character. Name of the R package to be loaded before processing the
  function. Default is `NULL`.

## Value

The function prints the formatted arguments to the console. If `assign`
is TRUE, it also assigns arguments to the global environment.

## Author

Ahmed El-Gabbas

## Examples

``` r
# loading packages
load_packages(dplyr, purrr)

# ---------------------------------------------
# using formals
# ---------------------------------------------
formals(stats::setNames)
#> $object
#> nm
#> 
#> $nm
#> 
#> 

# ---------------------------------------------
# no assignment
# ---------------------------------------------

function_arguments(stats::setNames)
#> object = NULL
#> nm = NULL

# objects were not assigned to the global environment
any(purrr::map_lgl(c("object", "nm"), exists))     # FALSE
#> [1] FALSE

# ---------------------------------------------
# with assignment
# ---------------------------------------------

# Example 1
function_arguments(stats::setNames, assign = TRUE)
#> object = NULL
#> nm = NULL

all(purrr::map_lgl(c("object", "nm"), exists))     # TRUE
#> [1] TRUE
object
#> NULL


# Example 2
function_arguments(get0, assign = TRUE)
#> x = NULL
#> envir = pos.to.env(-1L)
#> mode = "any"
#> inherits = TRUE
#> ifnotfound = NULL

c("x", "envir", "mode", "inherits", "ifnotfound") %>%
  purrr::map_lgl(exists) %>%
  all()                                            # TRUE
#> [1] TRUE
```
