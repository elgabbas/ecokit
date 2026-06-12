# Validate a Named List Against Required Elements

Checks that `x` is a named list whose elements match `valid_names`. A
contextual error is raised via
[`stop_ctx()`](https://elgabbas.github.io/ecokit/reference/stop_ctx.md)
if any check fails, reporting missing or unexpected names where
relevant.

## Usage

``` r
validate_named_list(
  x,
  valid_names,
  object_name = deparse(substitute(x)),
  exact_length = TRUE
)
```

## Arguments

- x:

  A named list to validate.

- valid_names:

  Character vector of required element names. Order is ignored;
  validation uses set equality.

- object_name:

  Character string used in error messages to identify `x`. Defaults to
  the unevaluated name of `x`.

- exact_length:

  Logical. If `TRUE` (default), `x` must contain exactly
  `length(valid_names)` elements. If `FALSE`, only names are checked.

## Value

Invisibly returns `TRUE` if all checks pass.

## See also

[`stop_ctx()`](https://elgabbas.github.io/ecokit/reference/stop_ctx.md)

## Author

Ahmed El-Gabbas

## Examples

``` r
valid_names <- c("a", "b", "c")
validate_named_list(list(a = 1, b = 2, c = 3), valid_names)

if (FALSE) { # \dontrun{
validate_named_list(list(a = 1, b = 2), valid_names)
validate_named_list(list(a = 1, b = 2, d = 3), valid_names)
} # }
```
