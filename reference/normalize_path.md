# Normalise and quote file paths

This function ensures that file paths are expressed in a consistent and
canonical form. It first converts paths to absolute form using
[`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html), then
tidies them with
[`fs::path_tidy()`](https://fs.r-lib.org/reference/path_tidy.html), and
finally quotes them correctly based on the operating system. By default,
[`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html)
behaves differently on Windows and Linux when a file does not exist. On
Windows, it tries to construct an absolute path, while on Linux, it
returns the input path as-is (relative). To maintain consistency across
platforms, this function uses
[`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html)
instead of
[`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html).

## Usage

``` r
normalize_path(path, must_work = FALSE)
```

## Arguments

- path:

  Character vector. file path(s).

- must_work:

  Logical; if `TRUE`, the function errors for non-existing paths.

## Value

A character vector of absolute, tidied, and shell-quoted paths.

## Author

Ahmed El-Gabbas

## Examples

``` r
# current working directory
normalize_path(".")
#> /home/runner/work/ecokit/ecokit/docs/reference

# up one directory
normalize_path("../")
#> /home/runner/work/ecokit/ecokit/docs

list.files()[1]
#> [1] "OS.html"
normalize_path(list.files()[1])
#> /home/runner/work/ecokit/ecokit/docs/reference/OS.html

# absolute path with windows-style slashes
normalize_path("D://Folder1//Folder2//file.txt")
#> D:/Folder1/Folder2/file.txt

if (FALSE) { # \dontrun{
  # this will give an error if the path does not exist
  normalize_path("D://Folder1//Folder2//file.txt", must_work = TRUE)
} # }
```
