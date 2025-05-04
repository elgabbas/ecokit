#' Apply a function over a list or vector with optional silence
#'
#' Wrapper functions around the base [base::lapply] and [base::sapply] functions
#' that allow for the application of a function over a list or vector. It
#' extends original functions by providing an option to suppress the output,
#' effectively allowing for operations where the user may not care about the
#' return value (e.g., plotting). This behaviour is similar to the [purrr::walk]
#' function.
#' @param Silent A logical value. If `TRUE`, the function suppresses the return
#'   value of `FUN` and returns `NULL` invisibly. If `FALSE`, the function
#'   returns the result of applying `FUN` over `X`.
#' @param ... Additional arguments to be passed to `FUN`.
#' @name apply_functions
#' @rdname apply_functions
#' @inheritParams base::sapply
#' @inheritParams base::lapply
#' @order 1
#' @author Ahmed El-Gabbas
#' @return If `Silent` is `TRUE`, returns `NULL` invisibly, otherwise returns a
#'   list of the same length as `X`, where each element is the result of
#'   applying `FUN` to the corresponding element of `X`.
#' @param Silent Logical; if TRUE, the function returns `invisible(NULL)`
#'   instead of the actual result, effectively suppressing the output. This
#'   enhances the base [base::sapply] for cases where the return value is not
#'   necessary and its output is undesired.
#' @export
#' @examples
#' par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
#' lapply(list(x = 100:110, y = 110:120), function(V) {
#'     plot(V, las = 1, main = "lapply")
#' })
#'
#' # -------------------------------------------
#'
#' par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
#' lapply_(list(x = 100:110, y = 110:120), function(V) {
#'     plot(V, las = 1, main = "lapply_")
#' })
#'
#' # -------------------------------------------
#'
#' #' par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
#' sapply(
#'     list(x = 100:110, y = 110:120),
#'     function(V) {
#'         plot(V, las = 1, main = "sapply")
#'         })
#'
#' # -------------------------------------------
#'
#' # nothing returned or printed, only the plotting
#' par(mfrow = c(1,2), oma = c(0.25, 0.25, 0.25, 0.25), mar = c(3,3,3,1))
#' sapply_(
#'   list(x = 100:110, y = 110:120),
#'   function(V) {
#'     plot(V, las = 1, main = "sapply_")
#'     })

## |------------------------------------------------------------------------| #
# lapply_ ----
## |------------------------------------------------------------------------| #

lapply_ <- function(X, FUN, Silent = TRUE, ...) {

  if (is.null(X) || is.null(FUN)) {
    ecokit::stop_ctx("X or FUN cannot be NULL", FUN = FUN, X = X)
  }

  result <- lapply(X = X, FUN = FUN, ...)

  if (Silent) {
    return(invisible(NULL))
  } else {
    return(result)
  }
}

## |------------------------------------------------------------------------| #
# sapply_ ----
## |------------------------------------------------------------------------| #

#' @export
#' @name apply_functions
#' @rdname apply_functions
#' @order 1

sapply_ <- function(X, FUN, simplify = TRUE, Silent = TRUE, ...) {

  if (is.null(X) || is.null(FUN)) {
    ecokit::stop_ctx("X or FUN cannot be NULL", FUN = FUN, X = X)
  }

  result <- sapply(X = X, FUN = FUN, simplify = simplify, ...)

  if (Silent) {
    return(invisible(NULL))
  } else {
    return(result)
  }
}
