% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bb_optimize.R
\name{bb_optimize}
\alias{bb_optimize}
\alias{bb_optimize.function}
\alias{bb_optimize.Objective}
\title{Black-Box Optimization}
\usage{
bb_optimize(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  ...
)

\method{bb_optimize}{`function`}(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  lower = NULL,
  upper = NULL,
  maximize = FALSE,
  ...
)

\method{bb_optimize}{Objective}(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  search_space = NULL,
  ...
)
}
\arguments{
\item{x}{(\code{function} | \link{Objective}).}

\item{method}{(\code{character(1)} | \link{Optimizer})\cr
Key to retrieve optimizer from \link{mlr_optimizers} dictionary or \link{Optimizer}.}

\item{max_evals}{(\code{integer(1)})\cr
Number of allowed evaluations.}

\item{max_time}{(\code{integer(1)})\cr
Maximum allowed time in seconds.}

\item{...}{(named \code{list()})\cr
Named arguments passed to objective function. Ignored if \link{Objective} is
optimized.}

\item{lower}{(\code{numeric()})\cr
Lower bounds on the parameters. If named, names are used to create the
domain.}

\item{upper}{(\code{numeric()})\cr
Upper bounds on the parameters.}

\item{maximize}{(\code{logical()})\cr
Logical vector used to create the codomain e.g. c(TRUE, FALSE) -> ps(y1 = p_dbl(tags = "maximize"), y2 = pd_dbl(tags = "minimize")).
If named, names are used to create the codomain.}

\item{search_space}{(\link[paradox:ParamSet]{paradox::ParamSet}).}
}
\value{
\code{list} of
\itemize{
\item \code{"par"} - Best found parameters
\item \code{"value"} - Optimal outcome
\item \code{"instance"} - \link{OptimInstanceBatchSingleCrit} | \link{OptimInstanceBatchMultiCrit}
}
}
\description{
This function optimizes a function or \link{Objective} with a given method.
}
\note{
If both \code{max_evals} and \code{max_time} are \code{NULL}, \link{TerminatorNone} is used. This
is useful if the \link{Optimizer} can terminate itself. If both are given,
\link{TerminatorCombo} is created and the optimization stops if the time or
evaluation budget is exhausted.
}
\examples{
# function and bounds
fun = function(xs) {
  -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
}

bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10)

# function and constant
fun = function(xs, c) {
  -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
}

bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10, c = 1)

# objective
fun = function(xs) {
  c(z = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# define domain and codomain using a `ParamSet` from paradox
domain = ps(x1 = p_dbl(-10, 10), x2 = p_dbl(-5, 5))
codomain = ps(z = p_dbl(tags = "minimize"))
objective = ObjectiveRFun$new(fun, domain, codomain)

bb_optimize(objective, method = "random_search", max_evals = 10)
}
