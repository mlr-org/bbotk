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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-27 12:50:21
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-27 12:50:21
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-27 12:50:21
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-27 12:50:21
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-27 12:50:22
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-27 12:50:22
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-27 12:50:22
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-27 12:50:22
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-27 12:50:22
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-27 12:50:22
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-27 12:50:22
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-27 12:50:22
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-27 12:50:22
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-27 12:50:22
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-27 12:50:22
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-27 12:50:22
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-27 12:50:22
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-27 12:50:22
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-27 12:50:22
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-27 12:50:22
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-27 12:50:21
#>  2: narrow_xinjiangovenator 2026-06-27 12:50:21
#>  3: narrow_xinjiangovenator 2026-06-27 12:50:21
#>  4: narrow_xinjiangovenator 2026-06-27 12:50:21
#>  5: narrow_xinjiangovenator 2026-06-27 12:50:22
#>  6: narrow_xinjiangovenator 2026-06-27 12:50:22
#>  7: narrow_xinjiangovenator 2026-06-27 12:50:22
#>  8: narrow_xinjiangovenator 2026-06-27 12:50:22
#>  9: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 10: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 11: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 12: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 13: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 14: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 15: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 16: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 17: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 18: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 19: narrow_xinjiangovenator 2026-06-27 12:50:22
#> 20: narrow_xinjiangovenator 2026-06-27 12:50:22
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 2f1d0eea-56f5-49fd-92dc-a2d6731d24aa -2.11085866    3.149893
#>  2: f8a53dc0-9a38-4209-94e0-b14d495931e7 -8.33732121    3.178398
#>  3: 5ea117ac-254a-4839-a381-83a404e245dc -7.78396197    2.105379
#>  4: 676f03fd-dd6b-460f-a6a6-2c780b04f825  5.92632791   -4.231512
#>  5: f30f670b-c3f3-4d23-b97e-7979eef8522d  0.98995613    2.678818
#>  6: 988686c0-fb07-49ed-b9fc-3a3c7e865382 -3.50214144    1.111543
#>  7: b7282d81-5324-421d-bb32-23167816b5f9  2.77985531    4.933030
#>  8: 909e0817-2230-4b00-b9ad-bee9753f257c  9.86020590    0.052479
#>  9: b991e1b5-0e1a-4a9e-b1cb-7c65c25fc2cd -4.77089430    4.984108
#> 10: b71bfe4d-903b-4c47-b811-df67b601d68d  8.62827623    3.264048
#> 11: 1c932790-77fa-4ac8-8d6b-9956e88e67ab  5.20608164   -2.035465
#> 12: f1c44cbb-5515-4a8c-9be5-a26c568691c2 -0.97588025    1.013553
#> 13: 6e2f6157-55d9-47e2-bc37-228261433f92 -9.42569878    0.916582
#> 14: 85c42d62-6cb6-424c-99e7-534829b037cc  0.07085662    3.202987
#> 15: a531405e-5512-4ab3-9052-186843abbc9c -6.61173459    1.705343
#> 16: dc0ffad9-0e4e-4e13-9d42-b8fc7ec43e0c  8.34573561    3.714461
#> 17: 6782e50d-1fc6-4770-a2af-f20d8877d00d -8.96971468   -3.263809
#> 18: 987bae8b-5b11-42d4-88ec-ffe42cd53347  1.89838435    2.698046
#> 19: 8d197313-54e6-4318-b60d-3f9e1fc2a64b -2.71425870    1.813992
#> 20: 40f32411-a70e-4da5-94f6-69970758fb6d  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
