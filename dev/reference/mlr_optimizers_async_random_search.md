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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:53:32
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:53:32
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:53:32
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:53:32
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:53:32
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:53:32
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:53:32
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:53:32
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:53:32
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:53:32
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:53:32
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:53:32
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:53:32
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:53:32
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:53:32
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:53:32
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:53:32
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:53:32
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:53:32
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:53:32
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  2: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  3: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  4: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  5: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  6: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  7: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  8: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>  9: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 10: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 11: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 12: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 13: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 14: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 15: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 16: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 17: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 18: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 19: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#> 20: narrow_xinjiangovenator_e2fced58 2026-09-17 09:53:32
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: c156768f-990e-4b5e-9fbe-f0bf44f166c0 -2.11085866    3.149893
#>  2: bc9d05e6-2645-4aa2-be3b-ca7b07e4a036 -8.33732121    3.178398
#>  3: 06ad2036-6c0a-41cc-b6f1-05c8e83aa367 -7.78396197    2.105379
#>  4: 1ad06345-a730-4799-9654-cc83a5c88a82  5.92632791   -4.231512
#>  5: 3ceed1b1-9b7b-4a63-b2e5-ae3efc28d612  0.98995613    2.678818
#>  6: 8f5f1f90-0d56-4fa6-93d1-dcbb82a9705e -3.50214144    1.111543
#>  7: 8a21f1ea-20ea-46e6-9127-b01a73d9cf18  2.77985531    4.933030
#>  8: 5e66142b-ada3-4765-b032-e212744e6ce4  9.86020590    0.052479
#>  9: ef71eca9-5b86-4c2a-a014-f2c5be188195 -4.77089430    4.984108
#> 10: a3e86958-d718-4b38-9760-8bffd4f4d521  8.62827623    3.264048
#> 11: ba392faf-de6f-48ea-87af-f1e1465f1c2a  5.20608164   -2.035465
#> 12: be4b3723-0731-4bcd-84c1-b3e56265ccdd -0.97588025    1.013553
#> 13: b8e768c6-7978-40b4-8c7c-ab506c198c4b -9.42569878    0.916582
#> 14: 5741d382-b4f4-4f20-977d-a747b987368f  0.07085662    3.202987
#> 15: 1f7409c9-026e-4260-9697-0900396011b1 -6.61173459    1.705343
#> 16: a398763b-01af-45c6-94eb-6d4262bcf8fa  8.34573561    3.714461
#> 17: c6add526-c53a-4c7f-a83f-3346f2a23a6c -8.96971468   -3.263809
#> 18: 20a73f72-888e-4c84-8889-9da0972e91c9  1.89838435    2.698046
#> 19: fbde614a-ddd1-42e2-abaa-8b3e40caaae4 -2.71425870    1.813992
#> 20: fd2513ee-6d7c-4cc9-85a6-dbe88dc9dbb7  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
