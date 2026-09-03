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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-03 11:40:16
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-03 11:40:16
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-03 11:40:16
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-03 11:40:16
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-03 11:40:16
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-03 11:40:16
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-03 11:40:16
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-03 11:40:16
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-03 11:40:16
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-03 11:40:16
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-03 11:40:16
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-03 11:40:16
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-03 11:40:16
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-03 11:40:16
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-03 11:40:16
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-03 11:40:16
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-03 11:40:16
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-03 11:40:16
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-03 11:40:16
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-03 11:40:16
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  2: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  3: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  4: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  5: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  6: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  7: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  8: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>  9: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 10: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 11: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 12: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 13: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 14: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 15: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 16: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 17: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 18: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 19: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#> 20: narrow_xinjiangovenator_0645a1f4 2026-09-03 11:40:16
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 44e572dd-e640-40dd-b198-d4825aa9299b -2.11085866    3.149893
#>  2: f83f116d-0ff2-411d-bbb5-6e23a19472c7 -8.33732121    3.178398
#>  3: c2cc02a0-96cd-4383-b9d5-dde44cdd44e1 -7.78396197    2.105379
#>  4: ed92929f-9910-423f-b84c-ee397b8df898  5.92632791   -4.231512
#>  5: 1315401e-80d0-453c-8301-107e1fc1cf79  0.98995613    2.678818
#>  6: 377013a4-c265-416b-bc73-885eda9df7e4 -3.50214144    1.111543
#>  7: 13138ad2-7bfc-4332-8e38-9c15993156bb  2.77985531    4.933030
#>  8: 8403026a-2766-4f82-b57d-ef28e9c2b73d  9.86020590    0.052479
#>  9: e04be059-07af-4d07-a026-e339ddbce60c -4.77089430    4.984108
#> 10: cd68aeb2-a230-4f39-8c15-21c943662587  8.62827623    3.264048
#> 11: 11b78a0d-b069-46f7-a1cd-4aabd61972ba  5.20608164   -2.035465
#> 12: 381b86f3-a563-41d8-97fd-ab74b242bb39 -0.97588025    1.013553
#> 13: 93a068b4-b2c1-40b5-bbad-846ad15e7dd1 -9.42569878    0.916582
#> 14: eb4045be-9735-4f9b-a718-6d3511504a47  0.07085662    3.202987
#> 15: 1c6b6d37-2032-4011-8e4b-20967ce480f2 -6.61173459    1.705343
#> 16: f0f954d7-780c-45ee-b6d2-7255d31c1f1b  8.34573561    3.714461
#> 17: 23059a06-fc07-45b0-a322-00032f53da71 -8.96971468   -3.263809
#> 18: e20ca27a-b7e1-4749-88bd-5195635bf6df  1.89838435    2.698046
#> 19: 91c48922-4e63-4acf-b064-cf8301e6d76a -2.71425870    1.813992
#> 20: 58a80cfc-a658-4543-9ecf-0d8ddb1208be  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
