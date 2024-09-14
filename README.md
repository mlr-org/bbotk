
# bbotk - Black-Box Optimization Toolkit

Package website: [release](https://bbotk.mlr-org.com/) \|
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
optimization algorithms e.g. Random Search, Grid Search, Iterated
Racing, Bayesian Optimization (in
[mlr3mbo](https://github.com/mlr-org/mlr3mbo)) and Hyperband (in
[mlr3hyperband](https://github.com/mlr-org/mlr3hyperband)). bbotk is the
base package of [mlr3tuning](https://github.com/mlr-org/mlr3tuning),
[mlr3fselect](https://github.com/mlr-org/mlr3fselect) and
[miesmuschel](https://github.com/mlr-org/miesmuschel).

## Resources

There are several sections about black-box optimization in the
[mlr3book](https://mlr3book.mlr-org.com). Often the sections about
tuning are also relevant for general black-box optimization.

-   Getting started with [black-box
    optimization](https://mlr3book.mlr-org.com/chapters/chapter5/advanced_tuning_methods_and_black_box_optimization.html#sec-black-box-optimization).
-   An overview of all optimizers and tuners can be found on our
    [website](https://mlr-org.com/tuners.html).
-   Learn about log transformations in the [search
    space](https://mlr3book.mlr-org.com/chapters/chapter4/hyperparameter_optimization.html#sec-logarithmic-transformations).
-   Or more advanced [search space
    transformations](https://mlr3book.mlr-org.com/chapters/chapter4/hyperparameter_optimization.html#sec-tune-trafo).
-   Run [multi-objective
    optimization](https://mlr3book.mlr-org.com/chapters/chapter5/advanced_tuning_methods_and_black_box_optimization.html#sec-multi-metrics-tuning).
-   The [mlr3viz](https://github.com/mlr-org/mlr3viz) package can be
    used to
    [visualize](https://mlr-org.com/gallery/technical/2022-12-22-mlr3viz/#tuning-instance)
    the optimization process.
-   Quick optimization with the
    [`bb_optimize`](https://bbotk.mlr-org.com/reference/bb_optimize.html)
    function.

## Installation

Install the latest release from CRAN.

``` r
install.packages("bbotk")
```

Install the development version from GitHub.

``` r
pak::pkg_install("mlr-org/bbotk")
```

## Example

``` r
# define the objective function
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

# create objective
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# initialize instance
instance = oi(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)

# load optimizer
optimizer = opt("gensa")

# trigger optimization
optimizer$optimize(instance)
```

    ##    x1 x2  x_domain  y
    ## 1:  2 -3 <list[2]> 10

``` r
# best performing configuration
instance$result
```

    ##    x1 x2  x_domain  y
    ## 1:  2 -3 <list[2]> 10

``` r
# all evaluated configuration
as.data.table(instance$archive)
```

    ##            x1        x2          y           timestamp batch_nr x_domain_x1 x_domain_x2
    ##  1: -4.689827 -1.278761 -37.716445 2024-08-13 17:52:54        1   -4.689827   -1.278761
    ##  2: -5.930364 -4.400474 -54.851999 2024-08-13 17:52:54        2   -5.930364   -4.400474
    ##  3:  7.170817 -1.519948 -18.927907 2024-08-13 17:52:54        3    7.170817   -1.519948
    ##  4:  2.045200 -1.519948   7.807403 2024-08-13 17:52:54        4    2.045200   -1.519948
    ##  5:  2.045200 -2.064742   9.123250 2024-08-13 17:52:54        5    2.045200   -2.064742
    ## ---                                                                                    
    ## 16:  2.000000 -3.000000  10.000000 2024-08-13 17:52:54       16    2.000000   -3.000000
    ## 17:  2.000001 -3.000000  10.000000 2024-08-13 17:52:54       17    2.000001   -3.000000
    ## 18:  1.999999 -3.000000  10.000000 2024-08-13 17:52:54       18    1.999999   -3.000000
    ## 19:  2.000000 -2.999999  10.000000 2024-08-13 17:52:54       19    2.000000   -2.999999
    ## 20:  2.000000 -3.000001  10.000000 2024-08-13 17:52:54       20    2.000000   -3.000001
