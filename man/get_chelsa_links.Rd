% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eco_get_chelsa_links.R
\name{get_chelsa_links}
\alias{get_chelsa_links}
\title{Retrieve CHELSA Data Links}
\usage{
get_chelsa_links(base_url = "https://os.zhdk.cloud.switch.ch/chelsav2/")
}
\arguments{
\item{base_url}{Base URL of the CHELSA repository. Defaults to
"https://os.zhdk.cloud.switch.ch/chelsav2/".}
}
\value{
A tibble with the following columns:
\itemize{
\item \code{url} (character): Full URL of the data file.
\item \code{relative_url} (character): Relative URL, excluding the base URL.
\item \code{file_name} (character): Name of the data file.
\item \code{dir_name} (character): Directory path of the file.
\item \code{climate_scenario} (character): Climate scenario. Values are: "current",
"ssp126", "ssp370", and "ssp585".
\item \code{climate_model} (character): Climate model. Values are: "Current",
"GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", and
"UKESM1-0-LL".
\item \code{year} (character): Year range. Values are "1981-2010", "2011-2040",
"2041-2070", and "2071-2100".
\item \code{var_name} (character): Variable name, e.g., "bio1".
\item \code{long_name} (character): Full variable name, e.g., "mean annual air
temperature".
\item \code{unit} (character): Measurement unit, e.g., "°C".
\item \code{scale} (numeric): Scale factor for the variable.
\item \code{offset} (numeric): Offset value for the variable.
\item \code{explanation} (character): Brief description of the variable.
}
}
\description{
Fetches links to \href{https://chelsa-climate.org/}{CHELSA} climate data files
from a specified base URL, filters them to include only links for *.tif files
for variables available under current and future climate scenarios, and
extracts metadata to create a tibble with detailed file information.
}
\examples{
library(tibble)
library(dplyr)
library(ecokit)
options(pillar.print_max = 64)

CHELSA_links <- ecokit::get_chelsa_links()

dplyr::glimpse(CHELSA_links)

# Count the number of files per climate scenario, model, and year
dplyr::count(CHELSA_links, climate_scenario, climate_model, year)

CHELSA_links \%>\%
  dplyr::count(var_name, long_name, unit, scale, offset, explanation)

print(CHELSA_links, n = 200)

}
\author{
Ahmed El-Gabbas
}
