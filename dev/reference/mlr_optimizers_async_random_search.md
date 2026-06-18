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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-18 08:16:05
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-18 08:16:05
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-18 08:16:05
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-18 08:16:05
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-18 08:16:05
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-18 08:16:05
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-18 08:16:05
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-18 08:16:05
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-18 08:16:05
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-18 08:16:06
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-18 08:16:06
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-18 08:16:06
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-18 08:16:06
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-18 08:16:06
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-18 08:16:06
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-18 08:16:06
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-18 08:16:06
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-18 08:16:06
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-18 08:16:06
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-18 08:16:06
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  2: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  3: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  4: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  5: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  6: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  7: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  8: narrow_xinjiangovenator 2026-06-18 08:16:05
#>  9: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 10: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 11: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 12: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 13: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 14: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 15: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 16: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 17: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 18: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 19: narrow_xinjiangovenator 2026-06-18 08:16:06
#> 20: narrow_xinjiangovenator 2026-06-18 08:16:06
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: bac02589-374b-463e-9a12-89a2d965bd99 -2.11085866    3.149893
#>  2: 98d4209f-d274-4561-a7c2-2c37f3f25449 -8.33732121    3.178398
#>  3: 5f6c42f9-224a-4473-b8df-ddb036629d33 -7.78396197    2.105379
#>  4: 6c46d31e-169c-4282-aa2f-b5350f2a3f22  5.92632791   -4.231512
#>  5: 5fd6b97a-953e-4717-b079-3921cc34367f  0.98995613    2.678818
#>  6: 2ce673ac-e924-422e-8a34-e45561be8a20 -3.50214144    1.111543
#>  7: 4c8778a7-d8f3-4b6a-aa7c-266ddc628c63  2.77985531    4.933030
#>  8: ae7e8875-0143-493f-86d3-f35cc8ab52b7  9.86020590    0.052479
#>  9: a6e2d1b2-2935-4cb2-a021-eceb38c11711 -4.77089430    4.984108
#> 10: 2bf6fb9d-43db-4f50-a2be-84d984097b9f  8.62827623    3.264048
#> 11: 5cf83003-83a9-4552-9ca6-613f730f5565  5.20608164   -2.035465
#> 12: 24e491c8-4602-46f3-bb18-aa2404b458a7 -0.97588025    1.013553
#> 13: a83d8292-bd08-4787-8f66-587ceb8a3890 -9.42569878    0.916582
#> 14: dcd6bb0d-fb27-40c6-84ac-9de6d153ea3e  0.07085662    3.202987
#> 15: b1bffd73-d272-465b-bc5e-fe6309edbf0a -6.61173459    1.705343
#> 16: 5f8d94f4-c192-4e8d-b640-c33671f3f804  8.34573561    3.714461
#> 17: d6ffbc60-30e2-4d16-9bc3-47c889982055 -8.96971468   -3.263809
#> 18: 892e34a4-e9bd-47a2-bc36-1402f82ba010  1.89838435    2.698046
#> 19: 241ae5a8-d031-487a-8bad-f4d0265f55a6 -2.71425870    1.813992
#> 20: 7900d5e5-6317-4096-86a3-3495ec000f68  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
