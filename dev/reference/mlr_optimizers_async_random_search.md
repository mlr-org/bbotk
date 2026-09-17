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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 08:22:44
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 08:22:44
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 08:22:44
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 08:22:44
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 08:22:44
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 08:22:44
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 08:22:44
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 08:22:44
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 08:22:44
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 08:22:44
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 08:22:44
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 08:22:44
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 08:22:44
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 08:22:44
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 08:22:44
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 08:22:44
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 08:22:44
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 08:22:44
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 08:22:44
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 08:22:44
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  2: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  3: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  4: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  5: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  6: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  7: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  8: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>  9: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 10: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 11: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 12: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 13: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 14: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 15: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 16: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 17: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 18: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 19: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#> 20: narrow_xinjiangovenator_012c6abf 2026-09-17 08:22:44
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: a1cabd28-f347-435d-a842-ded5b889966b -2.11085866    3.149893
#>  2: 71015033-d107-4ccc-aa87-f18e76925cf8 -8.33732121    3.178398
#>  3: 0dd4a27d-f10b-4649-9f59-acd992e7071f -7.78396197    2.105379
#>  4: 025b6282-c49d-4a91-8979-d66b7b247437  5.92632791   -4.231512
#>  5: 696cba30-63a0-4fdd-8c37-c50ef6cadf70  0.98995613    2.678818
#>  6: c1262a57-caf3-4b1e-8ebb-d3f638d86848 -3.50214144    1.111543
#>  7: c516352b-8b50-4251-8a93-bd0dd73822f6  2.77985531    4.933030
#>  8: 2298c22d-a402-4861-8632-b47e8a570a9b  9.86020590    0.052479
#>  9: 663f9c99-9aaf-425b-8a36-ef7ae1922653 -4.77089430    4.984108
#> 10: cfb0199a-b949-48c9-b64d-8f6b2dc8739c  8.62827623    3.264048
#> 11: 498f34a5-b9f7-49b5-af63-a15fbefdec16  5.20608164   -2.035465
#> 12: 63e99eae-90b2-4567-8777-93f8f4043819 -0.97588025    1.013553
#> 13: 9a193ce3-ee1a-4c89-95d1-87a130a9572d -9.42569878    0.916582
#> 14: 5f2d21f3-ef8c-4c98-85b7-f71daa103131  0.07085662    3.202987
#> 15: e9c768fa-77e7-4df2-b9c7-c9d9a5d00ea5 -6.61173459    1.705343
#> 16: 7794ac4b-2c36-4b15-896c-a0437145ca9e  8.34573561    3.714461
#> 17: b4db7b60-d997-4ed7-800c-2cba92fe4391 -8.96971468   -3.263809
#> 18: 7c2c2b2a-73f7-402c-ad2b-b42e073bb775  1.89838435    2.698046
#> 19: 553e39e2-63ac-4bf6-ae2e-02dd18195a57 -2.71425870    1.813992
#> 20: ec0da1d4-8845-44a7-ac3b-7d29e40fbabf  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
