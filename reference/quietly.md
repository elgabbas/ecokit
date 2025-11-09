# Quietly Evaluate an Expression with Custom Warning Patterns

Evaluates an R expression while suppressing package startup messages and
selected warnings and messages. By default, warnings containing "was
built under R version" or "Loading required namespace" are muffled.
Additional patterns (regular expressions) can be provided via `...` to
suppress matching warnings or messages.

## Usage

``` r
quietly(expr, ...)
```

## Arguments

- expr:

  An R expression to be evaluated quietly. This can be a single
  expression or a block of code wrapped in curly brackets.

- ...:

  Additional character strings. Each value will be treated as a regular
  expression pattern to match in warning or message text to muffle. For
  example,
  `quietly(expr, "Picked up JAVA_TOOL_OPTIONS", "Scale for [xy] is already present\\.")`.

## Value

The result of evaluating `expr`, with specified messages and warnings
suppressed.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Suppress a package startup message and a version warning
ecokit::quietly({
  warning("This package was built under R version 4.3.1", call. = FALSE)
})

# Suppress a custom warning pattern (e.g., JAVA_TOOL_OPTIONS)
ecokit::quietly({
 warning(
   "Picked up JAVA_TOOL_OPTIONS: -Djava.util.prefs.userRoot=/tmp/.java1234",
   call. = FALSE)
},
"Picked up JAVA_TOOL_OPTIONS")

# Suppress multiple custom warning patterns
ecokit::quietly({
  warning("Couldn't flush user prefs", call. = FALSE)
  warning("java.util.prefs.FileSystemPreferences error", call. = FALSE)
},
"Couldn't flush user prefs", "java.util.prefs.FileSystemPreferences")

# Show that a non-matching warning still prints
ecokit::quietly({
  warning("This is a normal warning and should be displayed", call. = FALSE)
},
"Picked up JAVA_TOOL_OPTIONS")
#> Warning: This is a normal warning and should be displayed

# Use a code block with multiple lines, some of which trigger warnings
ecokit::quietly({
  # suppressed by default
  warning("Loading required namespace: foo", call. = FALSE)
  # suppressed by default
  warning("was built under R version 4.3.0", call. = FALSE)
  # not suppressed, will be shown
  warning("Something else", call. = FALSE)
})
#> Warning: Something else

# Suppress specific messages using regular expression patterns
ecokit::quietly({
  message("Scale for y is already present.")
  message("Scale for x is already present.")
  message("TTT")
  warning("Something else")
},
"Scale for [xy] is already present\\.")
#> TTT
#> Warning: Something else

# Error if ... is not character
try(ecokit::quietly({ warning("test", call. = FALSE) }, 1L))
#> Error in ecokit::quietly({ : 
#>   All `...` arguments to `quietly` must be character strings.
#> 
#> ----- Metadata -----
#> 
#> class_dots [toString(sapply(dots, class))]: <character>
#> integer

# Error if expr is not a language object
try(ecokit::quietly("not an expression"))
#> Error in ecokit::quietly("not an expression") : 
#>   Argument `expr` must be an R expression (code or block wrapped in curly brackets).
#> 
#> ----- Metadata -----
#> 
#> class_expr [class(expr_sub)]: <character>
#> character
```
