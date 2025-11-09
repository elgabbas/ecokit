# Remove Options by Name or Pattern

Removes options from the current R session by name or regular expression
pattern.

## Usage

``` r
remove_options(pattern = NULL, regex = FALSE, case_sensitive = FALSE)
```

## Arguments

- pattern:

  Character vector of option names to remove, or a pattern string if
  `regex = TRUE.`

- regex:

  Logical. If `TRUE`, treat `pattern` as a regular expression to match
  option names. Default is `FALSE`.

- case_sensitive:

  Logical. If `TRUE`, matching is case-sensitive. Default is `FALSE`.

## Value

Invisibly returns `NULL`. Removes specified options if found.

## Author

Ahmed El-Gabbas

## Examples

``` r
 # removes option named "my_option"
 options(my_option = 42)
 ecokit::extract_options("my_option")
#> $my_option
#> [1] 42
#> 

 remove_options("my_option")
 ecokit::extract_options("my_option")
#> No options found with the specified pattern

 options(plot1 = 42, plot2 = "yes", plot_extra = TRUE)
 remove_options("plot_", regex = FALSE)
 ecokit::extract_options("plot")
#> $plot1
#> [1] 42
#> 
#> $plot2
#> [1] "yes"
#> 
#> $plot_extra
#> [1] TRUE
#> 

 remove_options("plot_", regex = TRUE)
 ecokit::extract_options("plot")
#> $plot1
#> [1] 42
#> 
#> $plot2
#> [1] "yes"
#> 

 # non-existing pattern (no output or error)
 remove_options("non_existing_pattern_123", regex = TRUE)
 remove_options("non_existing_pattern_123")
```
