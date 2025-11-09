# Find duplicated files and directories within a given path

This function scans a directory tree for duplicated files (by content
hash) and optionally duplicated directories (by identical file sets). It
supports filtering by file extension, minimum file size, and parallel
processing.

## Usage

``` r
find_duplicates(
  path = ".",
  size_threshold = 0L,
  extensions = NULL,
  n_cores = 1L,
  verbose = TRUE
)
```

## Arguments

- path:

  Character. Root directory to scan for duplicates.

- size_threshold:

  Numeric. Minimum file size (in MB) to report as duplicate.

- extensions:

  Character vector. Optional file extensions (without the leading dot)
  to filter (case-insensitive); e.g., `c("csv", "txt")`). If provided,
  only files with these extensions are considered. . Directories are
  excluded if they don't match. Defaults to `NULL` (all files are
  considered).

- n_cores:

  Integer. Number of parallel workers to use (default: 1).

- verbose:

  Logical. Whether to print results to the console (default: `TRUE`).

## Value

A list of tibbles with duplicated files and directories, if found. The
`duplicated_files` tibble (if any) contains the following columns:

- `path`: root path scanned;

- `dup_group`: duplicate group ID;

- `files`: list-column of tibbles with absolute/relative paths and
  modification times;

- `file_ext`: file extension(s) of the group;

- `n_files`: number of duplicated files in the group;

- `file_size_mb`: size (MB) of the first file in the group; and

- `content_hash`: MD5 hash of the file content. The `duplicated_dirs`
  tibble (if any) contains the following columns:

- `dir`: directory path at the duplicated level;

- `dir_abs`: absolute path to the directory;

- `n_files`: number of files in the directory;

- `n_dup_dirs`: number of duplicated directories in the group;

- `dup_group`: unique identifier for each group of duplicated
  directories.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(fs)

# ----------------------------------------------------
# Example 1: Detect duplicate files with identical content
# ----------------------------------------------------

temp_dir1 <- fs::path_temp("example1")
fs::dir_create(temp_dir1)

# Create files with identical content
file1 <- fs::path(temp_dir1, "file1.txt")
file2 <- fs::path(temp_dir1, "file2.txt")
file3 <- fs::path(temp_dir1, "subdir", "file3.txt")
fs::dir_create(path(temp_dir1, "subdir"))
writeLines("This is some test content.", file1)
fs::file_copy(file1, file2, overwrite = TRUE)
fs::file_copy(file1, file3, overwrite = TRUE)

# Create a unique file
unique_file <- fs::path(temp_dir1, "unique.txt")
writeLines("Different content.", unique_file)

# Find duplicates
dups <- find_duplicates(temp_dir1, size_threshold = 0)
#> 
#> --------------------------------
#>   >>  Duplicated files
#> --------------------------------
#> 
#> # A tibble: 1 × 7
#>   path             dup_group files    file_ext n_files file_size_mb content_hash
#>   <fs::path>           <int> <list>   <chr>      <int>        <dbl> <chr>       
#> 1 …9s80iV/example1         1 <tibble> txt            3            0 d3608428aac…

dups$duplicated_files$files
#> [[1]]
#> # A tibble: 3 × 3
#>   file_abs                                  file_rel         modified           
#>   <chr>                                     <fs::path>       <dttm>             
#> 1 /tmp/Rtmp9s80iV/example1/file1.txt        file1.txt        2025-11-09 17:55:48
#> 2 /tmp/Rtmp9s80iV/example1/file2.txt        file2.txt        2025-11-09 17:55:48
#> 3 /tmp/Rtmp9s80iV/example1/subdir/file3.txt subdir/file3.txt 2025-11-09 17:55:48
#> 

# Clean up
fs::dir_delete(temp_dir1)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #

# ----------------------------------------------------
# Example 2: Detect duplicate directories with identical file sets
# ----------------------------------------------------

temp_dir2 <- fs::path_temp("example2")
fs::dir_create(temp_dir2)

# Create duplicate directories
dir_a <- fs::path(temp_dir2, "dir_a")
dir_b <- fs::path(temp_dir2, "dir_b")
dir_c <- fs::path(temp_dir2, "dir_c")
fs::dir_create(dir_a)
fs::dir_create(dir_b)
fs::dir_create(dir_c)

# Files in dir_a and dir_b (identical)
writeLines("Content 1", fs::path(dir_a, "file1.txt"))
writeLines("Content 2", fs::path(dir_a, "file2.txt"))
fs::file_copy(path(dir_a, "file1.txt"), fs::path(dir_b, "file1.txt"))
fs::file_copy(path(dir_a, "file2.txt"), fs::path(dir_b, "file2.txt"))

# Different files in dir_c
writeLines("Content 3", path(dir_c, "file3.txt"))

# Run the function (no extensions filter to include dirs)
dups <- find_duplicates(temp_dir2, size_threshold = 0)
#> 
#> --------------------------------
#>   >>  Duplicated directories
#> --------------------------------
#> 
#> # A tibble: 3 × 5
#>   dir        dir_abs                        n_files n_dup_dirs dup_group
#>   <fs::path> <fs::path>                       <int>      <int>     <int>
#> 1 dir_a      /tmp/Rtmp9s80iV/example2/dir_a       1          3         1
#> 2 dir_b      /tmp/Rtmp9s80iV/example2/dir_b       1          3         1
#> 3 dir_c      /tmp/Rtmp9s80iV/example2/dir_c       1          3         1
#> 
#> --------------------------------
#>   >>  Duplicated files
#> --------------------------------
#> 
#> # A tibble: 2 × 7
#>   path             dup_group files    file_ext n_files file_size_mb content_hash
#>   <fs::path>           <int> <list>   <chr>      <int>        <dbl> <chr>       
#> 1 …9s80iV/example2         1 <tibble> txt            2            0 39a16930dd4…
#> 2 …9s80iV/example2         2 <tibble> txt            2            0 3294155fa14…

dups$duplicated_dirs
#> # A tibble: 3 × 5
#>   dir        dir_abs                        n_files n_dup_dirs dup_group
#>   <fs::path> <fs::path>                       <int>      <int>     <int>
#> 1 dir_a      /tmp/Rtmp9s80iV/example2/dir_a       1          3         1
#> 2 dir_b      /tmp/Rtmp9s80iV/example2/dir_b       1          3         1
#> 3 dir_c      /tmp/Rtmp9s80iV/example2/dir_c       1          3         1

dups$duplicated_files$files
#> [[1]]
#> # A tibble: 2 × 3
#>   file_abs                                 file_rel        modified           
#>   <chr>                                    <fs::path>      <dttm>             
#> 1 /tmp/Rtmp9s80iV/example2/dir_a/file1.txt dir_a/file1.txt 2025-11-09 17:55:48
#> 2 /tmp/Rtmp9s80iV/example2/dir_b/file1.txt dir_b/file1.txt 2025-11-09 17:55:48
#> 
#> [[2]]
#> # A tibble: 2 × 3
#>   file_abs                                 file_rel        modified           
#>   <chr>                                    <fs::path>      <dttm>             
#> 1 /tmp/Rtmp9s80iV/example2/dir_a/file2.txt dir_a/file2.txt 2025-11-09 17:55:48
#> 2 /tmp/Rtmp9s80iV/example2/dir_b/file2.txt dir_b/file2.txt 2025-11-09 17:55:48
#> 

# Clean up
fs::dir_delete(temp_dir2)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #

# ----------------------------------------------------
# Example 3: Filter by extensions and size threshold
# ----------------------------------------------------

temp_dir3 <- fs::path_temp("example3")
fs::dir_create(temp_dir3)

# Create duplicate CSV files
csv1 <- fs::path(temp_dir3, "data1.csv")
csv2 <- fs::path(temp_dir3, "data2.csv")
writeLines("col1,col2\n1,2", csv1)
fs::file_copy(csv1, csv2)

# Create small duplicate TXT file (below threshold)
txt1 <- fs::path(temp_dir3, "small1.txt")
txt2 <- fs::path(temp_dir3, "small2.txt")
writeLines("Small", txt1)
fs::file_copy(txt1, txt2)

# Run with extensions filter and size threshold
dups <- find_duplicates(
  temp_dir3, extensions = "csv", size_threshold = 0.001)

dups
#> NULL

# Clean up
fs::dir_delete(temp_dir3)

# # ||||||||||||||||||||||||||||||||||||||||||||||||||||| #

# ----------------------------------------------------
# Example 4: Parallel processing with multiple cores
# ----------------------------------------------------

temp_dir4 <- fs::path_temp("example4")
fs::dir_create(temp_dir3)

# Create many duplicate files to test parallel
for (i in 1:5) {
  fs::dir_create(path(temp_dir4, paste0("group", i)))
  for (j in 1:3) {
    file_path <- fs::path(
      temp_dir4, paste0("group", i), paste0("dup", j, ".txt"))
    writeLines(paste("Content for group", i), file_path)
  }
}

# Run with 2 cores
find_duplicates(temp_dir4, n_cores = 2, size_threshold = 0)
#> 
#> --------------------------------
#>   >>  Duplicated directories
#> --------------------------------
#> 
#> # A tibble: 5 × 5
#>   dir        dir_abs                         n_files n_dup_dirs dup_group
#>   <fs::path> <fs::path>                        <int>      <int>     <int>
#> 1 group1     /tmp/Rtmp9s80iV/example4/group1       1          5         1
#> 2 group2     /tmp/Rtmp9s80iV/example4/group2       1          5         1
#> 3 group3     /tmp/Rtmp9s80iV/example4/group3       1          5         1
#> 4 group4     /tmp/Rtmp9s80iV/example4/group4       1          5         1
#> 5 group5     /tmp/Rtmp9s80iV/example4/group5       1          5         1
#> 
#> --------------------------------
#>   >>  Duplicated files
#> --------------------------------
#> 
#> # A tibble: 5 × 7
#>   path             dup_group files    file_ext n_files file_size_mb content_hash
#>   <fs::path>           <int> <list>   <chr>      <int>        <dbl> <chr>       
#> 1 …9s80iV/example4         1 <tibble> txt            3            0 289d4cf190e…
#> 2 …9s80iV/example4         2 <tibble> txt            3            0 d5735c1086d…
#> 3 …9s80iV/example4         3 <tibble> txt            3            0 31575137fb5…
#> 4 …9s80iV/example4         4 <tibble> txt            3            0 e4f4464959f…
#> 5 …9s80iV/example4         5 <tibble> txt            3            0 8506efe5d5b…

# Clean up
dir_delete(temp_dir4)
```
