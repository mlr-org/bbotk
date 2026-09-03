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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 12:10:58
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 12:10:58
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 12:10:58
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 12:10:58
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 12:10:58
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 12:10:58
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 12:10:58
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 12:10:59
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 12:10:59
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 12:10:59
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 12:10:59
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 12:10:59
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 12:10:59
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 12:10:59
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 12:10:59
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 12:10:59
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 12:10:59
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 12:10:59
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 12:10:59
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 12:10:59
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  2: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  3: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  4: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  5: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  6: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  7: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:58
#>  8: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#>  9: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 10: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 11: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 12: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 13: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 14: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 15: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 16: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 17: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 18: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 19: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#> 20: narrow_xinjiangovenator_a08b59e3 2026-09-03 12:10:59
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 50b80314-af06-4391-8505-3a35832aefc1 -2.11085866    3.149893
#>  2: 82e17126-e9f0-49a3-b63f-a9b24290cd61 -8.33732121    3.178398
#>  3: 4a1064eb-f49b-4de4-bcdf-16c806e38e91 -7.78396197    2.105379
#>  4: 8f46609b-ac32-40c9-a9c2-5267305f8e0c  5.92632791   -4.231512
#>  5: 52debbf7-4022-4761-82be-21a03168a06c  0.98995613    2.678818
#>  6: 56c568d9-7f09-40fb-b18f-269896bb952f -3.50214144    1.111543
#>  7: 274c2785-5dd3-43d7-b186-6fb77ee7ddf3  2.77985531    4.933030
#>  8: 79e9dc4d-7cbd-45c4-9982-e4eced5ffd14  9.86020590    0.052479
#>  9: a80e8e53-0e05-43f6-95ff-beb951070560 -4.77089430    4.984108
#> 10: fff53769-177b-4fad-a651-1cfc2f631274  8.62827623    3.264048
#> 11: f8fff645-15e5-4cfe-9dab-c60cffa87864  5.20608164   -2.035465
#> 12: 0117969d-87c3-4ec8-b4ad-f01c5057559d -0.97588025    1.013553
#> 13: 4e9e508c-e605-429d-b9ff-1cb7cec5b22b -9.42569878    0.916582
#> 14: 131d8c83-2e42-4592-82b6-d22ebcd2423a  0.07085662    3.202987
#> 15: c831f8f5-bb52-4285-b9ac-dd6c36a7dd12 -6.61173459    1.705343
#> 16: c067d36c-c385-4cbe-a3f7-f76264e56f40  8.34573561    3.714461
#> 17: d13b37e6-5452-44f8-a00e-e35dd800c3ce -8.96971468   -3.263809
#> 18: d8bb01e3-3793-4d27-abc8-3477c49fac48  1.89838435    2.698046
#> 19: 5f80f577-ecff-4a60-8e9d-2f4433665faa -2.71425870    1.813992
#> 20: 8de9d953-3516-43d8-b007-d4341c1ab866  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
