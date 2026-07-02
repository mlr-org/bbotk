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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-02 09:45:07
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-02 09:45:07
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-02 09:45:07
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-02 09:45:07
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-02 09:45:07
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-02 09:45:07
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-02 09:45:07
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-02 09:45:07
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-02 09:45:07
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-02 09:45:07
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-02 09:45:07
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-02 09:45:07
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-02 09:45:07
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-02 09:45:07
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-02 09:45:07
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-02 09:45:07
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-02 09:45:07
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-02 09:45:07
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-02 09:45:07
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-02 09:45:07
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  2: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  3: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  4: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  5: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  6: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  7: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  8: narrow_xinjiangovenator 2026-07-02 09:45:07
#>  9: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 10: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 11: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 12: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 13: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 14: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 15: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 16: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 17: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 18: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 19: narrow_xinjiangovenator 2026-07-02 09:45:07
#> 20: narrow_xinjiangovenator 2026-07-02 09:45:07
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 2e0a4978-db83-4ec6-881b-ab89fd59e05c -2.11085866    3.149893
#>  2: 76ccdd4c-bb12-4778-b8d9-5bae89068036 -8.33732121    3.178398
#>  3: 8874da41-3f71-44b2-bf36-14dc4a476485 -7.78396197    2.105379
#>  4: 37cda5db-664f-46d9-873c-bb56d24d879b  5.92632791   -4.231512
#>  5: b66fb206-5de7-487c-a26a-d7ea9d3cc9df  0.98995613    2.678818
#>  6: 85ecf00e-a08d-4261-9bf7-b03be67764c0 -3.50214144    1.111543
#>  7: 56163d0a-bc8d-433b-9dba-9e9d898818bd  2.77985531    4.933030
#>  8: c5bfad86-edbd-4627-a140-b174cf004804  9.86020590    0.052479
#>  9: dffa64b7-610b-49b8-a4e0-ee9665ac0d03 -4.77089430    4.984108
#> 10: 6c7d0d6f-c277-4952-92b7-a8089999bd24  8.62827623    3.264048
#> 11: 4aa168fc-1ecd-4158-9a23-eb956493ccb4  5.20608164   -2.035465
#> 12: f6f41d7a-3fab-4401-8177-bd0e8cecdb94 -0.97588025    1.013553
#> 13: 69822e48-c535-418d-8593-d41bd745a9d2 -9.42569878    0.916582
#> 14: 01dd0d4c-dd8e-4f4f-b2a1-07701f6e1a68  0.07085662    3.202987
#> 15: 5f9855a8-dda9-43ce-8f1c-fe560d153a9d -6.61173459    1.705343
#> 16: b01e5502-3980-4f41-9564-271712ee41a3  8.34573561    3.714461
#> 17: 498ceb35-50fe-4035-8255-542d187cebc5 -8.96971468   -3.263809
#> 18: 413c7d11-4cb0-4a05-9caa-58e3e715bff6  1.89838435    2.698046
#> 19: 4d96c81d-90d2-443d-8554-49167c6e4be1 -2.71425870    1.813992
#> 20: 9bf71620-51f6-4e18-b5b2-a18252b69da5  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
