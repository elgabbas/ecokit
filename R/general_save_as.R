## |------------------------------------------------------------------------| #
# save_as ----
## |------------------------------------------------------------------------| #

#' Save an object to a file with a new name
#'
#' This function saves an R object to a specified file path with a potentially
#' new object name. It is useful for renaming objects during the save process.
#' The function supports saving objects in `RData`, `qs2`, `feather`, and `rds`
#' formats. The format is determined by the extension of the file path
#' (case-insensitive).
#' @param object The input object to be saved. This can be an actual R object or
#'   a character string representing the name of an object.
#' @param object_name Character. The new name for the saved `RData` object. This
#'   name is used when the object is loaded back into R. Default is `NULL`. This
#'   is required when saving `RData` files.
#' @param out_path Character. File path (ends with either `*.RData`, `*.qs2`,
#'   `feather`, and `rds`) where the object be saved. This includes the
#'   directory and the file name.
#' @param n_threads Numeric. Number of threads to use when compressing data.
#'   See [qs2::qs_save].
#' @param feather_compression Character. The compression algorithm to use when
#'   saving the object in the `feather` format. The default is "zstd". See
#'   [arrow::write_feather].
#' @param ... Additional arguments to be passed to the respective save
#'   functions. [base::save] for `RData` files; [qs2::qs_save] for `qs2` files;
#'   [arrow::write_feather] for `feather` files; and [base::saveRDS] for `rds`
#'   files.
#' @name save_as
#' @author Ahmed El-Gabbas
#' @return The function does not return a value but saves an object to the
#'   specified file path.
#' @export
#' @examples
#' load_packages(fs, tibble)
#'
#' temp_dir <- fs::path_temp("save_as")
#' fs::dir_create(temp_dir)
#' out_file <- fs::path(temp_dir, "iris2.RData")
#' list.files(temp_dir)
#'
#' # save iris data as `iris2.RData` with `iris2` object name
#' save_as(
#'   object = tibble::tibble(iris), object_name = "iris2", out_path = out_file)
#'
#' list.files(temp_dir, pattern = "^.+.RData")
#'
#' # load the object to global environment. The data is loaded as `iris2`
#' (loaded_name <- load(out_file))
#'
#' ecokit::load_as(out_file)
#'
#' # clean up
#' fs::file_delete(out_file)

save_as <- function(
    object = NULL, object_name = NULL, out_path = NULL, n_threads = 1L,
    feather_compression = "zstd", ...) {

  # input validation

  if (is.null(object) || is.null(out_path)) {
    ecokit::stop_ctx(
      "`object` and `out_path` cannot be NULL",
      class_object = class(object), out_path = out_path,
      include_backtrace = TRUE)
  }

  if (!is.null(object_name) &&
      (!is.character(object_name) || length(object_name) != 1L ||
       !nzchar(object_name))) {
    ecokit::stop_ctx(
      "`object_name` must be a character of length 1 or NULL",
      object_name = object_name, include_backtrace = TRUE)
  }

  if (!is.character(out_path) || length(out_path) != 1L || !nzchar(out_path)) {
    ecokit::stop_ctx(
      "`out_path` must be a single non-empty character string",
      out_path = out_path, include_backtrace = TRUE)
  }
  if (!is.numeric(n_threads) || length(n_threads) != 1L ||
      n_threads < 1L || n_threads != round(n_threads)) {
    ecokit::stop_ctx(
      "`n_threads` must be a positive integer", n_threads = n_threads,
      include_backtrace = TRUE)
  }

  if (inherits(object, "character")) {
    object <- get(object)
  }

  extension <- stringr::str_to_lower(tools::file_ext(out_path))

  if (!extension %in% c("qs2", "rdata", "feather", "rds")) {
    ecokit::stop_ctx(
      paste0(
        "extension of `out_path` must be either 'qs2', ",
        "'rdata', 'feather', or 'rds' (case-insensitive)."),
      extension = extension)
  }

  # Create directory if not available
  fs::dir_create(dirname(out_path))

  if (extension == "feather" && !requireNamespace("arrow", quietly = TRUE)) {
    ecokit::stop_ctx(
      "The `arrow` package is required to save feather files.",
      include_backtrace = TRUE)
  }

  switch(
    extension,
    qs2 = {
      qs2::qs_save(object = object, file = out_path, nthreads = n_threads, ...)
    },
    rdata = {
      if (is.null(object_name)) {
        ecokit::stop_ctx(
          "`object_name` cannot be `NULL` for saving RData files",
          object_name = object_name)
      }
      object_name <- eval(object_name)
      assign(object_name, object)
      save(list = object_name, file = out_path, ...)
    },
    feather = {
      supported_compression <- c(
        "default", "lz4", "lz4_frame", "uncompressed", "zstd")
      if (!feather_compression %in% supported_compression) {
        ecokit::stop_ctx(
          "Invalid `feather_compression`",
          feather_compression = feather_compression,
          supported_compression = supported_compression,
          include_backtrace = TRUE)
      }
      arrow::write_feather(
        x = object, sink = out_path, compression = feather_compression, ...)
    },
    rds = {
      saveRDS(object = object, file = out_path, ...)
    },
    ecokit::stop_ctx("Invalid file extension", extension = extension)
  )

  return(invisible(NULL))
}
