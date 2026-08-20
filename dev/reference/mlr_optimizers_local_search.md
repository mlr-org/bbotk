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

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchLocalSearch`

## Methods

### Public methods

- [`OptimizerBatchLocalSearch$new()`](#method-OptimizerBatchLocalSearch-initialize)

- [`OptimizerBatchLocalSearch$clone()`](#method-OptimizerBatchLocalSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchLocalSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchLocalSearch$new()

------------------------------------------------------------------------

### `OptimizerBatchLocalSearch$clone()`

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
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.095615 -3.078378 <list[2]> 9.175946

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>         x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>      <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>   1:    -8  -2.5   -99 2026-08-20 09:01:18        1          -8        -2.5
#>   2:    -4  -0.3   -28 2026-08-20 09:01:18        1          -4        -0.3
#>   3:    -3   0.5   -27 2026-08-20 09:01:18        1          -3         0.5
#>   4:    -2  -2.5    -3 2026-08-20 09:01:18        1          -2        -2.5
#>   5:     2  -2.1     9 2026-08-20 09:01:18        1           2        -2.1
#>  ---                                                                       
#> 106:    -7   0.5   -84 2026-08-20 09:01:18        2          -7         0.5
#> 107:    -8   1.2   -98 2026-08-20 09:01:18        2          -8         1.2
#> 108:    -7   0.9   -86 2026-08-20 09:01:18        2          -7         0.9
#> 109:    -7   2.8  -105 2026-08-20 09:01:18        2          -7         2.8
#> 110:    -9   1.2  -125 2026-08-20 09:01:18        2          -9         1.2

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.095615 -3.078378 <list[2]> 9.175946
```
