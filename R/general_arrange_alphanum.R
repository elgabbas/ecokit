#' Arrange Dataframe Rows Alphanumerically
#'
#' Sorts the rows of a dataframe based on one or more columns using alphanumeric
#' sorting order. Allows for specifying ascending or descending order for each
#' sorting column individually.
#'
#' @param data A dataframe or tibble to be sorted.
#' @param ... Unquoted names of the columns to sort by (e.g., v1, v2, etc.)
#'   Sorting is done sequentially based on the order of columns provided.
#' @param desc Logical value or vector. If a single `TRUE`, sorts all specified
#'   columns in descending alphanumeric order. If a single `FALSE` (default),
#'   sorts all in ascending order. If a logical vector, its length must match
#'   the number of columns specified in `...`, determining the sort order for
#'   each column respectively (e.g., `c(FALSE, TRUE)` for ascending first
#'   column, descending second). `NA` values in `desc` are treated as `FALSE`
#'   (ascending). Columns must be character, numeric, or factor types for
#'   sorting.
#' @param na_last	for controlling the treatment of `NA` values. If `TRUE`,
#'   missing values in the data are put last; if `FALSE`, they are put first; if
#'   `NA`, they are removed. See [gtools::mixedsort] for more details.
#' @param blank_last for controlling the treatment of blank values. If `TRUE`,
#'   blank values in the data are put last; if `FALSE`, they are put first; if
#'   `NA`, they are removed. See [gtools::mixedsort] for more details.
#' @param scientific logical. Should exponential notation be allowed for numeric
#'   values. See [gtools::mixedsort] for more details.
#' @return A dataframe sorted according to the specified columns and orders.
#' @author Ahmed El-Gabbas
#' @importFrom rlang := !! !!!
#' @export
#' @note The `arrange_alphanum` function sorts dataframe rows alphanumerically,
#'   handling mixed numeric and character strings correctly (e.g., "A1", "A10",
#'   "A2" as "A1", "A2", "A10"), whereas [dplyr::arrange] uses standard
#'   lexicographic sorting, which may order them incorrectly (e.g., "A1", "A10",
#'   "A2").
#' @examples
#' # increase the number of printed rows
#' options(pillar.print_max = 40)
#'
#' # create a sample dataframe
#' set.seed(100)
#' (df <- tidyr::expand_grid(
#'   v1 = c("A1", "A2", "A10", "A010", "A25"),
#'   v2 = c("P1", "P2"), v3 = c(10, 5, 1, 15)) %>%
#'   dplyr::slice_sample(n = 40))
#'
#' # sort by v1 (ascending)
#' # arrange function does not sort alphanumerically
#' dplyr::arrange(df, v1)
#'
#' # arrange_alphanum function sorts alphanumerically
#' arrange_alphanum(df, v1)
#' # arrange_alphanum(df, v1, desc = FALSE)                    # the same
#' # arrange_alphanum(df, v1, desc = NA)                       # the same
#'
#' # sort first by v2 (ascending), then by v1 (ascending)
#' arrange_alphanum(df, v2, v1)
#' # arrange_alphanum(df, v2, v1, desc = FALSE)                # the same
#' # arrange_alphanum(df, v2, v1, desc = c(FALSE, FALSE))      # the same
#'
#' # sort by v2 (ascending), then v1 (descending)
#' arrange_alphanum(df, v2, v1, desc = c(FALSE, TRUE))
#'
#' # sort by v2 (descending), then v1 (ascending)
#' arrange_alphanum(df, v2, v1, desc = c(TRUE, FALSE))
#'
#' # sort by v2 (descending), v1 (descending)
#' arrange_alphanum(df, v2, v1, desc = TRUE)
#' # arrange_alphanum(df, v2, v1, desc = c(TRUE, TRUE))        # the same
#'
#' # sort by v2 (descending), v1 (ascending), v3 (descending)
#' arrange_alphanum(df, v2, v1, v3, desc = c(TRUE, FALSE, TRUE))
#'
#' # -----------------------------------------------
#'
#' # Example with NA and blank strings
#' (df_special <- tibble::tibble(v1 = c("A", "", "B", NA, "C")))
#'
#' # sort with NA first, blanks first (default)
#' arrange_alphanum(df_special, v1, na_last = FALSE, blank_last = FALSE)
#'
#' # sort with NA last, blanks last
#' arrange_alphanum(df_special, v1, na_last = TRUE, blank_last = TRUE)

arrange_alphanum <- function(
    data = NULL, ..., desc = FALSE,
    na_last = TRUE, blank_last = FALSE, scientific = TRUE) {

  # Check if data exists in the parent frame and is a dataframe
  if (!exists(deparse(substitute(data)), envir = parent.frame()) ||
      !is.data.frame(data)) {
    ecokit::stop_ctx("The 'data' argument must be a valid dataframe or tibble")
  }

  # Validate that 'desc' is a logical value or vector
  if (!is.logical(desc)) {
    ecokit::stop_ctx(
      "'desc' must be a logical value or vector.",
      class_desc = class(desc), length_desc = length(desc))
  }

  # treat NA in desc as FALSE for user convenience
  desc[is.na(desc)] <- FALSE

  # Validate gtools::mixedsort arguments
  if (!is.logical(na_last) || length(na_last) != 1L || is.na(na_last)) {
    ecokit::stop_ctx(
      "'na_last' must be a single logical value (TRUE or FALSE).",
      na_last = na_last)
  }
  if (!is.logical(blank_last) || length(blank_last) != 1L ||
      is.na(blank_last)) {
    ecokit::stop_ctx(
      "'blank_last' must be a single logical value (TRUE or FALSE).",
      blank_last = blank_last)
  }
  if (!is.logical(scientific) || length(scientific) != 1L) {
    ecokit::stop_ctx(
      "'scientific' must be a single logical value (TRUE or FALSE).",
      scientific = scientific)
  }

  # Check if dataframe is empty (no rows)
  if (nrow(data) == 0L) {
    return(data)
  }

  # Capture unquoted column names as symbols
  dots <- rlang::ensyms(...)
  # number of columns to sort by
  n_cols <- length(dots)

  # If no columns provided, return original data unchanged
  if (n_cols == 0L) {
    return(data)
  }

  # Convert column symbols to character names
  col_names <- purrr::map_chr(dots, rlang::as_string)

  # Find columns specified that are not in the dataframe
  missing_cols <- setdiff(col_names, colnames(data))

  # stop if any specified columns are missing in the original data
  if (length(missing_cols) > 0L) {
    ecokit::stop_ctx(
      paste0("Columns not found in data: ", toString(missing_cols)),
      columns = col_names, data_columns = colnames(data))
  }
  # check if columns are suitable for sorting (character, numeric, factor)
  invalid_cols <- purrr::map_lgl(
    .x = data[col_names],
    .f = function(x) {
      is.character(x) || is.numeric(x) || is.factor(x)
    })
  invalid_cols <- col_names[!invalid_cols]
  if (length(invalid_cols) > 0L) {
    ecokit::stop_ctx(
      paste0(
        "Columns must be character, numeric, or factor for sorting: ",
        toString(invalid_cols)),
      column_types = purrr::map_chr(data[invalid_cols], class))
  }


  # Check if length of 'desc' is valid (1 or matches n_cols)
  if (length(desc) != 1L && length(desc) != n_cols) {
    ecokit::stop_ctx(
      paste0("Length of 'desc' must be 1 or match number of columns"),
      length_desc = length(desc), n_cols = n_cols)
  }

  # Recycle 'desc' to match number of columns if length is 1
  if (length(desc) == 1L && n_cols > 1L) {
    desc <- rep(desc, n_cols)
  }

  # Create unique names for temporary factor columns
  # Using '..' prefix to minimize collision chance with existing column names
  factor_cols <- paste0("..sort_factor_", seq_len(n_cols))

  # Check for collisions with existing column names
  if (any(factor_cols %in% colnames(data))) {
    ecokit::stop_ctx(
      "Temporary factor column names conflict with existing columns.",
      conflicting_cols = factor_cols[factor_cols %in% colnames(data)])
  }

  # Initialize mutated data as original data for factor creation
  data_mutated <- data

  # Pre-compute unique values for each column to improve performance
  unique_vals_list <- lapply(col_names, function(col) unique(data[[col]]))

  # Iteratively add sorting factor columns using purrr::reduce
  data_mutated <- purrr::reduce(
    # Iterate over the indices of columns to sort by
    .x = seq_len(n_cols),
    .f = function(current_data_accumulator, current_col_idx) {

      # current original column name to sort by
      col_name <- col_names[current_col_idx]

      # name for the new temporary factor column
      factor_col_name <- factor_cols[current_col_idx]

      # should sort this column in descending order
      is_desc <- desc[current_col_idx]

      # Use dplyr::mutate to add the new factor column to the accumulated data
      current_data_accumulator %>%
        dplyr::mutate(

          # Create the factor column using dynamic name assignment "!!"
          !!factor_col_name := factor(
            # original column from the accumulator using .data[[col_name]]
            .data[[col_name]],
            # levels for the factor based on unique values and sort order
            levels = {
              # unique values from pre-computed list
              unique_vals <- unique_vals_list[[current_col_idx]]

              # sort non-NA values alphanumerically with gtools::mixedsort
              vals_no_na <- gtools::mixedsort(
                x = unique_vals[!is.na(unique_vals)],
                na.last = na_last, blank.last = blank_last,
                scientific = scientific)

              # reverse levels if descending order is used
              if (is_desc) {
                vals_no_na <- rev(vals_no_na)
              }

              # NA values - NA first for descending, last for ascending
              if (anyNA(unique_vals)) {
                if (is_desc) {
                  c(NA, vals_no_na)
                } else {
                  c(vals_no_na, NA)
                }
              } else {
                # Use sorted levels if no NAs are present
                vals_no_na
              }
            }))
    },
    # Start the reduction with the initial data_mutated
    .init = data_mutated)

  # sort using the temporary factor columns.
  # "!!!rlang::syms(factor_cols)" converts strings to symbols and unquotes them
  data_sorted <- dplyr::arrange(data_mutated, !!!rlang::syms(factor_cols))

  # remove temporary factor columns, keeping original structure
  dplyr::select(data_sorted, -tidyselect::all_of(factor_cols))
}
