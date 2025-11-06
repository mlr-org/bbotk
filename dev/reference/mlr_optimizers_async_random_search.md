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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-06 11:18:42 11766
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-06 11:18:42 11766
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-06 11:18:42 11766
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-06 11:18:42 11766
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-06 11:18:42 11766
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-06 11:18:42 11766
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-06 11:18:42 11766
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-06 11:18:42 11766
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-06 11:18:42 11766
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-06 11:18:43 11766
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-06 11:18:43 11766
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-06 11:18:43 11766
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-06 11:18:43 11766
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-06 11:18:43 11766
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-06 11:18:43 11766
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-06 11:18:43 11766
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-06 11:18:43 11766
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-06 11:18:43 11766
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-06 11:18:43 11766
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-06 11:18:43 11766
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-06 11:18:42 88e08074-e21b-4a6a-a53c-e5337103917d
#>  2: papery_hog 2025-11-06 11:18:42 3afa8122-bb93-47c3-b201-9ea64a8f0704
#>  3: papery_hog 2025-11-06 11:18:42 0f0fd489-07de-49c4-a15d-3fdbb90fbb91
#>  4: papery_hog 2025-11-06 11:18:42 d758694c-5d78-4f12-a385-c49e3bf6ab7d
#>  5: papery_hog 2025-11-06 11:18:42 8022526f-928e-4dd2-9205-bc0b6933f748
#>  6: papery_hog 2025-11-06 11:18:42 12c28007-719b-46e1-9e8a-672df9d71fae
#>  7: papery_hog 2025-11-06 11:18:42 acb6a2a3-91eb-406a-9dd6-6e3fc90c952a
#>  8: papery_hog 2025-11-06 11:18:42 900854c5-c23c-4e95-b665-25afc7eb8c7a
#>  9: papery_hog 2025-11-06 11:18:42 b329b186-3133-4ab7-a2db-2b8e58c29a1b
#> 10: papery_hog 2025-11-06 11:18:43 b0b46102-79d1-4977-9f12-a495ac5de4eb
#> 11: papery_hog 2025-11-06 11:18:43 f8696c06-9b83-408e-9f22-b5b9420aff1f
#> 12: papery_hog 2025-11-06 11:18:43 c182a570-71cd-4e9e-8620-76484f08ef45
#> 13: papery_hog 2025-11-06 11:18:43 f05cdde6-d5b0-4924-bee5-7555313816b7
#> 14: papery_hog 2025-11-06 11:18:43 2c6c33c6-1a83-4694-8137-0beeb5914c96
#> 15: papery_hog 2025-11-06 11:18:43 af495e51-8117-434a-bf37-1b4d9f0dcda2
#> 16: papery_hog 2025-11-06 11:18:43 b9603bac-072d-4071-9a7e-76308a4f80d5
#> 17: papery_hog 2025-11-06 11:18:43 1db926c2-d3e0-4149-9c53-d85c3bef4b09
#> 18: papery_hog 2025-11-06 11:18:43 74ac3dbb-c8f0-4816-ab90-f2a1f1c3d34f
#> 19: papery_hog 2025-11-06 11:18:43 91e4c8f2-baff-4787-92e5-80a5f46074a0
#> 20: papery_hog 2025-11-06 11:18:43 13f7ca05-36ef-41d8-8e88-e753a007070c
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
