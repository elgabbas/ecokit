## |------------------------------------------------------------------------| #
# package_functions ----
## |------------------------------------------------------------------------| #
#
#' List of functions in a package
#'
#' This function returns a character vector listing all the functions available
#' in the specified R package. It first checks if the package is installed and
#' can be loaded; if not, it raises an error.
#' @author Ahmed El-Gabbas
#' @return A character vector containing the names of all functions in the
#'   specified package.
#' @param package Character. Package name.
#' @name package_functions
#' @export
#' @examples
#' str(package_functions(package = "raster"))
#'
#' str(package_functions(package = "sf"))
#'
#' package_functions(package = "ecokit")
#'
#' # Error: package not found
#'  try(package_functions(package = "non_exist"))

package_functions <- function(package) {

  if (is.null(package)) {
    ecokit::stop_ctx("`package` cannot be NULL or empty", package = package)
  }

  if (!requireNamespace(package, quietly = TRUE)) {
    ecokit::stop_ctx("package not found", package = package)
  }

  # load the package
  ecokit::load_packages(package_list = package, verbose = FALSE)

  ls(paste0("package:", package))
}



#' Check Package Availability
#'
#' Verifies that all specified packages are available in the current R
#' environment. If any packages are missing, the function throws an error with a
#' list of the missing packages.
#'
#' @param packages Character vector. Names of packages to check for
#'   availability. Default is `NULL`.
#' @param ... Additional arguments passed to [ecokit::stop_ctx()].
#'
#' @return Invisibly returns `NULL` if all packages are available. Otherwise,
#'   throws an error via [ecokit::stop_ctx()].
#'
#' @details The function uses [requireNamespace()] with `quietly = TRUE` to
#'   check if each package can be loaded. If one or more packages are not
#'   available, an error message is generated listing all missing packages.
#'
#' @examples
#' # Check if packages are available
#' check_packages(c("dplyr", "ggplot2"))
#'
#' # Will throw an error if packages are missing
#' try(check_packages("nonexistent_package"))
#'
#' @author Ahmed El-Gabbas
#' @export

check_packages <- function(packages = NULL, ...) {

  if (is.null(packages) || length(packages) == 0L) {
    ecokit::stop_ctx(
      "`packages` cannot be NULL or empty", packages = packages)
  }
  if (!is.character(packages)) {
    ecokit::stop_ctx(
      "`packages` must be a character vector", packages = packages)
  }

  packages_available <- purrr::map_lgl(
    packages, requireNamespace, quietly = TRUE)

  if (all(packages_available)) {
    return(invisible(NULL))
  }

  # Identify missing packages
  ecokit::stop_ctx(
    paste0(
      "The following required packages are missing: ",
      toString(packages[!packages_available]),
      ". Please install them to proceed."),
    ...)
}
