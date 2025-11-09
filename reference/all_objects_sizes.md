# Size of objects in memory

This function calculates the size of objects in the global environment
of R using
[lobstr::obj_size](https://lobstr.r-lib.org/reference/obj_size.html) and
prints a summary of objects that are greater than a specified size
threshold. It is useful for memory management and identifying large
objects in the workspace.

## Usage

``` r
all_objects_sizes(
  greater_than = 0L,
  in_function = FALSE,
  n_decimals = 2L,
  n_objects = Inf
)
```

## Arguments

- greater_than:

  Numeric. Size threshold in MB. Only objects larger than this value
  will be shown. Default is 0, which means all objects will be shown.
  `greater_than` must be a non-negative number.

- in_function:

  Logical. This controls the scope of the function. It indicates whether
  the execution is done inside or outside of a function. Defaults to
  `FALSE` to show sizes of objects in the global environment. If set to
  `TRUE`, sizes of objects in the function are returned.

- n_decimals:

  Integer; representing the number of decimal places to show in the
  `size_mb` column. Defaults to 2.

- n_objects:

  Number of objects to show. Defaults to `Inf` meaning show all
  available objects.

## Value

The function prints a tibble containing the variables' names, their
sizes in MB, and their percentage of the total size of all variables. If
no objects meet the criteria, a message is printed instead. Output is
sorted in descending order of the size of the objects. The function also
prints the total size of all variables and the number of objects that
were examined.

## Author

Ahmed El-Gabbas

## Examples

``` r
AA1 <<- rep(seq_len(1000), 10000)
AA2 <<- rep(seq_len(1000), 100)

# ----------------------------------------------------
# All objects in memory
# ----------------------------------------------------

all_objects_sizes()
#> ---------------------------------------------------
#>    3 object(s) fulfil the criteria
#> ---------------------------------------------------
#> # A tibble: 3 × 4
#>   object       object_class size_mb percent
#>   <chr>        <chr>          <dbl>   <dbl>
#> 1 AA1          integer        38.15   99.01
#> 2 AA2          integer         0.38    0.99
#> 3 .Random.seed integer         0       0   


# ----------------------------------------------------
# Objects larger than 1 MB
# ----------------------------------------------------

all_objects_sizes(greater_than = 1)
#> ---------------------------------------------------
#>    1 object(s) fulfil the criteria
#> ---------------------------------------------------
#> # A tibble: 1 × 4
#>   object object_class size_mb percent
#>   <chr>  <chr>          <dbl>   <dbl>
#> 1 AA1    integer        38.15   99.01


# ----------------------------------------------------
# Objects larger than 50 MB
# ----------------------------------------------------

all_objects_sizes(greater_than = 50)
#> No object has Size > 50 MB
#> 


# ----------------------------------------------------
# When called with another function, it shows the objects only available
# within the function
# ----------------------------------------------------

TestFun <- function(XX = 10) {
  Y <- 20
  C <- matrix(data = seq_len(10000), nrow = 100, ncol = 100)
  all_objects_sizes(in_function = TRUE)
}

TestFun()
#> ---------------------------------------------------
#>    3 object(s) fulfil the criteria
#> ---------------------------------------------------
#> # A tibble: 3 × 4
#>   object object_class size_mb percent
#>   <chr>  <chr>          <dbl>   <dbl>
#> 1 C      matrix_array    0.04     100
#> 2 XX     numeric         0          0
#> 3 Y      numeric         0          0

TestFun(XX = "TEST")
#> ---------------------------------------------------
#>    3 object(s) fulfil the criteria
#> ---------------------------------------------------
#> # A tibble: 3 × 4
#>   object object_class size_mb percent
#>   <chr>  <chr>          <dbl>   <dbl>
#> 1 C      matrix_array    0.04     100
#> 2 XX     character       0          0
#> 3 Y      numeric         0          0
```
