# # |------------------------------------------------------------------------| #
# pak_from_renv ----
## |------------------------------------------------------------------------| #

#' Extract Installable Package References from renv.lock for Use with pak
#'
#' This function parses a given `renv.lock` file and extracts all package
#' references that can be directly installed using the `pak` package
#' [pak::pkg_install]. It supports a wide range of repositories, including CRAN,
#' Bioconductor, GitHub, GitLab, Bitbucket, and other common remote sources, as
#' well as tarball URLs. The function returns a list of multiple character
#' vectors:
#' - `pak`: installable references for `pak` (CRAN/BioC only, no remotes)
#' - `tarballs`: package references for tarball URLs, formatted for pak as
#' `pkg=url::https://...` if the package name is known, or just
#' `url::https://...` if not.
#' - `remote`: GitHub/GitLab/Bitbucket package references, formatted for pak as
#' `github::user/repo`, `gitlab::user/repo`, or `bitbucket::user/repo` (or, if
#' the package name differs from the repo, as `pkg=github::user/repo` etc.).
#'
#' These lists allow you to separately process packages by source, or install
#' GitHub/GitLab/Bitbucket packages without strict versioning/commit, which can
#' sometimes help avoid dependency resolution conflicts in pak (and other
#' tools). Tarball URLs are provided in a pak-compatible format.
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
#'   In addition to the main installable references, the function outputs a
#'   separate list for all remotes (GitHub, GitLab, Bitbucket) in pak-compatible
#'   syntax, and a tarballs list in pak-compatible syntax (`url::` or
#'   `pkg=url::...`).
#'
#' @param lockfile Path to the `renv.lock` file (JSON format).
#'
#' @return A list with the following elements:
#'   \describe{
#'     \item{pak}{Character vector of installable references for `pak`
#'     (CRAN/BioC only)}
#'     \item{tarballs}{Character vector of tarball URLs in pak syntax
#'      (see Details)}
#'     \item{remote}{Character vector of all remote package references in pak
#'      syntax}
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
#' # Install all remote packages (latest HEAD, no SHA)
#' # pak::pak_install(pak_packages$remote)
#'
#' # Install tarballs
#' # pak::pak_install(pak_packages$tarballs)
#'
#' @seealso [pak::pkg_install()], [renv::restore()], [remotes::install_url()]
#'
#' @export
#' @author Ahmed El-Gabbas

pak_from_renv <- function(lockfile) {

  # Check for required dependency
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    ecokit::stop_ctx("The `jsonlite` package is required to read JSON files.")
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

  if (!fs::file_exists(lockfile)) {
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
  remote_refs <- character()

  # Loop through each package in the lock file
  for (package in names(packages)) {

    rec <- packages[[package]]

    # Skip R itself
    if (tolower(package) == "r") next

    # Detect and handle known remote types
    if (!is.null(rec$RemoteType)) {

      remote_type <- tolower(rec$RemoteType)
      # Handle GitHub/GitLab/Bitbucket remotes
      if (remote_type %in% c("github", "gitlab", "bitbucket")) {
        username <- rec$RemoteUsername
        repo <- rec$RemoteRepo
        # For pak, always use source::username/repo,
        # or pkg=source::username/repo if package is not equal to repo
        # (see pak's documentation)
        if (!is.null(username) && !is.null(repo)) {
          remote_string <- switch(
            remote_type,
            # nolint start
            github    = sprintf("%s/%s", username, repo),
            gitlab    = sprintf("gitlab::%s/%s", username, repo),
            bitbucket = sprintf("bitbucket::%s/%s", username, repo),
            # nolint end
            ""
          )
          # If repo != package, add pkg=source::username/repo
          # pak expects e.g. pins=github::rstudio/pins-r
          if (tolower(package) != tolower(repo)) {
            remote_string <- switch(
              remote_type,
              github    = sprintf("%s=github::%s/%s", package, username, repo),
              gitlab    = sprintf("%s=gitlab::%s/%s", package, username, repo),
              bitbucket = sprintf(
                "%s=bitbucket::%s/%s", package, username, repo),
              ""
            )
          }
          remote_refs <- c(remote_refs, remote_string)
        } else {
          warning(
            sprintf("Missing %s info for %s; skipping.", remote_type, package),
            call. = FALSE)
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
        # pak expects url::, or pkg=url:: if package name is known
        url_entry <- rec$RemoteUrl
        if (!is.null(package) && nzchar(package)) {
          tarball_urls <- c(
            tarball_urls, sprintf("%s=url::%s", package, url_entry))
        } else {
          tarball_urls <- c(
            tarball_urls, sprintf("url::%s", url_entry))
        }
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
      url_entry <- rec$RemoteUrl
      if (!is.null(package) && nzchar(package)) {
        tarball_urls <- c(
          tarball_urls, sprintf("%s=url::%s", package, url_entry))
      } else {
        tarball_urls <- c(
          tarball_urls, sprintf("url::%s", url_entry))
      }
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
  remote_refs <- sort(unique(remote_refs))

  # Return list of installable refs, tarballs, and remotes
  list(
    pak = pak_refs,
    tarballs = tarball_urls,
    remote = remote_refs
  )
}
