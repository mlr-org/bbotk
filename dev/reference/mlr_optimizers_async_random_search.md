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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-09 13:56:57
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-09 13:56:57
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-09 13:56:57
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-09 13:56:57
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-09 13:56:57
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-09 13:56:57
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-09 13:56:57
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-09 13:56:58
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-09 13:56:58
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-09 13:56:58
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-09 13:56:58
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-09 13:56:58
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-09 13:56:58
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-09 13:56:58
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-09 13:56:58
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-09 13:56:58
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-09 13:56:58
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-09 13:56:58
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-09 13:56:58
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-09 13:56:58
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  2: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  3: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  4: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  5: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  6: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  7: narrow_xinjiangovenator 2026-06-09 13:56:57
#>  8: narrow_xinjiangovenator 2026-06-09 13:56:58
#>  9: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 10: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 11: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 12: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 13: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 14: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 15: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 16: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 17: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 18: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 19: narrow_xinjiangovenator 2026-06-09 13:56:58
#> 20: narrow_xinjiangovenator 2026-06-09 13:56:58
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: f47f73bf-d04f-40fe-86f0-9423d1c36324 -2.11085866    3.149893
#>  2: 039ea162-25b1-4ac3-a86e-c152b380e510 -8.33732121    3.178398
#>  3: 4937d18d-b27c-4cb5-a6dc-b1cbd465b46c -7.78396197    2.105379
#>  4: 11d4dc41-cab4-485d-9571-c4d2d0efb152  5.92632791   -4.231512
#>  5: 05722701-994b-4b45-b369-6f02159141ac  0.98995613    2.678818
#>  6: af708dc9-279a-424f-aa64-3b8c45792dc1 -3.50214144    1.111543
#>  7: 8563f2bc-2d0f-42db-8838-ff34cfd407f1  2.77985531    4.933030
#>  8: 38415857-3cb4-471c-8866-bb4c96382b4b  9.86020590    0.052479
#>  9: b7302876-25cb-4f7f-af0b-eea07f5aec43 -4.77089430    4.984108
#> 10: 7c12df72-3b7e-4889-8a54-711dfc125476  8.62827623    3.264048
#> 11: ff7aefe2-e7de-4316-90c3-2bc302579f71  5.20608164   -2.035465
#> 12: b61e3388-3b4a-44db-9e06-dcea788aef3d -0.97588025    1.013553
#> 13: d017b3a5-7d65-4514-990d-91511e07b4b9 -9.42569878    0.916582
#> 14: 6d4d88e1-f0e9-4ee7-94f2-bb5d6b0703ec  0.07085662    3.202987
#> 15: 8e3aead6-cb04-4b11-af9f-8a9d7ab659eb -6.61173459    1.705343
#> 16: efc1f9a6-7d37-4aca-9be1-af8833cf6067  8.34573561    3.714461
#> 17: e5621ce5-4c52-4d9d-bcc1-0050d161865d -8.96971468   -3.263809
#> 18: 3c613377-4f35-41b5-b995-0bea96952a13  1.89838435    2.698046
#> 19: 2fcd1bd4-f47c-4597-a1b7-3c09670cf89b -2.71425870    1.813992
#> 20: c1309c14-a3b4-4a10-aa6b-5ab14a145432  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
