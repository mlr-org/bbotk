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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-12-13 11:32:35  9249
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-12-13 11:32:35  9249
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-12-13 11:32:35  9249
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-12-13 11:32:35  9249
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-12-13 11:32:35  9249
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-12-13 11:32:35  9249
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-12-13 11:32:35  9249
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-12-13 11:32:35  9249
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-12-13 11:32:35  9249
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-12-13 11:32:35  9249
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-12-13 11:32:35  9249
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-12-13 11:32:35  9249
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-12-13 11:32:35  9249
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-12-13 11:32:35  9249
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-12-13 11:32:35  9249
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-12-13 11:32:35  9249
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-12-13 11:32:35  9249
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-12-13 11:32:35  9249
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-12-13 11:32:35  9249
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-12-13 11:32:35  9249
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-12-13 11:32:35 812e8321-8f74-4d20-af8b-fbf948f3dd9a
#>  2: papery_hog 2025-12-13 11:32:35 caca2a24-41e8-4242-a968-be69740e5610
#>  3: papery_hog 2025-12-13 11:32:35 cc5c6d53-4443-4d6a-961e-8a80187a05cf
#>  4: papery_hog 2025-12-13 11:32:35 c8c1acad-462e-4ffb-bdf1-69ddc2761962
#>  5: papery_hog 2025-12-13 11:32:35 e01b4f10-f3c6-4372-bcb5-7c03e3241523
#>  6: papery_hog 2025-12-13 11:32:35 00a9786f-939c-4917-b2f1-8a0a0182ff19
#>  7: papery_hog 2025-12-13 11:32:35 da0b095e-d3a9-4037-a608-f9eec0f273b8
#>  8: papery_hog 2025-12-13 11:32:35 5ef4f913-6865-4445-ba86-b94c1148e9bd
#>  9: papery_hog 2025-12-13 11:32:35 89a1d6f5-6677-43a7-a629-36ce49084923
#> 10: papery_hog 2025-12-13 11:32:35 e8ada185-6b8c-4daf-8f02-794e9c77f800
#> 11: papery_hog 2025-12-13 11:32:35 69c6bae8-0028-47c6-a42f-1cf009400c74
#> 12: papery_hog 2025-12-13 11:32:35 0758caf7-58cf-477b-a95b-ee2974d268c1
#> 13: papery_hog 2025-12-13 11:32:35 d87b5391-ea82-417b-8d54-411d57b6fcc4
#> 14: papery_hog 2025-12-13 11:32:35 8d25011a-0bac-472b-85af-815704cea65e
#> 15: papery_hog 2025-12-13 11:32:35 aeaff13c-b335-4469-88a0-09365faafa5c
#> 16: papery_hog 2025-12-13 11:32:35 f049ca1e-2da2-45ad-9e8a-1acdc5833a27
#> 17: papery_hog 2025-12-13 11:32:35 64d56407-a33f-4611-a276-67c8511c0d24
#> 18: papery_hog 2025-12-13 11:32:35 62f5f84f-ca88-42f6-9fe1-116d71ffcaf6
#> 19: papery_hog 2025-12-13 11:32:35 7ac8b421-3f7a-46bd-92fd-1e2f31f616d5
#> 20: papery_hog 2025-12-13 11:32:35 a088c83e-b57e-4527-af74-9b25e43da713
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
