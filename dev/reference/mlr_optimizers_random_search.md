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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchRandomSearch`

## Methods

### Public methods

- [`OptimizerBatchRandomSearch$new()`](#method-OptimizerBatchRandomSearch-new)

- [`OptimizerBatchRandomSearch$clone()`](#method-OptimizerBatchRandomSearch-clone)

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

    OptimizerBatchRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

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
#>           x1        x2  x_domain        y
#>        <num>     <num>    <list>    <num>
#> 1: 0.7310295 -4.649834 <list[2]> 5.667762

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:  -8.2  -0.1  -103 2025-12-13 11:32:49        1        -8.2        -0.1
#>  2:  -5.0  -2.4   -40 2025-12-13 11:32:49        1        -5.0        -2.4
#>  3:  -2.2  -0.8   -13 2025-12-13 11:32:49        1        -2.2        -0.8
#>  4:  -8.1  -2.0   -92 2025-12-13 11:32:49        1        -8.1        -2.0
#>  5:  -0.9  -4.7    -2 2025-12-13 11:32:49        1        -0.9        -4.7
#>  6:   7.5  -2.6   -20 2025-12-13 11:32:49        1         7.5        -2.6
#>  7:  -3.9   2.4   -54 2025-12-13 11:32:49        1        -3.9         2.4
#>  8:  -9.8   2.1  -154 2025-12-13 11:32:49        1        -9.8         2.1
#>  9:   8.8   2.9   -71 2025-12-13 11:32:49        1         8.8         2.9
#> 10:   8.7  -1.3   -38 2025-12-13 11:32:49        1         8.7        -1.3
#> 11:   2.5  -1.0     6 2025-12-13 11:32:49        2         2.5        -1.0
#> 12:   7.3   2.1   -44 2025-12-13 11:32:49        2         7.3         2.1
#> 13:   4.0   3.1   -31 2025-12-13 11:32:49        2         4.0         3.1
#> 14:   3.1   2.2   -18 2025-12-13 11:32:49        2         3.1         2.2
#> 15:   0.7  -4.6     6 2025-12-13 11:32:49        2         0.7        -4.6
#> 16:  -2.3  -3.2    -8 2025-12-13 11:32:49        2        -2.3        -3.2
#> 17:   8.9   4.4   -93 2025-12-13 11:32:49        2         8.9         4.4
#> 18:   7.5   4.7   -80 2025-12-13 11:32:49        2         7.5         4.7
#> 19:  -2.9  -2.6   -14 2025-12-13 11:32:49        2        -2.9        -2.6
#> 20:   4.7   1.6   -18 2025-12-13 11:32:49        2         4.7         1.6
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2

# best performing configuration
instance$result
#>           x1        x2  x_domain        y
#>        <num>     <num>    <list>    <num>
#> 1: 0.7310295 -4.649834 <list[2]> 5.667762
```
