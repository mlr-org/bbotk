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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-26 10:08:03
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-26 10:08:03
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-26 10:08:03
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-26 10:08:03
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-26 10:08:03
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-26 10:08:03
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-26 10:08:03
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-26 10:08:03
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-26 10:08:03
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-26 10:08:03
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-26 10:08:03
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-26 10:08:03
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-26 10:08:03
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-26 10:08:03
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-26 10:08:03
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-26 10:08:03
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-26 10:08:03
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-26 10:08:03
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-26 10:08:03
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-26 10:08:03
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  2: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  3: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  4: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  5: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  6: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  7: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  8: narrow_xinjiangovenator 2026-06-26 10:08:03
#>  9: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 10: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 11: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 12: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 13: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 14: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 15: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 16: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 17: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 18: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 19: narrow_xinjiangovenator 2026-06-26 10:08:03
#> 20: narrow_xinjiangovenator 2026-06-26 10:08:03
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: f12cc555-adda-45a1-baf3-454bee15de77 -2.11085866    3.149893
#>  2: cc435326-388a-413b-96f9-8c65066af273 -8.33732121    3.178398
#>  3: cb4648ce-4732-4f43-92ff-c857a50c01c2 -7.78396197    2.105379
#>  4: 5d53899d-8694-4816-be1f-02c6120d8967  5.92632791   -4.231512
#>  5: 42e6f646-7eb0-4c16-a817-e6efbdcf92a3  0.98995613    2.678818
#>  6: d90a9b86-991c-49fd-a058-6e020d3b57dc -3.50214144    1.111543
#>  7: 87d38b91-dd14-4456-83e1-9fe6c07a39d1  2.77985531    4.933030
#>  8: 28924183-200f-42b5-9be4-27c8c2b5b84e  9.86020590    0.052479
#>  9: 9e1b1af7-87e0-4960-9f99-425515ba8ef3 -4.77089430    4.984108
#> 10: 07ac4ad8-7e18-4b2c-b7b6-e3632c0f2fd1  8.62827623    3.264048
#> 11: 11682feb-83e6-4ed9-89f6-7fa6db4f6489  5.20608164   -2.035465
#> 12: 53cfd9fb-a7cd-4e05-8bb8-0cf88c7d73c3 -0.97588025    1.013553
#> 13: b1191096-1514-43b1-935d-3b258599afcb -9.42569878    0.916582
#> 14: da6bb06c-1a62-4a73-baf6-e74f228f0166  0.07085662    3.202987
#> 15: b2fce7c0-d27d-4150-ab88-7383d32b0417 -6.61173459    1.705343
#> 16: aa2ad26b-707e-45f4-a031-d82d2384f725  8.34573561    3.714461
#> 17: 5e660c11-caba-4175-8eff-085b097bc889 -8.96971468   -3.263809
#> 18: 86cc9d4f-0a69-47f7-87cb-deb0256e0259  1.89838435    2.698046
#> 19: de909725-0f43-4037-9647-c050d419feb9 -2.71425870    1.813992
#> 20: 4b6a0527-c9be-4e84-8229-d387ec820eab  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
