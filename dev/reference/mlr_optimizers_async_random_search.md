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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 08:18:14
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 08:18:15
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 08:18:15
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 08:18:15
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 08:18:15
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 08:18:15
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 08:18:15
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 08:18:15
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 08:18:15
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 08:18:15
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 08:18:15
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 08:18:15
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 08:18:15
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 08:18:15
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 08:18:15
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 08:18:15
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 08:18:15
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 08:18:15
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 08:18:15
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 08:18:15
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:14
#>  2: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  3: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  4: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  5: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  6: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  7: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  8: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>  9: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 10: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 11: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 12: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 13: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 14: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 15: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 16: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 17: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 18: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 19: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#> 20: narrow_xinjiangovenator_e508f282 2026-09-17 08:18:15
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 468ea775-5539-4c3d-82db-07555feabfed -2.11085866    3.149893
#>  2: 11fed08a-85f2-4056-85cb-95f486186bc6 -8.33732121    3.178398
#>  3: 9255f587-a07c-4f07-b4bc-b2d3b9d161a5 -7.78396197    2.105379
#>  4: 7cc9b8ec-53e9-4d60-976d-38d5d6802030  5.92632791   -4.231512
#>  5: be53f0d9-b334-4447-999d-d2c93742007a  0.98995613    2.678818
#>  6: 1db5f948-7175-4ad0-a47b-c976ff99f169 -3.50214144    1.111543
#>  7: f68c2037-7176-434b-b0a5-17c09b7eb2de  2.77985531    4.933030
#>  8: 3b96797c-3a24-4b13-9a25-ffc9f4d609e7  9.86020590    0.052479
#>  9: 7ab55992-5edf-445e-a984-a29d82a37c66 -4.77089430    4.984108
#> 10: e62e594d-4edc-4946-a050-fde58386fa52  8.62827623    3.264048
#> 11: dfcc9912-3ed1-4e7a-9041-c5efb3a37c5c  5.20608164   -2.035465
#> 12: 7b51d590-9686-452f-bd89-baaf27b99299 -0.97588025    1.013553
#> 13: 99e813ad-6a2f-4290-8226-d566cfa5e071 -9.42569878    0.916582
#> 14: 43016850-348d-40db-9fb1-4d710352f21d  0.07085662    3.202987
#> 15: ca744b36-d6a2-4a3e-86b6-9c32e790a035 -6.61173459    1.705343
#> 16: bc0fdb5b-7712-4f4a-a108-0503586f71df  8.34573561    3.714461
#> 17: 10cb5429-c15d-4461-ac7d-c237899c2242 -8.96971468   -3.263809
#> 18: 0aa9cdf8-85a1-48b9-8cf1-1c02fd8c0d61  1.89838435    2.698046
#> 19: 282a31a2-7bc6-4b68-badb-b82a79cb42bb -2.71425870    1.813992
#> 20: 9a6b4ad8-acb2-46e8-96c0-b39e2dcc6a54  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
