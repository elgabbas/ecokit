% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_split_df_to_chunks.R
\name{split_df_to_chunks}
\alias{split_df_to_chunks}
\title{Split a data.frame into smaller chunks}
\usage{
split_df_to_chunks(
  data = NULL,
  chunk_size = NULL,
  n_chunks = NULL,
  prefix = "Chunk"
)
}
\arguments{
\item{data}{\code{data.frame}. The data.frame to be split into chunks.}

\item{chunk_size}{Integer. Number of rows each chunk should contain. It must
be a positive integer and less than the number of rows in \code{data}.}

\item{n_chunks}{Integer. Number of chunks to split the data.frame into. It
must be a positive integer.}

\item{prefix}{Character. Prefix for the names of the chunks. Default is
"Chunk".}
}
\value{
A list of data.frames, where each data.frame represents a chunk of
the original data.frame. The names of the list elements are constructed
using the \code{prefix} parameter followed by an underscore and the chunk number
(e.g., "Chunk_1", "Chunk_2", ...).
}
\description{
This function divides a data.frame into smaller chunks based on the specified
number of rows per chunk (\code{chunk_size}) or the specified number of chunks
(\code{n_chunks}). If neither is provided, it defaults to splitting the data.frame
into  a minimum of 5 chunks or less if the data.frame has fewer than 5 rows.
The function ensures that the data is evenly distributed among the chunks as
much as possible.
}
\examples{
split_df_to_chunks(mtcars, chunk_size = 16)

# -------------------------------------------

split_df_to_chunks(mtcars, n_chunks = 3)

# -------------------------------------------

split_df_to_chunks(mtcars, n_chunks = 3, prefix = "T")
}
\author{
Ahmed El-Gabbas
}
