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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-12 16:20:40
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-12 16:20:40
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-12 16:20:40
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-12 16:20:40
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-12 16:20:40
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-12 16:20:40
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-12 16:20:40
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-12 16:20:40
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-12 16:20:40
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-12 16:20:40
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-12 16:20:40
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-12 16:20:40
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-12 16:20:40
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-12 16:20:40
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-12 16:20:40
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-12 16:20:40
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-12 16:20:40
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-12 16:20:40
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-12 16:20:40
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-12 16:20:40
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  2: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  3: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  4: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  5: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  6: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  7: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  8: narrow_xinjiangovenator 2026-06-12 16:20:40
#>  9: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 10: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 11: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 12: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 13: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 14: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 15: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 16: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 17: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 18: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 19: narrow_xinjiangovenator 2026-06-12 16:20:40
#> 20: narrow_xinjiangovenator 2026-06-12 16:20:40
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 476d0fa5-3ccd-4248-8085-ca74bddbd476 -2.11085866    3.149893
#>  2: b90c79a2-32fe-422d-8288-2effd9205a25 -8.33732121    3.178398
#>  3: f545d527-53f9-48e7-ae43-923fa1b74ee9 -7.78396197    2.105379
#>  4: ddbfbafc-e17c-49eb-9308-49d1377a949a  5.92632791   -4.231512
#>  5: 994c0e7a-e08f-4e91-8e07-5b50951f8461  0.98995613    2.678818
#>  6: 57636c84-db83-4666-862f-a1607ca553b9 -3.50214144    1.111543
#>  7: 1eaf53de-679d-477b-9d67-9c99b51ac765  2.77985531    4.933030
#>  8: fc46658b-3914-46fe-81cd-0b0a6539602a  9.86020590    0.052479
#>  9: fa55609e-b5b2-420d-a95e-a7c13c658759 -4.77089430    4.984108
#> 10: d5286dd2-9f07-4e2b-86fe-7f7f28464f7c  8.62827623    3.264048
#> 11: 843f584f-145c-414b-aaf7-b76631f02ec6  5.20608164   -2.035465
#> 12: c902bc0a-d4d5-4b82-9e64-d6d6c9dc5658 -0.97588025    1.013553
#> 13: 3a81dd6f-fc46-4e80-a4b1-25abcd2affd3 -9.42569878    0.916582
#> 14: dfed8c72-f31e-4d09-8e2e-6ecdefa3a993  0.07085662    3.202987
#> 15: d5799595-65db-4fd5-af68-5cc55c1e32b9 -6.61173459    1.705343
#> 16: b0cf3d8f-6885-403a-b91b-48cbf2f5b32a  8.34573561    3.714461
#> 17: 25d09baa-7f75-4087-8738-2bf2323b7a4e -8.96971468   -3.263809
#> 18: b07eeadc-db74-4926-9a7d-b02dc8d130e5  1.89838435    2.698046
#> 19: 9ef00532-38c8-4de3-9bfd-d868c2876bc1 -2.71425870    1.813992
#> 20: bbffa988-ca4c-4a17-bdae-0c44f7fc54d5  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
