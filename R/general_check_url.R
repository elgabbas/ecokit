## |------------------------------------------------------------------------| #
# check_url ----
## |------------------------------------------------------------------------| #

#' Check the validity of URLs
#'
#' This function opens a connection to the specified URLs to check their
#'  validity.
#' @param url Character. The URLs to be checked.
#' @param timeout Numeric. Timeout in seconds for the connection attempt.
#'   Default is 2 seconds.
#' @param all_okay Logical. If `TRUE` (default), returns a single logical output
#'   indicating the validity of all URLs; if `FALSE`, returns a logical vector
#'   for each URL.
#' @name check_url
#' @source The source code of this function was taken from this
#'   [stackoverflow](https://stackoverflow.com/q/52911812) discussion.
#' @return Logical: `TRUE` if all checks pass; `FALSE` otherwise.
#' @examples
#' urls <- c(
#'      "http://www.amazon.com", "http://this.isafakelink.biz",
#'      "https://stackoverflow.com", "https://stackoverflow505.com")
#' check_url(urls)
#' check_url(urls, all_okay = FALSE)
#' @export

check_url <- function(url = NULL, timeout = 2L, all_okay = TRUE) {

  if (is.null(url)) {
    ecokit::stop_ctx("url cannot be NULL", url = url)
  }

  if (!is.numeric(timeout) || timeout < 1L) {
    ecokit::stop_ctx("`timeout` must be a positive integer", timeout = timeout)
  }
  if (!is.logical(all_okay) || length(all_okay) != 1L) {
    ecokit::stop_ctx(
      "`all_okay` must be a single logical value", all_okay = all_okay)
  }

  purrr::walk(
    .x = url,
    .f = ~{
      if (!is.character(.x) || length(.x) != 1L || !nzchar(.x)) {
        ecokit::stop_ctx("`url` must be a character string", url = .x)
      }
    })

  urls_check <- purrr::map_lgl(
    .x = url,
    .f = ~{

      # replace spaces with %20
      url_internal <- .x
      if (stringr::str_detect(url_internal, " ")) {
        url_internal <- stringr::str_replace_all(url_internal, " ", "%20")
      }

      con <- url(url_internal)
      check <- suppressWarnings(
        try(
          open.connection(
            con, open = "rt", timeout = timeout), silent = TRUE)[1L])

      suppressWarnings(try(close.connection(con), silent = TRUE))
      return(is.null(check))
    })

  if (all_okay) urls_check <- all(urls_check)

  return(urls_check)

}
