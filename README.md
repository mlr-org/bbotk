
# bbotk - Black-Box Optimization Toolkit

Package website: [release](https://bbotk.mlr-org.com/) |
[dev](https://bbotk.mlr-org.com/dev/)

<!-- badges: start -->

[![r-cmd-check](https://github.com/mlr-org/bbotk/actions/workflows/r-cmd-check.yml/badge.svg)](https://github.com/mlr-org/bbotk/actions/workflows/r-cmd-check.yml)
[![CRAN Status
Badge](https://www.r-pkg.org/badges/version-ago/bbotk)](https://cran.r-project.org/package=bbotk)
[![Mattermost](https://img.shields.io/badge/chat-mattermost-orange.svg)](https://lmmisld-lmu-stats-slds.srv.mwn.de/mlr_invite/)
<!-- badges: end -->

*bbotk* is a black-box optimization framework for R. It features highly
configurable search spaces via the
[paradox](https://github.com/mlr-org/paradox) package and optimizes
every user-defined objective function. The package includes several
optimization algorithms e.g. Random Search, Iterated Racing, Bayesian
Optimization (in [mlr3mbo](https://github.com/mlr-org/mlr3mbo)) and
Hyperband (in
[mlr3hyperband](https://github.com/mlr-org/mlr3hyperband)). bbotk is the
base package of [mlr3tuning](https://github.com/mlr-org/mlr3tuning),
[mlr3fselect](https://github.com/mlr-org/mlr3fselect) and
[miesmuschel](https://github.com/mlr-org/miesmuschel).

The package includes the basis building block of optimization:

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

## Resources

  - Package
    [vignette](https://CRAN.R-project.org/package=bbotk/vignettes/bbotk.html)

## Installation

Install the last release from CRAN:

``` r
install.packages("bbotk")
```

Install the development version from GitHub:

``` r
remotes::install_github("mlr-org/bbotk")
```

## Examples

### Optimization

``` r
# define objective function
fun = function(xs) {
  - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize")
)

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# Define termination criterion
terminator = trm("evals", n_evals = 10)

# create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = objective,
  terminator = terminator
)

# load optimizer
optimizer = opt("gensa")

# trigger optimization
optimizer$optimize(instance)
```

    ##        x1        x2  x_domain        y
    ## 1: 2.0452 -2.064743 <list[2]> 9.123252

``` r
# best performing configuration
instance$result
```

    ##        x1        x2  x_domain        y
    ## 1: 2.0452 -2.064743 <list[2]> 9.123252

``` r
# all evaluated configuration
as.data.table(instance$archive)
```

    ##            x1        x2          y           timestamp batch_nr x_domain_x1 x_domain_x2
    ##  1: -4.689827 -1.278761 -37.716445 2022-11-18 11:12:45        1   -4.689827   -1.278761
    ##  2: -5.930364 -4.400474 -54.851999 2022-11-18 11:12:45        2   -5.930364   -4.400474
    ##  3:  7.170817 -1.519948 -18.927907 2022-11-18 11:12:45        3    7.170817   -1.519948
    ##  4:  2.045200 -1.519948   7.807403 2022-11-18 11:12:45        4    2.045200   -1.519948
    ##  5:  2.045200 -2.064742   9.123250 2022-11-18 11:12:45        5    2.045200   -2.064742
    ##  6:  2.045200 -2.064742   9.123250 2022-11-18 11:12:45        6    2.045200   -2.064742
    ##  7:  2.045201 -2.064742   9.123250 2022-11-18 11:12:45        7    2.045201   -2.064742
    ##  8:  2.045199 -2.064742   9.123250 2022-11-18 11:12:45        8    2.045199   -2.064742
    ##  9:  2.045200 -2.064741   9.123248 2022-11-18 11:12:45        9    2.045200   -2.064741
    ## 10:  2.045200 -2.064743   9.123252 2022-11-18 11:12:45       10    2.045200   -2.064743

### Quick optimization with `bb_optimize`

``` r
library(bbotk)

# define objective function
fun = function(xs) {
  c(y1 = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# optimize function with random search
result = bb_optimize(fun, method = "random_search", lower = c(-10, -5), upper = c(10, 5),
  max_evals = 100)

# optimized parameters
result$par
```

    ##           x1       x2
    ## 1: -7.982537 4.273021

``` r
# optimal outcome
result$value
```

    ##        y1 
    ## -142.5479
