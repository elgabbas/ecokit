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
#' load_packages(nngeo)
#'
#' # Reloads nngeo; terra0 does not exist
#' reload_package(nngeo, terra0)
#' @export

reload_package <- function(...) {

  ecokit::check_packages(c("crayon", "purrr", "rlang"))

  # Capture and validate package names from unquoted arguments.
  packages <- purrr::map_chr(rlang::ensyms(...), rlang::as_string)

  if (length(packages) == 0L) {
    ecokit::stop_ctx(
      "At least one package name must be provided", packages = packages)
  }

  if (!all(nzchar(packages))) {
    ecokit::stop_ctx("Package names must be non-empty", packages = packages)
  }

  purrr::walk(
    .x = packages,
    .f = function(pkg) {

      # Skip packages that are not installed — warn rather than error so that
      # the remaining packages in the list are still processed.
      if (!requireNamespace(pkg, quietly = TRUE)) {
        message("Not installed: ", crayon::bold(pkg))
        return(invisible(NULL))
      }

      is_loaded <- pkg %in% ecokit::loaded_packages()

      message(
        if (is_loaded) "Reloading '" else "Loading '",
        crayon::bold(pkg), "'")

      # If already loaded, detach first (with unload = TRUE to also unload
      # the namespace). force = TRUE silently handles cases where other
      # packages depend on this one. Errors are caught and reported as
      # warnings so the subsequent library() call can still proceed.

      if (is_loaded) {
        tryCatch(
          suppressWarnings(
            detach(                                                  # nolint
              name = paste0("package:", pkg), character.only = TRUE,
              unload = TRUE, force = TRUE)),
          error = function(e) {
            message("Warning: Could not detach '", pkg, "': ", e$message)
          })
      }

      # Re-attach (or freshly attach) the package.
      suppressPackageStartupMessages(library(pkg, character.only = TRUE)) # nolint

      invisible(NULL)
    })

  invisible(NULL)
}
