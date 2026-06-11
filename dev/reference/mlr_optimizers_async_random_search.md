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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-11 08:59:49
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-11 08:59:49
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-11 08:59:49
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-11 08:59:49
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-11 08:59:49
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-11 08:59:49
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-11 08:59:49
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-11 08:59:49
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-11 08:59:49
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-11 08:59:49
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-11 08:59:49
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-11 08:59:49
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-11 08:59:49
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-11 08:59:49
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-11 08:59:49
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-11 08:59:49
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-11 08:59:49
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-11 08:59:49
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-11 08:59:49
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-11 08:59:49
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  2: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  3: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  4: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  5: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  6: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  7: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  8: narrow_xinjiangovenator 2026-06-11 08:59:49
#>  9: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 10: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 11: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 12: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 13: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 14: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 15: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 16: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 17: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 18: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 19: narrow_xinjiangovenator 2026-06-11 08:59:49
#> 20: narrow_xinjiangovenator 2026-06-11 08:59:49
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: a9609770-a1d3-45c0-9ae9-3322c42a3cf9 -2.11085866    3.149893
#>  2: 2bb760b4-a39b-43a8-9bed-1428b61cb495 -8.33732121    3.178398
#>  3: dc7b2aaf-4b29-4544-826f-e7f6e74324c4 -7.78396197    2.105379
#>  4: 7239937e-e22e-48d6-8eb0-f38bbd0ece36  5.92632791   -4.231512
#>  5: 66b5e071-e0b8-49d0-b7e5-138b47083f92  0.98995613    2.678818
#>  6: 3ef3145d-581e-4f9f-a527-6c0accb3dd1a -3.50214144    1.111543
#>  7: 9298f202-5a98-4b87-966f-f0a095b94247  2.77985531    4.933030
#>  8: 5876bdd0-1bae-489a-a37c-e2a6deeb9ad3  9.86020590    0.052479
#>  9: 4ab4dc48-3fd4-4cb2-8cb2-d7a4a8eb2505 -4.77089430    4.984108
#> 10: 0beaca9d-2af3-476e-b329-b6c163402e8f  8.62827623    3.264048
#> 11: 9d3a363e-175b-4992-833d-76063433e040  5.20608164   -2.035465
#> 12: 178c90bf-902f-4fef-a731-881ae1e304fb -0.97588025    1.013553
#> 13: fafa6b9e-0566-427b-b4d7-09357bf475d2 -9.42569878    0.916582
#> 14: 75ab775c-7913-4630-8898-3199216dfaa5  0.07085662    3.202987
#> 15: 6ed13233-c56b-4ac2-8434-4c0a9074e4fe -6.61173459    1.705343
#> 16: 267c2176-cd77-4800-badb-1c4639ac765f  8.34573561    3.714461
#> 17: 0df3cdd5-c24a-4c80-9e36-425a7b50fd63 -8.96971468   -3.263809
#> 18: cf440d27-944f-46ef-a5f3-3c9f5403204c  1.89838435    2.698046
#> 19: b0b70b9e-0990-4ec5-88a2-8d7455b42756 -2.71425870    1.813992
#> 20: 4373ffce-913e-4e89-a19e-309a3c6986ca  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
