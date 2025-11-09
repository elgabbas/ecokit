# Load objects from `RData` / `qs2` / `rds` / `feather` file

This function loads an `RData` file specified by the `file` parameter.
If the `RData` file contains a single object, that object is returned
directly. If the file contains multiple objects, they are returned as a
list with each object accessible by its name. This allows for flexible
handling of loaded data without needing to know the names of the objects
stored within the RData file ahead of time. The function also supports
loading `feather`, `qs2` and `rds` files.

## Usage

``` r
load_as(
  file = NULL,
  n_threads = 1L,
  timeout = 300L,
  load_packages = TRUE,
  unwrap_r = FALSE,
  ...
)
```

## Arguments

- file:

  Character. the file path or URL of the file to be loaded. If `file` is
  a URL, the function will download the file from the URL to a temporary
  file and load it.

- n_threads:

  Number of threads to use when reading `qs2` files. See
  [qs2::qs_read](https://rdrr.io/pkg/qs2/man/qs_read.html).

- timeout:

  integer; time in seconds before the download times out. Default 300
  seconds; see
  [download.file](https://rdrr.io/r/utils/download.file.html).

- load_packages:

  Logical. If TRUE (default), attempt to load R packages that correspond
  to the main classes of the loaded object(s).

- unwrap_r:

  Logical. If TRUE, and the loaded object is a `PackedSpatRaster` or
  `PackedSpatVector`, it will be unwrapped using
  [terra::unwrap](https://rspatial.github.io/terra/reference/wrap.html).

- ...:

  Additional arguments to be passed to the respective load functions.
  [base::load](https://rdrr.io/r/base/load.html) for `RData` files;
  [qs2::qs_read](https://rdrr.io/pkg/qs2/man/qs_read.html) for `qs2`
  files;
  [arrow::read_feather](https://arrow.apache.org/docs/r/reference/read_feather.html)
  for `feather` files; and
  [base::readRDS](https://rdrr.io/r/base/readRDS.html) for `rds` files.

## Value

Depending on the contents of the `RData` file, this function returns
either a single R object or a named list of R objects. The names of the
list elements (if a list is returned) correspond to the names of the
objects stored within the `RData` file.

## Author

Ahmed El-Gabbas

## Examples

``` r
file <- system.file("testdata", "culcita_dat.RData", package = "lme4")

# ---------------------------------------------------------
# loading RData using base::load
# ---------------------------------------------------------

(load(file))
#> [1] "culcita_dat"

ls()
#> [1] "culcita_dat" "file"       

tibble::tibble(culcita_dat)
#> # A tibble: 80 × 3
#>    block predation ttt  
#>    <fct>     <dbl> <fct>
#>  1 1             0 none 
#>  2 1             1 none 
#>  3 2             1 none 
#>  4 2             1 none 
#>  5 3             1 none 
#>  6 3             1 none 
#>  7 4             1 none 
#>  8 4             1 none 
#>  9 5             1 none 
#> 10 5             1 none 
#> # ℹ 70 more rows

# ---------------------------------------------------------
# Loading as custom object name
# ---------------------------------------------------------

NewObj <- load_as(file = file)

ls()
#> [1] "NewObj"      "culcita_dat" "file"       

print(tibble::tibble(NewObj))
#> # A tibble: 80 × 3
#>    block predation ttt  
#>    <fct>     <dbl> <fct>
#>  1 1             0 none 
#>  2 1             1 none 
#>  3 2             1 none 
#>  4 2             1 none 
#>  5 3             1 none 
#>  6 3             1 none 
#>  7 4             1 none 
#>  8 4             1 none 
#>  9 5             1 none 
#> 10 5             1 none 
#> # ℹ 70 more rows

# ---------------------------------------------------------
# Loading multiple objects stored in single RData file
# ---------------------------------------------------------

# store three objects to single RData file
mtcars2 <- mtcars3 <- mtcars

# save in the order of mtcars2, mtcars3, mtcars
TempFile_1 <- tempfile(pattern = "mtcars_", fileext = ".RData")
save(mtcars2, mtcars3, mtcars, file = TempFile_1)

# save in another order: mtcars, mtcars2, mtcars3
TempFile_2 <- tempfile(pattern = "mtcars_", fileext = ".RData")
save(mtcars, mtcars2, mtcars3, file = TempFile_2)

# loading as a single list  with 3 items, keeping original order
mtcars_all_1 <- load_as(TempFile_1)
str(mtcars_all_1, 1)
#> List of 3
#>  $ mtcars2:'data.frame': 32 obs. of  11 variables:
#>  $ mtcars3:'data.frame': 32 obs. of  11 variables:
#>  $ mtcars :'data.frame': 32 obs. of  11 variables:

mtcars_all_2 <- load_as(TempFile_2)
str(mtcars_all_2, 1)
#> List of 3
#>  $ mtcars :'data.frame': 32 obs. of  11 variables:
#>  $ mtcars2:'data.frame': 32 obs. of  11 variables:
#>  $ mtcars3:'data.frame': 32 obs. of  11 variables:
```
