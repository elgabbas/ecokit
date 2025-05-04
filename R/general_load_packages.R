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
#' @param install_missing Logical. If `TRUE` (default), missing packages are
#'   automatically installed and then loaded.
#' @return This function is used for its side effects (loading/installing
#'   packages) and does not return any value.
#' @author Ahmed El-Gabbas
#' @export
#' @name load_packages
#' @examples
#' # Currently loaded packages
#' (P1 <- ecokit::loaded_packages())
#'
#' load_packages(tidyr)
#' # Loaded packages after implementing the function
#' (P2 <- ecokit::loaded_packages())
#'
#' # Which packages were loaded?
#' setdiff(P2, P1)
#'
#' load_packages(terra, verbose = TRUE)

load_packages <- function(
    ..., package_list = NULL, verbose = FALSE, install_missing = TRUE) {

  # Packages to load
  packages <- rlang::ensyms(...) %>%
    as.character() %>%
    c(package_list) %>%
    unique() %>%
    sort()

  # List of installed packages
  installed_packages <- rownames(utils::installed.packages())

  # packages to install
  packages_to_install <- setdiff(packages, installed_packages)

  if (install_missing && length(packages_to_install) > 0) {
    message(
      "The following packages will be installed:\n",
      paste("  >>>>>  ", packages_to_install, collapse = "\n"))

    # Installing missing packages
    purrr::walk(
      .x = packages_to_install, .f = utils::install.packages,
      repos = "http://cran.us.r-project.org",
      dependencies = TRUE, quiet = TRUE) %>%
      utils::capture.output(file = nullfile()) %>%
      suppressMessages() %>%
      suppressWarnings()

  } else if (length(packages_to_install) > 0) {
    message(
      "The following packages are neither available nor installed ",
      "as install_missing = FALSE:\n",
      paste("  >>>>>  ", packages_to_install, collapse = "\n"))
  }

  # Packages to load
  packages_to_load <- setdiff(packages, ecokit::loaded_packages())

  purrr::walk(
    .x = packages_to_load, .f = library, character.only = TRUE,
    quietly = TRUE, warn.conflicts = FALSE) %>%
    invisible() %>%
    suppressWarnings() %>%
    suppressMessages()

  if (verbose && length(packages_to_load) > 0) {

    loaded_packages <- purrr::map_chr(
      .x = packages_to_load,
      .f = function(pkg) {
        version <- utils::packageDescription(pkg)$Version
        paste0("  >>>>>  ", pkg, ": ", as.character(version))
      })
    message(
      "\nThe following packages were loaded:\n",
      paste(loaded_packages, collapse = "\n"))
  }
  return(invisible(NULL))
}
