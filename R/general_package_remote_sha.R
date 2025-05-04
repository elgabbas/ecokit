## |------------------------------------------------------------------------| #
# package_remote_sha ----
## |------------------------------------------------------------------------| #

#' Get the remote SHA of R packages
#'
#' This function retrieves the remote SHA (Secure Hash Algorithm) reference for
#' one or more specified R packages from their remote repositories. The SHA
#' uniquely identifies the version of a package's source code, useful for
#' reproducibility and version tracking.
#'
#' @name package_remote_sha
#' @param ... Character. Names of one or more R packages (quoted or unquoted)
#'   for which to retrieve the remote SHA.
#' @return A named character vector where names are the package names and values
#'   are the corresponding remote SHAs. If a package is not found or has no
#'   remote SHA, the value will be `NA`.
#' @export
#' @author Ahmed El-Gabbas
#' @details The function uses [pak::lib_status()] to query the status of
#'   installed packages and extract their remote SHAs. It supports packages
#'   installed from GitHub, GitLab, or other remote sources via `pak`. If a
#'   package is installed from CRAN or locally without a remote SHA, the result
#'   will be `NA`.
#' @examples
#' package_remote_sha(ecokit, "nonexistent")

package_remote_sha <- function(...) {

  package <- NULL

  # Capture package names as symbols and convert to character strings
  package_names <- rlang::ensyms(...)

  # ensure at least one package is provided
  if (length(package_names) == 0) {
    ecokit::stop_ctx(
      "At least one package name must be provided",
      package_names = package_names, length_Pk = length(package_names))
  }

  package_names <- purrr::map_chr(package_names, .f = rlang::as_string)

  # Retrieve library status once for efficiency and map over packages
  lib_status <- ecokit::add_missing_columns(
    pak::lib_status(), NA_character_, "remotesha") %>%
    dplyr::filter(package %in% package_names)

  output <- purrr::map_chr(
    .x = package_names,
    .f = ~{

      # Filter library status for the current package
      sha <- dplyr::filter(lib_status, package == .x) %>%
        dplyr::pull("remotesha")

      # Return the SHA if found, otherwise NA
      if (length(sha) > 0) {
        sha
      } else {
        NA_character_
      }

    }) %>%
    # Name the output vector with package names
    stats::setNames(package_names)

  # Return the named vector of SHAs
  return(output)
}
