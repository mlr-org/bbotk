# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-initialize)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerAsync.html#method-optimize)

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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 10:50:36
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 10:50:36
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 10:50:36
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 10:50:36
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 10:50:36
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 10:50:36
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 10:50:36
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 10:50:36
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 10:50:36
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 10:50:36
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 10:50:36
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 10:50:36
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 10:50:36
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 10:50:36
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 10:50:36
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 10:50:36
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 10:50:36
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 10:50:36
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 10:50:36
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 10:50:36
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  2: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  3: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  4: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  5: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  6: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  7: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  8: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>  9: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 10: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 11: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 12: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 13: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 14: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 15: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 16: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 17: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 18: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 19: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#> 20: narrow_xinjiangovenator_352b7417 2026-09-03 10:50:36
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 6a52975f-9eaa-410f-b449-d67e29d2dc7f -2.11085866    3.149893
#>  2: 385255c4-ae68-4580-ad37-3a6700794f0b -8.33732121    3.178398
#>  3: 59fa96cc-37a4-41bf-92f5-2af275a73006 -7.78396197    2.105379
#>  4: b11d553d-d031-435d-970d-6ed33ec8ff8c  5.92632791   -4.231512
#>  5: e155b421-2943-467c-ade4-6b8686ca5426  0.98995613    2.678818
#>  6: 2e3ab436-beab-4422-a63b-0c7a32afc4d1 -3.50214144    1.111543
#>  7: 44ac9253-414f-403f-a5e5-ac7282610ce1  2.77985531    4.933030
#>  8: c6716be5-20ae-400d-a6da-0a8700569aa6  9.86020590    0.052479
#>  9: d24fef93-e464-4479-b58d-72482f28a209 -4.77089430    4.984108
#> 10: 801b6dac-0100-4297-9385-ded400c49258  8.62827623    3.264048
#> 11: 7fc2584c-799a-4493-9420-9256227f8c9b  5.20608164   -2.035465
#> 12: 8d41a89d-ed78-47f2-a77b-1daa8cafe1c0 -0.97588025    1.013553
#> 13: 0dbb7fb8-049e-4208-b91c-c5894c610528 -9.42569878    0.916582
#> 14: f5da17f1-e27d-469e-b110-3d5d94956b84  0.07085662    3.202987
#> 15: cf676c51-2742-4c50-aaf1-f692ddd46c14 -6.61173459    1.705343
#> 16: 322e9fa1-13ab-4ac5-af76-e06d412008cb  8.34573561    3.714461
#> 17: 66f5a308-340d-4a88-b43f-b00a1cdb8898 -8.96971468   -3.263809
#> 18: f7cd5843-c729-47fe-a871-8a7fe8ac5ddc  1.89838435    2.698046
#> 19: 7c872b67-8641-4533-8344-24752eeaa66d -2.71425870    1.813992
#> 20: 65e4cbf0-ce91-48b0-95b9-9cdd8084421f  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
