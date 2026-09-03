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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 11:36:38
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 11:36:38
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 11:36:38
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 11:36:38
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 11:36:38
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 11:36:39
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 11:36:39
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 11:36:39
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 11:36:39
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 11:36:39
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 11:36:39
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 11:36:39
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 11:36:39
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 11:36:39
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 11:36:39
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 11:36:39
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 11:36:39
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 11:36:39
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 11:36:39
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 11:36:39
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:38
#>  2: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:38
#>  3: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:38
#>  4: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:38
#>  5: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:38
#>  6: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#>  7: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#>  8: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#>  9: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 10: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 11: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 12: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 13: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 14: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 15: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 16: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 17: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 18: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 19: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#> 20: narrow_xinjiangovenator_dd00fe59 2026-09-03 11:36:39
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 51662fa4-be41-47dc-a3df-6f380e450828 -2.11085866    3.149893
#>  2: 5791a758-aa5b-4805-aef4-63767c61c422 -8.33732121    3.178398
#>  3: 148ebfff-a273-4db5-9885-2220266d7aae -7.78396197    2.105379
#>  4: b8777d48-901e-4f23-9c44-d2c604b37642  5.92632791   -4.231512
#>  5: e6143c04-6505-4338-a3b8-659393475b87  0.98995613    2.678818
#>  6: 45c9ce8f-00f6-4df5-9732-b24c6e911928 -3.50214144    1.111543
#>  7: 7e401fed-220c-4c65-b9c0-be2d172de565  2.77985531    4.933030
#>  8: b371cfe6-7111-4534-9082-7c31e72157e4  9.86020590    0.052479
#>  9: 405d0967-11c0-4ac0-8b6b-7043fcf34eb8 -4.77089430    4.984108
#> 10: 2500a930-e04b-4bc0-998c-39a95eb70f41  8.62827623    3.264048
#> 11: 6e332cd9-5f14-47db-92f2-d78b05bc814a  5.20608164   -2.035465
#> 12: 09f6cce5-eb61-4807-b8f7-1c0e94b34f9f -0.97588025    1.013553
#> 13: 680c29df-2ba7-4dd3-95e9-5f64c4285021 -9.42569878    0.916582
#> 14: 3923d3b6-433f-4794-a8ee-0c1732be0617  0.07085662    3.202987
#> 15: 4d7d74bd-751b-474f-8bd9-cdf6264eaa65 -6.61173459    1.705343
#> 16: daf8f4b1-e295-4131-8e9e-b00472eda4f0  8.34573561    3.714461
#> 17: 14f0b31b-45bd-41ac-a221-f9c0cb1fa0b0 -8.96971468   -3.263809
#> 18: f06a63a9-4bfd-4553-8174-565cc4876082  1.89838435    2.698046
#> 19: b27d4d5c-0187-419a-8db0-fe145f550281 -2.71425870    1.813992
#> 20: 66c6d3d7-857b-40bf-adc3-45dc387eeaa2  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
