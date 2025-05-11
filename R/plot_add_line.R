## |------------------------------------------------------------------------| #
# add_line ----
## |------------------------------------------------------------------------| #

#' Add a horizontal or vertical line to the current plot
#'
#' Add a horizontal or vertical line to the current plot
#'
#' @name add_line
#' @source The source code of this function was taken from this
#'   [stackoverflow](https://stackoverflow.com/questions/27800307/) question.
#' @export
#' @param at Numeric; the relative location of where the line should be plotted.
#'   Cannot be `NULL`.
#' @param outer Logical; if `TRUE`, the line is plotted outside of the plotting
#'   area. Default is `FALSE`.
#' @param horizontal Logical; if `TRUE` (default), a horizontal line is added.
#'   If `FALSE`, a vertical line is added.
#' @param ... Additional graphical parameters passed to [graphics::abline].
#' @return Invisible; the function is called for its side effect of drawing on
#'   the current plot.
#' @examples
#' # Horizontal line
#' par(oma = c(1, 1, 1, 1), mar = c(3, 3, 1, 1))
#' plot(seq_len(100))
#'
#' # add horizontal line
#' add_line(at = 0.25)
#' # add horizontal line that extends outside the plot area
#' add_line(at = 0.5, outer = TRUE)
#' # the same line but with a different line width and colour
#' add_line(at = 0.75, outer = TRUE, lwd = 3, col = "red")
#'
#' # ---------------------------------------------
#'
#' plot(seq_len(100))
#' # add vertical line
#' add_line(horizontal = FALSE, at = 0.25)
#' # add vertical line that extends outside the plot area
#' add_line(horizontal = FALSE, at = 0.5, outer = TRUE)
#' # the same line but with a different line width and colour
#' add_line(horizontal = FALSE, at = 0.75, outer = TRUE, lwd = 3, col = "red")

add_line <- function(at = NULL, outer = FALSE, horizontal = TRUE, ...) {

  if (is.null(at)) {
    ecokit::stop_ctx("at cannot be NULL", at = at)
  }

  if (outer) {
    graphics::par(xpd = TRUE)    #nolint
  }

  if (horizontal) {
    graphics::abline(h = graphics::grconvertY(at, "npc"), ...)
  } else {
    graphics::abline(v = graphics::grconvertX(at, "npc"), ...)
  }

  if (outer) {
    graphics::par(xpd = FALSE)    #nolint
  }
}
