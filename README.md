
# bbotk - Black-Box Optimization Toolkit

Package website: [release](https://bbotk.mlr-org.com/) |
[dev](https://bbotk.mlr-org.com/dev/)

<!-- badges: start -->

[![tic](https://github.com/mlr-org/bbotk/workflows/tic/badge.svg?branch=main)](https://github.com/mlr-org/bbotk/actions)
[![CRAN Status
Badge](https://www.r-pkg.org/badges/version-ago/bbotk)](https://cran.r-project.org/package=bbotk)
<!-- badges: end -->

This package provides a common framework for optimization including

  - `Optimizer`: Objects of this class allow you to optimize an object
    of the class `OptimInstance`.
  - `OptimInstance`: Defines the optimization problem, consisting of an
    `Objective`, the `search_space` and a `Terminator`. All evaluations
    on the `OptimInstance` will be automatically stored in its own
    `Archive`.
  - `Objective`: Objects of this class contain the objective function.
    The class ensures that the objective function is called in the right
    way and defines, whether the function should be minimized or
    maximized.
  - `Terminator`: Objects of this class control the termination of the
    optimization independent of the optimizer.

Various optimization methods are already implemented e.g. grid search,
random search and generalized simulated annealing.

## Resources

  - Package
    [vignette](https://cran.r-project.org/web/packages/bbotk/vignettes/bbotk.html)

## Installation

Install the last release from CRAN:

``` r
install.packages("bbotk")
```

Install the development version from GitHub:

``` r
remotes::install_github("mlr-org/bbotk")
```

## Example

``` r
library(bbotk)
```

    ## Loading required package: paradox

``` r
# Define objective function
fun = function(xs) {
  c(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# Set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# Set codomain
codomain = ps(
  y = p_dbl(tags = "maximize")
)

# Create Objective object
obfun = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# Define termination criterion
terminator = trm("evals", n_evals = 20)

# Create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = obfun,
  terminator = terminator
)

# Load optimizer
optimizer = opt("gensa")

# Trigger optimization
optimizer$optimize(instance)
```

    ##    x1 x2  x_domain  y
    ## 1:  2 -3 <list[2]> 10
