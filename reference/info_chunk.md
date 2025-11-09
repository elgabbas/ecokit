# Print Information chunk with time stamp

This function prints a formatted message with a timestamp, surrounded by
separators for better readability in console outputs or logs.

## Usage

``` r
info_chunk(
  message = "",
  cat_date = TRUE,
  sep_lines_before = 0L,
  sep_lines_after = 1L,
  cat_bold = FALSE,
  cat_red = FALSE,
  cat_timestamp = FALSE,
  level = 0L,
  msg_n_lines = 1L,
  info_lines_before = 0L,
  verbose = TRUE,
  ...
)
```

## Arguments

- message:

  Character. The main message to be timestamped. This parameter is
  mandatory and cannot be `NULL` or empty.

- cat_date:

  Logical. Whether to include the date in the timestamp. Default is
  `FALSE`, meaning only the time is printed. See
  [cat_time](https://elgabbas.github.io/ecokit/reference/cat_time.md).

- sep_lines_before, sep_lines_after:

  Integer. Number of extra empty lines to print before and after the
  separator lines. See
  [cat_sep](https://elgabbas.github.io/ecokit/reference/cat_sep.md) for
  more details.

- cat_bold:

  logical; whether to print the text in bold. Default is `FALSE`.

- cat_red:

  logical; whether to print the text in red. Default is `FALSE`.

- cat_timestamp:

  Logical. Whether to include the time in the timestamp. Default is
  `FALSE`.

- level:

  integer; the level at which the message will be printed. If e.g.
  `level = 1L`, the following string will be printed at the beginning of
  the message: " \>\>\> ". Default is `0`.

- msg_n_lines:

  integer; the number of newline characters to print after the message.
  Default is 1.

- info_lines_before:

  Integer. Number of extra empty lines to print before the message.
  Default is `0L`.

- verbose:

  logical; whether to print output to console. Default is `TRUE`. If
  `FALSE`, the function does nothing. This is useful to suppress the
  function output in certain contexts.

- ...:

  Additional arguments passed to
  [cat_sep](https://elgabbas.github.io/ecokit/reference/cat_sep.md) for
  customizing the separators.

## Value

The function does not return any value but prints the message and
separators to the console.

## Author

Ahmed El-Gabbas

## Examples

``` r
info_chunk(message = "Started")
#> 
#> --------------------------------------------------
#> Started - 09/11/2025
#> --------------------------------------------------
#> 

info_chunk(message = "finished", line_char = "*", line_char_rep = 60)
#> 
#> ************************************************************
#> finished - 09/11/2025
#> ************************************************************
#> 

info_chunk(message = "Started", cat_bold =  TRUE, cat_red = TRUE)
#> 
#> --------------------------------------------------
#> Started - 09/11/2025
#> --------------------------------------------------
#> 
```
