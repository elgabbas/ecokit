# Apply a function over a list or vector with optional silence

Wrapper functions around the base
[base::lapply](https://rdrr.io/r/base/lapply.html) and
[base::sapply](https://rdrr.io/r/base/lapply.html) functions that allow
for the application of a function over a list or vector. It extends
original functions by providing an option to suppress the output,
effectively allowing for operations where the user may not care about
the return value (e.g., plotting). This behaviour is similar to the
[purrr::walk](https://purrr.tidyverse.org/reference/map.html) function.

## Usage

``` r
lapply_(x, fun, silent = TRUE, ...)

sapply_(x, fun, simplify = TRUE, silent = TRUE, ...)
```

## Arguments

- x:

  a vector (atomic or list) or an expression object. Other objects
  (including classed objects) will be coerced by
  [base::as.list](https://rdrr.io/r/base/list.html).

- fun:

  the function to be applied to each element of x. In the case of
  functions like +, %\*%, the function name must be backquoted or
  quoted.

- silent:

  A logical value. If `TRUE`, the function suppresses the return value
  of `fun` and returns `NULL` invisibly. If `FALSE`, the function
  returns the result of applying `fun` over `X`.

- ...:

  Additional arguments to be passed to `fun`.

- simplify:

  Logical or character string; should the result be simplified to a
  vector, matrix or higher dimensional array if possible?

## Value

If `silent` is `TRUE`, returns `NULL` invisibly, otherwise returns a
list of the same length as `x`, where each element is the result of
applying `fun` to the corresponding element of `x`.

## Author

Ahmed El-Gabbas

## Examples

``` r
par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
lapply(list(x = 100:110, y = 110:120), function(V) {
    plot(V, las = 1, main = "lapply")
})

#> $x
#> NULL
#> 
#> $y
#> NULL
#> 

# -------------------------------------------

par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
lapply_(list(x = 100:110, y = 110:120), function(V) {
    plot(V, las = 1, main = "lapply_")
})


# -------------------------------------------

#' par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
sapply(
    list(x = 100:110, y = 110:120),
    function(V) {
        plot(V, las = 1, main = "sapply")
        })

#> $x
#> NULL
#> 
#> $y
#> NULL
#> 

# -------------------------------------------

# nothing returned or printed, only the plotting
par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
sapply_(
  list(x = 100:110, y = 110:120),
  function(V) {
    plot(V, las = 1, main = "sapply_")
    })
```
