# Verify Image File Integrity

This function checks the integrity of image files (JPEG, PNG, TIFF, and
PDF) by validating their existence, size, extension, and type using the
`file` bash command. It confirms that the file has a recognized image or
PDF format and non-zero dimensions (or page count for PDFs).

## Usage

``` r
check_image(file, warning = TRUE)
```

## Arguments

- file:

  A character string specifying the path to the image file.

- warning:

  A logical value indicating whether to issue warnings for invalid files
  (e.g., empty files, unrecognized extensions). Defaults to `TRUE`.

## Value

A logical value: `TRUE` if the file is a valid image or PDF, `FALSE`
otherwise.

## Details

The function performs the following checks:

- Validates that `file` is a single character string.

- Ensures the file exists and is not a directory.

- Checks that the file size is non-zero, issuing a warning if empty
  (when `warning = TRUE`).

- Verifies the file extension is one of `jpg`, `jpeg`, `png`, `tif`,
  `tiff`, or `pdf`, issuing a warning if not (when `warning = TRUE`).

- Uses the `file` bash command to confirm the file type and extract
  metadata (e.g., dimensions for images, page count for PDFs). The file
  is considered valid if it matches the expected type and has positive
  dimensions (or page count). The `file` command must be available on
  the system.

## Author

Ahmed El-Gabbas

## Examples

``` r
# Load required packages
ecokit::load_packages(fs)

# Create a temporary directory for test files
temp_dir <- fs::dir_create(fs::path_temp("image_test"))

# --------------------------------------------

# Valid image files

# jpeg
jpeg_path <- fs::path(temp_dir, "valid_image.jpg")
grDevices::jpeg(
  filename = jpeg_path, width = 6, height = 6, units = "cm", res = 200)
plot(1:10, 1:10, main = "Valid Image")
invisible(grDevices::dev.off())
check_image(jpeg_path)
#> [1] TRUE

# png
png_path <- fs::path(temp_dir, "valid_image.png")
png(
  filename = png_path, width = 6, height = 6, units = "cm", res = 200)
plot(1:10, 1:10, main = "Valid Image")
invisible(grDevices::dev.off())
check_image(png_path)
#> [1] TRUE


# tiff
tiff_path <- fs::path(temp_dir, "valid_image.tiff")
tiff(
  filename = tiff_path, width = 6, height = 6, units = "cm", res = 200)
plot(1:10, 1:10, main = "Valid Image")
invisible(grDevices::dev.off())
check_image(tiff_path)
#> [1] TRUE

# pdf
pdf_path <- fs::path(temp_dir, "valid_document.pdf")
grDevices::pdf(file = pdf_path, width = 6, height = 6)
plot(1:10, 1:10, main = "Valid Document")
invisible(grDevices::dev.off())
check_image(pdf_path)
#> [1] TRUE

# --------------------------------------------

# Corrupted image file

corrupt_path <- fs::path(temp_dir, "corrupt_image.jpg")
fs::file_create(corrupt_path)
writeBin(charToRaw("This is not an image"), corrupt_path)
check_image(corrupt_path)
#> [1] FALSE

corrupt_pdf_path <- fs::path(temp_dir, "valid_document.pdf")
grDevices::pdf(file = corrupt_pdf_path, width = 6, height = 6)
invisible(grDevices::dev.off())
check_image(corrupt_pdf_path)
#> [1] FALSE

# --------------------------------------------

# Non-image file

text_path <- fs::path(temp_dir, "not_an_image.txt")
fs::file_create(text_path)
writeLines("This is a text file", text_path)

check_image(text_path)
#> Warning: The file extension 'txt' is not a supported image format (JPEG, PNG, TIFF, PDF).
#> File: /tmp/Rtmp9s80iV/image_test/not_an_image.txt
#> [1] FALSE
check_image(text_path, warning = FALSE)
#> [1] FALSE

# --------------------------------------------

# Nonexistent file

nonexistent_path <- fs::path(temp_dir, "nonexistent_image.jpg")
check_image(nonexistent_path)
#> Warning: The file '/tmp/Rtmp9s80iV/image_test/nonexistent_image.jpg' does not exist.
#> [1] FALSE

check_image(temp_dir)
#> Warning: Input `file` '/tmp/Rtmp9s80iV/image_test' is a directory.
#> [1] FALSE

# --------------------------------------------

# Clean up
fs::dir_delete(temp_dir)
```
