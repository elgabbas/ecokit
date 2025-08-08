#' Open and Load a .qs2 File in RStudio
#'
#' @description An RStudio addin that allows you to interactively select and
#'   load a `.qs2` file into the global environment. The selected file is loaded
#'   using [ecokit::load_as()], and the resulting object is assigned as
#'   `qs2_object` in the global environment.
#'
#' @details
#' - Prompts the user with a file selection dialog (filtering for `.qs2` files).
#' - Requires the `qs2` and `ecokit` packages to be installed.
#' - If the selected file is not a `.qs2` file, a message is displayed.
#' - If the file is loaded successfully, the object is assigned as `qs2_object`
#' in `.GlobalEnv`.
#'
#' @return Invisibly returns `NULL`. The loaded object is assigned to
#'   `qs2_object` in the global environment as a side effect.
#'
#' @seealso [ecokit::load_as()]
#' @author Ahmed El-Gabbas
#' @keywords internal
#' @noRd

open_qs2 <- function() {
  file <- rstudioapi::selectFile(
    caption = "Select a file to open", filter = "qs2 files (*.qs2)")
  if (is.null(file)) return(invisible(NULL))

  if (tools::file_ext(file) == "qs2") {

    if (!requireNamespace("qs2", quietly = TRUE)) {
      ecokit::stop_ctx("The 'qs2' package is required to open qs2 files.")
    }
    ecokit::load_packages(package_list = c("ecokit", "qs2"))

    obj <- ecokit::load_as(file, load_packages = TRUE, unwrap_r = TRUE)
    assign("qs2_object", obj, envir = .GlobalEnv)
    message("Loaded qs2 file as 'qs2_object' in the global environment.")
  } else {
    message("Unsupported file type.")
  }

  invisible(NULL)
}
