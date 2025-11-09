# Check if the installed Quarto version is up to date

This function compares the installed Quarto version on the user's system
with the latest version available online. If the versions differ, it
suggests the user to update Quarto. It uses web scraping to find the
latest version available on the Quarto GitHub releases page and the
system command to find the installed version.

## Usage

``` r
check_quarto(pre_release = FALSE)
```

## Arguments

- pre_release:

  Logical. Whether to check for pre-release versions. Default is
  `FALSE`.

## Value

A message indicating whether the installed Quarto version is up to date
or suggesting an update if it is not.

## Author

Ahmed El-Gabbas

## Examples

``` r
check_quarto()
#> Quarto is not available in the system.
#> Latest quarto version is v1.8.25 [installed: NA]
#> 

check_quarto(pre_release = TRUE)
#> Quarto is not available in the system.
#> Available pre-release version is: v1.9.9 [installed: NA]
#> 
```
