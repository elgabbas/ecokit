# Retrieve a canonical parameter name from a HMSC coda object

Performs a case-insensitive lookup of a requested HMSC posterior
parameter name against the names in `obj`. Returns the exact name as
stored in the coda object (e.g. `"AlphaInd"` when HMSC \>= 3.4-0 is
used, or `"Alpha"` for older versions) so callers do not need to
hard-code version-specific names.

## Usage

``` r
coda_match_param(obj = NULL, param = NULL, warning = TRUE)
```

## Arguments

- obj:

  A named list (typically a HMSC coda object produced by
  [`Hmsc::convertToCodaObject()`](https://rdrr.io/pkg/Hmsc/man/convertToCodaObject.html)).
  Cannot be `NULL` or empty.

- param:

  Character. Parameter name to look up. Must be one of `"beta"`,
  `"alpha"`, `"omega"`, `"rho"`, or `"gamma"` (case-insensitive).

- warning:

  Logical. If `TRUE` (default), emit a warning when `param` is not found
  in `obj`.

## Value

The matched name as a character string, exactly as it appears in
`names(obj)`. Returns `NA_character_` when no match is found.

## Author

Ahmed El-Gabbas
