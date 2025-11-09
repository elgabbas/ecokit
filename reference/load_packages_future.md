# Prepare Packages for Parallel Processing with Future

Prepares a list of packages for use in parallel processing with the
`future` package, determining whether to load packages in the main
process or pass them to parallel workers based on the specified `future`
strategy. This function is designed to minimize package-loading messages
in SLURM environments, especially for `multicore`.

## Usage

``` r
load_packages_future(packages = character(), strategy = "multisession")
```

## Arguments

- packages:

  Character vector of package names to load, or `NULL` to indicate no
  packages are needed (returns `NULL`).

- strategy:

  Character. The parallel processing strategy to use. Valid options are
  "sequential", "multisession" (default), "multicore", and "cluster".
  See
  [`future::plan()`](https://future.futureverse.org/reference/plan.html).

## Value

A value depending on `strategy`:

- `sequential`: `NULL` (no workers; packages not loaded).

- `multicore` (non-Windows): `NULL` (packages loaded in the main
  process, inherited by forks).

- `multicore` (Windows), `multisession`, or `cluster`: `packages`
  (character vector of package names to load in workers, e.g., via
  `future.packages`).

- If `packages` is `NULL`: `NULL` (no packages to load).

## Details

This function helps manage package loading for parallel processing with
the `future` package. It ensures efficient package handling and
minimizes package-loading messages in SLURM environments, particularly
for `multicore` on non-Windows systems, where packages are loaded in the
main process to avoid redundant messages in worker forks. For
`multisession`, `cluster`, or `multicore` on Windows (where `multicore`
falls back to `multisession`), it returns the package names for loading
in workers, typically via the `future.packages` argument in functions
like
[`future.apply::future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html).

## Author

Ahmed El-Gabbas

## Examples

``` r
(pkg_init <- loaded_packages())
#>  [1] "tidyterra" "nnet"      "qs2"       "stringr"   "purrr"     "tools"    
#>  [7] "future"    "car"       "carData"   "rworldmap" "arrow"     "dismo"    
#> [13] "raster"    "sp"        "terra"     "fs"        "tidyr"     "tibble"   
#> [19] "png"       "sf"        "ggplot2"   "dplyr"     "ecokit"    "magrittr" 
#> [25] "stats"     "graphics"  "grDevices" "utils"     "datasets"  "methods"  
#> [31] "base"     
pkg_to_load <- c("tidyterra", "lubridate", "tidyr", "sf", "scales")

# sequential
load_packages_future(pkg_to_load, "sequential")
#> NULL
setdiff(loaded_packages(), pkg_init)
#> character(0)

# multisession
load_packages_future(pkg_to_load, "multisession")
#> [1] "tidyterra" "lubridate" "tidyr"     "sf"        "scales"   
setdiff(loaded_packages(), pkg_init)
#> character(0)

# multicore
load_packages_future(pkg_to_load, "multicore")
#> NULL
setdiff(loaded_packages(), pkg_init)
#> [1] "scales"    "lubridate"
```
