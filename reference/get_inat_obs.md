# Retrieve iNaturalist research-grade observations

Downloads all research-grade observations from the [iNaturalist
API](https://api.inaturalist.org/v1/docs/) for a given taxon, spatial
bounding box, and optional year and/or month filter.

## Usage

``` r
get_inat_obs(
  taxon_id,
  bounds,
  year = NULL,
  month = NULL,
  max_results = 10000L,
  verbose = TRUE
)
```

## Arguments

- taxon_id:

  `Integer`. iNaturalist taxon ID. Must be a positive integer (e.g.
  `47158` for *Animalia*). Find IDs at
  <https://www.inaturalist.org/taxa>.

- bounds:

  `Numeric`. Geographic bounding box in WGS 84 decimal degrees,
  specified as `c(sw_lat, sw_lng, ne_lat, ne_lng)`.

- year:

  `Integer` (optional). Four-digit calendar year to restrict the query.
  `NULL` retrieves records for all years (use with caution for
  widespread taxa — chunking by month and then week is still applied,
  but run time may be very long). Default: `NULL`.

- month:

  `Integer` (optional). Calendar month to restrict the query. `NULL`
  iterates over all 12 months automatically. Ignored when `year = NULL`.
  Default: `NULL`.

- max_results:

  `Integer`. Maximum records per API window before the next chunking
  level is triggered. The iNaturalist API enforces a hard ceiling of
  10,000; increasing this value beyond 10,000 has no effect on the API
  but will suppress intermediate splitting. Default: `10000L`.

- verbose:

  `Logical`. Whether to print progress messages to the console. Default:
  `TRUE`.

## Value

A deduplicated `tibble` with one row per research-grade observation and
the following columns:

- `id`: `integer` — unique iNaturalist observation ID

- `observed_on`: `character` — ISO 8601 observation date

- `quality_grade`: `character` — always `"research"` for these queries

- `taxon_id`: `integer` — taxon ID of the observed organism

- `taxon_name`: `character` — scientific name

- `latitude`: `numeric` — decimal latitude (WGS 84)

- `longitude`: `numeric` — decimal longitude (WGS 84)

- `place_guess`: `character` — observer-provided locality

- `user_login`: `character` — iNaturalist username

- `uri`: `character` — permanent observation URL

  An empty tibble (0 rows) is returned when no research-grade
  observations exist for the query.

## Details

### Chunking cascade

The iNaturalist API silently caps every query at *10,000 records*. This
function avoids silent truncation through an automatic, multi-level
chunking strategy:

- Level 1: Annual window (year filter) — if the annual count exceeds
  `max_results`, split by month.

- Level 2: Monthly window (month filter) — if the monthly count exceeds
  `max_results`, split by week.

- Level 3: Weekly window (day range filter) — if the weekly count
  exceeds `max_results`, split by day.

- Level 4: Daily window (day range filter) — if the daily count exceeds
  `max_results`, raise an error (spatial bounds too broad).

When `month` is supplied the cascade starts at level 2.

### Differences from `rinat::get_inat_obs()`

- Uses `httr2` (retry, backoff, structured error handling) instead of
  `httr`.

- Automatically handles result sets larger than 10,000 records at any
  temporal granularity, rather than requiring the user to supply chunked
  queries manually.

- Returns deduplicated results; iNaturalist's date-boundary indexing can
  occasionally assign the same observation to two adjacent windows.

- Raises a structured, informative error (with metadata) instead of
  silently truncating when the record ceiling cannot be resolved.

- Validates all inputs before making any network call.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(purrr)

# European bounding box
europe <- c(25, -30, 75, 50)

# All research-grade observations for a taxon in one month
obs_jan <- get_inat_obs(
  taxon_id = 67835, bounds = europe, year = 2024L, month = 1L)
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2024 | month: 1
#> --------------------------------------------------
#> 
#> Year: 2024, month: 1 --- 34 records
#> Done. 34 unique records retrieved.
obs_jan
#> # A tibble: 34 × 20
#>         id observed_on   day month  year quality_grade taxon_id rank  taxon_name
#>      <int> <date>      <int> <int> <int> <chr>            <int> <chr> <chr>     
#>  1  1.95e8 2024-01-01      1     1  2024 research         67835 spec… Danaus ch…
#>  2  1.95e8 2024-01-01      1     1  2024 research         67835 spec… Danaus ch…
#>  3  1.96e8 2024-01-04      4     1  2024 research         67835 spec… Danaus ch…
#>  4  1.96e8 2024-01-04      4     1  2024 research         67835 spec… Danaus ch…
#>  5  1.96e8 2024-01-08      8     1  2024 research         67835 spec… Danaus ch…
#>  6  1.96e8 2024-01-08      8     1  2024 research         67835 spec… Danaus ch…
#>  7  1.96e8 2024-01-07      7     1  2024 research         67835 spec… Danaus ch…
#>  8  1.96e8 2024-01-03      3     1  2024 research         67835 spec… Danaus ch…
#>  9  1.97e8 2024-01-15     15     1  2024 research         67835 spec… Danaus ch…
#> 10  1.97e8 2024-01-17     17     1  2024 research         67835 spec… Danaus ch…
#> 11  1.97e8 2024-01-17     17     1  2024 research         67835 spec… Danaus ch…
#> 12  1.97e8 2024-01-14     14     1  2024 research        466816 subs… Danaus ch…
#> 13  1.97e8 2024-01-22     22     1  2024 research         67835 spec… Danaus ch…
#> 14  1.97e8 2024-01-23     23     1  2024 research         67835 spec… Danaus ch…
#> 15  1.97e8 2024-01-24     24     1  2024 research         67835 spec… Danaus ch…
#> 16  1.98e8 2024-01-25     25     1  2024 research         67835 spec… Danaus ch…
#> 17  1.98e8 2024-01-25     25     1  2024 research         67835 spec… Danaus ch…
#> 18  1.98e8 2024-01-20     20     1  2024 research         67835 spec… Danaus ch…
#> 19  1.98e8 2024-01-28     28     1  2024 research         67835 spec… Danaus ch…
#> 20  1.98e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 21  1.98e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 22  1.98e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 23  1.98e8 2024-01-28     28     1  2024 research         67835 spec… Danaus ch…
#> 24  1.98e8 2024-01-28     28     1  2024 research         67835 spec… Danaus ch…
#> 25  2.00e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 26  2.00e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 27  2.00e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 28  2.00e8 2024-01-29     29     1  2024 research         67835 spec… Danaus ch…
#> 29  2.02e8 2024-01-07      7     1  2024 research         67835 spec… Danaus ch…
#> 30  2.04e8 2024-01-28     28     1  2024 research         67835 spec… Danaus ch…
#> 31  2.14e8 2024-01-28     28     1  2024 research         67835 spec… Danaus ch…
#> 32  2.39e8 2024-01-03      3     1  2024 research         67835 spec… Danaus ch…
#> 33  2.39e8 2024-01-03      3     1  2024 research         67835 spec… Danaus ch…
#> 34  2.55e8 2024-01-14     14     1  2024 research         67835 spec… Danaus ch…
#> # ℹ 11 more variables: num_identification_agreements <int>, latitude <dbl>,
#> #   longitude <dbl>, latitude_n_decimals <int>, longitude_n_decimals <int>,
#> #   geoprivacy <chr>, place_guess <chr>, user_login <chr>, uri <chr>,
#> #   in_gbif <lgl>, outlinks <list>

# All months for one year (monthly / weekly / daily fallback automatic)
obs_2023 <- get_inat_obs(taxon_id = 67835, bounds = europe, year = 2023L)
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2023
#> --------------------------------------------------
#> 
#> Year: 2023 --- 622 records total
#> Done. 622 unique records retrieved.
obs_2023
#> # A tibble: 622 × 20
#>         id observed_on   day month  year quality_grade taxon_id rank  taxon_name
#>      <int> <date>      <int> <int> <int> <chr>            <int> <chr> <chr>     
#>  1  1.46e8 2023-01-03      3     1  2023 research         67835 spec… Danaus ch…
#>  2  1.46e8 2023-01-04      4     1  2023 research         67835 spec… Danaus ch…
#>  3  1.46e8 2023-01-05      5     1  2023 research         67835 spec… Danaus ch…
#>  4  1.46e8 2023-01-04      4     1  2023 research         67835 spec… Danaus ch…
#>  5  1.46e8 2023-01-07      7     1  2023 research         67835 spec… Danaus ch…
#>  6  1.46e8 2023-01-09      9     1  2023 research         67835 spec… Danaus ch…
#>  7  1.46e8 2023-01-06      6     1  2023 research         67835 spec… Danaus ch…
#>  8  1.46e8 2023-01-07      7     1  2023 research         67835 spec… Danaus ch…
#>  9  1.46e8 2023-01-07      7     1  2023 research         67835 spec… Danaus ch…
#> 10  1.46e8 2023-01-07      7     1  2023 research         67835 spec… Danaus ch…
#> # ℹ 612 more rows
#> # ℹ 11 more variables: num_identification_agreements <int>, latitude <dbl>,
#> #   longitude <dbl>, latitude_n_decimals <int>, longitude_n_decimals <int>,
#> #   geoprivacy <chr>, place_guess <chr>, user_login <chr>, uri <chr>,
#> #   in_gbif <lgl>, outlinks <list>

# Multi-year loop with deduplication
obs_multi <- purrr::map_dfr(
  .x = 2020:2023,
  .f = ~ get_inat_obs(taxon_id = 67835, bounds = europe, year = .x))  %>%
  dplyr::distinct(id, .keep_all = TRUE)
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2020
#> --------------------------------------------------
#> 
#> Year: 2020 --- 167 records total
#> Done. 167 unique records retrieved.
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2021
#> --------------------------------------------------
#> 
#> Year: 2021 --- 145 records total
#> Done. 145 unique records retrieved.
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2022
#> --------------------------------------------------
#> 
#> Year: 2022 --- 246 records total
#> Done. 246 unique records retrieved.
#> 
#> --------------------------------------------------
#> Querying iNaturalist
#> taxon_id: 67835 | year: 2023
#> --------------------------------------------------
#> 
#> Year: 2023 --- 622 records total
#> Done. 622 unique records retrieved.
```
