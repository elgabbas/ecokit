# Retrieve the location of the current R script.

This function determines the file path of the currently executing R
script. It checks command line arguments (e.g., via `Rscript`) for the
script path, then in interactive sessions, it examines the call stack
for the most recently sourced file, falling back to `rstudioapi` (if
available and RStudio is running) when no sourcing context exists. If
the location cannot be determined, it returns `NA`.

## Usage

``` r
script_location()
```

## Source

The source code of this function was adapted from this
[stackoverflow](https://stackoverflow.com/questions/47044068/) question.

## Value

A character string representing the file path of the current R script,
or `NA_character_` if the path cannot be determined (e.g., in an
unsourced interactive session without a script context).

## Details

The function follows this priority order:

- Command line arguments (`--file`) when executed via `Rscript`.

- The most recent `ofile` attribute from the call stack when sourced
  interactively in any R environment, supporting nested sourcing
  scenarios.

- RStudio's active editor context via `rstudioapi` if available, RStudio
  is running, and no sourcing context is found.

- Returns `NA_character_` for unsourced interactive sessions or
  non-interactive execution without a script path.

## Examples

``` r
if (FALSE) { # \dontrun{
  # in an interactive mode, use
  script_location()

  # add script_location() to your script; e.g. "my_script.R"
  # Run: Rscript my_script.R
  # Output: absolute path of the script
} # }
```
