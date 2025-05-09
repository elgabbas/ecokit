## |------------------------------------------------------------------------| #
# assign_if_not_exist ----
## |------------------------------------------------------------------------| #

#' Assign a value to a variable if it does not already exist in the specified
#' environment
#'
#' This function checks if a given variable exists in the specified environment
#' (global environment by default). If the variable does not exist, it assigns a
#' given value to it. If the variable already exists, it prints the current
#' value of the variable. The function is designed to prevent overwriting
#' existing variables unintentionally.
#'
#' @param variable Character; the name of the variable to be checked and
#'   potentially assigned a value.
#' @param value any; the value to be assigned to the variable if it does not
#'   already exist.
#' @param environment environment; the environment in which to check for the
#'   existence of the variable and potentially assign the value. Defaults to the
#'   global environment.
#' @author Ahmed El-Gabbas
#' @return The function explicitly returns `NULL`, but its primary effect is the
#'   side-effect of assigning a value to a variable in an environment or
#'   printing the current value of an existing variable.
#' @export
#' @name assign_if_not_exist
#' @examples
#' load_packages(terra)
#'
#' exists("x")
#' assign_if_not_exist(variable = "x", value = TRUE)
#' exists("x")
#' print(x)
#'
#' # --------------------------------------------------
#'
#' y <- 10
#' # y exists and thus its value was not changed
#' assign_if_not_exist(variable = "y", value = TRUE)
#' print(y)
#'
#' # --------------------------------------------------
#'
#' assign_if_not_exist(
#'   variable = "R", value = terra::rast(nrows = 10, ncols = 10))
#' print(R)

assign_if_not_exist <- function(variable, value, environment = globalenv()) {

  if (is.null(variable) || is.null(value)) {
    ecokit::stop_ctx(
      "`variable` and `value` cannot be NULL",
      variable = variable, value = value)
  }

  variable <- as.character(rlang::ensyms(variable))

  if (exists(variable, envir = environment)) {
    "The input object already exists in the environment.\n" %>%
      crayon::blue() %>%
      cat()
    print(rlang::env_get(environment, paste0(variable)))
  } else {
    assign(x = variable, value = value, envir = environment)
  }
}
