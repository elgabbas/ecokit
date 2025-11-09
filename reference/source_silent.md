# Silently source R script with optional message and warning suppression

Sources an R script file with options to suppress messages and/or
warnings. Useful for running scripts that generate unwanted console
output.

## Usage

``` r
source_silent(file = NULL, messages = TRUE, warnings = TRUE, ...)
```

## Arguments

- file:

  Character. Path to the R script file to be sourced.

- messages:

  Logical. If `TRUE` (default), messages are shown. If `FALSE`, messages
  are suppressed.

- warnings:

  Logical. If `TRUE` (default), warnings are shown. If `FALSE`, warnings
  are suppressed.

- ...:

  Additional arguments passed to
  [`base::source()`](https://rdrr.io/r/base/source.html).

## Value

Invisible `NULL`. Used for its side effect of sourcing the file.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Create a temporary R script
script_file <- tempfile(fileext = ".R")
writeLines(
  c("message('This is a message')", "warning('This is a warning')",
    "print('Output')"),
    script_file)

# -------------------------------------------

# source with default settings (show messages and warnings)
source_silent(script_file)
#> This is a message
#> Warning: This is a warning

# suppress messages only
source_silent(script_file, messages = FALSE)
#> Warning: This is a warning

# suppress warnings only
source_silent(script_file, warnings = FALSE)
#> This is a message

# suppress both messages and warnings
source_silent(script_file, messages = FALSE, warnings = FALSE)

# clean up
fs::file_delete(script_file)
```
