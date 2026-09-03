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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 11:08:20
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 11:08:20
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 11:08:20
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 11:08:20
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 11:08:20
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 11:08:20
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 11:08:20
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 11:08:20
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 11:08:20
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 11:08:20
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 11:08:20
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 11:08:21
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 11:08:21
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 11:08:21
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 11:08:21
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 11:08:21
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 11:08:21
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 11:08:21
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 11:08:21
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 11:08:21
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  2: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  3: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  4: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  5: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  6: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  7: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  8: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#>  9: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#> 10: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#> 11: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:20
#> 12: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 13: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 14: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 15: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 16: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 17: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 18: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 19: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#> 20: narrow_xinjiangovenator_d95c1230 2026-09-03 11:08:21
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 99a8fe1d-1af0-4220-ab2f-43aa151f7644 -2.11085866    3.149893
#>  2: e3940d5d-3899-4309-b7be-dd5971d525d4 -8.33732121    3.178398
#>  3: ff4d2456-546d-47f7-a955-63a839ad6a45 -7.78396197    2.105379
#>  4: 643d2d5e-7bad-463a-bd2f-915e7b27bce9  5.92632791   -4.231512
#>  5: 246d31ff-1081-49e9-a24a-e29b6a00ff4c  0.98995613    2.678818
#>  6: 719e8e1d-5a10-4994-ab62-5cc2df7aead9 -3.50214144    1.111543
#>  7: b46c8368-2d2f-42db-a2b5-b38c9d2b48ef  2.77985531    4.933030
#>  8: d80481be-f9b6-4344-9fdd-d19d0412b070  9.86020590    0.052479
#>  9: e5ccaf6f-3d52-4b52-92b8-49223b67bc59 -4.77089430    4.984108
#> 10: d9d6d745-b752-478c-b16e-acf9d7c63343  8.62827623    3.264048
#> 11: 17b84b27-cac1-4ea0-b9f1-d554f5713a8d  5.20608164   -2.035465
#> 12: cf6e6ca1-ccab-4470-908c-d9b747275de3 -0.97588025    1.013553
#> 13: 30e95f36-5533-4f73-a520-f845b1aaa97b -9.42569878    0.916582
#> 14: eecf983e-5ab7-4e2a-bf82-97bbd266d73f  0.07085662    3.202987
#> 15: d4414d01-bdc0-4e37-99fe-61523c5b9fbf -6.61173459    1.705343
#> 16: 7acb757d-b8cd-4365-a67b-3cabe27b2cf6  8.34573561    3.714461
#> 17: a326935e-9693-4aa5-b34b-85727bcabe5d -8.96971468   -3.263809
#> 18: 42c3b40f-096f-4220-8787-099da68656d8  1.89838435    2.698046
#> 19: 8de5c7a0-ddd2-463c-8e0b-c9d15d279051 -2.71425870    1.813992
#> 20: 9ebae366-db98-4d6a-af7f-751b8c79c390  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
