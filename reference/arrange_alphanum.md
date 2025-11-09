# Arrange Dataframe Rows Alphanumerically

Sorts the rows of a dataframe based on one or more columns using
alphanumeric sorting order. Allows for specifying ascending or
descending order for each sorting column individually.

## Usage

``` r
arrange_alphanum(
  data = NULL,
  ...,
  desc = FALSE,
  na_last = TRUE,
  blank_last = FALSE,
  scientific = TRUE
)
```

## Arguments

- data:

  A dataframe or tibble to be sorted.

- ...:

  Unquoted names of the columns to sort by (e.g., v1, v2, etc.) Sorting
  is done sequentially based on the order of columns provided.

- desc:

  Logical value or vector. If a single `TRUE`, sorts all specified
  columns in descending alphanumeric order. If a single `FALSE`
  (default), sorts all in ascending order. If a logical vector, its
  length must match the number of columns specified in `...`,
  determining the sort order for each column respectively (e.g.,
  `c(FALSE, TRUE)` for ascending first column, descending second). `NA`
  values in `desc` are treated as `FALSE` (ascending). Columns must be
  character, numeric, or factor types for sorting.

- na_last:

  for controlling the treatment of `NA` values. If `TRUE`, missing
  values in the data are put last; if `FALSE`, they are put first; if
  `NA`, they are removed. See
  [gtools::mixedsort](https://rdrr.io/pkg/gtools/man/mixedsort.html) for
  more details.

- blank_last:

  for controlling the treatment of blank values. If `TRUE`, blank values
  in the data are put last; if `FALSE`, they are put first; if `NA`,
  they are removed. See
  [gtools::mixedsort](https://rdrr.io/pkg/gtools/man/mixedsort.html) for
  more details.

- scientific:

  logical. Should exponential notation be allowed for numeric values.
  See [gtools::mixedsort](https://rdrr.io/pkg/gtools/man/mixedsort.html)
  for more details.

## Value

A dataframe sorted according to the specified columns and orders.

## Note

The `arrange_alphanum` function sorts dataframe rows alphanumerically,
handling mixed numeric and character strings correctly (e.g., "A1",
"A10", "A2" as "A1", "A2", "A10"), whereas
[dplyr::arrange](https://dplyr.tidyverse.org/reference/arrange.html)
uses standard lexicographic sorting, which may order them incorrectly
(e.g., "A1", "A10", "A2").

## Author

Ahmed El-Gabbas

## Examples

``` r
# increase the number of printed rows
options(pillar.print_max = 40)
load_packages(dplyr, tidyr, tibble)

# create a sample dataframe
set.seed(100)
(df <- tidyr::expand_grid(
  v1 = c("A1", "A2", "A10", "A010", "A25"),
  v2 = c("P1", "P2"), v3 = c(10, 5, 1, 15)) %>%
  dplyr::slice_sample(n = 40))
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A2    P1        5
#>  2 A25   P2        5
#>  3 A010  P1       10
#>  4 A2    P2        5
#>  5 A10   P2        1
#>  6 A10   P2        5
#>  7 A1    P2        5
#>  8 A1    P1       15
#>  9 A25   P1       15
#> 10 A25   P1        5
#> 11 A1    P1        5
#> 12 A1    P2        1
#> 13 A010  P2       10
#> 14 A010  P2       15
#> 15 A2    P1        1
#> 16 A10   P2       15
#> 17 A10   P1        5
#> 18 A2    P1       15
#> 19 A1    P1        1
#> 20 A10   P1        1
#> 21 A1    P2       15
#> 22 A25   P2        1
#> 23 A010  P2        5
#> 24 A25   P1       10
#> 25 A10   P1       10
#> 26 A25   P2       10
#> 27 A2    P2       15
#> 28 A1    P2       10
#> 29 A010  P1        5
#> 30 A010  P1       15
#> 31 A2    P1       10
#> 32 A2    P2        1
#> 33 A10   P2       10
#> 34 A010  P2        1
#> 35 A2    P2       10
#> 36 A010  P1        1
#> 37 A10   P1       15
#> 38 A25   P2       15
#> 39 A1    P1       10
#> 40 A25   P1        1

# sort by v1 (ascending)
# arrange function does not sort alphanumerically
dplyr::arrange(df, v1)
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A010  P1       10
#>  2 A010  P2       10
#>  3 A010  P2       15
#>  4 A010  P2        5
#>  5 A010  P1        5
#>  6 A010  P1       15
#>  7 A010  P2        1
#>  8 A010  P1        1
#>  9 A1    P2        5
#> 10 A1    P1       15
#> 11 A1    P1        5
#> 12 A1    P2        1
#> 13 A1    P1        1
#> 14 A1    P2       15
#> 15 A1    P2       10
#> 16 A1    P1       10
#> 17 A10   P2        1
#> 18 A10   P2        5
#> 19 A10   P2       15
#> 20 A10   P1        5
#> 21 A10   P1        1
#> 22 A10   P1       10
#> 23 A10   P2       10
#> 24 A10   P1       15
#> 25 A2    P1        5
#> 26 A2    P2        5
#> 27 A2    P1        1
#> 28 A2    P1       15
#> 29 A2    P2       15
#> 30 A2    P1       10
#> 31 A2    P2        1
#> 32 A2    P2       10
#> 33 A25   P2        5
#> 34 A25   P1       15
#> 35 A25   P1        5
#> 36 A25   P2        1
#> 37 A25   P1       10
#> 38 A25   P2       10
#> 39 A25   P2       15
#> 40 A25   P1        1

# arrange_alphanum function sorts alphanumerically
arrange_alphanum(df, v1)
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A1    P2        5
#>  2 A1    P1       15
#>  3 A1    P1        5
#>  4 A1    P2        1
#>  5 A1    P1        1
#>  6 A1    P2       15
#>  7 A1    P2       10
#>  8 A1    P1       10
#>  9 A2    P1        5
#> 10 A2    P2        5
#> 11 A2    P1        1
#> 12 A2    P1       15
#> 13 A2    P2       15
#> 14 A2    P1       10
#> 15 A2    P2        1
#> 16 A2    P2       10
#> 17 A010  P1       10
#> 18 A010  P2       10
#> 19 A010  P2       15
#> 20 A010  P2        5
#> 21 A010  P1        5
#> 22 A010  P1       15
#> 23 A010  P2        1
#> 24 A010  P1        1
#> 25 A10   P2        1
#> 26 A10   P2        5
#> 27 A10   P2       15
#> 28 A10   P1        5
#> 29 A10   P1        1
#> 30 A10   P1       10
#> 31 A10   P2       10
#> 32 A10   P1       15
#> 33 A25   P2        5
#> 34 A25   P1       15
#> 35 A25   P1        5
#> 36 A25   P2        1
#> 37 A25   P1       10
#> 38 A25   P2       10
#> 39 A25   P2       15
#> 40 A25   P1        1
# arrange_alphanum(df, v1, desc = FALSE)                    # the same
# arrange_alphanum(df, v1, desc = NA)                       # the same

# sort first by v2 (ascending), then by v1 (ascending)
arrange_alphanum(df, v2, v1)
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A1    P1       15
#>  2 A1    P1        5
#>  3 A1    P1        1
#>  4 A1    P1       10
#>  5 A2    P1        5
#>  6 A2    P1        1
#>  7 A2    P1       15
#>  8 A2    P1       10
#>  9 A010  P1       10
#> 10 A010  P1        5
#> 11 A010  P1       15
#> 12 A010  P1        1
#> 13 A10   P1        5
#> 14 A10   P1        1
#> 15 A10   P1       10
#> 16 A10   P1       15
#> 17 A25   P1       15
#> 18 A25   P1        5
#> 19 A25   P1       10
#> 20 A25   P1        1
#> 21 A1    P2        5
#> 22 A1    P2        1
#> 23 A1    P2       15
#> 24 A1    P2       10
#> 25 A2    P2        5
#> 26 A2    P2       15
#> 27 A2    P2        1
#> 28 A2    P2       10
#> 29 A010  P2       10
#> 30 A010  P2       15
#> 31 A010  P2        5
#> 32 A010  P2        1
#> 33 A10   P2        1
#> 34 A10   P2        5
#> 35 A10   P2       15
#> 36 A10   P2       10
#> 37 A25   P2        5
#> 38 A25   P2        1
#> 39 A25   P2       10
#> 40 A25   P2       15
# arrange_alphanum(df, v2, v1, desc = FALSE)                # the same
# arrange_alphanum(df, v2, v1, desc = c(FALSE, FALSE))      # the same

# sort by v2 (ascending), then v1 (descending)
arrange_alphanum(df, v2, v1, desc = c(FALSE, TRUE))
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A25   P1       15
#>  2 A25   P1        5
#>  3 A25   P1       10
#>  4 A25   P1        1
#>  5 A10   P1        5
#>  6 A10   P1        1
#>  7 A10   P1       10
#>  8 A10   P1       15
#>  9 A010  P1       10
#> 10 A010  P1        5
#> 11 A010  P1       15
#> 12 A010  P1        1
#> 13 A2    P1        5
#> 14 A2    P1        1
#> 15 A2    P1       15
#> 16 A2    P1       10
#> 17 A1    P1       15
#> 18 A1    P1        5
#> 19 A1    P1        1
#> 20 A1    P1       10
#> 21 A25   P2        5
#> 22 A25   P2        1
#> 23 A25   P2       10
#> 24 A25   P2       15
#> 25 A10   P2        1
#> 26 A10   P2        5
#> 27 A10   P2       15
#> 28 A10   P2       10
#> 29 A010  P2       10
#> 30 A010  P2       15
#> 31 A010  P2        5
#> 32 A010  P2        1
#> 33 A2    P2        5
#> 34 A2    P2       15
#> 35 A2    P2        1
#> 36 A2    P2       10
#> 37 A1    P2        5
#> 38 A1    P2        1
#> 39 A1    P2       15
#> 40 A1    P2       10

# sort by v2 (descending), then v1 (ascending)
arrange_alphanum(df, v2, v1, desc = c(TRUE, FALSE))
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A1    P2        5
#>  2 A1    P2        1
#>  3 A1    P2       15
#>  4 A1    P2       10
#>  5 A2    P2        5
#>  6 A2    P2       15
#>  7 A2    P2        1
#>  8 A2    P2       10
#>  9 A010  P2       10
#> 10 A010  P2       15
#> 11 A010  P2        5
#> 12 A010  P2        1
#> 13 A10   P2        1
#> 14 A10   P2        5
#> 15 A10   P2       15
#> 16 A10   P2       10
#> 17 A25   P2        5
#> 18 A25   P2        1
#> 19 A25   P2       10
#> 20 A25   P2       15
#> 21 A1    P1       15
#> 22 A1    P1        5
#> 23 A1    P1        1
#> 24 A1    P1       10
#> 25 A2    P1        5
#> 26 A2    P1        1
#> 27 A2    P1       15
#> 28 A2    P1       10
#> 29 A010  P1       10
#> 30 A010  P1        5
#> 31 A010  P1       15
#> 32 A010  P1        1
#> 33 A10   P1        5
#> 34 A10   P1        1
#> 35 A10   P1       10
#> 36 A10   P1       15
#> 37 A25   P1       15
#> 38 A25   P1        5
#> 39 A25   P1       10
#> 40 A25   P1        1

# sort by v2 (descending), v1 (descending)
arrange_alphanum(df, v2, v1, desc = TRUE)
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A25   P2        5
#>  2 A25   P2        1
#>  3 A25   P2       10
#>  4 A25   P2       15
#>  5 A10   P2        1
#>  6 A10   P2        5
#>  7 A10   P2       15
#>  8 A10   P2       10
#>  9 A010  P2       10
#> 10 A010  P2       15
#> 11 A010  P2        5
#> 12 A010  P2        1
#> 13 A2    P2        5
#> 14 A2    P2       15
#> 15 A2    P2        1
#> 16 A2    P2       10
#> 17 A1    P2        5
#> 18 A1    P2        1
#> 19 A1    P2       15
#> 20 A1    P2       10
#> 21 A25   P1       15
#> 22 A25   P1        5
#> 23 A25   P1       10
#> 24 A25   P1        1
#> 25 A10   P1        5
#> 26 A10   P1        1
#> 27 A10   P1       10
#> 28 A10   P1       15
#> 29 A010  P1       10
#> 30 A010  P1        5
#> 31 A010  P1       15
#> 32 A010  P1        1
#> 33 A2    P1        5
#> 34 A2    P1        1
#> 35 A2    P1       15
#> 36 A2    P1       10
#> 37 A1    P1       15
#> 38 A1    P1        5
#> 39 A1    P1        1
#> 40 A1    P1       10
# arrange_alphanum(df, v2, v1, desc = c(TRUE, TRUE))        # the same

# sort by v2 (descending), v1 (ascending), v3 (descending)
arrange_alphanum(df, v2, v1, v3, desc = c(TRUE, FALSE, TRUE))
#> # A tibble: 40 × 3
#>    v1    v2       v3
#>    <chr> <chr> <dbl>
#>  1 A1    P2       15
#>  2 A1    P2       10
#>  3 A1    P2        5
#>  4 A1    P2        1
#>  5 A2    P2       15
#>  6 A2    P2       10
#>  7 A2    P2        5
#>  8 A2    P2        1
#>  9 A010  P2       15
#> 10 A010  P2       10
#> 11 A010  P2        5
#> 12 A010  P2        1
#> 13 A10   P2       15
#> 14 A10   P2       10
#> 15 A10   P2        5
#> 16 A10   P2        1
#> 17 A25   P2       15
#> 18 A25   P2       10
#> 19 A25   P2        5
#> 20 A25   P2        1
#> 21 A1    P1       15
#> 22 A1    P1       10
#> 23 A1    P1        5
#> 24 A1    P1        1
#> 25 A2    P1       15
#> 26 A2    P1       10
#> 27 A2    P1        5
#> 28 A2    P1        1
#> 29 A010  P1       15
#> 30 A010  P1       10
#> 31 A010  P1        5
#> 32 A010  P1        1
#> 33 A10   P1       15
#> 34 A10   P1       10
#> 35 A10   P1        5
#> 36 A10   P1        1
#> 37 A25   P1       15
#> 38 A25   P1       10
#> 39 A25   P1        5
#> 40 A25   P1        1

# -----------------------------------------------

# Example with NA and blank strings
(df_special <- tibble::tibble(v1 = c("A", "", "B", NA, "C")))
#> # A tibble: 5 × 1
#>   v1   
#>   <chr>
#> 1 "A"  
#> 2 ""   
#> 3 "B"  
#> 4  NA  
#> 5 "C"  

# sort with NA first, blanks first (default)
arrange_alphanum(df_special, v1, na_last = FALSE, blank_last = FALSE)
#> # A tibble: 5 × 1
#>   v1   
#>   <chr>
#> 1 ""   
#> 2 "A"  
#> 3 "B"  
#> 4 "C"  
#> 5  NA  

# sort with NA last, blanks last
arrange_alphanum(df_special, v1, na_last = TRUE, blank_last = TRUE)
#> # A tibble: 5 × 1
#>   v1   
#>   <chr>
#> 1 "A"  
#> 2 "B"  
#> 3 "C"  
#> 4 ""   
#> 5  NA  
```
