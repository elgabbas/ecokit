# Check and Load GBIF Credentials from .Renviron

Checks if [GBIF](https://www.gbif.org/) access credentials
(`GBIF_EMAIL`, `GBIF_PWD`, `GBIF_USER`) are available in the
environment. If not, attempts to read them from the specified
`.Renviron` file. If the credentials are still missing after reading the
file, an error is thrown with details about which credentials are
missing.

## Usage

``` r
check_gbif(r_environ = ".Renviron")
```

## Arguments

- r_environ:

  Character string specifying the path to the `.Renviron` file where
  GBIF credentials are stored. Defaults to `".Renviron"` in the current
  working directory.

## Value

Returns `NULL` invisibly if the GBIF credentials are successfully
loaded. Stops with an error if the credentials cannot be found or
loaded.

## Details

This function ensures that the necessary GBIF credentials are loaded
into the R environment for accessing GBIF services, typically for using
[rgbif](https://docs.ropensci.org/rgbif) R package. It first checks if
the credentials are already set as environment variables. If any are
missing, it attempts to read them from the specified `.Renviron` file.
If the file does not exist, is not readable, or does not contain all
required credentials, the function stops with an informative error
message. Note, however, that the function does not check if the
credentials are valid or if they work with GBIF; only that they are
present in the environment.

## Author

Ahmed El-Gabbas

## Examples

``` r
if (FALSE) { # \dontrun{

  # Check GBIF credentials using the default .Renviron file
  check_gbif()

  # Specify a custom .Renviron file
  check_gbif(r_environ = "~/.Renviron")

} # }
```
