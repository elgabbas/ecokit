# Replace whitespace with underscores

Replaces all whitespace characters (spaces, tabs, etc.) with underscores
in a character vector. This is a wrapper around
[`stringr::str_replace_all()`](https://stringr.tidyverse.org/reference/str_replace.html)
for formatting strings in contexts where whitespace is not allowed
(e.g., file names, variable names). Optionally, a custom replacement
character can be specified.

## Usage

``` r
replace_space(x, replacement = "_")
```

## Arguments

- x:

  A character vector. Each element is processed to replace whitespace
  with underscores. Missing values (`NA`) are preserved.

- replacement:

  A single character string to replace whitespace. Defaults to `"_"`
  (underscore). Must be of length 1.

## Value

A character vector of the same length as `x`, with all whitespace
characters replaced by `replacement`. Missing values (`NA`) are returned
unchanged.

## See also

[`stringr::str_replace_all()`](https://stringr.tidyverse.org/reference/str_replace.html)
for the underlying function,
[`gsub()`](https://rdrr.io/r/base/grep.html) for base R alternative.

## Examples

``` r
# Basic usage
replace_space("Genus species")
#> [1] "Genus_species"

# Vector input
replace_space(c("Genus species1", "Genus species2"))
#> [1] "Genus_species1" "Genus_species2"
replace_space(c("Genus species 1", "Genus species 2"))
#> [1] "Genus_species_1" "Genus_species_2"

# Multiple whitespace types
replace_space("Genus   species\tname")
#> [1] "Genus_species_name"

# Custom replacement
replace_space("Genus species", replacement = "-")
#> [1] "Genus-species"

# Handle missing values
replace_space(c("Genus species 1", NA, "Genus species 2"))
#> [1] "Genus_species_1" NA                "Genus_species_2"

# Empty strings
replace_space("")
#> [1] ""
```
