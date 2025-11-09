# Jump Up Parent Directories

Returns the n^(th) ancestor directory of a given path.

## Usage

``` r
parent_dir(
  path = NULL,
  levels = 1L,
  check_dir = FALSE,
  extract_full = FALSE,
  warning = TRUE,
  ...
)
```

## Arguments

- path:

  Character. The file or directory path to start from. If
  `check_dir = TRUE` and `path` exists as a file or has a file
  extension, its parent directory is used as the starting point. If
  `check_dir = FALSE`, a file path is treated as a directory name.

- levels:

  Integer. Number of parent levels to jump up. Must be a single,
  non-negative integer.

- check_dir:

  Logical. If `TRUE`, checks `path` is a valid directory and uses its
  parent if `path` is a file. If `FALSE`, does not check existence and
  uses the input as-is.

- extract_full:

  Logical. If `TRUE` and `levels` exceeds the number of path components
  minus one, returns the root of the path. If `FALSE`, an error is
  thrown when `levels` exceeds the available ancestors.

- warning:

  Logical. If `TRUE`, prints a warning message when `path` is a file or
  has an extension, indicating that the parent directory is being used
  instead. Defaults to `TRUE`.

- ...:

  Additional arguments passed to
  [stop_ctx](https://elgabbas.github.io/ecokit/reference/stop_ctx.md)
  for error reporting.

## Value

Character. The resulting path after jumping. If `extract_full = TRUE`
and `levels` exceeds the available ancestors, returns the root of the
path; otherwise, returns the ancestor path or throws an error.

## Author

Ahmed El-Gabbas

## Examples

``` r
example_path <- "/home/user/projects/data"
{
  cat(parent_dir(example_path, levels = 0), "\n")
  cat(parent_dir(example_path, levels = 1), "\n")
  cat(parent_dir(example_path, levels = 2), "\n")
  cat(parent_dir(example_path, levels = 3), "\n")
  cat(parent_dir(example_path, levels = 4), "\n")
}
#> /home/user/projects/data 
#> /home/user/projects 
#> /home/user 
#> /home 
#> / 

# input as file
example_file <- "/home/user/projects/data/file.txt"
parent_dir(example_file, levels = 2)
#>   >>>  Input `path` appears to be a file (exists as file or has extension), using its parent directory.
#>   >>>  /home/user/projects/data/file.txt
#> 
#> /home/user
# suppress warning
parent_dir(example_file, levels = 2, warning = FALSE)
#> /home/user

# not enough levels; this will give an error
try(parent_dir("/home/user", levels = 4, extract_full = TRUE))
#> Error in parent_dir("/home/user", levels = 4, extract_full = TRUE) : 
#>   `levels` > available ancestors (max = 2).
#> 
#> ----- Metadata -----
#> 
#> levels [levels]: <integer>
#> 4
#> 
#> abs_depth [abs_depth]: <integer>
#> 3
#> 
#> extract_full [extract_full]: <logical>
#> TRUE
```
