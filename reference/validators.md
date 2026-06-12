# Argument validation helpers for ecokit

A family of small, fast-failing validators used throughout `ecokit` (and
packages depending on it) to enforce argument types and formats —
particularly for HPC/SLURM job configuration (`mod_slurm()`) and
parallel processing setup
([`set_parallel()`](https://elgabbas.github.io/ecokit/reference/set_parallel.md)).

## Usage

``` r
is_integer(x)

validate_n_cores(x)

validate_strategy(x)

validate_slurm_runtime(x, warning = TRUE)

validate_slurm_ram(x)
```

## Arguments

- x:

  Input value

  - For `is_integer()` and `validate_n_cores()`, a numeric value to
    check.

  - For `validate_strategy()`, a character string naming a `future`
    strategy.

  - For `validate_slurm_runtime()` and `validate_slurm_ram()`, a
    character string with a SLURM time or memory specification.

- warning:

  Logical, used only by `validate_slurm_runtime()`. If `TRUE` (default),
  an invalid runtime string raises an error via
  [stop_ctx](https://elgabbas.github.io/ecokit/reference/stop_ctx.md).
  If `FALSE`, an invalid runtime string instead raises a
  [base::warning](https://rdrr.io/r/base/warning.html) and the function
  returns `FALSE`.

## Value

- `is_integer()`: a single logical (`TRUE`/`FALSE`) for numeric input;
  errors if `x` is `NULL`.

- `validate_n_cores()`: a single integer, clamped to
  [`parallelly::availableCores()`](https://parallelly.futureverse.org/reference/availableCores.html)
  if `x` exceeds it (with a warning).

- `validate_strategy()`, `validate_slurm_ram()`: the unchanged input `x`
  if valid; otherwise an error.

- `validate_slurm_runtime()`: the unchanged input `x` if valid;
  otherwise an error (`warning = TRUE`, default) or `FALSE` with a
  warning (`warning = FALSE`).

## Details

- `is_integer()`: checks whether `x` is a single positive whole-number
  value (e.g. `5`, `5L`, `5.0`). Returns `FALSE` for non-scalars, `NA`,
  zero, negative, non-integer, or non-numeric values (without erroring),
  but throws an error if `x` is `NULL`.

- `validate_n_cores()`: validates a requested core count `x`. Must be a
  positive integer scalar (checked via `is_integer()`; otherwise
  errors). If `x` exceeds
  [`parallelly::availableCores()`](https://parallelly.futureverse.org/reference/availableCores.html),
  a warning is issued and the number of available cores is used instead.

- `validate_strategy()`: validates a `future` parallelisation strategy
  name `x`. Must be one of `"sequential"`, `"multisession"`,
  `"multicore"`, or `"cluster"`.

- `validate_slurm_runtime()`: validates a SLURM `--time` string `x`.
  Accepted formats follow SLURM conventions: `"minutes"`,
  `"minutes:seconds"`, `"hours:minutes:seconds"`, `"days-hours"`,
  `"days-hours:minutes"`, or `"days-hours:minutes:seconds"`, with hours
  `00`-`23` and minutes/seconds `00`-`59`.

- `validate_slurm_ram()`: validates a SLURM `--mem` string `x`. Must be
  a positive integer immediately followed by an uppercase unit: `K`,
  `M`, `G`, `T`, or their long forms `KB`, `MB`, `GB`, `TB`.

## Author

Ahmed El-Gabbas

## Examples

``` r
# is_integer
is_integer(5)
#> [1] FALSE
is_integer(5L)
#> [1] TRUE
is_integer(5.5)
#> [1] FALSE
is_integer(-1)
#> [1] FALSE
is_integer(NA)
#> [1] FALSE
is_integer(c(1, 2))
#> [1] FALSE
is_integer("5")
#> [1] FALSE

if (FALSE) { # \dontrun{
  is_integer(NULL) # Errors: `x` cannot be NULL
} # }


# validate_n_cores
validate_n_cores(2)
#> [1] 2

# Warns and is clamped to the number of available cores
validate_n_cores(1000L)
#> Warning: `x` (1000) exceeds available cores. Using all available cores (4)
#> [1] 4

if (FALSE) { # \dontrun{
  # Errors: not a positive integer scalar
  validate_n_cores(-1)
  validate_n_cores("2")
} # }


# validate_strategy
validate_strategy("multisession")
#> [1] "multisession"
if (FALSE) { # \dontrun{
  validate_strategy("parallel") # Errors: not a valid `future` strategy
} # }

# validate_slurm_runtime ----
validate_slurm_runtime("30")
#> [1] "30"
validate_slurm_runtime("2:00:00")
#> [1] "2:00:00"
validate_slurm_runtime("0-12:00:00")
#> [1] "0-12:00:00"
validate_slurm_runtime("5-23:59")
#> [1] "5-23:59"
validate_slurm_runtime("2:00")
#> [1] "2:00"

if (FALSE) { # \dontrun{
  validate_slurm_runtime("2:70:00")     # Errors: invalid minutes
  validate_slurm_runtime("12-24:00:00") # Errors: invalid hours
  validate_slurm_runtime("abc")         # Errors: not a SLURM time format
} # }

# Returns FALSE with a warning instead of erroring
validate_slurm_runtime("abc", warning = FALSE)
#> Warning: Invalid SLURM runtime format: `abc`
#> [1] FALSE


# validate_slurm_ram ----
validate_slurm_ram("8G")
#> [1] "8G"
validate_slurm_ram("1024M")
#> [1] "1024M"
validate_slurm_ram("32GB")
#> [1] "32GB"
validate_slurm_ram("1T")
#> [1] "1T"

if (FALSE) { # \dontrun{
  validate_slurm_ram("500")    # Errors: missing unit
  validate_slurm_ram("500m")   # Errors: lowercase unit not accepted
  validate_slurm_ram("4.5G")   # Errors: non-integer amount
  validate_slurm_ram("100MBs") # Errors: trailing characters
  validate_slurm_ram("GB32")   # Errors: unit before amount
} # }
```
