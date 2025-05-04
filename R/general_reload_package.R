## |------------------------------------------------------------------------| #
# reload_package ----
## |------------------------------------------------------------------------| #
#
#' Reload an R package
#'
#' This function reloads a specified R package. If the package is not already
#' loaded, it attempts to load it. If the package is already loaded, it reloads
#' the package from its library location. This can be useful during package
#' development when changes are made to the package code. This function depends
#' on the [devtools::reload] function.
#'
#' @name reload_package
#' @param package Character. Name of the package to reload.
#' @return The function is used for its side effect of reloading a package
#'   rather than for its return value.
#' @author Ahmed El-Gabbas
#' @examples
#' load_packages(sf)
#'
#' reload_package("sf")
#'
#' @export

reload_package <- function(package) {

  if (is.null(package)) {
    ecokit::stop_ctx("`package` cannot be NULL", package = package)
  }

  if (requireNamespace(package, quietly = TRUE)) {
    package_folders <- ecokit::path(.libPaths(), package)
    package_folders <- package_folders[file.exists(package_folders)]
    if (length(package_folders) > 0) {
      purrr::walk(
        .x = package_folders, .f = ~ devtools::reload(pkg = .x, quiet = FALSE))
    }
  } else {
    library(package = package, character.only = TRUE)
  }

  return(invisible(NULL))
}
