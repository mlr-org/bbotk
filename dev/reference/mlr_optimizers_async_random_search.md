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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:23:42
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:23:42
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:23:42
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:23:42
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:23:42
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:23:42
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:23:42
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:23:43
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:23:43
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:23:43
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:23:43
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:23:43
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:23:43
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:23:43
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:23:43
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:23:43
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:23:43
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:23:43
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:23:43
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:23:43
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  2: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  3: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  4: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  5: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  6: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  7: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:42
#>  8: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#>  9: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 10: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 11: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 12: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 13: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 14: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 15: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 16: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 17: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 18: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 19: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#> 20: narrow_xinjiangovenator_bbd60b3b 2026-09-17 09:23:43
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 7efcd990-187c-45e4-815e-9019107741a9 -2.11085866    3.149893
#>  2: e66dedb3-7f2b-475f-8fbb-ba6a38d439ec -8.33732121    3.178398
#>  3: 01effd97-a5de-4159-9b56-1b99373b4ec3 -7.78396197    2.105379
#>  4: 362fb5cd-84d6-4b3c-8876-6f37e51b85c8  5.92632791   -4.231512
#>  5: 9d9ebe94-ebb2-45f5-a381-b0b6a5071870  0.98995613    2.678818
#>  6: aea21795-c9db-4fb9-8dc5-4e975033c5bd -3.50214144    1.111543
#>  7: b44be294-f826-46a5-9766-11d3e77d2e3a  2.77985531    4.933030
#>  8: 98c4c443-a72c-4da0-8742-6bfb6d44ea6e  9.86020590    0.052479
#>  9: 5be37fe8-e1e4-4cb0-b4af-3028c6c67d66 -4.77089430    4.984108
#> 10: f5bcaea1-b3d4-4308-b938-15eac2692d8e  8.62827623    3.264048
#> 11: 7821ab2f-1ed8-4489-9f4f-7c3da10ac186  5.20608164   -2.035465
#> 12: d2ff8d54-bb13-44d2-9251-a5a743a54056 -0.97588025    1.013553
#> 13: 1a1f9022-ab3a-49e9-b7f4-f31f71b593e7 -9.42569878    0.916582
#> 14: 178c8327-30ba-4425-8a2b-441caf5c2076  0.07085662    3.202987
#> 15: a52545df-8da8-4c3a-b2c7-536af247e68e -6.61173459    1.705343
#> 16: 32dd42fa-70b6-4b2f-8b2a-0d5b049dd6ee  8.34573561    3.714461
#> 17: e57843be-ead7-4e4e-a1b4-c35e489d74fb -8.96971468   -3.263809
#> 18: 58fef898-faf0-43ec-90b9-c34f7efc7f17  1.89838435    2.698046
#> 19: 7537785b-4ccd-4ed3-899f-66d12aecaba0 -2.71425870    1.813992
#> 20: 69cd0f14-a3cd-41e7-a840-47435d616b18  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
