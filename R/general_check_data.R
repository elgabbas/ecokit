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
#'   a positive integer. See [qs2::qs_read] for more details. If it exceeds
#'   [parallelly::availableCores()], it is silently clamped to the number of
#'   available cores (with a warning); see [validate_n_cores()].
#' @param all_okay Logical. If `TRUE` (default), returns a single logical output
#'   indicating the integrity of all files; if `FALSE`, returns logical vectors
#'   for each file.
#' @param timeout Integer. Maximum time in seconds allowed for the file-loading
#'   attempt (per file) before it is treated as a failure. Default `120L`.
#' @return Logical: `TRUE` if all checks pass; `FALSE` otherwise.
#' @author Ahmed El-Gabbas
#' @details The [check_data()] function determines the file type based on its
#'   extension (case-insensitive). If the extension is unrecognised, it returns
#'   `FALSE`. Supported file types:
#' - **RData**: Checked with [check_rdata()], read using [load_as]
#' - **qs2**: Checked with [check_qs()], read using [qs2::qs_read]
#' - **rds**: Checked with [check_rds()], read using [readRDS]
#' - **feather**: Checked with [check_feather()], read using
#'   [arrow::read_feather]
#'
#'   For `feather` files specifically, a lightweight, pure-R check of the Arrow
#'   IPC file-format magic bytes (`"ARROW1"` at the start and end of the file)
#'   is performed first. This is fast, allocates no native memory, and filters
#'   out most corrupted files before `arrow::read_feather` is ever called.
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
#'
#' check_data("nonexistent.rds")
#'
#' # |||||||||||||||||||||||||||||||||||||||
#' # check_data
#' # |||||||||||||||||||||||||||||||||||||||
#'
#' all_files <- c(
#'   rdata_file, bad_rdata, qs_file, bad_qs, rds_file, bad_rds,
#'   feather_file, bad_feather)
#'
#' check_data(all_files)
#'
#' check_data(all_files, warning = FALSE)
#'
#' check_data(all_files, all_okay = FALSE)
#'
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
    file = NULL, warning = TRUE, all_okay = TRUE, n_threads = 1L,
    timeout = 120L) {

  # Validate inputs
  ecokit::check_args(
    args_to_check = c("warning", "all_okay"), args_type = "logical")
  ecokit::check_args(
    args_to_check = c("n_threads", "timeout"), args_type = "numeric")

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }
  if (!is.character(file)) {
    ecokit::stop_ctx("`file` must be a character vector", file = file)
  }

  # Clamp n_threads to available cores if necessary
  n_threads <- ecokit::validate_n_cores(n_threads)

  if (isFALSE(ecokit::is_integer(timeout))) {
    ecokit::stop_ctx(
      "`timeout` must be a positive integer", timeout = timeout,
      class_timeout = class(timeout))
  }

  purrr::walk(
    .x = file,
    .f = ~{
      if (!is.character(.x) || length(.x) != 1L || is.na(.x) || !nzchar(.x)) {
        ecokit::stop_ctx("`file` must be a character string", file = .x)
      }
    })

  # files_check <- purrr::map_lgl(
  #   .x = file,
  #   .f = ~{
  #
  #     if (isFALSE(check_file_basic(.x, warning = warning))) {
  #       return(FALSE)
  #     }
  #
  #     # Get file extension
  #     extension <- get_file_extension(.x)
  #
  #     switch(
  #       extension,
  #       qs2 = ecokit::check_qs(
  #         .x, n_threads = n_threads, warning = warning, timeout = timeout),
  #       rdata = ecokit::check_rdata(.x, warning = warning, timeout = timeout),
  #       rds = ecokit::check_rds(.x, warning = warning, timeout = timeout),
  #       feather = ecokit::check_feather(
  #         .x, warning = warning, timeout = timeout),
  #       {
  #         if (warning) {
  #           warning("Unsupported file extension: ", extension, call. = FALSE)
  #         }
  #         FALSE
  #       })
  #   })


  files_check <- purrr::map_lgl(
    .x = file,
    .f = ~{

      if (isFALSE(check_file_basic(.x, warning = warning))) {
        return(FALSE)
      }

      # Get file extension
      extension <- get_file_extension(.x)

      attempt <- 1L

      repeat {

        result <- tryCatch(
          switch(
            extension,
            qs2 = ecokit::check_qs(
              .x,
              n_threads = n_threads,
              warning = warning,
              timeout = timeout),
            rdata = ecokit::check_rdata(
              .x,
              warning = warning,
              timeout = timeout),
            rds = ecokit::check_rds(
              .x,
              warning = warning,
              timeout = timeout),
            feather = ecokit::check_feather(
              .x,
              warning = warning,
              timeout = timeout),
            {
              if (warning) {
                warning(
                  "Unsupported file extension: ",
                  extension,
                  call. = FALSE)
              }
              FALSE
            }),
          error = function(e) FALSE,
          warning = function(w) FALSE)

        if (isTRUE(result)) {
          return(TRUE)
        }

        if (attempt >= 5L) {
          return(FALSE)
        }

        attempt <- attempt + 1L
      }
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

check_rdata <- function(file, warning = TRUE, timeout = 120L) {

  # Validate inputs
  validate_check_inputs(file = file, warning = warning)

  if (isFALSE(ecokit::is_integer(timeout))) {
    ecokit::stop_ctx(
      "`timeout` must be a positive integer", timeout = timeout,
      class_timeout = class(timeout))
  }

  if (isFALSE(check_file_basic(file, warning = warning))) {
    return(FALSE)
  }

  # Get file extension
  extension <- get_file_extension(file)

  if (extension != "rdata") {
    if (warning) {
      warning("The provided file is not an RData file", call. = FALSE)
    }
    return(FALSE)
  }

  loaded_obj <- tryCatch(
    ecokit::load_as(file),
    error = function(e) {
      if (warning) {
        warning(
          "Failed to load RData file: \n", ecokit::normalize_path(file),
          "\n  Reason: ", conditionMessage(e), call. = FALSE, immediate. = TRUE)
      }
      NULL
    })

  if (is.null(loaded_obj)) {
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# check_qs ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 3

check_qs <- function(file, warning = TRUE, n_threads = 1L, timeout = 120L) {

  # Validate inputs
  validate_check_inputs(file = file, warning = warning)

  # Clamp n_threads to available cores if necessary
  n_threads <- ecokit::validate_n_cores(n_threads)

  if (isFALSE(ecokit::is_integer(timeout))) {
    ecokit::stop_ctx(
      "`timeout` must be a positive integer", timeout = timeout,
      class_timeout = class(timeout))
  }

  if (isFALSE(check_file_basic(file, warning = warning))) {
    return(FALSE)
  }

  # Get file extension
  extension <- get_file_extension(file)

  if (extension != "qs2") {
    if (warning) {
      warning("The provided file is not a qs2 file", call. = FALSE)
    }
    return(FALSE)
  }

  ecokit::check_packages("qs2")


  loaded_obj <- tryCatch(
    qs2::qs_read(file),
    error = function(e) {
      if (warning) {
        warning(
          "Failed to load qs2 file: \n", ecokit::normalize_path(file),
          "\n  Reason: ", conditionMessage(e), call. = FALSE, immediate. = TRUE)
      }
      NULL
    })

  if (is.null(loaded_obj)) {
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# check_rds ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 4

check_rds <- function(file, warning = TRUE, timeout = 120L) {

  # Validate inputs
  validate_check_inputs(file = file, warning = warning)

  if (isFALSE(ecokit::is_integer(timeout))) {
    ecokit::stop_ctx(
      "`timeout` must be a positive integer", timeout = timeout,
      class_timeout = class(timeout))
  }

  if (isFALSE(check_file_basic(file, warning = warning))) {
    return(FALSE)
  }

  # Get file extension
  extension <- get_file_extension(file)

  if (extension != "rds") {
    if (warning) {
      warning("The provided file is not an rds file", call. = FALSE)
    }
    return(FALSE)
  }

  loaded_obj <- tryCatch(
    ecokit::load_as(file),
    error = function(e) {
      if (warning) {
        warning(
          "Failed to load rds file: \n", ecokit::normalize_path(file),
          "\n  Reason: ", conditionMessage(e), call. = FALSE, immediate. = TRUE)
      }
      NULL
    })

  if (is.null(loaded_obj)) {
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# check_feather ----
## |------------------------------------------------------------------------| #

#' @export
#' @name check_data
#' @rdname check_data
#' @order 5
#' @author Ahmed El-Gabbas

check_feather <- function(file, warning = TRUE, timeout = 120L) {

  # Validate inputs
  validate_check_inputs(file = file, warning = warning)

  if (isFALSE(ecokit::is_integer(timeout))) {
    ecokit::stop_ctx(
      "`timeout` must be a positive integer", timeout = timeout,
      class_timeout = class(timeout))
  }

  if (isFALSE(check_file_basic(file, warning = warning))) {
    return(FALSE)
  }

  # Get file extension
  extension <- get_file_extension(file)

  if (extension != "feather") {
    if (warning) {
      warning("The provided file is not a feather file", call. = FALSE)
    }
    return(FALSE)
  }

  ecokit::check_packages("arrow")

  # Cheap pre-check on Arrow IPC magic bytes; avoids invoking the native
  # arrow reader on obviously corrupted/truncated files, which can otherwise
  # crash the R session
  magic_ok <- try(check_feather_magic(file), silent = TRUE)

  if (inherits(magic_ok, "try-error") || isFALSE(magic_ok)) {
    if (warning) {
      warning(
        "Failed to load feather file: ", ecokit::normalize_path(file),
        call. = FALSE)
    }
    return(FALSE)
  }

  loaded_obj <- tryCatch(
    # default `mmap = TRUE` can cause crashes on corrupted files; safer to
    # disable memory-mapping
    arrow::read_feather(file = file, mmap = FALSE),
    error = function(e) {
      if (warning) {
        warning(
          "Failed to load feather file: \n", ecokit::normalize_path(file),
          "\n  Reason: ", conditionMessage(e), call. = FALSE, immediate. = TRUE)
      }
      NULL
    })

  if (is.null(loaded_obj)) {
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# get_file_extension ----
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
      length(file) != 1L || is.na(file) || !nzchar(file)) {
    ecokit::stop_ctx(
      "`file` must be a non-empty character string", file = file)
  }

  stringr::str_to_lower(
    tools::file_ext(
      stringr::str_trim(file)
    )
  )
}

## |------------------------------------------------------------------------| #
# validate_check_inputs ----
## |------------------------------------------------------------------------| #

#' Validate the common `file` and `warning` arguments
#'
#' Shared input validation used by [check_rdata], [check_qs], [check_rds],
#' and [check_feather].
#'
#' @param file Character. Path to a data file.
#' @param warning Logical. Single logical value.
#' @return Invisibly `NULL`. Throws an error via [ecokit::stop_ctx] if
#'   validation fails.
#' @keywords internal
#' @noRd

validate_check_inputs <- function(file, warning) {

  if (is.null(file)) {
    ecokit::stop_ctx("`file` cannot be NULL or empty string")
  }

  if (!is.character(file) || length(file) != 1L ||
      is.na(file) || !nzchar(file)) {
    ecokit::stop_ctx("`file` must be a non-empty character string", file = file)
  }

  if (!is.logical(warning) || length(warning) != 1L || is.na(warning)) {
    ecokit::stop_ctx(
      "`warning` must be a single logical value", warning = warning)
  }

  invisible(NULL)
}

## |------------------------------------------------------------------------| #
# check_file_basic ----
## |------------------------------------------------------------------------| #

#' Check that a file exists and is non-empty
#'
#' @param file Character. Path to a file.
#' @param warning Logical. If `TRUE`, issue a warning on failure.
#' @return Logical: `TRUE` if the file exists and has non-zero size; `FALSE`
#'   otherwise.
#' @keywords internal
#' @noRd

check_file_basic <- function(file, warning) {

  ecokit::check_args(args_to_check = "file", args_type = "character")
  ecokit::check_args(args_to_check = "warning", args_type = "logical")

  if (length(file) != 1L || is.na(file) || !nzchar(file)) {
    if (warning) {
      warning(
        "`file` must be a non-empty character string of length 1",
        call. = FALSE, immediate. = TRUE)
    }
    return(FALSE)
  }

  if (!fs::file_exists(file)) {
    if (warning) {
      warning(
        "File does not exist: `", ecokit::normalize_path(file),
        "`", call. = FALSE, immediate. = TRUE)
    }
    return(FALSE)
  }

  if (fs::file_info(file)$size == 0L) {
    if (warning) {
      warning(
        "File is empty: ", ecokit::normalize_path(file),
        call. = FALSE, immediate. = TRUE)
    }
    return(FALSE)
  }

  TRUE
}

## |------------------------------------------------------------------------| #
# check_feather_magic ----
## |------------------------------------------------------------------------| #

#' Check Arrow IPC ("feather" v2) magic bytes
#'
#' Performs a lightweight, pure-R check that a file begins and ends with the
#' `"ARROW1"` magic string used by the Arrow IPC file format (feather v2). This
#' catches most truncated/corrupted feather files without invoking the native
#' `arrow` reader, which can crash the R session on malformed input.
#'
#' @param file Character. Path to a feather file. The caller (`check_feather`)
#'   must have already confirmed that this file exists and is non-empty.
#' @return Logical: `TRUE` if both the leading and trailing 6 bytes match
#'   `"ARROW1"`; `FALSE` otherwise.
#' @keywords internal
#' @noRd

check_feather_magic <- function(file) {

  magic <- charToRaw("ARROW1")
  size <- fs::file_info(file)$size

  # Arrow IPC files contain the 6-byte magic at the start and end, plus a
  # 4-byte footer length and padding; anything shorter cannot be valid
  if (size < 12L) {
    return(FALSE)
  }

  con <- file(file, open = "rb")
  on.exit(close(con), add = TRUE)

  head_bytes <- readBin(con, what = "raw", n = 6L)
  seek(con, where = size - 6L, origin = "start")
  tail_bytes <- readBin(con, what = "raw", n = 6L)

  identical(head_bytes, magic) && identical(tail_bytes, magic)
}
