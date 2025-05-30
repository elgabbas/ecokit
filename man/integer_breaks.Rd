% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_integer_breaks.R
\name{integer_breaks}
\alias{integer_breaks}
\title{Integer breaks for ggplot axis}
\usage{
integer_breaks(n_breaks = 5L, ...)
}
\arguments{
\item{n_breaks}{integer (default: 5), the desired number of breaks on the
axis. Note that the actual number of breaks may slightly differ from what
is requested.}

\item{...}{additional arguments passed on to \link[base:pretty]{base::pretty}.}
}
\value{
A function that takes a numeric vector \code{x} and returns a vector of
integer breaks for the axis, with the names attribute set to the break
labels.
}
\description{
This function generates a function that calculates integer axis values for
ggplot, ensuring that the axis breaks are integers. It is particularly useful
for creating cleaner, more readable plots.
}
\details{
The source of the function is available on this
\href{https://joshuacook.netlify.app/post/integer-values-ggplot-axis/}{link}.
}
\examples{
ggplot2::ggplot(mtcars, ggplot2::aes(x = drat, y = hp)) +
  ggplot2::geom_point() +
  ggplot2::scale_x_continuous()

ggplot2::ggplot(mtcars, ggplot2::aes(x = drat, y = hp)) +
  ggplot2::geom_point() +
  ggplot2::scale_x_continuous(breaks = integer_breaks(5))
}
