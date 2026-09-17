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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:27:17
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:27:17
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:27:17
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:27:17
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:27:17
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:27:17
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:27:17
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:27:17
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:27:17
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:27:17
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:27:17
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:27:17
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:27:17
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:27:17
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:27:17
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:27:17
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:27:17
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:27:17
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:27:17
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:27:17
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  2: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  3: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  4: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  5: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  6: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  7: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  8: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>  9: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 10: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 11: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 12: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 13: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 14: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 15: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 16: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 17: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 18: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 19: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#> 20: narrow_xinjiangovenator_630a8343 2026-09-17 09:27:17
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 035c68a7-b7e9-49b7-b1b7-4dbc79221e50 -2.11085866    3.149893
#>  2: 55df22a8-3e51-4df8-9108-4d14fd0e3581 -8.33732121    3.178398
#>  3: 34f920c6-e15f-4420-8159-167ab648642e -7.78396197    2.105379
#>  4: e5f4b33d-1e82-45f7-9b0b-9db4e0c0b1fc  5.92632791   -4.231512
#>  5: 4e62ef15-473e-444f-9174-c592197b8410  0.98995613    2.678818
#>  6: 6fe048de-009f-4bbd-aa1d-269eafdde2ad -3.50214144    1.111543
#>  7: 87e0b521-5903-4d9f-b64a-bce5ecbe704c  2.77985531    4.933030
#>  8: fe0f0e5c-6bcd-4910-bf3b-3c78af2a5207  9.86020590    0.052479
#>  9: f0ff63a7-f1be-4fc4-a4b4-d08542880bb8 -4.77089430    4.984108
#> 10: 0180b940-dfb6-409f-aa72-0da5ad5e957d  8.62827623    3.264048
#> 11: 96107bd7-22b4-4beb-bb81-67f70cc0b500  5.20608164   -2.035465
#> 12: 523d7c0a-f1c7-46e7-a5e3-bfd0445fe22e -0.97588025    1.013553
#> 13: 53876a68-9f1b-41c8-9eab-a794b3d17f24 -9.42569878    0.916582
#> 14: 01465a8b-9c9c-4ec7-9d86-e6a7bd8fe3c1  0.07085662    3.202987
#> 15: a724338a-c1ae-4bfb-92af-e98f527f8878 -6.61173459    1.705343
#> 16: b7510351-87ba-425e-a56a-ac467ca35435  8.34573561    3.714461
#> 17: 7eb83282-582f-40f8-8136-e7488bccfa68 -8.96971468   -3.263809
#> 18: dfe44a29-800f-42b0-9cf7-ffb9671c4a8e  1.89838435    2.698046
#> 19: ca276384-4ebb-4ddd-b19e-8ce4db9c1217 -2.71425870    1.813992
#> 20: ff09f4e9-b769-4e98-819b-178d2da32240  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
