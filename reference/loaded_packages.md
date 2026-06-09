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
#>  [7] "tools"     "future"    "car"       "carData"   "purrr"     "archive"  
#> [13] "rworldmap" "arrow"     "dismo"     "raster"    "sp"        "terra"    
#> [19] "fs"        "tidyr"     "tibble"    "png"       "sf"        "ggplot2"  
#> [25] "dplyr"     "ecokit"    "magrittr"  "stats"     "graphics"  "grDevices"
#> [31] "utils"     "datasets"  "methods"   "base"     

load_packages(tidyterra, lubridate, nngeo)

loaded_packages()
#>  [1] "nngeo"     "scales"    "lubridate" "tidyterra" "nnet"      "qs2"      
#>  [7] "stringr"   "tools"     "future"    "car"       "carData"   "purrr"    
#> [13] "archive"   "rworldmap" "arrow"     "dismo"     "raster"    "sp"       
#> [19] "terra"     "fs"        "tidyr"     "tibble"    "png"       "sf"       
#> [25] "ggplot2"   "dplyr"     "ecokit"    "magrittr"  "stats"     "graphics" 
#> [31] "grDevices" "utils"     "datasets"  "methods"   "base"     
```
