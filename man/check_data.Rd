% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_check_data.R
\name{check_data}
\alias{check_data}
\alias{check_rdata}
\alias{check_qs}
\alias{check_rds}
\alias{check_feather}
\title{Check Integrity of Data Files}
\usage{
check_data(file = NULL, warning = TRUE, n_threads = 1L)

check_rdata(file, warning = TRUE)

check_qs(file, warning = TRUE, n_threads = 1L)

check_rds(file, warning = TRUE)

check_feather(file, warning = TRUE)
}
\arguments{
\item{file}{Character. Path to a data file (e.g., \code{.rdata}, \code{.qs2}, \code{.rds},
\code{.feather}). Must be a single, non-empty string.}

\item{warning}{Logical. If \code{TRUE} (default), warnings are issued for invalid
files (e.g., non-existent, wrong extension, or loading failure).}

\item{n_threads}{Integer. Number of threads for reading \code{qs2} files. Must be
a positive integer. See \link[qs2:qs_read]{qs2::qs_read} for more details.}
}
\value{
Logical: \code{TRUE} if the file is valid and loads successfully; \code{FALSE}
otherwise, with a warning if \code{warning = TRUE}.
}
\description{
Validates a data file by checking its extension and attempting to load its
contents. A file is considered valid if it exists, is non-empty, has a
supported extension, and loads successfully with a non-null object. Supports
\code{RData}, \code{qs2}, \code{rds}, and \code{feather} file types.
}
\details{
The \code{check_data()} function determines the file type based on its
extension (case-insensitive). If the extension is unrecognised, it returns
\code{FALSE}. Supported file types:
\itemize{
\item \strong{RData}: Checked with \code{check_rdata()}, read using \link{load_as}
\item \strong{qs2}: Checked with \code{check_qs()}, read using \link[qs2:qs_read]{qs2::qs_read}
\item \strong{rds}: Checked with \code{check_rds()}, read using \link{readRDS}
\item \strong{feather}: Checked with \code{check_feather()}, read using
\link[arrow:read_feather]{arrow::read_feather}
}
}
\examples{

# Setup temporary directory
temp_dir <- fs::path_temp("load_multiple")
fs::dir_create(temp_dir)

# |||||||||||||||||||||||||||||||||||||||
# Validate RData files
# |||||||||||||||||||||||||||||||||||||||

# valid RData file
data <- data.frame(x = 1:5)
rdata_file <- fs::path(temp_dir, "valid.Rdata")
save(data, file = rdata_file)

# Invalid RData file (corrupted)
bad_rdata <- fs::path(temp_dir, "invalid.Rdata")
writeLines("not an RData file", bad_rdata)

check_data(rdata_file)                               # TRUE
check_rdata(rdata_file)                              # TRUE

check_data(bad_rdata)                                # FALSE, with warning
check_rdata(bad_rdata)                               # FALSE, with warning

check_data(bad_rdata, warning = FALSE)               # FALSE, no warning
check_rdata(bad_rdata, warning = FALSE)              # FALSE, no warning

# |||||||||||||||||||||||||||||||||||||||
# Validate qs2 files
# |||||||||||||||||||||||||||||||||||||||

# Valid qs2 file
qs_file <- fs::path(temp_dir, "valid.qs2")
qs2::qs_save(data, qs_file, nthreads = 1)

# Invalid qs2 file (corrupted)
bad_qs <- fs::path(temp_dir, "invalid.qs2")
writeLines("not a qs2 file", bad_qs)

check_data(qs_file, n_threads = 1L)                  # TRUE
check_qs(qs_file, n_threads = 1L)                    # TRUE

check_data(bad_qs, n_threads = 1L)                   # FALSE, with warning
check_qs(bad_qs, n_threads = 1L)                     # FALSE, with warning

# |||||||||||||||||||||||||||||||||||||||
# Validate rds files
# |||||||||||||||||||||||||||||||||||||||

# Valid rds file
rds_file <- fs::path(temp_dir, "valid.rds")
saveRDS(data, rds_file)

# Invalid rds file (corrupted)
bad_rds <- fs::path(temp_dir, "invalid.rds")
writeLines("not an rds file", bad_rds)

check_data(rds_file)                                 # TRUE
check_rds(rds_file)                                  # TRUE

check_data(bad_rds)                                  # FALSE, with warning
check_rds(bad_rds)                                   # FALSE, with warning

# |||||||||||||||||||||||||||||||||||||||
# Validate feather files
# |||||||||||||||||||||||||||||||||||||||

# Valid feather file
feather_file <- fs::path(temp_dir, "valid.feather")
arrow::write_feather(data, feather_file)

# Invalid feather file (corrupted)
bad_feather <- fs::path(temp_dir, "invalid.feather")
writeLines("not a feather file", bad_feather)

check_data(feather_file)                             # TRUE
check_feather(feather_file)                          # TRUE

check_data(bad_feather)                              # FALSE, with warning
check_feather(bad_feather)                           # FALSE, with warning

# |||||||||||||||||||||||||||||||||||||||
# Non-existent file
# |||||||||||||||||||||||||||||||||||||||

check_data("nonexistent.rds")                        # FALSE, with warning

# Clean up
fs::file_delete(
  c(rdata_file, bad_rdata, qs_file, bad_qs, rds_file, bad_rds,
  feather_file, bad_feather))
fs::dir_delete(temp_dir)
}
\author{
Ahmed El-Gabbas
}
