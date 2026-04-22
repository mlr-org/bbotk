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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchGridSearch`

## Methods

### Public methods

- [`OptimizerBatchGridSearch$new()`](#method-OptimizerBatchGridSearch-new)

- [`OptimizerBatchGridSearch$clone()`](#method-OptimizerBatchGridSearch-clone)

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

    OptimizerBatchGridSearch$new()

------------------------------------------------------------------------

### Method `clone()`

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
#> 1: 3.333333 -1.666667 <list[2]> 6.444444

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2      y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num>  <num>              <POSc>    <int>       <num>       <num>
#>  1:    -1  -3.9   -0.5 2026-04-22 10:04:41        1          -1        -3.9
#>  2:     8   5.0  -87.4 2026-04-22 10:04:41        2           8         5.0
#>  3:     3   3.9  -39.2 2026-04-22 10:04:41        3           3         3.9
#>  4:    -1   0.6  -12.3 2026-04-22 10:04:41        4          -1         0.6
#>  5:    -6   3.9  -94.5 2026-04-22 10:04:41        5          -6         3.9
#>  6:   -10   1.7 -155.8 2026-04-22 10:04:41        6         -10         1.7
#>  7:    -8   0.6  -98.2 2026-04-22 10:04:41        7          -8         0.6
#>  8:     3   2.8  -25.2 2026-04-22 10:04:41        8           3         2.8
#>  9:    -8   3.9 -133.1 2026-04-22 10:04:41        9          -8         3.9
#> 10:    -6  -1.7  -48.9 2026-04-22 10:04:41       10          -6        -1.7
#> 11:    -3  -5.0  -22.4 2026-04-22 10:04:41       11          -3        -5.0
#> 12:    10   2.8  -87.4 2026-04-22 10:04:41       12          10         2.8
#> 13:    -6   1.7  -68.9 2026-04-22 10:04:41       13          -6         1.7
#> 14:   -10  -3.9 -134.8 2026-04-22 10:04:41       14         -10        -3.9
#> 15:    -3   1.7  -40.2 2026-04-22 10:04:41       15          -3         1.7
#> 16:     3  -1.7    6.4 2026-04-22 10:04:41       16           3        -1.7
#> 17:     6  -0.6   -8.6 2026-04-22 10:04:41       17           6        -0.6
#> 18:    10  -0.6  -60.0 2026-04-22 10:04:42       18          10        -0.6
#> 19:     3  -5.0    4.2 2026-04-22 10:04:42       19           3        -5.0
#> 20:     1   5.0  -54.8 2026-04-22 10:04:42       20           1         5.0
#>        x1    x2      y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num>  <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 3.333333 -1.666667 <list[2]> 6.444444
```
