# Load a File from a Tar Archive

Extracts a single file from a tar archive into a temporary directory,
loads it, and returns the in-memory object. The temporary directory is
always deleted on exit, so file-backed objects such as `SpatRaster` are
read fully into memory before the directory is removed.

## Usage

``` r
load_tar_file(
  tar_file,
  file_to_extract,
  load_fun = "ecokit::load_as",
  wrap_r = TRUE,
  ...
)
```

## Arguments

- tar_file:

  Character. Path to the tar archive file. Supported extensions: `.tar`,
  `.tar.gz`, `.tgz`, `.tar.bz2`, `.tbz2`.

- file_to_extract:

  Character. Path of the file to extract from the archive, exactly as it
  appears in the archive listing (may include subdirectory components).

- load_fun:

  Either a function or a character string naming a function (optionally
  namespace-qualified, e.g. `"readr::read_csv"`) used to load the
  extracted file for non-TIFF,
  non-[`ecokit::load_as`](https://elgabbas.github.io/ecokit/reference/load_as.md)-handled
  types. Defaults to
  [load_as](https://elgabbas.github.io/ecokit/reference/load_as.md).
  Ignored for TIFF files and for files whose extension is handled
  natively by
  [`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md).

- wrap_r:

  Logical. Only relevant when the extracted file is a TIFF. If `TRUE`
  (default), the in-memory `SpatRaster` is wrapped with
  [`terra::wrap()`](https://rspatial.github.io/terra/reference/wrap.html)
  before being returned, making it safe for serialisation (e.g. passing
  across parallel workers). Set to `FALSE` to return a plain
  `SpatRaster`.

- ...:

  Additional arguments passed to `load_fun` (ignored for TIFF files).

## Value

For TIFF files: a `PackedSpatRaster` (when `wrap_r = TRUE`) or a
`SpatRaster` fully loaded into memory (when `wrap_r = FALSE`). For all
other types: the object returned by `load_fun` or
[`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md),
as appropriate.

## Details

For TIFF files (extensions `.tif` or `.tiff`), the function always uses
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
followed by
[`terra::toMemory()`](https://rspatial.github.io/terra/reference/toMemory.html)
to ensure the raster is fully in memory before the temporary extraction
directory is deleted. The `load_fun` argument is therefore **ignored**
for TIFF files. If `wrap_r = TRUE` (the default), the in-memory
`SpatRaster` is additionally wrapped with
[`terra::wrap()`](https://rspatial.github.io/terra/reference/wrap.html)
to make it serialisable for parallel or inter-process transfer.

For files with extensions recognised by
[`load_as()`](https://elgabbas.github.io/ecokit/reference/load_as.md)
(`.rdata`, `.qs2`, `.rds`, `.feather`), that function is called directly
and `load_fun` is ignored.

For all other file types, the function calls `load_fun` on the extracted
file path.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(terra, stringr, fs)

# Build an example tar file containing 3 files
tif_file <- system.file("ex/elev.tif", package = "terra")
rds_file <- fs::file_temp(ext = ".rds")
ecokit::save_as(mtcars, out_path = rds_file)
csv_file <- tempfile(fileext = ".csv")
write.csv(iris, csv_file, row.names = FALSE)
tmp_tar <- fs::file_temp(ext = ".tar")
file_list <- c(tif_file, csv_file, rds_file)
base_names <- basename(file_list)
dirs <- dirname(file_list)
for (i in seq_along(file_list)) {
  tar_flag <- ifelse(i == 1L, "c", "r")
  tar_args <- stringr::str_glue(
    "tar -{tar_flag}f {shQuote(tmp_tar)} -C {shQuote(dirs[i])} \\
    {shQuote(base_names[i])}")
  invisible(system(tar_args))
}

# List contents of the tar file
print(system2("tar", c("-tf", tmp_tar), stdout = TRUE))
#> [1] "elev.tif"             "file217837a65535.csv" "file2178225b1998.rds"

# TIFF: returned fully in memory (wrapped by default)
r <- load_tar_file(
  tar_file = tmp_tar, file_to_extract = "elev.tif")

# TIFF: unwrapped SpatRaster
r2 <- load_tar_file(
  tar_file = tmp_tar, file_to_extract = "elev.tif", wrap_r = FALSE)
terra::sources(r2)  # should be "" (in memory)
#> [1] ""

# CSV via base read.csv
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(csv_file),
  load_fun = "read.csv") %>%
  head()
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa

# RDS (handled automatically by ecokit::load_as)
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(rds_file)) %>%
  head()
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

if (FALSE) { # \dontrun{
# Invalid load_fun: errors with a clear message
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(csv_file),
  load_fun = "function_name")
} # }

# clean up
fs::file_delete(tmp_tar)
```
