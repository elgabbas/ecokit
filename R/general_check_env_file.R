# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# check_env_file ------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#' Check the integrity of a `.env` file before loading environment variables
#'
#' Validates a `.env` file to ensure it is properly formatted for loading
#' environment variables.
#'
#' @details The function performs the following checks:
#' - Verifies file exists and is readable
#' - Confirms `.env` extension
#' - Ensures file is not empty
#' - Checks for at least one valid variable definition
#' - Validates non-comment, non-empty lines follow `KEY=VALUE` format (allowing
#' optional whitespace around KEY, '=', and VALUE)
#' - Ensures variable names start with letter/underscore, followed by
#' letters/digits/underscores
#' - Checks for duplicate variable names (case-sensitive)
#' - Ignores comment lines (starting with #) and empty lines
#' - Validates no unclosed quotes in values
#' - Checks for unquoted special characters in values
#'
#' @param env_file Path to the .env file (default: ".env")
#' @param warning Logical; if `TRUE`, prints warnings for errors (default:
#'   `TRUE`)
#' @return Logical: `TRUE` if valid, `FALSE` otherwise
#' @examples
#' # Save a valid .env file to temp file
#' valid_env <- fs::file_temp(ext = ".env")
#' writeLines(
#'   c("DB_HOST=localhost", "DB_PORT=5432", "# Comment", "API_KEY='abc123'"),
#'   valid_env)
#' check_env_file(valid_env)  # Returns TRUE
#'
#' # Invalid .env file
#' invalid_env <- fs::file_temp(ext = ".env")
#'
#' writeLines(
#'   c(
#'    "DB_HOST=localhost", "INVALID KEY=value",
#'    "DB_HOST=duplicate"),
#'  invalid_env)
#' check_env_file(invalid_env)  # Returns FALSE
#' @author Ahmed El-Gabbas
#' @export

check_env_file <- function(env_file = ".env", warning = TRUE) {

  errors <- character()

  if (!is.character(env_file) || length(env_file) != 1L) {
    ecokit::stop_ctx(
      "env_file must be a character of length 1",
      env_file = env_file, class_env_file = class(env_file))
  }

  if (!is.logical(warning) || length(warning) != 1L) {
    ecokit::stop_ctx(
      "warning must be a logical of length 1",
      env_file = env_file, class_env_file = class(env_file))
  }

  # Check if file exists and is readable
  if (!fs::file_exists(env_file)) {
    if (warning) {
      warning(
        stringr::str_glue("File '{env_file}' does not exist."), call. = FALSE)
    }
    return(FALSE)
  }

  if (!fs::is_file(env_file) || !fs::file_access(env_file, "read")) {
    if (warning) {
      warning(
        stringr::str_glue(
          "File '{env_file}' is not readable or not a regular file."),
        call. = FALSE)
    }
    return(FALSE)
  }

  # Check file extension
  if (!stringr::str_ends(env_file, "\\.env")) {
    if (warning) {
      warning(
        stringr::str_glue("File '{env_file}' does not have a .env extension."),
        call. = FALSE
      )
    }
    errors <- c(errors, "Invalid extension")
  }

  # Read file with proper encoding
  lines <- tryCatch(
    readLines(env_file, warn = FALSE, encoding = "UTF-8"),
    error = function(e) {
      if (warning) {
        warning(
          stringr::str_glue("Failed to read file '{env_file}': {e$message}"),
          call. = FALSE)
      }
      character()
    })

  if (length(lines) == 0L) {
    if (warning && length(errors) == 0L) {
      warning(
        stringr::str_glue("File '{env_file}' is empty or unreadable."),
        call. = FALSE)
    }
    return(FALSE)
  }

  # Remove comments and empty/whitespace-only lines
  clean_lines <- lines[!stringr::str_detect(lines, "^\\s*(#|$)")]

  if (length(clean_lines) == 0L) {
    if (warning) {
      warning(
        stringr::str_glue(
          "File '{env_file}' contains only comments or empty lines."),
        call. = FALSE
      )
    }
    return(FALSE)
  }

  # Regex for valid KEY=VALUE pairs
  var_regex <- paste0(
    "^\\s*[A-Za-z_][A-Za-z0-9_]*\\s*=\\s*(('[^']*')|",
    "(\"[^\"]*\")|[^#]*)\\s*(#.*)?$")

  # Check for invalid lines
  invalid_lines <- clean_lines[!stringr::str_detect(clean_lines, var_regex)]
  if (length(invalid_lines) > 0L) {
    if (warning) {
      warning(
        stringr::str_glue(
          "Invalid variable definition(s): ",
          "{paste0(invalid_lines, collapse = '; ')}"),
        call. = FALSE)
    }
    errors <- c(errors, "Invalid variable(s)")
  }

  # Extract variable names
  var_names <- stringr::str_extract(
    clean_lines, "^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*=") %>%
    stringr::str_remove_all("^\\s*|\\s*=$")

  # Check for duplicate variable names
  dups <- var_names[duplicated(var_names)]
  if (length(dups) > 0L) {
    if (warning) {
      warning(
        stringr::str_glue(
          "Duplicate variable names: {paste0(unique(dups), collapse = ', ')}"),
        call. = FALSE)
    }
    errors <- c(errors, "Duplicate variables")
  }

  # Check for unclosed quotes in values
  for (line in clean_lines) {
    value <- stringr::str_extract(
      line, "=\\s*(('[^']*')|(\"[^\"]*\")|[^#]*)\\s*(#.*)?$") %>%
      stringr::str_remove("^=\\s*|\\s*(#.*)?$")
    if (stringr::str_detect(value, "^['\"][^'\"]*$")) {
      if (warning) {
        warning(
          stringr::str_glue(
            "Unclosed quote in value for line: {line}"),
          call. = FALSE)
      }
      errors <- c(errors, "Unclosed quotes")
    }
  }

  # Check for special characters in unquoted values
  for (line in clean_lines) {
    value <- stringr::str_extract(
      line, "=\\s*(('[^']*')|(\"[^\"]*\")|[^#]*)\\s*(#.*)?$") %>%
      stringr::str_remove("^=\\s*|\\s*(#.*)?$")
    if (!stringr::str_detect(value, "^['\"].*['\"]$") &&
        stringr::str_detect(value, "[\\|&;<>()$`{}\\[\\]]")) {
      if (warning) {
        warning(
          stringr::str_glue(
            "Unquoted special characters in value for line: {line}"),
          call. = FALSE)
      }
      errors <- c(errors, "Special characters")
    }
  }

  # Return TRUE only if no errors were found
  length(errors) == 0L
}
