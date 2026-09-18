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
#>  1: finished -2.11085866  3.149893  -44.720348 2026-09-18 09:19:25
#>  2: finished -8.33732121  3.178398 -135.032815 2026-09-18 09:19:25
#>  3: finished -7.78396197  2.105379 -111.790803 2026-09-18 09:19:25
#>  4: finished  5.92632791 -4.231512   -6.932672 2026-09-18 09:19:25
#>  5: finished  0.98995613  2.678818  -23.269168 2026-09-18 09:19:25
#>  6: finished -3.50214144  1.111543  -37.178342 2026-09-18 09:19:25
#>  7: finished  2.77985531  4.933030  -53.541141 2026-09-18 09:19:25
#>  8: finished  9.86020590  0.052479  -61.100465 2026-09-18 09:19:25
#>  9: finished -4.77089430  4.984108  -99.590989 2026-09-18 09:19:25
#> 10: finished  8.62827623  3.264048  -73.172348 2026-09-18 09:19:25
#> 11: finished  5.20608164 -2.035465   -1.209287 2026-09-18 09:19:25
#> 12: finished -0.97588025  1.013553  -14.964468 2026-09-18 09:19:25
#> 13: finished -9.42569878  0.916582 -135.886207 2026-09-18 09:19:25
#> 14: finished  0.07085662  3.202987  -32.198639 2026-09-18 09:19:25
#> 15: finished -6.61173459  1.705343  -86.302224 2026-09-18 09:19:25
#> 16: finished  8.34573561  3.714461  -75.352353 2026-09-18 09:19:25
#> 17: finished -8.96971468 -3.263809 -110.404235 2026-09-18 09:19:25
#> 18: finished  1.89838435  2.698046  -22.478057 2026-09-18 09:19:25
#> 19: finished -2.71425870  1.813992  -35.398750 2026-09-18 09:19:25
#> 20: finished  1.30114551 -4.177370    8.125403 2026-09-18 09:19:25
#>        state          x1        x2           y        timestamp_xs
#>       <char>       <num>     <num>       <num>              <POSc>
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>  1: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  2: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  3: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  4: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  5: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  6: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  7: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  8: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>  9: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 10: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 11: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 12: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 13: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 14: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 15: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 16: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 17: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 18: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 19: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#> 20: narrow_xinjiangovenator_33392330 2026-09-18 09:19:25
#>                            worker_id        timestamp_ys
#>                               <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 9cd70165-d09a-4bf7-9e5e-a6996f4aaf22 -2.11085866    3.149893
#>  2: dfdc14ba-6e59-4c2f-ac12-5fbbc30bf88e -8.33732121    3.178398
#>  3: 846d4e7c-3e26-4833-94e4-3dd8194ecd95 -7.78396197    2.105379
#>  4: 847c401d-2f9b-46ee-9417-be67b35c1637  5.92632791   -4.231512
#>  5: 02c5159a-c6e0-4e9a-8eae-205a8ffafc0a  0.98995613    2.678818
#>  6: a376a821-4f63-4208-a7cd-a54852479c24 -3.50214144    1.111543
#>  7: 8e8b4621-0952-4f58-be9b-d57e6735a52b  2.77985531    4.933030
#>  8: 2cab44bb-3b8f-496e-a180-eac279078458  9.86020590    0.052479
#>  9: a4dc0d08-60e9-4cf6-b176-b532b5baea86 -4.77089430    4.984108
#> 10: 99c1106a-cb12-45f4-ba33-d4ee6a91d988  8.62827623    3.264048
#> 11: af661bd1-80a6-4de8-a8f0-3f5d1230004c  5.20608164   -2.035465
#> 12: 4677cd16-e27f-4df7-9baa-9535f0b82037 -0.97588025    1.013553
#> 13: 6ac8405b-1da6-4155-ac22-800b9cadcca3 -9.42569878    0.916582
#> 14: 8142252f-51e6-405d-999b-f93f8801c381  0.07085662    3.202987
#> 15: a981a0ce-a8be-4466-a9f3-d76470bfd6ec -6.61173459    1.705343
#> 16: fdfc7cf9-8e64-4ccf-88c5-65f67da6fda2  8.34573561    3.714461
#> 17: e90d364e-3d8f-4a9c-8168-8c939c92c815 -8.96971468   -3.263809
#> 18: e078fb93-e8f5-47fd-a056-8e7de89a7e0d  1.89838435    2.698046
#> 19: a4dd0227-db3b-43fd-8f44-c9fa11ec9a6f -2.71425870    1.813992
#> 20: cccbe98f-721a-4033-8944-922f7cc26ad9  1.30114551   -4.177370
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
