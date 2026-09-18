# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-initialize)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerAsync.html#method-optimize)

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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-18 09:12:16
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-18 09:12:16
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-18 09:12:16
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-18 09:12:16
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-18 09:12:16
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-18 09:12:16
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-18 09:12:16
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-18 09:12:16
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-18 09:12:16
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-18 09:12:16
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-18 09:12:16
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-18 09:12:16
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-18 09:12:16
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-18 09:12:16
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-18 09:12:16
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-18 09:12:16
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-18 09:12:16
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-18 09:12:16
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-18 09:12:16
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-18 09:12:17
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  2: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  3: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  4: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  5: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  6: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  7: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  8: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#>  9: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 10: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 11: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 12: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 13: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 14: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 15: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 16: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 17: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 18: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 19: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:16
#> 20: narrow_xinjiangovenator_67b61609 2026-09-18 09:12:17
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 18d30539-30bb-4a75-b0f6-0377550e5f39 -2.11085866    3.149893
#>  2: 54701205-3bf2-49ca-ab74-5d640f85f662 -8.33732121    3.178398
#>  3: 8d67fbf4-a5bc-48f9-b444-a19de3b5128a -7.78396197    2.105379
#>  4: e60bc8eb-131b-44f8-9d55-438bdf31deae  5.92632791   -4.231512
#>  5: cbb9193b-e973-4b75-b275-3b5cc6f4abde  0.98995613    2.678818
#>  6: e1182e82-a8bb-4236-a6d9-27e1262c5e3f -3.50214144    1.111543
#>  7: b0fd33ac-1414-42ec-abc8-de4435622822  2.77985531    4.933030
#>  8: 09c17159-ae13-4c85-a1f5-e36ee579aa14  9.86020590    0.052479
#>  9: 378cc5e0-d272-44de-8213-d3732a345628 -4.77089430    4.984108
#> 10: ee3baff2-a00a-4010-9e49-9d0667549554  8.62827623    3.264048
#> 11: 595f7640-f8b6-4031-a6a4-cd0639de30dd  5.20608164   -2.035465
#> 12: a6c8839a-d2f3-4878-8205-85c185b40abb -0.97588025    1.013553
#> 13: 421a783d-72f0-49a9-ae74-fa97e6ef22dc -9.42569878    0.916582
#> 14: 0da413bd-719b-44d8-8a50-98c71ae85082  0.07085662    3.202987
#> 15: b5ad86ad-50b6-452e-8a90-78eed0aa686f -6.61173459    1.705343
#> 16: 0f8248c0-7f9f-4694-b48e-c69d2d418e90  8.34573561    3.714461
#> 17: ff84fe82-c68a-4846-aaf5-447708b88f0d -8.96971468   -3.263809
#> 18: 6efdc0cb-16ed-4a52-9d4a-1cb4290e4ed3  1.89838435    2.698046
#> 19: 77f8d4ba-c8d6-436c-8a43-b58f8df3e5c7 -2.71425870    1.813992
#> 20: a7d7b75d-6926-4768-aa82-041e8faa47c7  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
