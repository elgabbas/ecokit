# Load a File from a Tar Archive

This function extracts a specified file from a tar archive to a
temporary directory, loads it using a provided loading function, and
returns the loaded object.

## Usage

``` r
load_tar_file(tar_file, file_to_extract, load_fun = "ecokit::load_as", ...)
```

## Arguments

- tar_file:

  Character. Path to the tar archive file.

- file_to_extract:

  Character. Path of the file to extract from the tar archive (can
  include directories within the archive).

- load_fun:

  Either a function or a character string naming a function (possibly
  with package namespace like "package::function") to load the extracted
  file. Defaults to
  [load_as](https://elgabbas.github.io/ecokit/reference/load_as.md).

- ...:

  Additional arguments passed to the loading function.

## Value

The object returned by the loading function applied to the extracted
file.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(terra, stringr, fs)

# example tar file containing 3 files

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
tar_flag <- ifelse(i == 1, "c", "r")
  tar_args <- str_glue(
    'tar -{tar_flag}f {shQuote(tmp_tar)} -C {shQuote(dirs[i])} \\
    {shQuote(base_names[i])}')
  invisible(system(tar_args))
}

# List contents of the tar file
print(system2("tar", c("-tf", tmp_tar), stdout = TRUE))
#> [1] "elev.tif"             "file24651d848c27.csv" "file24656fddf07d.rds"

# example SpatRaster
load_tar_file(
  tar_file = tmp_tar, file_to_extract = "elev.tif",
  load_fun = "terra::rast")
#> class       : SpatRaster 
#> size        : 90, 95, 1  (nrow, ncol, nlyr)
#> resolution  : 0.008333333, 0.008333333  (x, y)
#> extent      : 5.741667, 6.533333, 49.44167, 50.19167  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source      : elev.tif 
#> name        : elevation 
#> min value   :       141 
#> max value   :       547 

# example CSV file using readr
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

# example rds file
load_tar_file(
  tar_file = tmp_tar, file_to_extract = basename(rds_file),
  load_fun = readRDS) %>%
  head()
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```
