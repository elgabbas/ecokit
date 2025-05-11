## |------------------------------------------------------------------------| #
# dir_size ----
## |------------------------------------------------------------------------| #

#' Calculate the Size of a Directory
#'
#' Computes the total size of a directory, including all its contents,
#' recursively. The size can be returned in bytes or in a human-readable format
#' (e.g., KB, MB, GB).
#'
#' @param directory Character. The path to the directory.
#' @param human_readable Logical. Whether to return the size in a human-readable
#'   format (e.g., "1.2 GB") or in bytes. Defaults to `TRUE`.
#' @param recursive Logical. Whether to include subdirectories in the size
#'   calculation. Defaults to `TRUE`.
#' @return If `human_readable = TRUE`, a character string representing the
#'   directory size in a human-readable format. If `human_readable = FALSE`, a
#'   numeric value representing the directory size in bytes.
#' @details The function uses [fs::dir_info()] to recursively calculate the
#'   total size of all files in the specified directory. It handles edge cases
#'   such as: non-existent directories, invalid or inaccessible paths, empty
#'   directories, and cross-platform path normalization.
#' @export
#' @author Ahmed El-Gabbas
#' @name dir_size
#' @examples
#' # Calculate the size of the current working directory (recursive)
#' dir_size(".", human_readable = TRUE)      # human-readable format
#'
#' dir_size(".", human_readable = FALSE)     # size in bytes
#'
#' dir_size(".", recursive = FALSE)          # non-recursive size calculation
#'
#' \dontrun{
#'   # create temporary directory containing large files and subdirectories
#'   temp_dir <- fs::path_temp("dir_size")
#'   temp_sub_dir <- fs::path(temp_dir, "subdir")
#'   fs::dir_create(c(temp_dir, temp_sub_dir))
#'   # create large files
#'   file_path <- fs::path(temp_dir, "large_file1.txt")
#'
#'   # ------------------------------------------
#'
#'   # create example large file (10 MB)
#'
#'   # Open file connection in append mode
#'   con <- file(file_path, open = "at")
#'   # Generate a chunk of text (~1 MB)
#'   chunk <- paste(rep("X", 1024 * 1024), collapse = "")
#'   # Write chunks until target size (# 10 MB in bytes) is reached
#'   bytes_written <- 0
#'   while (bytes_written <  10 * 1024 * 1024) {
#'     writeLines(chunk, con)
#'     bytes_written <- bytes_written + nchar(chunk, type = "bytes")
#'   }
#'   close(con)
#'
#'   # ------------------------------------------
#'
#'   # Copy the file to create additional large files
#'   target_paths_1 <- fs::path(
#'     temp_dir, c("large_file2.txt", "large_file3.txt", "large_file4.txt"))
#'   target_paths_2 <- fs::path(
#'     temp_sub_dir, c("large_file5.txt", "large_file6.txt", "large_file4.txt"))
#'   fs::file_copy(rep(file_path, 3), target_paths_1, overwrite = TRUE)
#'   fs::file_copy(rep(file_path, 3), target_paths_2, overwrite = TRUE)
#'
#'   # list of files
#'   fs::dir_ls(temp_dir)
#'   fs::dir_ls(temp_sub_dir)
#'
#'   # ------------------------------------------
#'
#'   # Calculate size of the temporary directory
#'   dir_size(temp_dir)
#'   dir_size(temp_dir, human_readable = FALSE)
#'
#'   # Non-recursive size calculation
#'   dir_size(temp_dir, recursive = FALSE)
#'   dir_size(temp_dir, human_readable = FALSE, recursive = FALSE)
#'
#'   # clean up
#'   fs::dir_delete(temp_dir)
#' }

dir_size <- function(directory, human_readable = TRUE, recursive = TRUE) {

  # Input validation
  if (!is.character(directory) || is.null(directory) ||
      !nzchar(trimws(directory))) {
    ecokit::stop_ctx("'directory' must be a non-empty character string.")
  }
  if (!is.logical(human_readable) || is.na(human_readable) ||
      is.null(human_readable)) {
    ecokit::stop_ctx("'human_readable' must be a logical value.")
  }
  if (!is.logical(recursive) || is.na(recursive) || is.null(recursive)) {
    ecokit::stop_ctx("'recursive' must be a logical value.")
  }

  # Normalize path
  directory <- ecokit::normalize_path(directory)

  # Check directory accessibility (read permission)
  if (file.access(directory, mode = 4L) != 0L) {
    ecokit::stop_ctx("Directory is not readable: ", directory = directory)
  }

  # Check if directory exists and is a directory
  if (!fs::dir_exists(directory)) {
    ecokit::stop_ctx("Directory does not exist", directory = directory)
  }
  if (!fs::is_dir(directory)) {
    ecokit::stop_ctx("Path is not a directory", directory = directory)
  }

  # Collect file information
  # Include hidden files / Continue on permission errors
  files <- fs::dir_info(
    path = directory, recurse = recursive, all = TRUE, fail = FALSE)

  # Calculate total size
  if (nrow(files) == 0L) {
    # Handle empty directories
    total_size <- 0L
  } else {
    total_size <- sum(files$size, na.rm = TRUE)
  }

  # Format output
  if (human_readable) {
    format_bytes(total_size)
  } else {
    as.numeric(total_size)
  }

}

#' Format Bytes into Human-Readable String
#' Helper function to convert a size in bytes to a human-readable format.
#'
#' @param bytes A numeric value representing size in bytes.
#' @return A character string with the size in a human-readable format.
#' @keywords internal
#' @noRd

format_bytes <- function(bytes) {

  if (!is.numeric(bytes) || is.na(bytes) || bytes < 0L) {
    return("0 B")
  }

  units <- c("B", "KB", "MB", "GB", "TB", "PB")
  if (bytes == 0L) {
    return("0 B")
  }

  i <- floor(log(bytes, 1024L))
  i <- min(i, length(units) - 1L)
  size <- round(bytes / (1024L ^ i), 2L)
  paste(size, units[i + 1L])
}
