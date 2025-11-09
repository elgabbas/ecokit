# Load or install multiple R packages

This function attempts to load multiple R packages specified by the
user. If a package is not installed, the function can optionally install
it before loading. It also provides an option to print the names and
versions of the loaded packages.

## Usage

``` r
load_packages(
  ...,
  package_list = NULL,
  verbose = FALSE,
  install_missing = FALSE,
  n_cpus = getOption("Ncpus", 1L)
)
```

## Arguments

- ...:

  Character. Names of the packages to be loaded or installed.

- package_list:

  Character vector. An alternative or additional way to specify package
  names as a vector.

- verbose:

  Logical. If `TRUE`, prints the names and versions of the loaded
  packages. Defaults to `FALSE`.

- install_missing:

  Logical. If `TRUE`, missing packages are automatically installed and
  then loaded. Defaults to `FALSE`.

- n_cpus:

  Integer. Number of CPUs to use for parallel installation of packages.
  Defaults to the value of the `Ncpus` option. This is only valid if
  `install_missing` is `TRUE`.

## Value

This function is used for its side effects (loading/installing packages)
and does not return any value.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Currently loaded packages
(P1 <- ecokit::loaded_packages())
#>  [1] "qs2"       "stringr"   "purrr"     "tools"     "future"    "car"      
#>  [7] "carData"   "rworldmap" "arrow"     "dismo"     "raster"    "sp"       
#> [13] "terra"     "fs"        "tidyr"     "tibble"    "png"       "sf"       
#> [19] "ggplot2"   "dplyr"     "ecokit"    "magrittr"  "stats"     "graphics" 
#> [25] "grDevices" "utils"     "datasets"  "methods"   "base"     

# Load tidyr
load_packages(tidyr, raster, ggplot2, nnet, verbose = TRUE)
#> The following packages were already loaded:
#>   >>>>  ggplot2 (4.0.0)
#>   >>>>  raster (3.6-32)
#>   >>>>  tidyr (1.3.1)
#> Loading packages:
#>   >>>>  nnet (7.3-20)

# Loaded packages after implementing the function
(P2 <- ecokit::loaded_packages())
#>  [1] "nnet"      "qs2"       "stringr"   "purrr"     "tools"     "future"   
#>  [7] "car"       "carData"   "rworldmap" "arrow"     "dismo"     "raster"   
#> [13] "sp"        "terra"     "fs"        "tidyr"     "tibble"    "png"      
#> [19] "sf"        "ggplot2"   "dplyr"     "ecokit"    "magrittr"  "stats"    
#> [25] "graphics"  "grDevices" "utils"     "datasets"  "methods"   "base"     

# Which packages were loaded?
setdiff(P2, P1)
#> [1] "nnet"

# verbose = FALSE (default)
load_packages(tidyterra, verbose = FALSE)

# load already loaded packages
load_packages(tidyr, tidyterra, verbose = TRUE)
#> The following packages were already loaded:
#>   >>>>  tidyr (1.3.1)
#>   >>>>  tidyterra (0.7.2)

# non-existent package
load_packages("non_existent")
#> The following packages are neither available nor installed as install_missing = FALSE:
#>   >>>>   non_existent
```
