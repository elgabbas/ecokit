#' List and Download Files from a Zenodo Record
#'
#' These functions provide an R interface to list all files in a Zenodo record
#' and to download one of those files (optionally reading it into R).
#'
#' @param record_id Character or numeric. The Zenodo record ID (e.g.,
#'   `"1234567"`).
#' @param zenodo_file Character. The file key (or filename) as listed in the
#'   Zenodo record.
#' @param dest_file Character (optional). Local destination path to save the
#'   downloaded file. If `NULL` (default), a temporary file is created and
#'   deleted if `read_func` is used.
#' @param read_func Function (optional). A function to read or process the
#'   downloaded file (e.g., [read.csv()], [readr::read_csv()], [readLines()],
#'   [readxl::read_excel()], etc.). If `NULL`, only the file path is returned.
#' @param ... Additional arguments passed to `read_func`.
#'
#' @details
#' - `zenodo_file_list()` lists all files and their metadata for a given
#' Zenodo record.
#' - `download_zenodo_file()` downloads a specified file from a
#' Zenodo record and can optionally read its contents into R using a
#' user-supplied function.
#' @return
#' - `zenodo_file_list` returns a `tibble` with metadata for each file in the
#' Zenodo record, including file key, filename, download link, and record-level
#' metadata such as title, DOI, and creation dates.
#' - `download_zenodo_file`: If `read_func` is `NULL`, returns the path to the
#' downloaded file. If `read_func` is provided, returns the output of that
#' function.
#' @author Ahmed El-Gabbas
#' @examples
#' require(ecokit)
#' require(terra)
#'
#' files <- zenodo_file_list("6620748")
#' dplyr::glimpse(files)
#'
#' # --------------------------------------------
#'
#' # Download as file only
#' pdf_file <- download_zenodo_file(
#'    record_id = "1234567", zenodo_file = "article.pdf")
#' print(pdf_file)
#'
#' ecokit::file_type(pdf_file)
#' fs::file_delete(pdf_file)
#'
#' # Download and read as data frame
#' nc_file <- download_zenodo_file(
#'   record_id = "6620748",
#'   zenodo_file = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
#'   read_func = terra::rast)
#'
#' print(class(nc_file))
#'
#' print(nc_file)
#' fs::file_delete(nc_file)

## |------------------------------------------------------------------------| #
# zenodo_file_list ----
## |------------------------------------------------------------------------| #

#' @export
#' @name zenodo_tools
#' @rdname zenodo_tools
#' @order 1

zenodo_file_list <- function(record_id) {

  self <- NULL

  if (is.null(record_id) ||
      !is.character(record_id) && !is.numeric(record_id)) {
    ecokit::stop_ctx(
      "record_id must be a non-null character or numeric.",
      cat_time_stamp = FALSE)
  }

  # Construct API URL to fetch record metadata
  api_url <- paste0("https://zenodo.org/api/records/", record_id)

  # Fetch record metadata via API
  api_response <- httr::GET(api_url)
  if (httr::status_code(api_response) != 200L) {
    ecokit::stop_ctx(
      paste0(
        "Failed to retrieve record metadata: ",
        httr::content(api_response, "text")),
      cat_time_stamp = FALSE)
  }
  record_data <- jsonlite::fromJSON(
    httr::content(api_response, as = "text", encoding = "UTF-8"))

  files <- tibble::as_tibble(record_data$files) %>%
    tidyr::unnest("links") %>%
    dplyr::rename(link = self) %>%
    dplyr::mutate(
      id = record_data$id,
      title = record_data$title,
      id_url = record_data$links$self,
      created = lubridate::as_datetime(record_data$created),
      modified = lubridate::as_datetime(record_data$modified),
      updated = lubridate::as_datetime(record_data$updated),
      doi_version = record_data$doi,
      doi = record_data$conceptdoi,
      .before = 1L)
  files
}


## |------------------------------------------------------------------------| #
# download_zenodo_file ----
## |------------------------------------------------------------------------| #

#' @export
#' @name zenodo_tools
#' @rdname zenodo_tools
#' @order 2

download_zenodo_file <- function(
    record_id = NULL, zenodo_file = NULL, dest_file = NULL,
    read_func = NULL, ...) {

  key <- NULL

  # Validate inputs
  if (is.null(record_id) ||
      !is.character(record_id) && !is.numeric(record_id)) {
    ecokit::stop_ctx(
      "record_id must be a non-null character or numeric.",
      cat_time_stamp = FALSE)
  }
  if (is.null(zenodo_file) || !is.character(zenodo_file)) {
    ecokit::stop_ctx(
      "zenodo_file must be a non-null character string.",
      cat_time_stamp = FALSE)
  }

  file_list <- zenodo_file_list(record_id = record_id)

  matched_files <- dplyr::filter(file_list, key %in% zenodo_file)

  if (nrow(matched_files) == 0L) {
    ecokit::stop_ctx(
      "The specified file does not exist in the Zenodo record.",
      cat_time_stamp = FALSE)
  }
  if (nrow(matched_files) > 1L) {
    ecokit::stop_ctx(
      "Multiple files match the key; specify uniquely.",
      cat_time_stamp = FALSE)
  }

  # Get the direct download URL from API (handles encoding automatically)
  download_url <- paste0(matched_files$link, "?download=1")

  # Check file accessibility with HEAD request
  head_response <- httr::HEAD(download_url)
  if (httr::status_code(head_response) != 200L) {
    ecokit::stop_ctx(
      "The file is not accessible (may be restricted).",
      cat_time_stamp = FALSE)
  }

  # file extension
  file_ext <- fs::path_ext(zenodo_file)

  if (is.null(dest_file)) {
    down_path <- fs::file_temp(
      pattern = fs::path_ext_remove(basename(zenodo_file)),
      ext = paste0(".", file_ext))
  } else {
    down_path <- dest_file
  }

  # Download the file with progress
  file_down <- httr::GET(
    download_url, httr::write_disk(down_path, overwrite = TRUE))

  # Optionally read the final file
  if (is.null(read_func)) {
    output_data <- down_path
  } else {
    if (is.null(dest_file)) {
      on.exit(fs::file_delete(down_path), add = TRUE)
    }
    output_data <- read_func(down_path, ...)
  }

  rm(file_down, envir = environment())

  # Return the output
  output_data
}
