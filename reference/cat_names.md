# Print Names of an Object with Optional Sorting

Prints the names of an object to the console, with an option to sort
them. Supports custom separators and handles various edge cases.

## Usage

``` r
cat_names(x, sort = FALSE, sep = "\n", na_rm = TRUE, prefix = NULL, ...)
```

## Arguments

- x:

  An R object with names attribute (e.g., vector, list, data frame).

- sort:

  Logical. Whether to sort names using mixed alphanumeric sorting.
  Defaults to `FALSE`.

- sep:

  Character. Separate names in output. Defaults to newline (`"\n"`).

- na_rm:

  Logical. Whether to removes `NA` values from names before printing.
  Defaults to `TRUE`.

- prefix:

  Character. string to prepend to each name. Defaults to `NULL`.

- ...:

  Additional arguments passed to
  [`base::cat()`](https://rdrr.io/r/base/cat.html).

## Value

Invisibly returns the vector of names (sorted if `sort = TRUE`).

## Author

Ahmed El-Gabbas

## Examples

``` r
# Basic usage
vec <- c(a1 = 1, b = 2, a2 = 3)
cat_names(vec)
#> a1
#> b
#> a2

# Sorted names
cat_names(vec, sort = TRUE)
#> a1
#> a2
#> b

# Custom separator and prefix
cat_names(vec, sep = ", ", prefix = "- ")
#> - a1, - b, - a2

# Handle NA names
vec_na <- c(a = 1, NA, c = 3)
cat_names(vec_na, na_rm = TRUE)
#> a
#> 
#> c
cat_names(vec_na, na_rm = TRUE, sort = TRUE)
#> 
#> a
#> c

# Example with data frames
cat_names(mtcars)
#> mpg
#> cyl
#> disp
#> hp
#> drat
#> wt
#> qsec
#> vs
#> am
#> gear
#> carb
cat_names(iris)
#> Sepal.Length
#> Sepal.Width
#> Petal.Length
#> Petal.Width
#> Species
```
