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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-20 08:47:24
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-20 08:47:24
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-20 08:47:24
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-20 08:47:25
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-20 08:47:25
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-20 08:47:25
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-20 08:47:25
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-20 08:47:25
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-20 08:47:25
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-20 08:47:25
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-20 08:47:25
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-20 08:47:25
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-20 08:47:25
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-20 08:47:25
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-20 08:47:25
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-20 08:47:25
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-20 08:47:25
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-20 08:47:25
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-20 08:47:25
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-20 08:47:25
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:24
#>  2: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:24
#>  3: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:24
#>  4: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>  5: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>  6: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>  7: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>  8: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>  9: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 10: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 11: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 12: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 13: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 14: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 15: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 16: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 17: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 18: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 19: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#> 20: narrow_xinjiangovenator_a8b55bec 2026-07-20 08:47:25
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 4cedd5d4-d2f0-4688-8d16-b27b47715ce9 -2.11085866    3.149893
#>  2: 9dd2c69f-ccc9-4f23-b964-3f7478eb7f11 -8.33732121    3.178398
#>  3: ecee2ca4-f3bb-4edb-a185-bd8e2f1ad478 -7.78396197    2.105379
#>  4: 879fad0c-b601-4479-8807-6ab59ee36eef  5.92632791   -4.231512
#>  5: df83fc0b-8336-4d41-bc2b-7d9d0c5e7c04  0.98995613    2.678818
#>  6: b8f85e43-9bad-40b3-8de6-5d1221a158e1 -3.50214144    1.111543
#>  7: b2b82bb9-a798-441d-9d36-3b663b1409ed  2.77985531    4.933030
#>  8: 006735c2-1bb5-4f55-837a-adf0617a00ea  9.86020590    0.052479
#>  9: 7bf22598-4780-4878-a692-3c84e65948e4 -4.77089430    4.984108
#> 10: d3697d13-d358-4d9b-bea0-67f78648b51c  8.62827623    3.264048
#> 11: 10895f60-74f8-4df1-9367-890d931c613b  5.20608164   -2.035465
#> 12: ee1ddff5-d1cb-4f4f-a4aa-19054e05fed2 -0.97588025    1.013553
#> 13: cd5e9f85-23b2-4a5d-be0b-bf7f5809a8e8 -9.42569878    0.916582
#> 14: b330880c-f1e1-4268-9ac7-7003b048f0fd  0.07085662    3.202987
#> 15: d61c79e3-2b8a-4c8b-b89f-6b26453d64b2 -6.61173459    1.705343
#> 16: 254df64d-655c-42e6-9dd4-2250394697eb  8.34573561    3.714461
#> 17: d7e6dcde-9224-41b5-9929-f1bfeff51c51 -8.96971468   -3.263809
#> 18: 2770cff9-4dc3-4163-b75f-2298b22c9c58  1.89838435    2.698046
#> 19: fb74b48b-7d31-4c8e-a1dc-73910afe83ee -2.71425870    1.813992
#> 20: f6a9a654-e353-46fb-a176-928023090552  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
