# =========================================================================== #
# iNaturalist observation retrieval --- ecokit
#
# These functions provide a robust, pagination-aware interface to the
# iNaturalist v1 REST API (/observations endpoint), replacing the rinat
# package's `get_inat_obs()` workflow.
#
# Key differences from rinat::get_inat_obs():
#   - Uses httr2 (modern, retry-aware HTTP) instead of httr.
#   - Automatically bypasses the hard API ceiling of 10,000 records per
# query by cascading through yearly --> monthly --> weekly --> daily chunking,
# each level triggered only when the previous level exceeds the limit.
#   - Raises an informative error (via ecokit::stop_ctx()) instead of
# silently truncating if even daily chunks exceed 10,000 records.
#   - Returns a deduplicated tibble regardless of chunking depth used.
#   - Validates all inputs rigorously before any network call is made.
# =========================================================================== #


# =========================================================================== #
# INTERNAL HELPER: perform one paginated API request
# =========================================================================== #

#' Perform one iNaturalist API page request
#'
#' @description Low-level helper that builds and fires a single GET request
#'   against the iNaturalist v1 `/observations` endpoint and returns the parsed
#'   JSON body.
#'
#'   Filters are applied as URL query parameters. Optional parameters (`month`,
#'   `day_min`, `day_max`) are silently dropped from the URL when `NULL`,
#'   relying on `httr2::req_url_query()` behaviour, so no conditional branching
#'   is required in the caller.
#'
#'   `quality_grade` is fixed to `"research"` and results are ordered by
#'   ascending observation `id` to guarantee stable, gap-free pagination across
#'   multiple calls for the same window.
#'
#' @param taxon_id `[integer(1)]` iNaturalist taxon ID.
#' @param bounds `[numeric(4)]` Bounding box as `c(sw_lat, sw_lng, ne_lat,
#'   ne_lng)`.
#' @param year `[integer(1)]` Four-digit calendar year.
#' @param month `[integer(1) | NULL]` Month (1-12). `NULL` omits the filter.
#' @param day_min `[integer(1) | NULL]` First day of the day range within
#'   `month`. Requires `month` to be non-`NULL`; ignored otherwise.
#' @param day_max `[integer(1) | NULL]` Last day of the day range within
#'   `month`. Requires `month` to be non-`NULL`; ignored otherwise.
#' @param page `[integer(1)]` Page number to retrieve (default `1L`).
#' @param per_page `[integer(1)]` Records per page; maximum allowed by the API
#'   is 200 (default `200L`).
#'
#' @return A named list parsed from the JSON response body, as returned by
#'   `httr2::resp_body_json()`. Key fields include `$total_results` and
#'   `$results` (a list of observation records).
#'
#' @note HTTP errors are suppressed at the `httr2` level, so the caller is
#'   responsible for checking for empty or malformed responses. Up to 5 retries
#'   are attempted with exponential backoff (`2^attempt` seconds).
#'
#' @keywords internal
#' @noRd
#' @author Ahmed El-Gabbas

.inat_fetch_page <- function(
    taxon_id, bounds, year, month = NULL, day_min = NULL, day_max = NULL,
    page = 1L, per_page = 200L) {

  # Build the ISO-8601 date strings only when both month and day are supplied;
  # NULL values are automatically excluded from the URL by req_url_query().
  d1 <- if (!is.null(day_min) && !is.null(month)) {
    sprintf("%04d-%02d-%02d", year, month, day_min)
  } else {
    NULL
  }

  d2 <- if (!is.null(day_max) && !is.null(month)) {
    sprintf("%04d-%02d-%02d", year, month, day_max)
  } else {
    NULL
  }

  httr2::request("https://api.inaturalist.org/v1/observations") %>%
    httr2::req_url_query(
      taxon_id = taxon_id,
      swlat = bounds[1L], swlng = bounds[2L],
      nelat = bounds[3L], nelng = bounds[4L],
      quality_grade = "research", year = year,
      # month, d1, d2v --- NULL --> silently omitted
      month = month, d1 = d1, d2 = d2, per_page = per_page,
      page = page, order = "asc", order_by = "id") %>%
    httr2::req_retry(max_tries = 5L, backoff = ~ 2L^.x) %>%
    # let caller handle errors
    httr2::req_error(is_error = function(r) FALSE) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()
}


# =========================================================================== #
# INTERNAL HELPER: parse a flat list of observation records into a tibble
# =========================================================================== #

#' Parse a list of iNaturalist observation records into a tidy tibble
#'
#' @description Converts the nested list returned in `$results` by the
#'   iNaturalist API into a flat `tibble` with one row per observation. Missing
#'   or `NULL` leaf values are replaced by typed `NA` sentinels so the schema is
#'   always consistent regardless of which fields the API omits for any
#'   individual record.
#'
#' @param records `[list]` A flat list of observation records, each being a
#'   named list as returned by `httr2::resp_body_json()` for a single page.
#'   Typically obtained via `purrr::flatten(page_results)`.
#'
#' @return A [`tibble`][tibble::tibble] with columns:
#'  - `id`: `integer` --- unique iNaturalist observation ID
#'  - `observed_on`: `date` --- observation date (ISO 8601)
#'  - `day`: `integer` --- day of month (1-31)
#'  - `month`: `integer` --- month (1-12)
#'  - `year`: `integer` --- four-digit year
#'  - `quality_grade`: `character` --- always `"research"` for these
#'   queries but included for completeness
#'  - `taxon_id`: `integer` --- iNaturalist taxon ID of the observed
#'   organism (may differ from the queried `taxon_id` for aggregates)
#'  - `rank`: `character` --- taxonomic rank of the observed organism
#'  - `taxon_name`: `character` --- scientific name of the taxon
#'  - `num_identification_agreements`: `integer` --- number of iNaturalist
#'   users have agreed on the same identification for this observation
#'  - `latitude`: `numeric` --- WGS 84 decimal latitude
#'  - `longitude`: `numeric` --- WGS 84 decimal longitude
#'  - latitude_n_decimals`: `integer` --- number of decimal places in the
#'   latitude value
#'  - `longitude_n_decimals`: `integer` --- number of decimal places in the
#'   longitude value
#'  - `positional_accuracy`: `integer` --- positional accuracy in meters
#'  - `coordinates_obscured`: `logical` --- `TRUE` if the coordinates have been
#'   obscured, otherwise `FALSE`
#'  - `geoprivacy`: `character` --- geoprivacy setting (`"open"`, `"obscured"`,
#'   or `"private"`)
#'  - `place_guess`: `character` --- human-readable locality string
#'   provided by the observer
#'  - `user_login`: `character` --- iNaturalist username of the observer
#'  - `uri`: `character` --- permanent URL of the observation
#'  - `in_gbif`: `logical` --- `TRUE` if the observation is linked to GBIF,
#'   otherwise `FALSE`
#'  - `outlinks`: `list` --- a list-column containing the raw `outlinks` data
#'
#' @noRd
#' @keywords internal
#' @author Ahmed El-Gabbas

.inat_parse_records <- function(records) {

  purrr::map_dfr(
    records,
    ~ {
      coords <- stringr::str_split(.x$location, ",", simplify = TRUE) %>%
        as.vector()
      coords_n_decimals <- ecokit::n_decimals(coords)
      observed_on <- lubridate::ymd(.x$observed_on) %||% lubridate::NA_Date_

      outlinks <- tibble::tibble(as.data.frame(.x$outlinks))
      if (nrow(outlinks) > 0L) {
        outlinks_gbif <- any(tolower(outlinks$source) == "gbif")
      } else {
        outlinks_gbif <- FALSE
      }

      tibble::tibble(
        id = .x$id %||% NA_integer_,
        observed_on = observed_on,
        day = as.integer(lubridate::day(observed_on)) %||% NA_integer_,
        month = as.integer(lubridate::month(observed_on)) %||% NA_integer_,
        year = as.integer(lubridate::year(observed_on)) %||% NA_integer_,
        quality_grade = .x$quality_grade %||% NA_character_,
        taxon_id = .x$taxon$id %||% NA_integer_,
        rank = .x$taxon$rank %||% NA_character_,
        taxon_name = .x$taxon$name %||% NA_character_,
        num_identification_agreements =
          .x$num_identification_agreements %||% NA_integer_,
        latitude = as.numeric(coords[[1L]]) %||% NA_real_,
        longitude = as.numeric(coords[[2L]]) %||% NA_real_,
        latitude_n_decimals = coords_n_decimals[[1L]] %||% NA_integer_,
        longitude_n_decimals = coords_n_decimals[[2L]] %||% NA_integer_,
        positional_accuracy = .x$positional_accuracy %||% NA_integer_,
        coordinates_obscured = .x$obscured %||% NA,
        geoprivacy = .x$geoprivacy %||% NA_character_,
        place_guess = .x$place_guess %||% NA_character_,
        user_login = .x$user$login %||% NA_character_,
        uri = .x$uri %||% NA_character_,
        in_gbif = outlinks_gbif %||% NA,
        outlinks = list(outlinks))
    }
  )
}

# =========================================================================== #
# INTERNAL HELPER: fetch all pages for one date window
# =========================================================================== #

#' Fetch all paginated records for a single date window
#'
#' @description Issues a lightweight "ping" request (`per_page = 1`) to read
#'   `total_results` cheaply, then iterates over pages of 200 records each to
#'   retrieve the full result set. Progress is reported via
#'   `ecokit::cat_time()`.
#'
#'   This function is the core pagination engine shared by all chunking levels
#'   (annual, monthly, weekly, daily). It does **not** itself split large
#'   windows; that responsibility lies with the calling helper
#'   (`.inat_fetch_year`, `.inat_fetch_month`, `.inat_fetch_week`). If the
#'   window still exceeds `max_results` after all splitting levels have been
#'   exhausted, `ecokit::stop_ctx()` is called with a descriptive message and
#'   the `window_label` and `total_results` as metadata.
#'
#'   A polite delay of 0.7 s is inserted between page requests to stay within
#'   roughly 85 requests per minute (the unauthenticated limit is 100/min).
#'
#' @param taxon_id `[integer(1)]` iNaturalist taxon ID.
#' @param bounds `[numeric(4)]` Bounding box `c(sw_lat, sw_lng, ne_lat,
#'   ne_lng)`.
#' @param year `[integer(1)]` Four-digit calendar year.
#' @param month `[integer(1) | NULL]` Month filter (1-12) or `NULL`.
#' @param day_min `[integer(1) | NULL]` Start day of range or `NULL`.
#' @param day_max `[integer(1) | NULL]` End day of range or `NULL`.
#' @param window_label `[character(1)]` Human-readable label for this window,
#'   used only in progress and error messages.
#' @param max_results `[integer(1)]` Maximum records allowed before raising an
#'   error. Default: `10000L` (the iNaturalist API hard ceiling per query).
#' @param per_page `[integer(1)]` Records per page request (max `200L`).
#' @param verbose `[logical(1)]` Print progress messages. Default `TRUE`.
#'
#' @return A [`tibble`][tibble::tibble] with columns described in
#'   `.inat_parse_records()`, or an empty `tibble` if `total_results == 0`.
#'
#' @keywords internal
#' @noRd
#' @author Ahmed El-Gabbas

.inat_fetch_window <- function(
    taxon_id, bounds, year, month = NULL, day_min = NULL, day_max = NULL,
    window_label = NULL, max_results = 10000L, per_page = 200L,
    verbose = TRUE) {

  # ping: cheaply read total_results with a single-record request
  ping <- .inat_fetch_page(
    taxon_id = taxon_id, bounds = bounds, year = year,
    month = month, day_min = day_min, day_max = day_max,
    page = 1L, per_page = 1L)

  total_res <- ping$total_results

  total_res0 <- ecokit::format_number(total_res, underline = TRUE)
  ecokit::cat_time(
    glue::glue("{total_res0} records for: {window_label}"),
    verbose = verbose, cat_timestamp = FALSE, level = 1L)

  # Empty window: return zero-row tibble immediately
  if (total_res == 0L) {
    return(tibble::tibble())
  }

  # Guard: if the window still exceeds the API ceiling at this splitting level,
  # raise a structured error rather than silently losing records.
  if (total_res > max_results) {
    msg <- glue::glue(
      "Window [{window_label}] contains {total_res} records, which exceeds ",
      "the API ceiling of {max_results}. ",
      "Consider narrowing the spatial bounds, reducing the taxon scope, ",
      "or filing an issue if this occurs at daily granularity.")
    ecokit::stop_ctx(
      message = msg, window_label = window_label,
      total_results = total_res, max_results = max_results)
  }

  # Compute page count from confirmed total
  n_pages <- ceiling(total_res / per_page)

  # Paginated fetch loop
  page_results <- vector("list", n_pages)

  for (i in seq_len(n_pages)) {

    ecokit::cat_time(
      glue::glue("  Page {i}/{n_pages} [{window_label}]"),       # nolint
      verbose = verbose, cat_timestamp = FALSE)

    resp <- .inat_fetch_page(
      taxon_id = taxon_id, bounds = bounds, year = year,
      month = month, day_min = day_min, day_max = day_max,
      page = i, per_page = per_page)

    page_results[[i]] <- resp$results

    # Polite delay: ~85 req/min --- stays comfortably under 100/min limit
    Sys.sleep(0.7)
  }

  # Flatten page list and parse into a tibble
  .inat_parse_records(purrr::flatten(page_results))
}


# =========================================================================== #
# INTERNAL HELPER: fetch one week with automatic daily fallback
# =========================================================================== #

#' Fetch one calendar week, with automatic daily fallback
#'
#' @description Issues a ping for the week defined by `day_min:day_max`. If the
#'   record count is within the API ceiling the week is fetched as a single
#'   window via `.inat_fetch_window()`. If it exceeds the ceiling the week is
#'   split into individual days and each day is fetched via
#'   `.inat_fetch_window()`.
#'
#'   This is the innermost level of the chunking cascade: `year --> month -->
#'   week --> day`. If a single day still exceeds the ceiling,
#'   `.inat_fetch_window()` raises an informative error so the caller can
#'   investigate (e.g. by narrowing spatial bounds).
#'
#' @param taxon_id `Integer`. iNaturalist taxon ID.
#' @param bounds `Numeric`. Bounding box `c(sw_lat, sw_lng, ne_lat, ne_lng)`.
#' @param year `Integer`. Four-digit calendar year.
#' @param month `Integer`. Month (1-12).
#' @param day_min `Integer`. First day of the week window.
#' @param day_max `Integer`. Last day of the week window.
#' @param week_index `Integer`. Week number within the month (1-5),5), used only
#'   in progress messages.
#' @param n_weeks `Integer`. Total number of weeks in the month, used only in
#'   progress messages.
#' @param max_results `Integer`. Record ceiling before daily splitting is
#'   triggered (default `10000L`).
#' @param verbose `Logical`. Print progress messages. Default `TRUE`.
#'
#' @return A [`tibble`][tibble::tibble] with columns described in
#'   `.inat_parse_records()`, or an empty `tibble` if no records exist.
#'
#' @keywords internal
#' @noRd
#' @author Ahmed El-Gabbas

.inat_fetch_week <- function(
    taxon_id, bounds, year, month, day_min, day_max, week_index, n_weeks,
    max_results = 10000L, verbose = TRUE) {

  week_label <- glue::glue(
    "Year: {year}, month: {month}, week {week_index}/{n_weeks} ",
    "(days {day_min}-{day_max})")

  ecokit::cat_time(
    glue::glue("Week {week_index}/{n_weeks}: days {day_min}-{day_max}"),
    verbose = verbose, cat_timestamp = FALSE, level = 2L)

  # Ping the whole week first
  ping <- .inat_fetch_page(
    taxon_id = taxon_id, bounds = bounds, year = year, month = month,
    day_min = day_min, day_max = day_max, page = 1L, per_page = 1L)

  total_week <- ping$total_results

  # Fast path: week fits within the limit
  if (total_week == 0L) {
    ecokit::cat_time(
      "0 records --- skipping", verbose = verbose, cat_timestamp = FALSE)
    return(tibble::tibble())
  }

  if (total_week <= max_results) {
    return(
      .inat_fetch_window(
        taxon_id = taxon_id, bounds = bounds, year = year,
        month = month, day_min = day_min, day_max = day_max,
        window_label = week_label, max_results = max_results,
        verbose = FALSE  # count already printed above
      ))
  }

  # Slow path: week > limit, split into individual days
  total_week0 <- ecokit::format_number(total_week, underline = TRUE)
  max_results0 <- ecokit::format_number(max_results, underline = TRUE)
  ecokit::cat_time(
    glue::glue(
      "{total_week0} records exceed the `max_results` of {max_results0}"),
    verbose = verbose, cat_timestamp = FALSE, level = 1L)
  ecokit::cat_time(
    "Splitting week {week_index}/{n_weeks} into daily chunks",    # nolint
    verbose = verbose, cat_timestamp = FALSE, level = 1L)

  daily_data <- purrr::map_dfr(
    .x = seq(day_min, day_max),
    .f = function(d) {
      day_label <- glue::glue("Year: {year}, month: {month}, day: {d}")

      ecokit::cat_time(
        glue::glue("Day {d}"),
        verbose = verbose, cat_timestamp = FALSE)

      .inat_fetch_window(
        taxon_id = taxon_id, bounds = bounds, year = year,
        month = month, day_min = d, day_max = d,
        window_label = day_label, max_results = max_results,
        verbose = verbose)
    })

  daily_data
}


# =========================================================================== #
# INTERNAL HELPER: fetch one calendar month with automatic weekly fallback
# =========================================================================== #

#' Fetch one calendar month with automatic weekly (and daily) fallback
#'
#' @description Ping-tests the full month. If within the API ceiling the month
#'   is fetched as a single window. Otherwise the month is split into at most 5
#'   weekly windows whose boundaries are computed dynamically from the actual
#'   number of days in the month. Each week is delegated to
#'   `.inat_fetch_week()`, which itself falls back to daily chunks if needed.
#'
#'   Week windows are:
#' - W1: days 1-7
#' - W2: days 8-14
#' - W3: days 15-21
#' - W4: days 22-28
#' - W5: days 29 - last day (only created for months with > 28 days)
#'
#' @param taxon_id `[integer(1)]` iNaturalist taxon ID.
#' @param bounds `[numeric(4)]` Bounding box `c(sw_lat, sw_lng, ne_lat,
#'   ne_lng)`.
#' @param year `[integer(1)]` Four-digit calendar year.
#' @param month `[integer(1)]` Month (1-12).
#' @param max_results `[integer(1)]` Record ceiling before weekly splitting is
#'   triggered (default `10000L`).
#' @param verbose `[logical(1)]` Print progress messages. Default `TRUE`.
#'
#' @return A deduplicated [`tibble`][tibble::tibble] with columns described in
#'   `.inat_parse_records()`, or an empty `tibble` if no records exist.
#'
#' @keywords internal
#' @noRd
#' @author Ahmed El-Gabbas

.inat_fetch_month <- function(
    taxon_id, bounds, year, month, max_results = 10000L, verbose = TRUE) {

  month_label <- glue::glue("Year: {year}, month: {month}")

  # Ping the whole month
  ping <- .inat_fetch_page(
    taxon_id = taxon_id, bounds = bounds,
    year = year, month = month, page = 1L, per_page = 1L)

  total_month <- ping$total_results
  total_month0 <- ecokit::format_number(total_month, underline = TRUE)

  ecokit::cat_time(
    glue::glue("{month_label} --- {total_month0} records"),
    verbose = verbose, cat_timestamp = FALSE)

  # Empty month: return immediately
  if (total_month == 0L) {
    return(tibble::tibble())
  }

  # Fast path: month within limit
  if (total_month <= max_results) {
    return(
      .inat_fetch_window(
        taxon_id = taxon_id, bounds = bounds, year = year, month = month,
        window_label = month_label, max_results = max_results,
        verbose = FALSE  # count already printed above
      ))
  }

  # Slow path: split into weekly windows
  total_month0 <- ecokit::format_number(total_month, underline = TRUE)
  max_results0 <- ecokit::format_number(max_results, underline = TRUE)
  ecokit::cat_time(
    glue::glue(
      "{total_month0} records exceed the `max_results` of {max_results0}"),
    verbose = verbose, cat_timestamp = FALSE, level = 1L)
  ecokit::cat_time(
    glue::glue("Splitting month {month} into weekly chunks"),
    verbose = verbose, cat_timestamp = FALSE, level = 1L)

  # Last day of this month: advance to the 1st of next month then subtract 1
  last_day <- as.integer(format(
    as.Date(sprintf("%04d-%02d-01", year, month %% 12L + 1L)) - 1L, "%d"))

  # Build week boundary table; W5 only exists for months with > 28 days
  week_bounds <- list(
    list(d1 = 1L, d2 = 7L),
    list(d1 = 8L, d2 = 14L),
    list(d1 = 15L, d2 = 21L),
    list(d1 = 22L, d2 = 28L))

  # Append W5 only when the month has more than 28 days
  if (last_day > 28L) {
    week_bounds <- c(week_bounds, list(list(d1 = 29L, d2 = last_day)))
  }

  n_weeks <- length(week_bounds)

  weekly_data <- purrr::map_dfr(
    .x = seq_len(n_weeks),
    .f = function(w) {
      win <- week_bounds[[w]]
      .inat_fetch_week(
        taxon_id = taxon_id, bounds = bounds, year = year, month = month,
        day_min = win$d1, day_max = win$d2,
        week_index = w, n_weeks = n_weeks,
        max_results = max_results, verbose = verbose)
    })

  weekly_data
}


# =========================================================================== #
# MAIN FUNCTION: get_inat_obs()
# =========================================================================== #

#' Retrieve iNaturalist research-grade observations
#'
#' @description Downloads all research-grade observations from the [iNaturalist
#'   API](https://api.inaturalist.org/v1/docs/) for a given taxon, spatial
#'   bounding box, and optional year and/or month filter.
#'
#' @param taxon_id `Integer`. iNaturalist taxon ID. Must be a positive integer
#'   (e.g. `47158` for *Animalia*). Find IDs at
#'   <https://www.inaturalist.org/taxa>.
#' @param bounds `Numeric`. Geographic bounding box in WGS 84 decimal degrees,
#'   specified as `c(sw_lat, sw_lng, ne_lat, ne_lng)`.
#' @param year `Integer` (optional). Four-digit calendar year to restrict the
#'   query. `NULL` retrieves records for all years (use with caution for
#'   widespread taxa --- chunking by month and then week is still applied, but
#'   run time may be very long). Default: `NULL`.
#' @param month `Integer` (optional). Calendar month to restrict the query.
#'   `NULL` iterates over all 12 months automatically. Ignored when `year =
#'   NULL`. Default: `NULL`.
#' @param max_results `Integer`. Maximum records per API window before the next
#'   chunking level is triggered. The iNaturalist API enforces a hard ceiling of
#'   10,000; increasing this value beyond 10,000 has no effect on the API but
#'   will suppress intermediate splitting. Default: `10000L`.
#' @param verbose `Logical`. Whether to print progress messages to the console.
#'   Default: `TRUE`.
#'
#' @details
#'
#' ## Chunking cascade
#'
#' The iNaturalist API silently caps every query at
#'   *10,000 records*. This function avoids silent truncation through an
#' automatic, multi-level chunking strategy:
#'
#'   - Level 1: Annual window (year filter) --- if the annual count exceeds
#' `max_results`, split by month.
#'   - Level 2: Monthly window (month filter) --- if the monthly count exceeds
#' `max_results`, split by week.
#'   - Level 3: Weekly window (day range filter) --- if the weekly count exceeds
#' `max_results`, split by day.
#'   - Level 4: Daily window (day range filter) --- if the daily count exceeds
#' `max_results`, raise an error (spatial bounds too broad).
#'
#' When `month` is supplied the cascade starts at level 2.
#'
#' ## Differences from `rinat::get_inat_obs()`
#'
#' - Uses `httr2` (retry, backoff, structured error handling) instead of
#' `httr`.
#' - Automatically handles result sets larger than 10,000 records at any
#' temporal granularity, rather than requiring the user to supply chunked
#' queries manually.
#' - Returns deduplicated results; iNaturalist's date-boundary indexing can
#' occasionally assign the same observation to two adjacent windows.
#' - Raises a structured, informative error (with metadata) instead of
#' silently truncating when the record ceiling cannot be resolved.
#' - Validates all inputs before making any network call.
#'
#' @return A deduplicated `tibble` with one row per research-grade observation
#'   and the following columns:
#' - `id`: `integer` --- unique iNaturalist observation ID
#' - `observed_on`: `character` --- ISO 8601 observation date
#' - `quality_grade`: `character` --- always `"research"` for
#'   these queries
#' - `taxon_id`: `integer` --- taxon ID of the observed organism
#' - `taxon_name`: `character` --- scientific name
#' - `latitude`: `numeric` --- decimal latitude (WGS 84)
#' - `longitude`: `numeric` --- decimal longitude (WGS 84)
#' - `place_guess`: `character` --- observer-provided locality
#' - `user_login`: `character` --- iNaturalist username
#' - `uri`: `character` --- permanent observation URL
#'
#'   An empty tibble (0 rows) is returned when no research-grade observations
#'   exist for the query.
#'
#' @export
#' @examples
#' ecokit::load_packages(purrr)
#'
#' # European bounding box
#' europe <- c(25, -30, 75, 50)
#'
#' # All research-grade observations for a taxon in one month
#' obs_jan <- get_inat_obs(
#'   taxon_id = 67835, bounds = europe, year = 2024L, month = 1L)
#' obs_jan
#'
#' # All months for one year (monthly / weekly / daily fallback automatic)
#' obs_2023 <- get_inat_obs(taxon_id = 67835, bounds = europe, year = 2023L)
#' obs_2023
#'
#' # Multi-year loop with deduplication
#' obs_multi <- purrr::map_dfr(
#'   .x = 2020:2023,
#'   .f = ~ get_inat_obs(taxon_id = 67835, bounds = europe, year = .x))  %>%
#'   dplyr::distinct(id, .keep_all = TRUE)
#' obs_multi
#'
#' @author Ahmed El-Gabbas

get_inat_obs <- function(
    taxon_id, bounds, year = NULL, month = NULL,
    max_results = 10000L, verbose = TRUE) {

  id <- NULL

  # ------------------------------------------------------------------------- #
  # Input validation
  # ------------------------------------------------------------------------- #

  # taxon_id: single positive integer
  ecokit::check_args(
    args_to_check = "taxon_id", args_type = "numeric", arg_length = 1L)

  taxon_id <- as.integer(taxon_id)
  if (is.na(taxon_id) || taxon_id <= 0L) {
    ecokit::stop_ctx(
      "`taxon_id` must be a single positive integer.",
      taxon_id = taxon_id)
  }

  # bounds: numeric vector of length 4, valid lat/lng, SW < NE
  ecokit::check_args(
    args_to_check = "bounds", args_type = "numeric", arg_length = 4L)
  if (anyNA(bounds)) {
    ecokit::stop_ctx(
      "`bounds` contains NA values. Supply c(sw_lat, sw_lng, ne_lat, ne_lng).",
      bounds = bounds)
  }
  if (bounds[1L] < -90L  || bounds[3L] > 90L) {
    ecokit::stop_ctx(
      "Latitude values in `bounds` must be in [-90, 90].",
      sw_lat = bounds[1L], ne_lat = bounds[3L])
  }
  if (bounds[2L] < -180L || bounds[4L] > 180L) {
    ecokit::stop_ctx(
      "Longitude values in `bounds` must be in [-180, 180].",
      sw_lng = bounds[2L], ne_lng = bounds[4L])
  }
  if (bounds[1L] >= bounds[3L]) {
    ecokit::stop_ctx(
      "sw_lat (bounds[1]) must be strictly less than ne_lat (bounds[3]).",
      sw_lat = bounds[1L], ne_lat = bounds[3L])
  }
  if (bounds[2L] >= bounds[4L]) {
    ecokit::stop_ctx(
      "sw_lng (bounds[2]) must be strictly less than ne_lng (bounds[4]).",
      sw_lng = bounds[2L], ne_lng = bounds[4L])
  }

  # year: single integer in [1800, current_year] or NULL
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  if (!is.null(year)) {
    ecokit::check_args(
      args_to_check = "year", args_type = "numeric", arg_length = 1L)
    year <- as.integer(year)
    if (is.na(year) || year < 1800L || year > current_year) {
      ecokit::stop_ctx(
        glue::glue(
          "`year` must be an integer between 1800 and {current_year} ",
          "(current year)."),
        year = year, current_year = current_year)
    }
  }

  # month: single integer in [1, 12] or NULL; only meaningful with year
  if (!is.null(month)) {
    ecokit::check_args(
      args_to_check = "month", args_type = "numeric", arg_length = 1L)
    month <- as.integer(month)
    if (is.na(month) || !month %in% 1L:12L) {
      ecokit::stop_ctx(
        "`month` must be an integer between 1 and 12.",
        month = month)
    }
    if (is.null(year)) {
      ecokit::stop_ctx(
        "`month` requires `year` to be specified. ",
        "Provide a four-digit integer year together with `month`.",
        month = month, year = year)
    }
  }

  # max_results: single positive integer
  ecokit::check_args(
    args_to_check = "max_results", args_type = "numeric", arg_length = 1L)
  max_results <- as.integer(max_results)
  if (is.na(max_results) || max_results <= 0L) {
    ecokit::stop_ctx(
      "`max_results` must be a single positive integer.",
      max_results = max_results)
  }
  if (max_results > 10000L) {
    message(
      "`max_results` is set above the iNaturalist API hard ceiling of 10,000. ",
      "Values above 10,000 will not reduce chunking; ",
      "the API will still cap each query at 10,000 records.")
  }

  # verbose: single logical
  ecokit::check_args(
    args_to_check = "verbose", args_type = "logical", arg_length = 1L)


  # ------------------------------------------------------------------------- #
  # Dispatch
  # ------------------------------------------------------------------------- #

  # Build a human-readable query summary for the header message
  query_summary <- glue::glue(
    "taxon_id: {taxon_id}",
    "{if (!is.null(year))  paste0(' | year: ', year)  else ''}",
    "{if (!is.null(month)) paste0(' | month: ', month) else ''}")

  ecokit::info_chunk(
    glue::glue("Querying iNaturalist\n{query_summary}"),
    cat_date = FALSE, cat_bold = TRUE, cat_red = TRUE, verbose = verbose)


  # Case 1: year = NULL --> no temporal filter applied (all-time query)
  # Warn the user because this can be extremely slow for common taxa.
  if (is.null(year)) {
    message(
      "`year` is NULL: querying without a year filter. ",
      "This may return a very large number of records and take considerable ",
      "time. Consider supplying a `year` to limit the query scope.")

    result <- .inat_fetch_window(
      taxon_id = taxon_id, bounds = bounds, year = NULL,
      window_label = glue::glue("taxon_id: {taxon_id}, all years"),
      max_results = max_results, verbose = verbose)

    n_results <- ecokit::format_number(nrow(result), underline = TRUE)
    ecokit::cat_time(
      glue::glue("Done. {n_results} unique records retrieved."),
      verbose = verbose, cat_timestamp = FALSE)

    return(result)
  }

  # Case 2: month specified --> single-month fetch (with weekly / daily
  # fallback)
  if (!is.null(month)) {
    result <- .inat_fetch_month(
      taxon_id = taxon_id, bounds = bounds,
      year = year, month = month,
      max_results = max_results, verbose = verbose)

    n_results <- ecokit::format_number(nrow(result), underline = TRUE)
    ecokit::cat_time(
      glue::glue("Done. {n_results} unique records retrieved."),
      verbose = verbose, cat_timestamp = FALSE)

    return(result)
  }


  # Case 3: year only --> try annual fetch, fall back to monthly iteration

  # Ping the full year first
  annual_ping <- .inat_fetch_page(
    taxon_id = taxon_id, bounds = bounds, year = year,
    page = 1L, per_page = 1L)

  total_annual <- annual_ping$total_results
  total_annual0 <- ecokit::format_number(total_annual, underline = TRUE)

  ecokit::cat_time(
    glue::glue("Year: {year} --- {total_annual0} records total"),
    verbose = verbose, cat_timestamp = FALSE)

  # Fast path: entire year fits within the limit
  if (total_annual == 0L) {
    ecokit::cat_time(
      "No records found for this year.",
      verbose = verbose, cat_timestamp = FALSE)
    return(tibble::tibble())
  }

  if (total_annual <= max_results) {
    result <- .inat_fetch_window(
      taxon_id = taxon_id, bounds = bounds, year = year,
      window_label = glue::glue("Year: {year}"),
      max_results = max_results,
      verbose = FALSE)  # count already printed above

    n_results <- ecokit::format_number(nrow(result), underline = TRUE)
    ecokit::cat_time(
      glue::glue("Done. {n_results} unique records retrieved."),
      verbose = verbose, cat_timestamp = FALSE)

    return(result)
  }

  # Slow path: year > limit --> iterate over 12 months
  total_annual0 <- ecokit::format_number(total_annual, underline = TRUE)
  max_results0 <- ecokit::format_number(max_results, underline = TRUE)
  ecokit::cat_time(
    glue::glue(
      "{total_annual0} records exceed the `max_results` of {max_results0}"),
    verbose = verbose, cat_timestamp = FALSE, level = 1L)
  ecokit::cat_time(
    "Iterating over 12 months",
    verbose = verbose, cat_timestamp = FALSE, level = 1L)
  ecokit::cat_time(
    "Weekly/daily fallback applied as needed",              # nolint
    verbose = verbose, cat_timestamp = FALSE, level = 1L)

  monthly_data <- purrr::map(
    .x = 1L:12L,
    .f = ~ .inat_fetch_month(
      taxon_id = taxon_id, bounds = bounds, year = year, month = .x,
      max_results = max_results, verbose = verbose))

  # Deduplicate on observation ID --- iNaturalist's date-boundary indexing can
  # occasionally assign the same observation to two adjacent windows.
  result <- dplyr::bind_rows(monthly_data) %>%
    dplyr::distinct(id, .keep_all = TRUE)

  n_results <- ecokit::format_number(nrow(result), underline = TRUE)
  ecokit::cat_time(
    glue::glue(
      "Done. {n_results} unique records retrieved across all months."),
    verbose = verbose, cat_timestamp = FALSE)

  result
}
