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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-26 09:06:17  8414
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-26 09:06:17  8414
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-26 09:06:17  8414
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-26 09:06:17  8414
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-26 09:06:17  8414
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-26 09:06:17  8414
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-26 09:06:17  8414
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-26 09:06:17  8414
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-26 09:06:17  8414
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-26 09:06:17  8414
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-26 09:06:17  8414
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-26 09:06:18  8414
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-26 09:06:18  8414
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-26 09:06:18  8414
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-26 09:06:18  8414
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-26 09:06:18  8414
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-26 09:06:18  8414
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-26 09:06:18  8414
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-26 09:06:18  8414
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-26 09:06:18  8414
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-26 09:06:17 e05db0bd-e505-4b22-be70-46315c143ad3
#>  2: papery_hog 2025-11-26 09:06:17 a9130c73-5f58-486b-936a-3c56080fe48a
#>  3: papery_hog 2025-11-26 09:06:17 b2bb7bb0-e93e-4a5b-b4bd-0420a682ebc8
#>  4: papery_hog 2025-11-26 09:06:17 1927a25e-7d39-4450-a11d-39936085ec86
#>  5: papery_hog 2025-11-26 09:06:17 e13d3461-6843-4643-815f-dd67bb1b797e
#>  6: papery_hog 2025-11-26 09:06:17 db27290b-dd02-4257-ac1c-341515106c5b
#>  7: papery_hog 2025-11-26 09:06:17 b32243fc-884b-491f-934f-292800bd5fda
#>  8: papery_hog 2025-11-26 09:06:17 0c616db1-44a2-40f5-aa7c-2c64ec2a7b8c
#>  9: papery_hog 2025-11-26 09:06:17 45fd7915-fbc5-4d0f-bf59-1c4033ff70f3
#> 10: papery_hog 2025-11-26 09:06:17 221d357f-3b6d-42a2-a071-557081a22c13
#> 11: papery_hog 2025-11-26 09:06:17 7d6bbf69-bb5a-401b-9dab-f6f2c5d44bfc
#> 12: papery_hog 2025-11-26 09:06:18 be5b6388-0331-483f-84f3-416889ec3ab2
#> 13: papery_hog 2025-11-26 09:06:18 017f1245-5196-4d08-8708-c69e3d37a67e
#> 14: papery_hog 2025-11-26 09:06:18 7fb9bd2d-307b-4a5c-af95-9c9bf07f40a4
#> 15: papery_hog 2025-11-26 09:06:18 64c7950b-2285-43d4-822a-128914e7216e
#> 16: papery_hog 2025-11-26 09:06:18 05205896-7d0c-4a29-87b8-e2a1c32baa93
#> 17: papery_hog 2025-11-26 09:06:18 e2fb12dd-f12a-4588-9802-6186f29ae54d
#> 18: papery_hog 2025-11-26 09:06:18 81ffdf14-26d9-4d10-8112-66f74f8a26e0
#> 19: papery_hog 2025-11-26 09:06:18 81eea195-20c3-429c-b02c-dc0414c02685
#> 20: papery_hog 2025-11-26 09:06:18 83db3767-f79e-468d-8e99-3a1dbbab15c5
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
