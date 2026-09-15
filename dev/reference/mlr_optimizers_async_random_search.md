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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-15 16:14:51
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-15 16:14:51
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-15 16:14:52
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-15 16:14:52
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-15 16:14:52
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-15 16:14:52
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-15 16:14:52
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-15 16:14:52
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-15 16:14:52
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-15 16:14:52
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-15 16:14:52
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-15 16:14:52
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-15 16:14:52
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-15 16:14:52
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-15 16:14:52
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-15 16:14:52
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-15 16:14:52
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-15 16:14:52
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-15 16:14:52
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-15 16:14:52
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:51
#>  2: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  3: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  4: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  5: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  6: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  7: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  8: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>  9: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 10: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 11: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 12: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 13: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 14: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 15: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 16: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 17: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 18: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 19: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#> 20: narrow_xinjiangovenator_778a837b 2026-09-15 16:14:52
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d94f3b8e-8cd8-449a-9b98-148556afa8cf -2.11085866    3.149893
#>  2: db207bef-649c-4a5a-b755-fcccdf96ca68 -8.33732121    3.178398
#>  3: 5c41867d-8c91-4979-96c8-952f758fd381 -7.78396197    2.105379
#>  4: 03f9cd73-71a1-425c-8fcc-4af4ff7cbd01  5.92632791   -4.231512
#>  5: 1755abfe-e83e-448c-bb2d-aa45a1d9a8a4  0.98995613    2.678818
#>  6: 06648edd-a132-4ace-8472-a337eebdab94 -3.50214144    1.111543
#>  7: 11aa4a69-916b-4c2e-8df9-91f45739eadc  2.77985531    4.933030
#>  8: 99f10647-6894-44a9-9536-568058c6d07d  9.86020590    0.052479
#>  9: 48eddd52-5f55-4730-8ab6-f2b6121a65ce -4.77089430    4.984108
#> 10: c30c5878-c48e-4bd0-b277-19c1875af7b7  8.62827623    3.264048
#> 11: c354625c-e684-4cb3-ae61-b29edbf8de70  5.20608164   -2.035465
#> 12: 1ca66e73-17a5-48f9-a044-9fa610778d8d -0.97588025    1.013553
#> 13: 8af93851-56a3-446f-afde-87e358fa36a6 -9.42569878    0.916582
#> 14: d108cb38-0749-4d56-966a-83eecfc05a9a  0.07085662    3.202987
#> 15: 2509af74-ea64-47ef-81be-e26a22a92aa8 -6.61173459    1.705343
#> 16: dfd2aebb-974c-4e66-a7ee-34c49ad0064b  8.34573561    3.714461
#> 17: 8689ab75-0553-4690-aeb0-0b7dd6090a05 -8.96971468   -3.263809
#> 18: 8a916b73-7708-4d32-a055-630a30e52a40  1.89838435    2.698046
#> 19: 35ee4b48-5ea5-4ca4-9a57-edb20d0ee5d0 -2.71425870    1.813992
#> 20: e25ba29b-fa31-4cda-961b-81667aed297d  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
