
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
optimization algorithms e.g. Random Search, Iterated Racing, Bayesian
Optimization (in [mlr3mbo](https://github.com/mlr-org/mlr3mbo)) and
Hyperband (in
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
-   Learn about log transformations in the [search
    space](https://mlr3book.mlr-org.com/chapters/chapter4/hyperparameter_optimization.html#sec-logarithmic-transformations).
-   Or more advanced [search space
    transformations](https://mlr3book.mlr-org.com/chapters/chapter4/hyperparameter_optimization.html#sec-tune-trafo).
-   Learn about [multi-objective
    optimization](https://mlr3book.mlr-org.com/chapters/chapter5/advanced_tuning_methods_and_black_box_optimization.html#sec-multi-metrics-tuning).
-   The [mlr3viz](https://github.com/mlr-org/mlr3viz) package can be
    used to
    [visualize](https://mlr-org.com/gallery/technical/2022-12-22-mlr3viz/#tuning-instance)
    the optimization process.

## Installation

Install the latest release from CRAN.

``` r
install.packages("bbotk")
```

Install the development version from GitHub.

``` r
pak::pkg_install("mlr-org/bbotk")
```

## Examples

The package includes the basic building blocks of optimization:

-   `Optimizer`: Objects of this class allow you to optimize an object
    of the class `OptimInstance`.
-   `OptimInstance`: Defines the optimization problem, consisting of an
    `Objective`, the `search_space`, and a `Terminator`. All evaluations
    on the `OptimInstance` will be automatically stored in its own
    `Archive`.
-   `Objective`: Objects of this class contain the objective function.
    The class ensures that the objective function is called in the right
    way and defines, whether the function should be minimized or
    maximized.
-   `Terminator`: Objects of this class control the termination of the
    optimization independent of the optimizer.

bbotk supports user-defined batch parallelization and asynchronous high
performance parallelization with [Redis](https://redis.io/). The batch
parallelization is defined wit the classes `OptimizerBatch`,
`OptimInstanceBatchSingleCrit` and `OptimInstanceBatchMultiCrit`. The
asynchronous parallelization is defined with the classes
`OptimizerAsync`, `OptimInstanceAsyncSingleCrit` and
`OptimInstanceAsyncMultiCrit`. The package includes several optimizers.
Optimizers are constructed by calling the `opt(key)` function with the
optimizer’s key.

| Optimizer                                       | Key                 | Properties                             | Packages       |
|:------------------------------------------------|:--------------------|:---------------------------------------|:---------------|
| Design Points                                   | async_design_points | dependencies, single-crit , multi-crit | bbotk, rush    |
| Asynchronous Grid Search                        | async_grid_search   | dependencies, single-crit , multi-crit | bbotk, rush    |
| Asynchronous Random Search                      | async_random_search | dependencies, single-crit , multi-crit | bbotk, rush    |
| Covariance Matrix Adaptation Evolution Strategy | cmaes               | single-crit                            | bbotk , adagio |
| Design Points                                   | design_points       | dependencies, single-crit , multi-crit | bbotk          |
| Focus Search                                    | focus_search        | dependencies, single-crit              | bbotk          |
| Generalized Simulated Annealing                 | gensa               | single-crit                            | bbotk, GenSA   |
| Grid Search                                     | grid_search         | dependencies, single-crit , multi-crit | bbotk          |
| Iterated Racing                                 | irace               | dependencies, single-crit              | bbotk, irace   |
| Non-linear Optimization                         | nloptr              | single-crit                            | bbotk , nloptr |
| Random Search                                   | random_search       | dependencies, single-crit , multi-crit | bbotk          |

More optimizers can be found in
[mlr3mbo](https://github.com/mlr-org/bbotk),
[mlr3hyperband](https://github.com/mlr-org/mlr3hyperband) and
[miesmuschel](https://github.com/mlr-org/miesmuschel).

### Optimization

In the following we will use `bbotk` to minimize this function:

``` r
fun = function(xs) {
  c(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}
```

First we need to wrap `fun` inside an `Objective` object. For functions
that expect a list as input we can use the `ObjectiveRFun` class.
Additionally, we need to specify the domain, i.e. the space of x-values
that the function accepts as an input. Optionally, we can define the
co-domain, i.e. the output space of our objective function. This is only
necessary if we want to deviate from the default which would define the
output to be named *y* and be minimized. Such spaces are defined using
the package [`paradox`](https://github.com/mlr-org/paradox).

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

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)
```

In the next step we decide when the optimization should stop. We can
list all available terminators with the `trms()` function.

``` r
trms()
```

    ## <DictionaryTerminator> with 8 stored values
    ## Keys: clock_time, combo, evals, none, perf_reached, run_time, stagnation,
    ##   stagnation_batch

The termination should stop, when 20 evaluations are reached.

``` r
terminator = trm("evals", n_evals = 20)
```

Before we finally start the optimization, we have to create an
`OptimInstance` that contains also the `Objective` and the `Terminator`.
The `OptimInstance` is created with the `oi()` function.

``` r
# create optimization instance
instance = oi(
  objective = objective,
  terminator = terminator
)
instance
```

    ## <OptimInstanceBatchSingleCrit>
    ## * State:  Not optimized
    ## * Objective: <ObjectiveRFun:function>
    ## * Search Space:
    ##    id    class lower upper nlevels
    ## 1: x1 ParamDbl   -10    10     Inf
    ## 2: x2 ParamDbl    -5     5     Inf
    ## * Terminator: <TerminatorEvals>

Note, that `OptimInstance` also has an optional `search_space` argument.
It can be used if the `search_space` is only a subset of `obfun$domain`
or if you want to apply transformations.

Finally, we have to define an `Optimizer`. We opt for evolutionary
optimizer, from the `GenSA` package.

``` r
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
    ##  1: -4.689827 -1.278761 -37.716445 2024-08-12 17:12:37        1   -4.689827   -1.278761
    ##  2: -5.930364 -4.400474 -54.851999 2024-08-12 17:12:37        2   -5.930364   -4.400474
    ##  3:  7.170817 -1.519948 -18.927907 2024-08-12 17:12:37        3    7.170817   -1.519948
    ##  4:  2.045200 -1.519948   7.807403 2024-08-12 17:12:37        4    2.045200   -1.519948
    ##  5:  2.045200 -2.064742   9.123250 2024-08-12 17:12:37        5    2.045200   -2.064742
    ## ---                                                                                    
    ## 16:  2.000000 -3.000000  10.000000 2024-08-12 17:12:37       16    2.000000   -3.000000
    ## 17:  2.000001 -3.000000  10.000000 2024-08-12 17:12:37       17    2.000001   -3.000000
    ## 18:  1.999999 -3.000000  10.000000 2024-08-12 17:12:37       18    1.999999   -3.000000
    ## 19:  2.000000 -2.999999  10.000000 2024-08-12 17:12:37       19    2.000000   -2.999999
    ## 20:  2.000000 -3.000001  10.000000 2024-08-12 17:12:37       20    2.000000   -3.000001

The archive contains all evaluated configurations and their
corresponding performance. We can use less code by using the
[`bb_optimize`](https://bbotk.mlr-org.com/reference/bb_optimize.html)
function.
