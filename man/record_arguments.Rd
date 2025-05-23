% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/general_record_arguments.R
\name{record_arguments}
\alias{record_arguments}
\title{Capture and record evaluated function arguments}
\usage{
record_arguments(out_path = NULL)
}
\arguments{
\item{out_path}{Character. The path to an \code{.RData} file where the output
tibble will be exported. If \code{NULL} (default), the tibble is returned
without saving. If provided, the tibble is saved to the specified file and
\code{NULL} is returned invisibly.}
}
\value{
A \code{tibble} containing the evaluated forms of the parent function’s
arguments and any additional named arguments passed via \code{...}, with columns
named after the arguments (e.g., \code{w}, \code{x}, \code{y}, \code{extra1}). Evaluated values
are presented as scalars (e.g., \code{8}) or list columns for complex objects
(e.g., \verb{<SpatRaster>}). If \code{out_path} is provided, the tibble is saved to
the specified \code{.RData} file and \code{NULL} is returned invisibly.
}
\description{
\code{record_arguments()} is a utility function that captures and records the
evaluated forms of arguments passed to the parent function. It returns a
tibble with columns named after the arguments, containing their evaluated
values only.
}
\details{
This function evaluates all arguments in the grandparent environment
(two frames up), with a fallback to the global environment if evaluation
fails. This ensures correct evaluation in iterative contexts like \code{lapply}.
It handles:
\itemize{
\item Scalars (e.g., numbers, strings) as single values.
\item Multi-element vectors or complex objects (e.g., \code{SpatRaster}) as list
columns.
\item \code{NULL} values are converted to the string \code{"NULL"}.
\item Failed evaluations result in \code{NA}.
\item Additional named arguments passed via \code{...} in the parent function are also
recorded.
}

The function must be called from within another function, as it relies on
\code{sys.call(-1)} to capture the parent call.
}
\examples{
a <- 5
b <- 3
w_values <- 1:3
x_values <- c(a + b, 10, 15)
y_values <- c("ABCD", "XYZ123", "TEST")

Function1 <- function(w = 5, x, y, z = c(1, 2), ...) {
  Args <- record_arguments()
  return(Args)
}

# ----------------------------------------------------
# Example 1: Simple function call with scalar and expression
# ----------------------------------------------------

Function1(x = a + b, y = 2)

# ----------------------------------------------------
# Example 2: Using lapply with indexed arguments
# ----------------------------------------------------

lapply(
  X = 1:3,
  FUN = function(Z) {
    Function1(
      w = w_values[Z],
      x = x_values[Z],
      y = stringr::str_extract(y_values[Z], "B.+$"),
      z = Z)
}) \%>\%
dplyr::bind_rows() \%>\%
print()

# ----------------------------------------------------
# Example 3: Using pmap with mixed argument types
# ----------------------------------------------------

purrr::pmap(
  .l = list(w = w_values, x = x_values, y = y_values),
  .f = function(w, x, y) {
    Function1(
      w = w,
      x = x,
      y = stringr::str_extract(y, "B.+$"),
      z = terra::rast(system.file("ex/elev.tif", package = "terra")))
  }) \%>\%
  dplyr::bind_rows() \%>\%
  print()

# ----------------------------------------------------
# Example 4: Using additional arguments via ...
# ----------------------------------------------------

Function1(x = a + b, y = "test", extra1 = "hello", extra2 = 42)

}
\author{
Ahmed El-Gabbas
}
