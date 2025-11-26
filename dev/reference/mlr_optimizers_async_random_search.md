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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-26 11:10:10  8397
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-26 11:10:10  8397
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-26 11:10:10  8397
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-26 11:10:10  8397
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-26 11:10:10  8397
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-26 11:10:11  8397
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-26 11:10:11  8397
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-26 11:10:11  8397
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-26 11:10:11  8397
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-26 11:10:11  8397
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-26 11:10:11  8397
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-26 11:10:11  8397
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-26 11:10:11  8397
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-26 11:10:11  8397
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-26 11:10:11  8397
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-26 11:10:11  8397
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-26 11:10:11  8397
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-26 11:10:11  8397
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-26 11:10:11  8397
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-26 11:10:11  8397
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-26 11:10:10 29ed4e68-c061-4c75-af98-b0401a46c0cd
#>  2: papery_hog 2025-11-26 11:10:10 7e9d808e-12a5-41c4-80a5-f2274575a162
#>  3: papery_hog 2025-11-26 11:10:10 f31add29-6027-4525-b89c-3a7cf1a68cea
#>  4: papery_hog 2025-11-26 11:10:10 19dbb61b-375b-4222-a8ec-fb4015ee2e48
#>  5: papery_hog 2025-11-26 11:10:10 298e0565-8328-4934-bb6a-9964bd155d38
#>  6: papery_hog 2025-11-26 11:10:11 dc8ec265-9c43-4af9-a932-b58768db39bb
#>  7: papery_hog 2025-11-26 11:10:11 55c408b3-1c50-4a64-96f7-426b08dd167a
#>  8: papery_hog 2025-11-26 11:10:11 4b915d22-8e68-40e5-a1cd-22ce6a95a434
#>  9: papery_hog 2025-11-26 11:10:11 d40ff5ae-1152-41dc-9b7f-13b45da7b44b
#> 10: papery_hog 2025-11-26 11:10:11 81d705e3-f1c6-40ec-8d6e-b1cba02f0d58
#> 11: papery_hog 2025-11-26 11:10:11 ea671578-8d61-4eae-9465-03cfbe77787b
#> 12: papery_hog 2025-11-26 11:10:11 dc925957-69f1-4d75-80c1-1b8e9580426f
#> 13: papery_hog 2025-11-26 11:10:11 87f659a1-75f0-4a14-9c6f-e6d38094d0a7
#> 14: papery_hog 2025-11-26 11:10:11 5b0b9899-e653-4f1f-8cf2-2c4da0b722ec
#> 15: papery_hog 2025-11-26 11:10:11 5d614ac0-bfd4-49e9-98c9-4991549e6bfb
#> 16: papery_hog 2025-11-26 11:10:11 a2b76f6f-2966-4e2f-9160-89daac5ca3a7
#> 17: papery_hog 2025-11-26 11:10:11 d1668637-cca1-406d-81f1-692006f5fda2
#> 18: papery_hog 2025-11-26 11:10:11 a5af26bd-ae47-4edc-ba8e-fe39e9e61436
#> 19: papery_hog 2025-11-26 11:10:11 f5a88807-880f-4816-b72a-f2e1708dd89f
#> 20: papery_hog 2025-11-26 11:10:11 46852a09-f43f-4e11-8735-6e7462c64e27
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
