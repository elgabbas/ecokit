#' Suppress Future Device Warnings and Startup Messages
#'
#' This function evaluates an expression and selectively suppresses:
#' - Warnings related to device state changes (e.g., opening or closing
#' graphical devices) that occur inside `future` parallel workers (e.g., with
#' `multisession` or `multicore` plans).
#' - Package startup messages emitted during package loading in parallel workers
#' (e.g., from `ggplot2` or `terra` in `multicore` plans).
#'
#' When using `future.apply::future_lapply()` or similar parallel calls, certain
#' functions— notably `ggplot2::ggplotGrob()`, `cowplot::as_grob()`, or
#' `ggExtra::ggMarginal()`—may implicitly trigger graphics device changes (e.g.,
#' opening a PDF device internally). This causes `future` to emit a
#' `DeviceMisuseFutureWarning`, warning that devices were added, removed, or
#' modified within a future. Additionally, in `multicore` plans, forked
#' processes may emit startup messages from packages (particularly when using
#' `future.packages` argument), cluttering output. This function suppresses both
#' types of output while allowing other warnings and messages to pass through.
#'
#' @param expr An R expression to evaluate. This is the code block in which
#'   graphics device warnings or startup messages from futures might occur.
#' @return The result of evaluating `expr`, with specific future device warnings
#'   and package startup messages suppressed.
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' \dontrun{
#'   library(future)
#'   library(future.apply)
#'   library(ggplot2)
#'   library(parallelly)
#'
#'   # Use multicore if supported, otherwise fall back to multisession
#'   plan_type <- ifelse(
#'       parallelly::supportsMulticore(), "multicore", "multisession")
#'   future::plan(plan_type, workers = 2, gc = TRUE)
#'
#'   fun1 <- function(x) {
#'     # Loading ecokit triggers startup messages
#'     library(ecokit)
#'
#'     p <- data.frame(x = rnorm(100), y = rnorm(100)) %>%
#'       ggplot2::ggplot(ggplot2::aes(x, y)) +
#'       ggplot2::geom_point()
#'
#'     # this triggers device warnings
#  '   grob <- ggplot2::ggplotGrob(p)
#'     return(grob)
#'   }
#'
#'   # This will trigger device warnings and startup messages
#'   plots <- future.apply::future_lapply(1:5, fun1, future.seed = TRUE)
#'
#'   # Run with suppression of device warnings and startup messages
#'   plots <- future.apply::future_lapply(1:5, fun1, future.seed = TRUE) %>%
#'     quiet_device()
#'   plot(plots[[1]])
#'
#'   future::plan("sequential")
#'}

quiet_device <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) {
      msg <- conditionMessage(w)
      # Suppress warning if it matches known class or message pattern
      if (inherits(w, "DeviceMisuseFutureWarning") ||
          grepl("added, removed, or modified devices", msg, fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    },
    # Suppress package startup messages
    message = function(m) {
      if (inherits(m, "packageStartupMessage")) {
        invokeRestart("muffleMessage")
      }
    }
  )
}
