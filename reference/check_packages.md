# Check Package Availability

Verifies that all specified packages are available in the current R
environment. If any packages are missing, the function throws an error
with a list of the missing packages.

## Usage

``` r
check_packages(packages = NULL, ...)
```

## Arguments

- packages:

  Character vector. Names of packages to check for availability. Default
  is `NULL`.

- ...:

  Additional arguments passed to
  [`stop_ctx()`](https://elgabbas.github.io/ecokit/reference/stop_ctx.md).

## Value

Invisibly returns `NULL` if all packages are available. Otherwise,
throws an error via
[`stop_ctx()`](https://elgabbas.github.io/ecokit/reference/stop_ctx.md).

## Details

The function uses
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html) with
`quietly = TRUE` to check if each package can be loaded. If one or more
packages are not available, an error message is generated listing all
missing packages.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Check if packages are available
check_packages(c("dplyr", "ggplot2"))

# Will throw an error if packages are missing
try(check_packages("nonexistent_package"))
#> Error in check_packages("nonexistent_package") : 
#>   The following required packages are missing: nonexistent_package. Please install them to proceed.
```
