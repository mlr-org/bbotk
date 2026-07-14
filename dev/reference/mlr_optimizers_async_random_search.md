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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-14 15:10:25
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-14 15:10:25
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-14 15:10:25
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-14 15:10:25
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-14 15:10:25
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-14 15:10:25
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-14 15:10:25
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-14 15:10:25
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-14 15:10:25
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-14 15:10:25
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-14 15:10:25
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-14 15:10:25
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-14 15:10:25
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-14 15:10:25
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-14 15:10:25
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-14 15:10:25
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-14 15:10:25
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-14 15:10:25
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-14 15:10:25
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-14 15:10:25
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  2: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  3: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  4: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  5: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  6: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  7: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  8: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>  9: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 10: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 11: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 12: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 13: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 14: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 15: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 16: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 17: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 18: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 19: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#> 20: narrow_xinjiangovenator_9b6ac502 2026-07-14 15:10:25
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 9e317dad-36e2-4152-9be4-57a67bfb3d29 -2.11085866    3.149893
#>  2: 5fe470fe-94a6-40db-b23c-59210b73d47e -8.33732121    3.178398
#>  3: d477835a-f66b-4153-880a-fedfc7800f64 -7.78396197    2.105379
#>  4: 3cd51f86-ce00-45f9-9266-57d3e18bf881  5.92632791   -4.231512
#>  5: c91d234e-ffe9-43fc-9a6d-4199826b786d  0.98995613    2.678818
#>  6: bbfef1bb-42fc-4e36-8795-0bf6c4276592 -3.50214144    1.111543
#>  7: 71aba732-ebb4-48d4-9332-d4fa7815efc6  2.77985531    4.933030
#>  8: deafe7f7-ae09-4d6c-8342-ed4f88edead1  9.86020590    0.052479
#>  9: 1c6bbcca-0d68-4574-bc59-2a7772af4f58 -4.77089430    4.984108
#> 10: 4cd6b791-847d-4199-9293-c5c1a0b60179  8.62827623    3.264048
#> 11: 6a78d884-f443-4649-a119-603d69f89346  5.20608164   -2.035465
#> 12: 0621301d-616d-4a88-afdf-539a9481ed59 -0.97588025    1.013553
#> 13: d746c849-99db-4a55-b93f-fba2f566183d -9.42569878    0.916582
#> 14: 02f9fcee-4a43-4add-b486-ae936b9b24fc  0.07085662    3.202987
#> 15: 63dbecfb-0344-4ad3-bf7d-4e068f24ba6f -6.61173459    1.705343
#> 16: d3eb4620-4cfc-4d3c-992e-de84f28405a7  8.34573561    3.714461
#> 17: 90b46bd7-f0fc-4e79-8a0f-65502ad8590b -8.96971468   -3.263809
#> 18: 81b3d6a8-f4d7-493f-bb75-210688990fbe  1.89838435    2.698046
#> 19: b5c64e85-56c1-4c24-90dc-09b90b352d68 -2.71425870    1.813992
#> 20: 0ccf9d7f-b105-4dea-9572-07c318e64bd3  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
