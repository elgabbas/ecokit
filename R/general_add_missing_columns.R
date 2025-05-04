## |------------------------------------------------------------------------| #
# add_missing_columns ----
## |------------------------------------------------------------------------| #

#' Add missing columns to a data frame with specified fill values
#'
#' This function checks a data frame for missing columns specified by the user.
#' If any are missing, it adds these columns to the data frame, filling them
#' with a specified value.
#'
#' @name add_missing_columns
#' @author Ahmed El-Gabbas
#' @param data A data frame to which missing columns will be added. This
#'   parameter cannot be NULL.
#' @param fill_value The value to fill the missing columns with. This parameter
#'   defaults to `NA_character_`, but can be changed to any scalar value as
#'   required.
#' @param ... Column names as character strings.
#' @return a data frame with the missing columns added, if any were missing.
#' @export
#' @examples
#'
#' mtcars2 <- dplyr::select(mtcars, seq_len(3)) %>%
#'   head() %>%
#'   tibble::as_tibble()
#'
#' mtcars2
#'
#' # -------------------------------------------
#'
#' mtcars2 %>%
#'  add_missing_columns(fill_value = NA_character_, A, B, C) %>%
#'  add_missing_columns(fill_value = as.integer(10), D)
#'
#' # -------------------------------------------
#'
#' AddCols <- c("Add1", "Add2")
#' mtcars2 %>%
#'  add_missing_columns(fill_value = NA_real_, AddCols)

add_missing_columns <- function(data, fill_value = NA_character_, ...) {

  if (is.null(data) || is.null(fill_value)) {
    ecokit::stop_ctx(
      "data can not be NULL", fill_value = fill_value, data = data)
  }

  columns <- as.character(rlang::ensyms(...))

  if (any(columns %in% ls(envir = parent.env(rlang::caller_env())))) {
    columns <- get(columns, envir = parent.env(rlang::caller_env()))
  }

  columns_to_dd <- setdiff(columns, names(data))

  add_data <- rep(fill_value, length(columns_to_dd)) %>%
    matrix(nrow = 1) %>%
    as.data.frame() %>%
    stats::setNames(columns_to_dd) %>%
    tibble::as_tibble()

  if (length(columns_to_dd) != 0) {
    data <- tibble::add_column(data, !!!add_data) %>%
      tibble::tibble()
  }
  return(data)
}
