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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:43:42
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:43:42
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:43:42
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:43:42
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:43:43
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:43:43
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:43:43
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:43:43
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:43:43
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:43:43
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:43:43
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:43:43
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:43:43
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:43:43
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:43:43
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:43:43
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:43:43
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:43:43
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:43:43
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:43:43
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:42
#>  2: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:42
#>  3: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:42
#>  4: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:42
#>  5: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#>  6: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#>  7: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#>  8: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#>  9: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 10: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 11: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 12: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 13: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 14: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 15: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 16: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 17: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 18: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 19: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#> 20: narrow_xinjiangovenator_60c1c42b 2026-09-17 09:43:43
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 371a8fce-9c76-4561-956f-b27404319ad5 -2.11085866    3.149893
#>  2: 423dc5c9-df8d-4b1f-bccc-8e73a7c3d54b -8.33732121    3.178398
#>  3: a54f4366-a317-4995-8446-bec751230b32 -7.78396197    2.105379
#>  4: bc75e8c6-163b-4115-a9bc-a67fa9310092  5.92632791   -4.231512
#>  5: 42293f9a-2572-4acd-8b5a-035023f9e40f  0.98995613    2.678818
#>  6: b0a1e50e-cb62-4b79-8cc5-ffcb2984eadd -3.50214144    1.111543
#>  7: 44640b26-81fd-4dd7-be20-7cebec538bd8  2.77985531    4.933030
#>  8: b4d20ee3-4759-4d56-b5cf-6694ba303739  9.86020590    0.052479
#>  9: 94b19581-444e-43b3-83b4-4552b19331bb -4.77089430    4.984108
#> 10: 5237b6dc-90f8-49ee-b571-b2608eb2e227  8.62827623    3.264048
#> 11: 4775cc6b-0836-40ab-8991-751cdbcfc38a  5.20608164   -2.035465
#> 12: f94a84e3-0cd7-4342-aa8e-1d777713a2b2 -0.97588025    1.013553
#> 13: 51de6711-ce01-4e7e-a329-43d4e73f3ffc -9.42569878    0.916582
#> 14: 8a124fed-e4bd-4c3f-85fb-a3f4c91a4308  0.07085662    3.202987
#> 15: cc9ddf60-5f22-4d53-b1ad-d30a10b9c58d -6.61173459    1.705343
#> 16: 57e1d481-773d-4d56-8a68-35944777e9a0  8.34573561    3.714461
#> 17: 3cc106fc-38e4-4d49-991d-0ad06b6cdab1 -8.96971468   -3.263809
#> 18: 84a98609-a4d8-4cf6-8528-8c46b5badf8b  1.89838435    2.698046
#> 19: 512cd35c-7935-4487-8a81-7b2b88048ffd -2.71425870    1.813992
#> 20: 6a84589b-5014-48c4-ad91-d39887ab604e  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
