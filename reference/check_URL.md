# Check the validity of URLs

This function opens a connection to the specified URLs to check their
validity.

## Usage

``` r
check_url(url = NULL, timeout = 2L, all_okay = TRUE)
```

## Source

The source code of this function was taken from this
[stackoverflow](https://stackoverflow.com/q/52911812) discussion.

## Arguments

- url:

  Character. The URLs to be checked.

- timeout:

  Numeric. Timeout in seconds for the connection attempt. Default is 2
  seconds.

- all_okay:

  Logical. If `TRUE` (default), returns a single logical output
  indicating the validity of all URLs; if `FALSE`, returns a logical
  vector for each URL.

## Value

Logical: `TRUE` if all checks pass; `FALSE` otherwise.

## Examples

``` r
urls <- c(
     "http://www.amazon.com", "http://this.isafakelink.biz",
     "https://stackoverflow.com", "https://stackoverflow505.com")

check_url(urls)
#> [1] FALSE

check_url(urls, all_okay = FALSE)
#> [1]  TRUE FALSE  TRUE FALSE
```
