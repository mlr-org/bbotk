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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:40:37
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:40:37
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:40:37
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:40:37
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:40:37
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:40:37
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:40:37
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:40:37
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:40:37
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:40:37
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:40:37
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:40:37
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:40:37
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:40:37
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:40:37
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:40:37
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:40:37
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:40:37
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:40:37
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:40:37
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  2: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  3: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  4: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  5: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  6: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  7: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  8: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>  9: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 10: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 11: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 12: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 13: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 14: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 15: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 16: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 17: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 18: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 19: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#> 20: narrow_xinjiangovenator_52b30056 2026-09-17 09:40:37
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 7ef72524-13e9-485a-ac56-203fbfd28c01 -2.11085866    3.149893
#>  2: f13e41cd-8255-4c96-bf20-94bf3c331165 -8.33732121    3.178398
#>  3: dbd41bc4-ce2e-4ff0-9eeb-e5888aa241af -7.78396197    2.105379
#>  4: aa035040-44c7-4aef-8bbc-8b340a880b8d  5.92632791   -4.231512
#>  5: b1bd8064-0293-4719-be5e-d1ec4f3fbd4d  0.98995613    2.678818
#>  6: 77facff8-b74b-4fc4-818b-1829bf7b78cf -3.50214144    1.111543
#>  7: 2ffe257b-d585-456e-9749-da81875c951d  2.77985531    4.933030
#>  8: 0e609e3a-a23d-4fcd-8849-3088d249302c  9.86020590    0.052479
#>  9: 2235287b-d364-4f77-afab-f980693a816c -4.77089430    4.984108
#> 10: 05c68b5d-cb51-4629-8639-6c5958793168  8.62827623    3.264048
#> 11: 64052d9f-17d3-4e41-b191-a1cc2987a0e8  5.20608164   -2.035465
#> 12: 8d975368-0540-44d7-8ec1-262f17c2209f -0.97588025    1.013553
#> 13: ea7386f6-8bb2-4838-bd31-01e5b583d255 -9.42569878    0.916582
#> 14: 86d35d52-67a7-4bfe-bfe2-f1e440eac0d6  0.07085662    3.202987
#> 15: 766cc7bc-987b-4797-ba74-1bba2cc8c656 -6.61173459    1.705343
#> 16: 4cfb0775-9bd1-46c7-af7c-885b66fd373d  8.34573561    3.714461
#> 17: 1950c2a3-0ab9-4de7-ab2b-5c2eca8bc91b -8.96971468   -3.263809
#> 18: 67e9b898-1ab3-4588-a719-b25276defceb  1.89838435    2.698046
#> 19: 7c68b8b8-9fae-4d2e-bf0b-81281abb39ff -2.71425870    1.813992
#> 20: 91326fc7-4694-4a9f-8b16-2f884e94ceb4  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
