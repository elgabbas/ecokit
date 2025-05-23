% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_load_multiple.R
\name{load_multiple}
\alias{load_multiple}
\title{Load multiple data files together}
\usage{
load_multiple(
  files = NULL,
  verbose = TRUE,
  single_object = TRUE,
  return_names = TRUE,
  n_threads = 1L,
  conflict = c("skip", "overwrite", "rename"),
  environment = .GlobalEnv
)
}
\arguments{
\item{files}{Character vector. Paths to \code{.RData}, \code{.rds}, \code{.qs2}, or
\code{.feather} files to be loaded.}

\item{verbose}{Logical. Whether to print progress messages. Default: \code{TRUE}.}

\item{single_object}{Logical. Whether to load all objects into a single list
(\code{TRUE}) or directly into the specified environment (\code{FALSE}). Defaults to
\code{TRUE}.}

\item{return_names}{Logical. Whether to return the names of the loaded
objects. Defaults to \code{TRUE}. Only effective when \code{single_object} is
\code{FALSE}.}

\item{n_threads}{Integer. Number of threads for reading \code{.qs2} files. Must be
a positive integer. See \link[qs2:qs_read]{qs2::qs_read} and \link{load_as} for more
details.}

\item{conflict}{Character. Strategy for handling naming conflicts when
\code{single_object = FALSE}: \code{"skip"} (default, skip conflicting files),
\code{"overwrite"} (replace existing objects), or \code{"rename"} (append a suffix to
new objects).}

\item{environment}{Environment. The environment where objects are loaded when
\code{single_object} is \code{FALSE}. Defaults to \code{.GlobalEnv}.}
}
\value{
If \code{single_object} is \code{TRUE}, returns a named list of objects loaded
from the specified files (with \code{NULL} for failed loads). If \code{single_object}
is \code{FALSE} and \code{return_names} is \code{TRUE}, returns a character vector of the
names of the objects loaded into the environment. Otherwise, returns
\code{NULL}.
}
\description{
This function loads multiple data files either into a single list object or
directly into the specified environment. It provides options for verbosity,
returning object names, and handling of non-existent files. Supported data
files include: \code{.RData}, \code{.rds}, \code{.qs2}, and \code{.feather}.
}
\note{
For \code{.RData} files containing multiple objects, the function loads each
object individually and applies the \code{conflict} strategy to each.
Non-conflicting objects retain their original names in \code{rename} mode.
}
\examples{
ecokit::load_packages(qs2, arrow, fs, terra, dplyr)

# ---------------------------------------------------
# Create sample data files
# ---------------------------------------------------

# Setup temporary directory
temp_dir <- fs::path_temp("load_multiple")
fs::dir_create(temp_dir)

# Create sample data files
data1 <- terra::wrap(terra::rast(matrix(1:16, nrow = 4)))
data2 <- matrix(1:9, nrow = 3)
data3 <- list(a = 1:10, b = letters[1:5])
data4 <- data.frame(x = 1:5)

save(data1, file = fs::path(temp_dir, "data1.RData"))
saveRDS(data2, file = fs::path(temp_dir, "data2.rds"))
qs2::qs_save(data3, file = fs::path(temp_dir, "data3.qs2"), nthreads = 1)
arrow::write_feather(
  as.data.frame(data4), sink = fs::path(temp_dir, "data4.feather"))

files <- fs::path(
  temp_dir, c("data1.RData", "data2.rds", "data3.qs2", "data4.feather"))
basename(files)

# Create a specific environment for examples
example_env <- new.env()

# ---------------------------------------------------
# Load mixed data files to one list object
# `single_object = TRUE`
# ---------------------------------------------------

MultiObj <- load_multiple(files = files, single_object = TRUE, n_threads = 1)
str(MultiObj, 1)

# ---------------------------------------------------
# Load mixed data files separately to the specific environment
# `single_object = FALSE`, skip conflicts
# ---------------------------------------------------

# Remove any existing objects in example_env
rm(list = ls(envir = example_env), envir = example_env)

# Create conflicting object in example_env
assign("data2", "conflict", envir = example_env)
load_multiple(
  files = files, single_object = FALSE, conflict = "skip",
  environment = example_env, n_threads = 1)
ls(envir = example_env)

str(get("data1", envir = example_env), 1)
str(get("data2", envir = example_env), 1)
str(get("data3", envir = example_env), 1)
str(get("data4", envir = example_env), 1)

# ---------------------------------------------------
# Load mixed data files, overwrite conflicts
# `single_object = FALSE`, overwrite
# ---------------------------------------------------

# Remove specific objects from example_env
rm(list = c("data1", "data3", "data4"), envir = example_env)
ls(envir = example_env)

load_multiple(
  files = files, single_object = FALSE, conflict = "overwrite",
  environment = example_env, n_threads = 1)
ls(envir = example_env)

str(get("data1", envir = example_env), 1)
str(get("data2", envir = example_env), 1)
str(get("data3", envir = example_env), 1)
str(get("data4", envir = example_env), 1)

# ---------------------------------------------------
# Load mixed data files, rename conflicts
# `single_object = FALSE`, rename
# ---------------------------------------------------

# Remove specific objects from example_env
rm(list = c("data1", "data3", "data4"), envir = example_env)
ls(envir = example_env)

# Create conflicting object in example_env
assign("data2", 1:10, envir = example_env)

load_multiple(
  files = files, single_object = FALSE, conflict = "rename",
  environment = example_env, n_threads = 1)
ls(envir = example_env)

str(get("data1", envir = example_env), 1)
str(get("data2", envir = example_env), 1)
str(get("data2_new", envir = example_env), 1)
str(get("data3", envir = example_env), 1)
str(get("data4", envir = example_env), 1)

# Clean up
fs::file_delete(files)
fs::dir_delete(temp_dir)
rm(example_env)
}
\author{
Ahmed El-Gabbas
}
