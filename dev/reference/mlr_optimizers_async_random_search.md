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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-02 15:49:08
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-02 15:49:08
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-02 15:49:08
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-02 15:49:08
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-02 15:49:08
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-02 15:49:09
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-02 15:49:09
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-02 15:49:09
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-02 15:49:09
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-02 15:49:09
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-02 15:49:09
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-02 15:49:09
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-02 15:49:09
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-02 15:49:09
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-02 15:49:09
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-02 15:49:09
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-02 15:49:09
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-02 15:49:09
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-02 15:49:09
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-02 15:49:09
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-07-02 15:49:08
#>  2: narrow_xinjiangovenator 2026-07-02 15:49:08
#>  3: narrow_xinjiangovenator 2026-07-02 15:49:08
#>  4: narrow_xinjiangovenator 2026-07-02 15:49:08
#>  5: narrow_xinjiangovenator 2026-07-02 15:49:08
#>  6: narrow_xinjiangovenator 2026-07-02 15:49:09
#>  7: narrow_xinjiangovenator 2026-07-02 15:49:09
#>  8: narrow_xinjiangovenator 2026-07-02 15:49:09
#>  9: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 10: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 11: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 12: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 13: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 14: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 15: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 16: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 17: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 18: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 19: narrow_xinjiangovenator 2026-07-02 15:49:09
#> 20: narrow_xinjiangovenator 2026-07-02 15:49:09
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: ac562738-cf36-4ba2-afc9-406b2db44373 -2.11085866    3.149893
#>  2: 37aa667d-525a-4346-95a4-8739a10cbc67 -8.33732121    3.178398
#>  3: c159e7bd-8df0-4d4a-b494-6a0592e254c5 -7.78396197    2.105379
#>  4: a1f3721c-9ede-4fe2-b7dd-a25c90a0cf60  5.92632791   -4.231512
#>  5: b2afbbe3-7c11-4ee1-b900-ff18142e594f  0.98995613    2.678818
#>  6: 1a34bf42-10ff-4f97-8892-5ab424dbf4a8 -3.50214144    1.111543
#>  7: 5f0f0dd4-4f9d-4bcf-91aa-0abf895f83f8  2.77985531    4.933030
#>  8: 4645aa5d-3b72-44e5-90d0-32ff4a8ea4c8  9.86020590    0.052479
#>  9: 2c64d575-a067-4a5a-96ee-0561463adebf -4.77089430    4.984108
#> 10: 40b19053-e98b-49cd-adeb-614a93d75372  8.62827623    3.264048
#> 11: ff736458-a953-4e1a-9c58-54d9829bc93f  5.20608164   -2.035465
#> 12: 91c85636-bcf3-4c8f-ab39-ab53ee487267 -0.97588025    1.013553
#> 13: f1cd6962-22b9-40d3-9ba0-c557dddc675c -9.42569878    0.916582
#> 14: 63d66171-8bbc-42b5-9bd2-7bb5c0ff36c0  0.07085662    3.202987
#> 15: 9e1de838-6348-4732-81cd-6566a7187954 -6.61173459    1.705343
#> 16: 69039bb2-0be9-4d77-bf22-526b345eec1d  8.34573561    3.714461
#> 17: ff62b7a4-39ad-4276-a209-2bb681a37cc6 -8.96971468   -3.263809
#> 18: c8cce0ee-3233-4bfb-8770-b319586b3730  1.89838435    2.698046
#> 19: 025c80e6-68bf-47e9-86a8-fa0abb3aa15d -2.71425870    1.813992
#> 20: 311d41e8-e508-4ebc-aa13-1b64b5683c7e  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
