# Check function arguments for specific types

This function checks if the specified arguments of a function match the
expected type. It is useful for validating function inputs.

## Usage

``` r
check_args(args_to_check = NULL, args_type = NULL, arg_length = 1L, ...)
```

## Arguments

- args_to_check:

  Character vector. Names of the arguments to be checked.

- args_type:

  Character. The expected type of the arguments. Must be one of
  "character", "logical", or "numeric".

- arg_length:

  Numeric vector. Expected length of each argument in `args_to_check`.
  Default is 1L.

- ...:

  Additional arguments passed to
  [stop_ctx](https://elgabbas.github.io/ecokit/reference/stop_ctx.md).

## Value

The function does not return a value but will stop execution and throw
an error if any of the specified arguments do not match the expected
type.

## Author

Ahmed El-Gabbas

## Examples

``` r
f1 <- function(x = "AA", y = "BB", z = 1) {
 # Check if x and y are a character
 check_args(args_to_check = c("x", "y"), args_type = "character")

 # Check if z is a numeric
 check_args(args_to_check = "z", args_type = "numeric")
}

f1(x = "X", z = 20)
try(f1(x = 1))
#> Error in check_args(args_to_check = c("x", "y"), args_type = "character") : 
#>   The following argument(s) must be character
#> 
#> ----- Metadata -----
#> 
#> invalid_arguments [invalid_arguments]: <character>
#> x
#> 
#> length_MissingArgs [length(invalid_arguments)]: <integer>
#> 1

try(f1(x = c("X1", "x2", "x3"), y = c(20, 30)))
#> Error in check_args(args_to_check = c("x", "y"), args_type = "character") : 
#>   `arg_length` must match the length of the arguments
#> 
#> ----- Metadata -----
#> 
#> arguments [args_to_check[length_mismatches]]: <character>
#> x, y
#> 
#> lengths [lengths(arg_list[length_mismatches])]: <integer>
#> 3, 2
#> 
#> required_lengths [arg_length[length_mismatches]]: <integer>
#> 1, 1

f2 <- function(x = "AA", y = "BB", z = 1) {
 check_args(
  args_to_check = c("x", "y"), args_type = "character", arg_length = c(3, 2))
}
f2(x = c("X1", "x2", "x3"), y = c("20", "30"))
```
