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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 07:44:44
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 07:44:44
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 07:44:44
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 07:44:44
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 07:44:44
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 07:44:44
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 07:44:44
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 07:44:44
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 07:44:44
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 07:44:44
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 07:44:44
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 07:44:44
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 07:44:44
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 07:44:44
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 07:44:44
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 07:44:44
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 07:44:44
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 07:44:44
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 07:44:44
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 07:44:44
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  2: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  3: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  4: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  5: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  6: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  7: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  8: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>  9: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 10: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 11: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 12: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 13: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 14: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 15: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 16: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 17: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 18: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 19: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#> 20: narrow_xinjiangovenator_334cf229 2026-09-17 07:44:44
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 46e54f73-f980-4b45-99ea-5d3bd3cc7064 -2.11085866    3.149893
#>  2: 0369bf10-e8b0-42d1-bd97-a056cb603925 -8.33732121    3.178398
#>  3: c0b941bc-b35a-47c8-b6a8-45722ae6a69b -7.78396197    2.105379
#>  4: 0ad457ba-8a66-4fe4-87cc-fa9da9a0ab4e  5.92632791   -4.231512
#>  5: 6245419d-1c1c-4156-9ec2-b55afdd6b325  0.98995613    2.678818
#>  6: 2845bbb9-082d-45e4-8396-a6c05e19a5c1 -3.50214144    1.111543
#>  7: 1fab60d8-e96d-4a1e-9252-55c09b2175cb  2.77985531    4.933030
#>  8: 2546829d-2d9e-42a1-a0de-05cbf74eeb18  9.86020590    0.052479
#>  9: b5679aa8-a7f9-423b-8d6d-9c82ce80c4a1 -4.77089430    4.984108
#> 10: b130c241-9762-484e-a860-051b42865fd4  8.62827623    3.264048
#> 11: 4579c725-687a-418a-bb23-c7d10cac5372  5.20608164   -2.035465
#> 12: 2c0888ed-849e-46e8-9a34-3b93cc333893 -0.97588025    1.013553
#> 13: 21f2b795-8131-4f71-8d2a-e095cd3b426c -9.42569878    0.916582
#> 14: e6bb3192-e6b6-4efa-b94f-dae9c50c0cac  0.07085662    3.202987
#> 15: 357a852a-e724-40e2-a326-cd9c13d6e474 -6.61173459    1.705343
#> 16: 65f89f91-5668-4e1e-acaa-d928eaecfa2c  8.34573561    3.714461
#> 17: 8ace28c3-bbc2-4448-9904-7fb2843e2779 -8.96971468   -3.263809
#> 18: 1f9d0065-0f28-45d2-8130-191ddcda6639  1.89838435    2.698046
#> 19: 6a72335f-5570-47d1-9d60-f00b14b32d2c -2.71425870    1.813992
#> 20: 60621ca9-58f1-46cb-8848-9754112f46a8  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
