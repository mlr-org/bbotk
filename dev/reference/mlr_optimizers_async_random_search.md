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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:50:20
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:50:20
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:50:20
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:50:20
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:50:20
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:50:20
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:50:20
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:50:20
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:50:20
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:50:20
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:50:20
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:50:20
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:50:20
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:50:21
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:50:21
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:50:21
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:50:21
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:50:21
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:50:21
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:50:21
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  2: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  3: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  4: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  5: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  6: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  7: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  8: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#>  9: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#> 10: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#> 11: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#> 12: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:20
#> 13: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 14: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 15: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 16: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 17: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 18: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 19: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#> 20: narrow_xinjiangovenator_dcbccb9c 2026-09-17 09:50:21
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 0f3f242c-ff24-4672-ba5a-66b9a46b75ed -2.11085866    3.149893
#>  2: dd5eeab0-5177-41e8-91b5-52043bbd30ab -8.33732121    3.178398
#>  3: 2c3f2a8d-4c3a-47d8-aa8f-c6fa7d80e36a -7.78396197    2.105379
#>  4: 9a2d1fba-a827-4320-a95f-2f54b3abb18b  5.92632791   -4.231512
#>  5: 18e0c956-a0cc-405a-a51b-2a6c01c15640  0.98995613    2.678818
#>  6: 36ab1016-ff1f-4d0e-8b4e-90d9a5453ee0 -3.50214144    1.111543
#>  7: 2d1ecdda-8b87-455d-bd8e-91ed4e5b49bd  2.77985531    4.933030
#>  8: f6ca1b8f-3699-41bf-9b63-2f6c0e76175a  9.86020590    0.052479
#>  9: 195c06e2-cad7-4e6d-879d-1e79d01ef085 -4.77089430    4.984108
#> 10: 63fcfabc-ee18-4ad0-b750-00bba7add54f  8.62827623    3.264048
#> 11: f729f9c4-6628-4c42-adf7-01d89658e04c  5.20608164   -2.035465
#> 12: 0018bf4f-1e57-4da3-bf64-d584fe7087d2 -0.97588025    1.013553
#> 13: f9b0e4bc-5975-4ef9-82a3-8d1eb647826b -9.42569878    0.916582
#> 14: 5448a705-f9d0-4848-8a96-730c52de5aa3  0.07085662    3.202987
#> 15: 76d80408-b52c-4ceb-978f-5edfe128461f -6.61173459    1.705343
#> 16: e12a1b4f-9ed5-49ad-9660-2955b56a0d08  8.34573561    3.714461
#> 17: 9bf994fb-04da-4159-b6a8-324c57947566 -8.96971468   -3.263809
#> 18: ee75c865-1f59-40c9-9ee3-5612e015a2ce  1.89838435    2.698046
#> 19: 6400055c-fe81-4a97-ad99-508f834145f2 -2.71425870    1.813992
#> 20: 105ea671-ff3b-45ee-9195-5a2bc05ff24b  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
