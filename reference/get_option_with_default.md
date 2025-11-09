# Retrieve Option Value with Function Argument Default Fallback

This function returns the value of a specified R option if it is set;
otherwise, it falls back to the default value of a specified argument of
a given function. The function can be identified by name only or with
package qualification (e.g., `"pkg::fun"`). It supports arguments with
default values that are constants or quoted expressions.

## Usage

``` r
get_option_with_default(option_name, fun_name, arg_name)
```

## Arguments

- option_name:

  Character. The name of the R option to retrieve (e.g.,
  `"my_pkg_option"`).

- fun_name:

  Character. The name of the function, optionally qualified with a
  package (e.g., `"my_fun"` or `"mypkg::my_fun"`).

- arg_name:

  Character. The name of the argument whose default value should be used
  as a fallback.

## Value

The value of the option if set, otherwise the default value of the
specified function argument. Returns `NULL` if the default is not
accessible (e.g., for primitive or non-standard functions).

## Details

**Important:** This function only works for standard R functions whose
default argument values are accessible via
[`formals()`](https://rdrr.io/r/base/formals.html). It does **not** work
for primitive functions (such as `max`, `mean`), functions implemented
in C/C++, S4 methods, or functions whose defaults are not accessible
programmatically.

## Author

Ahmed El-Gabbas

## Examples

``` r
# No option is called `.add_changed`
getOption(".add_changed")
#> NULL

# return the default value of the `.add` argument of `dplyr::group_by()`
get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#> [1] FALSE

# Setting and retrieving the option
options(.add_changed = TRUE)
get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#> [1] TRUE

# Removing the option, should fall back to default again
ecokit::remove_options(".add_changed")
get_option_with_default(".add_changed", "dplyr::group_by", ".add")
#> [1] FALSE

# Will return NULL for primitives:
get_option_with_default("base_max_na.rm", "base::max", "na.rm")
#> NULL
```
