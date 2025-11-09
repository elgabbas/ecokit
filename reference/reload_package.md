# Reload an R package

Reloads one or more specified R packages. If a package is not loaded, it
is loaded; if already loaded, it is detached and reloaded from its
library location.

## Usage

``` r
reload_package(...)
```

## Arguments

- ...:

  Unquoted package names (e.g., `sf`, `ncdf4`). Must be installed
  packages. Multiple packages can be specified.

## Value

Returns `invisible(NULL)`. The function is used for its side effect of
reloading a package rather than for its return value.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(nngeo)

# Reloads nngeo; terra0 does not exist
reload_package(nngeo, terra0)
#> Reloading 'nngeo'
#> Not installed: terra0
```
