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
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-18 10:57:53  8753
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-18 10:57:53  8753
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-18 10:57:53  8753
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-18 10:57:53  8753
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-18 10:57:53  8753
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-18 10:57:53  8753
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-18 10:57:53  8753
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-18 10:57:53  8753
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-18 10:57:53  8753
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-18 10:57:53  8753
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-18 10:57:53  8753
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-18 10:57:53  8753
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-18 10:57:53  8753
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-18 10:57:53  8753
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-18 10:57:53  8753
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-18 10:57:53  8753
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-18 10:57:53  8753
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-18 10:57:53  8753
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-18 10:57:53  8753
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-18 10:57:53  8753
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-18 10:57:53 0c14a680-35b1-4f59-ae71-1d702d30d0f1
#>  2: papery_hog 2026-02-18 10:57:53 ed6b73d8-adf8-4747-a1b3-5ed3858786f0
#>  3: papery_hog 2026-02-18 10:57:53 22e09e30-8eae-49aa-86f1-e9c8e68c6f23
#>  4: papery_hog 2026-02-18 10:57:53 42ea9a82-3a86-4938-943e-10ee95bf1017
#>  5: papery_hog 2026-02-18 10:57:53 c1b486a9-2afb-4287-be57-bf06a76bfef2
#>  6: papery_hog 2026-02-18 10:57:53 8f833932-56f9-4701-9c04-624743b866fd
#>  7: papery_hog 2026-02-18 10:57:53 c07e59f1-a640-4206-8fbd-605fee96d415
#>  8: papery_hog 2026-02-18 10:57:53 4d6d1d8d-589c-423a-965a-eff0e7556cd0
#>  9: papery_hog 2026-02-18 10:57:53 d5474f7e-322d-4276-b1b1-8c5fdf50bf10
#> 10: papery_hog 2026-02-18 10:57:53 7fb6a224-f45d-426d-8857-9cf1ba4333ec
#> 11: papery_hog 2026-02-18 10:57:53 41af125f-1874-4640-b450-4ac2431e38f7
#> 12: papery_hog 2026-02-18 10:57:53 5688e5df-0268-43a5-9312-5f099796152c
#> 13: papery_hog 2026-02-18 10:57:53 21609ea1-a68c-47ec-890f-3075806cea39
#> 14: papery_hog 2026-02-18 10:57:53 15a07166-83ea-4e00-ab2f-0a9b0e07c0e3
#> 15: papery_hog 2026-02-18 10:57:53 06e4313a-5243-4222-b790-a55a163fddaa
#> 16: papery_hog 2026-02-18 10:57:53 b1bb0763-7ab4-47ef-8191-8bb94484b1fe
#> 17: papery_hog 2026-02-18 10:57:53 dc5f176f-b083-4067-899d-e61c21e8dab8
#> 18: papery_hog 2026-02-18 10:57:53 a602a063-7d10-40b7-b24c-2064caa6d71b
#> 19: papery_hog 2026-02-18 10:57:53 4adc203e-ef42-42e7-8737-42cd6a2eb901
#> 20: papery_hog 2026-02-18 10:57:53 015ad069-cd1d-43ea-aeb4-893482370c3d
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
