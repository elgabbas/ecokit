#' Check the integrity of a PDF file
#'
#' Verify that a file exists, is non-empty, is identified as a PDF document, and
#' can be successfully validated by `pdftools` when available. Optionally, the
#' first page can also be rendered to perform a stronger integrity check.
#'
#' The function is intended to detect missing, empty, truncated, or corrupted
#' PDF files. When "`use_pdftools = TRUE`", validation is performed by
#' attempting to read document metadata using [pdftools::pdf_info()].
#'
#' @param file Character scalar. Path to a PDF file.
#' @param use_pdftools Logical scalar. If `FALSE` (default), perform a basic
#'   check using file info and the PDF header signature ("`%PDF-`"). If `TRUE`,
#'   use `pdftools` for validation; if `pdftools` is not installed, the function
#'   falls back to the basic header check and issues a warning if "`warning =
#'   TRUE`".
#' @param warning Logical scalar. If `TRUE`, issue a warning when "`use_pdftools
#'   = TRUE`" but `pdftools` is not installed. Has no effect when "`use_pdftools
#'   = FALSE`" or when `pdftools` is installed.
#' @param render Logical scalar. If `TRUE`, additionally attempt to render the
#'   first page using [pdftools::pdf_render_page()]. Rendering provides a
#'   stronger integrity check but is slower than metadata validation alone. Only
#'   has an effect when "`use_pdftools = TRUE`".
#'
#' @return A logical scalar:
#' - `TRUE`: The file exists, is non-empty, and either (a) its first five bytes
#'   match the `%PDF-` header signature (`use_pdftools = FALSE`), or (b) it can
#'   be successfully parsed by `pdftools` ("`use_pdftools = TRUE`").
#' - `FALSE`: The file is missing, empty, not recognised as a PDF, fails the
#'   header check, cannot be parsed, or an error occurs during validation.
#'
#' @details Validation is performed in the following order:
#' - Verify that the file exists and is non-empty.
#' - Verify that the file type contains the string `pdf` according to
#'   [ecokit::file_type()].
#' - If "`use_pdftools = FALSE`" or `pdftools` is not installed: check that the
#'   first five bytes of the file match the `%PDF-` header signature.
#' - If "`use_pdftools = TRUE`" and `pdftools` is installed: attempt to read PDF
#'   metadata using [pdftools::pdf_info()].
#' - If `render = TRUE` (and "`use_pdftools = TRUE`"): additionally attempt to
#'   render the first page using [pdftools::pdf_render_page()]. Any R-level
#'   messages emitted during rendering are suppressed. Note that `Poppler` may
#'   also emit font diagnostic messages directly to C-level stderr; these bypass
#'   R's message system, are harmless, and cannot be suppressed from R.
#'
#'   Successful validation indicates that the PDF structure is readable by the
#'   Poppler library used by `pdftools`. It does not guarantee that every page
#'   is visually correct, but it provides a strong indication that the file is
#'   not corrupted.
#'
#' @examples
#' ecokit::load_packages(fs)
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

check_pdf <- function(
    file, use_pdftools = FALSE, warning = TRUE, render = FALSE) {

  pdf_header_valid <- function(file) {
    con <- file(file, open = "rb")
    on.exit(close(con), add = TRUE)
    hdr <- rawToChar(readBin(con, what = "raw", n = 5L))
    identical(hdr, "%PDF-")
  }

  ecokit::check_packages(packages = c("fs", "stringr"))

  ecokit::check_args(args_to_check = "file", args_type = "character")
  ecokit::check_args(
    args_to_check = c("render", "use_pdftools", "warning"),
    args_type = "logical")

  if (
    length(file) != 1L || !nzchar(file) ||
    !fs::file_exists(file) || as.numeric(fs::file_size(file)) == 0L) {
    return(FALSE)
  }

  file_type <- stringr::str_to_lower(ecokit::file_type(file))

  if (!stringr::str_detect(string = file_type, pattern = "pdf")) {
    return(FALSE)
  }

  is_pdftools_installed <- ecokit::package_installed("pdftools")

  if (use_pdftools && isFALSE(is_pdftools_installed) && warning) {
    warning(
      "pdftools is not installed; falling back to basic header check",
      immediate. = TRUE, call. = FALSE)
  }

  tryCatch(
    {
      if (isFALSE(use_pdftools) || isFALSE(is_pdftools_installed)) {
        return(pdf_header_valid(file))
      }

      info <- pdftools::pdf_info(file)
      status <- is.list(info) && !is.null(info$pages) && info$pages > 0L

      if (status && render) {

        ecokit::check_packages(packages = "withr")

        rendered <- tryCatch(
          {
            con <- file(nullfile(), open = "wt")
            withr::defer(close(con))
            # Suppresses R-level messages emitted during rendering. Note:
            # C-level stderr from `Poppler` (e.g. font diagnostics) bypasses R's
            # message system and cannot be suppressed from R.
            withr::with_message_sink(
              new = con,
              code = pdftools::pdf_render_page(pdf = file, page = 1L))
          },
          error = function(e) NULL)

        status <- is.array(rendered) && (length(rendered) > 0L)
      }
      status
    },
    error = function(e) FALSE)
}
