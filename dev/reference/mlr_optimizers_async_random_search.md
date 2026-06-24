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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-24 06:52:15
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-24 06:52:15
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-24 06:52:16
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-24 06:52:16
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-24 06:52:16
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-24 06:52:16
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-24 06:52:16
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-24 06:52:16
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-24 06:52:16
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-24 06:52:16
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-24 06:52:16
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-24 06:52:16
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-24 06:52:16
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-24 06:52:16
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-24 06:52:16
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-24 06:52:16
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-24 06:52:16
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-24 06:52:16
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-24 06:52:16
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-24 06:52:16
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-24 06:52:15
#>  2: narrow_xinjiangovenator 2026-06-24 06:52:15
#>  3: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  4: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  5: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  6: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  7: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  8: narrow_xinjiangovenator 2026-06-24 06:52:16
#>  9: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 10: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 11: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 12: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 13: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 14: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 15: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 16: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 17: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 18: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 19: narrow_xinjiangovenator 2026-06-24 06:52:16
#> 20: narrow_xinjiangovenator 2026-06-24 06:52:16
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 17459bbe-6dde-4aa4-a69c-6cc21180b65b -2.11085866    3.149893
#>  2: b9ad107e-8a09-4475-8fc1-857e7d47e4d2 -8.33732121    3.178398
#>  3: dc590556-edc3-4b3f-8360-c195b7d153ab -7.78396197    2.105379
#>  4: 2f9c8f5a-a27d-4cf6-abba-9a83afc5fcce  5.92632791   -4.231512
#>  5: 850d9f4d-7ebb-4646-a5be-092f8c554aa2  0.98995613    2.678818
#>  6: 96d9a3af-d4b5-4220-9fb3-4bda5fdb53fd -3.50214144    1.111543
#>  7: 523ba8ba-2783-4cf2-9602-401aba96ece0  2.77985531    4.933030
#>  8: 1fa70263-d688-4eb3-8f32-99b12820efd1  9.86020590    0.052479
#>  9: 9dd92e68-7593-46eb-9947-75913edd6046 -4.77089430    4.984108
#> 10: 5a2a4a51-17d8-4a3c-849c-b8fd6a8aa56b  8.62827623    3.264048
#> 11: 1ef84a5d-4de3-44b2-8eeb-d7d65c38c569  5.20608164   -2.035465
#> 12: be492365-63c9-482b-aab8-7d12c72559b4 -0.97588025    1.013553
#> 13: 30490d1a-1650-464d-bcd4-9ec3d8995ee7 -9.42569878    0.916582
#> 14: b32a09e8-472e-41d6-a96c-3ebb1200f272  0.07085662    3.202987
#> 15: 4142b426-2cbe-49c9-aa8c-631335aefb15 -6.61173459    1.705343
#> 16: 41b92ae5-ac8f-4e06-b582-310679d9efb6  8.34573561    3.714461
#> 17: 85d5ab5a-3a9c-4200-8c3a-b7dffb420600 -8.96971468   -3.263809
#> 18: b04a65af-524d-4536-a2be-c4632cf1cab0  1.89838435    2.698046
#> 19: 3b509e67-8c70-4df7-ba8a-a7a348e2f723 -2.71425870    1.813992
#> 20: d4323337-634e-455b-a0d8-582ab9281950  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
