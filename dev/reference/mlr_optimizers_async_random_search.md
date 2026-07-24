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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-24 14:14:28
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-24 14:14:28
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-24 14:14:28
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-24 14:14:28
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-24 14:14:28
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-24 14:14:28
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-24 14:14:28
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-24 14:14:28
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-24 14:14:28
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-24 14:14:28
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-24 14:14:28
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-24 14:14:28
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-24 14:14:28
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-24 14:14:28
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-24 14:14:28
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-24 14:14:28
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-24 14:14:29
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-24 14:14:29
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-24 14:14:29
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-24 14:14:29
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  2: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  3: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  4: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  5: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  6: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  7: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  8: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#>  9: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 10: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 11: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 12: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 13: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 14: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 15: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 16: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:28
#> 17: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:29
#> 18: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:29
#> 19: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:29
#> 20: narrow_xinjiangovenator_eed03e9b 2026-07-24 14:14:29
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d5e5ee9a-968d-4088-a41f-33fb72bd61c9 -2.11085866    3.149893
#>  2: 11b9419e-2dce-498b-8228-529921ef94d6 -8.33732121    3.178398
#>  3: 03d84295-ef3d-4056-b482-6749f163d0a8 -7.78396197    2.105379
#>  4: 9b1972e6-e4cf-45a5-ae30-6e35b10f34eb  5.92632791   -4.231512
#>  5: 9a74d5f6-bf71-42f8-9c49-a30a9fe1196b  0.98995613    2.678818
#>  6: 4d076404-8941-4321-8f97-fe75c9433e51 -3.50214144    1.111543
#>  7: 2a310201-e680-45ef-92fa-2370d956346d  2.77985531    4.933030
#>  8: 70e493cd-7a70-4567-87ca-763bebcce13e  9.86020590    0.052479
#>  9: 3b6deb5b-51dc-4253-9678-5a57fc3dd7a9 -4.77089430    4.984108
#> 10: e94524cb-3c8d-4f55-a700-737a134ee42b  8.62827623    3.264048
#> 11: 71e48718-e59c-46e0-832a-c47b13233ac4  5.20608164   -2.035465
#> 12: 42dc9d6d-bd82-4138-a35c-07aab61bb9e0 -0.97588025    1.013553
#> 13: 43377f11-a752-4ac1-bc3e-d31051ab5579 -9.42569878    0.916582
#> 14: 1a804aee-171f-46a7-921e-8f64e6511d76  0.07085662    3.202987
#> 15: 68722a0b-dc6d-46a9-9c93-deb95555fc42 -6.61173459    1.705343
#> 16: 60f009ce-2777-494c-b679-d22c55ebdb20  8.34573561    3.714461
#> 17: 42440f6f-e6a0-42ec-a7f0-66ae51f234c6 -8.96971468   -3.263809
#> 18: 643928d6-e177-4793-a493-cbb03f70589b  1.89838435    2.698046
#> 19: dc85ae48-ecfc-419c-85ae-e66777ae3911 -2.71425870    1.813992
#> 20: 6dcc09e5-0b0e-49d8-af24-99215b285a0d  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
