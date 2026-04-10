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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-10 10:22:05
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-10 10:22:05
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-10 10:22:05
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-10 10:22:05
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-10 10:22:05
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-10 10:22:05
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-10 10:22:05
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-10 10:22:05
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-10 10:22:05
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-10 10:22:05
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-10 10:22:05
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-10 10:22:05
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-10 10:22:05
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-10 10:22:05
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-10 10:22:05
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-10 10:22:06
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-10 10:22:06
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-10 10:22:06
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-10 10:22:06
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-10 10:22:06
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  2: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  3: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  4: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  5: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  6: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  7: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  8: narrow_xinjiangovenator 2026-04-10 10:22:05
#>  9: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 10: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 11: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 12: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 13: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 14: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 15: narrow_xinjiangovenator 2026-04-10 10:22:05
#> 16: narrow_xinjiangovenator 2026-04-10 10:22:06
#> 17: narrow_xinjiangovenator 2026-04-10 10:22:06
#> 18: narrow_xinjiangovenator 2026-04-10 10:22:06
#> 19: narrow_xinjiangovenator 2026-04-10 10:22:06
#> 20: narrow_xinjiangovenator 2026-04-10 10:22:06
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 685c72a6-b17f-4569-a228-6f8cbdcaf46c   7.0005899  0.64849173
#>  2: 283e41b7-fc44-4ae0-8bdf-e3d0968aba24  -4.7273068  1.55118543
#>  3: b576d41d-3ba7-476b-8ffc-cf995a637f00  -8.3142357 -0.84808989
#>  4: 710f23fc-e025-47e9-b3ef-70e2e2c7c737   7.4495551  2.57767647
#>  5: 649149b0-0680-4103-8648-a7d98469dcdb   7.5065666  1.81294693
#>  6: 1f16b745-935e-43fa-9dab-5b84b03a9fa3  -9.8478251 -2.69770124
#>  7: ab495492-b829-49f7-a7a8-2c32c130fb4d   0.3870992  2.09953629
#>  8: 7150a62c-d064-4b03-bccc-d61e4eea096e   9.1887166  1.95032306
#>  9: ee3d2e59-3340-4b19-86f1-211ea28fcd04  -6.7320590 -4.50562770
#> 10: 6ddd188d-213b-4d00-979e-e905b19b6710   0.9955564 -3.63495767
#> 11: f9eea124-3a9d-4907-9416-8560c65ab855   1.9339031  3.60780233
#> 12: be2757c8-3579-47b6-b8f0-ec81091069ba  -3.6334861 -0.37274046
#> 13: 809081fa-4888-4f83-b14f-66c57c36dfe5  -1.3406191 -2.02690225
#> 14: e0f0f970-957a-432c-b191-38b138823438  -5.8805572 -2.81415540
#> 15: d6dc557a-b726-468b-803b-9823e96023bd   6.5360563  4.77872294
#> 16: b7a98bf5-086a-4c4a-bbf4-07c058da949b  -4.5197170 -2.02682984
#> 17: 258c9839-5a26-4c37-b94a-439512d30907   5.3688411  1.11764111
#> 18: 67416912-6c23-45a6-a58f-f7644ee47805   2.5665792 -1.21875214
#> 19: 9f447bfb-0847-4288-b54f-3e982e570e22  -5.3691761 -0.01495275
#> 20: 8cf94bb6-70cf-444b-a8ad-1054adcc7eb0  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
