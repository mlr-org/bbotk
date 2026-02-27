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
#>  1:  -8.1 -2.03   -92 2026-02-27 14:19:48        1        -8.1       -2.03
#>  2:  -0.9 -4.73    -2 2026-02-27 14:19:48        1        -0.9       -4.73
#>  3:   7.5 -2.59   -20 2026-02-27 14:19:48        1         7.5       -2.59
#>  4:  -3.9  2.45   -54 2026-02-27 14:19:48        1        -3.9        2.45
#>  5:  -9.8  2.10  -154 2026-02-27 14:19:48        1        -9.8        2.10
#>  6:   8.8  2.86   -71 2026-02-27 14:19:48        1         8.8        2.86
#>  7:   8.7 -1.29   -38 2026-02-27 14:19:48        1         8.7       -1.29
#>  8:  -0.2  1.24   -13 2026-02-27 14:19:48        1        -0.2        1.24
#>  9:  -4.8  3.63   -80 2026-02-27 14:19:48        1        -4.8        3.63
#> 10:  -1.5  2.02   -28 2026-02-27 14:19:48        1        -1.5        2.02
#> 11:   3.1  2.15   -18 2026-02-27 14:19:48        2         3.1        2.15
#> 12:   0.7 -4.65     6 2026-02-27 14:19:48        2         0.7       -4.65
#> 13:  -2.3 -3.23    -8 2026-02-27 14:19:48        2        -2.3       -3.23
#> 14:   8.9  4.38   -93 2026-02-27 14:19:48        2         8.9        4.38
#> 15:   7.5  4.72   -80 2026-02-27 14:19:48        2         7.5        4.72
#> 16:  -2.9 -2.57   -14 2026-02-27 14:19:48        2        -2.9       -2.57
#> 17:   4.7  1.59   -18 2026-02-27 14:19:48        2         4.7        1.59
#> 18:  -1.9  0.06   -15 2026-02-27 14:19:48        2        -1.9        0.06
#> 19:   4.3 -1.26     2 2026-02-27 14:19:48        2         4.3       -1.26
#> 20:   6.1 -0.77   -12 2026-02-27 14:19:48        2         6.1       -0.77
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>           x1        x2  x_domain        y
#>        <num>     <num>    <list>    <num>
#> 1: 0.7310295 -4.649834 <list[2]> 5.667762
```
