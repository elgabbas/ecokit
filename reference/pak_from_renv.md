# Extract Installable Package References from renv.lock for Use with pak

This function parses a given `renv.lock` file and extracts all package
references that can be directly installed using the `pak` package
[pak::pkg_install](https://pak.r-lib.org/reference/pkg_install.html). It
supports a wide range of repositories, including CRAN, Bioconductor,
GitHub, GitLab, Bitbucket, and other common remote sources, as well as
tarball URLs. The function returns a list of multiple character vectors:

- `pak`: installable references for `pak` (CRAN/BioC only, no remotes)

- `tarballs`: package references for tarball URLs, formatted for pak as
  `pkg=url::https://...` if the package name is known, or just
  `url::https://...` if not.

- `remote`: GitHub/GitLab/Bitbucket package references, formatted for
  pak as `github::user/repo`, `gitlab::user/repo`, or
  `bitbucket::user/repo` (or, if the package name differs from the repo,
  as `pkg=github::user/repo` etc.).

## Usage

``` r
pak_from_renv(lockfile)
```

## Arguments

- lockfile:

  Path to the `renv.lock` file (JSON format).

## Value

A list with the following elements:

- pak:

  Character vector of installable references for `pak` (CRAN/BioC only)

- tarballs:

  Character vector of tarball URLs in pak syntax (see Details)

- remote:

  Character vector of all remote package references in pak syntax

## Details

These lists allow you to separately process packages by source, or
install GitHub/GitLab/Bitbucket packages without strict
versioning/commit, which can sometimes help avoid dependency resolution
conflicts in pak (and other tools). Tarball URLs are provided in a
pak-compatible format.

[`renv`](https://rstudio.github.io/renv/index.html) is a popular R
package for project-local dependency management, creating lock files
(`renv.lock`) to ensure reproducible environments.
[`pak`](https://pak.r-lib.org/) is a fast, parallel package installer
that works with CRAN, GitHub, Bioconductor, and other sources, but does
not natively install from `renv.lock`. This function bridges the gap,
enabling fast, parallel installation of all packages specified in a
lockfile using `pak`, and allows you to reuse `pak`'s cache with
renv::restore for speed and reliability.

The function is used to extract a complete list of installable
references from any `renv.lock` for rapid, parallel installation via
`pak`. After installing with
[pak::pkg_install](https://pak.r-lib.org/reference/pkg_install.html),
you can run renv::restore to link cached packages, ensuring a
reproducible environment with minimal download time.

In addition to the main installable references, the function outputs a
separate list for all remotes (GitHub, GitLab, Bitbucket) in
pak-compatible syntax, and a tarballs list in pak-compatible syntax
(`url::` or `pkg=url::...`).

## See also

[`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html),
`renv::restore()`,
[`remotes::install_url()`](https://remotes.r-lib.org/reference/install_url.html)

## Author

Ahmed El-Gabbas

## Examples

``` r
lock_path <- file.path(
    "https://raw.githubusercontent.com/cosname/",
    "rmarkdown-guide/master/renv.lock")

(pak_packages <- pak_from_renv(lockfile = lock_path))
#> $pak
#>   [1] "DBI@1.1.2"               "DiagrammeR@1.0.9"       
#>   [3] "MASS@7.3-57"             "Matrix@1.4-1"           
#>   [5] "R6@2.5.1"                "RColorBrewer@1.1-3"     
#>   [7] "RSQLite@2.2.13"          "Rcpp@1.0.8.3"           
#>   [9] "RcppTOML@0.1.7"          "askpass@1.1"            
#>  [11] "assertthat@0.2.1"        "babynames@1.0.1"        
#>  [13] "base64enc@0.1-3"         "bit64@4.0.5"            
#>  [15] "bit@4.0.4"               "blob@1.2.3"             
#>  [17] "bookdown@0.26"           "brio@1.1.3"             
#>  [19] "bslib@0.3.1"             "cachem@1.0.6"           
#>  [21] "callr@3.7.0"             "cli@3.3.0"              
#>  [23] "clipr@0.8.0"             "colorspace@2.0-3"       
#>  [25] "commonmark@1.8.0"        "cpp11@0.4.2"            
#>  [27] "crayon@1.5.1"            "crosstalk@1.2.0"        
#>  [29] "curl@4.3.2"              "desc@1.4.1"             
#>  [31] "diffobj@0.3.5"           "digest@0.6.29"          
#>  [33] "distill@1.3"             "downlit@0.4.0"          
#>  [35] "downloader@0.4"          "dplyr@1.0.9"            
#>  [37] "dygraphs@1.1.1.6"        "ellipsis@0.3.2"         
#>  [39] "evaluate@0.15"           "fansi@1.0.3"            
#>  [41] "farver@2.1.0"            "fastmap@1.1.0"          
#>  [43] "filehash@2.4-3"          "flexdashboard@0.5.2"    
#>  [45] "fontawesome@0.2.2"       "formatR@1.12"           
#>  [47] "fs@1.5.2"                "gdtools@0.2.4"          
#>  [49] "generics@0.1.2"          "ggplot2@3.3.5"          
#>  [51] "ggrepel@0.9.1"           "gifski@1.6.6-1"         
#>  [53] "glue@1.6.2"              "gridExtra@2.3"          
#>  [55] "gtable@0.3.0"            "here@1.0.1"             
#>  [57] "highr@0.9"               "hms@1.1.1"              
#>  [59] "htmltools@0.5.2"         "htmlwidgets@1.5.4"      
#>  [61] "httpuv@1.6.5"            "httr@1.4.3"             
#>  [63] "huxtable@5.4.0"          "igraph@1.3.1"           
#>  [65] "influenceR@0.1.0.1"      "isoband@0.2.5"          
#>  [67] "jquerylib@0.1.4"         "jsonlite@1.8.0"         
#>  [69] "kableExtra@1.3.4"        "knitr@1.39"             
#>  [71] "labeling@0.4.2"          "later@1.3.0"            
#>  [73] "lattice@0.20-45"         "lazyeval@0.2.2"         
#>  [75] "leaflet.providers@1.9.0" "leaflet@2.1.1"          
#>  [77] "lifecycle@1.0.1"         "lubridate@1.8.0"        
#>  [79] "magick@2.7.3"            "magrittr@2.0.3"         
#>  [81] "markdown@1.3"            "memoise@2.0.1"          
#>  [83] "mgcv@1.8-40"             "mime@0.12"              
#>  [85] "munsell@0.5.0"           "nlme@3.1-157"           
#>  [87] "officedown@0.2.4"        "officer@0.4.4"          
#>  [89] "openssl@2.0.4"           "pillar@1.7.0"           
#>  [91] "pkgconfig@2.0.3"         "pkgload@1.2.4"          
#>  [93] "plogr@0.2.0"             "png@0.1-7"              
#>  [95] "praise@1.0.0"            "prettydoc@0.4.1"        
#>  [97] "prettyunits@1.1.1"       "processx@3.6.0"         
#>  [99] "progress@1.2.2"          "promises@1.2.0.1"       
#> [101] "ps@1.7.0"                "purrr@0.3.4"            
#> [103] "r2d3@0.2.6"              "rappdirs@0.3.3"         
#> [105] "raster@3.5-15"           "readr@2.1.2"            
#> [107] "rematch2@2.1.2"          "renv@0.15.4"            
#> [109] "reticulate@1.24"         "rgl@0.108.3"            
#> [111] "rlang@1.0.6"             "rmarkdown@2.14"         
#> [113] "rprojroot@2.0.3"         "rstudioapi@0.13"        
#> [115] "rticles@0.23"            "rvest@1.0.2"            
#> [117] "rvg@0.2.5"               "sass@0.4.1"             
#> [119] "scales@1.2.0"            "selectr@0.4-2"          
#> [121] "servr@0.24"              "shiny@1.7.1"            
#> [123] "sourcetools@0.1.7"       "sp@1.4-7"               
#> [125] "stringi@1.7.6"           "stringr@1.4.0"          
#> [127] "svglite@2.1.0"           "sys@3.4"                
#> [129] "systemfonts@1.0.4"       "terra@1.5-21"           
#> [131] "testthat@3.1.4"          "tibble@3.1.7"           
#> [133] "tidyr@1.2.0"             "tidyselect@1.1.2"       
#> [135] "tikzDevice@0.12.3.1"     "tinytex@0.39"           
#> [137] "tufte@0.12"              "tzdb@0.3.0"             
#> [139] "utf8@1.2.2"              "uuid@1.1-0"             
#> [141] "vctrs@0.4.1"             "viridis@0.6.2"          
#> [143] "viridisLite@0.4.0"       "visNetwork@2.1.0"       
#> [145] "vroom@1.5.7"             "waldo@0.4.0"            
#> [147] "webshot@0.5.3"           "whisker@0.4"            
#> [149] "withr@2.5.0"             "xaringan@0.24"          
#> [151] "xaringanExtra@0.7.0"     "xfun@0.31"              
#> [153] "xml2@1.3.3"              "xtable@1.8-4"           
#> [155] "xts@0.12.1"              "yaml@2.3.5"             
#> [157] "zip@2.2.0"               "zoo@1.8-10"             
#> 
#> $tarballs
#> character(0)
#> 
#> $remote
#> character(0)
#> 

# Install packages using pak
# pak::pak_install(pak_packages$pak)

# Install all remote packages (latest HEAD, no SHA)
# pak::pak_install(pak_packages$remote)

# Install tarballs
# pak::pak_install(pak_packages$tarballs)
```
