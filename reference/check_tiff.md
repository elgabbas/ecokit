# Check if a tiff file corrupted

This function checks if the provided tiff file is corrupted by
attempting to describe it using the `terra` package and searching for
the presence of a "Driver" string in the description, which indicates a
valid tiff file. If the string is found, the function returns `TRUE` and
`FALSE` otherwise. The function works also for reading netCDF files with
the `terra` package.

## Usage

``` r
check_tiff(x = NULL, warning = TRUE)
```

## Arguments

- x:

  Character; the file path of the tiff file to be checked. The function
  will stop with an error if `x` is `NULL` or if the file does not
  exist.

- warning:

  Logical. If `TRUE`, the function will issue a warning if the file does
  not exist.

## Value

Logical; returns `TRUE` if the TIFF file is not corrupted (i.e., the
file exists, can be described with a "Driver" in its metadata, has
values, and its data can be read without errors or warnings), and
`FALSE` otherwise.

## Author

Ahmed El-Gabbas

## Examples

``` r
(f <- system.file("ex/elev.tif", package="terra"))
#> [1] "/home/runner/work/_temp/Library/terra/ex/elev.tif"

check_tiff(x = f)
#> [1] TRUE

# a temp file ends with .tif (not a valid tiff file)
(temp_file <- tempfile(fileext = ".tif"))
#> [1] "/tmp/RtmpIhN7qQ/file24654e81f0b4.tif"
fs::file_create(temp_file)
check_tiff(x = temp_file)
#> [1] FALSE

# clean up
fs::file_delete(temp_file)
```
