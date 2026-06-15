# Normalise file paths to a consistent absolute form

Converts one or more file paths to their absolute, tidied canonical form
using [`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html)
and [`fs::path_tidy()`](https://fs.r-lib.org/reference/path_tidy.html).
Optionally errors if any path does not exist on disk or has a size of
zero bytes.

## Usage

``` r
normalize_path(path = ".", must_work = FALSE, check_size = FALSE)
```

## Arguments

- path:

  Character vector. One or more file or directory paths to normalise.
  Empty strings and `NULL` trigger an error. Default: `"."` (current
  working directory).

- must_work:

  Logical. If `TRUE`, the function errors for any path in `path` that
  does not exist on disk (checked after normalisation). Default:
  `FALSE`.

- check_size:

  Logical. If `TRUE` and `must_work = TRUE`, the function additionally
  errors if any of the (existing) paths points to a file of zero bytes.
  Ignored when `must_work = FALSE` or when any path refers to a
  directory rather than a file. Default: `FALSE`.

## Value

A character vector of the same length as `path`, containing absolute,
tidied paths. Redundant separators, `.` and `..` components, and
mixed-style slashes are all resolved.

## Details

[`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html)
behaves inconsistently across platforms when a path does not exist: on
Windows it attempts to construct an absolute path, while on Linux/macOS
it returns the input unchanged (i.e. relative paths stay relative). This
function uses
[`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html)
instead, which always returns an absolute path regardless of whether the
path exists or which platform is used.

Path tidying via
[`fs::path_tidy()`](https://fs.r-lib.org/reference/path_tidy.html)
normalises directory separators to forward slashes and removes redundant
separators and trailing slashes, making the output safe to use in both R
and shell contexts across platforms.

When `must_work = TRUE`, existence is checked **after** normalisation so
that relative inputs such as `"."` or `"../"` resolve correctly before
the check is applied. The `check_size` check is subordinate to
`must_work`: it only runs once all paths are confirmed to exist.

## See also

[`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html),
[`fs::path_tidy()`](https://fs.r-lib.org/reference/path_tidy.html),
[`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html)

## Author

Ahmed El-Gabbas

## Examples

``` r
# Current working directory
normalize_path(".")
#> /home/runner/work/ecokit/ecokit/docs/reference

# Parent directory
normalize_path("../")
#> /home/runner/work/ecokit/ecokit/docs

# First file in the working directory (if any)
if (length(list.files()) > 0L) {
  normalize_path(list.files()[[1L]])
}
#> /home/runner/work/ecokit/ecokit/docs/reference/OS.html

# Vectorised: multiple paths at once
normalize_path(c(".", "../"))
#> /home/runner/work/ecokit/ecokit/docs/reference
#> /home/runner/work/ecokit/ecokit/docs

# Windows-style separators are normalised on all platforms
normalize_path("D://Folder1//Folder2//file.txt")
#> D:/Folder1/Folder2/file.txt

if (FALSE) { # \dontrun{
  # Errors when must_work = TRUE and the path does not exist
  normalize_path("D://Folder1//Folder2//file.txt", must_work = TRUE)

  # Errors when must_work = TRUE, check_size = TRUE, and the file is empty
  empty_file <- fs::file_temp(pattern = "empty_")
  fs::file_create(empty_file)
  normalize_path(empty_file, must_work = TRUE, check_size = TRUE)
} # }
```
