# # |------------------------------------------------------------------------| #
# pak_from_renv ----
## |------------------------------------------------------------------------| #

#' Extract Installable Package References from renv.lock for Use with pak
#'
#' This function parses a given `renv.lock` file and extracts all package
#' references that can be directly installed using the `pak` package
#' [pak::pkg_install]. It supports a wide range of repositories, including CRAN,
#' Bioconductor, GitHub, GitLab, Bitbucket, and other common remote sources, as
#' well as tarball URLs (which `pak` cannot install directly). The function
#' returns a list of two character vectors: one containing installable
#' references for `pak`, and one containing tarball URLs for manual installation
#' (e.g., with [remotes::install_url]).
#'
#' @details [`renv`](https://rstudio.github.io/renv/index.html) is a popular R
#'   package for project-local dependency management, creating lock files
#'   (`renv.lock`) to ensure reproducible environments.
#'   [`pak`](https://pak.r-lib.org/) is a fast, parallel package installer that
#'   works with CRAN, GitHub, Bioconductor, and other sources, but does not
#'   natively install from `renv.lock`. This function bridges the gap, enabling
#'   fast, parallel installation of all packages specified in a lockfile using
#'   `pak`, and allows you to reuse `pak`'s cache with [renv::restore] for speed
#'   and reliability.
#'
#'   The function is used to extract a complete list of installable references
#'   from any `renv.lock` for rapid, parallel installation via `pak`. After
#'   installing with [pak::pkg_install], you can run [renv::restore] to link
#'   cached packages, ensuring a reproducible environment with minimal download
#'   time.
#'
#' @param lockfile Path to the `renv.lock` file (JSON format).
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{pak}{Character vector of installable references for `pak`}
#'     \item{tarballs}{Character vector of tarball URLs (install with remotes)}
#'   }
#'
#' @examples
#' lock_path <- file.path(
#'     "https://raw.githubusercontent.com/cosname/",
#'     "rmarkdown-guide/master/renv.lock")
#'
#' (pak_packages <- pak_from_renv(lockfile = lock_path))
#'
#' # Install packages using pak
#' # pak::pak_install(pak_packages$pak)
#'
#' @seealso [pak::pkg_install()], [renv::restore()], [remotes::install_url()]
#'
#' @export
#' @author Ahmed El-Gabbas

pak_from_renv <- function(lockfile) {

  # Check for required dependency
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop(
      "The 'jsonlite' package is required. Please install it first.",
      call. = FALSE)
  }

  if (is.null(lockfile) || !nzchar(lockfile)) {
    stop("lockfile must be a non-empty character string.", call. = FALSE)
  }

  # Validate input argument: must be a file, exist, and readable
  if (!is.character(lockfile) || length(lockfile) != 1L) {
    stop("lockfile must be a single character string file path.", call. = FALSE)
  }

  if (grepl("^http.:+//", lockfile, ignore.case = TRUE)) {
    lockfile_url <- lockfile
    lockfile <- tempfile(fileext = ".lock")
    utils::download.file(
      url = lockfile_url, destfile = lockfile, quiet = TRUE)
  }

  if (!file.exists(lockfile)) {
    stop(sprintf("File does not exist: %s", lockfile), call. = FALSE)
  }

  if (file.access(lockfile, 4L) != 0L) {
    stop(sprintf("File not readable: %s", lockfile), call. = FALSE)
  }

  # Read lock file (JSON)
  lock <- jsonlite::read_json(lockfile, simplifyVector = TRUE)
  lock_names <- gsub(
    "([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", names(lock), perl = TRUE)
  lock <- stats::setNames(lock, lock_names)
  if (is.null(lock$Packages)) {
    stop("No 'Packages' entry found in renv.lock.", call. = FALSE)
  }
  packages <- lock$Packages

  # Initialize output lists
  pak_refs <- character()
  tarball_urls <- character()

  # Loop through each package in the lock file
  for (package in names(packages)) {

    rec <- packages[[package]]

    # Skip R itself
    if (tolower(package) == "r") next

    # Detect and handle known remote types
    if (!is.null(rec$RemoteType)) {

      remote_type <- tolower(rec$RemoteType)
      # Handle GitHub remotes
      if (remote_type == "github") {
        username <- rec$RemoteUsername
        repo <- rec$RemoteRepo
        ref <- rec$RemoteRef
        # Use commit sha if available and not a branch/tag
        sha <- rec$RemoteSha
        use_ref <- if (!is.null(sha) && nchar(sha) >= 7L) sha else ref
        if (is.null(username) || is.null(repo) || is.null(use_ref)) {
          warning(
            sprintf("Missing GitHub info for %s; skipping.", package),
            call. = FALSE)
        } else {
          pak_refs <- c(
            pak_refs, sprintf("%s/%s@%s", username, repo, use_ref)) # nolint: nonportable_path_linter
        }
        next
      }

      # Handle GitLab remotes
      if (remote_type == "gitlab") {
        username <- rec$RemoteUsername
        repo <- rec$RemoteRepo
        ref <- rec$RemoteRef
        sha <- rec$RemoteSha
        use_ref <- if (!is.null(sha) && nchar(sha) >= 7L) sha else ref
        if (is.null(username) || is.null(repo) || is.null(use_ref)) {
          warning(
            sprintf("Missing GitLab info for %s; skipping.", package),
            call. = FALSE)
        } else {
          pak_refs <- c(
            pak_refs, sprintf("gitlab::%s/%s@%s", username, repo, use_ref))
        }
        next
      }

      # Handle Bitbucket remotes
      if (remote_type == "bitbucket") {
        username <- rec$RemoteUsername
        repo <- rec$RemoteRepo
        ref <- rec$RemoteRef
        sha <- rec$RemoteSha
        use_ref <- if (!is.null(sha) && nchar(sha) >= 7L) sha else ref
        if (is.null(username) || is.null(repo) || is.null(use_ref)) {
          warning(
            sprintf("Missing Bitbucket info for %s; skipping.", package),
            call. = FALSE)
        } else {
          pak_refs <- c(
            pak_refs, sprintf("bitbucket::%s/%s@%s", username, repo, use_ref))
        }
        next
      }

      # Handle Bioconductor remote
      if (remote_type == "bioc" || remote_type == "bioconductor") {
        version <- rec$Version
        pak_refs <- c(
          pak_refs, sprintf("bioc::%s@%s", package, version))
        next
      }

      # Handle direct tarball or url installs
      if (remote_type == "url" && !is.null(rec$RemoteUrl)) {
        # pak does not support direct tarball install
        tarball_urls <- c(tarball_urls, rec$RemoteUrl)
        next
      }

      # Unknown remote type, warn and skip
      warning(
        sprintf(
          "Unknown remote type '%s' for %s; skipping.", remote_type, package),
        call. = FALSE)
      next
    }

    # Handle Bioconductor packages without explicit RemoteType
    if (!is.null(rec$Repository) &&
        grepl("^BioC", rec$Repository, ignore.case = TRUE)) {
      version <- rec$Version
      pak_refs <- c(pak_refs, sprintf("bioc::%s@%s", package, version))
      next
    }

    # Handle CRAN packages (or default)
    if (!is.null(rec$Version)) {
      pak_refs <- c(pak_refs, sprintf("%s@%s", package, rec$Version))
      next
    }

    # Handle fallback: try tarball if available
    if (!is.null(rec$Source) && rec$Source == "URL" &&
        !is.null(rec$RemoteUrl)) {
      tarball_urls <- c(tarball_urls, rec$RemoteUrl)
      next
    }

    warning(
      sprintf(
        "Could not determine install reference for %s; skipping.", package),
      call. = FALSE)
  }

  # Remove duplicates, sort for consistency
  pak_refs <- sort(unique(pak_refs))
  tarball_urls <- sort(unique(tarball_urls))

  # Return list of installable refs and tarballs
  list(pak = pak_refs, tarballs = tarball_urls)
}
