## |------------------------------------------------------------------------| #
# save_multiple ----
## |------------------------------------------------------------------------| #

#' Save multiple objects to their respective `.RData` files
#'
#' This function saves specified variables from the global environment to
#' separate `.RData` files. It allows for optional file prefixing and
#' overwriting of existing files.
#' @param variables Character vector. Names of the variables to be saved. If
#'   `NULL` or any specified variable does not exist in the global environment,
#'   the function will stop with an error.
#' @param out_directory Character. Path to the output folder where the `.RData`
#'   files will be saved. Defaults to the current working directory.
#' @param overwrite Logical. Whether existing `.RData` files should be
#'   overwritten. If `FALSE` (Default) and files exist, the function will stop
#'   with an error message.
#' @param prefix Character. Prefix of each output file name. Useful for
#'   organizing saved files or avoiding name conflicts. Defaults to an empty
#'   string.
#' @param verbose Logical. Whether to print a message upon successful saving of
#'   files. Defaults to `FALSE`.
#' @name save_multiple
#' @author Ahmed El-Gabbas
#' @return The function is used for its side effect of saving files and does not
#'   return a value.
#' @export
#' @examples
#' load_packages(fs, purrr)
#'
#' temp_dir <- fs::path_temp("save_multiple")
#' fs::dir_create(temp_dir)
#'
#' # ----------------------------------------------
#' # Save x1 and x2 to disk
#' # ----------------------------------------------
#' x1 = 10
#' x2 = 20
#'
#' save_multiple(
#'   variables = c("x1", "x2"), out_directory = temp_dir, verbose = TRUE)
#'
#' list.files(path = temp_dir, pattern = "^.+.RData")
#'
#' (x1Contents <- ecokit::load_as(fs::path(temp_dir, "x1.RData")))
#' (x2Contents <- ecokit::load_as(fs::path(temp_dir, "x2.RData")))
#'
#' # ----------------------------------------------
#' # Use prefix
#' # ----------------------------------------------
#' save_multiple(
#'   variables = c("x1", "x2"), out_directory = temp_dir, prefix = "A_")
#'
#' list.files(path = temp_dir, pattern = "^.+.RData")
#'
#' # ----------------------------------------------
#' # File exists, no save
#' # ----------------------------------------------
#' try(save_multiple(variables = c("x1", "x2"), out_directory = temp_dir))
#'
#' # ----------------------------------------------
#' # overwrite existing file
#' # ----------------------------------------------
#' x1 = 100; x2 = 200; x3 = 300
#'
#' save_multiple(
#'   variables = c("x1", "x2", "x3"),
#'   out_directory = temp_dir, overwrite = TRUE)
#'
#' (x1Contents <- ecokit::load_as(fs::path(temp_dir, "x1.RData")))
#' (x2Contents <- ecokit::load_as(fs::path(temp_dir, "x2.RData")))
#' (x3Contents <- ecokit::load_as(fs::path(temp_dir, "x3.RData")))
#'
#' # clean up
#' fs::dir_delete(temp_dir)

save_multiple <- function(
    variables = NULL, out_directory = getwd(),
    overwrite = FALSE, prefix = "", verbose = FALSE) {

  # Validate `variables`
  if (!is.character(variables) || length(variables) < 1L) {
    ecokit::stop_ctx(
      "`variables` must be a non-empty character vector",
      variables = variables)
  }

  # Capture caller's environment
  caller_env <- parent.frame()
  store_env  <- rlang::new_environment(parent = emptyenv())

  # Copy each requested object into store_env
  purrr::walk(variables, function(var) {
    if (!exists(var, envir = caller_env, inherits = FALSE)) {
      ecokit::stop_ctx(
        paste0("Variable '", var, "' not found in caller environment."),
        missing = var)
    }
    assign(var, get(var, envir = caller_env), envir = store_env)
  })

  # Prepare output dir
  fs::dir_create(out_directory)

  # Check existing files
  paths <- fs::path(out_directory, paste0(prefix, variables, ".RData"))
  exists_any <- any(fs::file_exists(paths))

  if (exists_any && !overwrite) {
    message(
      "One or more files exist; skipping save. Use overwrite = TRUE to force.")
    return(invisible(NULL))
  }

  # Save each object
  purrr::walk2(
    .x = variables, .y = paths,
    .f = function(var, out_path) {
      ecokit::save_as(
        object = get(var, envir = store_env),
        object_name = var, out_path = out_path)
    })

  # Verbose feedback
  if (verbose) {
    message(
      "Saved ", length(variables), " object(s) to ",
      ecokit::normalize_path(out_directory), ".")
    message("Saved files are: ", toString(crayon::red(basename(paths))), ".")
  }

  invisible(NULL)
}
