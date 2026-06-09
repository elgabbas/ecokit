# Check whether an R package is installed

A small wrapper function to determine whether a package namespace can be
loaded via
[`base::requireNamespace()`](https://rdrr.io/r/base/ns-load.html)
without attaching the package.

## Usage

``` r
package_installed(package)
```

## Arguments

- package:

  Character scalar. Package name.

## Value

A logical scalar:

- `TRUE`: The package is installed and its namespace can be loaded.

- `FALSE`: The package is not installed or its namespace cannot be
  loaded.

## Details

The supplied package name is first validated to be a non-missing,
non-empty character scalar, then
[`base::requireNamespace()`](https://rdrr.io/r/base/ns-load.html) is
called with `quietly = TRUE`.

## Author

Ahmed El-Gabbas

## Examples

``` r
package_installed("stats")
#> [1] TRUE
package_installed("this_package_does_not_exist")
#> [1] FALSE
```
