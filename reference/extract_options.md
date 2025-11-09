# Extract Options Matching a Pattern

Returns a subset of the current R session options whose names match a
given pattern.

## Usage

``` r
extract_options(pattern = "", case_sensitive = FALSE)
```

## Arguments

- pattern:

  Character string. Pattern to search for in option names. If empty
  (`""`), all options are returned.

- case_sensitive:

  Logical. If TRUE, pattern matching is case-sensitive. Default is
  FALSE.

## Value

A list of matched options, or all options if pattern is `""`. If no
matches are found, returns `NULL` (invisibly) and prints a message.

## Author

Ahmed El-Gabbas

## Examples

``` r
# all options
all_options <- extract_options()
length(all_options)
#> [1] 131

# all options with "warn" in the name (case-insensitive)
extract_options(pattern = "warn")
#> $datatable.dfdispatchwarn
#> [1] TRUE
#> 
#> $datatable.warnredundantby
#> [1] TRUE
#> 
#> $nwarnings
#> [1] 50
#> 
#> $showWarnCalls
#> [1] FALSE
#> 
#> $spam.inefficiencywarning
#> [1] 1e+06
#> 
#> $warn
#> [1] 0
#> 
#> $warnPartialMatchArgs
#> [1] FALSE
#> 
#> $warnPartialMatchAttr
#> [1] FALSE
#> 
#> $warnPartialMatchDollar
#> [1] FALSE
#> 
#> $warning.length
#> [1] 1000
#> 

# options starting with "r" (case-sensitive)
extract_options(pattern = "^r", case_sensitive = TRUE)
#> $repos
#>                                                          RSPM 
#> "https://packagemanager.posit.co/cran/__linux__/noble/latest" 
#>                                                          CRAN 
#>                                    "https://cran.rstudio.com" 
#> 
#> $rl_word_breaks
#> [1] " \t\n\"\\'`><=%;,|&{()}"
#> 
#> $rlang_interactive
#> [1] FALSE
#> 
#> $rlang_trace_top_env
#> <environment: 0x556441811300>
#> 

# non-existing pattern
extract_options(pattern = "non_existing_pattern_123")
#> No options found with the specified pattern
```
