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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-08-07 14:43:53
#>  2: finished -8.33732121  3.178398 -135.032815 2026-08-07 14:43:53
#>  3: finished -7.78396197  2.105379 -111.790803 2026-08-07 14:43:53
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-08-07 14:43:53
#>  5: finished  0.98995613  2.678818  -23.269168 2026-08-07 14:43:53
#>  6: finished -3.50214144  1.111543  -37.178342 2026-08-07 14:43:53
#>  7: finished  2.77985531  4.933030  -53.541141 2026-08-07 14:43:53
#>  8: finished  9.86020590  0.052479  -61.100465 2026-08-07 14:43:53
#>  9: finished -4.77089430  4.984108  -99.590989 2026-08-07 14:43:53
#> 10: finished  8.62827623  3.264048  -73.172348 2026-08-07 14:43:53
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-08-07 14:43:53
#> 12: finished -0.97588025  1.013553  -14.964468 2026-08-07 14:43:54
#> 13: finished -9.42569878  0.916582 -135.886207 2026-08-07 14:43:54
#> 14: finished  0.07085662  3.202987  -32.198639 2026-08-07 14:43:54
#> 15: finished -6.61173459  1.705343  -86.302224 2026-08-07 14:43:54
#> 16: finished  8.34573561  3.714461  -75.352353 2026-08-07 14:43:54
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-08-07 14:43:54
#> 18: finished  1.89838435  2.698046  -22.478057 2026-08-07 14:43:54
#> 19: finished -2.71425870  1.813992  -35.398750 2026-08-07 14:43:54
#> 20: finished  1.30114551 -4.177370    8.125403 2026-08-07 14:43:54
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  2: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  3: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  4: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  5: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  6: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  7: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  8: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#>  9: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#> 10: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#> 11: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:53
#> 12: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 13: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 14: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 15: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 16: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 17: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 18: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 19: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#> 20: narrow_xinjiangovenator_6573721e 2026-08-07 14:43:54
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 7e300efc-abdf-49cc-956d-72b2d1b23499 -2.11085866    3.149893
#>  2: e38ce1fa-bc2c-4a0f-8f9a-ae13237c1d0c -8.33732121    3.178398
#>  3: 8d6294cd-fac2-4fe5-b6e5-bc8e5b395531 -7.78396197    2.105379
#>  4: ba943cb5-cbca-483e-a74f-5b4fa6f1d367  5.92632791   -4.231512
#>  5: ced9ec88-00f8-450a-bb09-05f1fedaa0b6  0.98995613    2.678818
#>  6: 0637f0f5-f86c-4b76-b4bd-8dcc1c0f6a07 -3.50214144    1.111543
#>  7: c90884ec-886b-4efd-878b-24467bc69c7f  2.77985531    4.933030
#>  8: 3aee3d6d-8c65-4f60-bffe-a38c5062c6ff  9.86020590    0.052479
#>  9: 6acbd778-b77d-40e6-80f6-0e82493ff20b -4.77089430    4.984108
#> 10: 57ea0549-b898-46ba-9c07-3d1adb40f887  8.62827623    3.264048
#> 11: 0866362e-a1b6-4210-bff1-e77c3bb8fe20  5.20608164   -2.035465
#> 12: 6ec80242-f98a-42b3-ab90-cf4d13f0e0b3 -0.97588025    1.013553
#> 13: 5c2fc166-e61f-4952-aab5-f866b79f0b6e -9.42569878    0.916582
#> 14: e8a8d8c3-5ca5-486a-ac82-a2e264eb676a  0.07085662    3.202987
#> 15: b52451ab-d5bf-4db0-a1d8-b21e2bf6391d -6.61173459    1.705343
#> 16: a8a52f8b-8711-4a3b-b45a-a3e8f3df6302  8.34573561    3.714461
#> 17: 5418c07c-2408-437d-96bc-f5ba556e6b45 -8.96971468   -3.263809
#> 18: a47c8424-76d9-4928-b706-599ec23c0017  1.89838435    2.698046
#> 19: 43d3b2e1-8822-4d7d-9850-197e40901f20 -2.71425870    1.813992
#> 20: 91fc5582-06c6-4abb-adf2-e2483eee685e  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
