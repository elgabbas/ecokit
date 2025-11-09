# Save non-function objects from the global environment to an RData file

Saves all objects (except functions and specified exclusions) from the
global environment as a named list in an `.RData` file. Returns a
summary of the saved objects' sizes in memory.

## Usage

``` r
save_session(out_directory = getwd(), exclude_objects = NULL, prefix = "S")
```

## Arguments

- out_directory:

  Character. Directory path where the `.RData` file is saved. Defaults
  to the current working directory
  [`base::getwd()`](https://rdrr.io/r/base/getwd.html).

- exclude_objects:

  Character vector. Names of objects to exclude from saving. Defaults to
  `NULL`.

- prefix:

  Character. Prefix for the saved file name. Defaults to `"S"`.

## Value

A tibble with columns `object` (object names) and `size` (size in MB,
rounded to 1 decimal place) for the saved objects, sorted by size in
descending order.

## Examples

``` r
load_packages(fs, purrr)

# Create sample objects in the global environment
assign("df", data.frame(a = 1:1000), envir = .GlobalEnv)
assign("vec", rnorm(1000), envir = .GlobalEnv)
assign("fun", function(x) x + 1, envir = .GlobalEnv)
ls(.GlobalEnv)
#>  [1] "AA1"             "AA2"             "R"               "chelsa_var_info"
#>  [5] "df"              "envir"           "fun"             "ifnotfound"     
#>  [9] "inherits"        "mode"            "nm"              "object"         
#> [13] "vec"             "x"               "y"              

# Save objects to a unique temporary directory, excluding "vec"
temp_dir <- fs::path_temp("save_session")
fs::dir_create(temp_dir)

(result <- save_session(out_directory = temp_dir, exclude_objects = "vec"))
#> Saved objects to:
#> /tmp/RtmpIhN7qQ/save_session/S_20251109_1926.RData
#> # A tibble: 13 × 2
#>    object           size
#>    <chr>           <dbl>
#>  1 AA1              38.1
#>  2 AA2               0.4
#>  3 R                 0  
#>  4 chelsa_var_info   0  
#>  5 df                0  
#>  6 envir             0  
#>  7 ifnotfound        0  
#>  8 inherits          0  
#>  9 mode              0  
#> 10 nm                0  
#> 11 object            0  
#> 12 x                 0  
#> 13 y                 0  

# Load saved objects
saved_files <- list.files(
  temp_dir, pattern = "S_.+\\.RData$", full.names = TRUE)
if (length(saved_files) == 0) {
  stop("No RData files found in temp_dir")
}
# pick the most recent file, if there is more than one file
(saved_file <- saved_files[length(saved_files)])
#> [1] "/tmp/RtmpIhN7qQ/save_session/S_20251109_1926.RData"

saved_objects <- ecokit::load_as(saved_file)
#> Error in purrr::map(.x = output_file, .f = ~{    if (inherits(.x, "PackedSpatRaster"))         return("PackedSpatRaster")    if (isS4(.x) || length(.x) == 0L || is.null(.x[[1L]])) {        return(character(0L))    }    class(.x[[1L]])}): ℹ In index: 6.
#> ℹ With name: envir.
#> Caused by error in `.x[[1L]]`:
#> ! wrong arguments for subsetting an environment
names(saved_objects)
#> Error: object 'saved_objects' not found
str(saved_objects, 1)
#> Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'str': object 'saved_objects' not found

setdiff(
  ls(.GlobalEnv),
  c(result$object, "saved_file", "result", "saved_objects", "temp_dir")) %>%
  purrr::map(~ stats::setNames(class(get(.x, envir = .GlobalEnv)), .x)) %>%
  unlist()
#>        fun        vec 
#> "function"  "numeric" 

# Clean up
fs::dir_delete(temp_dir)
```
