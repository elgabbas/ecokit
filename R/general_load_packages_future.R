## |------------------------------------------------------------------------| #
# load_packages_future ----
## |------------------------------------------------------------------------| #

#' Prepare Packages for Parallel Processing with Future
#'
#' Prepares a list of packages for use in parallel processing with the `future`
#' package, determining whether to load packages in the main process or pass
#' them to parallel workers based on the specified `future` strategy. This
#' function is designed to minimize package-loading messages in SLURM
#' environments, especially for `future::multicore`.
#'
#' @param packages Character vector of package names to load, or `NULL` to
#'   indicate no packages are needed (returns `NULL`).
#' @param strategy Character string specifying the `future` strategy, one of
#'   `"future::sequential"`, `"future::multisession"`, `"future::multicore"`, or
#'   `"future::cluster"`.
#' @return A value depending on `strategy`:
#'   - `future::sequential`: `NULL` (no workers; packages not loaded).
#'   - `future::multicore` (non-Windows): `NULL` (packages loaded in the
#'   main process, inherited by forks).
#'   - `future::multicore` (Windows), `future::multisession`, or
#'   `future::cluster`: `packages` (character vector of package names to load in
#'   workers, e.g., via `future.packages`).
#'   - If `packages` is `NULL`: `NULL` (no packages to load).
#'
#' @details This function helps manage package loading for parallel processing
#'   with the `future` package. It ensures efficient package handling and
#'   minimizes package-loading messages in SLURM environments, particularly for
#'   `future::multicore` on non-Windows systems, where packages are loaded in
#'   the main process to avoid redundant messages in worker forks. For
#'   `future::multisession`, `future::cluster`, or `future::multicore` on
#'   Windows (where `multicore` falls back to `multisession`), it returns the
#'   package names for loading in workers, typically via the `future.packages`
#'   argument in functions like [future.apply::future_lapply()].
#'
#' @author Ahmed El-Gabbas
#' @name load_packages_future
#' @export
#' @examples
#' (pkg_init <- loaded_packages())
#' pkg_to_load <- c("tidyterra", "lubridate", "tidyr", "sf", "scales")
#'
#' # future::sequential
#' load_packages_future(pkg_to_load, "future::sequential")
#' setdiff(loaded_packages(), pkg_init)
#'
#' # future::multisession
#' load_packages_future(pkg_to_load, "future::multisession")
#' setdiff(loaded_packages(), pkg_init)
#'
#' # future::multicore
#' load_packages_future(pkg_to_load, "future::multicore")
#' setdiff(loaded_packages(), pkg_init)

load_packages_future <- function(
    packages = character(), strategy = "future::sequential") {

  if (length(packages) > 0L) {
    if (!is.character(packages) || anyNA(packages) || !all(nzchar(packages))) {
      ecokit::stop_ctx(
        paste0(
          "`packages` must be a non-empty character vector of package names ",
          "without NA or empty strings, or an empty character vector"),
        packages = packages, length_packages = length(packages))
    }
    if (!all(grepl("^[a-zA-Z0-9._]+$", packages))) {
      ecokit::stop_ctx(
        paste0(
          "All `packages` must be valid package names (letters, numbers, ",
          "dots, underscores only)"),
        invalid_packages = packages[!grepl("^[a-zA-Z0-9._]+$", packages)])
    }
  }

  # Remove duplicates
  packages <- unique(packages)
  if (length(packages) == 0L) {
    return(NULL)
  }

  # Validate strategy
  if (!is.character(strategy) || length(strategy) != 1L || is.na(strategy)) {
    ecokit::stop_ctx(
      "`strategy` must be a single non-NA character string",
      strategy = strategy, length_strategy = length(strategy))
  }

  valid_strategies <- c(
    "future::sequential", "future::multisession",
    "future::multicore", "future::cluster")
  if (!strategy %in% valid_strategies) {
    ecokit::stop_ctx(
      paste(
        "`strategy` must be one of:", toString(shQuote(valid_strategies))),
      strategy = strategy)
  }

  # Handle strategies
  if (strategy == "future::sequential") {
    # No workers; no need to load packages separately
    return(NULL)
  }

  # Check OS for multicore
  is_windows <- (ecokit::os() == "Windows")

  if (strategy == "future::multicore" && !is_windows) {
    # Multicore on non-Windows: forks inherit environment, load in main process
    ecokit::load_packages(package_list = packages)
    return(NULL)
  }
  # Multisession, cluster, or multicore on Windows: return packages for workers
  return(packages)
}
