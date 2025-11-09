# Retrieve Remote SHAs for R Packages

Retrieves the remote SHA (Secure Hash Algorithm) reference for one or
more R packages from their remote repositories (e.g., GitHub, GitLab).
The SHA uniquely identifies a package's source code version, aiding
reproducibility and version tracking.

## Usage

``` r
package_remote_sha(..., lib_path = .libPaths()[1L])
```

## Arguments

- ...:

  Quoted or unquoted names of one or more R packages (e.g., `dplyr`,
  `"tidyr"`). Must be valid package names (letters, numbers, dots, or
  underscores) and installed in the library.

- lib_path:

  Character. Path to the library where the packages are installed.
  Defaults to the first library in
  [`.libPaths()`](https://rdrr.io/r/base/libPaths.html). This parameter
  is optional.

## Value

A named character vector where names are package names and values are
the corresponding remote SHAs. Returns `NA` for packages not installed,
from CRAN, or without a remote SHA.

## Details

This function uses
[`pak::lib_status()`](https://pak.r-lib.org/reference/lib_status.html)
to query installed packages and extract their remote SHAs. CRAN or
locally installed packages typically return `NA`, as they lack remote
SHAs.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(remotes, fs)

# create a temporary directory for package installation
temp_lib <- fs::path_temp("temp_lib")
fs::dir_create(temp_lib)

# install pkgconfig from GitHub into the temporary directory
remotes::install_github(
  "r-lib/pkgconfig", lib = temp_lib, upgrade = "never",
  quiet = TRUE, dependencies = FALSE)

# retrieve remote SHA for pkgconfig
package_remote_sha(pkgconfig, lib_path = temp_lib)
#>                                  pkgconfig 
#> "687e3154aa407642649beb00334940c71d6f22d9" 

# `stats` and non-existent packages return NA
package_remote_sha(stats, non_existent)
#>        stats non_existent 
#>           NA           NA 

# clean up
remove.packages("pkgconfig", lib = temp_lib)
fs::dir_delete(temp_lib)

if (FALSE) { # \dontrun{
  # the following will give an error
  package_remote_sha(TRUE)
  package_remote_sha(NA)
  package_remote_sha(NULL)
} # }
```
