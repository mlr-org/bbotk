# Local Search

Implements a simple Local Search, see
[`local_search()`](https://bbotk.mlr-org.com/dev/reference/local_search.md)
for details. Currently, setting initial points is not supported.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("local_search")
    opt("local_search")

## Parameters

The same as for
[`local_search_control()`](https://bbotk.mlr-org.com/dev/reference/local_search_control.md),
with the same defaults (except for `minimize`).

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchLocalSearch`

## Methods

### Public methods

- [`OptimizerBatchLocalSearch$new()`](#method-OptimizerBatchLocalSearch-new)

- [`OptimizerBatchLocalSearch$clone()`](#method-OptimizerBatchLocalSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchLocalSearch$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchLocalSearch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# define the objective function
fun = function(xs) {
  list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
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
optimizer = opt("local_search")

# trigger optimization
optimizer$optimize(instance)
#>          x1        x2  x_domain       y
#>       <num>     <num>    <list>   <num>
#> 1: 2.197966 -2.625208 <list[2]> 9.82034

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>         x1    x2      y           timestamp batch_nr x_domain_x1 x_domain_x2
#>      <num> <num>  <num>              <POSc>    <int>       <num>       <num>
#>   1:   4.9  -2.0    0.5 2025-11-07 11:51:25        1         4.9        -2.0
#>   2:  -8.7  -1.0 -108.1 2025-11-07 11:51:25        1        -8.7        -1.0
#>   3:  -2.6  -1.4  -13.5 2025-11-07 11:51:25        1        -2.6        -1.4
#>   4:   3.2  -0.9    4.2 2025-11-07 11:51:25        1         3.2        -0.9
#>   5:   0.7  -4.8    5.1 2025-11-07 11:51:25        1         0.7        -4.8
#>  ---                                                                        
#> 106:   1.1  -0.5    2.8 2025-11-07 11:51:26        2         1.1        -0.5
#> 107:   1.7   1.8  -13.5 2025-11-07 11:51:26        2         1.7         1.8
#> 108:   1.7   0.4   -1.7 2025-11-07 11:51:26        2         1.7         0.4
#> 109:   0.2  -0.5    0.5 2025-11-07 11:51:26        2         0.2        -0.5
#> 110:  -0.8  -0.5   -4.5 2025-11-07 11:51:26        2        -0.8        -0.5

# best performing configuration
instance$result
#>          x1        x2  x_domain       y
#>       <num>     <num>    <list>   <num>
#> 1: 2.197966 -2.625208 <list[2]> 9.82034
```
