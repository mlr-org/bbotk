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
#>          x1        x2  x_domain       y
#>       <num>     <num>    <list>   <num>
#> 1: 1.242137 -2.992694 <list[2]> 9.42559

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:     4  -4.6     5 2026-03-09 09:07:33        1           4        -4.6
#>  2:     6  -2.6   -10 2026-03-09 09:07:33        1           6        -2.6
#>  3:    -6   1.6   -71 2026-03-09 09:07:33        1          -6         1.6
#>  4:     5   0.7   -14 2026-03-09 09:07:33        1           5         0.7
#>  5:    10   2.3   -80 2026-03-09 09:07:33        1          10         2.3
#>  6:     4   0.8   -10 2026-03-09 09:07:33        1           4         0.8
#>  7:    10   0.7   -62 2026-03-09 09:07:33        1          10         0.7
#>  8:     5   1.6   -19 2026-03-09 09:07:33        1           5         1.6
#>  9:    -7   0.3   -84 2026-03-09 09:07:33        1          -7         0.3
#> 10:     1  -2.2     9 2026-03-09 09:07:33        1           1        -2.2
#> 11:     1  -4.5     7 2026-03-09 09:07:33        2           1        -4.5
#> 12:    -1  -4.0    -2 2026-03-09 09:07:33        2          -1        -4.0
#> 13:    -2  -0.5    -9 2026-03-09 09:07:33        2          -2        -0.5
#> 14:     1  -3.0     9 2026-03-09 09:07:33        2           1        -3.0
#> 15:    -5  -4.2   -42 2026-03-09 09:07:33        2          -5        -4.2
#> 16:     7   0.8   -28 2026-03-09 09:07:33        2           7         0.8
#> 17:    10  -3.1   -47 2026-03-09 09:07:33        2          10        -3.1
#> 18:    -8   1.5  -104 2026-03-09 09:07:33        2          -8         1.5
#> 19:    10   3.4   -87 2026-03-09 09:07:33        2          10         3.4
#> 20:     5  -4.1     2 2026-03-09 09:07:33        2           5        -4.1
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1        x2  x_domain       y
#>       <num>     <num>    <list>   <num>
#> 1: 1.242137 -2.992694 <list[2]> 9.42559
```
