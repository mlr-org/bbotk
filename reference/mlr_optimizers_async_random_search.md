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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-20 08:44:16
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-20 08:44:16
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-20 08:44:16
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-20 08:44:16
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-20 08:44:16
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-20 08:44:16
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-20 08:44:16
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-20 08:44:16
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-20 08:44:16
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-20 08:44:16
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-20 08:44:17
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-20 08:44:17
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-20 08:44:17
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-20 08:44:17
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-20 08:44:17
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-20 08:44:17
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-20 08:44:17
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-20 08:44:17
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-20 08:44:17
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-20 08:44:17
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  2: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  3: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  4: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  5: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  6: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  7: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  8: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#>  9: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#> 10: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:16
#> 11: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 12: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 13: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 14: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 15: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 16: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 17: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 18: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 19: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#> 20: narrow_xinjiangovenator_196879f8 2026-07-20 08:44:17
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 671a1ec7-9ac5-4ebb-b541-8e6ffd39c97f -2.11085866    3.149893
#>  2: 62be4951-1b9e-42d0-a0a8-a6de58dc0dcf -8.33732121    3.178398
#>  3: e35c8ff1-4eee-4635-8c29-ddfb415fad5b -7.78396197    2.105379
#>  4: 4281eb70-b718-451f-96d8-a32c5bf584f1  5.92632791   -4.231512
#>  5: 3aeee405-4478-4ac8-b8ce-78b7dea400d5  0.98995613    2.678818
#>  6: 3e559127-14be-4eb8-8be4-3dedf785c8cd -3.50214144    1.111543
#>  7: 56d9eda1-5848-4751-8a75-c58cc535b746  2.77985531    4.933030
#>  8: 1d9d03c2-29d2-435f-b5ab-43f6d8d2e13a  9.86020590    0.052479
#>  9: e7cab063-9ff8-497c-b7bb-7217afe43693 -4.77089430    4.984108
#> 10: f4e17dd1-f07d-4972-b74f-c43ae858e4e2  8.62827623    3.264048
#> 11: 1d2e84ef-fbb0-424a-8538-179d7793ac36  5.20608164   -2.035465
#> 12: f88e1745-763b-464e-abc7-b966899c64ca -0.97588025    1.013553
#> 13: 55e45eb6-2bdc-46c0-b540-a5cca37dd5c7 -9.42569878    0.916582
#> 14: 160293a3-be2b-49b6-bc9e-2d37c14d2677  0.07085662    3.202987
#> 15: 148b1f29-066d-4531-83b8-4dc00baf6f28 -6.61173459    1.705343
#> 16: 1f3edfd9-48f0-4e6c-bfcd-2e3c36389fa2  8.34573561    3.714461
#> 17: b26c0364-e295-4702-891b-dbecfb6fe9f7 -8.96971468   -3.263809
#> 18: 891a4a69-23b3-4fc8-907e-8531d425fa02  1.89838435    2.698046
#> 19: 45bab9d0-4e56-4f22-84ee-fc8c80b600c5 -2.71425870    1.813992
#> 20: dda9e700-eeed-47ad-999c-cd58734f28ca  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
