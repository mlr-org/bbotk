# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

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
rush::rush_plan(worker_type = "remote")
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
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-26 11:04:09  8332
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-26 11:04:09  8332
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-26 11:04:09  8332
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-26 11:04:09  8332
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-26 11:04:09  8332
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-26 11:04:09  8332
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-26 11:04:09  8332
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-26 11:04:09  8332
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-26 11:04:09  8332
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-26 11:04:09  8332
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-26 11:04:09  8332
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-26 11:04:09  8332
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-26 11:04:09  8332
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-26 11:04:09  8332
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-26 11:04:09  8332
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-26 11:04:09  8332
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-26 11:04:09  8332
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-26 11:04:09  8332
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-26 11:04:09  8332
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-26 11:04:09  8332
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-26 11:04:09 365032e3-27ff-487c-8c65-548cfd39cc02
#>  2: papery_hog 2025-11-26 11:04:09 d1f8c4b9-3c2d-42f9-a17f-c8cfd8c7d2fd
#>  3: papery_hog 2025-11-26 11:04:09 2f38d59c-28d1-4f4d-8ab9-e1a4d17745ad
#>  4: papery_hog 2025-11-26 11:04:09 be80f32a-ec28-46f7-a6e0-0af31c9063ed
#>  5: papery_hog 2025-11-26 11:04:09 5f983f15-40cd-4559-a1a8-6f7aa36cc60b
#>  6: papery_hog 2025-11-26 11:04:09 eb3be4af-be4d-4877-bc14-a91913eb6778
#>  7: papery_hog 2025-11-26 11:04:09 2ce1c901-e8af-4803-b210-2a19854d77b3
#>  8: papery_hog 2025-11-26 11:04:09 32aeeb88-48c9-4ee2-9a2e-228cf5b94eba
#>  9: papery_hog 2025-11-26 11:04:09 6cf7368a-d3d0-4257-bd6c-b7ed0d3e3a13
#> 10: papery_hog 2025-11-26 11:04:09 9f91d315-d56f-4571-8a71-f5f449657e28
#> 11: papery_hog 2025-11-26 11:04:09 0b99d42f-2fec-41a3-9cee-083642c2b5a6
#> 12: papery_hog 2025-11-26 11:04:09 29a0df11-b7ae-4699-84d6-56a1b3fadcbc
#> 13: papery_hog 2025-11-26 11:04:09 0f810079-aa36-41f5-a55c-14319dc938ce
#> 14: papery_hog 2025-11-26 11:04:09 f8b2f45b-7d9f-4df8-bb54-6da9ae724c31
#> 15: papery_hog 2025-11-26 11:04:09 1cc1a54c-4011-4f12-a016-20c08b4595c3
#> 16: papery_hog 2025-11-26 11:04:09 b0e44a81-35f8-435a-88ad-4b2f140ab84f
#> 17: papery_hog 2025-11-26 11:04:09 4870938f-9fcd-457e-9f75-9c9cb3b3c17f
#> 18: papery_hog 2025-11-26 11:04:09 7a9327a4-b15e-4782-90f9-e1a86effb8d7
#> 19: papery_hog 2025-11-26 11:04:09 6ac3d24c-2f69-4474-8ed6-706a9ca6936e
#> 20: papery_hog 2025-11-26 11:04:09 557b8020-21f0-47a2-8fd4-5474ccb8825c
#>      worker_id        timestamp_ys                                 keys
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
#>  1:  -8.6401429 -0.22082921
#>  2:   2.6451261 -0.47433125
#>  3:   6.6553863 -4.98604438
#>  4:   5.0158969 -1.16851633
#>  5:  -4.2982254  4.20337792
#>  6:  -5.3318011  3.07859096
#>  7:  -1.2947935  4.44486001
#>  8:   4.4867714 -4.92985296
#>  9:  -4.1477403  2.28072295
#> 10:  -5.6137151  4.91263287
#> 11:   0.5407374 -0.53103894
#> 12:  -5.7833451 -3.39854730
#> 13:  -8.4307422  4.47890861
#> 14:   7.1022916 -0.75569363
#> 15:   5.9002467 -2.48642191
#> 16:   4.0407162 -0.43184476
#> 17:  -7.4830553 -2.92798538
#> 18:  -3.9849409 -1.06526646
#> 19:  -2.3908942  0.02101378
#> 20:   0.8103813  4.51596998
#>     x_domain_x1 x_domain_x2
```
