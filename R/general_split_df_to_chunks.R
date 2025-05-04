## |------------------------------------------------------------------------| #
# split_df_to_chunks ----
## |------------------------------------------------------------------------| #

#' Split a data.frame into smaller chunks
#'
#' This function divides a data.frame into smaller chunks based on the specified
#' number of rows per chunk (`chunk_size`) or the specified number of chunks
#' (`n_chunks`). If neither is provided, it defaults to splitting the data.frame
#' into  a minimum of 5 chunks or less if the data.frame has fewer than 5 rows.
#' The function ensures that the data is evenly distributed among the chunks as
#' much as possible.
#' @param data `data.frame`. The data.frame to be split into chunks.
#' @param chunk_size Integer. Number of rows each chunk should contain. It must
#'   be a positive integer and less than the number of rows in `data`.
#' @param n_chunks Integer. Number of chunks to split the data.frame into. It
#'   must be a positive integer.
#' @param prefix Character. Prefix for the names of the chunks. Default is
#'   "Chunk".
#' @name split_df_to_chunks
#' @author Ahmed El-Gabbas
#' @return A list of data.frames, where each data.frame represents a chunk of
#'   the original data.frame. The names of the list elements are constructed
#'   using the `prefix` parameter followed by an underscore and the chunk number
#'   (e.g., "Chunk_1", "Chunk_2", ...).
#' @export
#' @examples
#' split_df_to_chunks(mtcars, chunk_size = 16)
#'
#' # -------------------------------------------
#'
#' split_df_to_chunks(mtcars, n_chunks = 3)
#'
#' # -------------------------------------------
#'
#' split_df_to_chunks(mtcars, n_chunks = 3, prefix = "T")

split_df_to_chunks <- function(
    data = NULL, chunk_size = NULL, n_chunks = NULL, prefix = "Chunk") {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL", data = data)
  }

  if (!is.null(chunk_size) && (chunk_size < 1 || !is.numeric(chunk_size))) {
    ecokit::stop_ctx(
      "`chunk_size` must be numeric and larger than 1", chunk_size = chunk_size)
  }

  if (is.null(chunk_size) && is.null(n_chunks)) {
    n_chunks <- min(5, nrow(data))
    cat(paste0(crayon::green(
      paste0(
        "`chunk_size` and `n_chunks` are not determined by user. ",
        "Defaulting to split into ")), n_chunks, " chunks.\n"))
  }

  if (!is.null(chunk_size) && nrow(data) <= chunk_size) {
    ecokit::stop_ctx(
      paste0(
        "`chunk_size` is larger than the number of rows in the data ",
        "frame!\nPlease use a smaller chunk_size."),
      chunk_size = chunk_size, nrow_data = nrow(data))
  }

  if (is.null(chunk_size)) {
    chunk_size <- ceiling(nrow(data) / n_chunks)
  }

  data <- tibble::as_tibble(data)
  output <- split(data, (seq_len(nrow(data)) - 1) %/% chunk_size)
  names(output) <- paste0(prefix, "_", seq_along(output))

  return(output)
}
