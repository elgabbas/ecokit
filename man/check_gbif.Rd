% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eco_check_gbif.R
\name{check_gbif}
\alias{check_gbif}
\title{Check and Load GBIF Credentials from .Renviron}
\usage{
check_gbif(r_environ = ".Renviron")
}
\arguments{
\item{r_environ}{Character string specifying the path to the \code{.Renviron} file
where GBIF credentials are stored. Defaults to \code{".Renviron"} in the current
working directory.}
}
\value{
Returns \code{NULL} invisibly if the GBIF credentials are successfully
loaded. Stops with an error if the credentials cannot be found or loaded.
}
\description{
Checks if \href{https://www.gbif.org/}{GBIF} access credentials (\code{GBIF_EMAIL},
\code{GBIF_PWD}, \code{GBIF_USER}) are available in the environment. If not, attempts
to read them from the specified \code{.Renviron} file. If the credentials are
still missing after reading the file, an error is thrown with details about
which credentials are missing.
}
\details{
This function ensures that the necessary GBIF credentials are loaded
into the R environment for accessing GBIF services, typically for using
\href{https://docs.ropensci.org/rgbif}{rgbif} R package. It first checks if the
credentials are already set as environment variables. If any are missing,
it attempts to read them from the specified \code{.Renviron} file. If the file
does not exist, is not readable, or does not contain all required
credentials, the function stops with an informative error message. Note,
however, that the function does not check if the credentials are valid or
if they work with GBIF; only that they are present in the environment.
}
\examples{
\dontrun{

  # Check GBIF credentials using the default .Renviron file
  check_gbif()

  # Specify a custom .Renviron file
  check_gbif(r_environ = "~/.Renviron")

}
}
\author{
Ahmed El-Gabbas
}
