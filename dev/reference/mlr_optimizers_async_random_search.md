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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-10 12:15:38
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-10 12:15:38
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-10 12:15:38
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-10 12:15:38
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-10 12:15:38
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-10 12:15:38
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-10 12:15:38
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-10 12:15:38
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-10 12:15:38
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-10 12:15:38
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-10 12:15:38
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-10 12:15:38
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-10 12:15:38
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-10 12:15:39
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-10 12:15:39
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-10 12:15:39
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-10 12:15:39
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-10 12:15:39
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-10 12:15:39
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-10 12:15:39
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  2: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  3: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  4: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  5: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  6: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  7: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  8: narrow_xinjiangovenator 2026-06-10 12:15:38
#>  9: narrow_xinjiangovenator 2026-06-10 12:15:38
#> 10: narrow_xinjiangovenator 2026-06-10 12:15:38
#> 11: narrow_xinjiangovenator 2026-06-10 12:15:38
#> 12: narrow_xinjiangovenator 2026-06-10 12:15:38
#> 13: narrow_xinjiangovenator 2026-06-10 12:15:38
#> 14: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 15: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 16: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 17: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 18: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 19: narrow_xinjiangovenator 2026-06-10 12:15:39
#> 20: narrow_xinjiangovenator 2026-06-10 12:15:39
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 8b01d120-4cf2-41c8-8c52-31c951cd765f -2.11085866    3.149893
#>  2: 93e3d1e3-ca98-4a37-adc0-5dd9f2aa2bd0 -8.33732121    3.178398
#>  3: 8b43f346-d3ed-4bc1-99d2-270b734383fe -7.78396197    2.105379
#>  4: 0c0e7d6d-22e0-4124-9af4-d3bd1f4cbdc1  5.92632791   -4.231512
#>  5: 7aa92ae9-9487-4cea-bd5b-14016db9df2c  0.98995613    2.678818
#>  6: bae43b3c-7ace-4a9a-a134-45d13306a0f8 -3.50214144    1.111543
#>  7: c04d5f93-9589-4a16-932d-11492b3bf0e7  2.77985531    4.933030
#>  8: c4f1075d-d60f-4126-a373-136f2eda2923  9.86020590    0.052479
#>  9: b40932c2-7b55-4380-b7fc-ed65640ab784 -4.77089430    4.984108
#> 10: 8f21e6d6-a4b0-4b8d-8467-4409a1e94db8  8.62827623    3.264048
#> 11: 02ec9826-b445-4b00-acc0-dd240bd87c20  5.20608164   -2.035465
#> 12: 6f6aed67-fee6-4143-a695-bcc0a1a0fbd2 -0.97588025    1.013553
#> 13: d339c6ef-11fe-4ae3-982a-b153690b884a -9.42569878    0.916582
#> 14: 07364caf-ce34-4334-b524-661dec315bff  0.07085662    3.202987
#> 15: 63315590-0b94-4803-9e7f-100c86382302 -6.61173459    1.705343
#> 16: eadc88fb-d7a7-47a7-a4da-a2526ad8a056  8.34573561    3.714461
#> 17: 94509044-f430-453c-b490-92d8959fe553 -8.96971468   -3.263809
#> 18: f5ab6904-95a4-4a97-b69e-0ec891502612  1.89838435    2.698046
#> 19: e22e33a9-6294-4501-b448-26a280412fb4 -2.71425870    1.813992
#> 20: 9b04af16-f390-4990-b3a3-2e56e9fb1f06  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
