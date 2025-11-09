# Write a SpatRaster to a NetCDF File with Multiple Variables

This function takes a
[`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object and writes it to a NetCDF file. Each layer of the input raster is
saved as a separate, correctly named variable in the output file. This
function uses the `ncdf4` package for robust, low-level control over the
NetCDF creation process, ensuring that layer names, CRS, and other
metadata are preserved and compression is applied correctly.

## Usage

``` r
write_nc(
  input_raster = NULL,
  filename = NULL,
  overwrite = FALSE,
  compression_level = 9L,
  missval = -9999L,
  var_units = ""
)
```

## Arguments

- input_raster:

  A
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object with one or more layers. The names of the layers will be used
  as the variable names in the `NetCDF` file.

- filename:

  Character. The file path for the output NetCDF file. It is recommended
  to use a `.nc` extension.

- overwrite:

  Logical. If `TRUE`, an existing file at the specified `filename` will
  be overwritten. Defaults to `FALSE`.

- compression_level:

  An integer between 0 (no compression) and 9 (maximum DEFLATE
  compression). Defaults to `9`.

- missval:

  Numeric. Value for missing values in the NetCDF file. Defaults to
  `-9999`.

- var_units:

  A character string or a vector of character strings specifying the
  units for each variable. If a single string is provided, it will be
  applied to all variables. If a vector, its length must match the
  number of layers in `input_raster`. Defaults to empty string `""`.

## Value

This function does not return a value. It is called for its side effect
of writing a file to disk.

## Author

Ahmed El-Gabbas

## Examples

``` r
require(terra)
require(ncdf4)
#> Loading required package: ncdf4
require(dismo)

fnames <- list.files(
  path = paste(system.file(package = "dismo"), "/ex", sep = ""),
  pattern = "grd", full.names = TRUE)

predictors <- terra::toMemory(terra::rast(fnames))
names(predictors)
#> [1] "bio1"  "bio12" "bio16" "bio17" "bio5"  "bio6"  "bio7"  "bio8"  "biome"

# Define an output file path
output_file <- tempfile(fileext = ".nc")

# Use the function to write the SpatRaster to a NetCDF file
write_nc(
  input_raster = predictors,
  filename = output_file,
  overwrite = TRUE,
  compression_level = 7)

# Verify the result
predictors2 <- terra::rast(output_file)
print(identical(names(predictors), names(predictors2)))
#> [1] TRUE

difference_raster <- predictors - predictors2
print(terra::minmax(difference_raster))
#>     bio1 bio12 bio16 bio17 bio5 bio6 bio7 bio8 biome
#> min    0     0     0     0    0    0    0    0     0
#> max    0     0     0     0    0    0    0    0     0

# Clean up the temporary file
unlink(output_file)
```
