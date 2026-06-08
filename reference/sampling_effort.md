# Get Sampling Effort Rasters

Downloads sampling effort raster files from the Open Science Framework
(OSF) based on specified taxonomic groups, descendants, metrics, years,
and spatial resolution. The function validates all inputs and retrieves
corresponding raster data files. Valid descendants for each group can be
retrieved with `get_group_descendants()`. For more information, see
[this repo](https://github.com/elgabbas/global_sampling_efforts/) and
*El-Gabbas (2026)*. [DOI](https://doi.org/10.1111/ddi.70205).

## Usage

``` r
get_group_descendants(group = NULL)

get_sampling_effort(
  group = NULL,
  descendants = "all",
  metric = NULL,
  years = "total",
  resolution = NULL,
  out_dir = getwd(),
  conflicts = "skip",
  verbose = FALSE,
  osf_token = NULL
)
```

## Arguments

- group:

  Character. The taxonomic group to download sampling effort data for.
  Must be one of: "all", "amphibia", "arachnida", "aves", "fungi",
  "insecta", "mammalia", "mollusca", "reptilia", or "tracheophyta".
  "all" refers to the overall sampling effort across all groups.
  Required.

- descendants:

  A character vector of descendants for the chosen group. Valid
  descendants vary by group. Defaults to "all" to download data for all
  descendants combined for the chosen group. Use
  `get_group_descendants()` to retrieve valid descendants for a given
  group. Required.

- metric:

  A character string specifying the metric to download. Must be either
  "n_sp" (number of species) or "n_obs" (number of observations).
  Required.

- years:

  A numeric vector or character string specifying year(s) to download.
  Valid range is 1980 to 2025, or "total" (default) for overall efforts.
  Automatically set to "total" when group is "all". Required for other
  groups.

- resolution:

  A numeric value specifying the spatial resolution in kilometers. Must
  be one of: 1, 5, 10, or 20 km. Required.

- out_dir:

  A character string specifying the output directory path. Defaults to
  the current working directory. If the directory does not exist, it
  will be created.

- conflicts:

  A character string specifying how to handle existing files. Must be
  either "skip" (default) or "overwrite".

- verbose:

  Logical. If `TRUE`, prints progress messages during the download
  process. Defaults to `FALSE`.

- osf_token:

  Character string. An *optional* OSF token for authentication. If
  provided, it will be used to authenticate with OSF. Defaults to
  `NULL`, which access public files without authentication.

## Value

A tibble containing downloaded sampling effort data with columns:

- `group`: The taxonomic group

- `descendant`: The taxonomic descendant

- `year`: The year of the data

- `metric`: The metric type (`n_sp` or `n_obs`)

- `resolution`: The spatial resolution in km

- `name`: The name of the downloaded file

- `id`: The OSF file ID

- `local_path`: The local file path where the raster was downloaded

- `meta`: Metadata about the downloaded file from OSF

## Details

This function downloads sampling effort raster files from the OSF
project. This function complements the manuscript *"A Global,
Taxon-Stratified, High-Resolution Sampling-Effort Dataset From GBIF for
Bias-Aware Ecological Modelling"*
\[[DOI](https://doi.org/10.1111/ddi.70205)\] by providing a programmatic
way to access the underlying data used in the study. Please cite the
manuscript when using the data retrieved by this function.

Files on the OSF project are organized hierarchically by group,
resolution, metric, and descendant-year combinations.

This function retrieves sampling effort rasters based on the specified
group and its descendants. The `descendants` argument allows users to
specify which descendant groups to download data for. The function
validates descendants using `get_group_descendants()` and retrieves the
corresponding raster files from OSF.

Use `[get_group_descendants()]` to retrieve all valid descendants for a
given taxonomic group.

The function tries to download files using the `osfr` package. If the
download fails or results in an invalid file, it attempts a fallback
download using the direct URL with
[`utils::download.file()`](https://rdrr.io/r/utils/download.file.html).
If both attempts fail, an error is raised.

## References

El-Gabbas, A. (2026). A Global, Taxon-Stratified, High-Resolution
Sampling-Effort Dataset From GBIF for Bias-Aware Ecological Modelling.
Diversity and Distributions. [DOI](https://doi.org/10.1111/ddi.70205).

## Author

Ahmed El-Gabbas

## Examples

``` r
require(terra)
require(fs)

# Retrieve descendants for all groups
descendants_all <- get_group_descendants("all")
str(descendants_all)
#> List of 10
#>  $ all         : chr "all"
#>  $ amphibia    : chr [1:4] "all" "anura" "caudata" "gymnophiona"
#>  $ arachnida   : chr [1:17] "all" "amblypygi" "araneae" "holothyrida" ...
#>  $ aves        : chr [1:43] "all" "accipitriformes" "anseriformes" "apodiformes" ...
#>  $ fungi       : chr [1:12] "all" "ascomycota" "basidiomycota" "blastocladiomycota" ...
#>  $ insecta     : chr [1:32] "all" "archaeognatha" "blattodea" "cnemidolestodea" ...
#>  $ mammalia    : chr [1:30] "all" "afrosoricida" "artiodactyla" "carnivora" ...
#>  $ mollusca    : chr [1:11] "all" "bivalvia" "caudofoveata" "cephalopoda" ...
#>  $ reptilia    : chr [1:5] "all" "crocodylia" "sphenodontia" "squamata" ...
#>  $ tracheophyta: chr [1:9] "all" "cycadopsida" "ginkgoopsida" "gnetopsida" ...
descendants_all$aves
#>  [1] "all"                 "accipitriformes"     "anseriformes"       
#>  [4] "apodiformes"         "apterygiformes"      "bucerotiformes"     
#>  [7] "caprimulgiformes"    "cariamiformes"       "casuariiformes"     
#> [10] "charadriiformes"     "ciconiiformes"       "coliiformes"        
#> [13] "columbiformes"       "coraciiformes"       "cuculiformes"       
#> [16] "eurypygiformes"      "falconiformes"       "galliformes"        
#> [19] "gaviiformes"         "gruiformes"          "leptosomiformes"    
#> [22] "mesitornithiformes"  "musophagiformes"     "nyctibiiformes"     
#> [25] "opisthocomiformes"   "otidiformes"         "passeriformes"      
#> [28] "pelecaniformes"      "phaethontiformes"    "phoenicopteriformes"
#> [31] "piciformes"          "podicipediformes"    "procellariiformes"  
#> [34] "psittaciformes"      "pteroclidiformes"    "rheiformes"         
#> [37] "sphenisciformes"     "steatornithiformes"  "strigiformes"       
#> [40] "struthioniformes"    "suliformes"          "tinamiformes"       
#> [43] "trogoniformes"      

# Retrieve valid descendants for a group
get_group_descendants("insecta")
#>  [1] "all"               "archaeognatha"     "blattodea"        
#>  [4] "cnemidolestodea"   "coleoptera"        "dermaptera"       
#>  [7] "diptera"           "embioptera"        "ephemeroptera"    
#> [10] "grylloblattodea"   "hemiptera"         "hymenoptera"      
#> [13] "lepidoptera"       "mantodea"          "mantophasmatodea" 
#> [16] "mecoptera"         "megaloptera"       "neuroptera"       
#> [19] "odonata"           "orthoptera"        "palaeodictyoptera"
#> [22] "phasmida"          "plecoptera"        "protorthoptera"   
#> [25] "psocodea"          "raphidioptera"     "siphonaptera"     
#> [28] "strepsiptera"      "thysanoptera"      "trichoptera"      
#> [31] "zoraptera"         "zygentoma"        

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

temp_dir <- fs::path(fs::path_temp(), "sampling_efforts")
fs::dir_create(temp_dir)

# Occurrence count for birds at 20 km resolution
efforts_birds_all <- get_sampling_effort(
  group = "aves", metric = "n_obs", resolution = 20, out_dir = temp_dir)

dplyr::glimpse(efforts_birds_all)
#> Rows: 1
#> Columns: 9
#> $ group      <chr> "aves"
#> $ descendant <chr> "all"
#> $ year       <chr> "total"
#> $ metric     <chr> "n_obs"
#> $ resolution <dbl> 20
#> $ name       <chr> "n_obs_Aves_res_20.tif"
#> $ id         <chr> "69144be425b8c888ea3ee2b8"
#> $ local_path <chr> "/tmp/RtmpvafRTD/sampling_efforts/n_obs_Aves_res_20.tif"
#> $ meta       <list> [[<NULL>, <NULL>, "n_obs_Aves_res_20.tif", "file", "/69144be425b8c888ea3ee2b8", 822667, "osfstorage", "/res_20_n_obs/n_obs_Aves_res_20.tif", <NULL>, 2025-11-12 08:57:09, 2025-11-12 08:57:09, [["ba82a8bd3ef8fe226f5a91e366ff2755", "def3eac67285494859167be1838dd3fee1edc0a069f4465ed97a8a2f8262a226"], 156], [], FALSE, 1, FALSE], ["https://api.osf.io/v2/files/69144be425b8c888ea3ee2b…

efforts_birds_all_r <- terra::rast(efforts_birds_all$local_path)

# Plot at log10 scale
terra::classify(efforts_birds_all_r, cbind(0, NA)) %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  log10() %>%
  plot()


# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Occurrence count for insecta at 10 km resolution in 2020
efforts_insecta_2020 <- get_sampling_effort(
  group = "insecta", descendants = "all",
  metric = "n_obs", years = 2020, resolution = 10, out_dir = temp_dir)
#> Error in dplyr::mutate(., effort_down = purrr::pmap(list(group, descendant,     year, metric, resolution), function(group, descendant, year,     metric, resolution) {    ecokit::cat_time(paste0(group, ": ", descendant, "; year: ",         year), verbose = verbose)    if (group == "all") {        descendant_year <- paste0(metric, "_", resolution, ".tif")        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(type = "file", pattern = descendant_year)    }    else {        res_metric <- paste0("res_", resolution, "_", metric)        if (year == "total") {            if (descendant == "all") {                descendant_year <- paste0(group, "_res")            }            else {                descendant_year <- paste0("_", descendant, "_total_res")            }        }        else if (descendant == "all") {            descendant_year <- paste0(group, "_", year)        }        else {            descendant_year <- paste0("_", descendant, "_", year)        }        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(n_max = 15L, type = "folder",                 pattern = res_metric) %>% osfr::osf_ls_files(type = "file",             pattern = descendant_year)    }    if (nrow(r_file) != 1L) {        ecokit::stop_ctx(paste0("Expected exactly one file for metric '",             metric, "' and descendant-year '", descendant, " - ",             year, "'. Found ", nrow(r_file), " files."))    }    Sys.sleep(2L)    down_osf <- tryCatch({        r_file2 <- osfr::osf_download(x = r_file, path = out_dir,             conflicts = conflicts)        TRUE    }, warning = function(w) {        FALSE    }, error = function(e) {        FALSE    })    if (down_osf) {        return(r_file2)    }    file_tiff <- fs::path(out_dir, r_file$name)    down_url <- r_file$meta[[1L]]$links$download    if (!ecokit::check_tiff(file_tiff, warning = FALSE) && verbose) {        warning("Failed to download file using osfr. ", "Attempting fallback download.\n   group: ",             group, "\n   descendant: ", descendant, "\n   year: ",             year, "\n   metric: ", metric, "\n   resolution: ",             resolution, "\n   URL: ", down_url, "\n", call. = FALSE,             immediate. = TRUE)        utils::download.file(url = down_url, destfile = file_tiff,             mode = "wb", quiet = TRUE)    }    if (!ecokit::check_tiff(file_tiff, warning = FALSE)) {        if (fs::file_exists(file_tiff)) {            try(fs::file_delete(file_tiff), silent = TRUE)        }        ecokit::stop_ctx("Failed to download file from OSF and fallback URL.",             file_tiff = file_tiff, down_url = down_url, group = group,             descendant = descendant, year = year, metric = metric,             resolution = resolution)    }    dplyr::mutate(r_file, local_path = file_tiff, .before = meta)})): ℹ In argument: `effort_down = purrr::pmap(...)`.
#> Caused by error in `purrr::pmap()`:
#> ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! Failed to download file from OSF and fallback URL.
#> 
#> ----- Metadata -----
#> 
#> file_tiff [file_tiff]: <fs_path + character>
#> /tmp/RtmpvafRTD/sampling_efforts/n_obs_Insecta_2020_res_10.tif
#> 
#> down_url [down_url]: <character>
#> https://osf.io/download/69162951e79337dd25e2f525/
#> 
#> group [group]: <character>
#> insecta
#> 
#> descendant [descendant]: <character>
#> all
#> 
#> year [year]: <character>
#> 2020
#> 
#> metric [metric]: <character>
#> n_obs
#> 
#> resolution [resolution]: <numeric>
#> 10

efforts_insecta_2020_r <- terra::rast(efforts_insecta_2020$local_path)
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rast': object 'efforts_insecta_2020' not found

# Plot at log10 scale
terra::classify(efforts_insecta_2020_r, cbind(0, NA)) %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  log10() %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': error in evaluating the argument 'x' in selecting a method for function 'classify': object 'efforts_insecta_2020_r' not found

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Species count for vascular plants at 10 km
efforts_plants_2020 <- get_sampling_effort(
  group = "tracheophyta", descendants = "all",
  metric = "n_sp", resolution = 10, out_dir = temp_dir)
#> Error in dplyr::mutate(., effort_down = purrr::pmap(list(group, descendant,     year, metric, resolution), function(group, descendant, year,     metric, resolution) {    ecokit::cat_time(paste0(group, ": ", descendant, "; year: ",         year), verbose = verbose)    if (group == "all") {        descendant_year <- paste0(metric, "_", resolution, ".tif")        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(type = "file", pattern = descendant_year)    }    else {        res_metric <- paste0("res_", resolution, "_", metric)        if (year == "total") {            if (descendant == "all") {                descendant_year <- paste0(group, "_res")            }            else {                descendant_year <- paste0("_", descendant, "_total_res")            }        }        else if (descendant == "all") {            descendant_year <- paste0(group, "_", year)        }        else {            descendant_year <- paste0("_", descendant, "_", year)        }        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(n_max = 15L, type = "folder",                 pattern = res_metric) %>% osfr::osf_ls_files(type = "file",             pattern = descendant_year)    }    if (nrow(r_file) != 1L) {        ecokit::stop_ctx(paste0("Expected exactly one file for metric '",             metric, "' and descendant-year '", descendant, " - ",             year, "'. Found ", nrow(r_file), " files."))    }    Sys.sleep(2L)    down_osf <- tryCatch({        r_file2 <- osfr::osf_download(x = r_file, path = out_dir,             conflicts = conflicts)        TRUE    }, warning = function(w) {        FALSE    }, error = function(e) {        FALSE    })    if (down_osf) {        return(r_file2)    }    file_tiff <- fs::path(out_dir, r_file$name)    down_url <- r_file$meta[[1L]]$links$download    if (!ecokit::check_tiff(file_tiff, warning = FALSE) && verbose) {        warning("Failed to download file using osfr. ", "Attempting fallback download.\n   group: ",             group, "\n   descendant: ", descendant, "\n   year: ",             year, "\n   metric: ", metric, "\n   resolution: ",             resolution, "\n   URL: ", down_url, "\n", call. = FALSE,             immediate. = TRUE)        utils::download.file(url = down_url, destfile = file_tiff,             mode = "wb", quiet = TRUE)    }    if (!ecokit::check_tiff(file_tiff, warning = FALSE)) {        if (fs::file_exists(file_tiff)) {            try(fs::file_delete(file_tiff), silent = TRUE)        }        ecokit::stop_ctx("Failed to download file from OSF and fallback URL.",             file_tiff = file_tiff, down_url = down_url, group = group,             descendant = descendant, year = year, metric = metric,             resolution = resolution)    }    dplyr::mutate(r_file, local_path = file_tiff, .before = meta)})): ℹ In argument: `effort_down = purrr::pmap(...)`.
#> Caused by error in `purrr::pmap()`:
#> ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! Failed to download file from OSF and fallback URL.
#> 
#> ----- Metadata -----
#> 
#> file_tiff [file_tiff]: <fs_path + character>
#> /tmp/RtmpvafRTD/sampling_efforts/n_sp_Tracheophyta_res_10.tif
#> 
#> down_url [down_url]: <character>
#> https://osf.io/download/690b6907e442d3491b9c3f51/
#> 
#> group [group]: <character>
#> tracheophyta
#> 
#> descendant [descendant]: <character>
#> all
#> 
#> year [year]: <character>
#> total
#> 
#> metric [metric]: <character>
#> n_sp
#> 
#> resolution [resolution]: <numeric>
#> 10

efforts_plants_2020_r <- terra::rast(efforts_plants_2020$local_path)
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rast': object 'efforts_plants_2020' not found

# Plot at log10 scale
terra::classify(efforts_plants_2020_r, cbind(0, NA)) %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  log10() %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': error in evaluating the argument 'x' in selecting a method for function 'classify': object 'efforts_plants_2020_r' not found

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Occurrence count for selected insect groups (descendants) at 10 km
efforts_insects <- get_sampling_effort(
  group = "insecta",
  descendants = c("hemiptera", "hymenoptera", "lepidoptera"),
  metric = "n_obs", resolution = 10, out_dir = temp_dir)
#> Error in dplyr::mutate(., effort_down = purrr::pmap(list(group, descendant,     year, metric, resolution), function(group, descendant, year,     metric, resolution) {    ecokit::cat_time(paste0(group, ": ", descendant, "; year: ",         year), verbose = verbose)    if (group == "all") {        descendant_year <- paste0(metric, "_", resolution, ".tif")        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(type = "file", pattern = descendant_year)    }    else {        res_metric <- paste0("res_", resolution, "_", metric)        if (year == "total") {            if (descendant == "all") {                descendant_year <- paste0(group, "_res")            }            else {                descendant_year <- paste0("_", descendant, "_total_res")            }        }        else if (descendant == "all") {            descendant_year <- paste0(group, "_", year)        }        else {            descendant_year <- paste0("_", descendant, "_", year)        }        r_file <- osfr::osf_retrieve_node(node_lists$id) %>%             osfr::osf_ls_files(n_max = 15L, type = "folder",                 pattern = res_metric) %>% osfr::osf_ls_files(type = "file",             pattern = descendant_year)    }    if (nrow(r_file) != 1L) {        ecokit::stop_ctx(paste0("Expected exactly one file for metric '",             metric, "' and descendant-year '", descendant, " - ",             year, "'. Found ", nrow(r_file), " files."))    }    Sys.sleep(2L)    down_osf <- tryCatch({        r_file2 <- osfr::osf_download(x = r_file, path = out_dir,             conflicts = conflicts)        TRUE    }, warning = function(w) {        FALSE    }, error = function(e) {        FALSE    })    if (down_osf) {        return(r_file2)    }    file_tiff <- fs::path(out_dir, r_file$name)    down_url <- r_file$meta[[1L]]$links$download    if (!ecokit::check_tiff(file_tiff, warning = FALSE) && verbose) {        warning("Failed to download file using osfr. ", "Attempting fallback download.\n   group: ",             group, "\n   descendant: ", descendant, "\n   year: ",             year, "\n   metric: ", metric, "\n   resolution: ",             resolution, "\n   URL: ", down_url, "\n", call. = FALSE,             immediate. = TRUE)        utils::download.file(url = down_url, destfile = file_tiff,             mode = "wb", quiet = TRUE)    }    if (!ecokit::check_tiff(file_tiff, warning = FALSE)) {        if (fs::file_exists(file_tiff)) {            try(fs::file_delete(file_tiff), silent = TRUE)        }        ecokit::stop_ctx("Failed to download file from OSF and fallback URL.",             file_tiff = file_tiff, down_url = down_url, group = group,             descendant = descendant, year = year, metric = metric,             resolution = resolution)    }    dplyr::mutate(r_file, local_path = file_tiff, .before = meta)})): ℹ In argument: `effort_down = purrr::pmap(...)`.
#> Caused by error in `purrr::pmap()`:
#> ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! Failed to download file from OSF and fallback URL.
#> 
#> ----- Metadata -----
#> 
#> file_tiff [file_tiff]: <fs_path + character>
#> /tmp/RtmpvafRTD/sampling_efforts/n_obs_Hemiptera_total_res_10.tif
#> 
#> down_url [down_url]: <character>
#> https://osf.io/download/691627285d3006de940c2892/
#> 
#> group [group]: <character>
#> insecta
#> 
#> descendant [descendant]: <character>
#> hemiptera
#> 
#> year [year]: <character>
#> total
#> 
#> metric [metric]: <character>
#> n_obs
#> 
#> resolution [resolution]: <numeric>
#> 10

efforts_insects
#> Error: object 'efforts_insects' not found

dplyr::glimpse(efforts_insects)
#> Error: object 'efforts_insects' not found

efforts_insects_r <- terra::rast(efforts_insects$local_path)
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rast': object 'efforts_insects' not found
efforts_insects_r
#> Error: object 'efforts_insects_r' not found

# Plot at log10 scale
terra::classify(efforts_insects_r, cbind(0, NA)) %>%
  terra::crop(terra::ext(-125, -66.5, 24.5, 49.5)) %>%
  stats::setNames(c("hemiptera", "hymenoptera", "lepidoptera")) %>%
  log10() %>%
  plot()
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': error in evaluating the argument 'x' in selecting a method for function 'crop': error in evaluating the argument 'x' in selecting a method for function 'classify': object 'efforts_insects_r' not found

fs::dir_delete(temp_dir)
```
