# Mask raster to show top % and bottom % of cumulative sum

This function complements the
[`get_sampling_effort()`](https://elgabbas.github.io/ecokit/reference/sampling_effort.md)
function by creating masked rasters that highlight areas contributing to
the top and bottom percentages of the cumulative sum of the original
raster values. This can be useful for identifying areas with the highest
and lowest sampling efforts based on the original raster (i.e., number
of observations). The function also identifies cells with zero
observations. For more information, see [this
repo](https://github.com/elgabbas/global_sampling_efforts/) and
*El-Gabbas (2026)*. [DOI](https://doi.org/10.1111/ddi.70205).

## Usage

``` r
mask_cumulative_pct(rast, top_pct = 90L)
```

## Arguments

- rast:

  A SpatRaster object with numeric values (e.g., counts per cell)

- top_pct:

  Numeric, percentage (0–100) for the top cumulative sum (default: 90)

## Value

A SpatRaster with three layers:

- `top_xx_percent_cumulative`: cells cumulatively accounting for the top
  `top_pct`%; where `xx` is the value of `top_pct`

- `bottom_xx_percent_cumulative`: cells cumulatively accounting for the
  lowest `(100 - top_pct)`%; where `xx` is the value of `top_pct`

- `zero_observations`: cells with original value equal to zero

## Examples

``` r
require(terra)

temp_dir <- fs::path(fs::path_temp(), "sampling_efforts")
fs::dir_create(temp_dir)

# Sampling effort raster for birds (number of observations at 20 km
# resolution)
efforts_birds_all <- get_sampling_effort(
  group = "aves", metric = "n_obs", resolution = 20, out_dir = temp_dir)
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `effort_down = purrr::pmap(...)`.
#> Caused by warning:
#> ! Failed to download file using osfr. Attempting fallback download.
#>    group: aves
#>    descendant: all
#>    year: total
#>    metric: n_obs
#>    resolution: 20
#>    URL: https://osf.io/download/69144be425b8c888ea3ee2b8/
efforts_birds_all_r <- terra::rast(efforts_birds_all$local_path)
#> Warning: Unknown or uninitialised column: `local_path`.
#> Error in methods::as(x, "SpatRaster"): no method or default for coercing “NULL” to “SpatRaster”

result <- mask_cumulative_pct(rast = efforts_birds_all_r, top_pct = 90)
#> Error: object 'efforts_birds_all_r' not found
result
#> function (future, ...) 
#> {
#>     if (inherits(future, "Future") && inherits(future[[".journal"]], 
#>         "FutureJournal")) {
#>         start <- Sys.time()
#>         on.exit({
#>             appendToFutureJournal(future, event = "gather", category = "overhead", 
#>                 start = start, stop = Sys.time())
#>             if (!isTRUE(future[[".journal_signalled"]])) {
#>                 journal <- journal(future)
#>                 label <- sQuoteLabel(future)
#>                 msg <- sprintf("A future (%s) of class %s was resolved", 
#>                   label, class(future)[1])
#>                 cond <- FutureJournalCondition(message = msg, 
#>                   journal = journal)
#>                 signalCondition(cond)
#>                 future[[".journal_signalled"]] <- TRUE
#>             }
#>         })
#>     }
#>     UseMethod("result")
#> }
#> <bytecode: 0x55909b604f78>
#> <environment: namespace:future>

# Areas contributing to the top 90% of cumulative sum (log10 scale; computed
# on the global scale and cropped to USA)
result$top_90_percent_cumulative %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  log10() %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': object of type 'closure' is not subsettable

# Areas contributing to the lowest 10% of cumulative sum (log10 scale;
# computed on the global scale and cropped to USA)
result$lowest_10_percent_cumulative %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  log10() %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': object of type 'closure' is not subsettable

# Areas with zero observations (computed on the global scale and cropped to
# USA)
result$zero_observations %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': object of type 'closure' is not subsettable

fs::dir_delete(temp_dir)
```
