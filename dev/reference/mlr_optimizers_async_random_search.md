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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-26 10:11:07
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-26 10:11:07
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-26 10:11:07
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-26 10:11:07
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-26 10:11:07
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-26 10:11:07
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-26 10:11:07
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-26 10:11:07
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-26 10:11:07
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-26 10:11:07
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-26 10:11:07
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-26 10:11:07
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-26 10:11:07
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-26 10:11:07
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-26 10:11:07
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-26 10:11:07
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-26 10:11:08
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-26 10:11:08
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-26 10:11:08
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-26 10:11:08
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  2: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  3: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  4: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  5: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  6: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  7: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  8: narrow_xinjiangovenator 2026-06-26 10:11:07
#>  9: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 10: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 11: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 12: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 13: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 14: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 15: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 16: narrow_xinjiangovenator 2026-06-26 10:11:07
#> 17: narrow_xinjiangovenator 2026-06-26 10:11:08
#> 18: narrow_xinjiangovenator 2026-06-26 10:11:08
#> 19: narrow_xinjiangovenator 2026-06-26 10:11:08
#> 20: narrow_xinjiangovenator 2026-06-26 10:11:08
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 392d23eb-aaff-4e8c-ac49-1c46e75820e0 -2.11085866    3.149893
#>  2: 4d5284b9-71ee-4002-b297-74ac45e8f346 -8.33732121    3.178398
#>  3: 865dcb50-6f0b-482c-9025-ddb636e98b9a -7.78396197    2.105379
#>  4: 04986f55-eb3b-4996-9a62-e02adf042fbf  5.92632791   -4.231512
#>  5: 09d5d094-441a-49f9-a7d8-11901687090e  0.98995613    2.678818
#>  6: 09059423-fa74-414f-815d-77103adedf0f -3.50214144    1.111543
#>  7: 0c6f5c64-e29e-4b0a-9be6-c07465fb89d0  2.77985531    4.933030
#>  8: e937530d-509b-4ab6-980f-b0ce13b63d5d  9.86020590    0.052479
#>  9: 11419ac4-58ce-47de-acc7-e97c56dad73b -4.77089430    4.984108
#> 10: be7f2dd3-bf23-43f1-af8f-688ff88f0ce4  8.62827623    3.264048
#> 11: 3ff34b5a-2bcb-4fd7-b1da-88556e213e8b  5.20608164   -2.035465
#> 12: 7200a1ef-2021-477f-b1aa-dd6147ec926e -0.97588025    1.013553
#> 13: 7886bd30-08c0-4ee4-bace-187a4df79697 -9.42569878    0.916582
#> 14: c29472f2-762f-4c01-86c6-10e6848528be  0.07085662    3.202987
#> 15: 7ea48d4c-a44c-4c73-8e32-61b5fc5d029c -6.61173459    1.705343
#> 16: cbe05dd6-a5ee-44df-b248-08a1be30ea2a  8.34573561    3.714461
#> 17: e448c021-e863-4f29-82db-8c7b574996c9 -8.96971468   -3.263809
#> 18: ba9af4e7-863b-4ede-9ba8-56604d2f6d96  1.89838435    2.698046
#> 19: 0f8eecf1-08bc-4d34-97eb-e493f2388ba3 -2.71425870    1.813992
#> 20: c93b0657-9ab4-48e4-afdf-eaae3cf851fc  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
