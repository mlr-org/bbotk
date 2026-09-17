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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:30:28
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:30:28
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:30:28
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:30:28
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:30:28
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:30:28
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:30:28
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:30:28
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:30:28
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:30:28
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:30:28
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:30:28
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:30:28
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:30:28
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:30:28
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:30:28
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:30:28
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:30:28
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:30:28
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:30:28
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  2: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  3: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  4: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  5: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  6: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  7: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  8: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>  9: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 10: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 11: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 12: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 13: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 14: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 15: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 16: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 17: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 18: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 19: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#> 20: narrow_xinjiangovenator_d2f3311e 2026-09-17 09:30:28
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 04c535a3-c37b-41ff-92ef-5bfa7c4b43db -2.11085866    3.149893
#>  2: d932ebbe-9b06-489f-a2db-14d1137dafa0 -8.33732121    3.178398
#>  3: f8d790a2-19ec-4412-b945-1ebbf6fec060 -7.78396197    2.105379
#>  4: 8cf9507d-261d-4cb6-b5df-27410da618d8  5.92632791   -4.231512
#>  5: 94b3a961-ce2a-4cec-b906-5f7163784317  0.98995613    2.678818
#>  6: e0321e2f-827c-45a5-85e5-7e2e36fb5909 -3.50214144    1.111543
#>  7: afba4345-e40c-4e4e-99b5-819f8a723119  2.77985531    4.933030
#>  8: ab4df3ea-6093-4cef-9141-51fde1035898  9.86020590    0.052479
#>  9: 7c88e5a0-aa22-4cb8-9cef-96d7330775e5 -4.77089430    4.984108
#> 10: c48de8d5-f354-44a6-ab2b-ddb67a30c8af  8.62827623    3.264048
#> 11: bbe6ca14-3f9c-4fac-a5d3-97f956a10509  5.20608164   -2.035465
#> 12: 3b8239f2-311e-4e39-85fd-bc95d9fc2a82 -0.97588025    1.013553
#> 13: a3d3b8a3-e4d3-44e2-9451-91c70bdebcc5 -9.42569878    0.916582
#> 14: 96e8d75a-2e9a-4744-b572-2d5e56ef93b1  0.07085662    3.202987
#> 15: a42e12e7-966b-4683-8941-aa9cd5102db3 -6.61173459    1.705343
#> 16: c1aa16eb-53d6-4456-816d-dab3668a4738  8.34573561    3.714461
#> 17: 56546ea3-3a64-40de-b184-23870821f66e -8.96971468   -3.263809
#> 18: 5a9f595c-5f6b-4b40-81ff-157952141f51  1.89838435    2.698046
#> 19: 43f378b7-96b5-4508-8633-4b0a41b4dd82 -2.71425870    1.813992
#> 20: ee3fbeb0-fd56-4349-990d-bc147af1177d  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
