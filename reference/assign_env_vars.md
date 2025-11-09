# Assign environment variables from a .env file

Reads environment variables from a `.env` file and assigns them to R
variables based on a data frame specifying variable names, environment
variable keys, and optional directory or file checks. Facilitates
structured management of environment variables.

## Usage

``` r
assign_env_vars(env_file = ".env", env_variables_data = NULL)
```

## Arguments

- env_file:

  Character. Path to a environment file containing key-value pairs
  (e.g., `KEY=VALUE`). Defaults to `.env`.

- env_variables_data:

  `data.frame`. A data frame or tibble with columns `var_name`
  (character, R variable name), `value` (character, environment variable
  key in `.env`), `check_dir` (logical, check if value is a directory),
  and `check_file` (logical, check if value is a file). Each row defines
  a variable to assign with optional validation.

## Value

Returns `invisible(NULL)`. Used for its side effect of assigning
variables from the `.env` file to `envir` based on `env_variables_data`.

## Note

The `.env` file must contain key-value pairs (e.g.,
`DATA_PATH=/path/to/data`). `var_name` must start with a letter and
contain only letters, numbers, dots, or underscores. Only one of
`check_dir` or `check_file` can be `TRUE` per row.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(tibble, dplyr, fs)

# Create a temporary file and directory

tmp_dir <- fs::path_temp("assign_env_vars")
fs::dir_create(tmp_dir)
tmp_file <- ecokit::normalize_path(tempfile(fileext = ".txt"))
fs::file_create(tmp_file)

# Create a minimal .env file
tmp_env_file <- tempfile(fileext = ".env")
c(paste0("MY_FILE=", tmp_file), paste0("MY_DIR=", tmp_dir)) %>%
  writeLines(tmp_env_file)
rm(tmp_dir, tmp_file, envir = environment())

# contents of the .env file
readLines(tmp_env_file)
#> [1] "MY_FILE=/tmp/RtmpIhN7qQ/file24652997a709.txt"
#> [2] "MY_DIR=/tmp/RtmpIhN7qQ/assign_env_vars"      

# Define simple environment variables data
(env_vars <- tibble::tibble(
  var_name = c("my_file", "my_dir"),
  value = c("MY_FILE", "MY_DIR"),
  check_dir = c(FALSE, TRUE),
  check_file = c(TRUE, FALSE)))
#> # A tibble: 2 × 4
#>   var_name value   check_dir check_file
#>   <chr>    <chr>   <lgl>     <lgl>     
#> 1 my_file  MY_FILE FALSE     TRUE      
#> 2 my_dir   MY_DIR  TRUE      FALSE     

ls()
#> [1] "env_vars"     "tmp_env_file"

# Assign environment variables
assign_env_vars(env_file = tmp_env_file, env_variables_data = env_vars)
ls()
#> [1] "env_vars"     "my_dir"       "my_file"      "tmp_env_file"

# Verify
my_file
#> [1] "/tmp/RtmpIhN7qQ/file24652997a709.txt"
my_dir
#> [1] "/tmp/RtmpIhN7qQ/assign_env_vars"

# clean up
fs::dir_delete(fs::path_temp("assign_env_vars"))
```
