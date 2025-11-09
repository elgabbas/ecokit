# Signal structured errors with metadata, timestamps, and backtraces

Signals errors with rich context, wrapping
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html). It
includes:

- The calling function name (if applicable).

- User-defined metadata (e.g., vectors, lists, data frames, tibbles,
  SpatRaster, RasterLayer, RasterStack, RasterBrick, sf objects,
  regression models, ggplot objects, S4 objects).

- Optional timestamps/dates.

- Optional backtraces to aid debugging.

## Usage

``` r
stop_ctx(
  message,
  ...,
  class = NULL,
  call = NULL,
  parent = NULL,
  include_backtrace = FALSE,
  cat_timestamp = FALSE,
  cat_date = FALSE
)
```

## Arguments

- message:

  Character. The primary error message to display.

- ...:

  Named R objects to include as metadata. These can be of various types,
  such as vectors, lists, data frames, tibbles, SpatRaster, RasterLayer,
  RasterStack, RasterBrick, sf objects, regression models (e.g., lm,
  glm), ggplot objects, S4 objects, and more. Unnamed arguments will
  cause an error due to `.named = TRUE` in
  [`rlang::enquos()`](https://rlang.r-lib.org/reference/enquo.html).
  `NULL` values are displayed as "NULL".

- class:

  Character or `NULL.` Subclass(es) for the error condition. Defaults to
  `NULL`. See
  [rlang::abort](https://rlang.r-lib.org/reference/abort.html) for more
  details.

- call:

  Call or `NULL`. The call causing the error. Defaults to the caller's
  expression. See
  [rlang::abort](https://rlang.r-lib.org/reference/abort.html) for more
  details.

- parent:

  Condition or `NULL`. Parent error for nesting. Defaults to `NULL`. See
  [rlang::abort](https://rlang.r-lib.org/reference/abort.html) for more
  details.

- include_backtrace:

  Logical. If `TRUE`, includes a compact backtrace. Default: `FALSE`.

- cat_timestamp:

  Logical. If `TRUE`, prepends a timestamp (HH:MM:SS). Default: `TRUE`.

- cat_date:

  Logical. If `TRUE`, prepends the date (YYYY-MM-DD). Default: `FALSE`.

## Value

Does not return; throws an error via
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html).

## Metadata Output

The metadata section in the error message displays each provided object
with its name, the verbatim expression used, its class, and its value:

- **Object Name**: The name of the argument (e.g., `file`).

- **Verbatim Expression**: The expression passed (e.g., `"data.csv"`).

- **Class**: The class of the object, with multiple classes concatenated
  using `+` (e.g., `<tbl_df + tbl + data.frame>`).

- **Value**: The formatted output of the object, using methods like
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`glimpse()`](https://pillar.r-lib.org/reference/glimpse.html), or
  [`str()`](https://rdrr.io/r/utils/str.html), depending on the object
  type.

For example:

      ----- Metadata -----
      file ["data.csv"]: <character>
      "data.csv"

      type ["missing_input"]: <character>
      "missing_input"
      

Complex objects, such as data frames or raster layers, will display
their structure or summary as appropriate.

## Author

Ahmed El-Gabbas

## Examples

``` r
# loading packages
load_packages(dplyr, sf, terra, raster)

# -------------------------------------------------------------------

# Basic error with metadata and backtrace
try(
  stop_ctx(
    message = "File not found", file = "data.csv",
    type = "missing_input", foo = 1:3, include_backtrace = TRUE))
#> Error in try(stop_ctx(message = "File not found", file = "data.csv", type = "missing_input",  : 
#>   File not found
#> 
#> ----- Metadata -----
#> 
#> file ["data.csv"]: <character>
#> data.csv
#> 
#> type ["missing_input"]: <character>
#> missing_input
#> 
#> foo [1:3]: <integer>
#> 1, 2, 3
#> 
#> ----- Backtrace -----
#>   1. └─pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
#>   2.   └─pkgdown::build_site(...)
#>   3.     └─pkgdown:::build_site_local(...)
#>   4.       └─pkgdown::build_reference(...)
#>   5.         ├─pkgdown:::unwrap_purrr_error(...)
#>   6.         │ └─base::withCallingHandlers(...)
#>   7.         └─purrr::map(...)
#>   8.           └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
#>   9.             ├─purrr:::with_indexed_errors(...)
#>  10.             │ └─base::withCallingHandlers(...)
#>  11.             ├─purrr:::call_with_cleanup(...)
#>  12.             └─pkgdown (local) .f(.x[[i]], ...)
#>  13.               ├─base::withCallingHandlers(...)
#>  14.               └─pkgdown:::data_reference_topic(...)
#>  15.                 └─pkgdown:::run_examples(...)
#>  16.                   └─pkgdown:::highlight_examples(code, topic, env = env)
#>  17.                     └─downlit::evaluate_and_highlight(...)
#>  18.                       └─evaluate::evaluate(code, child_env(env), new_device = TRUE, output_handler = output_handler)
#>  19.                         ├─base::withRestarts(...)
#>  20.                         │ └─base (local) withRestartList(expr, restarts)
#>  21.                         │   ├─base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
#>  22.                         │   │ └─base (local) doWithOneRestart(return(expr), restart)
#>  23.                         │   └─base (local) withRestartList(expr, restarts[-nr])
#>  24.                         │     └─base (local) withOneRestart(expr, restarts[[1L]])
#>  25.                         │       └─base (local) doWithOneRestart(return(expr), restart)
#>  26.                         ├─evaluate:::with_handlers(...)
#>  27.                         │ ├─base::eval(call)
#>  28.                         │ │ └─base::eval(call)
#>  29.                         │ └─base::withCallingHandlers(...)
#>  30.                         ├─base::withVisible(eval(expr, envir))
#>  31.                         └─base::eval(expr, envir)
#>  32.                           └─base::eval(expr, envir)

# -------------------------------------------------------------------

# Include date in error message; no backtrace
try(
  stop_ctx(
    message = "File not found", file = "data.csv",
    type = "missing_input", cat_date = TRUE))
#> Error in try(stop_ctx(message = "File not found", file = "data.csv", type = "missing_input",  : 
#>   File not found - 09/11/2025
#> 
#> ----- Metadata -----
#> 
#> file ["data.csv"]: <character>
#> data.csv
#> 
#> type ["missing_input"]: <character>
#> missing_input

# -------------------------------------------------------------------

# Complex objects as metadata
terra_obj <- terra::rast()
raster_obj <- raster::raster()
sf_obj <- sf::st_point(c(0,0))
lm_obj <- lm(mpg ~ wt, data = mtcars)
try(
  stop_ctx(
    message = "File not found", raster = raster_obj, terra = terra_obj,
    data_frame = iris, matrix = as.matrix(iris), sf_obj = sf_obj,
    lm_obj = lm_obj))
#> Error in try(stop_ctx(message = "File not found", raster = raster_obj,  : 
#>   File not found
#> 
#> ----- Metadata -----
#> 
#> raster [raster_obj]: <RasterLayer>
#> class      : RasterLayer 
#> dimensions : 180, 360, 64800  (nrow, ncol, ncell)
#> resolution : 1, 1  (x, y)
#> extent     : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> crs        : +proj=longlat +datum=WGS84 +no_defs 
#> 
#> terra [terra_obj]: <SpatRaster>
#> class       : SpatRaster 
#> size        : 180, 360, 1  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (CRS84) (OGC:CRS84) 
#> 
#> data_frame [iris]: <data.frame>
#> Rows: 150
#> Columns: 5
#> $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.…
#> $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.…
#> $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.…
#> $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.…
#> $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s…
#> 
#> matrix [as.matrix(iris)]: <matrix + array>
#>  chr [1:150, 1:5] "5.1" "4.9" "4.7" "4.6" "5.0" "5.4" "4.6" "5.0" "4.4" ...
#>  - attr(*, "dimnames")=List of 2
#>   ..$ : NULL
#>   ..$ : chr [1:5] "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" ...
#> 
#> sf_obj [sf_obj]: <XY + POINT + sfg>
#> 0, 0
#> 
#> lm_obj [lm_obj]: <lm>
#> Call:
#> lm(formula = mpg ~ wt, data = mtcars)
#> Coefficients:
#> (Intercept)           wt  
#>      37.285       -5.344  

# -------------------------------------------------------------------

# S4 object as metadata
setClass("Student", slots = list(name = "character", age = "numeric"))
student <- new("Student", name = "John Doe", age = 23)
try(
  stop_ctx(
    message = "Student record error",
    metadata = student, type = "invalid_data", include_backtrace = FALSE))
#> Error in try(stop_ctx(message = "Student record error", metadata = student,  : 
#>   Student record error
#> 
#> ----- Metadata -----
#> 
#> metadata [student]: <Student>
#>  Length   Class    Mode 
#>       1 Student      S4 
#> 
#> type ["invalid_data"]: <character>
#> invalid_data

# -------------------------------------------------------------------

# Nested function error with backtrace
f3 <- function(x) {
  stop_ctx("Non-numeric input in f3()", input = x, include_backtrace = TRUE)
}
f2 <- function(y) f3(y + 1)
f1 <- function(z) f2(z * 3)

# Output includes: "Calling Function: f1" before metadata
try(f1("not a number"))
#> Error : Error evaluating argument 'input': non-numeric argument to binary operator

# -------------------------------------------------------------------

# Nested function error without metadata
f3 <- function() {
  stop_ctx(message = "Error in f3()", include_backtrace = TRUE)
}
f2 <- function(y) f3()
f1 <- function(z) f2()

# Output includes: "Calling Function: f1" before metadata
try(f1())
#> Error in f3() : Error in f3()
#> 
#> ----- Backtrace -----
#>   1. └─pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
#>   2.   └─pkgdown::build_site(...)
#>   3.     └─pkgdown:::build_site_local(...)
#>   4.       └─pkgdown::build_reference(...)
#>   5.         ├─pkgdown:::unwrap_purrr_error(...)
#>   6.         │ └─base::withCallingHandlers(...)
#>   7.         └─purrr::map(...)
#>   8.           └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
#>   9.             ├─purrr:::with_indexed_errors(...)
#>  10.             │ └─base::withCallingHandlers(...)
#>  11.             ├─purrr:::call_with_cleanup(...)
#>  12.             └─pkgdown (local) .f(.x[[i]], ...)
#>  13.               ├─base::withCallingHandlers(...)
#>  14.               └─pkgdown:::data_reference_topic(...)
#>  15.                 └─pkgdown:::run_examples(...)
#>  16.                   └─pkgdown:::highlight_examples(code, topic, env = env)
#>  17.                     └─downlit::evaluate_and_highlight(...)
#>  18.                       └─evaluate::evaluate(code, child_env(env), new_device = TRUE, output_handler = output_handler)
#>  19.                         ├─base::withRestarts(...)
#>  20.                         │ └─base (local) withRestartList(expr, restarts)
#>  21.                         │   ├─base (local) withOneRestart(withRestartList(expr, restarts[-nr]), restarts[[nr]])
#>  22.                         │   │ └─base (local) doWithOneRestart(return(expr), restart)
#>  23.                         │   └─base (local) withRestartList(expr, restarts[-nr])
#>  24.                         │     └─base (local) withOneRestart(expr, restarts[[1L]])
#>  25.                         │       └─base (local) doWithOneRestart(return(expr), restart)
#>  26.                         ├─evaluate:::with_handlers(...)
#>  27.                         │ ├─base::eval(call)
#>  28.                         │ │ └─base::eval(call)
#>  29.                         │ └─base::withCallingHandlers(...)
#>  30.                         ├─base::withVisible(eval(expr, envir))
#>  31.                         └─base::eval(expr, envir)
#>  32.                           └─base::eval(expr, envir)
#>  33.                             ├─base::try(f1())
#>  34.                             │ └─base::tryCatch(...)
#>  35.                             │   └─base (local) tryCatchList(expr, classes, parentenv, handlers)
#>  36.                             │     └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
#>  37.                             │       └─base (local) doTryCatch(return(expr), name, parentenv, handler)
#>  38.                             └─f1()
#>  39.                               └─f2()
#>  40.                                 └─f3()

# -------------------------------------------------------------------

if (FALSE) { # \dontrun{
  # Unnamed arguments will cause an error
  stop_ctx("A", "X")
} # }
```
