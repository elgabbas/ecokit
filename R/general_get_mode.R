## |------------------------------------------------------------------------| #
# get_mode ----
## |------------------------------------------------------------------------| #

#' Calculate the mode of a numeric vector
#'
#' This function calculates the mode of a given numeric vector.
#'
#' @param x Numeric vector. It must not be `NULL` or empty.
#' @name get_mode
#' @source The source of this function was taken from this
#'   [link](https://www.tutorialspoint.com/r/r_mean_median_mode.htm).
#' @return The mode of the vector as a single value. If the vector has a uniform
#'   distribution (all values appear with the same frequency), the function
#'   returns the first value encountered.
#' @examples
#' get_mode(c(seq_len(10), 1, 1, 3, 3, 3, 3))
#'
#' get_mode(c(1, 2, 2, 3, 4))
#'
#' get_mode(c(1, 1, 2, 3, 3))
#' @export

get_mode <- function(x) {

  # Check if the vector is NULL or empty
  if (is.null(x) || length(x) == 0) {
    ecokit::stop_ctx("x cannot be NULL or empty", x = x)
  }

  # Extract unique values from the vector
  unique_vals <- unique(x)

  # Find the mode by identifying the most frequent unique value
  return(unique_vals[which.max(tabulate(match(x, unique_vals)))])
}
