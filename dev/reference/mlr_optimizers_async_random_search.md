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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-22 13:44:44
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-22 13:44:44
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-22 13:44:44
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-22 13:44:44
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-22 13:44:44
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-22 13:44:44
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-22 13:44:44
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-22 13:44:44
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-22 13:44:44
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-22 13:44:44
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-22 13:44:44
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-22 13:44:44
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-22 13:44:44
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-22 13:44:44
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-22 13:44:44
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-22 13:44:44
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-22 13:44:44
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-22 13:44:44
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-22 13:44:44
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-22 13:44:44
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  2: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  3: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  4: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  5: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  6: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  7: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  8: narrow_xinjiangovenator 2026-06-22 13:44:44
#>  9: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 10: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 11: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 12: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 13: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 14: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 15: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 16: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 17: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 18: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 19: narrow_xinjiangovenator 2026-06-22 13:44:44
#> 20: narrow_xinjiangovenator 2026-06-22 13:44:44
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: ca51a918-074c-4870-87c6-c606eb910525 -2.11085866    3.149893
#>  2: 93a408ce-df0d-44fc-b922-c9705183f896 -8.33732121    3.178398
#>  3: 08e6f2b5-b2e6-4afd-8ce2-9a54a515b9d3 -7.78396197    2.105379
#>  4: 04a07b25-15eb-43d0-916b-11d527857420  5.92632791   -4.231512
#>  5: edf6e79a-84b7-47d4-a47f-03c207b764b2  0.98995613    2.678818
#>  6: a17e5afc-5c5d-4ea7-a063-81b18484183a -3.50214144    1.111543
#>  7: 21165b40-03a5-4881-9679-94e3b088693f  2.77985531    4.933030
#>  8: 4cb60b18-7d9a-4c00-9f9c-4db041fb5923  9.86020590    0.052479
#>  9: 6c3cc7ec-d006-4399-893e-afbfa606fd2b -4.77089430    4.984108
#> 10: 5680cf06-3493-48c6-8935-b886a750e14e  8.62827623    3.264048
#> 11: 05b17e3d-5d13-4590-8840-da4d6d7ba1a8  5.20608164   -2.035465
#> 12: d63a5e1a-01a6-432f-af42-b3b67addf5d5 -0.97588025    1.013553
#> 13: 06fb1b56-79a7-4468-ab97-fe6ceb8ea6f1 -9.42569878    0.916582
#> 14: 9100b0ef-1923-4e48-8dcb-4b614660d139  0.07085662    3.202987
#> 15: f6bcf9d5-adde-47e2-af8c-8451c8924c6e -6.61173459    1.705343
#> 16: d7ac3a87-267e-40fd-bd50-4e1acda9a140  8.34573561    3.714461
#> 17: b2f7991b-75f6-421e-a7f1-d8fc325b4427 -8.96971468   -3.263809
#> 18: 836c6a4b-7621-427c-90e8-046d3e2ae26c  1.89838435    2.698046
#> 19: 834c1fe0-4f6f-4ab7-a2df-00065867f00f -2.71425870    1.813992
#> 20: 7aacdbd5-d9a1-4b06-9e76-ecd1c2d308c2  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
