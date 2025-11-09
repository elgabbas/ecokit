# Check if a raster stack reads from disk or memory

This function checks whether the layers of a RasterStack object are
stored in memory or read from disk. It prints messages indicating
whether all layers are in memory, all layers are on disk, or a mix of
both. If there's a mix, it specifies which layers are on disk.

## Usage

``` r
check_stack_in_memory(stack = NULL)
```

## Arguments

- stack:

  A RasterStack object. If `NULL`, empty, or not a `RasterStack`, the
  function stops with an error or prints a message for empty stacks.

## Value

Returns `invisible(NULL)` and prints messages to the console indicating
whether all layers are in memory, all are read from disk, or a mix
(specifying which layers are read from disk).

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(raster)

# create a small in-memory raster
r_1 <- raster::raster(nrows = 10, ncols = 10, vals = 1)
r_2 <- raster::raster(nrows = 10, ncols = 10, vals = 2)

# create a stack with one disk-based and one in-memory layer
temp_file_1 <- tempfile(fileext = ".tif")
raster::writeRaster(r_1, temp_file_1)
temp_file_2 <- tempfile(fileext = ".tif")
raster::writeRaster(r_2, temp_file_2)

# ---------------------------------------------

stack1 <- raster::stack(temp_file_1, r_1)
check_stack_in_memory(stack1)
#> Mixed storage: layers 1 are read from disk; others are in memory

# ---------------------------------------------

stack3 <- raster::stack(temp_file_1, temp_file_2)
check_stack_in_memory(stack3)
#> All stack layers are read from disk

# ---------------------------------------------

stack2 <- raster::stack(r_1, r_2)
check_stack_in_memory(stack2)
#> All stack layers reads from memory

# ---------------------------------------------

# clean up
fs::file_delete(c(temp_file_1, temp_file_2))
```
