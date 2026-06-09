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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-09 18:24:17
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-09 18:24:17
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-09 18:24:17
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-09 18:24:17
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-09 18:24:17
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-09 18:24:17
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-09 18:24:17
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-09 18:24:17
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-09 18:24:17
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-09 18:24:17
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-09 18:24:17
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-09 18:24:17
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-09 18:24:17
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-09 18:24:17
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-09 18:24:17
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-09 18:24:17
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-09 18:24:17
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-09 18:24:17
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-09 18:24:17
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-09 18:24:17
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  2: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  3: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  4: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  5: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  6: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  7: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  8: narrow_xinjiangovenator 2026-06-09 18:24:17
#>  9: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 10: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 11: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 12: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 13: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 14: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 15: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 16: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 17: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 18: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 19: narrow_xinjiangovenator 2026-06-09 18:24:17
#> 20: narrow_xinjiangovenator 2026-06-09 18:24:17
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 45285a57-db12-4917-b2da-3d69e271179f -2.11085866    3.149893
#>  2: 5d6950bf-5193-4879-8415-9e16aa9ca719 -8.33732121    3.178398
#>  3: dd19a855-4aaf-492a-8a8a-6c38d917f076 -7.78396197    2.105379
#>  4: 446112f3-c823-40e2-883b-ae785d243f5f  5.92632791   -4.231512
#>  5: 4905b609-bbf5-49e4-82bf-7af7b8c2807d  0.98995613    2.678818
#>  6: 3139b6f2-b0ff-42bc-a107-ec78f175a138 -3.50214144    1.111543
#>  7: d89833ba-b336-49ed-a702-a1e1980d7c93  2.77985531    4.933030
#>  8: 79386317-7322-44cd-8029-42629b76e89c  9.86020590    0.052479
#>  9: 48063513-966e-420e-b8cd-3e38da1f621d -4.77089430    4.984108
#> 10: 3ba3f543-a842-4bcf-9d98-7eb5934f27fb  8.62827623    3.264048
#> 11: dac3741e-93f4-4e39-a427-8832f55d254a  5.20608164   -2.035465
#> 12: 9bceab95-9d0c-47dd-a8e8-7c48e4566003 -0.97588025    1.013553
#> 13: cbadfdd4-30f5-4362-914c-cbe6bd44cb51 -9.42569878    0.916582
#> 14: ffa8e136-2be4-4db8-ad8d-1a5d446637f6  0.07085662    3.202987
#> 15: 3532ef6d-3475-4551-95be-6ddec08b12e0 -6.61173459    1.705343
#> 16: 322fb0ba-b3dd-46ba-9a95-c452c944b935  8.34573561    3.714461
#> 17: 28e270af-9e8d-49ed-830e-b754fd644caf -8.96971468   -3.263809
#> 18: 124db031-67cd-4402-af84-8b88bb325bb8  1.89838435    2.698046
#> 19: 0b529b65-1f30-45e5-8438-f90e3e597aac -2.71425870    1.813992
#> 20: 0504e1fc-c18d-4e10-9f06-f50fba557f2b  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
