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
#' @param prefix Character. prefix of each output file name. Useful for
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
#' \dontrun{
#'   TMP_Folder <- ecokit::path(tempdir(), stringi::stri_rand_strings(1, 5))
#'   fs::dir_create(TMP_Folder)
#'
#'   # ----------------------------------------------
#'   # Save x1 and x2 to disk
#'   # ----------------------------------------------
#'   x1 = 10; x2 = 20
#'
#'   save_multiple(variables = c("x1", "x2"), out_directory = TMP_Folder)
#'
#'   list.files(path = TMP_Folder, pattern = "^.+.RData")
#'
#'   (x1Contents <- ecokit::load_as(ecokit::path(TMP_Folder, "x1.RData")))
#'
#'   (x2Contents <- ecokit::load_as(ecokit::path(TMP_Folder, "x2.RData")))
#'
#'   # ----------------------------------------------
#'   # Use prefix
#'   # ----------------------------------------------
#'
#'   save_multiple(
#'       variables = c("x1", "x2"), out_directory = TMP_Folder, prefix = "A_")
#'
#'   list.files(path = TMP_Folder, pattern = "^.+.RData")
#'
#'   # ----------------------------------------------
#'   # File exists, no save
#'   # ----------------------------------------------
#'   try(save_multiple(variables = c("x1", "x2"), out_directory = TMP_Folder))
#'
#'   # ----------------------------------------------
#'   # overwrite existing file
#'   # ----------------------------------------------
#'   x1 = 100; x2 = 200; x3 = 300
#'
#'   save_multiple(variables = c("x1", "x2", "x3"),
#'      out_directory = TMP_Folder, overwrite = TRUE)
#'
#'   (x1Contents <- ecokit::load_as(ecokit::path(TMP_Folder, "x1.RData")))
#'
#'   (x2Contents <- ecokit::load_as(ecokit::path(TMP_Folder, "x2.RData")))
#'
#'   (x3Contents <- ecokit::load_as(ecokit::path(TMP_Folder, "x3.RData")))
#' }

save_multiple <- function(
    variables = NULL, out_directory = getwd(),
    overwrite = FALSE, prefix = "", verbose = FALSE) {

  # Check if variables is provided correctly
  if (is.null(variables) || !is.character(variables)) {
    ecokit::stop_ctx(
      "`variables` should be a character vector for names of objects",
      variables = variables)
  }

  env <- rlang::new_environment()

  purrr::walk(
    .x = variables,
    .f = ~assign(.x, get(.x, envir = parent.frame()), envir = env))

  # Check if all specified variables are available in the caller environment
  missing_vars <- setdiff(variables, ls(envir = env))

  if (length(missing_vars) > 0) {
    ecokit::stop_ctx(
      paste0(
        "Variable(s) ", paste(missing_vars, collapse = " & "),
        " do not exist in the caller environment.\n"))
  }
  fs::dir_create(out_directory)

  # Check if files already exist
  file_exist <- purrr::map_lgl(
    .x = ecokit::path(out_directory, paste0(prefix, variables, ".RData")),
    .f = file.exists) %>%
    any()

  if (file_exist && isFALSE(overwrite)) {
    message(
      "Some files already exist. No files are saved. ",
      "Please use overwrite = TRUE")
  } else {

    purrr::walk(
      .x = variables,
      .f = ~{
        ecokit::save_as(
          object = get(.x, envir = env), object_name = .x,
          out_path = ecokit::path(out_directory, paste0(prefix, .x, ".RData")))
      })

    all_exist <- all(
      file.exists(
        ecokit::path(out_directory, paste0(prefix, variables, ".RData"))))

    if (all_exist) {
      if (verbose) {
        message(
          "All files are saved to disk in ", out_directory, " successfully.")
      }
    } else {
      message("Some files were not saved to disk! Please check again.")
    }
  }
  return(invisible(NULL))
}
