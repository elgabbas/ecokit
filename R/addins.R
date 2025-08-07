open_qs2 <- function() {
  file <- rstudioapi::selectFile(caption = "Select a file to open")
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
