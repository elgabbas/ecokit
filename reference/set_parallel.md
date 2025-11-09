# Set up or stop parallel processing plan

Configures parallel processing with
[`future::plan()`](https://future.futureverse.org/reference/plan.html)
or stops an existing plan. When stopping, it resets to sequential mode.

## Usage

``` r
set_parallel(
  n_cores = 1L,
  strategy = "multisession",
  stop_cluster = FALSE,
  show_log = TRUE,
  future_max_size = 500L,
  cat_timestamp = FALSE,
  ...
)
```

## Arguments

- n_cores:

  Integer. Number of cores to use. If `NULL`, defaults to sequential
  mode. Default is `1`.

- strategy:

  Character. The parallel processing strategy to use. Valid options are
  "sequential", "multisession" (default), "multicore", and "cluster".
  See
  [`future::plan()`](https://future.futureverse.org/reference/plan.html)
  and `set_parallel()` for details.

- stop_cluster:

  Logical. If `TRUE`, stops any parallel cluster and resets to
  sequential mode. If `FALSE` (default), sets up a new plan.

- show_log:

  Logical. If `TRUE` (default), logs messages via
  [`cat_time()`](https://elgabbas.github.io/ecokit/reference/cat_time.md).

- future_max_size:

  Numeric. Maximum allowed total size (in megabytes) of global variables
  identified. See `future.globals.maxSize` argument of
  [future::future.options](https://future.futureverse.org/reference/zzz-future.options.html)
  for more details. Default is `500L` for 500 MB.

- cat_timestamp:

  logical; whether to include the time in the timestamp. Default is
  `TRUE`. If `FALSE`, only the text is printed. See
  [`cat_time()`](https://elgabbas.github.io/ecokit/reference/cat_time.md).

- ...:

  Additional arguments to pass to
  [cat_time](https://elgabbas.github.io/ecokit/reference/cat_time.md).

## Author

Ahmed El-Gabbas

## Examples

``` r
load_packages(future)

# number of workers available
future::nbrOfWorkers()
#> [1] 1

# ---------------------------------------------
# `multisession`
# ---------------------------------------------

# Prepare working in parallel
set_parallel(n_cores = 2)
#> Setting up parallel processing using 2 cores (`multisession`)
future::plan("list")
#> List of future strategies:
#> 1. multisession:
#>    - args: function (..., workers = 2L, gc = TRUE)
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = strategy, workers = n_cores, gc = TRUE)
future::nbrOfWorkers()
#> [1] 2

# Stopping parallel processing
set_parallel(stop_cluster = TRUE)
#> Stopping parallel processing
future::plan("list")
#> List of future strategies:
#> 1. sequential:
#>    - args: function (..., gc = TRUE, envir = parent.frame(), workers = "<NULL>")
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = "sequential", gc = TRUE)
future::nbrOfWorkers()
#> [1] 1

# ---------------------------------------------
# `cluster`
# ---------------------------------------------

# Prepare working in parallel
set_parallel(n_cores = 2, strategy = "cluster")
#> Setting up parallel processing using 2 cores (`cluster`)
future::plan("list")
#> List of future strategies:
#> 1. cluster:
#>    - args: function (..., workers = 2L, gc = TRUE)
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = strategy, workers = n_cores, gc = TRUE)
future::nbrOfWorkers()
#> [1] 2

# Stopping parallel processing
set_parallel(stop_cluster = TRUE)
#> Stopping parallel processing
future::plan("list")
#> List of future strategies:
#> 1. sequential:
#>    - args: function (..., gc = TRUE, envir = parent.frame(), workers = "<NULL>")
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = "sequential", gc = TRUE)
future::nbrOfWorkers()
#> [1] 1

# ---------------------------------------------
# `multicore`
# ---------------------------------------------

# Prepare working in parallel
set_parallel(n_cores = 2, strategy = "multicore")
#> Setting up parallel processing using 2 cores (`multicore`)
future::plan("list")
#> List of future strategies:
#> 1. multicore:
#>    - args: function (..., workers = 2L, gc = TRUE)
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = strategy, workers = n_cores, gc = TRUE)
future::nbrOfWorkers()
#> [1] 2
#> attr(,"class")
#> [1] "integer"

# Stopping parallel processing
set_parallel(stop_cluster = TRUE)
#> Stopping parallel processing
future::plan("list")
#> List of future strategies:
#> 1. sequential:
#>    - args: function (..., gc = TRUE, envir = parent.frame(), workers = "<NULL>")
#>    - tweaked: TRUE
#>    - call: future::plan(strategy = "sequential", gc = TRUE)
future::nbrOfWorkers()
#> [1] 1

# ---------------------------------------------
# `sequential`
# ---------------------------------------------

set_parallel(n_cores = 1, strategy = "sequential")
future::nbrOfWorkers()
#> [1] 1
```
