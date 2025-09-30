#' List and Download Files from a Zenodo Record
#'
#' These functions provide an R interface to list all files in a Zenodo record
#' and to download one of those files (optionally reading it into R).
#'
#' @param record_id Character or numeric. The Zenodo record ID (e.g.,
#'   `"1234567"`).
#' @param file_name Character. The file key (or filename) as listed in the
#'   Zenodo record.
#' @param dest_file Character (optional). Local destination path to save the
#'   downloaded file. If `NULL` (default), a temporary file is created and
#'   deleted if `read_func` is used.
#' @param read_func Function (optional). A function to read or process the
#'   downloaded file (e.g., [read.csv()], [readr::read_csv()], [readLines()],
#'   [readxl::read_excel()], etc.). If `NULL`, only the file path is returned.
#' @param delete_temp Logical. Whether to delete temporary files after reading
#'   them with `read_func`. Default is `TRUE`. Set to `FALSE` if you need the
#'   file to persist or if you're experiencing "resource busy" errors with
#'   complex read functions.
#' @param unwrap_r Logical. If `read_func` returns an `PackedSpatRaster` or
#'   `PackedSpatVector` object, this argument controls whether to unwrap packed
#'   objects using `terra::unwrap()`. Default is `TRUE`.
#' @param ... Additional arguments passed to `read_func`.
#'
#' @details
#' - `zenodo_file_list()` lists all files and their metadata for a given
#' Zenodo record.
#' - `zenodo_download_file()` downloads a specified file from a
#' Zenodo record and can optionally read its contents into R using a
#' user-supplied function.
#' @return
#' - `zenodo_file_list` returns a `tibble` with metadata for each file in the
#' Zenodo record, including file key, filename, download link, and record-level
#' metadata such as title, DOI, and creation dates.
#' - `zenodo_download_file`: If `read_func` is `NULL`, returns the path to the
#' downloaded file. If `read_func` is provided, returns the output of that
#' function.
#' @author Ahmed El-Gabbas
#' @examples
#' require(ecokit)
#' ecokit::load_packages(terra, dplyr, fs)
#'
#' files <- zenodo_file_list("6620748")
#' dplyr::glimpse(files)
#'
#' # --------------------------------------------
#'
#' # Download as file only
#' pdf_file <- zenodo_download_file(
#'   record_id = "1234567", file_name = "article.pdf")
#' print(pdf_file)
#'
#' ecokit::file_type(pdf_file)
#' try(fs::file_delete(pdf_file), silent = TRUE)
#'
#' # --------------------------------------------
#'
#' # Download and read NetCDF as SpatRaster
#' nc_file <- zenodo_download_file(
#'   record_id = "6620748",
#'   file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
#'   read_func = terra::rast)
#'
#' print(class(nc_file))
#'
#' print(nc_file)
#'
#' terra::inMemory(nc_file)
#'
#' # --------------------------------------------
#'
#' # Download and read NetCDF as SpatRaster; using custom function
#' nc_file2 <- zenodo_download_file(
#'   record_id = "6620748",
#'   file_name = "100Ma_Pohletal2022_DIB_PhaneroContinentalClimate.nc",
#'   read_func = function(x) { terra::rast(x) * 10 })
#'
#' print(class(nc_file2))
#'
#' print(nc_file2)
#'
#' terra::inMemory(nc_file2)
#'
#' # --------------------------------------------
#'
#' terra::app(nc_file, "range")
#' terra::app(nc_file2, "range")
#'

## |------------------------------------------------------------------------| #
# zenodo_file_list ----
## |------------------------------------------------------------------------| #

#' @export
#' @name zenodo_tools
#' @rdname zenodo_tools
#' @order 1

zenodo_file_list <- function(record_id) {

  self <- NULL

  ecokit::check_args(args_to_check = "record_id", args_type = "character")

  if (is.null(record_id) ||
      !is.character(record_id) && !is.numeric(record_id)) {
    ecokit::stop_ctx("record_id must be a non-null character or numeric.")
  }

  # Construct API URL to fetch record metadata
  api_url <- paste0("https://zenodo.org/api/records/", record_id)

  # Fetch record metadata via API
  api_response <- httr::GET(api_url)
  if (httr::status_code(api_response) != 200L) {
    ecokit::stop_ctx(
      paste0(
        "Failed to retrieve record metadata: ",
        httr::content(api_response, "text")))
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
# zenodo_download_file ----
## |------------------------------------------------------------------------| #

#' @export
#' @name zenodo_tools
#' @rdname zenodo_tools
#' @order 2

zenodo_download_file <- function(
    record_id = NULL, file_name = NULL, dest_file = NULL,
    read_func = NULL, delete_temp = TRUE, unwrap_r = TRUE, ...) {

  key <- NULL

  ecokit::check_args(
    args_to_check = c("delete_temp", "unwrap_r"), args_type = "logical")
  ecokit::check_args(
    args_to_check = c("record_id", "file_name"), args_type = "character")

  # Validate inputs
  if (is.null(record_id) ||
      !is.character(record_id) && !is.numeric(record_id)) {
    ecokit::stop_ctx("record_id must be a non-null character or numeric.")
  }
  if (is.null(file_name) || !is.character(file_name)) {
    ecokit::stop_ctx("file_name must be a non-null character string.")
  }

  file_list <- zenodo_file_list(record_id = record_id)
  if (nrow(file_list) == 0L) {
    ecokit::stop_ctx("The specified Zenodo record contains no files.")
  }

  matched_files <- dplyr::filter(file_list, key %in% file_name)
  if (nrow(matched_files) == 0L) {
    ecokit::stop_ctx("The specified file does not exist in the Zenodo record.")
  }
  if (nrow(matched_files) > 1L) {
    ecokit::stop_ctx("Multiple files match the key; specify uniquely.")
  }

  # Get the direct download URL from API (handles encoding automatically)
  download_url <- paste0(matched_files$link, "?download=1")

  # Check file accessibility with HEAD request
  head_response <- httr::HEAD(download_url)
  if (httr::status_code(head_response) != 200L) {
    ecokit::stop_ctx("The file is not accessible (may be restricted).")
  }

  # file extension
  file_ext <- fs::path_ext(file_name)

  if (is.null(dest_file)) {
    down_path <- fs::file_temp(
      pattern = fs::path_ext_remove(basename(file_name)),
      ext = paste0(".", file_ext))
  } else {
    down_path <- dest_file
  }

  # Download the file with progress
  file_down <- httr::GET(
    download_url, httr::write_disk(down_path, overwrite = TRUE))
  if (httr::status_code(file_down) != 200L) {
    ecokit::stop_ctx("Failed to download the file from Zenodo.")
  }
  if (!fs::file_exists(down_path)) {
    ecokit::stop_ctx("Downloaded file does not exist at the expected path.")
  }

  # Optionally read the final file
  if (is.null(read_func)) {
    output_data <- down_path
  } else {
    # Read the file first
    output_data <- read_func(down_path, ...)

    if (inherits(output_data, "SpatRaster") &&
        !all(terra::inMemory(output_data))) {
      output_data <- terra::toMemory(output_data)
    }

    if (inherits(output_data, c("PackedSpatRaster", "PackedSpatVector")) &&
        unwrap_r) {
      output_data <- terra::unwrap(output_data)
    }

    # Only delete if it's a temp file and delete_temp is TRUE
    if (is.null(dest_file) && delete_temp) {
      try(fs::file_delete(down_path), silent = TRUE)
    }
  }

  rm(file_down, envir = environment())
  invisible(gc())

  # Return the output
  output_data
}
