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
#' @author Ahmed El-Gabbas
#' @export
#' @name load_packages
#' @examples
#' # Currently loaded packages
#' (P1 <- ecokit::loaded_packages())
#'
#' # Load tidyr
#' load_packages(tidyr, raster, ggplot2, verbose = TRUE)
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

  prefix <- "  >>>>  "

  # List of installed packages
  installed_packages <- rownames(utils::installed.packages())

  # packages to install
  packages_to_install <- setdiff(packages, installed_packages)

  if (length(packages_to_install) > 0L) {
    if (install_missing) {
      message(
        "The following packages will be installed:\n",
        paste(prefix, packages_to_install, collapse = "\n"))

      # Installing missing packages
      utils::capture.output(
        utils::install.packages(
          pkgs = packages_to_install, repos = "http://cran.us.r-project.org",
          dependencies = TRUE, quiet = TRUE, verbose = FALSE, Ncpus = n_cpus),
        file = nullfile())

    } else {
      message(
        "The following packages are neither available nor installed ",
        "as install_missing = FALSE:\n",
        paste(prefix, crayon::blue(packages_to_install), collapse = "\n"))
      packages <- setdiff(packages, packages_to_install)
    }
  }

  # already loaded packages; they will not be reloaded
  already_loaded <- intersect(packages, ecokit::loaded_packages())
  # Packages to load
  packages_to_load <- setdiff(packages, ecokit::loaded_packages())

  if (verbose && length(already_loaded) > 0L) {

    message("The following packages were already loaded:")
    purrr::walk(
      .x = already_loaded,
      .f = ~{
        utils::packageDescription(.x)$Version %>%
          as.character() %>%
          paste0(prefix, crayon::bold(crayon::blue(.x)), " (", ., ")") %>%
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
              library(    #nolint
                package = .x, character.only = TRUE,
                quietly = TRUE, warn.conflicts = FALSE)
            )))

        if (verbose) {
          utils::packageDescription(.x)$Version %>%
            as.character() %>%
            paste0(prefix, crayon::bold(crayon::blue(.x)), " (", ., ")") %>%
            message()
        }

      }) %>%
      invisible()
  }

  return(invisible(NULL))
}
