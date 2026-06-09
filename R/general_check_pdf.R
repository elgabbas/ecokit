#' Check the integrity of a PDF file
#'
#' Verify that a file exists, is non-empty, is identified as a PDF document, and
#' can be successfully parsed by `pdftools`. Optionally, the first page can also
#' be rendered to perform a stronger integrity check.
#'
#' The function is intended to detect missing, empty, truncated, or corrupted
#' PDF files. Validation is performed by attempting to read the document
#' metadata using [pdftools::pdf_info()]
#'
#' @param file Character scalar. Path to a PDF file.
#' @param render Logical scalar. If `TRUE`, additionally attempt to render the
#'   first page using [pdftools::pdf_render_page()]. Rendering provides a
#'   stronger integrity check but is slower than metadata validation alone.
#'
#' @return A logical scalar:
#' - `TRUE`: The file exists, is non-empty, appears to be a PDF
#'   document, and can be successfully parsed by `pdftools`.
#' - `FALSE`: The file is missing, empty, not recognized as a PDF,
#'   cannot be parsed, or an error occurs during validation.
#'
#' @details Validation is performed in the following order:
#' - Verify that the file exists and is non-empty.
#' - Verify that the file type contains the string `pdf` according to
#'   [ecokit::file_type()].
#' - Attempt to read PDF metadata using [pdftools::pdf_info()].
#' - Optionally render the first page using [pdftools::pdf_render_page()].
#'   Note that Poppler may emit font diagnostic messages directly to stderr
#'   during rendering; these are harmless and are suppressed automatically.
#'
#'   Successful validation indicates that the PDF structure is readable by the
#'   Poppler library used by `pdftools`. It does not guarantee that every page
#'   is visually correct, but it provides a strong indication that the file is
#'   not corrupted.
#'
#' @examples
#' ecokit::load_packages(fs, pdftools)
#'
#' # Create a temporary invalid pdf file
#' invalid_file <- fs::file_temp(ext = "pdf")
#' fs::file_create(invalid_file)
#' check_pdf(invalid_file)
#'
#' # Create a valid pdf file
#' valid_file <- fs::file_temp(ext = "pdf")
#' invisible({
#'   grDevices::pdf(valid_file)
#'   plot(1:10)
#'   grDevices::dev.off()
#' })
#' check_pdf(valid_file, render = TRUE)
#'
#' # Clean up temporary files
#' fs::file_delete(c(invalid_file, valid_file))
#'
#' @export
#' @author Ahmed El-Gabbas

check_pdf <- function(file, render = FALSE) {

  ecokit::check_packages(packages = c("pdftools", "withr"))

  ecokit::check_args(args_to_check = "file", args_type = "character")
  ecokit::check_args(args_to_check = "render", args_type = "logical")

  if (
    length(file) != 1L || !nzchar(file) || !fs::file_exists(file) ||
    as.numeric(fs::file_size(file)) == 0L) {
    return(FALSE)
  }

  file_type <- ecokit::file_type(file)

  if (!stringr::str_detect(
    string = stringr::str_to_lower(file_type), pattern = "pdf")) {
    return(FALSE)
  }

  tryCatch(
    {
      info <- pdftools::pdf_info(file)
      status <- is.list(info) && !is.null(info$pages) && info$pages > 0L
      if (status && render) {
        rendered <- tryCatch(
          {
            # Poppler emits font diagnostics directly to C-level stderr,
            # bypassing R's warning system; nullfile() suppresses these
            # cross-platform ("/dev/null" on Unix, "nul" on Windows)
            con <- file(nullfile(), open = "wt")
            on.exit(close(con), add = TRUE)
            withr::with_message_sink(
              new = con,
              code = pdftools::pdf_render_page(pdf = file, page = 1L))
          },
          error = function(e) NULL)
        status <- is.array(rendered) && length(rendered) > 0L
      }
      status
    },
    error = function(e) FALSE)
}
