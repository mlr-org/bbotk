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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-24 06:31:50
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-24 06:31:50
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-24 06:31:50
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-24 06:31:50
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-24 06:31:50
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-24 06:31:50
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-24 06:31:50
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-24 06:31:50
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-24 06:31:50
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-24 06:31:50
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-24 06:31:50
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-24 06:31:50
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-24 06:31:50
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-24 06:31:50
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-24 06:31:50
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-24 06:31:50
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-24 06:31:51
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-24 06:31:51
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-24 06:31:51
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-24 06:31:51
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  2: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  3: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  4: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  5: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  6: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  7: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  8: narrow_xinjiangovenator 2026-06-24 06:31:50
#>  9: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 10: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 11: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 12: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 13: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 14: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 15: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 16: narrow_xinjiangovenator 2026-06-24 06:31:50
#> 17: narrow_xinjiangovenator 2026-06-24 06:31:51
#> 18: narrow_xinjiangovenator 2026-06-24 06:31:51
#> 19: narrow_xinjiangovenator 2026-06-24 06:31:51
#> 20: narrow_xinjiangovenator 2026-06-24 06:31:51
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: ea627dc4-05b4-4735-be93-a89322e96330 -2.11085866    3.149893
#>  2: b9c7eb8d-ca6f-4fc6-b118-1c4fddcde95c -8.33732121    3.178398
#>  3: e3102c3b-79c5-4049-b5e9-076af9ca05d6 -7.78396197    2.105379
#>  4: e40d359f-b291-486a-b98c-325749a3a22c  5.92632791   -4.231512
#>  5: 189fce30-b73b-4f55-8178-8e248dee926c  0.98995613    2.678818
#>  6: cc662994-1ada-41fd-8552-ec3aaba210db -3.50214144    1.111543
#>  7: 238862a7-1553-47aa-93fd-668c1c16823d  2.77985531    4.933030
#>  8: 85565324-bd17-4e4e-9e2b-36efc91e374c  9.86020590    0.052479
#>  9: 4fc1517f-f3ff-4135-999d-9f0945e327bc -4.77089430    4.984108
#> 10: 0f6debaa-b6cf-43fe-af31-3eb8494b1798  8.62827623    3.264048
#> 11: 32d6695b-7e33-4c30-b19f-0b9fafbea820  5.20608164   -2.035465
#> 12: 064c5482-7823-44bd-b477-5f62e94fbd5d -0.97588025    1.013553
#> 13: df839b07-59cb-4a3c-ab74-029e700af2f5 -9.42569878    0.916582
#> 14: 0278de75-218b-4b03-872c-14c65ca15af0  0.07085662    3.202987
#> 15: e6866f6d-e49f-4de5-a99d-34e1b705ce06 -6.61173459    1.705343
#> 16: f2168a9c-c5d9-49cb-873d-a1a482a8d344  8.34573561    3.714461
#> 17: 23414c00-5830-48ca-a2ca-61ace8500fee -8.96971468   -3.263809
#> 18: ffed6608-3eb6-4952-ac2f-4284fbe9e3c1  1.89838435    2.698046
#> 19: 7f95d538-a472-42a1-8b06-a11ada4d2088 -2.71425870    1.813992
#> 20: b87d3a52-b3da-4d68-bfba-e48faf5d9d66  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
