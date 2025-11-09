# Check the Integrity of ZIP Files

Tests the integrity of ZIP files using the `unzip -t` system command.
Verifies that files exist, non-empty, have a `.zip` extension, and pass
the integrity check.

## Usage

``` r
check_zip(file = NULL, warning = TRUE, all_okay = TRUE)
```

## Arguments

- file:

  Character. Path to a ZIP file. Must be a single, non-empty string.

- warning:

  Logical. If `TRUE`, issues a warning if the file does not exist, is
  empty, or fails the integrity check. Default is `TRUE`.

- all_okay:

  Logical. If `TRUE` (default), returns a single logical output
  indicating the validity of all ZIP files; if `FALSE`, returns a
  logical vector for each ZIP file.

## Value

Logical: `TRUE` if all checks pass; `FALSE` otherwise.

## Note

Requires the `unzip` system command.

## Author

Ahmed El-Gabbas

## Examples

``` r
# |||||||||||||||||||||||||||||||||||||||
# Create ZIP files
# |||||||||||||||||||||||||||||||||||||||

# valid ZIP file
temp_dir <- fs::path_temp("check_zip")
fs::dir_create(temp_dir)
temp_file <- fs::path(temp_dir, "test.txt")
writeLines("Hello, world!", temp_file)
zip_file <- fs::path(temp_dir, "valid.zip")
zip(zip_file, temp_file, flags = "-jq")
check_zip(zip_file)
#> [1] TRUE

# invalid ZIP file (corrupted)
bad_zip <- fs::path(temp_dir, "invalid.zip")
writeLines("Not a ZIP file", bad_zip)
check_zip(bad_zip)
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/invalid.zip'' had status 9
#> [1] FALSE
check_zip(bad_zip, warning = FALSE)
#> [1] FALSE

# empty ZIP file
empty_zip <- fs::path(temp_dir, "empty.zip")
fs::file_create(empty_zip)
check_zip(empty_zip)
#> Warning: File is empty: /tmp/RtmpIhN7qQ/check_zip/empty.zip
#> [1] FALSE
check_zip(empty_zip, warning = FALSE)
#> [1] FALSE

# non-ZIP file
non_zip_file <- fs::path(temp_dir, "test.txt")
writeLines("Hello, world!", non_zip_file)
check_zip(non_zip_file)
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/test.txt'' had status 9
#> [1] FALSE
check_zip(non_zip_file, warning = FALSE)
#> [1] FALSE

# non-existent file
check_zip("nonexistent.zip")
#> Warning: File does not exist: /home/runner/work/ecokit/ecokit/docs/reference/nonexistent.zip
#> [1] FALSE
check_zip("nonexistent.zip", warning = FALSE)
#> [1] FALSE

# Check multiple files
zip_files <- c(zip_file, bad_zip, empty_zip, temp_file)

check_zip(zip_files)
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/invalid.zip'' had status 9
#> Warning: File is empty: /tmp/RtmpIhN7qQ/check_zip/empty.zip
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/test.txt'' had status 9
#> [1] FALSE

check_zip(zip_files, warning = FALSE)
#> [1] FALSE

check_zip(zip_files, all_okay = FALSE)
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/invalid.zip'' had status 9
#> Warning: File is empty: /tmp/RtmpIhN7qQ/check_zip/empty.zip
#> Warning: Warning during file validation: running command 'unzip -t '/tmp/RtmpIhN7qQ/check_zip/test.txt'' had status 9
#> [1]  TRUE FALSE FALSE FALSE

check_zip(zip_files, all_okay = FALSE, warning = FALSE)
#> [1]  TRUE FALSE FALSE FALSE

# clean up
fs::file_delete(zip_files)
fs::dir_delete(temp_dir)
```
