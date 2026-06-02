## |------------------------------------------------------------------------| #
# set_parallel ----
## |------------------------------------------------------------------------| #

#' Set up or stop parallel processing plan
#'
#' Configures parallel processing with [future::plan()] or stops an existing
#' plan. When stopping, it resets to sequential mode.
#'
#' @param n_cores Integer. Number of cores to use. If `NULL`, defaults to
#'   sequential mode. Default is `1`.
#' @param strategy Character. The parallel processing strategy to use. Valid
#'   options are "sequential", "multisession" (default), "multicore", and
#'   "cluster". See [future::plan()] and [ecokit::set_parallel()] for details.
#' @param stop_cluster  Logical. If `TRUE`, stops any parallel cluster and
#'   resets to sequential mode. If `FALSE` (default), sets up a new plan.
#' @param show_log Logical. If `TRUE` (default), logs messages via
#'   [ecokit::cat_time()].
#' @param future_max_size Numeric. Maximum allowed total size (in megabytes) of
#'   global variables identified. See `future.globals.maxSize` argument of
#'   [future::future.options] for more details. Default is `500L` for 500 MB.
#' @param cat_timestamp	logical; whether to include the time in the timestamp.
#'   Default is `TRUE`. If `FALSE`, only the text is printed. See
#'   [ecokit::cat_time()].
#' @param ... Additional arguments to pass to [cat_time].
#' @export
#' @name set_parallel
#' @author Ahmed El-Gabbas
#' @examples
#' load_packages(future)
#'
#' # number of workers available
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `multisession`
#' # ---------------------------------------------
#'
#' # Prepare working in parallel
#' set_parallel(n_cores = 2)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # Stopping parallel processing
#' set_parallel(stop_cluster = TRUE)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `cluster`
#' # ---------------------------------------------
#'
#' # Prepare working in parallel
#' set_parallel(n_cores = 2, strategy = "cluster")
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # Stopping parallel processing
#' set_parallel(stop_cluster = TRUE)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `multicore`
#' # ---------------------------------------------
#'
#' # Prepare working in parallel
#' set_parallel(n_cores = 2, strategy = "multicore")
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # Stopping parallel processing
#' set_parallel(stop_cluster = TRUE)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `sequential`
#' # ---------------------------------------------
#'
#' set_parallel(n_cores = 1, strategy = "sequential")
#' future::nbrOfWorkers()

set_parallel <- function(
    n_cores = 1L, strategy = "multisession", stop_cluster = FALSE,
    show_log = TRUE, future_max_size = 500L, cat_timestamp = FALSE, ...) {

  # Validate n_cores input
  n_cores <- ifelse((is.null(n_cores) || n_cores < 1L), 1L, as.integer(n_cores))

  # n_cores can not be more than the available cores
  available_cores <- parallelly::availableCores()
  if (n_cores > available_cores) {
    if (show_log) {
      ecokit::cat_time(
        paste0(
          "`n_cores` > number of available cores (", available_cores, "). ",
          "It was reset to ", available_cores, "."),
        cat_timestamp = cat_timestamp)
    }
    n_cores <- available_cores
  }

  if (strategy == "sequential") {
    n_cores <- 1L
  }

  ecokit::check_packages(packages = c("future", "parallelly"))

  if (stop_cluster) {
    if (show_log) {
      ecokit::cat_time(
        "Stopping parallel processing", cat_timestamp = cat_timestamp, ...)
    }

    # stop any running future plan and reset to sequential
    future::plan(strategy = "sequential", gc = TRUE)

  } else {

    # strategy can not be NULL
    if (is.null(strategy)) {
      message(
        "`strategy` cannot be NULL. It was reset to `multisession`",
        call. = FALSE)
      strategy <- "multisession"
    }

    # strategy should be a character vector of length 1
    if (length(strategy) != 1L) {
      ecokit::stop_ctx(
        "`strategy` must be a character vector of length 1",
        strategy = strategy, length_strategy = length(strategy))
    }

    # strategy can be only one of the following: "sequential",
    # "multisession", "multicore", "cluster".
    valid_strategy <- c("sequential", "multisession", "multicore", "cluster")

    if (!(strategy %in% valid_strategy)) {
      warning(
        "`strategy` must be one of the following: `",
        paste(valid_strategy, collapse = "`, `"),
        "` It was reset to `multisession`", call. = FALSE)
      strategy <- "multisession"
    }

    # "multicore" can not be used on Windows.
    if (strategy == "multicore" && !parallelly::supportsMulticore()) {
      warning(
        "`multicore` is not supported; `strategy` was reset to `multisession`",
        call. = FALSE)
      strategy <- "multisession"
    }


    if (n_cores > 1L) {

      if (show_log) {
        ecokit::cat_time(
          paste0(
            "Setting up parallel processing using ", n_cores,
            " cores (`", strategy, "`)"), cat_timestamp = cat_timestamp,
          ...)
      }

      # Set future options directly with `options()` rather than
      # withr::local_options() because withr scopes changes to parent.frame(),
      # which works correctly when called interactively (parent.frame() =
      # .GlobalEnv, which never exits), but silently reverts the options when
      # the file is sourced. `source()` creates a temporary evaluation frame
      # that exits as soon as the file finishes parsing, triggering withr's
      # cleanup before future_lapply() ever runs. Direct options() ensures the
      # settings persist for the full session regardless of how the script is
      # invoked (interactive, source(), nested function, Rscript, etc.). The
      # nolint tags suppress lintr's no_options_lint rule, which flags bare
      # options() calls in favour of withr::local_options() — here that advice
      # is intentionally overridden for the reason above.

      #nolint start: no_options_lint
      options(
        future.globals.maxSize = future_max_size * 1024L^2L,
        future.gc = TRUE, future.seed = TRUE)
      #nolint end

      # `.cleanup = FALSE` prevents `future::plan()` from registering an
      # `on.exit()` hook on `parent.frame()` that would silently reset the plan
      # to sequential when the calling frame exits. By default `.cleanup =
      # TRUE`, `plan()` is designed for use inside package functions so the plan
      # auto-restores after the function returns — correct behaviour there, but
      # fatal here: when the script is sourced, the `source()` evaluation frame
      # exits immediately after the last line is parsed, firing the `on.exit()`
      # and reverting to sequential before any `future_lapply()` call runs.
      # Interactively, `parent.frame()` is `.GlobalEnv` (which never exits), so
      # the bug is invisible. `set_parallel()` is an explicit set-and-forget
      # utility paired with a matching `set_parallel(stop_cluster = TRUE)` call,
      # so managing the plan lifetime via `on.exit()` is neither needed nor
      # wanted.
      future::plan(
        strategy = strategy, workers = n_cores, gc = TRUE, .cleanup = FALSE)

    } else {

      future::plan(strategy = "sequential", gc = TRUE)

    }
  }
  return(invisible(NULL))
}
