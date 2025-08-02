## |------------------------------------------------------------------------| #
# scrape_link ----
## |------------------------------------------------------------------------| #

#' Extracts link texts and URLs from a web page
#'
#' This function scrapes a web page for all links (`<a>` tags) and extracts both
#' the URLs and the link text.
#' @param url Character. The URL of the web page to scrape. This URL is also
#'   used to resolve relative links to absolute URLs if no `<base>` tag is
#'   found.
#' @param sort_by Character vector of length 1 or 2. The columns to arrange the
#'   output by. The default is c("link", "link_text").
#' @name scrape_link
#' @return A tibble with two columns: `link_text` containing the text of each
#'   link, and `link` containing the absolute URL of each link. The tibble is
#'   sorted by link and then by link text, and only unique links are included.
#' @importFrom rlang .data
#' @examples
#'
#' head(scrape_link(url = "https://github.com/tidyverse/dplyr"))
#'
#' head(
#'   scrape_link(
#'     url = "https://github.com/tidyverse/dplyr", sort_by = "link_text"))
#'
#' # This will give an "Invalid url" error
#' \dontrun{
#'  scrape_link(url = "https://github50.com")
#' }
#' @export

scrape_link <- function(url, sort_by = c("link", "link_text")) {

  link <- link_text <- NULL

  # Ensure that sort_by is a character vector of length 1 or 2
  if (!is.character(sort_by) || length(sort_by) > 2L ||
      length(sort_by) < 1L) {
    ecokit::stop_ctx(
      "`sort_by` must be a character vector of length 1 or 2",
      sort_by = sort_by)
  }

  # Ensure that all values of sort_by are in c("link", "link_text")
  if (!all(sort_by %in% c("link", "link_text"))) {
    ecokit::stop_ctx(
      "`sort_by` must contain only 'link' and 'link_text'", sort_by = sort_by)
  }

  if (is.null(url)) {
    ecokit::stop_ctx("url cannot be NULL", url = url)
  }

  if (!is.character(url) || length(url) != 1L || !nzchar(url)) {
    ecokit::stop_ctx("url must be a single character string", url = url)
  }

  # replace spaces with %20
  if (stringr::str_detect(url, " ")) {
    url <- stringr::str_replace_all(url, " ", "%20")
  }

  if (isFALSE(ecokit::check_url(url))) {
    ecokit::stop_ctx("Invalid url", url = url)
  }

  # Create an html document from the url
  webpage <- xml2::read_html(url)

  # Extract the base URL from the <base> tag, if present
  base_url <- webpage %>%
    rvest::html_node("base") %>%
    rvest::html_attr("href")

  # If no <base> tag, use the input url as the base
  base_url <- if (is.na(base_url) || is.null(base_url)) url else base_url

  # Extract all <a> tags
  links <- rvest::html_nodes(webpage, "a")

  # Extract the URLs
  output <- purrr::map_dfr(
    .x = links,
    .f = ~ tibble::tibble(
      link = stringr::str_trim(rvest::html_attr(.x, "href")),
      link_text = stringr::str_trim(rvest::html_text(.x)))) %>%
    # Remove empty or anchor links
    dplyr::filter(
      !is.na(link) & !stringr::str_starts(link, "#"),
      link != "..", nzchar(link_text),
      !stringr::str_detect(link, "^javascript:"),
      !stringr::str_detect(link, "^mailto:"),
      !is.na(link) & nzchar(link)) %>%
    # If the link is relative, make it absolute using the base URL
    dplyr::mutate(
      link = purrr::map_chr(
        .x = link,
        .f = ~ {
          if (stringr::str_starts(.x, "http://|https://")) {
            .x
          } else {
            xml2::url_absolute(.x, base = base_url)
          }
        }),
      link = stringr::str_replace_all(link, " ", "%20"),
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
