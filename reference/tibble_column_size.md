# Calculate Column Sizes in a Tibble

This function calculates the memory size of each column in a tibble or
data frame and returns a summary tibble containing column indices,
names, classes, and sizes.

## Usage

``` r
tibble_column_size(tibble)
```

## Arguments

- tibble:

  A tibble or data frame with at least one row and one column.

## Value

A tibble with the following columns (sorted by `col_size` in descending
order):

- `col_index`: Integer; The original column index.

- `col_name`: Character; The name of the column.

- `col_class`: Character; The class(es) of the column, collapsed into a
  single string.

- `col_size`: Numeric; The memory size of the column in bytes, as
  calculated by
  [lobstr::obj_size](https://lobstr.r-lib.org/reference/obj_size.html).

## Details

The memory size is computed using
[lobstr::obj_size](https://lobstr.r-lib.org/reference/obj_size.html),
which includes the overhead of the column's vector structure. Columns
with complex data (e.g., lists) may have larger sizes due to their
structure.

## Examples

``` r
# Load required packages
ecokit::load_packages(tibble, dplyr, purrr, lobstr, terra)

# # ---------------------------------------------------------------
# Generate a moderately sized tibble with various column types
# # ---------------------------------------------------------------

# Create a moderately sized tibble (100 rows)
n_rows <- 100

# Simple columns
set.seed(123)
species_data <- tibble::tibble(
  species_id = seq_len(n_rows),
  species_name = paste0("Species_", sprintf("%03d", seq_len(n_rows))),
  n_cells = sample(10:500, n_rows, replace = TRUE),
  habitat = factor(
    sample(c("Forest", "Grassland", "Wetland"), n_rows, replace = TRUE)))

# List column: Observations per species (vectors of random coordinates)
obs_coords <- purrr::map(seq_len(n_rows), ~ runif(sample(5:20, 1), 0, 100))
species_data$obs_coords <- obs_coords

# Nested tibble column: Species traits
set.seed(123)
traits <- purrr::map(
  .x = seq_len(n_rows),
  .f = ~ tibble::tibble(
    trait_name = c("height_cm", "seed_count", "growth_rate"),
    value = runif(3, 0, 100),
    unit = c("cm", "count", "cm/day")))
species_data$traits <- traits

# SpatRaster column: Small raster maps for each species
# Create a template raster (10x10 grid)
template_raster <- terra::rast(
  nrows = 10, ncols = 10, xmin = 0, xmax = 100, ymin = 0, ymax = 100)
set.seed(123)
rasters <- purrr::map(
  .x = seq_len(n_rows),
  .f = ~ {
    r <- template_raster
    # Random presence/absence values
    terra::values(r) <- runif(terra::ncell(r), 0, 1)
    r
  })
species_data$raster_map <- rasters

# Verify the tibble
dplyr::glimpse(species_data, 1)
#> Rows: 100
#> Columns: 7
#> $ species_id   <int> …
#> $ species_name <chr> …
#> $ n_cells      <int> …
#> $ habitat      <fct> …
#> $ obs_coords   <list> …
#> $ traits       <list> …
#> $ raster_map   <list> …

# # ---------------------------------------------------------------
# Calculate column sizes
# # ---------------------------------------------------------------

tibble_column_size(species_data)
#> # A tibble: 7 × 4
#>   col_index col_name     col_class               col_size  
#>       <int> <chr>        <chr>                   <lbstr_by>
#> 1         7 raster_map   SpatRaster              10.89 MB  
#> 2         6 traits       tbl_df, tbl, data.frame 72.13 kB  
#> 3         5 obs_coords   numeric                 17.12 kB  
#> 4         2 species_name character                7.25 kB  
#> 5         1 species_id   integer                  1.13 kB  
#> 6         4 habitat      factor                   1.04 kB  
#> 7         3 n_cells      integer                    448 B  
```
