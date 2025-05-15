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
#'   options are `future::sequential` (sequential), `future::multisession`
#'   (default), `future::multicore` (not supported on Windows), and
#'   `future::cluster`. If `strategy` is not one of the valid options or if
#'   `future::multicore` on Windows PC, it defaults to `future::multisession`.
#'   See [future::plan()] for more details.
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
#' # `future::multisession`
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
#' # `future::cluster`
#' # ---------------------------------------------
#'
#' # Prepare working in parallel
#' set_parallel(n_cores = 2, strategy = "future::cluster")
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # Stopping parallel processing
#' set_parallel(stop_cluster = TRUE)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `future::multicore`
#' # ---------------------------------------------
#'
#' # Prepare working in parallel
#' set_parallel(n_cores = 2, strategy = "future::multicore")
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # Stopping parallel processing
#' set_parallel(stop_cluster = TRUE)
#' future::plan("list")
#' future::nbrOfWorkers()
#'
#' # ---------------------------------------------
#' # `future::sequential`
#' # ---------------------------------------------
#'
#' set_parallel(n_cores = 1, strategy = "future::sequential")
#' future::nbrOfWorkers()

set_parallel <- function(
    n_cores = 1L, strategy = "future::multisession", stop_cluster = FALSE,
    show_log = TRUE, future_max_size = 500L, ...) {

  # Validate n_cores input
  n_cores <- ifelse((is.null(n_cores) || n_cores < 1L), 1L, as.integer(n_cores))

  # n_cores can not be more than the available cores
  available_cores <- parallelly::availableCores()
  n_cores <- ifelse(
    n_cores > available_cores,
    {
      warning(
        "`n_cores` > number of available cores. ",
        "It was reset to the number of available cores: ", available_cores,
        call. = FALSE)
      available_cores
    },
    n_cores)

  if (strategy == "future::sequential") {
    n_cores <- 1L
  }

  if (stop_cluster) {
    if (show_log) {
      ecokit::cat_time("Stopping parallel processing", ...)
    }

    # stop any running future plan and reset to sequential
    future::plan("future::sequential", gc = TRUE)

  } else {

    # strategy can not be NULL
    strategy <- ifelse(
      is.null(strategy),
      {
        message(
          "`strategy` cannot be NULL. It was reset to `future::multisession`",
          call. = FALSE)
        "future::multisession"
      },
      strategy)

    # strategy should be a character vector of length 1
    if (length(strategy) != 1L) {
      ecokit::stop_ctx(
        "`strategy` must be a character vector of length 1",
        strategy = strategy, length_strategy = length(strategy))
    }

    # strategy can be only one of the following: "future::sequential",
    # "future::multisession", "future::multicore", "future::cluster".
    valid_strategy <- c(
      "future::sequential", "future::multisession", "future::multicore",
      "future::cluster")
    strategy <- ifelse(
      (strategy %in% valid_strategy),
      strategy,
      {
        warning(
          "`strategy` must be one of the following: `",
          paste(valid_strategy, collapse = "`, `"),
          "` It was reset to `future::multisession`", call. = FALSE)
        "future::multisession"
      })

    # "future::multicore" can not be used on Windows.
    if (strategy == "future::multicore" && .Platform$OS.type == "windows") {
      warning(
        "`future::multicore` is not supported on Windows. ",
        "It was reset to `future::multisession`", call. = FALSE)
      strategy <- "future::multisession"
    }


    if (show_log) {
      ecokit::cat_time(
        paste0(
          "Setting up ",
          ifelse(n_cores > 1L, "parallel", "sequential"),
          " processing (", n_cores,
          ifelse(n_cores > 1L, " cores)", " core)"),
          ". Strategy: `", strategy, "`"),
        ...)
    }

    withr::local_options(
      future.globals.maxSize = future_max_size * 1024L^2L,
      future.gc = TRUE, future.seed = TRUE,
      .local_envir = parent.frame())

    if (n_cores > 1L) {
      future::plan(strategy = strategy, workers = n_cores)
    } else {
      future::plan("future::sequential", gc = TRUE)
    }
  }
  return(invisible(NULL))
}
