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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-27 09:00:48
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-27 09:00:48
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-27 09:00:48
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-27 09:00:48
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-27 09:00:48
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-27 09:00:48
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-27 09:00:48
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-27 09:00:48
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-27 09:00:48
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-27 09:00:48
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-27 09:00:48
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-27 09:00:48
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-27 09:00:48
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-27 09:00:48
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-27 09:00:48
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-27 09:00:48
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-27 09:00:48
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-27 09:00:48
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-27 09:00:48
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-27 09:00:48
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  2: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  3: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  4: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  5: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  6: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  7: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  8: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>  9: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 10: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 11: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 12: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 13: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 14: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 15: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 16: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 17: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 18: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 19: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#> 20: narrow_xinjiangovenator_36c8da86 2026-07-27 09:00:48
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 6be0e579-50f1-4845-8c87-980b1f7e71c6 -2.11085866    3.149893
#>  2: f5f0ef63-e100-4b49-bb43-7ad2cb5a6ac2 -8.33732121    3.178398
#>  3: 7b0816f1-0259-41ef-90dc-809f844c39ef -7.78396197    2.105379
#>  4: 252d7152-9a5b-488d-8b1c-69ea6ad1335e  5.92632791   -4.231512
#>  5: 4e3279d5-c3d9-450d-ac7b-003248ef7e53  0.98995613    2.678818
#>  6: d6303088-f830-46a1-8afe-c9245fc48f5e -3.50214144    1.111543
#>  7: be47e322-b417-420e-9ca0-e95985f0b54d  2.77985531    4.933030
#>  8: 13c840d0-1e74-4f4b-9ce3-0946cd272927  9.86020590    0.052479
#>  9: 120f8437-a2d2-46ef-808a-530c7fbaa401 -4.77089430    4.984108
#> 10: e1ae3e55-a8e6-46bf-b829-af136c22cd4b  8.62827623    3.264048
#> 11: b246a121-8742-4578-8338-9db53f1c13ac  5.20608164   -2.035465
#> 12: 6bde1b29-1aff-4e12-8557-edbee095a16b -0.97588025    1.013553
#> 13: a2e7a94c-681b-48ce-9112-0910ee35b996 -9.42569878    0.916582
#> 14: 54d21171-aadc-4e5d-a0f8-b3ab4f76c4cd  0.07085662    3.202987
#> 15: 3d15b4f2-c04c-42fe-b806-83218b3a6edf -6.61173459    1.705343
#> 16: a075b5d9-fe12-4f3f-804b-788323a1675a  8.34573561    3.714461
#> 17: b262f2cc-56d8-445b-a850-e83ac72b181f -8.96971468   -3.263809
#> 18: 6c95b996-1854-4667-9d0c-59f25a7bf1c5  1.89838435    2.698046
#> 19: e5ac5767-dc38-44dd-9080-31a09a59c2a7 -2.71425870    1.813992
#> 20: 2d901f8c-33fb-483f-879a-57600994b8ee  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
