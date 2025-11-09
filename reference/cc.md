# Concatenate without quotes

Concatenates one or more inputs into a single string without quotes.
Inputs can be unquoted symbols (e.g., variable names), quoted strings,
numbers, or simple expressions. Useful for creating strings from
variable names or data without including quotes.

## Usage

``` r
cc(..., collapse = NULL, unique = FALSE, sort = FALSE)
```

## Arguments

- ...:

  One or more inputs: unquoted symbols (e.g., `A`, `B`), quoted strings
  (e.g., `"text"`), numbers (e.g., `10`), or simple expressions (e.g.,
  `1:3`). Invalid R symbols (e.g., `12a`) will cause an error unless
  quoted.

- collapse:

  An optional single character string to separate concatenated elements
  (e.g., `""`, " "`or`","`). If `NULL\` (default), returns a character
  vector of individual elements.

- unique:

  Logical. If `TRUE`, returns only unique values. Default is `FALSE`.

- sort:

  Logical. If `TRUE`, sorts the result alphanumerically using
  [gtools::mixedsort](https://rdrr.io/pkg/gtools/man/mixedsort.html).
  Default is `FALSE`.

## Value

A single character string with concatenated inputs (if `collapse` is a
string) or a character vector (if \`collapse = NULL“).

## Author

Ahmed El-Gabbas

## Examples
