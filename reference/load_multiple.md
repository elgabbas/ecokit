# Load multiple data files together

This function loads multiple data files either into a single list object
or directly into the specified environment. It provides options for
verbosity, returning object names, and handling of non-existent files.
Supported data files include: `.RData`, `.rds`, `.qs2`, and `.feather`.

## Usage

``` r
load_multiple(
  files = NULL,
  verbose = TRUE,
  single_object = TRUE,
  return_names = TRUE,
  n_threads = 1L,
  conflict = c("skip", "overwrite", "rename"),
  environment = .GlobalEnv
)
```

## Arguments

- files:

  Character vector. Paths to `.RData`, `.rds`, `.qs2`, or `.feather`
  files to be loaded.

- verbose:

  Logical. Whether to print progress messages. Default: `TRUE`.

- single_object:

  Logical. Whether to load all objects into a single list (`TRUE`) or
  directly into the specified environment (`FALSE`). Defaults to `TRUE`.

- return_names:

  Logical. Whether to return the names of the loaded objects. Defaults
  to `TRUE`. Only effective when `single_object` is `FALSE`.

- n_threads:

  Integer. Number of threads for reading `.qs2` files. Must be a
  positive integer. See
  [qs2::qs_read](https://rdrr.io/pkg/qs2/man/qs_read.html) and
  [load_as](https://elgabbas.github.io/ecokit/reference/load_as.md) for
  more details.

- conflict:

  Character. Strategy for handling naming conflicts when
  `single_object = FALSE`: `"skip"` (default, skip conflicting files),
  `"overwrite"` (replace existing objects), or `"rename"` (append a
  suffix to new objects).

- environment:

  Environment. The environment where objects are loaded when
  `single_object` is `FALSE`. Defaults to `.GlobalEnv`.

## Value

If `single_object` is `TRUE`, returns a named list of objects loaded
from the specified files (with `NULL` for failed loads). If
`single_object` is `FALSE` and `return_names` is `TRUE`, returns a
character vector of the names of the objects loaded into the
environment. Otherwise, returns `NULL`.

## Note

For `.RData` files containing multiple objects, the function loads each
object individually and applies the `conflict` strategy to each.
Non-conflicting objects retain their original names in `rename` mode.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(qs2, arrow, fs, terra, dplyr)

# ---------------------------------------------------
# Create sample data files
# ---------------------------------------------------

# Setup temporary directory
temp_dir <- fs::path_temp("load_multiple")
fs::dir_create(temp_dir)

# Create sample data files
data1 <- terra::wrap(terra::rast(matrix(1:16, nrow = 4)))
data2 <- matrix(1:9, nrow = 3)
data3 <- list(a = 1:10, b = letters[1:5])
data4 <- data.frame(x = 1:5)

save(data1, file = fs::path(temp_dir, "data1.RData"))
saveRDS(data2, file = fs::path(temp_dir, "data2.rds"))
qs2::qs_save(data3, file = fs::path(temp_dir, "data3.qs2"), nthreads = 1)
arrow::write_feather(
  as.data.frame(data4), sink = fs::path(temp_dir, "data4.feather"))

files <- fs::path(
  temp_dir, c("data1.RData", "data2.rds", "data3.qs2", "data4.feather"))
basename(files)
#> [1] "data1.RData"   "data2.rds"     "data3.qs2"     "data4.feather"

# Create a specific environment for examples
example_env <- new.env()

# ---------------------------------------------------
# Load mixed data files to one list object
# `single_object = TRUE`
# ---------------------------------------------------

MultiObj <- load_multiple(files = files, single_object = TRUE, n_threads = 1)
#> Loading all objects as a single R object
#> Object:  data1  was loaded successfully
#> Object:  data2  was loaded successfully
#> Object:  data3  was loaded successfully
#> Object:  data4  was loaded successfully
#> 
str(MultiObj, 1)
#> List of 4
#>  $ data1:Formal class 'PackedSpatRaster' [package "terra"] with 3 slots
#>  $ data2: int [1:3, 1:3] 1 2 3 4 5 6 7 8 9
#>  $ data3:List of 2
#>  $ data4: tibble [5 × 1] (S3: tbl_df/tbl/data.frame)

# ---------------------------------------------------
# Load mixed data files separately to the specific environment
# `single_object = FALSE`, skip conflicts
# ---------------------------------------------------

# Remove any existing objects in example_env
rm(list = ls(envir = example_env), envir = example_env)

# Create conflicting object in example_env
assign("data2", "conflict", envir = example_env)
load_multiple(
  files = files, single_object = FALSE, conflict = "skip",
  environment = example_env, n_threads = 1)
#> Loading all objects separately 
#> Object data1 was loaded successfully from file data1.RData
#> Object data2 exists; skipped from file data2.rds
#> Object data3 was loaded successfully from file data3.qs2
#> Object data4 was loaded successfully from file data4.feather
#> 
#> [1] "data1" "data3" "data4"
ls(envir = example_env)
#> [1] "data1" "data2" "data3" "data4"

str(get("data1", envir = example_env), 1)
#> Formal class 'PackedSpatRaster' [package "terra"] with 3 slots
str(get("data2", envir = example_env), 1)
#>  chr "conflict"
str(get("data3", envir = example_env), 1)
#> List of 2
#>  $ a: int [1:10] 1 2 3 4 5 6 7 8 9 10
#>  $ b: chr [1:5] "a" "b" "c" "d" ...
str(get("data4", envir = example_env), 1)
#> tibble [5 × 1] (S3: tbl_df/tbl/data.frame)

# ---------------------------------------------------
# Load mixed data files, overwrite conflicts
# `single_object = FALSE`, overwrite
# ---------------------------------------------------

# Remove specific objects from example_env
rm(list = c("data1", "data3", "data4"), envir = example_env)
ls(envir = example_env)
#> [1] "data2"

load_multiple(
  files = files, single_object = FALSE, conflict = "overwrite",
  environment = example_env, n_threads = 1)
#> Loading all objects separately 
#> Object:  data1  was loaded successfully
#> Object:  data2  already exists and overwritten
#> Object:  data3  was loaded successfully
#> Object:  data4  was loaded successfully
#> 
#> [1] "data1" "data2" "data3" "data4"
ls(envir = example_env)
#> [1] "data1" "data2" "data3" "data4"

str(get("data1", envir = example_env), 1)
#> Formal class 'PackedSpatRaster' [package "terra"] with 3 slots
str(get("data2", envir = example_env), 1)
#>  int [1:3, 1:3] 1 2 3 4 5 6 7 8 9
str(get("data3", envir = example_env), 1)
#> List of 2
#>  $ a: int [1:10] 1 2 3 4 5 6 7 8 9 10
#>  $ b: chr [1:5] "a" "b" "c" "d" ...
str(get("data4", envir = example_env), 1)
#> tibble [5 × 1] (S3: tbl_df/tbl/data.frame)

# ---------------------------------------------------
# Load mixed data files, rename conflicts
# `single_object = FALSE`, rename
# ---------------------------------------------------

# Remove specific objects from example_env
rm(list = c("data1", "data3", "data4"), envir = example_env)
ls(envir = example_env)
#> [1] "data2"

# Create conflicting object in example_env
assign("data2", 1:10, envir = example_env)

load_multiple(
  files = files, single_object = FALSE, conflict = "rename",
  environment = example_env, n_threads = 1)
#> Loading all objects separately 
#> Object:  data1  was loaded successfully
#> Object:  data2  exists; loaded as  data2_new 
#> Object:  data3  was loaded successfully
#> Object:  data4  was loaded successfully
#> 
#> [1] "data1"     "data2_new" "data3"     "data4"    
ls(envir = example_env)
#> [1] "data1"     "data2"     "data2_new" "data3"     "data4"    

str(get("data1", envir = example_env), 1)
#> Formal class 'PackedSpatRaster' [package "terra"] with 3 slots
str(get("data2", envir = example_env), 1)
#>  int [1:10] 1 2 3 4 5 6 7 8 9 10
str(get("data2_new", envir = example_env), 1)
#>  int [1:3, 1:3] 1 2 3 4 5 6 7 8 9
str(get("data3", envir = example_env), 1)
#> List of 2
#>  $ a: int [1:10] 1 2 3 4 5 6 7 8 9 10
#>  $ b: chr [1:5] "a" "b" "c" "d" ...
str(get("data4", envir = example_env), 1)
#> tibble [5 × 1] (S3: tbl_df/tbl/data.frame)

# Clean up
fs::file_delete(files)
fs::dir_delete(temp_dir)
rm(example_env)
```
