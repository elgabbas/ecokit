## |------------------------------------------------------------------------| #
# system ----
## |------------------------------------------------------------------------| #

#' Run a system command in a cross-platform manner
#'
#' This function executes a system command, using either `shell` on Windows or
#' `system` on Linux. It allows the output of the command to be captured into an
#' R object.
#' @param command Character. The bash command to be executed.
#' @param r_object Logical. Whether to capture the output of the command as an R
#'   object. If `TRUE` (Default), the output is captured; if `FALSE`, the output
#'   is printed to the console.
#' @param ... Additional arguments passed to either `shell` or `system`
#'   function, depending on the operating system.
#' @name system_command
#' @author Ahmed El-Gabbas
#' @return Depending on the value of `r_object`, either the output of the
#'   executed command as an R object or `NULL` if `r_object` is `FALSE` and the
#'   output is printed to the console.
#' @examples
#' # print working directory
#' system_command("pwd")
#' system_command("pwd", r_object = FALSE)
#'
#' # first 5 files on the working directory
#' (A <- system_command("ls | head -n 5"))
#'
#' B <- system_command("ls | head -n 5", r_object = FALSE)
#' B
#' @export

system_command <- function(command, r_object = TRUE, ...) {

  # Ensure that command is not NULL
  if (is.null(command)) {
    ecokit::stop_ctx("`command` cannot be NULL", command = command)
  }

  if (ecokit::os() == "Windows") {
    output <- shell(cmd = command, intern = TRUE, ...)
  }
  if (ecokit::os() == "Linux") {
    output <- system(command = command, intern = TRUE, ...)
  }

  if (r_object) {
    return(output)
  } else {
    cat(output, sep = "\n")
    return(invisible(NULL))
  }
}
