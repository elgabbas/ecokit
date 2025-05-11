## |------------------------------------------------------------------------| #
# reload_package ----
## |------------------------------------------------------------------------| #

#' Reload an R package
#'
#' Reloads one or more specified R packages. If a package is not loaded, it is
#' loaded; if already loaded, it is detached and reloaded from its library
#' location.
#' @name reload_package
#' @param ... Unquoted package names (e.g., `sf`, `ncdf4`). Must be installed
#'   packages. Multiple packages can be specified.
#' @return Returns `invisible(NULL)`. The function is used for its side effect
#'   of reloading a package rather than for its return value.
#' @author Ahmed El-Gabbas
#' @examples
#' load_packages(sf)
#'
#' # Reloads sf and ncdf4. terra0 does not exist
#' reload_package(sf, ncdf4, terra0)
#' @export

reload_package <- function(...) {

  # capture the package name
  package <- rlang::ensyms(...) %>%
    purrr::map_chr(rlang::as_string)

  # capture and validate package names
  packages <- tryCatch(
    expr = {
      rlang::ensyms(...) %>%
        purrr::map_chr(rlang::as_string)
    },
    error = function(e) {
      ecokit::stop_ctx(
        "All arguments must be unquoted package names", input = list(...))
    })

  if (length(packages) == 0L) {
    ecokit::stop_ctx(
      "At least one package name must be provided", packages = packages)
  }
  if (!all(nzchar(packages))) {
    ecokit::stop_ctx("Package names must be non-empty", packages = packages)
  }

  purrr::walk(
    .x = package,
    .f = function(pkg) {

      # check if package is installed
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message("Not installed: ", crayon::bold(pkg))
        return(NULL)
      }

      # check if package is loaded
      if (pkg %in% ecokit::loaded_packages()) {
        # Detach and reload
        message("Reloading '", crayon::bold(pkg), "'")
        tryCatch(
          expr = {
            detach(   #nolint
              name = paste0("package:", pkg), character.only = TRUE,
              unload = TRUE, force = TRUE)
          },
          error = function(e) {
            message("Warning: Could not detach '", pkg, "': ", e$message)
          })
        return(NULL)
      }

      message("Loading '", crayon::bold(pkg), "'")

      # find package path
      pkg_path <- tryCatch(
        find.package(pkg),
        error = function(e) {
          message(
            "Cannot locate package '", crayon::bold(pkg),
            "' in library paths")
        })

      # Reload using devtools::reload
      devtools::reload(pkg = pkg_path, quiet = TRUE)
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))  #nolint
    })

  invisible(NULL)
}
