# Check system commands availability

This function checks if a list of system commands are available on the
user's PATH.

## Usage

``` r
check_system_command(commands, warning = TRUE)
```

## Arguments

- commands:

  A character vector of system command names to check (e.g.,
  `c("git", "Rscript", "unzip")`).

- warning:

  Logical. Whether to issue a warning if any command is missing.
  Defaults to `TRUE`.

## Value

The function returns `TRUE` if *all* specified commands are available on
the system, `FALSE` if any is not available.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Check for the availability of system commands
check_system_command(c("unzip", "head"))
#> [1] TRUE

# return FALSE, with a warning for a missing command
check_system_command(c("unzip", "head", "curl", "missing"))
#> Warning: The following tool(s) are missing: missing
#> [1] FALSE

# return FALSE, without a warning for a missing command
check_system_command(c("unzip", "head", "curl", "missing"), warning = FALSE)
#> [1] FALSE
```
