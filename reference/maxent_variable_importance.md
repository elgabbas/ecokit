# Extract Variable Importance from a Maxent Model Object

This function extracts the percent contribution and permutation
importance for each variable from a fitted Maxent model (class "MaxEnt")
as returned by
[`dismo::maxent()`](https://rdrr.io/pkg/dismo/man/maxent.html). It
returns a tibble with variables and their respective importance metrics.

## Usage

``` r
maxent_variable_importance(model = NULL)
```

## Arguments

- model:

  A fitted Maxent model object of class "MaxEnt" (from
  [`dismo::maxent()`](https://rdrr.io/pkg/dismo/man/maxent.html).

## Value

A tibble with columns:

- variable:

  Variable name (character).

- percent_contribution:

  Percent contribution of the variable (numeric).

- permutation_importance:

  Permutation importance of the variable (numeric).

## Author

Ahmed El-Gabbas

## Examples

``` r
require(ecokit)
ecokit::load_packages(fs, dismo, rJava, raster)

# fit a Maxent model
if (dismo::maxent(silent = TRUE)) {
  predictors <- list.files(
    path = fs::path(
      system.file(package = "dismo"), "ex"),
    pattern = "grd", full.names = TRUE) %>%
    raster::stack()

  occurence <- fs::path(
    system.file(package = "dismo"), "ex", "bradypus.csv") %>%
    read.table(header = TRUE, sep = ",") %>%
    dplyr::select(-1)
  # fit model, biome is a categorical variable
  me <- maxent(predictors, occurence, factors='biome')

  maxent_variable_importance(me)
}
#> # A tibble: 9 × 3
#>   variable percent_contribution permutation_importance
#>   <chr>                   <dbl>                  <dbl>
#> 1 bio1                    2.89                    2.50
#> 2 bio12                   1.69                   10.8 
#> 3 bio16                  10.1                     1.33
#> 4 bio17                   3.57                    3.44
#> 5 bio5                    3.53                    5.27
#> 6 bio6                    3.00                    3.82
#> 7 bio7                   28.2                    59.6 
#> 8 bio8                    0.303                   2.94
#> 9 biome                  46.8                    10.3 
```
