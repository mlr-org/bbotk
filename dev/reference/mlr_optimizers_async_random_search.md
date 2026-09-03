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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 11:02:59
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 11:02:59
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 11:02:59
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 11:02:59
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 11:02:59
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 11:02:59
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 11:02:59
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 11:02:59
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 11:02:59
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 11:02:59
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 11:02:59
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 11:02:59
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 11:02:59
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 11:03:00
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 11:03:00
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 11:03:00
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 11:03:00
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 11:03:00
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 11:03:00
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 11:03:00
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  2: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  3: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  4: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  5: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  6: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  7: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  8: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#>  9: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#> 10: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#> 11: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#> 12: narrow_xinjiangovenator_1833d03e 2026-09-03 11:02:59
#> 13: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 14: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 15: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 16: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 17: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 18: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 19: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#> 20: narrow_xinjiangovenator_1833d03e 2026-09-03 11:03:00
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: af28dae5-0fb5-43b2-98a3-35f38bd88a7b -2.11085866    3.149893
#>  2: 185eb6e9-fab1-438b-bcef-37d81a91900d -8.33732121    3.178398
#>  3: 5b98206e-36bc-4d95-a5db-9a1d81600535 -7.78396197    2.105379
#>  4: fc8b26d6-c00d-42bb-b844-7fce51ad9a39  5.92632791   -4.231512
#>  5: 7a83d863-197c-46a8-a805-af9f2ef57544  0.98995613    2.678818
#>  6: a53ae376-0017-4ff5-b9cb-08eb506dc0b1 -3.50214144    1.111543
#>  7: 8961d196-b79b-452a-9785-aec00fcc7edc  2.77985531    4.933030
#>  8: b03e1921-d31a-4d73-ba8f-21e80865c635  9.86020590    0.052479
#>  9: 45a33bc4-5c3a-409a-b8e2-5880a837f8a6 -4.77089430    4.984108
#> 10: d043ed62-c198-476a-95b3-20e6b1d3388f  8.62827623    3.264048
#> 11: 88ed87c7-42f9-4574-a86e-47038eef927f  5.20608164   -2.035465
#> 12: a89d4d4f-3584-450d-a482-89c73495b962 -0.97588025    1.013553
#> 13: 8ee2fd49-7fa9-4377-a356-a18d7d2e149e -9.42569878    0.916582
#> 14: e213d034-db1a-4e93-a462-c30479fcf234  0.07085662    3.202987
#> 15: b5a81e36-2702-4c8a-998b-17a79c2b656a -6.61173459    1.705343
#> 16: 6b9bb72c-c201-496f-8d55-ce82fb16accb  8.34573561    3.714461
#> 17: c8a56cc7-4348-4238-8ef5-a94520bb5adf -8.96971468   -3.263809
#> 18: 42b55d68-85b2-4a29-be0c-7eb6cb4b1b63  1.89838435    2.698046
#> 19: 9306138b-8416-4da4-b560-fbdfecce6696 -2.71425870    1.813992
#> 20: 0842b381-c167-470b-af95-62e5ecfca673  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
