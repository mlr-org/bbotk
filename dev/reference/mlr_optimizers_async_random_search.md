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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-17 09:46:43
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-17 09:46:43
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-17 09:46:43
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-17 09:46:43
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-17 09:46:43
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-17 09:46:43
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-17 09:46:43
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-17 09:46:43
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-17 09:46:43
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-17 09:46:43
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-17 09:46:43
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-17 09:46:44
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-17 09:46:44
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-17 09:46:44
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-17 09:46:44
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-17 09:46:44
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-17 09:46:44
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-17 09:46:44
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-17 09:46:44
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-17 09:46:44
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  2: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  3: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  4: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  5: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  6: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  7: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  8: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#>  9: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#> 10: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#> 11: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:43
#> 12: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 13: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 14: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 15: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 16: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 17: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 18: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 19: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#> 20: narrow_xinjiangovenator_6a2e475c 2026-09-17 09:46:44
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 53d79e5e-902f-4546-892c-a05fe74494fa -2.11085866    3.149893
#>  2: 1b00537f-52c1-4fd2-98f1-dd3111971ed8 -8.33732121    3.178398
#>  3: ec8e30bb-e3bf-4fb7-8111-4be0dcb139ae -7.78396197    2.105379
#>  4: 6b4111b3-e538-428f-a328-2970dc4eabf6  5.92632791   -4.231512
#>  5: f7f515cc-3bfa-473b-8347-09b82132d975  0.98995613    2.678818
#>  6: 6ecbb24a-ad50-4b5e-a8a9-60edcb3ca0c4 -3.50214144    1.111543
#>  7: 75405b7b-7e26-45e0-9552-cf47cb288c2b  2.77985531    4.933030
#>  8: 18a852a4-8d38-43a8-bf20-18c463848c13  9.86020590    0.052479
#>  9: db9f1414-80a8-4375-9f3d-a63085594dcb -4.77089430    4.984108
#> 10: a71ef01d-84cd-4c8b-a967-4e9fee34cc24  8.62827623    3.264048
#> 11: 3be151eb-7f3c-4f57-931f-401edc6aaa7d  5.20608164   -2.035465
#> 12: 161cac4e-2139-46c0-b1b0-5a593a7945df -0.97588025    1.013553
#> 13: b15a918c-6e07-4913-aa5c-501a4d899f22 -9.42569878    0.916582
#> 14: b09295e3-23a9-4632-a0e4-040b9b94324e  0.07085662    3.202987
#> 15: bc64fe9e-31c4-4834-b4ce-03affcae2eac -6.61173459    1.705343
#> 16: d4e623d6-4f1b-4686-9dca-78e7cb5caa2a  8.34573561    3.714461
#> 17: cd392e78-4787-4171-a06c-2fd350d310b8 -8.96971468   -3.263809
#> 18: 41124612-61f4-4182-ba21-00237a318830  1.89838435    2.698046
#> 19: 76d34949-9245-4026-b931-558415066175 -2.71425870    1.813992
#> 20: 42a1c6c2-6ae9-43eb-a08e-804285cd0b1f  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
