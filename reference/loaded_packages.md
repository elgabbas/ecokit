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
#> [13] "Hmsc"      "coda"      "rworldmap" "arrow"     "dismo"     "raster"   
#> [19] "sp"        "terra"     "fs"        "tidyr"     "tibble"    "png"      
#> [25] "sf"        "ggplot2"   "dplyr"     "ecokit"    "magrittr"  "stats"    
#> [31] "graphics"  "grDevices" "utils"     "datasets"  "methods"   "base"     

load_packages(tidyterra, lubridate, nngeo)

loaded_packages()
#>  [1] "nngeo"     "scales"    "lubridate" "tidyterra" "nnet"      "qs2"      
#>  [7] "stringr"   "tools"     "future"    "car"       "carData"   "purrr"    
#> [13] "archive"   "Hmsc"      "coda"      "rworldmap" "arrow"     "dismo"    
#> [19] "raster"    "sp"        "terra"     "fs"        "tidyr"     "tibble"   
#> [25] "png"       "sf"        "ggplot2"   "dplyr"     "ecokit"    "magrittr" 
#> [31] "stats"     "graphics"  "grDevices" "utils"     "datasets"  "methods"  
#> [37] "base"     
```
