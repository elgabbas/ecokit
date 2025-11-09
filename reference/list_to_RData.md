# Split list items into separate `.RData` files

This function takes a named list and saves each element of the list as a
separate `.RData` file. The names of the list elements are used as the
base for the filenames, optionally prefixed. Files are saved in the
specified directory, with an option to overwrite existing files.

## Usage

``` r
list_to_rdata(list, prefix = "", directory = getwd(), overwrite = FALSE)
```

## Arguments

- list:

  A named list object to be split into separate `.RData` files.

- prefix:

  Character. Prefix to each filename. If empty (default), no prefix is
  added.

- directory:

  The directory where the `.RData` files will be saved. Defaults to the
  current working directory.

- overwrite:

  A logical indicating whether to overwrite existing files. Defaults to
  `FALSE`, in which case files that already exist will not be
  overwritten, and a message will be printed for each such file.

## Value

The function is called for its side effect of saving files and does not
return a value.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(dplyr, fs)

# split iris data by species name
iris2 <- iris %>%
  tibble::tibble() %>%
  split(~Species)

str(iris2, 1)
#> List of 3
#>  $ setosa    : tibble [50 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ versicolor: tibble [50 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ virginica : tibble [50 × 5] (S3: tbl_df/tbl/data.frame)

# save each species as a separate RData file
temp_dir <- fs::path_temp("list_to_rdata")
fs::dir_create(temp_dir)
list.files(temp_dir)
#> character(0)

list_to_rdata(list = iris2, directory = temp_dir)
list.files(temp_dir)
#> [1] "setosa.RData"     "versicolor.RData" "virginica.RData" 

# loading data
setosa <- load_as(fs::path(temp_dir, "setosa.RData"))
str(setosa, 1)
#> tibble [50 × 5] (S3: tbl_df/tbl/data.frame)

versicolor <- load_as(fs::path(temp_dir, "versicolor.RData"))
str(versicolor, 1)
#> tibble [50 × 5] (S3: tbl_df/tbl/data.frame)

virginica <- load_as(fs::path(temp_dir, "virginica.RData"))
str(virginica, 1)
#> tibble [50 × 5] (S3: tbl_df/tbl/data.frame)

# load multiple files in a single R object
loaded_data <- load_multiple(
  files = fs::path(
  temp_dir, c("setosa.RData", "versicolor.RData", "virginica.RData")),
  verbose = TRUE)
#> Loading all objects as a single R object
#> Object:  setosa  was loaded successfully
#> Object:  versicolor  was loaded successfully
#> Object:  virginica  was loaded successfully
#> 
str(loaded_data, 1)
#> List of 3
#>  $ setosa    : tibble [50 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ versicolor: tibble [50 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ virginica : tibble [50 × 5] (S3: tbl_df/tbl/data.frame)

# clean up
fs::dir_delete(temp_dir)
```
