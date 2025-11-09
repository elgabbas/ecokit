# List and Download Files from a Zenodo Record

These functions provide an R interface to list all files in a Zenodo
record and to download one of those files (optionally reading it into
R).

## Usage

``` r
zenodo_file_list(record_id)

zenodo_download_file(
  record_id = NULL,
  file_name = NULL,
  dest_file = NULL,
  read_func = NULL,
  delete_temp = TRUE,
  unwrap_r = TRUE,
  verbose = FALSE,
  check_md5sum = TRUE,
  timeout = 600L,
  ...
)
```

## Arguments

- record_id:

  Character or numeric. The Zenodo record ID (e.g., `"1234567"`).

- file_name:

  Character. The file key (or filename) as listed in the Zenodo record.

- dest_file:

  Character (optional). Local destination path to save the downloaded
  file. If `NULL` (default), a temporary file is created and deleted if
  `read_func` is used.

- read_func:

  Function (optional). A function to read or process the downloaded file
  (e.g., [`read.csv()`](https://rdrr.io/r/utils/read.table.html),
  `readr::read_csv()`,
  [`readLines()`](https://rdrr.io/r/base/readLines.html),
  `readxl::read_excel()`, etc.). If `NULL`, only the file path is
  returned.

- delete_temp:

  Logical. Whether to delete temporary files after reading them with
  `read_func`. Default is `TRUE`. Set to `FALSE` if you need the file to
  persist or if you're experiencing "resource busy" errors with complex
  read functions.

- unwrap_r:

  Logical. If `read_func` returns an `PackedSpatRaster` or
  `PackedSpatVector` object, this argument controls whether to unwrap
  packed objects using
  [`terra::unwrap()`](https://rspatial.github.io/terra/reference/wrap.html).
  Default is `TRUE`.

- verbose:

  Logical. Whether to print progress messages during download. Default
  is `FALSE`.

- check_md5sum:

  Logical. Whether to verify the MD5 checksum of the downloaded file
  against the checksum provided by Zenodo. Default is `TRUE`. If the
  checksums do not match, an error is raised and the file is deleted.
  Set to `FALSE` to skip this verification step.

- timeout:

  Numeric. Maximum time (in seconds) to wait for the download to
  complete. Default is `600L` seconds (10 minutes). Increase this value
  for larger files or slower connections.

- ...:

  Additional arguments passed to `read_func`.

## Value

- `zenodo_file_list` returns a `tibble` with metadata for each file in
  the Zenodo record, including file key, filename, download link, and
  record-level metadata such as title, DOI, and creation dates.

- `zenodo_download_file`: If `read_func` is `NULL`, returns the path to
  the downloaded file. If `read_func` is provided, returns the output of
  that function.

## Details

- `zenodo_file_list()` lists all files and their metadata for a given
  Zenodo record.

- `zenodo_download_file()` downloads a specified file from a Zenodo
  record and can optionally read its contents into R using a
  user-supplied function.

## Author

Ahmed El-Gabbas

## Examples

``` r
require(ecokit)
ecokit::load_packages(terra, dplyr, fs)

files <- zenodo_file_list("6620748")
dplyr::glimpse(files)
#> Rows: 59
#> Columns: 12
#> $ title       <chr> "Phanerozoic continental climate and Köppen–Geiger climate…
#> $ id_url      <chr> "https://zenodo.org/api/records/6620748", "https://zenodo.…
#> $ created     <dttm> 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:2…
#> $ modified    <dttm> 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:4…
#> $ updated     <dttm> 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:4…
#> $ doi_version <chr> "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.52…
#> $ doi         <chr> "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.52…
#> $ id          <int> 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620…
#> $ key         <chr> "40Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc", "0Ma…
#> $ size        <int> 8261200, 14498683, 8261200, 14573851, 8261200, 14407735, 8…
#> $ checksum    <chr> "md5:e9ca6e5e58b7b892c2dfd00fffdcc7af", "md5:65ee19cbf3da6…
#> $ link        <chr> "https://zenodo.org/api/records/6620748/files/40Ma_Pohleta…

# --------------------------------------------

# Download as file only
pdf_file <- zenodo_download_file(
  record_id = "1234567", file_name = "article.pdf")
print(pdf_file)
#> /tmp/Rtmp9s80iV/article24671059d179.pdf

ecokit::file_type(pdf_file)
#> [1] "PDF document, version 1.6"
try(fs::file_delete(pdf_file), silent = TRUE)

# --------------------------------------------

# Download and read NetCDF as SpatRaster
nc_file <- zenodo_download_file(
  record_id = "6620748",
  file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
  read_func = terra::rast)

print(class(nc_file))
#> [1] "SpatRaster"
#> attr(,"package")
#> [1] "terra"

print(nc_file)
#> class       : SpatRaster 
#> size        : 128, 128, 3  (nrow, ncol, nlyr)
#> resolution  : 1.40625, 2.8125  (x, y)
#> extent      : -90, 90, 0, 360  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> varname     : topo (topography) 
#> names       :              topo,                                              koppen, area 
#> unit        : m above sea level, Koppen_Geiger classes (see associated data article),   m2 

terra::inMemory(nc_file)
#> [1] TRUE

# --------------------------------------------

# Download and read NetCDF as SpatRaster; using custom function
nc_file2 <- zenodo_download_file(
  record_id = "6620748",
  file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
  read_func = function(x) { terra::rast(x) * 10 })

print(class(nc_file2))
#> [1] "SpatRaster"
#> attr(,"package")
#> [1] "terra"

print(nc_file2)
#> class       : SpatRaster 
#> size        : 128, 128, 3  (nrow, ncol, nlyr)
#> resolution  : 1.40625, 2.8125  (x, y)
#> extent      : -90, 90, 0, 360  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source(s)   : memory
#> names       :     topo, koppen,         area 
#> min values  :   200.00,     10,   5999121920 
#> max values  : 31916.11,    130, 488827879424 

terra::inMemory(nc_file2)
#> [1] TRUE

# --------------------------------------------

terra::app(nc_file, "range")
#> class       : SpatRaster 
#> size        : 128, 128, 2  (nrow, ncol, nlyr)
#> resolution  : 1.40625, 2.8125  (x, y)
#> extent      : -90, 90, 0, 360  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source      : spat_246765d5369e_9319_8nr4ZcY08gqXcRL.tif 
#> names       : lyr.1,       lyr.2 
#> min values  :     1,   599912192 
#> max values  :    13, 48882786304 
terra::app(nc_file2, "range")
#> class       : SpatRaster 
#> size        : 128, 128, 2  (nrow, ncol, nlyr)
#> resolution  : 1.40625, 2.8125  (x, y)
#> extent      : -90, 90, 0, 360  (xmin, xmax, ymin, ymax)
#> coord. ref. :  
#> source      : spat_246748a40c61_9319_CV8ON4lE27FBVEp.tif 
#> names       : lyr.1,        lyr.2 
#> min values  :    10,   5999121920 
#> max values  :   130, 488827879424 
```
