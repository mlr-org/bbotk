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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:57:40
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:57:40
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:57:40
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:57:40
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:57:40
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:57:40
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:57:40
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:57:40
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:57:40
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:57:41
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:57:41
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:57:41
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:57:41
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:57:41
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:57:41
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:57:41
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:57:41
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:57:41
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:57:41
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:57:41
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  2: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  3: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  4: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  5: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  6: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  7: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  8: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#>  9: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:40
#> 10: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 11: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 12: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 13: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 14: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 15: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 16: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 17: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 18: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 19: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#> 20: narrow_xinjiangovenator_74c8e5a7 2026-09-17 09:57:41
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 33d9001e-96e7-40ed-a60f-078d658f22c9 -2.11085866    3.149893
#>  2: 1cd459c8-6adc-4dae-a2ea-5cafdfe12c15 -8.33732121    3.178398
#>  3: 88291a46-6b23-434e-b7ab-10ddd790cdcb -7.78396197    2.105379
#>  4: 25c94172-6541-48c5-bc05-92b5d2a40885  5.92632791   -4.231512
#>  5: 5c1640fa-79fc-44ce-986d-a266a3a4a8df  0.98995613    2.678818
#>  6: 8b23a765-eff8-4e99-b4fa-55f1fb658b5a -3.50214144    1.111543
#>  7: 578d8bf7-5fc0-46c6-abf8-07cecab46ad5  2.77985531    4.933030
#>  8: 16c7e57f-51a8-475a-a8a0-3d37b9d5be9d  9.86020590    0.052479
#>  9: ec601ee4-98e1-4862-a04b-8ac55a93cb3a -4.77089430    4.984108
#> 10: c3ff78fe-b3dd-4c13-a01c-fe60d533c84b  8.62827623    3.264048
#> 11: 41887ab8-12dc-44e1-8ec0-1e95351bea29  5.20608164   -2.035465
#> 12: 04ab580e-9e99-4a54-80a6-090a966835fc -0.97588025    1.013553
#> 13: 44a33c9f-28ca-48fc-b626-629fd302fcea -9.42569878    0.916582
#> 14: a01bd02d-7fc7-451a-a7d6-dafbebe1c6fb  0.07085662    3.202987
#> 15: 4628449b-5e23-4f05-93e1-2d06f42f1887 -6.61173459    1.705343
#> 16: 4a59df77-fe42-433a-9d0d-72d5be32b529  8.34573561    3.714461
#> 17: 524254ae-ef55-4dba-bc52-28bbe503d156 -8.96971468   -3.263809
#> 18: 266d9eec-1774-4d15-be91-c24437a543db  1.89838435    2.698046
#> 19: 331aa21c-277c-4cf9-b10c-cae340315cc5 -2.71425870    1.813992
#> 20: 52dbbdae-52e0-4330-85bb-22f1268b8132  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
