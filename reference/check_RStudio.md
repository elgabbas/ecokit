# Check if the installed RStudio version is up to date

This function checks the current installed version of RStudio against
the latest version available online. If the versions do not match, it
suggests updating RStudio.

## Usage

``` r
check_rstudio()
```

## Value

Side effects include printing messages to the console regarding the
status of RStudio version.

## Note

This function requires internet access to check the latest version of
RStudio online. If called outside of RStudio, it will only fetch and
display the latest version without comparing. If posit has changed the
structure of their webpage and the online version can not be parsed, the
function reports this clearly and, when possible, still shows the
installed version.

## Author

Ahmed El-Gabbas

## Examples

``` r
check_rstudio()
#> Not called from RStudio. The most recent version of RStudio is 2026.07.1.147.
```
