## |------------------------------------------------------------------------| #
# load_packages ----
## |------------------------------------------------------------------------| #

#' Load or install multiple R packages
#'
#' This function attempts to load multiple R packages specified by the user. If
#' a package is not installed, the function can optionally install it before
#' loading. It also provides an option to print the names and versions of the
#' loaded packages.
#' @param ... Character. Names of the packages to be loaded or installed.
#' @param package_list Character vector. An alternative or additional way to
#'   specify package names as a vector.
#' @param verbose Logical. If `TRUE`, prints the names and versions of the
#'   loaded packages. Defaults to `FALSE`.
#' @param install_missing Logical. If `TRUE`, missing packages are automatically
#'   installed and then loaded. Defaults to `FALSE`.
#' @param n_cpus Integer. Number of CPUs to use for parallel installation of
#'   packages. Defaults to the value of the `Ncpus` option. This is only valid
#'   if `install_missing` is `TRUE`.
#' @return This function is used for its side effects (loading/installing
#'   packages) and does not return any value.
#' @details On HPC systems using network filesystems (e.g. Lustre) with `renv`,
#'   [utils::installed.packages()] can be slow due to high metadata I/O latency
#'   across large library trees. This function mitigates that by calling
#'   [ecokit::installed.packages()] once with `fields = "Version"` only, caching
#'   the result, and reading package versions from the cached matrix rather than
#'   re-reading individual `DESCRIPTION` files via `packageDescription()`.
#'
#' @author Ahmed El-Gabbas
#' @export
#' @name load_packages
#' @examples
#' # Currently loaded packages
#' (P1 <- ecokit::loaded_packages())
#'
#' # Load tidyr
#' load_packages(tidyr, raster, ggplot2, nnet, verbose = TRUE)
#'
#' # Loaded packages after implementing the function
#' (P2 <- ecokit::loaded_packages())
#'
#' # Which packages were loaded?
#' setdiff(P2, P1)
#'
#' # verbose = FALSE (default)
#' load_packages(tidyterra, verbose = FALSE)
#'
#' # load already loaded packages
#' load_packages(tidyr, tidyterra, verbose = TRUE)
#'
#' # non-existent package
#' load_packages("non_existent")

load_packages <- function(
    ..., package_list = NULL, verbose = FALSE, install_missing = FALSE,
    n_cpus = getOption("Ncpus", 1L)) {

  ecokit::check_packages(c("crayon", "purrr", "rlang"))

  # Check inputs
  if (!is.logical(verbose) || length(verbose) != 1L) {
    ecokit::stop_ctx(
      "`verbose` must be a logical of length 1", verbose = verbose)
  }

  if (!is.logical(install_missing) || length(install_missing) != 1L) {
    ecokit::stop_ctx(
      "`install_missing` must be a logical of length 1",
      install_missing = install_missing)
  }

  if (!is.numeric(n_cpus) || length(n_cpus) != 1L || n_cpus < 1L) {
    ecokit::stop_ctx(
      "`n_cpus` must be a positive integer of length 1", n_cpus = n_cpus)
  }

  # Packages to load
  packages <- rlang::ensyms(...) %>%
    as.character() %>%
    c(package_list) %>%
    unique() %>%
    sort()

  base_pkgs <- c(
    "base", "utils", "graphics", "grDevices", "stats",
    "methods", "datasets", "tools", "compiler")
  packages <- setdiff(packages, base_pkgs)

  if (length(packages) == 0L) return(invisible(NULL))

  prefix <- " >> "

  # Call installed.packages() once with only the Version field. On HPC
  # network filesystems (Lustre/GPFS) with renv, this single call dominates
  # wall time because R must stat() every DESCRIPTION file across potentially
  # thousands of packages in multiple library trees. Requesting only the
  # Version field reduces the per-file parse work and keeps the matrix small.
  
  installed_mat <- utils::installed.packages(fields = "Version")
  installed_pkgs <- rownames(installed_mat)

  # Packages to install
  packages_to_install <- setdiff(packages, installed_pkgs)

  if (length(packages_to_install) > 0L) {
    if (install_missing) {
      message(
        "The following packages will be installed:\n",
        paste(prefix, packages_to_install, collapse = "\n"))
      utils::capture.output(
        utils::install.packages(
          pkgs = packages_to_install, repos = "http://cran.us.r-project.org",
          dependencies = TRUE, quiet = TRUE, verbose = FALSE, Ncpus = n_cpus),
        file = nullfile())

      
      # Refresh the cache only after installation changes the library state
      installed_mat <- utils::installed.packages(fields = "Version")
      installed_pkgs <- rownames(installed_mat)
    } else {
      message(
        "The following packages are neither available nor installed ",
        "as install_missing = FALSE:\n",
        paste(prefix, crayon::blue(packages_to_install), collapse = "\n"))
      packages <- setdiff(packages, packages_to_install)
    }
  }

  # Call loaded_packages() once and reuse the result for both set operations
  currently_loaded <- ecokit::loaded_packages()

  already_loaded <- intersect(packages, currently_loaded)
  packages_to_load <- setdiff(packages, currently_loaded)

  # Read version from the cached installed_mat to avoid per-package
  # packageDescription() disk reads (one stat()+open() per call on Lustre)
  .get_version <- function(pkg) {
    v <- installed_mat[pkg, "Version"]
    if (is.na(v)) {
      tryCatch(
        as.character(utils::packageVersion(pkg)),
        error = function(e) "unknown"
      )
    } else {
      as.character(v)
    }
  }

  if (verbose && length(already_loaded) > 0L) {
    message("The following packages were already loaded:")
    purrr::walk(
      .x = already_loaded,
      .f = ~{
        paste0(
          prefix, crayon::bold(crayon::blue(.x)),
          " (", .get_version(.x), ")"
        ) %>%
          message()
      }) %>%
      invisible()
  }

  if (length(packages_to_load) > 0L) {
    if (verbose) {
      message("Loading packages:")
    }
    purrr::walk(
      .x = packages_to_load,
      .f = ~{
        suppressMessages(
          suppressWarnings(
            suppressPackageStartupMessages(
              library( #nolint
                package = .x, character.only = TRUE,
                quietly = TRUE, warn.conflicts = FALSE)
            )))
        if (verbose) {
          paste0(
            prefix, crayon::bold(crayon::blue(.x)),
            " (", .get_version(.x), ")"
          ) %>%
            message()
        }
      }) %>%
      invisible()
  }

  return(invisible(NULL))
}
