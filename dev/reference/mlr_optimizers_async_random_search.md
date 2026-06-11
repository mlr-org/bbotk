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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-11 08:56:20
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-11 08:56:20
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-11 08:56:20
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-11 08:56:20
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-11 08:56:20
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-11 08:56:20
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-11 08:56:21
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-11 08:56:21
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-11 08:56:21
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-11 08:56:21
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-11 08:56:21
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-11 08:56:21
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-11 08:56:21
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-11 08:56:21
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-11 08:56:21
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-11 08:56:21
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-11 08:56:21
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-11 08:56:21
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-11 08:56:21
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-11 08:56:21
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  2: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  3: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  4: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  5: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  6: narrow_xinjiangovenator 2026-06-11 08:56:20
#>  7: narrow_xinjiangovenator 2026-06-11 08:56:21
#>  8: narrow_xinjiangovenator 2026-06-11 08:56:21
#>  9: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 10: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 11: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 12: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 13: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 14: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 15: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 16: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 17: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 18: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 19: narrow_xinjiangovenator 2026-06-11 08:56:21
#> 20: narrow_xinjiangovenator 2026-06-11 08:56:21
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: e64c4fc7-af7e-44e1-82d8-93f3615d1564 -2.11085866    3.149893
#>  2: c443a6a3-0dea-48d8-8baa-b177fe49a9a0 -8.33732121    3.178398
#>  3: 8765c027-1ee7-4de7-b8a4-ab4be7bff04c -7.78396197    2.105379
#>  4: 085900b1-0cce-4128-b331-8c0f1dd7a91a  5.92632791   -4.231512
#>  5: 2327a8f7-8023-49e3-9be7-1d06566fafd2  0.98995613    2.678818
#>  6: fc90a7ae-095b-49e2-b676-a868a74885d4 -3.50214144    1.111543
#>  7: 33730b03-642b-4829-99c9-6689a19416cf  2.77985531    4.933030
#>  8: ecb8fb43-215e-460f-852c-d98c9f578241  9.86020590    0.052479
#>  9: f1b6c4f5-a23f-41d9-a871-64b5abba81b6 -4.77089430    4.984108
#> 10: a8ee16be-44b4-4677-88e0-0133f349875b  8.62827623    3.264048
#> 11: fd7096c4-0d3a-4e72-89ab-3b77cd86e846  5.20608164   -2.035465
#> 12: 24ee70bd-bc6d-470c-ad03-d9494f8ef86b -0.97588025    1.013553
#> 13: a9788cef-a4a3-47cb-bb36-5a204e68422b -9.42569878    0.916582
#> 14: 7abb4be2-9326-4ac7-8e27-3d2773b711d0  0.07085662    3.202987
#> 15: 0b97fff4-ac46-4c88-a07a-8498dfd70d57 -6.61173459    1.705343
#> 16: 74f00c8d-643f-499d-9c6a-8214462e2a47  8.34573561    3.714461
#> 17: f8c3c956-9e08-4e27-a979-67f5efa1c3a7 -8.96971468   -3.263809
#> 18: 5fe15790-ec7d-419d-ad23-c6243d6b0442  1.89838435    2.698046
#> 19: 9ee599e1-a042-4d78-9fce-989e20508a38 -2.71425870    1.813992
#> 20: 35e47b66-7e0b-4090-9880-1d433ed11671  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
