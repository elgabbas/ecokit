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
#> $ title       <chr> "Phanerozoic continental climate and Köppen–Geiger climate classes", "Phanerozoic continental climate and Köppen–Geiger climate classes", "Phanerozoic continental climate and Köppen–Geiger climate classes", "Phanerozoic continental climate and Köppen–Geiger climate classes", "Phanerozoic continental climate and Köppen–Geiger climate classes", "Phanerozoic continental climate …
#> $ id_url      <chr> "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", "https://zenodo.org/api/records/6620748", …
#> $ created     <dttm> 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05, 2022-06-07 15:21:05,…
#> $ modified    <dttm> 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29,…
#> $ updated     <dttm> 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29, 2024-07-16 15:44:29,…
#> $ doi_version <chr> "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenodo.6620748", "10.5281/zenod…
#> $ doi         <chr> "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenodo.6402040", "10.5281/zenod…
#> $ id          <int> 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, 6620748, …
#> $ key         <chr> "40Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc", "0Ma_Pohletal2022_DIB_PhaneroContinentalClimate.csv", "0Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc", "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.csv", "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc", "120Ma_Pohletal2022_DIB_PhaneroContinentalClimate.csv", "120Ma_Pohletal2022_DIB_PhaneroContinentalClimate.…
#> $ size        <int> 8261200, 14498683, 8261200, 14573851, 8261200, 14407735, 8261200, 15328128, 8261200, 12718896, 8261200, 14026230, 8261200, 15003813, 8261200, 15117199, 8261200, 14141045, 8261200, 14804994, 8261200, 12550434, 8261200, 11977973, 8261200, 11629677, 32824202, 19087436, 68368591, 8261200, 13335048, 8261200, 14727520, 8261200, 11330048, 8261200, 10698643, 8261200, 11087698, 826120…
#> $ checksum    <chr> "md5:e9ca6e5e58b7b892c2dfd00fffdcc7af", "md5:65ee19cbf3da6a3190f8be8b2312055e", "md5:b59dacf289dc4a3d01a5c551ffab76f2", "md5:8ff79ab6df7e2858edf30a03d5c2b5b7", "md5:69b44851e9c05aa82be467e38d94e79e", "md5:be7376d7971abd7c195576fd018942df", "md5:1a518b2ecb281d9d11c34ceb6ccc1b89", "md5:b67a50025999b71288407d6c085a97d2", "md5:92e4f4a102f0ab4a4952fd77f58eb9d1", "md5:ab390d845300d…
#> $ link        <chr> "https://zenodo.org/api/records/6620748/files/40Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc/content", "https://zenodo.org/api/records/6620748/files/0Ma_Pohletal2022_DIB_PhaneroContinentalClimate.csv/content", "https://zenodo.org/api/records/6620748/files/0Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc/content", "https://zenodo.org/api/records/6620748/files/100Ma_Pohlet…

# --------------------------------------------

# Download as file only
pdf_file <- zenodo_download_file(
  record_id = "1234567", file_name = "article.pdf")
print(pdf_file)
#> /tmp/RtmpWSxkbf/article2121140c2f2f.pdf

ecokit::file_type(pdf_file)
#> [1] "PDF document, version 1.6"
try(fs::file_delete(pdf_file), silent = TRUE)

# --------------------------------------------

# Download and read NetCDF as SpatRaster
nc_file <- zenodo_download_file(
  record_id = "6620748",
  file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
  read_func = terra::rast)
#> Warning: [rast] guessed crs

print(class(nc_file))
#> [1] "SpatRaster"
#> attr(,"package")
#> [1] "terra"

print(nc_file)
#> class       : SpatRaster
#> size        : 128, 128, 63  (nrow, ncol, nlyr)
#> dimensions  : time, lat, lon (12, 128, 128}
#> resolution  : 2.8125, 1.40625  (x, y)
#> extent      : 0, 360, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source(s)   : memory
#> varname     : PmE (precipitation minus evaporation balance)
#> names       :    PmE_1,    PmE_2,    PmE_3,    PmE_4,    PmE_5,    PmE_6, ...
#> unit        : mm day-1, mm day-1, mm day-1, mm day-1, mm day-1, mm day-1, ...

terra::inMemory(nc_file)
#> [1] TRUE

# --------------------------------------------

# Download and read NetCDF as SpatRaster; using custom function
nc_file2 <- zenodo_download_file(
  record_id = "6620748",
  file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
  read_func = function(x) { terra::rast(x) * 10 })
#> Warning: [rast] guessed crs

print(class(nc_file2))
#> [1] "SpatRaster"
#> attr(,"package")
#> [1] "terra"

print(nc_file2)
#> class       : SpatRaster
#> size        : 128, 128, 63  (nrow, ncol, nlyr)
#> resolution  : 2.8125, 1.40625  (x, y)
#> extent      : 0, 360, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84)
#> source(s)   : memory
#> names       :                                  PmE_1,                                  PmE_2,                                  PmE_3,                                  PmE_4,                                  PmE_5,                                  PmE_6, ...
#> min values  :                              -26.04104,                             -20.056664,                             -17.386028,                             -27.430588,                             -25.757488,                             -20.652157, ...
#> max values  : 99692099683868690467785529521025843200, 99692099683868690467785529521025843200, 99692099683868690467785529521025843200, 99692099683868690467785529521025843200, 99692099683868690467785529521025843200, 99692099683868690467785529521025843200, ...

terra::inMemory(nc_file2)
#> [1] TRUE

# --------------------------------------------

terra::app(nc_file, "range")
#> class       : SpatRaster
#> size        : 128, 128, 2  (nrow, ncol, nlyr)
#> resolution  : 2.8125, 1.40625  (x, y)
#> extent      : 0, 360, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> source      : spat_21217949e358_8481_rUCLcxsvO3wjAGy.tif
#> names       :                                 lyr.1,                                 lyr.2
#> min values  :                            -42.894333,                             599912192
#> max values  : 9969209968386899742160691604796473344, 9969209968386899742160691604796473344
terra::app(nc_file2, "range")
#> class       : SpatRaster
#> size        : 128, 128, 2  (nrow, ncol, nlyr)
#> resolution  : 2.8125, 1.40625  (x, y)
#> extent      : 0, 360, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326)
#> source      : spat_212150c10a69_8481_QYXbw8PZyYIJh7f.tif
#> names       :                                  lyr.1,                                  lyr.2
#> min values  :                            -428.943329,                             5999121920
#> max values  : 99692099683868992699240433178319519744, 99692099683868992699240433178319519744
```
