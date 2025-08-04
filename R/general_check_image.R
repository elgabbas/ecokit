#' Verify Image File Integrity
#'
#' This function checks the integrity of image files (JPEG, PNG, TIFF, and PDF)
#' by validating their existence, size, extension, and type using the `file`
#' bash command. It confirms that the file has a recognized image or PDF format
#' and non-zero dimensions (or page count for PDFs).
#'
#' @param file A character string specifying the path to the image file.
#' @param warning A logical value indicating whether to issue warnings for
#'   invalid files (e.g., empty files, unrecognized extensions). Defaults to
#'   `TRUE`.
#' @return A logical value: `TRUE` if the file is a valid image or PDF, `FALSE`
#'   otherwise.
#' @details The function performs the following checks:
#'   - Validates that `file` is a single character string.
#'   - Ensures the file exists and is not a directory.
#'   - Checks that the file size is non-zero, issuing a warning if empty (when
#'   `warning = TRUE`).
#'   - Verifies the file extension is one of `jpg`, `jpeg`, `png`, `tif`,
#'   `tiff`, or `pdf`, issuing a warning if not (when `warning = TRUE`).
#'   - Uses the `file` bash command to confirm the file type and extract
#'   metadata (e.g., dimensions for images, page count for PDFs). The file is
#'   considered valid if it matches the expected type and has positive
#'   dimensions (or page count). The `file` command must be available on the
#'   system.
#' @export
#' @name check_image
#' @author Ahmed El-Gabbas
#' @examples
#' # Load required packages
#' ecokit::load_packages(fs)
#'
#' # Create a temporary directory for test files
#' temp_dir <- fs::dir_create(fs::path_temp("image_test"))
#'
#' # --------------------------------------------
#'
#' # Valid image files
#'
#' # jpeg
#' jpeg_path <- fs::path(temp_dir, "valid_image.jpg")
#' grDevices::jpeg(
#'   filename = jpeg_path, width = 6, height = 6, units = "cm", res = 200)
#' plot(1:10, 1:10, main = "Valid Image")
#' invisible(grDevices::dev.off())
#' check_image(jpeg_path)
#'
#' # png
#' png_path <- fs::path(temp_dir, "valid_image.png")
#' png(
#'   filename = png_path, width = 6, height = 6, units = "cm", res = 200)
#' plot(1:10, 1:10, main = "Valid Image")
#' invisible(grDevices::dev.off())
#' check_image(png_path)
#'
#'
#' # tiff
#' tiff_path <- fs::path(temp_dir, "valid_image.tiff")
#' tiff(
#'   filename = tiff_path, width = 6, height = 6, units = "cm", res = 200)
#' plot(1:10, 1:10, main = "Valid Image")
#' invisible(grDevices::dev.off())
#' check_image(tiff_path)
#'
#' # pdf
#' pdf_path <- fs::path(temp_dir, "valid_document.pdf")
#' grDevices::pdf(file = pdf_path, width = 6, height = 6)
#' plot(1:10, 1:10, main = "Valid Document")
#' invisible(grDevices::dev.off())
#' check_image(pdf_path)
#'
#' # --------------------------------------------
#'
#' # Corrupted image file
#'
#' corrupt_path <- fs::path(temp_dir, "corrupt_image.jpg")
#' fs::file_create(corrupt_path)
#' writeBin(charToRaw("This is not an image"), corrupt_path)
#' check_image(corrupt_path)
#'
#' corrupt_pdf_path <- fs::path(temp_dir, "valid_document.pdf")
#' grDevices::pdf(file = corrupt_pdf_path, width = 6, height = 6)
#' invisible(grDevices::dev.off())
#' check_image(corrupt_pdf_path)
#'
#' # --------------------------------------------
#'
#' # Non-image file
#'
#' text_path <- fs::path(temp_dir, "not_an_image.txt")
#' fs::file_create(text_path)
#' writeLines("This is a text file", text_path)
#'
#' check_image(text_path)
#' check_image(text_path, warning = FALSE)
#'
#' # --------------------------------------------
#'
#' # Nonexistent file
#'
#' nonexistent_path <- fs::path(temp_dir, "nonexistent_image.jpg")
#' check_image(nonexistent_path)
#'
#' check_image(temp_dir)
#'
#' # --------------------------------------------
#'
#' # Clean up
#' fs::dir_delete(temp_dir)

check_image <- function(file, warning = TRUE) {

  # validate file system command
  if (isFALSE(ecokit::check_system_command("file"))) {
    ecokit::stop_ctx("The 'file' command is not available on your system.")
  }

  # # ---------------------------------------------------- #

  # Validate input file

  # Validate that file is a single character string
  if (!is.character(file) || length(file) != 1L) {
    ecokit::stop_ctx("file must be a single character string")
  }

  file <- ecokit::normalize_path(file)

  # Check if the file is not a directory
  if (fs::is_dir(file)) {
    if (warning) {
      warning("Input `file` '", file, "' is a directory.", call. = FALSE)
    }
    return(FALSE)
  }

  # Check if the file exists
  if (!fs::file_exists(file)) {
    if (warning) {
      warning("The file '", file, "' does not exist.", call. = FALSE)
    }
    return(FALSE)
  }

  # Check if file size is zero
  if (file.info(file)$size == 0L) {
    if (warning) {
      warning("The file '", file, "' is empty.", call. = FALSE)
    }
    return(FALSE)
  }

  # Check file extension
  ext <- tolower(ecokit::file_extension(file))
  accepted_extensions <- c("jpeg", "jpg", "png", "tiff", "tif", "pdf")

  if (!ext %in% accepted_extensions) {
    if (warning) {
      warning(
        "The file extension '", ext, "' is not a supported image format ",
        "(JPEG, PNG, TIFF, PDF).\nFile: ", file, call. = FALSE)
    }
    return(FALSE)
  }

  # # ---------------------------------------------------- #

  # Get file type using the file command
  file_type_int <- ecokit::file_type(file)

  # Initialize file status
  file_status <- FALSE

  # Validate file type and metadata based on extension
  if (ext %in% c("jpg", "jpeg")) {
    file_status <- stringr::str_detect(file_type_int, "JPEG image data")
    if (file_status) {
      dims <- file_type_int %>%
        stringr::str_extract(
          pattern = "precision \\d+, \\d+x\\d+") %>% #nolint: nonportable_path_lintr
        stringr::str_remove(
          pattern = "precision \\d+, ") %>% #nolint: nonportable_path_lintr
        stringr::str_split("x", simplify = TRUE) %>%
        as.numeric()
      file_status <- all(dims > 0L, na.rm = TRUE)
    }
  } else if (ext == "png") {
    file_status <- stringr::str_detect(file_type_int, "PNG image data")
    if (file_status) {
      dims <- file_type_int %>%
        stringr::str_extract(", \\d+ x \\d+") %>% #nolint: nonportable_path_lintr
        stringr::str_remove(", ") %>%
        stringr::str_split(" x ", simplify = TRUE) %>%
        as.numeric()
      file_status <- all(dims > 0L, na.rm = TRUE)
    }
  } else if (ext %in% c("tif", "tiff")) {
    file_status <- stringr::str_detect(file_type_int, "TIFF image data")
    if (file_status) {
      dims <- file_type_int %>%
        stringr::str_extract_all("width=\\d+|height=\\d+") %>%
        unlist() %>%
        stringr::str_remove_all("width=|height=") %>%
        as.numeric()
      file_status <- all(dims > 0L, na.rm = TRUE)
    }
  } else if (ext == "pdf") {
    file_status <- stringr::str_detect(file_type_int, "PDF document")
    if (file_status) {
      pages <- file_type_int %>%
        stringr::str_extract(", \\d+ page") %>% #nolint: nonportable_path_lintr
        stringr::str_remove_all(", | page") %>%
        as.numeric()
      file_status <- !is.na(pages) && pages > 0L
    }
  }
  # Return file status
  file_status

}
