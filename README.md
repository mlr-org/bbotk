# bbotk - Black-Box Optimization Toolkit

Package website: [release](https://bbotk.mlr-org.com/)

<!-- badges: start -->
[![tic](https://github.com/mlr-org/bbotk/workflows/tic/badge.svg?branch=master)](https://github.com/mlr-org/bbotk/actions)
[![CRAN Status Badge](https://www.r-pkg.org/badges/version-ago/bbotk)](https://cran.r-project.org/package=bbotk)
[![codecov.io](https://codecov.io/github/mlr-org/bbotk/coverage.svg?branch=master)](https://codecov.io/gh/mlr-org/bbotk?branch=master)
<!-- badges: end -->

This package provides a common framework for optimization including 

* `Optimizer`: Objects of this class allow you to optimize an object of the class `OptimInstance`.
* `OptimInstance`: Defines the optimization problem, consisting of an `Objective`, the `search_space` and a `Terminator`. 
   All evaluations on the `OptimInstance` will be automatically stored in its own `Archive`.
* `Objective`: Objects of this class contain the objective function. 
   The class ensures that the objective function is called in the right way and defines, whether the function should be minimized or maximized.
* `Terminator`: Objects of this class control the termination of the optimization independent of the optimizer.  

Various optimization methods are already implemented e.g. grid search, random search and generalized simulated annealing. 

## Installation

CRAN version

```{r}
install.packages("bbotk")
```

Development version

```{r}
remotes::install_github("mlr-org/bbotk")
```

## Example

```{r}
library(bbotk)
library(paradox)

# Define objective function
fun = function(xs) {
  - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
}

# Set domain
domain = ParamSet$new(list(
  ParamDbl$new("x1", -10, 10), 
  ParamDbl$new("x2", -5, 5)
))

# Set codomain
codomain = ParamSet$new(list(
  ParamDbl$new("y", tags = "maximize")
))

# Create Objective object
obfun = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain, 
  properties = "deterministic"
)

# Define termination criterion
terminator = term("evals", n_evals = 20)

# Create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = obfun, 
  terminator = terminator
)

# Load optimizer
optimizer = opt("gensa")

# Trigger optimization
optimizer$optimize(instance)

# View results
instance$result
```
