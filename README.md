
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

### Quick optimization with `bb_optimize`

``` r
library(bbotk)

# define objective function
fun = function(xs) {
  c(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# optimize function with random search
result = bb_optimize(fun, method = "random_search", lower = c(-10, -5), upper = c(10, 5), max_evals = 100)

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

### Advanced optimization

``` r
# define objective function
fun = function(xs) {
  c(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
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

    ##           x1        x2  x_domain        y
    ## 1: 0.3359377 -2.310494 <list[2]> 6.755478

``` r
# best performing configuration
instance$result
```

    ##           x1        x2  x_domain        y
    ## 1: 0.3359377 -2.310494 <list[2]> 6.755478

``` r
# all evaluated configuration
as.data.table(instance$archive)
```

    ##             x1        x2          y           timestamp batch_nr x_domain_x1 x_domain_x2
    ##  1:  0.3359367 -2.310494   6.755475 2021-09-13 11:23:14        1   0.3359367   -2.310494
    ##  2: -0.9046005  4.567793 -55.708198 2021-09-13 11:23:14        2  -0.9046005    4.567793
    ##  3: -7.8034191 -2.551681 -86.308016 2021-09-13 11:23:14        3  -7.8034191   -2.551681
    ##  4: -8.3482136 -2.551681 -97.286514 2021-09-13 11:23:14        4  -8.3482136   -2.551681
    ##  5: -8.3482136 -1.985619 -98.114492 2021-09-13 11:23:14        5  -8.3482136   -1.985619
    ##  6:  0.3359367 -2.310494   6.755475 2021-09-13 11:23:14        6   0.3359367   -2.310494
    ##  7:  0.3359377 -2.310494   6.755478 2021-09-13 11:23:14        7   0.3359377   -2.310494
    ##  8:  0.3359357 -2.310494   6.755472 2021-09-13 11:23:14        8   0.3359357   -2.310494
    ##  9:  0.3359367 -2.310493   6.755474 2021-09-13 11:23:14        9   0.3359367   -2.310493
    ## 10:  0.3359367 -2.310495   6.755476 2021-09-13 11:23:14       10   0.3359367   -2.310495
