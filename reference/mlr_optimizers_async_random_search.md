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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-27 12:47:09
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-27 12:47:09
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-27 12:47:09
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-27 12:47:09
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-27 12:47:09
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-27 12:47:09
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-27 12:47:09
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-27 12:47:09
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-27 12:47:09
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-27 12:47:09
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-27 12:47:09
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-27 12:47:09
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-27 12:47:09
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-27 12:47:09
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-27 12:47:09
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-27 12:47:09
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-27 12:47:10
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-27 12:47:10
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-27 12:47:10
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-27 12:47:10
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  2: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  3: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  4: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  5: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  6: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  7: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  8: narrow_xinjiangovenator 2026-06-27 12:47:09
#>  9: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 10: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 11: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 12: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 13: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 14: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 15: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 16: narrow_xinjiangovenator 2026-06-27 12:47:09
#> 17: narrow_xinjiangovenator 2026-06-27 12:47:10
#> 18: narrow_xinjiangovenator 2026-06-27 12:47:10
#> 19: narrow_xinjiangovenator 2026-06-27 12:47:10
#> 20: narrow_xinjiangovenator 2026-06-27 12:47:10
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 7a6b8b3c-3972-4175-9d17-37e6dad00696 -2.11085866    3.149893
#>  2: f34ab33b-b69e-443d-9c7f-f3b0b21b15e2 -8.33732121    3.178398
#>  3: 03790590-4034-4997-be7e-f31f08d95295 -7.78396197    2.105379
#>  4: 5f9e6bae-19a8-4a70-96b8-0b63cdefdec2  5.92632791   -4.231512
#>  5: e2407488-552f-4d82-9529-1f902e723ca9  0.98995613    2.678818
#>  6: 800cb534-a275-427d-ab24-c0bc64e1a9a0 -3.50214144    1.111543
#>  7: ac06b7a3-9e51-4b40-bf5d-ff0c5d9fdd46  2.77985531    4.933030
#>  8: 204ff69e-fa68-4b4d-8a08-3139c0f5fe57  9.86020590    0.052479
#>  9: 004a26af-6fcb-4bd0-b978-c418da265757 -4.77089430    4.984108
#> 10: c73d60f1-b6ed-4690-9d20-d85159a5909a  8.62827623    3.264048
#> 11: 73b23896-27dc-4808-a240-22d61ea0dc04  5.20608164   -2.035465
#> 12: c799db85-f5ce-407b-a0bc-e4974d2bfd98 -0.97588025    1.013553
#> 13: b0c9275f-303a-4ef8-ac2f-539342c4c0ed -9.42569878    0.916582
#> 14: af8b7a2b-8f8e-4bcf-ac5f-285934758491  0.07085662    3.202987
#> 15: 86968fea-4b5c-4e51-8044-7e561ec2e7e1 -6.61173459    1.705343
#> 16: 9cd60179-ad10-4b85-b52a-9d67dd8aa37a  8.34573561    3.714461
#> 17: 3d8d1ff2-773c-4942-b11f-ac1ad6287b40 -8.96971468   -3.263809
#> 18: 874765a5-17d2-4164-9404-9b55f70fef37  1.89838435    2.698046
#> 19: e37dec83-0093-44c7-b60e-49aad5b21475 -2.71425870    1.813992
#> 20: a4f1ef2f-5163-49c7-b7b6-a5fad243fe15  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
