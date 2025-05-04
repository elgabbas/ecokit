## |------------------------------------------------------------------------| #
# function_arguments ----
## |------------------------------------------------------------------------| #

#' Print function Arguments
#'
#' This function takes another function as input and prints its arguments in the
#' format `ArgumentName = DefaultValue`. Each argument is printed on a new line.
#' The function can optionally assign the formatted arguments to the global
#' environment and can load a specified package before processing.
#' @param function_name A function whose arguments you want to print. Must be a
#'   valid R function.
#' @param assign Logical. Whether to assign the arguments as variables in the
#'   global environment. Defaults to `FALSE`.
#' @param package Character. Name of the R package to be loaded before
#'   processing the function. Default is `NULL`.
#' @export
#' @name function_arguments
#' @author Ahmed El-Gabbas
#' @return The function prints the formatted arguments to the console. If
#'   `assign` is TRUE, it also assigns arguments to the global environment.
#' @examples
#' formals(stats::setNames)
#'
#' function_arguments(stats::setNames)

function_arguments <- function(function_name, assign = FALSE, package = NULL) {

  if (!is.function(function_name)) {
    ecokit::stop_ctx(
      "The provided input is not a function", function_name = function_name)
  }

  if (!is.null(package)) {
    ecokit::load_packages(package_list = package)
  }

  # Extract the formal arguments of the function
  args_list <- formals(function_name)

  formatted_args <- purrr::map_chr(
    .x = seq_along(args_list),
    .f = function(i) {

      arg_name <- names(args_list)[i]

      if (is.name(args_list[[i]])) {
        arg_value <- NULL
      } else {
        arg_value <- args_list[[i]]
      }

      post_process <- !any(
        c(
          is.numeric(arg_value),
          is.logical(arg_value),
          is.null(arg_value)
        )
      )

      if (post_process) {
        arg_value <- deparse(args_list[[i]]) %>%
          stringr::str_c(collapse = "") %>%
          stringr::str_replace_all('^\"|\"$', "") %>%
          stringr::str_replace_all('\"', '"') %>%
          stringr::str_replace_all("  +", " ")
      }

      output <- if (is.null(arg_value)) {
        paste0(arg_name, " = NULL")
      } else if (is.character(arg_value)) {
        if (stringr::str_detect(arg_value, "\\(|\\)")) {
          paste0(arg_name, " = ", arg_value)
        } else {
          paste0(arg_name, " = \"", arg_value, "\"")
        }
      } else {
        paste0(arg_name, " = ", as.character(arg_value))
      }

      if (assign) {
        eval(expr = parse(text = output), envir = .GlobalEnv)
      }
      return(output)
    }
  )

  cat(formatted_args, sep = "\n")
  return(invisible(NULL))
}
