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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-26 11:07:18  8338
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-26 11:07:19  8338
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-26 11:07:19  8338
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-26 11:07:19  8338
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-26 11:07:19  8338
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-26 11:07:19  8338
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-26 11:07:19  8338
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-26 11:07:19  8338
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-26 11:07:19  8338
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-26 11:07:19  8338
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-26 11:07:19  8338
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-26 11:07:19  8338
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-26 11:07:19  8338
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-26 11:07:19  8338
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-26 11:07:19  8338
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-26 11:07:19  8338
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-26 11:07:19  8338
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-26 11:07:19  8338
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-26 11:07:19  8338
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-26 11:07:19  8338
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-26 11:07:18 4c5f0e2a-54c5-4f02-a06f-51b084c07a71
#>  2: papery_hog 2025-11-26 11:07:19 7ddbebfd-114f-41d6-a426-43cc4a69baab
#>  3: papery_hog 2025-11-26 11:07:19 5abf3ba0-447a-4f91-9266-bf1152a95281
#>  4: papery_hog 2025-11-26 11:07:19 688ca16b-db8e-4aee-a6f9-3577e08befcf
#>  5: papery_hog 2025-11-26 11:07:19 c4dde0c4-fe39-4e52-badc-b402bac55deb
#>  6: papery_hog 2025-11-26 11:07:19 d617f4df-49fc-41f0-a1e1-ab6e0401c4ad
#>  7: papery_hog 2025-11-26 11:07:19 811021a9-bb1d-42e3-aceb-c40a6498340d
#>  8: papery_hog 2025-11-26 11:07:19 0e41aaa6-8b6e-46bf-b9be-c49a809445df
#>  9: papery_hog 2025-11-26 11:07:19 eb58fd08-de97-42fa-93a2-e5bd1e9efbe3
#> 10: papery_hog 2025-11-26 11:07:19 e2096422-2f1c-47ff-b7e9-d8f3fbbd207e
#> 11: papery_hog 2025-11-26 11:07:19 bf1a21a1-8590-4998-a39c-d1462a609554
#> 12: papery_hog 2025-11-26 11:07:19 5dfff06f-e7d2-429d-8247-d73c122fdb71
#> 13: papery_hog 2025-11-26 11:07:19 0c6ce345-2ba3-4a5b-a9c5-484961262d69
#> 14: papery_hog 2025-11-26 11:07:19 97cb2444-4654-434b-9685-68f57e6c9fc2
#> 15: papery_hog 2025-11-26 11:07:19 29eed347-af1f-40fe-92c9-b55f751dfd31
#> 16: papery_hog 2025-11-26 11:07:19 e9fc5637-4eb9-4f62-9e62-842b5f16f3d5
#> 17: papery_hog 2025-11-26 11:07:19 e1603cc3-ef74-43c8-ab94-ef35b9afaedf
#> 18: papery_hog 2025-11-26 11:07:19 ad58b130-4285-4eac-8ef6-447ea5d724bf
#> 19: papery_hog 2025-11-26 11:07:19 c861792c-68fe-406d-b03e-37b86e13a42c
#> 20: papery_hog 2025-11-26 11:07:19 8ae6dc67-4d8b-4a36-b406-67b935918478
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
