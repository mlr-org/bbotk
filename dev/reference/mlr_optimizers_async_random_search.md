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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-08-20 09:01:04
#>  2: finished -8.33732121  3.178398 -135.032815 2026-08-20 09:01:04
#>  3: finished -7.78396197  2.105379 -111.790803 2026-08-20 09:01:04
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-08-20 09:01:04
#>  5: finished  0.98995613  2.678818  -23.269168 2026-08-20 09:01:04
#>  6: finished -3.50214144  1.111543  -37.178342 2026-08-20 09:01:04
#>  7: finished  2.77985531  4.933030  -53.541141 2026-08-20 09:01:04
#>  8: finished  9.86020590  0.052479  -61.100465 2026-08-20 09:01:04
#>  9: finished -4.77089430  4.984108  -99.590989 2026-08-20 09:01:04
#> 10: finished  8.62827623  3.264048  -73.172348 2026-08-20 09:01:04
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-08-20 09:01:04
#> 12: finished -0.97588025  1.013553  -14.964468 2026-08-20 09:01:04
#> 13: finished -9.42569878  0.916582 -135.886207 2026-08-20 09:01:04
#> 14: finished  0.07085662  3.202987  -32.198639 2026-08-20 09:01:04
#> 15: finished -6.61173459  1.705343  -86.302224 2026-08-20 09:01:04
#> 16: finished  8.34573561  3.714461  -75.352353 2026-08-20 09:01:04
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-08-20 09:01:04
#> 18: finished  1.89838435  2.698046  -22.478057 2026-08-20 09:01:04
#> 19: finished -2.71425870  1.813992  -35.398750 2026-08-20 09:01:04
#> 20: finished  1.30114551 -4.177370    8.125403 2026-08-20 09:01:04
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  2: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  3: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  4: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  5: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  6: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  7: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  8: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>  9: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 10: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 11: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 12: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 13: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 14: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 15: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 16: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 17: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 18: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 19: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#> 20: narrow_xinjiangovenator_2f651c66 2026-08-20 09:01:04
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 125c69fa-b962-4fbc-b549-2e0bf97fe762 -2.11085866    3.149893
#>  2: 94331a69-fe2f-49c5-889d-a9305611b819 -8.33732121    3.178398
#>  3: 9ca49641-0bae-4772-b265-70c2fcd38e54 -7.78396197    2.105379
#>  4: 8f2a254d-e597-42bd-a52e-9f7e40d6fb6b  5.92632791   -4.231512
#>  5: 01106cba-56ea-4645-a228-339d3f73f643  0.98995613    2.678818
#>  6: ecd81943-a4c4-4e7b-9cf0-077d9f09c59a -3.50214144    1.111543
#>  7: d67c03d0-a1f7-4e31-834a-73222a0c02d5  2.77985531    4.933030
#>  8: 64f03cdf-0e40-47ac-8073-7f30e5e4fbfe  9.86020590    0.052479
#>  9: b074ae7d-3ff7-4903-9fd8-4d6ef865618c -4.77089430    4.984108
#> 10: 55497413-7ab1-4a08-ad79-fd6435480fc1  8.62827623    3.264048
#> 11: 6b94b759-846d-452f-be27-925aa7433331  5.20608164   -2.035465
#> 12: a3379422-9cf5-4ead-a8a2-9126d9b02cee -0.97588025    1.013553
#> 13: f97acf4b-557a-4cf5-9a76-7f545cee4e7a -9.42569878    0.916582
#> 14: f901b0b6-fbb5-47ee-a916-224e71dbe032  0.07085662    3.202987
#> 15: c3be525b-4662-4747-bb57-23c146c96646 -6.61173459    1.705343
#> 16: 94f1d3b4-19d4-4ed5-865d-04383f5fff69  8.34573561    3.714461
#> 17: 1ee625d6-f1a4-4b07-99f0-8ff042f3cc46 -8.96971468   -3.263809
#> 18: a77321a5-ecf5-4f8f-8a24-ba5b5c70d270  1.89838435    2.698046
#> 19: 02515691-9a72-4a34-be09-58703ea9bb61 -2.71425870    1.813992
#> 20: 10ee56e0-55ea-48cf-a441-857442e42d52  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
