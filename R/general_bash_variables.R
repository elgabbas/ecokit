## |------------------------------------------------------------------------| #
# bash_variables ----
## |------------------------------------------------------------------------| #

#' Read command line arguments passed to an R script
#'
#' Reads command line arguments passed to an R script executed via the command
#' line (`Rscript`) and return the name and value of each argument as a
#' tibble.
#' @return A `tibble` with two columns: "name" and "value", containing the
#'   parsed command line arguments. If no arguments are provided, an empty
#'   `tibble` is returned.
#' @author Ahmed El-Gabbas
#' @export
#' @details To use `bash_variables`, include it in an R script and run the
#'   script with `Rscript` and command line arguments in the format
#'   `variable=value`. The function parses each argument and returns a `tibble`
#'   with columns "name" and "value". You can then access these values as
#'   needed.
#'
#' **Usage**:
#'
#'   1. Create an R script (e.g., `script.R`):
#'    ```R
#'        library(ecokit)
#'
#'        load_packages(stringr, dplyr, purrr, tibble)
#'
#'        # read command line arguments
#'        args <- ecokit::bash_variables()
#'
#'        # Access variables from the tibble
#'        cat("Input:", args$value[args$name == "input_file"], "\n")
#'        n_iterations <- as.numeric(args$value[args$name == "n_iterations"])
#'        cat("Iterations:", n_iterations, "\n")
#'    ```
#'
#'   2. Run the script:
#'    ```bash
#'        Rscript script.R input_file=data.csv n_iterations=100
#'    ```
#'    **Output**:
#'    ```
#'        Input: data.csv
#'        Iterations: 100
#'    ```
#'
#' **Argument Format**:
#' - Arguments must be `variable=value` (e.g., `input_file=data.csv`).
#' - Variable names must be valid R names: start with a letter or underscore,
#'   followed by letters, numbers, or underscores (e.g., `max_iter`, `_flag`).
#' - Values can be any string, including empty strings (e.g., `config_file=`).
#' - Values are assigned as character strings; convert types in the script if
#'   needed (e.g., `as.numeric(n_iterations)` for numbers).
#'
#' **Valid Commands**:
#'
#'   ```bash
#'       # Assigns: `data_path = "/home/data"`, `output_dir = "results"`,
#'       # `n_threads = "8"`.
#'       Rscript script.R data_path=/home/data output_dir=results n_threads=8
#'
#'       # Assigns: `debug = "TRUE"`, `config_file = ""`.
#'       Rscript script.R debug=TRUE config_file=
#'
#'       # Assigns: `model_type = "linear"`.
#'       Rscript script.R model_type=linear
#'
#'       # No arguments; prints message: "No command line arguments provided".
#'       Rscript script.R
#'    ```
#'
#' **Invalid Commands** (cause errors):
#'   ```bash
#'       # Error: "Invalid argument format... got: input_file, data.csv".
#'       Rscript script.R input_file data.csv
#'
#'       # Error: "Invalid argument format... got: 1st_model=linear".
#'       Rscript script.R 1st_model=linear
#'
#'       # Error: "Invalid argument format... got: input file=data.csv"
#'       Rscript script.R input file=data.csv
#'
#'       # Error: "Variable names cannot be empty".
#'       Rscript script.R =data.csv
#'   ```
#'
#' **Notes**:
#' - The returned `tibble` contains the parsed arguments; you can convert values
#'   to other types as needed (e.g., `as.numeric(args$value[args$name ==
#'   "n_iterations"])`).

bash_variables <- function() {

  # Get command line arguments
  command_arguments <- commandArgs(trailingOnly = TRUE)

  # Check if arguments exist
  if (length(command_arguments) == 0L) {
    message("No command line arguments provided")
    return(tibble::tibble(name = character(), value = character()))
  }

  # Validate argument format
  valid_format <- grepl("^[a-zA-Z_][a-zA-Z0-9_]*=.*$", command_arguments)
  if (!all(valid_format)) {
    ecokit::stop_ctx(
      paste0(
        "Invalid argument format. Arguments must be 'variable=value' with ",
        "valid R variable names, got: ",
        toString(command_arguments[!valid_format])),
      invalid_args = command_arguments[!valid_format])
  }

  # Convert arguments to data frame
  args_df <- command_arguments %>%
    stringr::str_split("=", simplify = TRUE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    stats::setNames(c("name", "value")) %>%
    tibble::tibble()

  # Check for empty variables
  if (!all(nzchar(args_df$name))) {
    ecokit::stop_ctx("Variable names cannot be empty")
  }

  # Validate variable names
  purrr::walk2(
    args_df$name,
    args_df$value,
    function(var, val) {
      if (!grepl("^[a-zA-Z_][a-zA-Z0-9_]*$", var)) {
        ecokit::stop_ctx(
          sprintf("'%s' is not a valid R variable name", var = var))
      }
    }
  )

  args_df
}
