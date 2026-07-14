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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-14 14:48:18
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-14 14:48:18
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-14 14:48:18
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-14 14:48:18
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-14 14:48:18
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-14 14:48:18
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-14 14:48:18
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-14 14:48:18
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-14 14:48:19
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-14 14:48:19
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-14 14:48:19
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-14 14:48:19
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-14 14:48:19
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-14 14:48:19
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-14 14:48:19
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-14 14:48:19
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-14 14:48:19
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-14 14:48:19
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-14 14:48:19
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-14 14:48:19
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  2: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  3: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  4: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  5: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  6: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  7: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  8: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:18
#>  9: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 10: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 11: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 12: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 13: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 14: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 15: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 16: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 17: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 18: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 19: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#> 20: narrow_xinjiangovenator_c5e9b7d4 2026-07-14 14:48:19
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: a43b634d-4e0e-44fa-a330-c94acd1200a5 -2.11085866    3.149893
#>  2: f9413e36-1b28-4684-90c1-be9ec8274609 -8.33732121    3.178398
#>  3: 27de195c-bb97-4c2d-bf2e-b576e0b48138 -7.78396197    2.105379
#>  4: 2aada311-58b1-4bf7-adb0-44d9c5dc81d3  5.92632791   -4.231512
#>  5: c9a5967c-6bfb-420b-a78c-d995191f3111  0.98995613    2.678818
#>  6: bf22699f-4011-4c69-913f-55f9a83f4ccd -3.50214144    1.111543
#>  7: 137d91f7-4f59-4f03-8b8d-bc92593f8d4f  2.77985531    4.933030
#>  8: d43d3168-2a5d-4123-b598-8ae8505f8b1b  9.86020590    0.052479
#>  9: 65250f79-b73d-47ea-9252-b1736f717acc -4.77089430    4.984108
#> 10: 9f4687eb-a372-47fd-9400-76779bb75cf4  8.62827623    3.264048
#> 11: 24e4dcb6-430f-49aa-b608-107b46025ad8  5.20608164   -2.035465
#> 12: 55f64d62-1a2b-4165-878c-749f89518b5f -0.97588025    1.013553
#> 13: d9973b3d-edfc-41b0-b7aa-dd599a8b45ea -9.42569878    0.916582
#> 14: a4d795be-39b5-46db-9006-309b1a32a5dd  0.07085662    3.202987
#> 15: 8edbe511-8a35-417b-8e27-4550f2ef642e -6.61173459    1.705343
#> 16: c13a2076-f757-436b-9fb3-4a019c9a5988  8.34573561    3.714461
#> 17: e35fc3da-69ee-49ca-a822-b90ddc7f59be -8.96971468   -3.263809
#> 18: f294646c-b0b9-4b56-8459-797f1b9071b0  1.89838435    2.698046
#> 19: 8878db47-8a62-4c0d-bfbf-d1395bcba607 -2.71425870    1.813992
#> 20: 3c29b1fc-c4c4-4f37-9d6b-f4a671a01205  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
