## |------------------------------------------------------------------------| #
# assign_env_vars ------
## |------------------------------------------------------------------------| #

#' Assign environment variables from a .env file
#'
#' This function reads environment variables from a specified `.env` file and
#' assigns them to variables in the R environment based on a data frame
#' containing variable names, values, and checks for directories and files. It
#' is designed to facilitate the management of environment variables in a
#' structured and reproducible manner.
#' @name assign_env_vars
#' @param env_file Character. Path to the environment file containing paths to
#'   data sources. Defaults to `.env`.
#' @param env_variables_data `data.frame`. A data frame or tibble containing the
#'   columns `var_name`, `value`, `check_dir`, and `check_file`. Each row
#'   specifies an environment variable, the name to assign it to, and whether to
#'   check if it is a directory or file. This structure allows for additional
#'   validation checks on the variables being imported.
#' @author Ahmed El-Gabbas
#' @export
#' @return This function is used for its side effects of setting environment
#'   variables in the R environment. It assigns each variable from the `.env`
#'   file to the R environment with the name specified in the
#'   `env_variables_data` data frame.

assign_env_vars <- function(env_file = ".env", env_variables_data = NULL) {

  if (is.null(env_file) || is.null(env_variables_data)) {
    ecokit::stop_ctx(
      "`env_file` and `env_variables_data` can not be empty",
      env_file = env_file, env_variables_data = env_variables_data)
  }

  if (!file.exists(env_file)) {
    ecokit::stop_ctx("env_file does not exist", env_file = env_file)
  }

  if (!inherits(env_variables_data, "data.frame")) {
    ecokit::stop_ctx(
      paste0(
        "The provided env_variables_data object should be either tibble or ",
        "data frame"),
      env_variables_data = env_variables_data,
      class_env_variables_data = class(env_variables_data))
  }

  match_names <- setdiff(
    c("var_name", "value", "check_dir", "check_file"),
    names(env_variables_data))

  if (length(match_names) > 0) {
    ecokit::stop_ctx(
      paste0(
        "The following columns are missing from `env_variables_data`: ",
        paste(match_names, collapse = "; ")),
      match_names = match_names, length_MatchNames = length(match_names))
  }

  in_classes <- purrr::map_chr(env_variables_data, class)
  expected_classes <- c("character", "character", "logical", "logical")
  match_class <- all(in_classes == expected_classes)

  if (isFALSE(match_class)) {
    class_difference <- which(in_classes != expected_classes)
    msg <- purrr::map_chr(
      .x = class_difference,
      .f = ~{
        paste0(
          '"', names(env_variables_data)[.x], '" is ', in_classes[.x],
          " not ", expected_classes[.x])
      }) %>%
      stringr::str_c(collapse = "\n") %>%
      stringr::str_c("\n", ., collapse = "\n")
    ecokit::stop_ctx(msg, match_class = match_class, in_classes = in_classes)
  }

  readRenviron(env_file)

  purrr::walk(
    .x = seq_len(nrow(env_variables_data)),
    .f = ~{
      var_value <- env_variables_data$value[.x]
      var_name <- env_variables_data$var_name[.x]
      check_dir <- env_variables_data$check_dir[.x]
      check_file <- env_variables_data$check_file[.x]

      values <- Sys.getenv(var_value)

      if (check_dir && check_file) {
        ecokit::stop_ctx(
          "values should be checked as either file or directory, not both",
          values = values)
      }

      if (!nzchar(values)) {
        ecokit::stop_ctx(
          paste0(
            "`", var_value,
            "` environment variable was not set in the .env file"),
          var_value = var_value, var_name = var_name)
      }

      if (check_dir && !dir.exists(values)) {
        ecokit::stop_ctx(
          paste0("`", values, "` directory does not exist"),
          values = values, check_dir = check_dir)
      }

      if (check_file && !file.exists(values)) {
        ecokit::stop_ctx(
          paste0("`", values, "` file does not exist"),
          values = values, check_dir = check_dir)
      }

      assign(x = var_name, value = values, envir = parent.frame(5))
    })

  return(invisible(NULL))
}
