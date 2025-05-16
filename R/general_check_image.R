## |------------------------------------------------------------------------| #
# check_image ----
## |------------------------------------------------------------------------| #

#' Check the integrity of image files
#'
#' This function verifies the integrity of image files (e.g., JPEG, PNG, TIFF,
#' PDF, etc.) by checking if they can be read without errors. It performs input
#' validation, checks file existence, and optionally uses the `file` bash
#' command to verify the file type. For PDFs, it uses
#' `magick::image_read_pdf()`; otherwise, `magick::image_read()`.
#'
#' @param file A character string specifying the path to the image file.
#' @return A logical value: `TRUE` if the image file is valid, `FALSE`
#'   otherwise.
#' @details The function validates that `file` is a single character string,
#'   checks if the file exists and is not a directory, and uses the `file` bash
#'   command (if available) to confirm the file is likely an image or PDF.
#' @export
#' @name check_image
#' @author Ahmed El-Gabbas
#' @examples
#' # Load required packages
#' ecokit::load_packages(fs, magick, pdftools)
#'
#' # Create a temporary directory for test files
#' temp_dir <- fs::dir_create(fs::path_temp("image_test"))
#'
#' # --------------------------------------------
#'
#' # Valid image files
#'
#' # JPEG
#' jpeg_path <- fs::path(temp_dir, "valid_image.jpg")
#' img <- magick::image_blank(100, 100, color = "blue")
#' magick::image_write(img, path = jpeg_path, format = "jpg")
#' check_image(jpeg_path)
#' plot(magick::image_read(jpeg_path))
#'
#' # PNG
#' png_path <- fs::path(temp_dir, "valid_image.png")
#' img <- magick::image_blank(200, 200, color = "green")
#' magick::image_write(img, path = png_path, format = "png")
#' check_image(png_path)
#' plot(magick::image_read(png_path))
#'
#' # TIFF
#' tiff_path <- fs::path(temp_dir, "valid_image.tiff")
#' img <- magick::image_blank(150, 150, color = "red")
#' magick::image_write(img, path = tiff_path, format = "tiff")
#' check_image(tiff_path)
#' plot(magick::image_read(tiff_path))
#'
#' # PDF
#' pdf_path <- fs::path(temp_dir, "valid_document.pdf")
#' temp_png <- fs::path(temp_dir, "temp_png.png")
#' img <- magick::image_blank(300, 300, color = "purple")
#' magick::image_write(img, path = pdf_path, format = "pdf")
#' check_image(pdf_path)
#' plot(magick::image_read_pdf(pdf_path))
#'
#' # --------------------------------------------
#'
#' # Corrupted image file
#'
#' corrupt_path <- fs::path(temp_dir, "corrupt_image.jpg")
#' img <- magick::image_blank(100, 100, color = "yellow")
#' magick::image_write(img, path = corrupt_path, format = "jpg")
#' writeBin(charToRaw("This is not an image"), corrupt_path)
#'
#' check_image(corrupt_path)
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
#'
#' # --------------------------------------------
#'
#' # Nonexistent file
#'
#' nonexistent_path <- fs::path(temp_dir, "nonexistent_image.jpg")
#' check_image(nonexistent_path)
#'
#' # --------------------------------------------
#'
#' # Clean up
#' fs::dir_delete(temp_dir)

check_image <- function(file) {

  # Validate that file is a single character string
  if (!is.character(file) || length(file) != 1L) {
    ecokit::stop_ctx("file must be a single character string")
  }

  # Check if the file exists and is not a directory
  if (!file.exists(file) || file.info(file)$isdir) {
    return(FALSE)
  }

  # Determine if the 'file' bash command is available
  file_available <- !inherits(
    try(
      system("file --version", intern = TRUE, ignore.stderr = TRUE),
      silent = TRUE),
    "try-error")

  # If 'file' command is available, verify the file is likely an image or PDF
  if (file_available) {
    file_type <- system(paste("file", shQuote(file)), intern = TRUE)
    if (!grepl("image|bitmap|graphics|PDF", file_type, ignore.case = TRUE)) {
      return(FALSE)
    }
  }

  tryCatch(
    expr = {
      if (startsWith(ecokit::file_type(file), "PDF document")) {
        img <- magick::image_read_pdf(file, density = 72L)
        rm(img, envir = environment())
      } else {
        img <- magick::image_read(file)
        rm(img, envir = environment())
      }
      TRUE
    },
    error = function(e) {
      FALSE
    })
}
