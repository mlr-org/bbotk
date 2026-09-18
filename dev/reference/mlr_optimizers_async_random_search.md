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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-18 09:15:22
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-18 09:15:22
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-18 09:15:22
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-18 09:15:22
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-18 09:15:22
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-18 09:15:22
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-18 09:15:22
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-18 09:15:22
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-18 09:15:22
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-18 09:15:22
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-18 09:15:22
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-18 09:15:22
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-18 09:15:22
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-18 09:15:22
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-18 09:15:22
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-18 09:15:22
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-18 09:15:22
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-18 09:15:22
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-18 09:15:22
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-18 09:15:22
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  2: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  3: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  4: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  5: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  6: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  7: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  8: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>  9: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 10: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 11: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 12: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 13: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 14: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 15: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 16: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 17: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 18: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 19: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#> 20: narrow_xinjiangovenator_815008f1 2026-09-18 09:15:22
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 269b5c5b-f960-4f64-b577-814d87827eac -2.11085866    3.149893
#>  2: 9689a60e-1d50-43d4-bd2d-9f5965d28abf -8.33732121    3.178398
#>  3: 6503a79a-1f9b-4858-b35f-61bfcce1fe9c -7.78396197    2.105379
#>  4: 6c48bac4-be19-44da-bc1b-73e56a717353  5.92632791   -4.231512
#>  5: fa3aeea2-b041-4fdf-a195-26da39e85043  0.98995613    2.678818
#>  6: 8074611c-c2d2-4d05-9c6f-8ee5fb852cab -3.50214144    1.111543
#>  7: 44c17129-d25b-42ea-9fa6-8c11565a93a5  2.77985531    4.933030
#>  8: a1a22cd2-4222-4bd1-84e3-a099912e8f04  9.86020590    0.052479
#>  9: b9303d2c-5383-4c56-9534-2b9d2d83cb1d -4.77089430    4.984108
#> 10: 11ea533b-f359-4452-88e8-90250d3fcf2e  8.62827623    3.264048
#> 11: c838809a-cb91-4627-8172-b3ddb8703b70  5.20608164   -2.035465
#> 12: 3d24721d-c5f3-4f4e-8639-a2163b80acb2 -0.97588025    1.013553
#> 13: 93ff30b7-c3b6-41bb-ac5f-00b69180d2a6 -9.42569878    0.916582
#> 14: 59133088-aa1e-453a-9664-e31944c6c9f2  0.07085662    3.202987
#> 15: 24ed0a9f-0ba4-442d-8058-066e412e8e50 -6.61173459    1.705343
#> 16: 3118425b-f5f7-4f68-9375-05fb9cf2108a  8.34573561    3.714461
#> 17: 8fac9bf9-577b-43cf-9f81-1b96c06b61b7 -8.96971468   -3.263809
#> 18: fb63d4dc-914b-4189-bff0-1c0005321a13  1.89838435    2.698046
#> 19: 48e7ff77-5132-4c01-8289-6036002f74c4 -2.71425870    1.813992
#> 20: a7535294-4a11-42a7-8e01-e7a223b0651b  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
