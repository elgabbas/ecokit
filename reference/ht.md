# Print head and tail of a data frame or vector with indices

Prints the first and last few rows of a data frame or elements of a
vector, displaying row numbers for data frames or indices for vectors in
a style similar to `data.table`. Useful for quickly inspecting the
structure and contents of large data frames or vectors, with explicit
row or index numbers.

## Usage

``` r
ht(data = NULL, n_rows = 5L)
```

## Arguments

- data:

  A data frame or vector (numeric, character, or other atomic types).
  This parameter cannot be `NULL`.

- n_rows:

  Integer. Number of rows (for data frames) or elements (for vectors) to
  print from both the head and tail. Defaults to 5.

## Value

The function is used for its side effect (printing) and returns
`invisible(NULL)`.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Data frame examples

ht(mtcars)
#>       mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>     <num> <num> <num> <num> <num> <num> <num> <num> <num> <num> <num>
#>  1:  21.0     6 160.0   110  3.90 2.620 16.46     0     1     4     4
#>  2:  21.0     6 160.0   110  3.90 2.875 17.02     0     1     4     4
#>  3:  22.8     4 108.0    93  3.85 2.320 18.61     1     1     4     1
#>  4:  21.4     6 258.0   110  3.08 3.215 19.44     1     0     3     1
#>  5:  18.7     8 360.0   175  3.15 3.440 17.02     0     0     3     2
#> ---                                                                  
#> 28:  30.4     4  95.1   113  3.77 1.513 16.90     1     1     5     2
#> 29:  15.8     8 351.0   264  4.22 3.170 14.50     0     1     5     4
#> 30:  19.7     6 145.0   175  3.62 2.770 15.50     0     1     5     6
#> 31:  15.0     8 301.0   335  3.54 3.570 14.60     0     1     5     8
#> 32:  21.4     4 121.0   109  4.11 2.780 18.60     1     1     4     2

ht(data = mtcars, n_rows = 2)
#>       mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>     <num> <num> <num> <num> <num> <num> <num> <num> <num> <num> <num>
#>  1:  21.0     6   160   110  3.90 2.620 16.46     0     1     4     4
#>  2:  21.0     6   160   110  3.90 2.875 17.02     0     1     4     4
#> ---                                                                  
#> 31:  15.0     8   301   335  3.54 3.570 14.60     0     1     5     8
#> 32:  21.4     4   121   109  4.11 2.780 18.60     1     1     4     2

ht(data = mtcars, n_rows = 6)
#>       mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>     <num> <num> <num> <num> <num> <num> <num> <num> <num> <num> <num>
#>  1:  21.0     6 160.0   110  3.90 2.620 16.46     0     1     4     4
#>  2:  21.0     6 160.0   110  3.90 2.875 17.02     0     1     4     4
#>  3:  22.8     4 108.0    93  3.85 2.320 18.61     1     1     4     1
#>  4:  21.4     6 258.0   110  3.08 3.215 19.44     1     0     3     1
#>  5:  18.7     8 360.0   175  3.15 3.440 17.02     0     0     3     2
#>  6:  18.1     6 225.0   105  2.76 3.460 20.22     1     0     3     1
#> ---                                                                  
#> 27:  26.0     4 120.3    91  4.43 2.140 16.70     0     1     5     2
#> 28:  30.4     4  95.1   113  3.77 1.513 16.90     1     1     5     2
#> 29:  15.8     8 351.0   264  4.22 3.170 14.50     0     1     5     4
#> 30:  19.7     6 145.0   175  3.62 2.770 15.50     0     1     5     6
#> 31:  15.0     8 301.0   335  3.54 3.570 14.60     0     1     5     8
#> 32:  21.4     4 121.0   109  4.11 2.780 18.60     1     1     4     2

# -------------------------------------------

# Vector examples

ht(1:100)
#>      value
#>      <int>
#>   1:     1
#>   2:     2
#>   3:     3
#>   4:     4
#>   5:     5
#>  ---      
#>  96:    96
#>  97:    97
#>  98:    98
#>  99:    99
#> 100:   100

ht(letters)
#>      value
#>     <char>
#>  1:      a
#>  2:      b
#>  3:      c
#>  4:      d
#>  5:      e
#> ---       
#> 22:      v
#> 23:      w
#> 24:      x
#> 25:      y
#> 26:      z

colour_vect <- colours()
colour_vect <- seq_along(colour_vect) %>%
  stats::setNames(paste0("colour:", colour_vect))
head(colour_vect)
#>         colour:white     colour:aliceblue  colour:antiquewhite 
#>                    1                    2                    3 
#> colour:antiquewhite1 colour:antiquewhite2 colour:antiquewhite3 
#>                    4                    5                    6 
ht(colour_vect)
#>                      name value
#>                    <char> <int>
#>   1:         colour:white     1
#>   2:     colour:aliceblue     2
#>   3:  colour:antiquewhite     3
#>   4: colour:antiquewhite1     4
#>   5: colour:antiquewhite2     5
#>  ---                           
#> 653:       colour:yellow1   653
#> 654:       colour:yellow2   654
#> 655:       colour:yellow3   655
#> 656:       colour:yellow4   656
#> 657:   colour:yellowgreen   657
```
