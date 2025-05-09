## |------------------------------------------------------------------------| #
# assign_env_vars ------
## |------------------------------------------------------------------------| #

#' Assign environment variables from a .env file
#'
#' Reads environment variables from a `.env` file and assigns them to R
#' variables based on a data frame specifying variable names, environment
#' variable keys, and optional directory or file checks. Facilitates structured
#' management of environment variables.
#'
#' @name assign_env_vars
#' @param env_file Character. Path to a environment file containing key-value
#'   pairs (e.g., `KEY=VALUE`). Defaults to `.env`.
#' @param env_variables_data `data.frame`. A data frame or tibble with columns
#'   `var_name` (character, R variable name), `value` (character, environment
#'   variable key in `.env`), `check_dir` (logical, check if value is a
#'   directory), and `check_file` (logical, check if value is a file). Each row
#'   defines a variable to assign with optional validation.
#' @author Ahmed El-Gabbas
#' @export
#' @return Returns `invisible(NULL)`. Used for its side effect of assigning
#'   variables from the `.env` file to `envir` based on `env_variables_data`.
#' @note The `.env` file must contain key-value pairs (e.g.,
#'   `DATA_PATH=/path/to/data`). `var_name` must start with a letter and contain
#'   only letters, numbers, dots, or underscores. Only one of `check_dir` or
#'   `check_file` can be `TRUE` per row.
#' @examples
#' load_packages(tibble, dplyr, fs)
#'
#' # Create a temporary file and directory
#' tmp_dir <- ecokit::normalize_path(tempdir())
#' fs::dir_create(tmp_dir)
#' tmp_file <- ecokit::normalize_path(tempfile(fileext = ".txt"))
#' fs::file_create(tmp_file)
#'
#' # Create a minimal .env file
#' tmp_env_file <- tempfile(fileext = ".env")
#' c(paste0("MY_FILE=", tmp_file), paste0("MY_DIR=", tmp_dir)) %>%
#'   writeLines(tmp_env_file)
#' rm(tmp_dir, tmp_file, envir = environment())
#'
#' # contents of the .env file
#' readLines(tmp_env_file)
#'
#' # Define simple environment variables data
#' (env_vars <- tibble::tibble(
#'   var_name = c("my_file", "my_dir"),
#'   value = c("MY_FILE", "MY_DIR"),
#'   check_dir = c(FALSE, TRUE),
#'   check_file = c(TRUE, FALSE)))
#'
#' ls()
#'
#' # Assign environment variables
#' assign_env_vars(env_file = tmp_env_file, env_variables_data = env_vars)
#' ls()
#'
#' # Verify
#' my_file
#' my_dir
#'
#' # clean up
#' unlink(c(my_file, my_dir, tmp_env_file))

assign_env_vars <- function(env_file = ".env", env_variables_data = NULL) {

  var_name <- value <- cols <- classes <- data_class <- n <- NULL

  # # |||||||||||||||||||||||||||||||||||||||||||||||
  # env_file validation                         #####
  # # |||||||||||||||||||||||||||||||||||||||||||||||

  if (is.null(env_file) || !is.character(env_file) ||
      length(env_file) != 1L || !nzchar(env_file)) {
    ecokit::stop_ctx(
      "`env_file` must be a single non-empty character string",
      env_file = env_file)
  }

  # check that env_file exists
  if (!file.exists(env_file)) {
    ecokit::stop_ctx("`env_file` does not exist", env_file = env_file)
  }

  # # |||||||||||||||||||||||||||||||||||||||||||||||
  # env_variables_data validation               #####
  # # |||||||||||||||||||||||||||||||||||||||||||||||

  # env_variables_data can not be NULL
  if (is.null(env_variables_data)) {
    ecokit::stop_ctx(
      "`env_variables_data` cannot be NULL",
      env_variables_data = env_variables_data)
  }

  if (!inherits(env_variables_data, "data.frame")) {
    ecokit::stop_ctx(
      "`env_variables_data` must be a data frame or tibble",
      env_variables_data = env_variables_data,
      class_env_variables_data = class(env_variables_data))
  }

  # check if env_variables_data is empty
  if (nrow(env_variables_data) == 0L) {
    ecokit::stop_ctx(
      "`env_variables_data` must have at least one row",
      env_variables_data = env_variables_data)
  }

  # required columns and classes
  required_info <- tibble::tibble(
    cols = c("var_name", "value", "check_dir", "check_file"),
    classes = c("character", "character", "logical", "logical"))

  # Validate env_variables_data columns
  missing_cols <- setdiff(required_info$cols, names(env_variables_data))
  if (length(missing_cols) > 0L) {
    ecokit::stop_ctx(
      paste0(
        "Missing column(s) in `env_variables_data`: ", toString(missing_cols)),
      missing_cols = missing_cols)
  }

  # select only the required columns and remove duplicated rows
  env_data <- env_variables_data %>%
    dplyr::select(tidyselect::all_of(required_info$cols)) %>%
    # remove duplicates in these columns
    dplyr::distinct()

  # validate column types
  required_info <- required_info %>%
    dplyr::mutate(
      data_class = purrr::map2_lgl(
        .x = cols, .y = classes, .f = ~ !inherits(env_data[[.x]], .y))) %>%
    dplyr::filter(data_class)
  if (nrow(required_info) > 0L) {
    ecokit::stop_ctx(
      paste0(
        "The following columns are not of the expected class: ",
        toString(required_info$cols)),
      var_name = required_info$cols, var_class = required_info$classes)
  }

  # check if var_name are value columns are unique
  dup <- dplyr::count(env_data, var_name, value) %>%
    dplyr::filter(n > 1L)

  if (nrow(dup) > 0L) {
    ecokit::stop_ctx(
      "`var_name` and `value` must be unique",
      dup_names = dup$var_name, dup_values = dup$value)
  }

  # # |||||||||||||||||||||||||||||||||||||||||||||||
  # read and check data in `.env` file
  # # |||||||||||||||||||||||||||||||||||||||||||||||

  readRenviron(env_file)

  purrr::walk(
    .x = seq_len(nrow(env_data)),
    .f = ~{

      # name of variable to be assigned
      in_name <- env_data$var_name[.x]
      # value to be extracted from the environment variable file
      in_value <- env_data$value[.x]
      # whether to check if the extracted value is an existing directory
      in_check_dir <- env_data$check_dir[.x]
      # whether to check if the extracted value is an existing file
      in_check_file <- env_data$check_file[.x]


      # check if the variable name is valid
      if (!is.character(in_name) || length(in_name) != 1L ||
          !nzchar(in_name)) {
        ecokit::stop_ctx(
          "`var_name` must be a valid object name", var_name = in_name)
      }

      if (in_check_dir && in_check_file) {
        ecokit::stop_ctx(
          "`check_dir` and `check_file` can not be both TRUE",
          var_name = in_name, var_value = in_value,
          check_dir = in_check_dir, check_file = in_check_file)
      }

      # get the value of the `in_value` from env_file
      env_value <- Sys.getenv(in_value)

      if (!nzchar(env_value)) {
        ecokit::stop_ctx(
          stringr::str_glue(
            "`{in_value}` environment variable was not set in env_file"),
          var_name = in_name, var_value = in_value)
      }

      if (in_check_dir && !dir.exists(env_value)) {
        ecokit::stop_ctx(
          stringr::str_glue("`{env_value}` directory does not exist"),
          directory = env_value, var_name = in_name,
          var_value = in_value, check_dir = in_check_dir)
      }

      if (in_check_file && !file.exists(env_value)) {
        ecokit::stop_ctx(
          stringr::str_glue("`{env_value}` file does not exist"),
          file = env_value, var_name = in_name,
          var_value = in_value, check_file = in_check_file)
      }

      assign(x = in_name, value = env_value, envir = parent.frame(5L))
    })

  return(invisible(NULL))
}
