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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:13:50
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:13:50
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:13:50
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:13:50
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:13:50
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:13:50
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:13:50
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:13:50
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:13:50
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:13:50
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:13:50
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:13:50
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:13:50
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:13:50
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:13:50
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:13:50
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:13:50
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:13:50
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:13:50
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:13:50
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  2: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  3: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  4: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  5: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  6: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  7: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  8: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>  9: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 10: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 11: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 12: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 13: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 14: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 15: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 16: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 17: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 18: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 19: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#> 20: narrow_xinjiangovenator_258368b0 2026-09-17 09:13:50
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 7b4ae124-88be-46a0-a53d-7e62c784e769 -2.11085866    3.149893
#>  2: e3cbad1d-8174-47f5-99eb-6a2d6ba00aa9 -8.33732121    3.178398
#>  3: 6749d140-00b7-4866-862d-c4130a096079 -7.78396197    2.105379
#>  4: 07fe3ea3-4ab0-47ac-9b2a-bc09ad224d0f  5.92632791   -4.231512
#>  5: dd2b7411-5299-4e3f-b539-e942b9c7699f  0.98995613    2.678818
#>  6: 704d4f56-51f3-4c6e-aeaa-b99288475520 -3.50214144    1.111543
#>  7: 7b99e5a8-156b-486f-9cfa-2b788beb42bd  2.77985531    4.933030
#>  8: e04a6ea6-d7ed-41c1-842f-886c138675eb  9.86020590    0.052479
#>  9: 08213ff1-add6-4d50-9284-f08e09f3fe4d -4.77089430    4.984108
#> 10: b4517dd8-8ce3-4a02-97ac-34a0051b24b8  8.62827623    3.264048
#> 11: e3f597f5-3331-45a3-b14a-067b34efb0c7  5.20608164   -2.035465
#> 12: cd0bcc62-4d99-48f8-bf82-7d8ada3ac8c2 -0.97588025    1.013553
#> 13: ce731c72-9ddf-4583-b2c9-063f15884640 -9.42569878    0.916582
#> 14: 7d42a3e6-4f49-41be-894d-d20ca81132f4  0.07085662    3.202987
#> 15: 8490b812-0301-4153-a2fd-991e304e8fd6 -6.61173459    1.705343
#> 16: 7fdf1650-6f64-4941-9e84-3268c649368b  8.34573561    3.714461
#> 17: c00f30ad-33b8-4a48-bb87-89b68ff673e8 -8.96971468   -3.263809
#> 18: b3b14579-a86f-4de8-a107-9947aa2d6b93  1.89838435    2.698046
#> 19: 531e68f5-59d5-4314-b38d-e5e750564c67 -2.71425870    1.813992
#> 20: 350a30b9-c0dd-450d-a832-f27c15a8e540  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
