# Check the integrity of a PDF file

Verify that a file exists, is non-empty, is identified as a PDF
document, and can be successfully parsed by `pdftools`. Optionally, the
first page can also be rendered to perform a stronger integrity check.

## Usage

``` r
check_pdf(file, render = FALSE)
```

## Arguments

- file:

  Character scalar. Path to a PDF file.

- render:

  Logical scalar. If `TRUE`, additionally attempt to render the first
  page using
  [`pdftools::pdf_render_page()`](https://docs.ropensci.org/pdftools//reference/pdf_render_page.html).
  Rendering provides a stronger integrity check but is slower than
  metadata validation alone.

## Value

A logical scalar:

- `TRUE`: The file exists, is non-empty, appears to be a PDF document,
  and can be successfully parsed by `pdftools`.

- `FALSE`: The file is missing, empty, not recognized as a PDF, cannot
  be parsed, or an error occurs during validation.

## Details

The function is intended to detect missing, empty, truncated, or
corrupted PDF files. Validation is performed by attempting to read the
document metadata using
[`pdftools::pdf_info()`](https://docs.ropensci.org/pdftools//reference/pdftools.html)

Validation is performed in the following order:

- Verify that the file exists and is non-empty.

- Verify that the file type contains the string `pdf` according to
  [`file_type()`](https://elgabbas.github.io/ecokit/reference/file_operations.md).

- Attempt to read PDF metadata using
  [`pdftools::pdf_info()`](https://docs.ropensci.org/pdftools//reference/pdftools.html).

- Optionally render the first page using
  [`pdftools::pdf_render_page()`](https://docs.ropensci.org/pdftools//reference/pdf_render_page.html).
  Note that Poppler may emit font diagnostic messages directly to stderr
  during rendering; these are harmless and are suppressed automatically.

  Successful validation indicates that the PDF structure is readable by
  the Poppler library used by `pdftools`. It does not guarantee that
  every page is visually correct, but it provides a strong indication
  that the file is not corrupted.

## Author

Ahmed El-Gabbas

## Examples

``` r
ecokit::load_packages(fs, pdftools)

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
