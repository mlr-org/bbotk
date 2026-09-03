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
#>          x1         x2  x_domain       y
#>       <num>      <num>    <list>   <num>
#> 1: 1.566668 -0.2343097 <list[2]> 2.16318

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1     x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num>  <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:  -7.5 -3.411   -80 2026-09-03 11:46:20        1        -7.5      -3.411
#>  2:  -4.6 -1.715   -35 2026-09-03 11:46:20        1        -4.6      -1.715
#>  3:  -8.2  2.961  -129 2026-09-03 11:46:20        1        -8.2       2.961
#>  4:   6.8 -1.387   -16 2026-09-03 11:46:20        1         6.8      -1.387
#>  5:  -5.0  3.733   -85 2026-09-03 11:46:20        1        -5.0       3.733
#>  6:  -1.6  4.537   -60 2026-09-03 11:46:20        1        -1.6       4.537
#>  7:  -8.4 -4.783  -102 2026-09-03 11:46:20        1        -8.4      -4.783
#>  8:  -9.7  4.776  -186 2026-09-03 11:46:20        1        -9.7       4.776
#>  9:  -0.6  0.694   -11 2026-09-03 11:46:20        1        -0.6       0.694
#> 10:   7.4  4.774   -79 2026-09-03 11:46:20        1         7.4       4.774
#> 11:   6.9 -0.008   -23 2026-09-03 11:46:20        2         6.9      -0.008
#> 12:   1.6 -0.234     2 2026-09-03 11:46:20        2         1.6      -0.234
#> 13:   8.0 -1.193   -30 2026-09-03 11:46:20        2         8.0      -1.193
#> 14:  -7.5  0.202   -91 2026-09-03 11:46:20        2        -7.5       0.202
#> 15:  -9.1 -0.207  -121 2026-09-03 11:46:20        2        -9.1      -0.207
#> 16:  -3.9  2.411   -54 2026-09-03 11:46:20        2        -3.9       2.411
#> 17:  -6.9 -3.768   -70 2026-09-03 11:46:20        2        -6.9      -3.768
#> 18:   9.3 -3.079   -44 2026-09-03 11:46:20        2         9.3      -3.079
#> 19:  -4.4 -2.351   -31 2026-09-03 11:46:20        2        -4.4      -2.351
#> 20:   1.7  1.904   -14 2026-09-03 11:46:20        2         1.7       1.904
#>        x1     x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num>  <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1         x2  x_domain       y
#>       <num>      <num>    <list>   <num>
#> 1: 1.566668 -0.2343097 <list[2]> 2.16318
```
