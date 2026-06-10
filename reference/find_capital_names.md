# Find files and directories with uppercase letters in their names

Recursively searches a directory tree and reports files and directories
whose names contain one or more uppercase letters. This is useful for
enforcing project-wide naming conventions that require lowercase file
and directory names, especially when working on case-sensitive file
systems such as Linux or HPC environments.

## Usage

``` r
find_capital_names(
  path = ".",
  extension = NULL,
  exclude_extension = NULL,
  exclude_dirs = c(".git", ".Rproj.user"),
  full_paths = FALSE
)
```

## Arguments

- path:

  Character scalar. Root directory to search recursively.

- extension:

  Optional character vector of file extensions to include
  (case-insensitive). If `NULL` (default), all file types are searched.
  Extensions may be supplied with or without a leading `"."`.

- exclude_extension:

  Optional character vector of file extensions to exclude. Matching is
  case-insensitive.

- exclude_dirs:

  Character vector of directory names to exclude together with all of
  their contents.

- full_paths:

  Logical scalar. If `TRUE`, absolute paths are returned. Otherwise,
  paths are returned relative to `path` (default).

## Value

A named list with elements:

- `files`: Files whose filenames contain uppercase letters.

- `directories`: Directories whose own names contain uppercase letters.

- `directories_anywhere_in_path`: Directories whose relative paths
  contain uppercase letters anywhere in the path hierarchy.

## Details

By default, paths are returned relative to the search root. Absolute
paths can be returned by setting `full_paths = TRUE`.

This function is useful for identifying violations of lowercase naming
conventions in projects. Detecting uppercase letters early helps avoid
problems caused by case-sensitive file systems and promotes consistent
project structure.

## Author

Ahmed El-Gabbas

## Examples
