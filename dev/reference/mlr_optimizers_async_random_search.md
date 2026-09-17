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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 07:54:56
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 07:54:56
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 07:54:56
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 07:54:56
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 07:54:56
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 07:54:56
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 07:54:56
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 07:54:56
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 07:54:56
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 07:54:56
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 07:54:56
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 07:54:56
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 07:54:56
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 07:54:56
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 07:54:56
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 07:54:56
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 07:54:56
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 07:54:56
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 07:54:56
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 07:54:57
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  2: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  3: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  4: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  5: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  6: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  7: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  8: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#>  9: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 10: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 11: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 12: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 13: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 14: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 15: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 16: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 17: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 18: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 19: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:56
#> 20: narrow_xinjiangovenator_c9614147 2026-09-17 07:54:57
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 631b6fc0-ac43-4656-99ee-95311d089a9a -2.11085866    3.149893
#>  2: 02f8b030-d7e1-44c3-9715-cc1c3c9f503b -8.33732121    3.178398
#>  3: 23c5c54b-6f1a-45b7-b7a6-a6ed42531b14 -7.78396197    2.105379
#>  4: 00bfdb17-498b-4f63-b048-d912ecbbd564  5.92632791   -4.231512
#>  5: 509c93ce-4fd2-4170-98bd-dc74d99bd985  0.98995613    2.678818
#>  6: 5589e0aa-6722-43d6-9bcc-e3965353d59c -3.50214144    1.111543
#>  7: abac5694-b2af-4c62-bcdd-5281621b15e0  2.77985531    4.933030
#>  8: 41a69c81-f6b8-4ccd-849f-4f1f8f7dddee  9.86020590    0.052479
#>  9: 5a73de3c-9c14-479d-954f-b766002e1ec0 -4.77089430    4.984108
#> 10: 489fba95-a640-4392-9175-9ff6a7d697dd  8.62827623    3.264048
#> 11: 790867cb-17d1-479e-8241-10e9d479e332  5.20608164   -2.035465
#> 12: c74fcc48-165a-4588-8853-6ce952616686 -0.97588025    1.013553
#> 13: c01d46be-66a5-48db-9ce4-8b90cb01023b -9.42569878    0.916582
#> 14: eafa41e4-8f00-467e-9a78-45e9207b7af6  0.07085662    3.202987
#> 15: cf70e29a-6f07-476e-ae52-6a993c1e1475 -6.61173459    1.705343
#> 16: b2a21f80-39e4-4715-9697-02174496b909  8.34573561    3.714461
#> 17: 6c7b51b2-c098-41ec-9639-54d350547c44 -8.96971468   -3.263809
#> 18: 5de7a639-1a42-4020-a905-7a803e0b38fa  1.89838435    2.698046
#> 19: f47bdf4c-ff97-4eca-b4a6-43fe56d38634 -2.71425870    1.813992
#> 20: e21f144a-bfcb-4073-9067-398183de4a82  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
