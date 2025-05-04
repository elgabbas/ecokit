## |------------------------------------------------------------------------| #
# scrape_link ----
## |------------------------------------------------------------------------| #

#' Extracts link texts and URLs from a web page
#'
#' This function scrapes a web page for all links (`<a>` tags) and extracts both
#' the URLs and the link text.
#' @param URL Character. The URL of the web page to scrape. This URL is also
#'   used to resolve relative links to absolute URLs.
#' @param sort_by Character vector of length 1 or 2. The columns to arrange the
#'   output by. The default is c("link", "link_text"). The first column is the
#'   URL of the link, and the second column is the text of the link. The
#'   function will arrange the output in ascending order by the column(s)
#'   specified in this argument.
#' @name scrape_link
#' @return A tibble with two columns: `link_text` containing the text of each
#'   link, and `URL` containing  the absolute URL of each link. The tibble is
#'   sorted by URL and then by link text, and only unique links are included.
#' @importFrom rlang .data
#' @examples
#'
#' head(
#' scrape_link(URL = "https://github.com/tidyverse/dplyr"))
#'
#' head(
#'   scrape_link(
#'     URL = "https://github.com/tidyverse/dplyr", sort_by = "link_text"))
#'
#' # This will give an "Invalid URL" error
#' \dontrun{
#'  scrape_link(URL = "https://github50.com")
#' }
#' @export

scrape_link <- function(URL, sort_by = c("link", "link_text")) {

  link <- link_text <- NULL

  # Ensure that sort_by is a character vector of length 1 or 2
  if (!is.character(sort_by) || length(sort_by) > 2 ||
      length(sort_by) < 1) {
    ecokit::stop_ctx(
      "`sort_by` must be a character vector of length 1 or 2",
      sort_by = sort_by)
  }

  # Ensure that all values of sort_by are in c("link", "link_text")
  if (!all(sort_by %in% c("link", "link_text"))) {
    ecokit::stop_ctx(
      "`sort_by` must contain only 'link' and 'link_text'", sort_by = sort_by)
  }

  if (is.null(URL)) {
    ecokit::stop_ctx("URL cannot be NULL", URL = URL)
  }

  if (isFALSE(ecokit::check_URL(URL))) {
    ecokit::stop_ctx("Invalid URL", URL = URL)
  }

  # Create an html document from the URL
  webpage <- xml2::read_html(URL) %>%
    rvest::html_nodes("a")

  # Extract the URLs
  output <- purrr::map(
    .x = webpage,
    .f = ~ tibble::tibble(
      link = stringr::str_trim(rvest::html_attr(.x, "href")),
      link_text = stringr::str_trim(rvest::html_text(.x)))) %>%
    dplyr::bind_rows() %>%
    # Remove empty or anchor links
    dplyr::filter(
      !is.na(link) & !stringr::str_starts(link, "#"),
      link != "..", nzchar(link_text)) %>%
    dplyr::mutate(
      link = dplyr::if_else(
        stringr::str_starts(link, "http"), link,
        ecokit::path(
          stringr::str_remove(URL, "/$"), stringr::str_remove(link, "^/")
        )),

      link_text = {
        stringr::str_remove_all(link_text, "\n") %>%
          stringr::str_replace_all("\\s+", " ") %>%
          stringr::str_trim()
      }) %>%
    dplyr::distinct() %>%
    dplyr::select(link_text, link) %>%
    dplyr::arrange(dplyr::across(tidyselect::all_of(sort_by)))

  return(output)
}
