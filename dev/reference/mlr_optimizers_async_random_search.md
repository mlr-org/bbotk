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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-07-14 10:25:23
#>  2: finished -8.33732121  3.178398 -135.032815 2026-07-14 10:25:23
#>  3: finished -7.78396197  2.105379 -111.790803 2026-07-14 10:25:23
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-07-14 10:25:23
#>  5: finished  0.98995613  2.678818  -23.269168 2026-07-14 10:25:23
#>  6: finished -3.50214144  1.111543  -37.178342 2026-07-14 10:25:23
#>  7: finished  2.77985531  4.933030  -53.541141 2026-07-14 10:25:23
#>  8: finished  9.86020590  0.052479  -61.100465 2026-07-14 10:25:23
#>  9: finished -4.77089430  4.984108  -99.590989 2026-07-14 10:25:23
#> 10: finished  8.62827623  3.264048  -73.172348 2026-07-14 10:25:23
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-07-14 10:25:23
#> 12: finished -0.97588025  1.013553  -14.964468 2026-07-14 10:25:23
#> 13: finished -9.42569878  0.916582 -135.886207 2026-07-14 10:25:23
#> 14: finished  0.07085662  3.202987  -32.198639 2026-07-14 10:25:23
#> 15: finished -6.61173459  1.705343  -86.302224 2026-07-14 10:25:23
#> 16: finished  8.34573561  3.714461  -75.352353 2026-07-14 10:25:23
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-07-14 10:25:23
#> 18: finished  1.89838435  2.698046  -22.478057 2026-07-14 10:25:23
#> 19: finished -2.71425870  1.813992  -35.398750 2026-07-14 10:25:23
#> 20: finished  1.30114551 -4.177370    8.125403 2026-07-14 10:25:23
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  2: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  3: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  4: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  5: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  6: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  7: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  8: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>  9: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 10: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 11: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 12: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 13: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 14: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 15: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 16: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 17: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 18: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 19: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#> 20: narrow_xinjiangovenator_459921d8 2026-07-14 10:25:23
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 3d2c24ff-8e24-4afa-a90f-0ca0d0ad361b -2.11085866    3.149893
#>  2: 01e3f539-a5f8-45ef-8ef5-a3b26872088a -8.33732121    3.178398
#>  3: c7e06bfe-0e75-4954-84f4-c462b0813d81 -7.78396197    2.105379
#>  4: 9b3481d8-7031-469c-b30e-724c0a8a0a60  5.92632791   -4.231512
#>  5: 561e7cbf-b2b4-4ce7-ac9a-e27ebf860830  0.98995613    2.678818
#>  6: cb7ca7d1-0dc4-46c4-9d8e-00bbd3cd1a9e -3.50214144    1.111543
#>  7: dd35c017-69ed-41c0-89b4-1ce3f78ffbd2  2.77985531    4.933030
#>  8: 72a7586f-545c-471b-b656-7512d390585b  9.86020590    0.052479
#>  9: 1dc194bb-ef56-4871-9416-7ad7476622c0 -4.77089430    4.984108
#> 10: 460b0d50-b033-4559-84db-9c46f7c1b891  8.62827623    3.264048
#> 11: cbcca27b-acea-4d40-82d5-d85eeaa8b746  5.20608164   -2.035465
#> 12: dc503a5d-5f86-4b1c-8e8b-a4f3b3cd09a2 -0.97588025    1.013553
#> 13: f4b507cc-fb70-429a-8eb2-729f053bcc9f -9.42569878    0.916582
#> 14: 0066c6da-ea6a-41f2-891d-72c4b4c48a3a  0.07085662    3.202987
#> 15: 53d3ce3e-7ac2-4f57-8b14-ff78463cc51d -6.61173459    1.705343
#> 16: 12300446-319e-43ed-b531-a7da0bf14178  8.34573561    3.714461
#> 17: 4a9a49aa-2802-4b8d-9f9c-ca3ad364ab63 -8.96971468   -3.263809
#> 18: f3316866-9668-4e14-abea-0978ca323cfb  1.89838435    2.698046
#> 19: 66238e45-cc6b-4a02-967c-fe911cb146b1 -2.71425870    1.813992
#> 20: 201242da-dd68-44b4-b200-d95650ce08c8  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
