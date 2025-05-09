## |------------------------------------------------------------------------| #
# check_url ----
## |------------------------------------------------------------------------| #

#' Check the validity of a URL
#'
#' This function opens a connection to the specified URL to check its validity.
#' It returns `TRUE` if the URL is valid (i.e., the connection can be opened),
#' and `FALSE` otherwise.
#' @param url Character. The URL to be checked.
#' @param timeout Numeric. Timeout in seconds for the connection attempt.
#'   Default is 2 seconds.
#' @name check_url
#' @source The source code of this function was taken from this
#'   [stackoverflow](https://stackoverflow.com/q/52911812) discussion.
#' @return A logical value: `TRUE` if the URL is valid, `FALSE` if not.
#' @examples
#' load_packages(purrr, tibble)
#'
#' urls <- c(
#'      "http://www.amazon.com", "http://this.isafakelink.biz",
#'      "https://stackoverflow.com", "https://stackoverflow505.com")
#' purrr::map_dfr(urls, ~tibble::tibble(URL = .x, Valid = check_url(.x)))
#' @export

check_url <- function(url, timeout = 2L) {

  if (is.null(url)) {
    ecokit::stop_ctx("url cannot be NULL", url = url)
  }

  con <- url(url)
  check <- suppressWarnings(
    try(
      open.connection(con, open = "rt", timeout = timeout), silent = TRUE)[1L])

  suppressWarnings(try(close.connection(con), silent = TRUE))

  return(is.null(check))
}
