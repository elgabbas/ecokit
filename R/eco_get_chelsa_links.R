#' Retrieve CHELSA Data Links
#'
#' Fetches links to [CHELSA](https://chelsa-climate.org/) climate data files
#' from a specified base URL, filters them to include only links for *.tif files
#' for variables available under current and future climate scenarios, and
#' extracts metadata to create a tibble with detailed file information.
#'
#' @param base_url Base URL of the CHELSA repository. Defaults to
#'   "https://os.zhdk.cloud.switch.ch/chelsav2/".
#'
#' @return A tibble with the following columns:
#'
#' - `url` (character): Full URL of the data file.
#' - `relative_url` (character): Relative URL, excluding the base URL.
#' - `file_name` (character): Name of the data file.
#' - `dir_name` (character): Directory path of the file.
#' - `climate_scenario` (character): Climate scenario. Values are: "current",
#'   "ssp126", "ssp370", and "ssp585".
#' - `climate_model` (character): Climate model. Values are: "Current",
#'   "GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", and
#'   "UKESM1-0-LL".
#' - `year` (character): Year range. Values are "1981-2010", "2011-2040",
#'   "2041-2070", and "2071-2100".
#' - `var_name` (character): Variable name, e.g., "bio1".
#' - `long_name` (character): Full variable name, e.g., "mean annual air
#'   temperature".
#' - `unit` (character): Measurement unit, e.g., "°C".
#' - `scale` (numeric): Scale factor for the variable.
#' - `offset` (numeric): Offset value for the variable.
#' - `explanation` (character): Brief description of the variable.
#' @author Ahmed El-Gabbas
#' @examples
#' options(tibble.print_max = 200)
#' CHELSA_links <- get_chelsa_links()
#'
#' dplyr::glimpse(CHELSA_links)
#'
#' # Count the number of files per climate scenario, model, and year
#' dplyr::count(CHELSA_links, climate_scenario, climate_model, year)
#'
#' CHELSA_links %>%
#'   dplyr::count(var_name, long_name, unit, scale, offset, explanation)
#'
#' print(CHELSA_links, n = 200)
#'
#' @export

get_chelsa_links <- function(
    base_url = "https://os.zhdk.cloud.switch.ch/chelsav2/") {

  url <- relative_url <- climate_scenario <- climate_model <- var_name <-
    dir_name <- year <-  NULL

  # Initialise variables for pagination and retries

  # Tracks pagination token for API requests
  continuation_token <- ""
  # Stores all file keys from API responses
  all_keys <- vector(mode = "character")
  # Maximum number of retry attempts for failed requests
  max_retries <- 3L
  # Counter for retry attempts
  retry_count <- 0L

  # Climate models for regex pattern matching
  clim_models <- c(
    "MRI-ESM2-0", "MPI-ESM1-2-HR", "UKESM1-0-LL",
    "GFDL-ESM4", "IPSL-CM6A-LR") %>%
    # Combine into a single regex pattern
    paste(collapse = "|")

  # CHELSA variables for regex pattern matching
  #nolint start: nonportable_path_linter
  vars_to_extract <- c(
    "bio\\d{1,2}", "fcf", "gdgfgd\\d{1,2}", "fgd", "gddlgd\\d{1,2}",
    "gdd\\d{1,2}", "gsl", "gsp", "gst", "kg\\d", "lgd", "ngd\\d{1,2}",
    "npp", "scd", "swe") %>%
    # Combine into a single regex pattern
    paste0(collapse = "|")
  #nolint end

  # Loop to handle paginated API responses
  repeat {
    # Construct the API request URL with list-type
    url <- paste0(base_url, "?list-type=2")

    # Append continuation token for paginated requests if present
    if (continuation_token != "") {
      url <- paste0(
        url, "&continuation-token=", utils::URLencode(continuation_token))
    }

    # Send GET request to the CHELSA API
    response <- httr::GET(url)

    # Handle HTTP errors with retries
    if (httr::status_code(response) != 200L) {
      retry_count <- retry_count + 1L
      if (retry_count > max_retries) {
        # Stop after max retries with error context
        ecokit::stop_ctx(
          paste0("Error after ", max_retries, " retries."),
          status_code = httr::status_code(response))
      }
      # Pause before retrying to avoid overwhelming the server
      Sys.sleep(1L)
      # Retry the request
      next
    }

    # Reset retry count after a successful request
    retry_count <- 0L

    # Parse XML response with explicit UTF-8 encoding
    xml_content <- httr::content(response, as = "text", encoding = "UTF-8") %>%
      xml2::read_xml()

    # Extract namespace information for XML parsing
    name_space_info <- xml2::xml_ns(xml_content)

    # Extract file keys from XML using namespace
    keys <- xml2::xml_find_all(
      x = xml_content, xpath = ".//s3:Key",
      ns = c(s3 = as.character(name_space_info))) %>%
      xml2::xml_text()

    # Append new keys to the collection
    all_keys <- c(all_keys, keys)

    # Check for next continuation token to continue pagination
    continuation_node <- xml2::xml_find_first(
      x = xml_content, xpath = ".//s3:NextContinuationToken",
      ns = c(s3 = as.character(name_space_info)))

    continuation_token <- xml2::xml_text(continuation_node)

    # Exit loop if no more continuation tokens
    if (is.na(continuation_token)) {
      break
    }
  }

  # Create tibble with file links and extract metadata
  all_links <- tibble::tibble(url = paste0(base_url, all_keys)) %>%
    dplyr::mutate(
      # Replace spaces in URLs with %20 for proper encoding
      url = stringr::str_replace_all(url, " ", "%20"),
      # Remove base URL to get relative path
      relative_url = stringr::str_remove_all(url, base_url),
      # Extract file name from URL
      file_name = basename(url),
      # Extract directory path from relative URL
      dir_name = dirname(relative_url)) %>%
    # Filter for climatology files with .tif extension
    dplyr::filter(
      stringr::str_detect(relative_url, "climatologies"),
      tools::file_ext(url) == "tif") %>%
    # Extract metadata from file paths
    dplyr::mutate(
      # Extract climate scenario (e.g., ssp585)
      climate_scenario = stringr::str_extract(
        relative_url, "ssp\\d{1,3}"), # nolint: nonportable_path_linter
      # Extract climate model
      climate_model = stringr::str_extract(relative_url, clim_models),
      # Extract year range (e.g., 1981-2010)
      year = stringr::str_extract(relative_url, "[0-9]{4}-[0-9]{4}"),
      # Assign "current" for 1981-2010 scenarios if missing
      climate_scenario = dplyr::if_else(
        stringr::str_detect(relative_url, "1981-2010") &
          is.na(climate_scenario),
        "current", climate_scenario),
      # Assign "current" for 1981-2010 models if missing
      climate_model = dplyr::if_else(
        stringr::str_detect(relative_url, "1981-2010") & is.na(climate_model),
        "current", climate_model),
      # Extract variable name
      var_name = stringr::str_extract(relative_url, vars_to_extract)) %>%
    # Filter for valid variables and exclude ssp126 directories
    dplyr::filter(!is.na(var_name), !endsWith(dir_name, "ssp126")) %>%
    # Join with `chelsa_var_info` for additional variable details
    dplyr::left_join(ecokit::chelsa_var_info, by = "var_name") %>%
    ecokit::arrange_alphanum(climate_scenario, climate_model, year, var_name)

  # Return the final tibble
  return(all_links)
}
