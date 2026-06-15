# Trim an `Hmsc` model object by removing specified components

Removes named components from a fitted
[`Hmsc::Hmsc`](https://rdrr.io/pkg/Hmsc/man/Hmsc.html) model object,
returning a lighter object that retains only the elements needed for
downstream computations. This is particularly useful when a fitted model
is large (several GB) and copies must be shipped to parallel workers via
SLURM array jobs or `future`-based parallel backends, where transferring
the full object would be prohibitively slow or exceed memory limits.

## Usage

``` r
trim_hmsc(model, names_to_remove = NULL)
```

## Arguments

- model:

  An object of class `Hmsc`. Must not be `NULL`.

- names_to_remove:

  Character vector. Names of components to remove from `model` (e.g.
  `c("postList", "rL", "ranLevels")`). Duplicate names are silently
  dropped. All supplied names must exist in `model`; unrecognised names
  trigger an error. Cannot be `NULL` or empty.

## Value

An `Hmsc` object with the specified components removed. Returned
invisibly.

## Details

The function converts the `Hmsc` object to a plain `list` before
removing components, then restores the `"Hmsc"` class attribute.
Conversion to a plain list avoids S3-dispatch overhead that would
otherwise be triggered by modifying `Hmsc` slots directly.

Components are removed one at a time with a `for` loop rather than via
vectorised subsetting (e.g. `model[names_to_remove] <- NULL`). Although
the vectorised form is syntactically simpler, benchmarking on large
models inside SLURM-submitted jobs showed the iterative approach to be
substantially faster in practice, likely due to how R handles
copy-on-modify semantics for large named lists.

A call to [`base::gc()`](https://rdrr.io/r/base/gc.html) is made before
returning to prompt immediate release of the memory freed by removal.

## See also

[`Hmsc::Hmsc()`](https://rdrr.io/pkg/Hmsc/man/Hmsc.html) for the full
model object structure;
[`Hmsc::sampleMcmc()`](https://rdrr.io/pkg/Hmsc/man/sampleMcmc.html) for
the fitting step that populates `postList`.

## Author

Ahmed El-Gabbas

## Examples

``` r
library(Hmsc)

# Fitted example model bundled with Hmsc
(model <- Hmsc::TD$m)
#> Hmsc object with 50 sampling units, 4 species, 3 covariates, 3 traits and 2 random levels
#> Posterior MCMC sampling with 2 chains each with 100 samples, thin 1 and transient 50 

# Remove large posterior and random-level components
(trimmed_model <- trim_hmsc(
  model = model, names_to_remove = c("postList", "rL", "ranLevels")))
#> Hmsc object with 50 sampling units, 4 species, 3 covariates, 3 traits and 2 random levels
#> Posterior MCMC sampling with 100 samples, thin 1 and transient 50 

# Components that were removed
setdiff(names(model), names(trimmed_model))
#> [1] "ranLevels" "rL"        "postList" 

# Memory savings
lobstr::obj_size(model)
#> 937.01 kB
lobstr::obj_size(trimmed_model)
#> 44.06 kB
```
