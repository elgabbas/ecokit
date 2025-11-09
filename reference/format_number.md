# Format a numbers with thousands separator and crayon styles

Format numeric input using a specified thousands separator and
optionally apply crayon styling (`blue`, `red`, `underline`, `bold`). If
multiple numbers are provided they are formatted individually then
collapsed into a single comma-separated string.

## Usage

``` r
format_number(
  number = NULL,
  big_mark = ",",
  blue = TRUE,
  red = FALSE,
  bold = FALSE,
  underline = FALSE
)
```

## Arguments

- number:

  Numeric vector to format.

- big_mark:

  Character of length 1 used as the thousands separator (passed to
  `format(..., big.mark = big_mark)`). Must be non-NULL, non-empty, and
  of length 1. Default: `","`.

- blue:

  Logical; if `TRUE` (default) the formatted output is wrapped with
  [`crayon::blue()`](http://r-lib.github.io/crayon/reference/crayon.md).

- red:

  Logical; if `TRUE` the formatted output is wrapped with
  [`crayon::red()`](http://r-lib.github.io/crayon/reference/crayon.md).
  Default: `FALSE`.

- bold:

  Logical; if `TRUE` the formatted output is wrapped with
  [`crayon::bold()`](http://r-lib.github.io/crayon/reference/crayon.md).
  Default: `FALSE`.

- underline:

  Logical; if `TRUE` the formatted output is wrapped with
  [`crayon::underline()`](http://r-lib.github.io/crayon/reference/crayon.md).
  Default: `FALSE`.

## Value

A character scalar containing the formatted number(s) with the requested
`crayon` styling applied.

## Details

Input validation performed by the function:

- `big_mark` must not be `NULL`, must be a character of length 1, and
  must be non-empty.

- `number` must be numeric; otherwise an error is raised.

- `blue` and `red` cannot both be `TRUE` (mutually exclusive).

  The function first formats numbers using
  `format(..., big.mark = big_mark)`, which returns a character vector.
  If the numeric input has length greater than one, it collapses the
  formatted values into a single string using
  [`toString()`](https://rdrr.io/r/base/toString.html). Finally, the
  selected `crayon` styles are applied in sequence (`blue`, `red`,
  `underline`, `bold`) to the resulting character value.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Single number (default: blue)
cat(format_number(1234567))
#> 1,234,567

# Multiple numbers collapsed to a single string
cat(format_number(c(1000, 2000000)))
#>     1,000, 2,000,000

# Use a space as the thousands separator and apply red + bold
cat(
  format_number(
    1234567, big_mark = " ", blue = FALSE, red = TRUE, bold = TRUE))
#> 1 234 567
```
