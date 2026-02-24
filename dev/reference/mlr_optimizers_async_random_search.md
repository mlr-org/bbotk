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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-24 11:45:30  9960
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-24 11:45:30  9960
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-24 11:45:30  9960
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-24 11:45:30  9960
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-24 11:45:31  9960
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-24 11:45:31  9960
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-24 11:45:31  9960
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-24 11:45:31  9960
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-24 11:45:31  9960
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-24 11:45:31  9960
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-24 11:45:31  9960
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-24 11:45:31  9960
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-24 11:45:31  9960
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-24 11:45:31  9960
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-24 11:45:31  9960
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-24 11:45:31  9960
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-24 11:45:31  9960
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-24 11:45:31  9960
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-24 11:45:31  9960
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-24 11:45:31  9960
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-24 11:45:30 d044d4e1-ae8e-42c6-b499-2250cbeeb1a7
#>  2: papery_hog 2026-02-24 11:45:30 64bbf49f-a63a-428b-a05c-d5df9625e7a6
#>  3: papery_hog 2026-02-24 11:45:30 3865a41e-8aa6-4911-b219-035dee06c25e
#>  4: papery_hog 2026-02-24 11:45:30 f3439c2b-9c06-4816-a99d-9cd187b83529
#>  5: papery_hog 2026-02-24 11:45:31 7d341daa-0e04-447e-a116-0cf7e382301f
#>  6: papery_hog 2026-02-24 11:45:31 b75676a1-9ebb-447e-93d4-4c6cf5de6f6c
#>  7: papery_hog 2026-02-24 11:45:31 e806eb8b-d60d-4753-9ffd-4c3802a72c3c
#>  8: papery_hog 2026-02-24 11:45:31 5e2607d3-2db3-4749-a01e-58089d567e6c
#>  9: papery_hog 2026-02-24 11:45:31 603f9e2a-4de8-430a-a112-02960dbe9771
#> 10: papery_hog 2026-02-24 11:45:31 a807de5b-ee54-492d-b533-266594619dab
#> 11: papery_hog 2026-02-24 11:45:31 6f3fb765-ce30-434e-9dde-8a580849596d
#> 12: papery_hog 2026-02-24 11:45:31 d1f8f579-41ac-4717-914a-5739f2d091df
#> 13: papery_hog 2026-02-24 11:45:31 66318e52-adb2-459a-a9cc-4e9ac96e511c
#> 14: papery_hog 2026-02-24 11:45:31 dbbd4f63-34c8-4c42-a99d-2f227c8cc8d0
#> 15: papery_hog 2026-02-24 11:45:31 7c5e0926-bef2-42c5-a253-3af751323dfa
#> 16: papery_hog 2026-02-24 11:45:31 9fcb6d52-13fc-4e60-af41-36aef015c0e9
#> 17: papery_hog 2026-02-24 11:45:31 6d8a04f4-c94e-4ae7-90f7-931f06d28884
#> 18: papery_hog 2026-02-24 11:45:31 38101b8f-fb51-4fa4-b881-39fe9813d040
#> 19: papery_hog 2026-02-24 11:45:31 3980bb11-7a55-42ea-9fc9-0ce09a4d18af
#> 20: papery_hog 2026-02-24 11:45:31 0cf5108d-fc5e-42ba-97c6-40c624007b2e
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
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
#>           <num>       <num>
```
