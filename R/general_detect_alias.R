## |------------------------------------------------------------------------| #
# detect_alias ----
## |------------------------------------------------------------------------| #

#' Detect aliased variables in a linear model
#'
#' This function identifies aliased (linearly dependent) variables in a linear
#' model by adding a constant column to the data frame, fitting a linear model,
#' and then using the alias function to detect aliased variables.
#' @param data A `data frame` or `tibble` containing the variables to be checked
#'   for aliasing.
#' @param verbose Logical. Whether to print the aliased variables
#'   found (if any). If `TRUE`, aliased variables are printed to the console.
#'   Defaults to `FALSE`.
#' @return Returns a character vector of aliased variable names if any are
#'   found; otherwise, returns `NULL` invisibly. If `verbose` is `TRUE`, the
#'   function will also print a message to the console.
#' @name detect_alias
#' @author Ahmed El-Gabbas
#' @export
#' @examples
#' library("car", warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
#' x1 <- rnorm(100)
#' x2 <- 2 * x1
#' x3 <- rnorm(100)
#' y <- rnorm(100)
#'
#' model <- lm(y ~ x1 + x2 + x3)
#' summary(model)
#'
#' # there are aliased coefficients in the model
#' try(car::vif(model))
#'
#' # The function identifies the aliased variables
#' detect_alias(data = cbind.data.frame(x1, x2, x3))
#'
#' detect_alias(data = cbind.data.frame(x1, x2, x3), verbose = TRUE)
#'
#' # excluding x2 and refit the model
#' model <- lm(y ~ x1 + x3)
#'
#' summary(model)
#'
#' try(car::vif(model))

detect_alias <- function(data, verbose = FALSE) {

  if (is.null(data)) {
    ecokit::stop_ctx("`data` cannot be NULL", data = data)
  }

  # Ensure data is a data.frame or tibble
  if (!is.data.frame(data)) {
    ecokit::stop_ctx("`data` must be a data frame or tibble.", data = data)
  }

  # Add a constant column to the data frame
  data <- cbind.data.frame(XX = rep(1, nrow(data)), data)

  # Construct the formula for linear model
  form <- paste(names(data)[-1], collapse = " + ")
  form <- stats::as.formula(paste("XX", "~", form))

  # Fit the linear model
  fit <- stats::lm(form, data = data)

  # Detect aliased variables
  aliased <- stats::alias(fit)
  aliased <- rownames(aliased$Complete)

  # Output aliased variables if any
  if (length(aliased) > 0) {
    if (verbose) {
      cat(paste0("aliased variables: ", toString(aliased), "\n"))
    }
    return(aliased)
  } else {
    if (verbose) {
      cat("No aliased variables found\n")
    }
    return(invisible(NULL))
  }
}
