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
#> Error in dplyr::mutate(., effort_down = purrr::pmap(list(group, descendant,     year, metric, resolution), function(group, descendant, year,     metric, resolution) {    ecokit::cat_time(paste0(group, ": ", descendant, "; year: ",         year), verbose = verbose)    if (group == "all") {        descendant_year <- paste0(metric, "_", resolution, ".tif")        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(type = "file", pattern = descendant_year)    }    else {        res_metric <- paste0("res_", resolution, "_", metric)        if (year == "total") {            if (descendant == "all") {                descendant_year <- paste0(group, "_res")            }            else {                descendant_year <- paste0("_", descendant, "_total_res")            }        }        else if (descendant == "all") {            descendant_year <- paste0(group, "_", year)        }        else {            descendant_year <- paste0("_", descendant, "_", year)        }        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(n_max = 15L, type = "folder",                 pattern = res_metric) %>% osfr::osf_ls_files(type = "file",             pattern = descendant_year)    }    if (nrow(r_file) != 1L) {        ecokit::stop_ctx(paste0("Expected exactly one file for metric '",             metric, "' and descendant-year '", descendant, " - ",             year, "'. Found ", nrow(r_file), " files."))    }    Sys.sleep(2L)    down_osf <- tryCatch({        r_file2 <- osfr::osf_download(x = r_file, path = out_dir,             conflicts = conflicts)        TRUE    }, warning = function(w) {        FALSE    }, error = function(e) {        FALSE    })    if (down_osf) {        return(r_file2)    }    file_tiff <- fs::path(out_dir, r_file$name)    down_url <- r_file$meta[[1L]]$links$download    if (!ecokit::check_tiff(file_tiff, warning = FALSE) && verbose) {        warning("Failed to download file using osfr. ", "Attempting fallback download.\n   group: ",             group, "\n   descendant: ", descendant, "\n   year: ",             year, "\n   metric: ", metric, "\n   resolution: ",             resolution, "\n   URL: ", down_url, "\n", call. = FALSE,             immediate. = TRUE)        utils::download.file(url = down_url, destfile = file_tiff,             mode = "wb", quiet = TRUE)    }    if (!ecokit::check_tiff(file_tiff, warning = FALSE)) {        if (fs::file_exists(file_tiff)) {            try(fs::file_delete(file_tiff), silent = TRUE)        }        ecokit::stop_ctx("Failed to download file from OSF and fallback URL.",             file_tiff = file_tiff, down_url = down_url, group = group,             descendant = descendant, year = year, metric = metric,             resolution = resolution)    }    dplyr::mutate(r_file, local_path = file_tiff, .before = meta)})): ℹ In argument: `effort_down = purrr::pmap(...)`.
#> Caused by error in `purrr::pmap()`:
#> ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! Failed to download file from OSF and fallback URL.
#> 
#> ----- Metadata -----
#> 
#> file_tiff [file_tiff]: <fs_path + character>
#> /tmp/RtmpvafRTD/sampling_efforts/n_obs_Aves_res_20.tif
#> 
#> down_url [down_url]: <character>
#> https://osf.io/download/69144be425b8c888ea3ee2b8/
#> 
#> group [group]: <character>
#> aves
#> 
#> descendant [descendant]: <character>
#> all
#> 
#> year [year]: <character>
#> total
#> 
#> metric [metric]: <character>
#> n_obs
#> 
#> resolution [resolution]: <numeric>
#> 20
efforts_birds_all_r <- terra::rast(efforts_birds_all$local_path)
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rast': object 'efforts_birds_all' not found

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
#> <bytecode: 0x55b887b0a578>
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
