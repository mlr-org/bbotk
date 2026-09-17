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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:16:59
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:16:59
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:16:59
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:16:59
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:16:59
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:16:59
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:16:59
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:16:59
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:16:59
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:16:59
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:16:59
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:16:59
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:16:59
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:16:59
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:16:59
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:16:59
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:16:59
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:16:59
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:16:59
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:16:59
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  2: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  3: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  4: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  5: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  6: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  7: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  8: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>  9: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 10: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 11: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 12: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 13: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 14: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 15: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 16: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 17: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 18: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 19: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#> 20: narrow_xinjiangovenator_eebb51b1 2026-09-17 09:16:59
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: e764b364-a572-4917-9ef2-c0e0147dcc6a -2.11085866    3.149893
#>  2: bc7c6d90-09bc-4e3a-b862-9baacad4f1e0 -8.33732121    3.178398
#>  3: 46b5667c-c312-41d7-9892-31bb31913804 -7.78396197    2.105379
#>  4: c8537459-6652-4261-b5c0-d690d94652f9  5.92632791   -4.231512
#>  5: 00404460-71d8-4039-a7d2-e661df0ccddc  0.98995613    2.678818
#>  6: d5870153-8982-4f59-bbe0-f7920c8942af -3.50214144    1.111543
#>  7: ae49cfce-31d2-4499-b669-25abf27fd291  2.77985531    4.933030
#>  8: 771e5478-2b0d-43e0-94e8-d89874bc78d2  9.86020590    0.052479
#>  9: 6f71ed49-172b-4b6c-bf89-8ef430f440b8 -4.77089430    4.984108
#> 10: df257a63-7e8c-49bf-8523-1cbc8fe2df32  8.62827623    3.264048
#> 11: b010ea84-b11f-4686-b8b8-09b379efd3cf  5.20608164   -2.035465
#> 12: 03c4b6bb-40ff-4cb3-9dd2-80702cb2ed5d -0.97588025    1.013553
#> 13: 716b9c97-7129-4ce5-9efa-5e5314f6bff8 -9.42569878    0.916582
#> 14: a2f308f6-9959-40c0-bf90-02bb075bc7ef  0.07085662    3.202987
#> 15: 0ca89752-c867-4b5c-8dea-a3cf815d4502 -6.61173459    1.705343
#> 16: e3a97b8b-794e-4e7d-be00-0165a4611196  8.34573561    3.714461
#> 17: 4f8e3a61-ee50-45ee-aeb2-1911bdb5768e -8.96971468   -3.263809
#> 18: ffb58a59-7966-4caf-b915-d8aa6dfe4590  1.89838435    2.698046
#> 19: 391e0558-eba2-4b90-9f25-15fabf96d2ba -2.71425870    1.813992
#> 20: 70884515-484a-4735-8763-a76afdf40c78  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
