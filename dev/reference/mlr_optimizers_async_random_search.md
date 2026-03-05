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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-03-05 08:52:28  8881
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-03-05 08:52:28  8881
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-03-05 08:52:28  8881
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-03-05 08:52:28  8881
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-03-05 08:52:28  8881
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-03-05 08:52:28  8881
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-03-05 08:52:28  8881
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-03-05 08:52:28  8881
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-03-05 08:52:29  8881
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-03-05 08:52:29  8881
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-03-05 08:52:29  8881
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-03-05 08:52:29  8881
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-03-05 08:52:29  8881
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-03-05 08:52:29  8881
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-03-05 08:52:29  8881
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-03-05 08:52:29  8881
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-03-05 08:52:29  8881
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-03-05 08:52:29  8881
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-03-05 08:52:29  8881
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-03-05 08:52:29  8881
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-03-05 08:52:28 3b5e496d-0aae-48d2-8441-9739929f2318
#>  2: papery_hog 2026-03-05 08:52:28 db63bcdf-e728-42ee-a002-74fcef5ec17f
#>  3: papery_hog 2026-03-05 08:52:28 6d130960-1ce0-4870-a8a5-421b968931ce
#>  4: papery_hog 2026-03-05 08:52:28 790031c6-ad6d-4332-8035-05fd863d4014
#>  5: papery_hog 2026-03-05 08:52:28 7378f896-53bb-4acd-94b6-b0015e9e653b
#>  6: papery_hog 2026-03-05 08:52:28 e37a8feb-8cf1-4116-ba6a-7accfa88cfea
#>  7: papery_hog 2026-03-05 08:52:28 a6c41659-72a4-4038-8070-08c150acee01
#>  8: papery_hog 2026-03-05 08:52:28 bc8c9f5e-830c-4f0d-addd-fab1704b7a74
#>  9: papery_hog 2026-03-05 08:52:29 3fa83b5b-8020-49d2-8c82-e2d7ec436897
#> 10: papery_hog 2026-03-05 08:52:29 50aa3cc9-8bec-4365-b732-0d4c9a4cf7b5
#> 11: papery_hog 2026-03-05 08:52:29 e409d26d-2809-47d3-b3ca-2a5d4cf5a43e
#> 12: papery_hog 2026-03-05 08:52:29 dfd26223-5b0b-4865-9ca5-9bc895fc7de9
#> 13: papery_hog 2026-03-05 08:52:29 36a543a6-5b39-4920-9d0b-1f9a63a01790
#> 14: papery_hog 2026-03-05 08:52:29 6c7d0103-afb7-4116-99f8-9ac02a03e7ea
#> 15: papery_hog 2026-03-05 08:52:29 724c0bc8-f8e7-45b5-badf-85daf2a102fb
#> 16: papery_hog 2026-03-05 08:52:29 3053c71a-6675-4ade-a7e3-eb6a73dbe863
#> 17: papery_hog 2026-03-05 08:52:29 8b87d660-02cd-4850-a7d5-fbb65267e7e8
#> 18: papery_hog 2026-03-05 08:52:29 2a348dda-4b0c-484d-a59f-af2b61c3b9a3
#> 19: papery_hog 2026-03-05 08:52:29 0b169075-89b8-4e11-8ad2-b23e39037046
#> 20: papery_hog 2026-03-05 08:52:29 29633527-c7b1-4dd6-a943-8cca3cee735c
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
