#' Check Integrity of Data Files
#'
#' Validates a data file by checking its extension and attempting to load its
#' contents. A file is considered valid if it exists, is non-empty, has a
#' supported extension, and loads successfully with a non-null object. Supports
#' `RData`, `qs2`, `rds`, and `feather` file types.
#' @param file Character vector. Path to a data file (e.g., `.rdata`, `.qs2`,
#'   `.rds`, `.feather`).
#' @param warning Logical. If `TRUE` (default), warnings are issued for invalid
#'   files (e.g., non-existent, wrong extension, or loading failure).
#' @param n_threads Integer. Number of threads for reading `qs2` files. Must be
#'   a positive integer. See [qs2::qs_read] for more details.
#' @param all_okay Logical. If `TRUE` (default), returns a single logical output
#'   indicating the integrity of all files; if `FALSE`, returns logical vectors
#'   for each file.
#' @return Logical: `TRUE` if all checks pass; `FALSE` otherwise.
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
#' require(ecokit)
#' ecokit::load_packages(fs, arrow)
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
#' check_rdata(rdata_file)
#'
#' # Invalid RData file (corrupted)
#' bad_rdata <- fs::path(temp_dir, "invalid.Rdata")
#' writeLines("not an RData file", bad_rdata)
#' check_rdata(bad_rdata)
#' check_rdata(bad_rdata, warning = FALSE)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate qs2 files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid qs2 file
#' qs_file <- fs::path(temp_dir, "valid.qs2")
#' qs2::qs_save(data, qs_file, nthreads = 1)
#' check_qs(qs_file, n_threads = 1L)
#'
#' # Invalid qs2 file (corrupted)
#' bad_qs <- fs::path(temp_dir, "invalid.qs2")
#' writeLines("not a qs2 file", bad_qs)
#' check_qs(bad_qs, n_threads = 1L)
#' check_qs(bad_qs, n_threads = 1L, warning = FALSE)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate rds files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid rds file
#' rds_file <- fs::path(temp_dir, "valid.rds")
#' saveRDS(data, rds_file)
#' check_rds(rds_file)
#'
#' # Invalid rds file (corrupted)
#' bad_rds <- fs::path(temp_dir, "invalid.rds")
#' writeLines("not an rds file", bad_rds)
#' check_rds(bad_rds)
#' check_rds(bad_rds, warning = FALSE)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Validate feather files
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' # Valid feather file
#' feather_file <- fs::path(temp_dir, "valid.feather")
#' arrow::write_feather(data, feather_file)
#' check_feather(feather_file)
#'
#' # Invalid feather file (corrupted)
#' bad_feather <- fs::path(temp_dir, "invalid.feather")
#' writeLines("not a feather file", bad_feather)
#' check_feather(bad_feather)
#' check_feather(bad_feather, warning = FALSE)
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # Non-existent file
#' # |||||||||||||||||||||||||||||||||||||||
#' check_data("nonexistent.rds")
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # check_data
#' # |||||||||||||||||||||||||||||||||||||||
#' all_files <- c(
#'   rdata_file, bad_rdata, qs_file, bad_qs, rds_file, bad_rds,
#'   feather_file, bad_feather)
#' check_data(all_files)
#' check_data(all_files, all_okay = FALSE)
#' check_data(all_files, all_okay = FALSE, warning = FALSE)
#'
#' # clean up
#' fs::file_delete(all_files)
#' fs::dir_delete(temp_dir)

## |------------------------------------------------------------------------| #
# check_data ----
## |------------------------------------------------------------------------| #

#' @name check_data
#' @rdname check_data
#' @order 1
#' @export

check_data <- function(
    file = NULL, warning = TRUE, all_okay = TRUE, n_threads = 1L) {

  # Validate inputs
  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }
  if (!is.logical(all_okay) || length(all_okay) != 1L) {
    ecokit::stop_ctx(
      "`all_okay` must be a single logical value", all_okay = all_okay)
  }
  if (!is.numeric(n_threads) || n_threads < 1L ||
      n_threads != as.integer(n_threads)) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads)
  }

  purrr::walk(
    .x = file,
    .f = ~{
      if (!is.character(.x) || length(.x) != 1L || !nzchar(.x)) {
        ecokit::stop_ctx("`file` must be a character string", file = .x)
      }
    })

  files_check <- purrr::map_lgl(
    .x = file,
    .f = ~{

      if (!fs::file_exists(.x)) {
        if (warning) {
          warning(
            "File does not exist: `", ecokit::normalize_path(.x),
            "`", call. = FALSE)
        }
        return(FALSE)
      }

      if (file.info(.x)$size == 0L) {
        if (warning) {
          warning("File is empty: ", ecokit::normalize_path(.x), call. = FALSE)
        }
        return(FALSE)
      }

      # Get file extension
      extension <- get_file_extension(.x)

      out_file <- switch(
        extension,
        qs2 = ecokit::check_qs(.x, n_threads = n_threads, warning = warning),
        rdata = ecokit::check_rdata(.x, warning = warning),
        rds = ecokit::check_rds(.x, warning = warning),
        feather = ecokit::check_feather(.x, warning = warning),
        {
          if (warning) {
            warning("Unsupported file extension: ", extension, call. = FALSE)
          }
          FALSE
        })
    })

  if (all_okay) {
    files_check <- all(files_check)
  }

  return(files_check)
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

  if (!fs::file_exists(file)) {
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
  extension <- get_file_extension(file)

  if (extension == "rdata") {

    ecokit::quietly({
      loaded_obj <- try(ecokit::load_as(file), silent = TRUE)
    },
    "has magic number")

    if (inherits(loaded_obj, "try-error")) {
      if (warning) {
        warning(
          "Failed to load RData file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("loaded_obj") && !is.null(loaded_obj)) {
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

  if (!fs::file_exists(file)) {
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
  extension <- get_file_extension(file)

  if (extension == "qs2") {

    loaded_obj <- try(qs2::qs_read(
      file = file, nthreads = n_threads), silent = TRUE)

    if (inherits(loaded_obj, "try-error")) {
      if (warning) {
        warning(
          "Failed to load qs2 file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("loaded_obj") && !is.null(loaded_obj)) {
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

  if (!fs::file_exists(file)) {
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

  # Get file extension
  extension <- get_file_extension(file)

  if (extension == "rds") {

    loaded_obj <- try(readRDS(file), silent = TRUE)

    if (inherits(loaded_obj, "try-error")) {
      if (warning) {
        warning(
          "Failed to load rds file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("loaded_obj") && !is.null(loaded_obj)) {
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

  if (!fs::file_exists(file)) {
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

  # Get file extension
  extension <- get_file_extension(file)

  if (extension == "feather") {

    # check if arrow is installed
    if (!requireNamespace("arrow", quietly = TRUE)) {
      ecokit::stop_ctx("The `arrow` package is required to read feather files.")
    }

    loaded_obj <- try(arrow::read_feather(file), silent = TRUE)

    if (inherits(loaded_obj, "try-error")) {
      if (warning) {
        warning(
          "Failed to load feather file: ", ecokit::normalize_path(file),
          call. = FALSE)
      }
      return(FALSE)
    }

    if (exists("loaded_obj") && !is.null(loaded_obj)) {
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


## |------------------------------------------------------------------------| #
# Get file extension ----
## |------------------------------------------------------------------------| #

#' Get the file extension from a file path or name
#'
#' This function extracts the file extension from a given file path or file
#' name. It performs input validation to ensure the argument is a non-empty
#' character string. The returned extension is trimmed and converted to
#' lowercase.
#'
#' @param file A non-empty character string representing the file path or name.
#'
#' @return A character string containing the file extension in lowercase.
#' @keywords internal
#' @noRd

get_file_extension <- function(file) {

  if (is.null(file) || !is.character(file) ||
      length(file) != 1L || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a non-empty character string", file = file)
  }

  stringr::str_to_lower(
    tools::file_ext(
      stringr::str_trim(file)
    )
  )
}
