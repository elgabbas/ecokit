# Suppress Future Device Warnings and Startup Messages

This function evaluates an expression and selectively suppresses:

- Warnings related to device state changes (e.g., opening or closing
  graphical devices) that occur inside `future` parallel workers (e.g.,
  with `multisession` or `multicore` plans).

- Package startup messages emitted during package loading in parallel
  workers (e.g., from `ggplot2` or `terra` in `multicore` plans).

## Usage

``` r
quiet_device(expr)
```

## Arguments

- expr:

  An R expression to evaluate. This is the code block in which graphics
  device warnings or startup messages from futures might occur.

## Value

The result of evaluating `expr`, with specific future device warnings
and package startup messages suppressed.

## Details

When using
[`future.apply::future_lapply()`](https://future.apply.futureverse.org/reference/future_lapply.html)
or similar parallel calls, certain functions— notably
[`ggplot2::ggplotGrob()`](https://ggplot2.tidyverse.org/reference/ggplotGrob.html),
[`cowplot::as_grob()`](https://wilkelab.org/cowplot/reference/as_grob.html),
or `ggExtra::ggMarginal()`—may implicitly trigger graphics device
changes (e.g., opening a PDF device internally). This causes `future` to
emit a `DeviceMisuseFutureWarning`, warning that devices were added,
removed, or modified within a future. Additionally, in `multicore`
plans, forked processes may emit startup messages from packages
(particularly when using `future.packages` argument), cluttering output.
This function suppresses both types of output while allowing other
warnings and messages to pass through.

## Author

Ahmed El-Gabbas

## Examples

``` r
if (FALSE) { # \dontrun{
  library(future)
  library(future.apply)
  library(ggplot2)
  library(parallelly)

  # Use multicore if supported, otherwise fall back to multisession
  plan_type <- ifelse(
      parallelly::supportsMulticore(), "multicore", "multisession")
  future::plan(plan_type, workers = 2, gc = TRUE)

  fun1 <- function(x) {
    # Loading ecokit triggers startup messages
    library(ecokit)

    p <- data.frame(x = rnorm(100), y = rnorm(100)) %>%
      ggplot2::ggplot(ggplot2::aes(x, y)) +
      ggplot2::geom_point()

    # this triggers device warnings
    return(grob)
  }

  # This will trigger device warnings and startup messages
  plots <- future.apply::future_lapply(1:5, fun1, future.seed = TRUE)

  # Run with suppression of device warnings and startup messages
  plots <- future.apply::future_lapply(1:5, fun1, future.seed = TRUE) %>%
    quiet_device()
  plot(plots[[1]])

  future::plan("sequential")
} # }
```
