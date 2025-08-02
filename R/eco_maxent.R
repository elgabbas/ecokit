# # |------------------------------------------------------------------------| #
# maxent_open ----
## |------------------------------------------------------------------------| #

#' Launch the Maxent Java Application from the dismo Package
#'
#' This function locates and launches the Maxent Java application (`maxent.jar`)
#' that is distributed with the `dismo` R package. It performs robust checks for
#' required package installations, the presence of Java, and the availability of
#' the JAR file. If all checks pass, it attempts to launch the Maxent graphical
#' user interface using your system's Java installation.
#'
#' **Note:** This function works on Windows, macOS, and Linux, provided that
#' Java is correctly installed and available on your system PATH. The function
#' does not attempt to modify any system configurations. For headless (server)
#' environments, the GUI may not be displayed.
#'
#' @details Maxent is a Java-based application for species distribution
#'   modelling. The `dismo` package bundles the Maxent JAR file and provides R
#'   wrappers for interacting with it. This function is a convenience to open
#'   the Maxent GUI from within R.
#'
#'   If Java is not installed or not found on your PATH, or if Maxent is missing
#'   from the expected location, informative errors will be given. The function
#'   returns (invisibly) the result from the system call to launch Maxent.
#'
#' @return Invisibly returns the result of the system call (integer exit status
#'   on most platforms). Stops with an informative error if unsuccessful.
#'
#' @author Ahmed El-Gabbas
#' @examples
#' \dontrun{
#' require(ecokit)
#' ecokit::load_packages(dismo, rJava)
#'
#' # Launch Maxent GUI from the dismo package
#' maxent_open()
#' }
#' @export

maxent_open <- function() {

  # Check for required packages
  required_packages <- c("dismo", "rJava")
  missing_pkgs <- required_packages[
    !vapply(required_packages, requireNamespace, logical(1L), quietly = TRUE)]

  if (length(missing_pkgs) > 0L) {
    stop(
      sprintf(
        "The following required packages are not installed: %s",
        toString(missing_pkgs)),
      call. = FALSE)
  }

  # Check if dismo::maxent is functional (Java/rJava configuration)
  maxent_available <- tryCatch(
    expr = dismo::maxent(silent = TRUE),
    error = function(e) FALSE)
  if (!maxent_available) {
    stop(
      "MaxEnt is not available. Please ensure Java and rJava are ",
      "correctly installed and configured.",
      call. = FALSE)
  }

  # Locate maxent.jar
  dismo_dir <- system.file(package = "dismo")
  if (!nzchar(dismo_dir) || !dir.exists(dismo_dir)) {
    stop(
      "Could not locate the dismo package directory. Please reinstall dismo.",
      call. = FALSE)
  }
  maxent_jar_path <- file.path(dismo_dir, "java", "maxent.jar")
  if (!fs::file_exists(maxent_jar_path)) {
    stop(
      "`maxent.jar` was not found in the dismo package's java directory ",
      "(expected at: ", maxent_jar_path, ").",
      call. = FALSE)
  }

  # Check that Java is available on PATH
  java_exec <- Sys.which("java")
  if (!nzchar(java_exec)) {
    stop(
      "Java is not installed or not found in your system PATH. Please ",
      "install Java and ensure it is accessible.",
      call. = FALSE)
  }

  # OS check and warning for headless environments
  if (tolower(Sys.info()[["sysname"]]) %in% c("linux", "darwin")) {
    display_var <- Sys.getenv("DISPLAY")
    if (!nzchar(display_var)) {
      warning(
        "No DISPLAY environment variable detected. The Maxent GUI may not",
        "appear in a headless environment.",
        call. = FALSE)
    }
  }

  # Attempt to launch Maxent
  result <- tryCatch(
    expr = {
      code <- system2(
        java_exec, args = c("-jar", shQuote(maxent_jar_path)),
        wait = FALSE)
      if (code != 0L) {
        stop("Maxent launch returned non-zero exit status.", call. = FALSE)
      }
      invisible(code)
    }, error = function(e) {
      stop("Failed to launch Maxent: ", conditionMessage(e), call. = FALSE)
    })

  invisible(result)
}

# # |------------------------------------------------------------------------| #

#' Extract Variable Importance from a Maxent Model Object
#'
#' This function extracts the percent contribution and permutation importance
#' for each variable from a fitted Maxent model (class "MaxEnt") as returned by
#' [dismo::maxent()]. It returns a tibble with variables and their respective
#' importance metrics.
#'
#' @param model A fitted Maxent model object of class "MaxEnt" (from
#'   [dismo::maxent()].
#'
#' @return A tibble with columns:
#' \describe{
#'   \item{variable}{Variable name (character).}
#'   \item{percent_contribution}{Percent contribution of the variable
#'     (numeric).}
#'   \item{permutation_importance}{Permutation importance of the variable
#'     (numeric).}
#' }
#'
#' @author Ahmed El-Gabbas
#' @examples
#' require(ecokit)
#' ecokit::load_packages(fs, dismo, rJava, raster)
#'
#' # fit a Maxent model
#' if (dismo::maxent(silent = TRUE)) {
#'   predictors <- list.files(
#'     path = fs::path(
#'       system.file(package = "dismo"), "ex"),
#'     pattern = "grd", full.names = TRUE) %>%
#'     raster::stack()
#'
#'   occurence <- fs::path(
#'     system.file(package = "dismo"), "ex", "bradypus.csv") %>%
#'     read.table(header = TRUE, sep = ",") %>%
#'     dplyr::select(-1)
#'   # fit model, biome is a categorical variable
#'   me <- maxent(predictors, occurence, factors='biome')
#'
#'   maxent_variable_importance(me)
#'}
#'
#' @export

maxent_variable_importance <- function(model = NULL) {

  variable <- value <- NULL

  # Check input
  if (is.null(model)) {
    ecokit::stop_ctx("Argument 'model' must be provided and not NULL.")
  }

  if (!inherits(model, "MaxEnt")) {
    ecokit::stop_ctx(
      "The model is not a MaxEnt object.", class_model = class(model))
  }

  results <- model@results
  # Should be a numeric matrix with variable importances
  if (!inherits(results, "matrix")) {
    ecokit::stop_ctx(
      "The model results are not in the expected matrix format.",
      class_results = class(results))
  }

  if (nrow(results) == 0L) {
    ecokit::stop_ctx(
      "The model results matrix is empty.", nrows_results = nrow(results))
  }

  # Convert matrix to data frame, preserving rownames as variable names
  results_df <- as.data.frame(results)
  results_df$variable <- rownames(results_df)
  results_df <- tibble::tibble(results_df) %>%
    stats::setNames(c("value", "variable"))

  # Extract percent contribution
  contribution <- dplyr::filter(results_df, endsWith(variable, ".contribution"))
  if (nrow(contribution) == 0L) {
    ecokit::stop_ctx("No contribution data found in the model results.")
  }
  contribution <- contribution %>%
    dplyr::mutate(
      variable = stringr::str_remove(variable, "\\.contribution$")) %>%
    dplyr::select(variable, percent_contribution = value)


  # Extract permutation importance
  permutation_importance <- dplyr::filter(
    results_df, endsWith(variable, ".permutation.importance"))
  if (nrow(permutation_importance) == 0L) {
    ecokit::stop_ctx(
      "No permutation importance data found in the model results.")
  }
  permutation_importance <- permutation_importance %>%
    dplyr::mutate(
      variable = stringr::str_remove(
        variable, "\\.permutation\\.importance$")) %>%
    dplyr::select(variable, permutation_importance = value)

  # Join on variable name
  dplyr::left_join(contribution, permutation_importance, by = "variable")
}
