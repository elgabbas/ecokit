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
    show_log = TRUE, future_max_size = 500L, ...) {

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
        cat_timestamp = FALSE)
    }
    n_cores <- available_cores
  }

  if (strategy == "sequential") {
    n_cores <- 1L
  }

  if (stop_cluster) {
    if (show_log && n_cores > 1L) {
      ecokit::cat_time("Stopping parallel processing", ...)
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
            " cores (strategy: `", strategy, "`)"),
          ...)
      }

      withr::local_options(
        future.globals.maxSize = future_max_size * 1024L^2L,
        future.gc = TRUE, future.seed = TRUE,
        .local_envir = parent.frame())

      future::plan(strategy = strategy, workers = n_cores, gc = TRUE)

    } else {

      future::plan(strategy = "sequential", gc = TRUE)

    }
  }
  return(invisible(NULL))
}
