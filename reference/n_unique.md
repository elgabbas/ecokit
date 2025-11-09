# Number of unique values for all columns of a data frame

This function calculates the number of unique values for each column in
a given data frame and returns a data frame with two columns: `variable`
and `n_unique`. The `variable` column lists the names of the original
columns, and the `n_unique` column lists the corresponding number of
unique values in each column.

## Usage

``` r
n_unique(data, arrange = TRUE)
```

## Source

The source code of the function was copied from this
[stackoverflow](https://stackoverflow.com/q/22196078) question.

## Arguments

- data:

  A data frame for which the number of unique values per column will be
  calculated.

- arrange:

  Logical. Whether to arrange the result in descending order of the
  number of unique values. Defaults to `TRUE`.

## Value

A data frame with two columns: `variable` and `n_unique`. The variable
column lists the names of the original columns, and the `n_unique`
column lists the number of unique values in each column.

## Author

Ahmed El-Gabbas

## Examples

``` r
# arranged by n_unique
n_unique(mtcars)
#> # A tibble: 11 × 2
#>    variable n_unique
#>    <chr>       <int>
#>  1 qsec           30
#>  2 wt             29
#>  3 disp           27
#>  4 mpg            25
#>  5 hp             22
#>  6 drat           22
#>  7 carb            6
#>  8 cyl             3
#>  9 gear            3
#> 10 vs              2
#> 11 am              2

# not arranged (keep original data order)
n_unique(mtcars, arrange = FALSE)
#> # A tibble: 11 × 2
#>    variable n_unique
#>    <chr>       <int>
#>  1 mpg            25
#>  2 cyl             3
#>  3 disp           27
#>  4 hp             22
#>  5 drat           22
#>  6 wt             29
#>  7 qsec           30
#>  8 vs              2
#>  9 am              2
#> 10 gear            3
#> 11 carb            6

n_unique(iris)
#> # A tibble: 5 × 2
#>   variable     n_unique
#>   <chr>           <int>
#> 1 Petal.Length       43
#> 2 Sepal.Length       35
#> 3 Sepal.Width        23
#> 4 Petal.Width        22
#> 5 Species             3

n_unique(iris, arrange = FALSE)
#> # A tibble: 5 × 2
#>   variable     n_unique
#>   <chr>           <int>
#> 1 Sepal.Length       35
#> 2 Sepal.Width        23
#> 3 Petal.Length       43
#> 4 Petal.Width        22
#> 5 Species             3
```
