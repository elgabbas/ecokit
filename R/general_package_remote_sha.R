## |------------------------------------------------------------------------| #
# package_remote_sha ----
## |------------------------------------------------------------------------| #

#' Retrieve Remote SHAs for R Packages
#'
#' Retrieves the remote SHA (Secure Hash Algorithm) reference for one or more R
#' packages from their remote repositories (e.g., GitHub, GitLab). The SHA
#' uniquely identifies a package's source code version, aiding reproducibility
#' and version tracking.
#' @name package_remote_sha
#' @param ... Quoted or unquoted names of one or more R packages (e.g., `dplyr`,
#'   `"tidyr"`). Must be valid package names (letters, numbers, dots, or
#'   underscores) and installed in the library.
#' @param lib_path Character. Path to the library where the packages are
#'   installed. Defaults to the first library in `.libPaths()`. This parameter
#'   is optional.
#' @return A named character vector where names are package names and values are
#'   the corresponding remote SHAs. Returns `NA` for packages not installed,
#'   from CRAN, or without a remote SHA.
#' @export
#' @author Ahmed El-Gabbas
#' @details This function uses [pak::lib_status()] to query installed packages
#'   and extract their remote SHAs. CRAN or locally installed packages typically
#'   return `NA`, as they lack remote SHAs.
#' @examples
#' load_packages(remotes, fs)
#'
#' # create a temporary directory for package installation
#' temp_lib <- fs::path_temp("temp_lib")
#' fs::dir_create(temp_lib)
#'
#' # install pkgconfig from GitHub into the temporary directory
#' remotes::install_github(
#'   "r-lib/pkgconfig", lib = temp_lib, upgrade = "never",
#'   quiet = TRUE, dependencies = FALSE)
#'
#' # retrieve remote SHA for pkgconfig
#' package_remote_sha(pkgconfig, lib_path = temp_lib)
#'
#' # `stats` and non-existent packages return NA
#' package_remote_sha(stats, non_existent)
#'
#' # clean up
#' remove.packages("pkgconfig", lib = temp_lib)
#' fs::dir_delete(temp_lib)
#'
#' \dontrun{
#'   # the following will give an error
#'   package_remote_sha(TRUE)
#'   package_remote_sha(NA)
#'   package_remote_sha(NULL)
#' }

package_remote_sha <- function(..., lib_path = .libPaths()[1L]) {

  package <- NULL

  # Capture package names (quoted or unquoted)
  quos <- rlang::enquos(...)

  package_names <- purrr::map_chr(
    .x = quos,
    .f = ~ {

      if (rlang::quo_is_null(.x)) {
        ecokit::stop_ctx("Package names cannot be NULL")
      }

      if (rlang::quo_is_symbol(.x)) {
        return(rlang::as_string(rlang::quo_get_expr(.x)))
      }

      val <- rlang::eval_tidy(.x)
      input <- rlang::quo_get_expr(.x)

      if (is.logical(val)) {
        ecokit::stop_ctx("Package names can not be logical", input = input)
      }
      if (is.na(val)) {
        ecokit::stop_ctx("Package names can not be NA", input = input)
      }
      if (is.null(val)) {
        ecokit::stop_ctx("Package names can not be NULL", input = input)
      }

      if (!is.character(val)) {
        ecokit::stop_ctx(
          "Package names must be character strings", input = input)
      }
      return(val)
    })

  # input validation
  if (length(package_names) == 0L) {
    ecokit::stop_ctx("At least one package name must be provided")
  }
  package_no_chars <- package_names[!nzchar(package_names)]
  if (length(package_no_chars) > 0L) {
    ecokit::stop_ctx(
      "Package names must be non-empty", package_names = package_names)
  }
  if (!all(grepl("^[a-zA-Z0-9._]+$", package_names))) {
    invalid_names <- package_names[!grepl("^[a-zA-Z0-9._]+$", package_names)]
    ecokit::stop_ctx(
      "Package names must contain only letters, numbers, dots, or underscores",
      invalid_names = invalid_names)
  }

  # nolint start

  # Retrieve library status once for efficiency and map over packages
  lib_status <- ecokit::add_missing_columns(
    data = pak::lib_status(lib = lib_path),
    fill_value = NA_character_, "remotesha") %>%
    dplyr::filter(package %in% package_names)
  # nolint end

  output <- purrr::map_chr(
    .x = package_names,
    .f = ~{

      # Filter library status for the current package
      sha <- lib_status %>%
        dplyr::filter(package == .x) %>%
        dplyr::pull("remotesha")

      # Return the SHA if found, otherwise NA
      if (length(sha) > 0L) {
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
