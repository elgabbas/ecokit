# Save multiple objects to their respective `.RData` files

This function saves specified variables from the global environment to
separate `.RData` files. It allows for optional file prefixing and
overwriting of existing files.

## Usage

``` r
save_multiple(
  variables = NULL,
  out_directory = getwd(),
  overwrite = FALSE,
  prefix = "",
  verbose = FALSE
)
```

## Arguments

- variables:

  Character vector. Names of the variables to be saved. If `NULL` or any
  specified variable does not exist in the global environment, the
  function will stop with an error.

- out_directory:

  Character. Path to the output folder where the `.RData` files will be
  saved. Defaults to the current working directory.

- overwrite:

  Logical. Whether existing `.RData` files should be overwritten. If
  `FALSE` (Default) and files exist, the function will stop with an
  error message.

- prefix:

  Character. Prefix of each output file name. Useful for organizing
  saved files or avoiding name conflicts. Defaults to an empty string.

- verbose:

  Logical. Whether to print a message upon successful saving of files.
  Defaults to `FALSE`.

## Value

The function is used for its side effect of saving files and does not
return a value.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(fs, purrr)

temp_dir <- fs::path_temp("save_multiple")
fs::dir_create(temp_dir)

# ----------------------------------------------
# Save x1 and x2 to disk
# ----------------------------------------------
x1 = 10
x2 = 20

save_multiple(
  variables = c("x1", "x2"), out_directory = temp_dir, verbose = TRUE)
#> Saved 2 object(s) to /tmp/RtmpIhN7qQ/save_multiple.
#> Saved files are: x1.RData, x2.RData.

list.files(path = temp_dir, pattern = "^.+.RData")
#> [1] "x1.RData" "x2.RData"

(x1Contents <- ecokit::load_as(fs::path(temp_dir, "x1.RData")))
#> [1] 10
(x2Contents <- ecokit::load_as(fs::path(temp_dir, "x2.RData")))
#> [1] 20

# ----------------------------------------------
# Use prefix
# ----------------------------------------------
save_multiple(
  variables = c("x1", "x2"), out_directory = temp_dir, prefix = "A_")

list.files(path = temp_dir, pattern = "^.+.RData")
#> [1] "A_x1.RData" "A_x2.RData" "x1.RData"   "x2.RData"  

# ----------------------------------------------
# File exists, no save
# ----------------------------------------------
try(save_multiple(variables = c("x1", "x2"), out_directory = temp_dir))
#> One or more files exist; skipping save. Use overwrite = TRUE to force.

# ----------------------------------------------
# overwrite existing file
# ----------------------------------------------
x1 = 100; x2 = 200; x3 = 300

save_multiple(
  variables = c("x1", "x2", "x3"),
  out_directory = temp_dir, overwrite = TRUE)

(x1Contents <- ecokit::load_as(fs::path(temp_dir, "x1.RData")))
#> [1] 100
(x2Contents <- ecokit::load_as(fs::path(temp_dir, "x2.RData")))
#> [1] 200
(x3Contents <- ecokit::load_as(fs::path(temp_dir, "x3.RData")))
#> [1] 300

# clean up
fs::dir_delete(temp_dir)
```
