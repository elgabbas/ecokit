# Print time difference

This function calculates the time difference from a given initial time
to the current time and prints it with a specified prefix. Optionally,
it can also print a session summary.

## Usage

``` r
cat_diff(
  init_time,
  chunk_text = "Session summary",
  prefix = "Completed in ",
  cat_info = FALSE,
  level = 0L,
  cat_timestamp = FALSE,
  verbose = TRUE,
  ...
)
```

## Arguments

- init_time:

  `POSIXct`. The initial time from which the difference is calculated.

- chunk_text:

  Character. The message printed as chunk info. Default value:
  `Session summary`. See:
  [info_chunk](https://elgabbas.github.io/ecokit/reference/info_chunk.md)
  for more information.

- prefix:

  Character. prefix to prepend to the printed time difference. Defaults
  to "Completed in ".

- cat_info:

  Logical. If `TRUE`, prints a session summary using
  [info_chunk](https://elgabbas.github.io/ecokit/reference/info_chunk.md)
  ("Session summary"). Defaults to `FALSE`.

- level:

  integer; the level at which the message will be printed. If e.g.
  `level = 1L`, the following string will be printed at the beginning of
  the message: " \>\>\> ". Default is `0`.

- cat_timestamp:

  logical; whether to include the time in the timestamp. Default is
  `TRUE`. If `FALSE`, only the text is printed.

- verbose:

  logical; whether to print output to console. Default is `TRUE`. If
  `FALSE`, the function does nothing. This is useful to suppress the
  function output in certain contexts.

- ...:

  Additional arguments for
  [cat_time](https://elgabbas.github.io/ecokit/reference/cat_time.md).

## Value

The function is used for its side effect of printing to the console and
does not return any value.

## Author

Ahmed El-Gabbas

## Examples

``` r
# basic usage
reference_time <- (lubridate::now() - lubridate::seconds(45))

cat_diff(reference_time)
#> Completed in 00:00:45

# custom prefix text
cat_diff(reference_time, prefix = "Finished in ")
#> Finished in 00:00:45

# level = 1
cat_diff(reference_time, prefix = "Finished in ", level = 1L)
#>   >>>  Finished in 00:00:45

# print date
cat_diff(reference_time, prefix = "Finished in ", cat_timestamp = TRUE)
#> Finished in 00:00:45 - 19:25:11

# print date and time
cat_diff(reference_time, prefix = "Finished in ", cat_date = TRUE)
#> Finished in 00:00:45 - 09/11/2025

# show chunk info
cat_diff(reference_time, cat_info = TRUE, prefix = "Finished in ")
#> 
#> --------------------------------------------------
#> Session summary - 09/11/2025
#> --------------------------------------------------
#> 
#> 
#> Finished in 00:00:45

# custom chunk info text
cat_diff(
  reference_time, cat_info = TRUE, chunk_text = "Summary of task",
  prefix = "Finished in ")
#> 
#> --------------------------------------------------
#> Summary of task - 09/11/2025
#> --------------------------------------------------
#> 
#> 
#> Finished in 00:00:45

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

reference_time <- (lubridate::now() -
    (lubridate::minutes(50) + lubridate::seconds(45)))
cat_diff(reference_time)
#> Completed in 00:50:45

reference_time <- (lubridate::now() - lubridate::minutes(50))
cat_diff(reference_time)
#> Completed in 00:50:00

reference_time <- (lubridate::now() - lubridate::minutes(70))
cat_diff(reference_time)
#> Completed in 01:10:00

reference_time <- (lubridate::now() - lubridate::hours(4))
cat_diff(reference_time)
#> Completed in 04:00:00

reference_time <- lubridate::now() -
  (lubridate::hours(4) + lubridate::minutes(50) + lubridate::seconds(45))
cat_diff(reference_time)
#> Completed in 04:50:45
```
