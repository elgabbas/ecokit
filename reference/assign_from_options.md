# Assign Argument Value from Option if NULL or Missing

This utility function is designed to be called from within another
function. If a function argument is missing or `NULL`, this function
attempts to assign a value from a global option. If neither the argument
nor the option is set, an informative error is thrown, unless
`allow_null = TRUE`, in which case `NULL` is allowed. Optionally, it
checks that the resulting value inherits from a specified class.

## Usage

``` r
assign_from_options(
  arg,
  option_name,
  expected_class = NULL,
  allow_null = FALSE
)
```

## Arguments

- arg:

  Bare name of the argument to check and (potentially) assign. Should be
  unquoted.

- option_name:

  Character. The name of the global option (as in
  [`getOption()`](https://rdrr.io/r/base/options.html)) to use as a
  fallback value.

- expected_class:

  Character vector or `NULL`; if not `NULL`, the result must inherit
  from one of these classes, otherwise an error is thrown.

- allow_null:

  Logical; if `TRUE`, both the argument and the global option are
  allowed to be `NULL` without error. If `FALSE` (default), an error is
  thrown if both are `NULL`.

## Value

Invisibly returns the final value of the argument (after assignment, if
performed).

## Details

This function is intended for use inside another function's body to help
set default argument values using global options.

- If the argument is missing, it assigns the value from
  `getOption(option_name)`, if available.

- If the argument is explicitly supplied but is `NULL`, it will also
  assign the value from the option if available.

- If neither the argument nor the option is set, an error is thrown,
  unless `allow_null = TRUE`, in which case `NULL` is allowed.

- If `expected_class` is provided, the final value is checked for class
  inheritance.

## Author

Ahmed El-Gabbas

## Examples

``` r
my_fun <- function(x = NULL) {
  ecokit::assign_from_options(x, "my_x_option", expected_class = "numeric")
  x  # x is now set from option if not provided
}

options(my_x_option = 42)

# returns 42
my_fun()
#> [1] 42

# returns 1.5
my_fun(1.5)
#> [1] 1.5

ecokit::remove_options("my_x_option")

# error: Argument `x` is missing/NULL and option `my_x_option` is not set.
try(my_fun())
#> Error in ecokit::assign_from_options(x, "my_x_option", expected_class = "numeric") : 
#>   Argument `x` is NULL and option `my_x_option` is not set. Provide `x` or set options(my_x_option = ...).
```
