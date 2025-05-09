## |------------------------------------------------------------------------| #
# os ----
## |------------------------------------------------------------------------| #

#' Current operating system
#'
#' This function returns the name of the current operating system the R session
#' is running on.
#' @name os
#' @author Ahmed El-Gabbas
#' @return A character string representing the name of the operating system.
#' @examples
#' os()
#'
#' @export

os <- function() {
  as.character(Sys.info()["sysname"])
}
