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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-09 16:20:15
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-09 16:20:15
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-09 16:20:15
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-09 16:20:15
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-09 16:20:15
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-09 16:20:15
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-09 16:20:15
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-09 16:20:15
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-09 16:20:15
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-09 16:20:15
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-09 16:20:15
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-09 16:20:15
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-09 16:20:15
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-09 16:20:15
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-09 16:20:15
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-09 16:20:15
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-09 16:20:15
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-09 16:20:15
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-09 16:20:15
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-09 16:20:15
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  2: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  3: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  4: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  5: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  6: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  7: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  8: narrow_xinjiangovenator 2026-06-09 16:20:15
#>  9: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 10: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 11: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 12: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 13: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 14: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 15: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 16: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 17: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 18: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 19: narrow_xinjiangovenator 2026-06-09 16:20:15
#> 20: narrow_xinjiangovenator 2026-06-09 16:20:15
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 4b1c7745-5cf4-4235-aab4-4e4f35985b40 -2.11085866    3.149893
#>  2: 1d696dc2-f5b3-4963-ad1c-ecae4b426754 -8.33732121    3.178398
#>  3: 007f4ea7-76c2-49a9-a374-98cc18d1386f -7.78396197    2.105379
#>  4: 4ed6fb67-b3fb-4f70-ac4f-1ce5785521d9  5.92632791   -4.231512
#>  5: 280feefd-229a-4f48-9994-f5024e42d1c0  0.98995613    2.678818
#>  6: c586c97a-0894-4dc5-a6b7-87221e403635 -3.50214144    1.111543
#>  7: 65b20017-766a-4438-88f1-8d4e55b9d18f  2.77985531    4.933030
#>  8: cf41c23c-a61b-4948-a0cd-c970aa9c503a  9.86020590    0.052479
#>  9: 028520d6-2df6-4984-8b69-c1ee3bde31fd -4.77089430    4.984108
#> 10: f1d74203-f852-41ad-ab06-b34400266663  8.62827623    3.264048
#> 11: baea01d2-cc64-4ff6-bd57-7aa2c6459229  5.20608164   -2.035465
#> 12: 25782911-d0ba-4452-9eb8-86d9bebbe56c -0.97588025    1.013553
#> 13: 96542dc2-4dcc-414e-9a5a-cdf73e85db48 -9.42569878    0.916582
#> 14: a93460c0-76b2-456b-8f7e-a3b353c780c1  0.07085662    3.202987
#> 15: dbd482c4-0500-49d7-b35a-9fdcce2a4712 -6.61173459    1.705343
#> 16: 66947f84-613d-4907-94ec-eb1334bcab07  8.34573561    3.714461
#> 17: 6169dcf9-09ad-44eb-9a59-b4ab58a9e80f -8.96971468   -3.263809
#> 18: 8ac4ea9f-0131-43e2-b2ac-29502a584bfa  1.89838435    2.698046
#> 19: f14e3c02-59ec-43c1-96b0-1e7dc42a9148 -2.71425870    1.813992
#> 20: 39e71c28-f2e7-4ca1-b6a3-00d2579a84a6  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
