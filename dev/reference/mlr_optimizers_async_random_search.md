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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 11:46:07
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 11:46:07
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 11:46:07
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 11:46:07
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 11:46:07
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 11:46:07
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 11:46:07
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 11:46:07
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 11:46:07
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 11:46:07
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 11:46:07
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 11:46:07
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 11:46:07
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 11:46:07
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 11:46:07
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 11:46:07
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 11:46:07
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 11:46:07
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 11:46:07
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 11:46:07
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  2: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  3: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  4: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  5: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  6: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  7: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  8: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>  9: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 10: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 11: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 12: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 13: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 14: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 15: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 16: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 17: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 18: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 19: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#> 20: narrow_xinjiangovenator_cd355fd6 2026-09-03 11:46:07
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 8019d7f5-31e7-4df5-bf88-555c8c13089c -2.11085866    3.149893
#>  2: 49a56b26-bd59-4ede-864f-3c8f4ef5e32a -8.33732121    3.178398
#>  3: 51086995-3d78-4643-81a3-2cc9798fca7a -7.78396197    2.105379
#>  4: 314f04e6-592f-43c3-a41d-fe8a6cffa380  5.92632791   -4.231512
#>  5: 9cab697f-14be-4cd2-878a-2bb40cf151ee  0.98995613    2.678818
#>  6: 62da189c-38c5-4dd9-a361-8c367ede6d32 -3.50214144    1.111543
#>  7: 17443043-2ff0-4795-b5fb-f6a0264fddae  2.77985531    4.933030
#>  8: 27f3374a-bc06-49d0-98d3-923f98c50ba7  9.86020590    0.052479
#>  9: c73f2ebd-4b07-4603-a994-b860060b15f0 -4.77089430    4.984108
#> 10: 758a296c-01e6-488e-abb0-ba400fa1f40c  8.62827623    3.264048
#> 11: 0656751d-0669-49e8-b9e9-efe8c1ac5ac7  5.20608164   -2.035465
#> 12: 0d70e7fb-74f2-4248-ba7f-7fd70b054b44 -0.97588025    1.013553
#> 13: 23f6b4df-d7a3-44a0-8c4c-5be1a52439b1 -9.42569878    0.916582
#> 14: c4e4efeb-b156-4b0a-9b45-d1f257db5ea3  0.07085662    3.202987
#> 15: 2ff4f87e-43c6-42a1-a877-1d8471def2b0 -6.61173459    1.705343
#> 16: 17e55d02-2691-4380-a181-40894733b855  8.34573561    3.714461
#> 17: 8830f0aa-dc18-4f62-ab79-2a760821bd3a -8.96971468   -3.263809
#> 18: 7d7b1df1-7ebe-4179-a1b1-6ce4546dcc9b  1.89838435    2.698046
#> 19: c7c3453d-22c7-4eb8-86d6-b9e5622c49a8 -2.71425870    1.813992
#> 20: 04b9f033-4d89-4334-af09-c7f539051abe  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
