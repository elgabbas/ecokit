# Print separator(s) to the console

This function prints customizable separator lines to the console,
optionally preceded and followed by empty lines. It is useful for
improving the readability of console output in R scripts or during
interactive sessions.

## Usage

``` r
cat_sep(
  n_separators = 1L,
  sep_lines_before = 0L,
  sep_lines_after = 1L,
  line_char = "-",
  line_char_rep = 50L,
  cat_bold = FALSE,
  cat_red = FALSE,
  verbose = TRUE,
  ...
)
```

## Arguments

- n_separators:

  integer; the number of separator lines to print. Default is `1`.

- sep_lines_before, sep_lines_after:

  integer; the number of extra empty lines to print before and after the
  separator lines. Default is `0` and `1`, respectively.

- line_char:

  character; the character used to construct the separator line. Default
  is `"-"`.

- line_char_rep:

  integer; the number of times the character is repeated to form a
  separator line. Default is `50`.

- cat_bold:

  logical; whether to print the text in bold. Default is `FALSE`.

- cat_red:

  logical; whether to print the text in red. Default is `FALSE`.

- verbose:

  logical; whether to print output to console. Default is `TRUE`. If
  `FALSE`, the function does nothing. This is useful to suppress the
  function output in certain contexts.

- ...:

  additional arguments to be passed to
  [`base::cat()`](https://rdrr.io/r/base/cat.html).

## Value

The function is called for its side effect (printing to the console) and
does not return a meaningful value.

## Author

Ahmed El-Gabbas

## Examples

``` r
cat_sep()
#> --------------------------------------------------

cat_sep(n_separators = 2)
#> --------------------------------------------------
#> --------------------------------------------------

cat_sep(n_separators = 2, sep_lines_before = 2, sep_lines_after = 3)
#> 
#> 
#> --------------------------------------------------
#> --------------------------------------------------
#> 
#> 

cat_sep(
  n_separators = 2, sep_lines_before = 2,
  sep_lines_after = 3, line_char = "*")
#> 
#> 
#> **************************************************
#> **************************************************
#> 
#> 

cat_sep(
  n_separators = 2, sep_lines_before = 2,
  sep_lines_after = 3, line_char = "*", line_char_rep = 20)
#> 
#> 
#> ********************
#> ********************
#> 
#> 
```
