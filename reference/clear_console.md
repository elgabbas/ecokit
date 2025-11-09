# Clear the console

function clears the console in RStudio by sending a form feed character.
If not run in RStudio, it prints a message indicating the function is
not supported.

## Usage

``` r
clear_console()
```

## Value

An invisible `NULL` to indicate the function has completed without
returning any meaningful value.

## Note

This function checks if it is being run in RStudio by examining the
`RSTUDIO` environment variable. If the function is not run in RStudio,
it will not clear the console and instead print a message.

## Examples

``` r
clear_console()
#> This function does not work outside of RStudio.
```
