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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-06-09 17:41:33
#>  2: finished -8.33732121  3.178398 -135.032815 2026-06-09 17:41:33
#>  3: finished -7.78396197  2.105379 -111.790803 2026-06-09 17:41:33
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-06-09 17:41:33
#>  5: finished  0.98995613  2.678818  -23.269168 2026-06-09 17:41:34
#>  6: finished -3.50214144  1.111543  -37.178342 2026-06-09 17:41:34
#>  7: finished  2.77985531  4.933030  -53.541141 2026-06-09 17:41:34
#>  8: finished  9.86020590  0.052479  -61.100465 2026-06-09 17:41:34
#>  9: finished -4.77089430  4.984108  -99.590989 2026-06-09 17:41:34
#> 10: finished  8.62827623  3.264048  -73.172348 2026-06-09 17:41:34
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-06-09 17:41:34
#> 12: finished -0.97588025  1.013553  -14.964468 2026-06-09 17:41:34
#> 13: finished -9.42569878  0.916582 -135.886207 2026-06-09 17:41:34
#> 14: finished  0.07085662  3.202987  -32.198639 2026-06-09 17:41:34
#> 15: finished -6.61173459  1.705343  -86.302224 2026-06-09 17:41:34
#> 16: finished  8.34573561  3.714461  -75.352353 2026-06-09 17:41:34
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-06-09 17:41:34
#> 18: finished  1.89838435  2.698046  -22.478057 2026-06-09 17:41:34
#> 19: finished -2.71425870  1.813992  -35.398750 2026-06-09 17:41:34
#> 20: finished  1.30114551 -4.177370    8.125403 2026-06-09 17:41:34
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-06-09 17:41:33
#>  2: narrow_xinjiangovenator 2026-06-09 17:41:33
#>  3: narrow_xinjiangovenator 2026-06-09 17:41:33
#>  4: narrow_xinjiangovenator 2026-06-09 17:41:33
#>  5: narrow_xinjiangovenator 2026-06-09 17:41:34
#>  6: narrow_xinjiangovenator 2026-06-09 17:41:34
#>  7: narrow_xinjiangovenator 2026-06-09 17:41:34
#>  8: narrow_xinjiangovenator 2026-06-09 17:41:34
#>  9: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 10: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 11: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 12: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 13: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 14: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 15: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 16: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 17: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 18: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 19: narrow_xinjiangovenator 2026-06-09 17:41:34
#> 20: narrow_xinjiangovenator 2026-06-09 17:41:34
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d0695c05-f4f2-4203-9d3a-80f0a76638f1 -2.11085866    3.149893
#>  2: 699d8150-6758-4a73-821d-701b7adcda99 -8.33732121    3.178398
#>  3: 0caca243-8304-46a2-91e7-50537552980d -7.78396197    2.105379
#>  4: fb000985-b0f4-404f-b5ef-caa679c38fbb  5.92632791   -4.231512
#>  5: 5dbaacf3-efae-493f-a738-6014886ac3c4  0.98995613    2.678818
#>  6: ec15b2a2-00cd-40da-9cc3-2e6bf7243cbb -3.50214144    1.111543
#>  7: b93358e9-8e07-46d2-84db-17460d0712ba  2.77985531    4.933030
#>  8: 28a73cf8-dc20-44be-97ac-592b9596c6d4  9.86020590    0.052479
#>  9: cccc8be6-91e5-4022-a49d-6144d8e984f0 -4.77089430    4.984108
#> 10: b61f1f5e-35fc-4383-9d3a-c62d5d617ec6  8.62827623    3.264048
#> 11: eb92a452-2070-478b-8fa7-7e4cd7126748  5.20608164   -2.035465
#> 12: b1e7494b-4565-4a25-873c-75c78eff108e -0.97588025    1.013553
#> 13: b7fe4c03-31b1-4125-b013-bc05f3a6db1d -9.42569878    0.916582
#> 14: 039aad0c-61e2-4995-ade0-43a1545ffc31  0.07085662    3.202987
#> 15: a374ed12-29a1-4dfe-bc49-21e008ed5999 -6.61173459    1.705343
#> 16: 8fcc3cc7-68d1-426d-a82f-cb2ed18e87a1  8.34573561    3.714461
#> 17: 7fc57e8d-70f7-456d-89d9-26d8b3d1d9ce -8.96971468   -3.263809
#> 18: fd30126f-8b45-4163-8c2a-c3362d404aa8  1.89838435    2.698046
#> 19: 51741823-f941-48cc-8960-01e39e297be0 -2.71425870    1.813992
#> 20: f60d7f5f-a49a-42bd-9429-d93c378b797f  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
