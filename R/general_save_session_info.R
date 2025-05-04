## |------------------------------------------------------------------------| #
# save_session_info ----
## |------------------------------------------------------------------------| #

#' Save session information to a file
#'
#' This function saves the current R session information, including installed
#' packages, session details, and optionally, information about specific objects
#' in the session, to a text file.
#' @param out_directory Character. Directory path where the output file should
#'   be saved. The default is the current working directory ([base::getwd]).
#' @param session_info An optional list of objects to include in the session
#'   information output. This is typically the result of a session management
#'   function like [ecokit::save_session]. If provided, details of these
#'   objects (excluding functions and pre-selected objects, with sizes in
#'   megabytes) are appended to the session information file.
#' @param prefix Character. Prefix for the output file name. Defaults to `S`.
#' @author Ahmed El-Gabbas
#' @return The primary effect of this function is the side effect of writing
#'   session information to a file.
#' @export
#' @name save_session_info

save_session_info <- function(
  out_directory = getwd(), session_info = NULL, prefix = "S") {

  file_name <- paste0(
    out_directory, "/", prefix, "_",
    format(lubridate::now(tzone = "CET"), "%Y%m%d_%H%M"), ".txt")

  utils::capture.output(
    ecokit::info_chunk("Session Info"), file = file_name, append = TRUE)
  utils::capture.output(
    sessioninfo::session_info(), file = file_name, append = TRUE)

  if (!is.null(session_info)) {
    utils::capture.output(
      ecokit::info_chunk(
        paste0(
          "Objects in the current session (except functions and ",
          "pre-selected objects; Size in megabytes)")),
      file = file_name, append = TRUE)

    sink(file_name, append = TRUE)
    print.data.frame(tibble::tibble(session_info), row.names = FALSE)
    sink()
  }

  return(invisible(NULL))
}
