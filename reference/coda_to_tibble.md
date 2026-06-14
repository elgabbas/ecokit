# Convert an MCMC coda object to a tidy tibble

Converts an object of class `mcmc.list` or `mcmc` — as produced by
[`coda::as.mcmc.list()`](https://rdrr.io/pkg/coda/man/mcmc.list.html) or
[`Hmsc::convertToCodaObject()`](https://rdrr.io/pkg/Hmsc/man/convertToCodaObject.html)
— into a tidy tibble. Four posterior parameter types used in
hierarchical models are supported: `"rho"`, `"alpha"`, `"beta"`, and
`"omega"`.

## Usage

``` r
coda_to_tibble(coda_object = NULL, posterior_type = NULL, n_omega = 100L)
```

## Arguments

- coda_object:

  An object of class `mcmc.list` or `mcmc`. Cannot be `NULL`.

- posterior_type:

  Character string (case-insensitive). One of `"rho"`, `"alpha"`,
  `"beta"`, or `"omega"`. Determines the reshaping and column-naming
  strategy applied to the raw MCMC matrix.

- n_omega:

  Positive integer. For `posterior_type = "omega"` only: the number of
  species-pair columns to randomly sample from the coda object before
  pivoting. If `n_omega` exceeds the number of available columns, all
  columns are used and a warning is issued. Default: `100L`.

## Value

A tibble whose structure depends on `posterior_type`; see Details.

## Details

Each `posterior_type` produces a different tibble structure:

- **`"rho"`**: Returns a tibble with columns `chain`, `iter`, and
  `value`.

- **`"alpha"`**: Returns a tibble with columns `Alpha`, `alpha_num`,
  `factor`, `chain`, `iter`, and `value`. Column names in the coda
  object must follow the pattern `Alpha<N>[<num>, factor<k>]`.

- **`"beta"`**: Returns a nested tibble grouped by `variable` and
  `sp_id` (species identifier). Coda dimnames must follow the Hmsc
  convention `B[<covariate>, <species_id>]`. Polynomial terms encoded as
  `stats::poly(..., degree = 2, raw = TRUE)` are parsed and renamed with
  `_l` (linear) and `_q` (quadratic) suffixes.

- **`"omega"`**: Samples `n_omega` species pairs at random and returns a
  nested tibble grouped by `species_combs`, `sp1`, and `sp2`. Coda
  dimnames must follow the Hmsc convention `Omega1[<sp_id1>, <sp_id2>]`.

## See also

[`coda::as.mcmc.list()`](https://rdrr.io/pkg/coda/man/mcmc.list.html),
[`Hmsc::convertToCodaObject()`](https://rdrr.io/pkg/Hmsc/man/convertToCodaObject.html)

## Author

Ahmed El-Gabbas

## Examples

``` r
#' # Example usage with a coda object from Hmsc::convertToCodaObject()
ecokit::load_packages(Hmsc, coda, dplyr)

coda_object <- Hmsc::convertToCodaObject(Hmsc::TD$m)

# ||||||||||||||||||||||||||||||||||||
# Alpha posterior samples
# ||||||||||||||||||||||||||||||||||||

dt_alpha <- coda_to_tibble(
   coda_object = coda_object$alpha[[1]], posterior_type = "Alpha")
#> Error in coda_to_tibble(coda_object = coda_object$alpha[[1]], posterior_type = "Alpha"): `coda_object` must both be provided.
dplyr::glimpse(dt_alpha)
#> Error: object 'dt_alpha' not found

# ||||||||||||||||||||||||||||||||||||
# Omega posterior samples
# ||||||||||||||||||||||||||||||||||||

dt_omega <- coda_to_tibble(
   coda_object = coda_object$Omega[[1]], posterior_type = "omega",
   n_omega = 10L)

dplyr::glimpse(dt_omega)
#> Rows: 10
#> Columns: 4
#> $ species_combs <chr> "Omega1[sp_001 (S4), sp_001 (S4)]", "Omega1[sp_001 (S4),…
#> $ sp1           <chr> "sp_001", "sp_001", "sp_002", "sp_002", "sp_002", "sp_00…
#> $ sp2           <chr> "sp_001", "sp_002", "sp_001", "sp_003", "sp_004", "sp_00…
#> $ data          <list> [<tbl_df[200 x 3]>], [<tbl_df[200 x 3]>], [<tbl_df[200 …

dplyr::glimpse(dt_omega$data[[1]])
#> Rows: 200
#> Columns: 3
#> $ chain <fct> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ iter  <int> 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, …
#> $ value <dbl> 0.0005252639, 0.0002361166, 0.0012787492, 0.0016374162, 0.038244…

# ||||||||||||||||||||||||||||||||||||
# Rho posterior samples
# ||||||||||||||||||||||||||||||||||||

dt_rho <- coda_to_tibble(
    coda_object = coda_object$rho, posterior_type = "rho")
#> Error in coda_to_tibble(coda_object = coda_object$rho, posterior_type = "rho"): `coda_object` must both be provided.
dplyr::glimpse(dt_rho)
#> Error: object 'dt_rho' not found
```
