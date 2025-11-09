# Extract package names used with :: in an R script

Reads an R script file and extracts unique package names used with the
`::` operator (e.g., `dplyr` from
[`dplyr::arrange`](https://dplyr.tidyverse.org/reference/arrange.html)).
Ignores entire lines that are comments (starting with `#`, ignoring
whitespace) and text after `#` within lines.

## Usage

``` r
used_packages(file_path)
```

## Arguments

- file_path:

  Character string specifying the path to the R script file.

## Value

A character vector of unique package names used with `::`. Returns
`character(0)` if none are found.

## Examples

``` r
# Example with a script from GitHub
dplyr_select_url <- paste0(
  "https://raw.githubusercontent.com/elgabbas/ecokit/",
  "refs/heads/main/R/spat_split_raster.R")
example_script <- fs::file_temp("Example_script_", ext = "R")
download.file(dplyr_select_url, destfile = example_script, quiet = TRUE)

used_packages(example_script)
#> [1] "ecokit"   "fs"       "graphics" "raster"  

# cleanup
fs::file_delete(example_script)
```
