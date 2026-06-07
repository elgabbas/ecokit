# Create a tar archive from files in a directory

Creates a tar archive (optionally compressed) containing the specified
files from a directory. The function uses the system `tar` executable
and passes the file list via a temporary file, avoiding command-line
length limitations when archiving large numbers of files.

## Usage

``` r
create_tar(
  files,
  dir_source,
  path_tar,
  compress = c("none", "gzip", "bzip2", "xz"),
  chmod = NULL,
  overwrite = FALSE
)
```

## Arguments

- files:

  Character vector of file names relative to `dir_source`. Must be
  non-`NULL`, non-empty, and contain no `NA` values or absolute paths.
  All named files must exist and be non-empty within `dir_source`.

- dir_source:

  Character scalar. Directory containing the files to archive. The
  parent directory of `path_tar` is created if it does not exist.

- path_tar:

  Character scalar. Path to the output tar archive.

- compress:

  Character scalar controlling compression. One of `"none"` (default,
  plain `.tar`), `"gzip"` (`.tar.gz`), `"bzip2"` (`.tar.bz2`), or `"xz"`
  (`.tar.xz`). The archive extension is not checked against this choice;
  the caller is responsible for using a consistent file name.

- chmod:

  Character scalar. Optional Unix file permissions to set on the created
  archive, as a three-digit octal string (e.g. `"644"`). If `NULL` (the
  default) permissions are determined by the system. Values outside the
  range `"000"`-`"777"` are rejected.

- overwrite:

  Logical scalar. Should an existing archive at `path_tar` be
  overwritten? Defaults to `FALSE`.

## Value

Invisibly returns `path_tar`.

## Details

The function requires a `tar` executable to be available on the system
`PATH`. File names in `files` must be relative to `dir_source`; absolute
paths are not supported.

Compression support depends on the `tar` implementation and the presence
of the corresponding compressor (`gzip`, `bzip2`, or `xz`) on the
system.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(fs, archive, purrr, dplyr)

# Create non-empty example files in a temporary directory
tmp <- fs::path_temp("example_files")
fs::dir_create(tmp)
files <- c("a.qs2", "b.qs2", "c.qs2")
purrr::walk(file.path(tmp, files), .f = ~ writeLines("test content", .x))

# Create an uncompressed tar archive
tar_file <- fs::path(tmp, "archive.tar")
create_tar(
  files = files, dir_source = tmp, path_tar = tar_file, overwrite = TRUE)

# Verify the created archive
archive::archive(tar_file)
#> # A tibble: 3 × 3
#>   path   size date               
#>   <chr> <int> <dttm>             
#> 1 a.qs2    13 2026-06-07 22:32:57
#> 2 b.qs2    13 2026-06-07 22:32:57
#> 3 c.qs2    13 2026-06-07 22:32:57

ecokit::file_type(tar_file)
#> [1] "POSIX tar archive (GNU)"

# Create a gzip-compressed archive
tar_gz_file <- fs::path(tmp, "archive.tar.gz")
create_tar(
  files = files, dir_source = tmp, path_tar = tar_gz_file,
  compress = "gzip", overwrite = TRUE)

# Compare the two archives
fs::file_info(c(tar_file, tar_gz_file)) %>%
 dplyr::select(path, size, type)
#> # A tibble: 2 × 3
#>   path                                                size type 
#>   <fs::path>                                   <fs::bytes> <fct>
#> 1 /tmp/RtmpxXMNZN/example_files/archive.tar            10K file 
#> 2 /tmp/RtmpxXMNZN/example_files/archive.tar.gz         149 file 
```
