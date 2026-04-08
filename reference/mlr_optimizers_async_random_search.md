# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

## Source

Bergstra J, Bengio Y (2012). “Random Search for Hyper-Parameter
Optimization.” *Journal of Machine Learning Research*, **13**(10),
281–305. <https://jmlr.csail.mit.edu/papers/v13/bergstra12a.html>.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerAsync.html#method-optimize)

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
rush::rush_plan(worker_type = "mirai")
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
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-08 06:03:02
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-08 06:03:02
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-08 06:03:02
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-08 06:03:02
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-08 06:03:02
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-08 06:03:03
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-08 06:03:03
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-08 06:03:03
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-08 06:03:03
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-08 06:03:03
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-08 06:03:03
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-08 06:03:03
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-08 06:03:03
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-08 06:03:03
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-08 06:03:03
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-08 06:03:03
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-08 06:03:03
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-08 06:03:03
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-08 06:03:03
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-08 06:03:03
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-08 06:03:02
#>  2: narrow_xinjiangovenator 2026-04-08 06:03:02
#>  3: narrow_xinjiangovenator 2026-04-08 06:03:02
#>  4: narrow_xinjiangovenator 2026-04-08 06:03:02
#>  5: narrow_xinjiangovenator 2026-04-08 06:03:02
#>  6: narrow_xinjiangovenator 2026-04-08 06:03:03
#>  7: narrow_xinjiangovenator 2026-04-08 06:03:03
#>  8: narrow_xinjiangovenator 2026-04-08 06:03:03
#>  9: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 10: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 11: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 12: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 13: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 14: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 15: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 16: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 17: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 18: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 19: narrow_xinjiangovenator 2026-04-08 06:03:03
#> 20: narrow_xinjiangovenator 2026-04-08 06:03:03
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 50bb4649-9f0e-4c85-83d3-ebcea9d215d5   7.0005899  0.64849173
#>  2: f460648a-0f65-49f1-98b5-6d7555e11ffc  -4.7273068  1.55118543
#>  3: 0465af23-8e12-4d9e-a2e9-008aa8dcc791  -8.3142357 -0.84808989
#>  4: 84dc2f0d-cb57-4a8e-a11e-a43eae3098ac   7.4495551  2.57767647
#>  5: 3e537739-a1b9-43b1-a53c-7e6ac3a8e070   7.5065666  1.81294693
#>  6: 71c81b5d-b366-427b-9a01-3b84b3bbbd45  -9.8478251 -2.69770124
#>  7: 5e549589-acc3-42f6-9bfa-e574a9791ffe   0.3870992  2.09953629
#>  8: 3130bd37-dd4b-4c3b-b58c-151c06b1aa75   9.1887166  1.95032306
#>  9: df54c5d7-c9bb-45a2-9a7e-3a656b0463c2  -6.7320590 -4.50562770
#> 10: 1d3c2f32-4be0-428f-8071-061d9a0101c8   0.9955564 -3.63495767
#> 11: 6fb43b03-92dc-4411-a89f-2e023dfad3a7   1.9339031  3.60780233
#> 12: db7386e2-95db-4543-9a28-521e510bc3ba  -3.6334861 -0.37274046
#> 13: 2d336421-4e56-40ce-86d6-af785456d4d5  -1.3406191 -2.02690225
#> 14: e32b49f0-906b-4460-a4da-09e7b6f9d1eb  -5.8805572 -2.81415540
#> 15: 0ad82879-6fcf-4866-ae07-892c4d0aef22   6.5360563  4.77872294
#> 16: bef45a0f-b13c-4c1e-aecd-3c6fd1497fdf  -4.5197170 -2.02682984
#> 17: 51e9b7e7-b526-48b1-add2-fa30a682e25c   5.3688411  1.11764111
#> 18: acba45e5-fa60-497a-b7e0-344b68456b72   2.5665792 -1.21875214
#> 19: 92bfddff-4d82-4595-b1c5-693e7af44110  -5.3691761 -0.01495275
#> 20: 3c297215-8a43-487a-b6ea-639c0abf5771  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
