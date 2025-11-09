# Run a system command in a cross-platform manner

This function executes a system command, using either `shell` on Windows
or `system` on Linux. It allows the output of the command to be captured
into an R object.

## Usage

``` r
system_command(command, r_object = TRUE, ...)
```

## Arguments

- command:

  Character. The bash command to be executed.

- r_object:

  Logical. Whether to capture the output of the command as an R object.
  If `TRUE` (Default), the output is captured; if `FALSE`, the output is
  printed to the console.

- ...:

  Additional arguments passed to either `shell` or `system` function,
  depending on the operating system.

## Value

Depending on the value of `r_object`, either the output of the executed
command as an R object or `NULL` if `r_object` is `FALSE` and the output
is printed to the console.

## Author

Ahmed El-Gabbas

## Examples

``` r
# print working directory
system_command("pwd")
#> [1] "/home/runner/work/ecokit/ecokit/docs/reference"
system_command("pwd", r_object = FALSE)
#> /home/runner/work/ecokit/ecokit/docs/reference

# first 5 files on the working directory
(A <- system_command("ls | head -n 5"))
#> [1] "OS.html"                      "add_geometric_features-1.png"
#> [3] "add_geometric_features-2.png" "add_geometric_features.html" 
#> [5] "add_image_to_plot-1.png"     

B <- system_command("ls | head -n 5", r_object = FALSE)
#> OS.html
#> add_geometric_features-1.png
#> add_geometric_features-2.png
#> add_geometric_features.html
#> add_image_to_plot-1.png
B
#> NULL
```
