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
#' @details When `n_cores > 1`, the function sets `future`-related options
#'   (`future.globals.maxSize`, `future.gc`, `future.seed`) using one of two
#'   approaches depending on the calling context:
#'   - **Top-level (interactive) use**: options are set globally via
#'   [base::options()]. No deferred restoration is registered.
#'   - **Inside a function**: options are set locally via
#'   [withr::local_options()] scoped to the caller's environment
#'   (`parent.frame()`), so they are automatically restored when the calling
#'   function exits.
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

  ecokit::check_packages(
    packages = c("future", "withr", "parallelly"))

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

      # Set future-related options, scoped to the calling context to avoid the
      # withr "Setting global deferred event(s)..." message. That message occurs
      # because withr::local_options() requires an enclosing function scope; at
      # the top level no such scope exists, so it falls back to session-level
      # deferral. withr::with_options() avoids this at the top level by wrapping
      # the plan-setup call in a temporary scope without registering a deferred
      # event. Inside a function, withr::local_options() is used instead so
      # options are restored cleanly when the calling function exits.
      future_opts <- list(
        future.globals.maxSize = future_max_size * 1024L^2L,
        future.gc = TRUE, future.seed = TRUE)

      if (is.null(sys.call(-1L))) {
        withr::with_options(future_opts, {
          future::plan(strategy = strategy, workers = n_cores, gc = TRUE)
        })
      } else {
        withr::local_options(future_opts, .local_envir = parent.frame())
        future::plan(strategy = strategy, workers = n_cores, gc = TRUE)
      }

    } else {

      future::plan(strategy = "sequential", gc = TRUE)

    }
  }
  return(invisible(NULL))
}
