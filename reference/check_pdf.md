# Check the integrity of a PDF file

Verify that a file exists, is non-empty, is identified as a PDF
document, and can be successfully validated by `pdftools` when
available. Optionally, the first page can also be rendered to perform a
stronger integrity check.

## Usage

``` r
check_pdf(file, use_pdftools = FALSE, warning = TRUE, render = FALSE)
```

## Arguments

- file:

  Character scalar. Path to a PDF file.

- use_pdftools:

  Logical scalar. If `FALSE` (default), perform a basic check using file
  info and the PDF header signature ("`%PDF-`"). If `TRUE`, use
  `pdftools` for validation; if `pdftools` is not installed, the
  function falls back to the basic header check and issues a warning if
  "`warning = TRUE`".

- warning:

  Logical scalar. If `TRUE`, issue a warning when
  "`use_pdftools = TRUE`" but `pdftools` is not installed. Has no effect
  when "`use_pdftools = FALSE`" or when `pdftools` is installed.

- render:

  Logical scalar. If `TRUE`, additionally attempt to render the first
  page using
  [`pdftools::pdf_render_page()`](https://docs.ropensci.org/pdftools//reference/pdf_render_page.html).
  Rendering provides a stronger integrity check but is slower than
  metadata validation alone. Only has an effect when
  "`use_pdftools = TRUE`".

## Value

A logical scalar:

- `TRUE`: The file exists, is non-empty, and either (a) its first five
  bytes match the `%PDF-` header signature (`use_pdftools = FALSE`),
  or (b) it can be successfully parsed by `pdftools`
  ("`use_pdftools = TRUE`").

- `FALSE`: The file is missing, empty, not recognised as a PDF, fails
  the header check, cannot be parsed, or an error occurs during
  validation.

## Details

The function is intended to detect missing, empty, truncated, or
corrupted PDF files. When "`use_pdftools = TRUE`", validation is
performed by attempting to read document metadata using
[`pdftools::pdf_info()`](https://docs.ropensci.org/pdftools//reference/pdftools.html).

Validation is performed in the following order:

- Verify that the file exists and is non-empty.

- Verify that the file type contains the string `pdf` according to
  [`file_type()`](https://elgabbas.github.io/ecokit/reference/file_operations.md).

- If "`use_pdftools = FALSE`" or `pdftools` is not installed: check that
  the first five bytes of the file match the `%PDF-` header signature.

- If "`use_pdftools = TRUE`" and `pdftools` is installed: attempt to
  read PDF metadata using
  [`pdftools::pdf_info()`](https://docs.ropensci.org/pdftools//reference/pdftools.html).

- If `render = TRUE` (and "`use_pdftools = TRUE`"): additionally attempt
  to render the first page using
  [`pdftools::pdf_render_page()`](https://docs.ropensci.org/pdftools//reference/pdf_render_page.html).
  Any R-level messages emitted during rendering are suppressed. Note
  that `Poppler` may also emit font diagnostic messages directly to
  C-level stderr; these bypass R's message system, are harmless, and
  cannot be suppressed from R.

  Successful validation indicates that the PDF structure is readable by
  the Poppler library used by `pdftools`. It does not guarantee that
  every page is visually correct, but it provides a strong indication
  that the file is not corrupted.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(fs)

# Create a temporary invalid pdf file
invalid_file <- fs::file_temp(ext = "pdf")
fs::file_create(invalid_file)
check_pdf(invalid_file)
#> [1] FALSE

# Create a valid pdf file
valid_file <- fs::file_temp(ext = "pdf")
invisible({
  grDevices::pdf(valid_file)
  plot(1:10)
  grDevices::dev.off()
})
check_pdf(valid_file, render = TRUE)
#> [1] TRUE

# Clean up temporary files
fs::file_delete(c(invalid_file, valid_file))
```
