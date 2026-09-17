# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

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

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-initialize)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerAsyncRandomSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### `OptimizerAsyncRandomSearch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncRandomSearch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if a Redis server is available
if (mlr3misc::require_namespaces(c("rush", "redux", "mirai"), quietly = TRUE) &&
  redux::redis_available()) {
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

# start workers
rush::rush_plan(worker_type = "mirai")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)

# load optimizer
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 07:48:04
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 07:48:04
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 07:48:04
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 07:48:04
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 07:48:04
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 07:48:04
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 07:48:04
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 07:48:04
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 07:48:04
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 07:48:04
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 07:48:04
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 07:48:04
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 07:48:04
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 07:48:04
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 07:48:04
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 07:48:04
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 07:48:04
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 07:48:05
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 07:48:05
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 07:48:05
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  2: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  3: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  4: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  5: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  6: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  7: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  8: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#>  9: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 10: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 11: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 12: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 13: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 14: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 15: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 16: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 17: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:04
#> 18: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:05
#> 19: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:05
#> 20: narrow_xinjiangovenator_7665796f 2026-09-17 07:48:05
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 4bdedfd8-d724-42c1-a1fb-2f0fd627e5b9 -2.11085866    3.149893
#>  2: c7f95170-d0a7-4ecf-9336-e36d9b462d09 -8.33732121    3.178398
#>  3: 1fa96b73-6008-430b-aef6-8e7435c91dc2 -7.78396197    2.105379
#>  4: 7577ce36-65ef-4940-8ee8-b7066c9fe162  5.92632791   -4.231512
#>  5: aa2ab80d-baad-434e-abef-0055f3dbe686  0.98995613    2.678818
#>  6: 91cf08b9-a559-4332-8e7c-6fa6819a5482 -3.50214144    1.111543
#>  7: 9d7f1148-2d48-46fe-8ac3-3c6d6f9fc3cf  2.77985531    4.933030
#>  8: 4fc38d36-d371-4d04-a0b7-0883b17f84c7  9.86020590    0.052479
#>  9: bfb69fb1-84a7-44b5-a7b8-55892d274cad -4.77089430    4.984108
#> 10: 3bd29fed-5ec5-4a0f-914d-74da4a558e07  8.62827623    3.264048
#> 11: 818bc739-1bec-4b86-be2c-08897e617f08  5.20608164   -2.035465
#> 12: c1b030ab-6c6e-4c57-84b1-ae531c15e20e -0.97588025    1.013553
#> 13: 9be8a626-98c6-4c83-8653-60d319c28db1 -9.42569878    0.916582
#> 14: a84e02f4-7b44-4a64-8f67-b90c8168a37a  0.07085662    3.202987
#> 15: 1f4d6a71-0c83-495d-a9f0-b10f43fc4bfa -6.61173459    1.705343
#> 16: 6a36444a-1708-4e42-aec8-fae92acf043f  8.34573561    3.714461
#> 17: 36846791-2fbd-4fa6-adc5-3755388f41a1 -8.96971468   -3.263809
#> 18: 3ae86d85-16e1-4f96-9f33-1b4c8e188a2e  1.89838435    2.698046
#> 19: f56c6e29-e084-44c0-b10b-d27912fe8654 -2.71425870    1.813992
#> 20: 395ac8f7-f2eb-490c-8bec-b9074e05a872  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
