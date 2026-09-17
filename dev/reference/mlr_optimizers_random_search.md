# Optimization via Random Search

`OptimizerBatchRandomSearch` class that implements a simple Random
Search.

In order to support general termination criteria and parallelization, we
evaluate points in a batch-fashion of size `batch_size`. Larger batches
mean we can parallelize more, smaller batches imply a more fine-grained
checking of termination criteria.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("random_search")
    opt("random_search")

## Parameters

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
-\> `OptimizerBatchRandomSearch`

## Methods

### Public methods

- [`OptimizerBatchRandomSearch$new()`](#method-OptimizerBatchRandomSearch-initialize)

- [`OptimizerBatchRandomSearch$clone()`](#method-OptimizerBatchRandomSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchRandomSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchRandomSearch$new()

------------------------------------------------------------------------

### `OptimizerBatchRandomSearch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchRandomSearch$clone(deep = FALSE)

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
optimizer = opt("random_search", batch_size = 10)

# trigger optimization
optimizer$optimize(instance)
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.388184 -4.170693 <list[2]> 8.255159

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1: -0.40   0.8   -10 2026-09-17 09:46:59        1       -0.40         0.8
#>  2: -4.16  -3.4   -28 2026-09-17 09:46:59        1       -4.16        -3.4
#>  3:  1.85  -4.7     7 2026-09-17 09:46:59        1        1.85        -4.7
#>  4:  8.04  -1.5   -29 2026-09-17 09:46:59        1        8.04        -1.5
#>  5: -0.62   1.9   -21 2026-09-17 09:46:59        1       -0.62         1.9
#>  6: -5.04  -1.3   -42 2026-09-17 09:46:59        1       -5.04        -1.3
#>  7: -6.52   2.4   -92 2026-09-17 09:46:59        1       -6.52         2.4
#>  8:  8.87   0.8   -51 2026-09-17 09:46:59        1        8.87         0.8
#>  9:  0.56  -2.0     7 2026-09-17 09:46:59        1        0.56        -2.0
#> 10:  5.98  -3.5    -6 2026-09-17 09:46:59        1        5.98        -3.5
#> 11:  7.95   3.8   -72 2026-09-17 09:46:59        2        7.95         3.8
#> 12: -0.07  -4.0     5 2026-09-17 09:46:59        2       -0.07        -4.0
#> 13:  1.39  -4.2     8 2026-09-17 09:46:59        2        1.39        -4.2
#> 14:  9.31   0.8   -58 2026-09-17 09:46:59        2        9.31         0.8
#> 15:  0.12  -1.6     5 2026-09-17 09:46:59        2        0.12        -1.6
#> 16:  6.01   1.5   -27 2026-09-17 09:46:59        2        6.01         1.5
#> 17: -2.40   3.7   -54 2026-09-17 09:46:59        2       -2.40         3.7
#> 18:  1.61   3.9   -38 2026-09-17 09:46:59        2        1.61         3.9
#> 19:  0.49   0.6    -5 2026-09-17 09:46:59        2        0.49         0.6
#> 20: -5.54   2.1   -73 2026-09-17 09:46:59        2       -5.54         2.1
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.388184 -4.170693 <list[2]> 8.255159
```
