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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2025-11-07 11:51:14  9663
#>  2: finished  2.6451261 -0.47433125    3.20480965 2025-11-07 11:51:14  9663
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2025-11-07 11:51:14  9663
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2025-11-07 11:51:14  9663
#>  5: finished -4.2982254  4.20337792  -81.55629675 2025-11-07 11:51:14  9663
#>  6: finished -5.3318011  3.07859096  -80.70457510 2025-11-07 11:51:14  9663
#>  7: finished -1.2947935  4.44486001  -56.28160502 2025-11-07 11:51:14  9663
#>  8: finished  4.4867714 -4.92985296    0.09163568 2025-11-07 11:51:14  9663
#>  9: finished -4.1477403  2.28072295  -55.68074611 2025-11-07 11:51:14  9663
#> 10: finished -5.6137151  4.91263287 -110.57841706 2025-11-07 11:51:14  9663
#> 11: finished  0.5407374 -0.53103894    1.77478382 2025-11-07 11:51:14  9663
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2025-11-07 11:51:14  9663
#> 13: finished -8.4307422  4.47890861 -154.73445725 2025-11-07 11:51:14  9663
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2025-11-07 11:51:14  9663
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2025-11-07 11:51:14  9663
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2025-11-07 11:51:14  9663
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2025-11-07 11:51:14  9663
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2025-11-07 11:51:14  9663
#> 19: finished -2.3908942  0.02101378  -18.40647620 2025-11-07 11:51:14  9663
#> 20: finished  0.8103813  4.51596998  -47.90499748 2025-11-07 11:51:14  9663
#>        state         x1          x2             y        timestamp_xs   pid
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2025-11-07 11:51:14 20493849-5a6b-453f-be04-19a4a230f85f
#>  2: papery_hog 2025-11-07 11:51:14 1a675ff3-2f7b-4a4d-805c-8b41cbd131ba
#>  3: papery_hog 2025-11-07 11:51:14 0268e733-0f9b-4d64-929c-666e159a67fc
#>  4: papery_hog 2025-11-07 11:51:14 6a7e0a47-c44e-49cc-b769-2cdb0bbfa6b1
#>  5: papery_hog 2025-11-07 11:51:14 16435ce4-feb0-4a96-ae85-b3d6508a8a7b
#>  6: papery_hog 2025-11-07 11:51:14 f75d2adf-aae8-4e1d-85f0-6c6e16000710
#>  7: papery_hog 2025-11-07 11:51:14 064c9705-2bab-4c32-8d61-e74c9b32eac8
#>  8: papery_hog 2025-11-07 11:51:14 701404b0-dc37-49a9-8191-337a919d985f
#>  9: papery_hog 2025-11-07 11:51:14 af88a609-1ab8-4059-aaac-f35d28168c62
#> 10: papery_hog 2025-11-07 11:51:14 bcf46ca4-2a0e-4ae9-8fc5-208596a31b32
#> 11: papery_hog 2025-11-07 11:51:14 16a2617e-2ae5-441d-9f01-d57908349dba
#> 12: papery_hog 2025-11-07 11:51:14 851c3ae5-7351-47f9-af9b-d0a8e80220b6
#> 13: papery_hog 2025-11-07 11:51:14 c5c8ff77-7358-4649-b558-25f6dee61ec6
#> 14: papery_hog 2025-11-07 11:51:14 7bedd3be-8cb4-46af-af74-42bbe023d2dc
#> 15: papery_hog 2025-11-07 11:51:14 25548476-459a-4661-b964-6de237fe10d6
#> 16: papery_hog 2025-11-07 11:51:14 f359edac-0349-40fd-b3f1-2647c34007c5
#> 17: papery_hog 2025-11-07 11:51:14 f6e31de2-0e3d-480f-a5d4-b7ad514bdd71
#> 18: papery_hog 2025-11-07 11:51:14 9098251c-d917-4bae-b79e-7db5f40f44f8
#> 19: papery_hog 2025-11-07 11:51:14 4d545524-e47c-40cf-8a8c-6f2b4d455b02
#> 20: papery_hog 2025-11-07 11:51:14 8391a417-7f86-4144-a68a-db3da88b8686
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
