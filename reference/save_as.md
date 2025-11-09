# Save an object to a file with a new name

This function saves an R object to a specified file path with a
potentially new object name. It is useful for renaming objects during
the save process. The function supports saving objects in `RData`,
`qs2`, `feather`, and `rds` formats. The format is determined by the
extension of the file path (case-insensitive).

## Usage

``` r
save_as(
  object = NULL,
  object_name = NULL,
  out_path = NULL,
  n_threads = 1L,
  feather_compression = "zstd",
  ...
)
```

## Arguments

- object:

  The input object to be saved. This can be an actual R object or a
  character string representing the name of an object.

- object_name:

  Character. The new name for the saved `RData` object. This name is
  used when the object is loaded back into R. Default is `NULL`. This is
  required when saving `RData` files.

- out_path:

  Character. File path (ends with either `*.RData`, `*.qs2`, `feather`,
  and `rds`) where the object be saved. This includes the directory and
  the file name.

- n_threads:

  Numeric. Number of threads to use when compressing data. See
  [qs2::qs_save](https://rdrr.io/pkg/qs2/man/qs_save.html).

- feather_compression:

  Character. The compression algorithm to use when saving the object in
  the `feather` format. The default is "zstd". See
  [arrow::write_feather](https://arrow.apache.org/docs/r/reference/write_feather.html).

- ...:

  Additional arguments to be passed to the respective save functions.
  [base::save](https://rdrr.io/r/base/save.html) for `RData` files;
  [qs2::qs_save](https://rdrr.io/pkg/qs2/man/qs_save.html) for `qs2`
  files;
  [arrow::write_feather](https://arrow.apache.org/docs/r/reference/write_feather.html)
  for `feather` files; and
  [base::saveRDS](https://rdrr.io/r/base/readRDS.html) for `rds` files.

## Value

The function does not return a value but saves an object to the
specified file path.

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(fs, tibble)

temp_dir <- fs::path_temp("save_as")
fs::dir_create(temp_dir)
out_file <- fs::path(temp_dir, "iris2.RData")
list.files(temp_dir)
#> character(0)

# save iris data as `iris2.RData` with `iris2` object name
save_as(
  object = tibble::tibble(iris), object_name = "iris2", out_path = out_file)

list.files(temp_dir, pattern = "^.+.RData")
#> [1] "iris2.RData"

# load the object to global environment. The data is loaded as `iris2`
(loaded_name <- load(out_file))
#> [1] "iris2"

ecokit::load_as(out_file)
#> # A tibble: 150 × 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # ℹ 140 more rows

# clean up
fs::file_delete(out_file)
```
