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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-03-05 09:12:13  8887
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-03-05 09:12:13  8887
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-03-05 09:12:13  8887
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-03-05 09:12:14  8887
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-03-05 09:12:14  8887
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-03-05 09:12:14  8887
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-03-05 09:12:14  8887
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-03-05 09:12:14  8887
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-03-05 09:12:14  8887
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-03-05 09:12:14  8887
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-03-05 09:12:14  8887
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-03-05 09:12:14  8887
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-03-05 09:12:14  8887
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-03-05 09:12:14  8887
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-03-05 09:12:14  8887
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-03-05 09:12:14  8887
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-03-05 09:12:14  8887
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-03-05 09:12:14  8887
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-03-05 09:12:14  8887
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-03-05 09:12:14  8887
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-03-05 09:12:13 4f12024a-4258-49ea-a348-41bc8811d693
#>  2: papery_hog 2026-03-05 09:12:13 dba3b761-94c0-4126-87a2-d848c80c462a
#>  3: papery_hog 2026-03-05 09:12:13 4afba28f-49b2-428d-98f8-961efb534aab
#>  4: papery_hog 2026-03-05 09:12:14 e4899524-349a-48e4-a46d-0955f87ddb99
#>  5: papery_hog 2026-03-05 09:12:14 243cc547-1c26-408e-8833-907c68948a86
#>  6: papery_hog 2026-03-05 09:12:14 0c88acb6-9637-49d0-881a-681d55e934ef
#>  7: papery_hog 2026-03-05 09:12:14 836ada07-02e4-4e4a-b7f2-f217aaab898c
#>  8: papery_hog 2026-03-05 09:12:14 a3015fd8-4e0e-4574-9f08-6cff0b81d8fb
#>  9: papery_hog 2026-03-05 09:12:14 aac5b416-112b-4b60-8369-e731b843a5e8
#> 10: papery_hog 2026-03-05 09:12:14 df0b271e-c5ce-4e00-8b43-403b0c6c1e5f
#> 11: papery_hog 2026-03-05 09:12:14 01463715-c617-4d42-a1a1-c08d89c634d0
#> 12: papery_hog 2026-03-05 09:12:14 7c3e6271-50da-45df-9883-b46ab1b09543
#> 13: papery_hog 2026-03-05 09:12:14 9637f964-3098-434f-b30b-a0159cf055a9
#> 14: papery_hog 2026-03-05 09:12:14 c87577a8-8878-46f9-bf63-c7bff3d4a807
#> 15: papery_hog 2026-03-05 09:12:14 e4d1ed0e-aaa1-4f21-95e0-8e1c0fe7891c
#> 16: papery_hog 2026-03-05 09:12:14 3d950790-1744-43ab-88b6-0dfb759b32e6
#> 17: papery_hog 2026-03-05 09:12:14 77aa725d-ca81-4e8b-9077-2b07d76471ee
#> 18: papery_hog 2026-03-05 09:12:14 4bc2a41a-34b3-4827-9df9-59c27b2f2703
#> 19: papery_hog 2026-03-05 09:12:14 089741f4-572f-4c2c-9d15-3040ea926f6a
#> 20: papery_hog 2026-03-05 09:12:14 c69e4320-2147-4189-a693-4ee3b5aa078f
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
