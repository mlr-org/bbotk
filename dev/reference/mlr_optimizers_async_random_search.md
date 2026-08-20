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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-08-20 10:53:20
#>  2: finished -8.33732121  3.178398 -135.032815 2026-08-20 10:53:20
#>  3: finished -7.78396197  2.105379 -111.790803 2026-08-20 10:53:20
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-08-20 10:53:20
#>  5: finished  0.98995613  2.678818  -23.269168 2026-08-20 10:53:20
#>  6: finished -3.50214144  1.111543  -37.178342 2026-08-20 10:53:20
#>  7: finished  2.77985531  4.933030  -53.541141 2026-08-20 10:53:20
#>  8: finished  9.86020590  0.052479  -61.100465 2026-08-20 10:53:20
#>  9: finished -4.77089430  4.984108  -99.590989 2026-08-20 10:53:20
#> 10: finished  8.62827623  3.264048  -73.172348 2026-08-20 10:53:20
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-08-20 10:53:20
#> 12: finished -0.97588025  1.013553  -14.964468 2026-08-20 10:53:20
#> 13: finished -9.42569878  0.916582 -135.886207 2026-08-20 10:53:20
#> 14: finished  0.07085662  3.202987  -32.198639 2026-08-20 10:53:20
#> 15: finished -6.61173459  1.705343  -86.302224 2026-08-20 10:53:20
#> 16: finished  8.34573561  3.714461  -75.352353 2026-08-20 10:53:20
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-08-20 10:53:20
#> 18: finished  1.89838435  2.698046  -22.478057 2026-08-20 10:53:20
#> 19: finished -2.71425870  1.813992  -35.398750 2026-08-20 10:53:20
#> 20: finished  1.30114551 -4.177370    8.125403 2026-08-20 10:53:20
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  2: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  3: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  4: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  5: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  6: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  7: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  8: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>  9: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 10: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 11: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 12: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 13: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 14: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 15: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 16: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 17: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 18: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 19: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#> 20: narrow_xinjiangovenator_97f8bb66 2026-08-20 10:53:20
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: b01a9383-efae-4ea8-8cac-911aa5104736 -2.11085866    3.149893
#>  2: be9124a2-1fe5-4d9c-b056-d3242e6250ed -8.33732121    3.178398
#>  3: 14204c82-e5c3-4015-9054-c5dff0720b1c -7.78396197    2.105379
#>  4: bd9b8246-c003-4f97-99ba-31835e49a9b2  5.92632791   -4.231512
#>  5: 8f6fdd8f-4797-4887-9bdb-d716e08aaef4  0.98995613    2.678818
#>  6: 79a2e083-aa83-433f-bb79-1c339edb7b68 -3.50214144    1.111543
#>  7: de2c8575-535b-4696-b4ed-c186120ddcdc  2.77985531    4.933030
#>  8: 84c95e06-a3be-4fc8-9b80-95ee520e3f19  9.86020590    0.052479
#>  9: 3da2d6d3-512f-4280-97f2-7ca62fd57cb8 -4.77089430    4.984108
#> 10: ad814789-c098-4bbd-bc28-d80e0eee5332  8.62827623    3.264048
#> 11: e425930e-6425-44bc-808b-9280b04133d2  5.20608164   -2.035465
#> 12: bf8e5c1a-b422-41b5-999a-4dc222b86248 -0.97588025    1.013553
#> 13: b5968efa-6126-40ef-9f3d-e5d559ba385f -9.42569878    0.916582
#> 14: 975c2c86-ad12-4368-bf22-abddad45b3d3  0.07085662    3.202987
#> 15: 9fa613fb-1eef-41c9-b368-1b074731335f -6.61173459    1.705343
#> 16: 83a1f17f-db85-45d8-8a76-50ea062157b8  8.34573561    3.714461
#> 17: 9c746b91-6104-4620-9270-bcbca9a5623c -8.96971468   -3.263809
#> 18: f53b1d0f-415e-47a6-a745-9c58d324e256  1.89838435    2.698046
#> 19: b0687cfb-6ef6-4c8f-9119-bdc35727f054 -2.71425870    1.813992
#> 20: 05bdbfe8-42f9-451b-a764-d9376f55433c  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
