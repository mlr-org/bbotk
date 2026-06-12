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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-12 16:23:48
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-12 16:23:48
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-12 16:23:48
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-12 16:23:48
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-12 16:23:48
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-12 16:23:48
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-12 16:23:48
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-12 16:23:48
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-12 16:23:48
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-12 16:23:48
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-12 16:23:48
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-12 16:23:48
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-12 16:23:48
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-12 16:23:48
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-12 16:23:48
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-12 16:23:48
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-12 16:23:49
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-12 16:23:49
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-12 16:23:49
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-12 16:23:49
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  2: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  3: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  4: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  5: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  6: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  7: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  8: narrow_xinjiangovenator 2026-06-12 16:23:48
#>  9: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 10: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 11: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 12: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 13: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 14: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 15: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 16: narrow_xinjiangovenator 2026-06-12 16:23:48
#> 17: narrow_xinjiangovenator 2026-06-12 16:23:49
#> 18: narrow_xinjiangovenator 2026-06-12 16:23:49
#> 19: narrow_xinjiangovenator 2026-06-12 16:23:49
#> 20: narrow_xinjiangovenator 2026-06-12 16:23:49
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 86767820-ed41-4d21-b5d9-0900d6504c26 -2.11085866    3.149893
#>  2: c6eedb16-b2db-4337-9b65-744b9a25535c -8.33732121    3.178398
#>  3: b47541e4-cd5f-47e5-a742-6cdc695a63cb -7.78396197    2.105379
#>  4: 6ebca771-5016-4262-b3c6-e7e1fb1f3379  5.92632791   -4.231512
#>  5: a0f2fc9e-11d4-40ad-b4e8-f91e69e6eb53  0.98995613    2.678818
#>  6: 40aaeb7a-db29-4938-ad58-54da09ac5853 -3.50214144    1.111543
#>  7: 401d5d0f-3d85-45e3-ba1b-764801e41497  2.77985531    4.933030
#>  8: ca4b47a8-e2f1-4b29-8515-b9eececa8ccf  9.86020590    0.052479
#>  9: 347a7191-12c6-4e3b-8975-14f96e640fa6 -4.77089430    4.984108
#> 10: 6d167c99-c486-4f17-ae03-4e6481d1b7a1  8.62827623    3.264048
#> 11: efe5d549-7564-43ac-9b0c-118396fe057b  5.20608164   -2.035465
#> 12: f81c0402-3820-4bc7-93d6-c80bd99b70f3 -0.97588025    1.013553
#> 13: fd8008b8-880e-445f-a952-e85ab13c5a5a -9.42569878    0.916582
#> 14: af4c51b0-8680-422f-a774-ada5b7abc8e7  0.07085662    3.202987
#> 15: 57d29ed8-87e0-414a-a7a9-5460c430e0f1 -6.61173459    1.705343
#> 16: 9b046fda-a6a3-49e3-a4a3-2166f1c6527c  8.34573561    3.714461
#> 17: 74416c83-8b3e-4b3b-a546-4a36fc1b0d1f -8.96971468   -3.263809
#> 18: 6b69dc50-d500-4fea-b686-32f0a160e9f4  1.89838435    2.698046
#> 19: ea94e37a-d59a-4d55-8bb7-bdb9a896e8d1 -2.71425870    1.813992
#> 20: 8d0d29ed-c1a8-42a0-9304-4589bf46aee2  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
