#' Check Integrity of Data Files
#'
#' Validates a data file by checking its extension and attempting to load its
#' contents. A file is considered valid if it exists, is non-empty, has a
#' supported extension, and loads successfully with a non-null object. Supports
#' `RData`, `qs2`, `rds`, and `feather` file types.
#' @param file Character. Path to a data file (e.g., `.rdata`, `.qs2`, `.rds`,
#'   `.feather`). Must be a single, non-empty string.
#' @param warning Logical. If `TRUE` (default), warnings are issued for invalid
#'   files (e.g., non-existent, wrong extension, or loading failure).
#' @param n_threads Integer. Number of threads for reading `qs2` files. Must be
#'   a positive integer. See [qs2::qs_read] for more details.
#' @return Logical: `TRUE` if the file is valid and loads successfully; `FALSE`
#'   otherwise, with a warning if `warning = TRUE`.
#' @author Ahmed El-Gabbas
#' @details The `check_data()` function determines the file type based on its
#'   extension (case-insensitive). If the extension is unrecognised, it returns
#'   `FALSE`. Supported file types:
#' - **RData**: Checked with `check_rdata()`, read using [load_as]
#' - **qs2**: Checked with `check_qs()`, read using [qs2::qs_read]
#' - **rds**: Checked with `check_rds()`, read using [readRDS]
#' - **feather**: Checked with `check_feather()`, read using
#'   [arrow::read_feather]
#' @examples
#'
#' # Setup temporary directory
#' temp_dir <- fs::path_temp("load_multiple")
#' fs::dir_create(temp_dir)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate RData files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # valid RData file
#' data <- data.frame(x = 1:5)
#' rdata_file <- fs::path(temp_dir, "valid.Rdata")
#' save(data, file = rdata_file)
#'
#' # Invalid RData file (corrupted)
#' bad_rdata <- fs::path(temp_dir, "invalid.Rdata")
#' writeLines("not an RData file", bad_rdata)
#'
#' check_data(rdata_file)                               # TRUE
#' check_rdata(rdata_file)                              # TRUE
#'
#' check_data(bad_rdata)                                # FALSE, with warning
#' check_rdata(bad_rdata)                               # FALSE, with warning
#'
#' check_data(bad_rdata, warning = FALSE)               # FALSE, no warning
#' check_rdata(bad_rdata, warning = FALSE)              # FALSE, no warning
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate qs2 files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid qs2 file
#' qs_file <- fs::path(temp_dir, "valid.qs2")
#' qs2::qs_save(data, qs_file, nthreads = 1)
#'
#' # Invalid qs2 file (corrupted)
#' bad_qs <- fs::path(temp_dir, "invalid.qs2")
#' writeLines("not a qs2 file", bad_qs)
#'
#' check_data(qs_file, n_threads = 1L)                  # TRUE
#' check_qs(qs_file, n_threads = 1L)                    # TRUE
#'
#' check_data(bad_qs, n_threads = 1L)                   # FALSE, with warning
#' check_qs(bad_qs, n_threads = 1L)                     # FALSE, with warning
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate rds files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid rds file
#' rds_file <- fs::path(temp_dir, "valid.rds")
#' saveRDS(data, rds_file)
#'
#' # Invalid rds file (corrupted)
#' bad_rds <- fs::path(temp_dir, "invalid.rds")
#' writeLines("not an rds file", bad_rds)
#'
#' check_data(rds_file)                                 # TRUE
#' check_rds(rds_file)                                  # TRUE
#'
#' check_data(bad_rds)                                  # FALSE, with warning
#' check_rds(bad_rds)                                   # FALSE, with warning
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate feather files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid feather file
#' feather_file <- fs::path(temp_dir, "valid.feather")
#' arrow::write_feather(data, feather_file)
#'
#' # Invalid feather file (corrupted)
#' bad_feather <- fs::path(temp_dir, "invalid.feather")
#' writeLines("not a feather file", bad_feather)
#'
#' check_data(feather_file)                             # TRUE
#' check_feather(feather_file)                          # TRUE
#'
#' check_data(bad_feather)                              # FALSE, with warning
#' check_feather(bad_feather)                           # FALSE, with warning
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Non-existent file
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' check_data("nonexistent.rds")                        # FALSE, with warning
#'
#' # Clean up
#' fs::file_delete(
#'   c(rdata_file, bad_rdata, qs_file, bad_qs, rds_file, bad_rds,
#'   feather_file, bad_feather))
#' fs::dir_delete(temp_dir)

## |------------------------------------------------------------------------| #
# check_data ----
## |------------------------------------------------------------------------| #

#' @name check_data
#' @rdname check_data
#' @order 1
#' @export

check_data <- function(file = NULL, warning = TRUE, n_threads = 1L) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  if (!is.numeric(n_threads) || n_threads < 1L ||
      n_threads != as.integer(n_threads)) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads)
  }

  if (!file.exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file),
        "`", call. = FALSE)
    }
    return(FALSE)
  }

  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("File is empty: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # Get file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  out_file <- switch(
    extension,
    qs2 = ecokit::check_qs(file, n_threads = n_threads, warning = warning),
    rdata = ecokit::check_rdata(file, warning = warning),
    rds = ecokit::check_rds(file, warning = warning),
    feather = ecokit::check_feather(file, warning = warning),
    {
      if (warning) {
        warning("Unsupported file extension: ", extension, call. = FALSE)
      }
      FALSE
    })

  return(out_file)
}

## |------------------------------------------------------------------------| #
# check_rdata ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 2

check_rdata <- function(file, warning = TRUE) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  if (!file.exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file),
        "`", call. = FALSE)
    }
    return(FALSE)
  }

  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("File is empty: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # check file type
  in_file_type <- ecokit::file_type(file)
  if (!startsWith(in_file_type, "gzip compressed data")) {
    if (warning) {
      warning(
        "Not a valid RData file: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # Get file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  if (extension == "rdata") {

    object <- try(ecokit::load_as(file), silent = TRUE)

    if (inherits(object, "try-error")) {
      if (warning) {
        warning(
          "Failed to load RData file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("object") && !is.null(object)) {
      return(TRUE)
    } else {
      if (warning) {
        warning(
          "Failed to load RData file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

  } else {
    if (warning) {
      warning("The provided file is not an RData file", call. = FALSE)
    }
    return(FALSE)
  }
}

## |------------------------------------------------------------------------| #
# check_qs ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 3

check_qs <- function(file, warning = TRUE, n_threads = 1L) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  if (!is.numeric(n_threads) || n_threads < 1L ||
      n_threads != as.integer(n_threads)) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads)
  }


  if (!file.exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file),
        "`", call. = FALSE)
    }
    return(FALSE)
  }
  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("File is empty: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # check file type
  in_file_type <- ecokit::file_type(file)
  if (in_file_type != "data") {
    if (warning) {
      warning(
        "Not a valid qs2 file: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # Get file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  if (extension == "qs2") {

    object <- try(qs2::qs_read(
      file = file, nthreads = n_threads), silent = TRUE)

    if (inherits(object, "try-error")) {
      if (warning) {
        warning(
          "Failed to load qs2 file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("object") && !is.null(object)) {
      return(TRUE)
    } else {
      if (warning) {
        warning(
          "Failed to load qs2 file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }
  } else {
    if (warning) {
      warning("The provided file is not a qs2 file", call. = FALSE)
    }
    return(FALSE)
  }
}

## |------------------------------------------------------------------------| #
# check_rds ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 4

check_rds <- function(file, warning = TRUE) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  if (!file.exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file), "`",
        call. = FALSE)
    }
    return(FALSE)
  }
  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("File is empty: ", file, call. = FALSE)
    }
    return(FALSE)
  }

  # check file type
  in_file_type <- ecokit::file_type(file)
  if (!startsWith(in_file_type, "gzip compressed data")) {
    if (warning) {
      warning(
        "Not a valid rds file: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # Get file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  if (extension == "rds") {

    object <- try(readRDS(file), silent = TRUE)

    if (inherits(object, "try-error")) {
      if (warning) {
        warning(
          "Failed to load rds file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("object") && !is.null(object)) {
      return(TRUE)
    } else {
      if (warning) {
        warning(
          "Failed to load rds file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

  } else {
    if (warning) {
      warning("The provided file is not an rds file", call. = FALSE)
    }
    return(FALSE)
  }
}

## |------------------------------------------------------------------------| #
# check_feather ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 5
#' @author Ahmed El-Gabbas

check_feather <- function(file, warning = TRUE) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a character string", file = file)
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  if (!file.exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file), "`",
        call. = FALSE)
    }
    return(FALSE)
  }
  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("File is empty: ", ecokit::normalize_path(file), call. = FALSE)
    }
    return(FALSE)
  }

  # check file type
  in_file_type <- ecokit::file_type(file)
  if (stringr::str_detect(in_file_type, "^data|^DIY", negate = TRUE)) {
    if (warning) {
      warning(
        "Not a valid feather file: ", ecokit::normalize_path(file),
        call. = FALSE)
    }
    return(FALSE)
  }

  # Get file extension
  extension <- stringr::str_to_lower(tools::file_ext(file))

  if (extension == "feather") {

    object <- try(arrow::read_feather(file), silent = TRUE)

    if (inherits(object, "try-error")) {
      if (warning) {
        warning(
          "Failed to load feather file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("object") && !is.null(object)) {
      return(TRUE)
    } else {
      if (warning) {
        warning(
          "Failed to load feather file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }
  } else {
    if (warning) {
      warning("The provided file is not a feather file", call. = FALSE)
    }
    return(FALSE)
  }
}
