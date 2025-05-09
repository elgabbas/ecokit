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
#' \dontrun{
#'   # Error: package not found
#'   package_functions(package = "non_exist")
#' }

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
