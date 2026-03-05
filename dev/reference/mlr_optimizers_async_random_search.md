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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-03-05 07:59:13  9497
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-03-05 07:59:13  9497
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-03-05 07:59:13  9497
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-03-05 07:59:13  9497
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-03-05 07:59:13  9497
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-03-05 07:59:13  9497
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-03-05 07:59:13  9497
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-03-05 07:59:13  9497
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-03-05 07:59:13  9497
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-03-05 07:59:13  9497
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-03-05 07:59:13  9497
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-03-05 07:59:13  9497
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-03-05 07:59:13  9497
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-03-05 07:59:13  9497
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-03-05 07:59:13  9497
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-03-05 07:59:13  9497
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-03-05 07:59:13  9497
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-03-05 07:59:13  9497
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-03-05 07:59:13  9497
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-03-05 07:59:13  9497
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-03-05 07:59:13 d6b6d0a2-528c-4c9a-83ac-03c4b5895514
#>  2: papery_hog 2026-03-05 07:59:13 cceb97dd-8043-425b-8a65-da31c12756c2
#>  3: papery_hog 2026-03-05 07:59:13 3eb5ea3c-6113-43c7-afba-fc62a3fd0804
#>  4: papery_hog 2026-03-05 07:59:13 83c47087-ff13-41dc-bae5-11db31cb6654
#>  5: papery_hog 2026-03-05 07:59:13 dbafb976-d609-4523-86ab-e02695a682bd
#>  6: papery_hog 2026-03-05 07:59:13 0cd4ee81-79e9-415d-a0ef-bcd2f66ea996
#>  7: papery_hog 2026-03-05 07:59:13 b75b46f5-1437-48f1-9a7b-e8310d2f9aa3
#>  8: papery_hog 2026-03-05 07:59:13 90c91b1a-bf52-402e-8c8f-c78c47cd377c
#>  9: papery_hog 2026-03-05 07:59:13 8fb1ca1f-9a16-4371-b513-1f5f7fc8ffdf
#> 10: papery_hog 2026-03-05 07:59:13 1ebb63b3-dbe2-4c63-af95-842a89b1ab23
#> 11: papery_hog 2026-03-05 07:59:13 30b57467-7200-480a-a05c-753fb6213934
#> 12: papery_hog 2026-03-05 07:59:13 b3971471-ece8-4c30-a3ee-8db3a1fc478c
#> 13: papery_hog 2026-03-05 07:59:13 bb30ee7d-a076-4926-87e0-a38e766903bc
#> 14: papery_hog 2026-03-05 07:59:13 d8d7f6e0-0c1e-4bf4-845e-ed763f7b9f60
#> 15: papery_hog 2026-03-05 07:59:13 2cd93838-2a7b-4b9e-a337-da2813cf79c7
#> 16: papery_hog 2026-03-05 07:59:13 e551d5aa-8c9a-4c9a-811a-10bc631daa50
#> 17: papery_hog 2026-03-05 07:59:13 fa198678-7c9a-43d6-a8aa-86278e92ce8f
#> 18: papery_hog 2026-03-05 07:59:13 eae4b9cc-7cfa-487f-b740-0dc704350975
#> 19: papery_hog 2026-03-05 07:59:13 3cdedb25-3ba6-4623-8f51-91b1b78d0e0d
#> 20: papery_hog 2026-03-05 07:59:13 bb89e3f6-b973-45bb-9182-1b5620117b9d
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
