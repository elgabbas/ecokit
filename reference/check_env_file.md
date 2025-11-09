# Check the integrity of a `.env` file before loading environment variables

Validates a `.env` file to ensure it is properly formatted for loading
environment variables.

## Usage

``` r
check_env_file(env_file = ".env", warning = TRUE)
```

## Arguments

- env_file:

  Path to the .env file (default: ".env")

- warning:

  Logical; if `TRUE`, prints warnings for errors (default: `TRUE`)

## Value

Logical: `TRUE` if valid, `FALSE` otherwise

## Details

The function performs the following checks:

- Verifies file exists and is readable

- Confirms `.env` extension

- Ensures file is not empty

- Checks for at least one valid variable definition

- Validates non-comment, non-empty lines follow `KEY=VALUE` format
  (allowing optional whitespace around KEY, '=', and VALUE)

- Ensures variable names start with letter/underscore, followed by
  letters/digits/underscores

- Checks for duplicate variable names (case-sensitive)

- Ignores comment lines (starting with \#) and empty lines

- Validates no unclosed quotes in values

- Checks for unquoted special characters in values

## Author

Ahmed El-Gabbas

## Examples

``` r
# Save a valid .env file to temp file
valid_env <- fs::file_temp(ext = ".env")
writeLines(
  c("DB_HOST=localhost", "DB_PORT=5432", "# Comment", "API_KEY='abc123'"),
  valid_env)
check_env_file(valid_env)  # Returns TRUE
#> [1] TRUE

# Invalid .env file
invalid_env <- fs::file_temp(ext = ".env")

writeLines(
  c(
   "DB_HOST=localhost", "INVALID KEY=value",
   "DB_HOST=duplicate"),
 invalid_env)
check_env_file(invalid_env)  # Returns FALSE
#> Warning: Invalid variable definition(s): INVALID KEY=value
#> Warning: Duplicate variable names: DB_HOST
#> [1] FALSE
```
