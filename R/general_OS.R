## |------------------------------------------------------------------------| #
# OS ----
## |------------------------------------------------------------------------| #

#' Current operating system
#'
#' This function returns the name of the current operating system the R session
#' is running on.
#' @name OS
#' @author Ahmed El-Gabbas
#' @return A character string representing the name of the operating system.
#' @examples
#' OS()
#'
#' @export

OS <- function() {
  as.character(Sys.info()["sysname"])
}
