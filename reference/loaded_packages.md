# List of loaded packages

This function returns a character vector listing all the packages that
are currently loaded in the R session.

## Usage

``` r
loaded_packages()
```

## Value

A character vector containing the names of all loaded packages.

## Examples

``` r
loaded_packages()
#>  [1] "scales"    "lubridate" "tidyterra" "nnet"      "qs2"       "stringr"  
#>  [7] "purrr"     "tools"     "future"    "car"       "carData"   "rworldmap"
#> [13] "arrow"     "dismo"     "raster"    "sp"        "terra"     "fs"       
#> [19] "tidyr"     "tibble"    "png"       "sf"        "ggplot2"   "dplyr"    
#> [25] "ecokit"    "magrittr"  "stats"     "graphics"  "grDevices" "utils"    
#> [31] "datasets"  "methods"   "base"     

load_packages(tidyterra, lubridate, nngeo)

loaded_packages()
#>  [1] "nngeo"     "scales"    "lubridate" "tidyterra" "nnet"      "qs2"      
#>  [7] "stringr"   "purrr"     "tools"     "future"    "car"       "carData"  
#> [13] "rworldmap" "arrow"     "dismo"     "raster"    "sp"        "terra"    
#> [19] "fs"        "tidyr"     "tibble"    "png"       "sf"        "ggplot2"  
#> [25] "dplyr"     "ecokit"    "magrittr"  "stats"     "graphics"  "grDevices"
#> [31] "utils"     "datasets"  "methods"   "base"     
```
