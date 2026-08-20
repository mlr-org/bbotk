# Optimization via Grid Search

`OptimizerBatchGridSearch` class that implements grid search. The grid
is constructed as a Cartesian product over discretized values per
parameter, see
[`paradox::generate_design_grid()`](https://paradox.mlr-org.com/reference/generate_design_grid.html).
The points of the grid are evaluated in a random order.

In order to support general termination criteria and parallelization, we
evaluate points in a batch-fashion of size `batch_size`. Larger batches
mean we can parallelize more, smaller batches imply a more fine-grained
checking of termination criteria.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("grid_search")
    opt("grid_search")

## Parameters

- `resolution`:

  `integer(1)`  
  Resolution of the grid, see
  [`paradox::generate_design_grid()`](https://paradox.mlr-org.com/reference/generate_design_grid.html).

- `param_resolutions`:

  named [`integer()`](https://rdrr.io/r/base/integer.html)  
  Resolution per parameter, named by parameter ID, see
  [`paradox::generate_design_grid()`](https://paradox.mlr-org.com/reference/generate_design_grid.html).

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

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
-\> `OptimizerBatchGridSearch`

## Methods

### Public methods

- [`OptimizerBatchGridSearch$new()`](#method-OptimizerBatchGridSearch-initialize)

- [`OptimizerBatchGridSearch$clone()`](#method-OptimizerBatchGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchGridSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchGridSearch$new()

------------------------------------------------------------------------

### `OptimizerBatchGridSearch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchGridSearch$clone(deep = FALSE)

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
optimizer = opt("grid_search", resolution = 10)

# trigger optimization
optimizer$optimize(instance)
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.111111 -1.666667 <list[2]> 7.432099

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:     3   0.6    -4 2026-08-20 10:53:26        1           3         0.6
#>  2:     1   1.7   -13 2026-08-20 10:53:26        2           1         1.7
#>  3:     6  -5.0    -7 2026-08-20 10:53:26        3           6        -5.0
#>  4:    10  -0.6   -60 2026-08-20 10:53:26        4          10        -0.6
#>  5:    -8  -0.6   -92 2026-08-20 10:53:26        5          -8        -0.6
#>  6:    -8  -1.7   -87 2026-08-20 10:53:26        6          -8        -1.7
#>  7:    -8  -3.9   -86 2026-08-20 10:53:26        7          -8        -3.9
#>  8:    -8   1.7  -107 2026-08-20 10:53:26        8          -8         1.7
#>  9:     1   2.8   -24 2026-08-20 10:53:26        9           1         2.8
#> 10:    -1   1.7   -21 2026-08-20 10:53:26       10          -1         1.7
#> 11:    -8   2.8  -119 2026-08-20 10:53:26       11          -8         2.8
#> 12:    -8   0.6   -98 2026-08-20 10:53:26       12          -8         0.6
#> 13:     1  -1.7     7 2026-08-20 10:53:26       13           1        -1.7
#> 14:   -10   0.6  -147 2026-08-20 10:53:26       14         -10         0.6
#> 15:     8   1.7   -45 2026-08-20 10:53:26       15           8         1.7
#> 16:    -8   5.0  -150 2026-08-20 10:53:26       16          -8         5.0
#> 17:     3  -0.6     2 2026-08-20 10:53:26       17           3        -0.6
#> 18:     3   5.0   -56 2026-08-20 10:53:26       18           3         5.0
#> 19:     8   0.6   -36 2026-08-20 10:53:26       19           8         0.6
#> 20:     8  -5.0   -27 2026-08-20 10:53:26       20           8        -5.0
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.111111 -1.666667 <list[2]> 7.432099
```
