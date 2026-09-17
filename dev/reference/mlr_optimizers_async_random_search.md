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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 12:33:46
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 12:33:46
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 12:33:46
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 12:33:46
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 12:33:46
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 12:33:46
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 12:33:46
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 12:33:46
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 12:33:46
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 12:33:46
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 12:33:46
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 12:33:46
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 12:33:46
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 12:33:46
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 12:33:46
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 12:33:47
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 12:33:47
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 12:33:47
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 12:33:47
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 12:33:47
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  2: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  3: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  4: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  5: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  6: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  7: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  8: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#>  9: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 10: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 11: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 12: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 13: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 14: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 15: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:46
#> 16: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:47
#> 17: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:47
#> 18: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:47
#> 19: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:47
#> 20: narrow_xinjiangovenator_b52df2d3 2026-09-17 12:33:47
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 128cbb60-25f0-47a8-b5e5-0a9ac11b8176 -2.11085866    3.149893
#>  2: 94b1c7b1-bd02-4f70-b911-f89d8354e753 -8.33732121    3.178398
#>  3: 10d1c2be-4330-4dcc-8946-12f68f31c3dc -7.78396197    2.105379
#>  4: 2260ba21-e243-46be-b322-b56f1076e777  5.92632791   -4.231512
#>  5: 7143c8e9-4c8b-4611-8c73-5fd96b27dbc0  0.98995613    2.678818
#>  6: dc39f766-5387-44a7-9e06-549cf88f3a9d -3.50214144    1.111543
#>  7: 8b1634fc-0621-43f8-a246-415089c323ff  2.77985531    4.933030
#>  8: ae80cb45-35d4-4986-bacf-6fab280c77ab  9.86020590    0.052479
#>  9: f14a0ad5-c934-4f33-a63f-1a57e926a435 -4.77089430    4.984108
#> 10: 506099fb-c250-4996-b25d-bc42dabca16c  8.62827623    3.264048
#> 11: a1958e7c-856f-4049-b92b-45164f9b8542  5.20608164   -2.035465
#> 12: abe93e51-02dc-4adb-898b-37388999c5c0 -0.97588025    1.013553
#> 13: 844b366b-87c0-4a0e-88a2-fe4bd71c946b -9.42569878    0.916582
#> 14: 0e6220cb-ce8b-4dd7-9210-135a1c2f32a1  0.07085662    3.202987
#> 15: 1fea174f-92e6-442a-9c5b-5956a088e401 -6.61173459    1.705343
#> 16: 60edc4ee-11e2-4a4b-b245-5f7fc87238d0  8.34573561    3.714461
#> 17: 7dcb7d53-e4c2-42dd-ae75-304974a32bb8 -8.96971468   -3.263809
#> 18: ec141f94-7b00-4435-921b-1e803d64e276  1.89838435    2.698046
#> 19: 2d6de8a0-479f-42f0-acd6-1dbd942653f5 -2.71425870    1.813992
#> 20: 8f339fb4-0989-42f6-9594-25de2c857d4d  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
