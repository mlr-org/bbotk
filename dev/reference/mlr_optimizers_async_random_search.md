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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-10 12:39:45
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-10 12:39:45
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-10 12:39:45
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-10 12:39:45
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-10 12:39:45
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-10 12:39:45
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-10 12:39:45
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-10 12:39:45
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-10 12:39:45
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-10 12:39:45
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-10 12:39:45
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-10 12:39:45
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-10 12:39:45
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-10 12:39:45
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-10 12:39:45
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-10 12:39:45
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-10 12:39:45
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-10 12:39:46
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-10 12:39:46
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-10 12:39:46
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  2: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  3: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  4: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  5: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  6: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  7: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  8: narrow_xinjiangovenator 2026-06-10 12:39:45
#>  9: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 10: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 11: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 12: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 13: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 14: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 15: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 16: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 17: narrow_xinjiangovenator 2026-06-10 12:39:45
#> 18: narrow_xinjiangovenator 2026-06-10 12:39:46
#> 19: narrow_xinjiangovenator 2026-06-10 12:39:46
#> 20: narrow_xinjiangovenator 2026-06-10 12:39:46
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 2c18cadb-b0cf-47f4-b205-5ba7b4ab4b9e -2.11085866    3.149893
#>  2: 9c42de43-90a9-43d0-a49e-f8d059d52eac -8.33732121    3.178398
#>  3: bd6cbb28-e404-43bb-b298-680c9029542b -7.78396197    2.105379
#>  4: fec6d8fd-c647-4d2f-92d2-aa25d30d10e9  5.92632791   -4.231512
#>  5: 48632b21-982c-440f-b664-8316764aa7ab  0.98995613    2.678818
#>  6: de811045-aa23-4a73-b62f-6dca54337db7 -3.50214144    1.111543
#>  7: 525ad98d-d2fe-4771-a3dc-4bfd2fcd80d2  2.77985531    4.933030
#>  8: 82fc8e4d-a74f-4bb5-aade-4803795a1301  9.86020590    0.052479
#>  9: 51238006-428d-487a-aa76-af192aa0b8e5 -4.77089430    4.984108
#> 10: 431c6b09-9217-4a49-af51-9a683da9e644  8.62827623    3.264048
#> 11: 3b870eaa-2b34-4f62-aa4c-95afdbfc2dc2  5.20608164   -2.035465
#> 12: 7c434cff-d32b-4d96-9c95-ba85645775f1 -0.97588025    1.013553
#> 13: ae4536bf-9e12-4367-808d-1f589534dfe0 -9.42569878    0.916582
#> 14: 01109f5f-9b99-4b14-8867-dde79b1ef9bc  0.07085662    3.202987
#> 15: 2a0a7cda-364b-47cd-8aa4-6ff5191564dd -6.61173459    1.705343
#> 16: fac10ca2-fc59-4624-bcaa-de609ba7c86d  8.34573561    3.714461
#> 17: c5392144-2b7b-4b2c-ae5b-5c55ea97f953 -8.96971468   -3.263809
#> 18: f6be5f57-fb8f-4652-9f2d-bf703b2fea4f  1.89838435    2.698046
#> 19: a8c40c6e-a042-40cb-89dc-46a8684850d5 -2.71425870    1.813992
#> 20: 93e2fdfe-e95e-46b9-8319-e24c879b4fe7  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
