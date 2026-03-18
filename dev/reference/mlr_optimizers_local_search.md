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
#>         x1        x2  x_domain        y
#>      <num>     <num>    <list>    <num>
#> 1: 1.30762 -3.111123 <list[2]> 9.508261

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>         x1    x2      y           timestamp batch_nr x_domain_x1 x_domain_x2
#>      <num> <num>  <num>              <POSc>    <int>       <num>       <num>
#>   1:  -2.7   0.1 -21.81 2026-03-18 14:01:03        1        -2.7         0.1
#>   2:   1.3  -3.7   8.99 2026-03-18 14:01:03        1         1.3        -3.7
#>   3:   3.3   1.2  -9.03 2026-03-18 14:01:03        1         3.3         1.2
#>   4:  -5.9   3.1 -89.21 2026-03-18 14:01:03        1        -5.9         3.1
#>   5:  -3.9   4.7 -83.85 2026-03-18 14:01:03        1        -3.9         4.7
#>  ---                                                                        
#> 106:  -1.2  -3.3  -0.04 2026-03-18 14:01:04        2        -1.2        -3.3
#> 107:   2.4  -3.8   9.13 2026-03-18 14:01:04        2         2.4        -3.8
#> 108:   2.6  -3.8   8.92 2026-03-18 14:01:04        2         2.6        -3.8
#> 109:  -2.0  -3.8  -6.96 2026-03-18 14:01:04        2        -2.0        -3.8
#> 110:   0.4  -3.8   6.74 2026-03-18 14:01:04        2         0.4        -3.8

# best performing configuration
instance$result
#>         x1        x2  x_domain        y
#>      <num>     <num>    <list>    <num>
#> 1: 1.30762 -3.111123 <list[2]> 9.508261
```
