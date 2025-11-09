# Calculate the Size of a Directory

Computes the total size of a directory, including all its contents,
recursively. The size can be returned in bytes or in a human-readable
format (e.g., KB, MB, GB).

## Usage

``` r
dir_size(directory, human_readable = TRUE, recursive = TRUE)
```

## Arguments

- directory:

  Character. The path to the directory.

- human_readable:

  Logical. Whether to return the size in a human-readable format (e.g.,
  "1.2 GB") or in bytes. Defaults to `TRUE`.

- recursive:

  Logical. Whether to include subdirectories in the size calculation.
  Defaults to `TRUE`.

## Value

If `human_readable = TRUE`, a character string representing the
directory size in a human-readable format. If `human_readable = FALSE`,
a numeric value representing the directory size in bytes.

## Details

The function uses
[`fs::dir_info()`](https://fs.r-lib.org/reference/dir_ls.html) to
recursively calculate the total size of all files in the specified
directory. It handles edge cases such as: non-existent directories,
invalid or inaccessible paths, empty directories, and cross-platform
path normalization.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Calculate the size of the current working directory (recursive)
dir_size(".", human_readable = TRUE)      # human-readable format
#> [1] "1.48 MB"

dir_size(".", human_readable = FALSE)     # size in bytes
#> [1] 1553818

dir_size(".", recursive = FALSE)          # non-recursive size calculation
#> [1] "1.48 MB"

if (FALSE) { # \dontrun{
  # create temporary directory containing large files and subdirectories
  temp_dir <- fs::path_temp("dir_size")
  temp_sub_dir <- fs::path(temp_dir, "subdir")
  fs::dir_create(c(temp_dir, temp_sub_dir))
  # create large files
  file_path <- fs::path(temp_dir, "large_file1.txt")

  # ------------------------------------------

  # create example large file (10 MB)

  # Open file connection in append mode
  con <- file(file_path, open = "at")
  # Generate a chunk of text (~1 MB)
  chunk <- paste(rep("X", 1024 * 1024), collapse = "")
  # Write chunks until target size (# 10 MB in bytes) is reached
  bytes_written <- 0
  while (bytes_written <  10 * 1024 * 1024) {
    writeLines(chunk, con)
    bytes_written <- bytes_written + nchar(chunk, type = "bytes")
  }
  close(con)

  # ------------------------------------------

  # Copy the file to create additional large files
  target_paths_1 <- fs::path(
    temp_dir, c("large_file2.txt", "large_file3.txt", "large_file4.txt"))
  target_paths_2 <- fs::path(
    temp_sub_dir, c("large_file5.txt", "large_file6.txt", "large_file4.txt"))
  fs::file_copy(rep(file_path, 3), target_paths_1, overwrite = TRUE)
  fs::file_copy(rep(file_path, 3), target_paths_2, overwrite = TRUE)

  # list of files
  fs::dir_ls(temp_dir)
  fs::dir_ls(temp_sub_dir)

  # ------------------------------------------

  # Calculate size of the temporary directory
  dir_size(temp_dir)
  dir_size(temp_dir, human_readable = FALSE)

  # Non-recursive size calculation
  dir_size(temp_dir, recursive = FALSE)
  dir_size(temp_dir, human_readable = FALSE, recursive = FALSE)

  # clean up
  fs::dir_delete(temp_dir)
} # }
```
