% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_check_url.R
\name{check_url}
\alias{check_url}
\title{Check the validity of a URL}
\source{
The source code of this function was taken from this
\href{https://stackoverflow.com/q/52911812}{stackoverflow} discussion.
}
\usage{
check_url(url, timeout = 2L)
}
\arguments{
\item{url}{Character. The URL to be checked.}

\item{timeout}{Numeric. Timeout in seconds for the connection attempt.
Default is 2 seconds.}
}
\value{
A logical value: \code{TRUE} if the URL is valid, \code{FALSE} if not.
}
\description{
This function opens a connection to the specified URL to check its validity.
It returns \code{TRUE} if the URL is valid (i.e., the connection can be opened),
and \code{FALSE} otherwise.
}
\examples{
load_packages(purrr, tibble)

urls <- c(
     "http://www.amazon.com", "http://this.isafakelink.biz",
     "https://stackoverflow.com", "https://stackoverflow505.com")
purrr::map_dfr(urls, ~tibble::tibble(URL = .x, Valid = check_url(.x)))
}
