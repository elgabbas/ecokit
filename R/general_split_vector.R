## |------------------------------------------------------------------------| #
# split_vector ----
## |------------------------------------------------------------------------| #

#' Split a vector into smaller chunks
#'
#' This function divides a given vector into a specified number of smaller
#' chunks. It is useful for partitioning data into more manageable pieces or for
#' parallel processing tasks.
#' @param vector A numeric or character vector that you want to split.
#' @param n_splits Integer. Number of chunks to split the vector into. It must
#'   not exceed the length of the vector.
#' @param prefix Character. prefix for the names of the chunks in the returned
#'   list. Defaults to `"Chunk"`.
#' @name split_vector
#' @author Ahmed El-Gabbas
#' @return A list of vectors, where each vector represents a chunk of the
#'   original vector. The names of the list elements are generated using the
#'   specified prefix followed by an underscore and the chunk number.
#' @examples
#' split_vector(vector = seq_len(100), n_splits = 3)
#'
#' # -------------------------------------------
#'
#' split_vector(vector = seq_len(100), n_splits = 2, prefix = "T")
#'
#' @export

split_vector <- function(vector = NULL, n_splits = NULL, prefix = "Chunk") {

  if (is.null(vector) || is.null(n_splits)) {
    ecokit::stop_ctx(
      "`vector` and `n_splits` cannot be NULL",
      vector = vector, n_splits = n_splits)
  }

  if (n_splits > length(vector)) {
    ecokit::stop_ctx(
      "`n_splits` cannot be greater than the length of vector",
      vector = vector, n_splits = n_splits)
  }

  output <- split(
    vector,
    cut(seq_along(vector), breaks = n_splits,
        labels = paste0(prefix, "_", seq_len(n_splits)),
        include.lowest = TRUE))

  return(output)
}
