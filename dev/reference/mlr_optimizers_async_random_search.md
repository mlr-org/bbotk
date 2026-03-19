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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-19 10:30:35
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-19 10:30:35
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-19 10:30:35
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-19 10:30:35
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-19 10:30:35
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-19 10:30:35
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-19 10:30:35
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-19 10:30:35
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-19 10:30:35
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-19 10:30:35
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-19 10:30:35
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-19 10:30:35
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-19 10:30:35
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-19 10:30:35
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-19 10:30:35
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-19 10:30:35
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-19 10:30:35
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-19 10:30:35
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-19 10:30:35
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-19 10:30:35
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  2: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  3: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  4: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  5: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  6: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  7: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  8: narrow_xinjiangovenator 2026-03-19 10:30:35
#>  9: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 10: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 11: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 12: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 13: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 14: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 15: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 16: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 17: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 18: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 19: narrow_xinjiangovenator 2026-03-19 10:30:35
#> 20: narrow_xinjiangovenator 2026-03-19 10:30:35
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 462c892c-7bc0-4d3b-834a-a75128941b7a   7.0005899  0.64849173
#>  2: 23f93b59-9b2e-41d5-9291-2151d17a22c4  -4.7273068  1.55118543
#>  3: 129ea01b-9935-47f5-b511-45ef9ba1c158  -8.3142357 -0.84808989
#>  4: 79054d56-9f52-44fd-a62a-f84578e58aa1   7.4495551  2.57767647
#>  5: 524f42fb-6e4d-4fa7-940b-b73bc0318516   7.5065666  1.81294693
#>  6: 9b681645-9368-4f83-a7aa-fe105092632b  -9.8478251 -2.69770124
#>  7: c1169118-7063-4c66-b022-b98f6b3f99b0   0.3870992  2.09953629
#>  8: ce39d91a-ff3d-49c7-932f-aacd9febcda0   9.1887166  1.95032306
#>  9: 20e9bef8-10ec-4478-a5c4-7b4e7847f297  -6.7320590 -4.50562770
#> 10: 1642ecfb-e961-4c97-b93f-19cc14b09679   0.9955564 -3.63495767
#> 11: ee761b64-e407-40bb-987e-e621dc7b7a75   1.9339031  3.60780233
#> 12: 13cfad26-76be-4429-8d22-5c3d99a913eb  -3.6334861 -0.37274046
#> 13: 5cf0c4c0-ce9b-4cc7-aeaa-e33688a3c2e8  -1.3406191 -2.02690225
#> 14: 45fd09e8-4ad0-4d73-aeea-c0eb611c0295  -5.8805572 -2.81415540
#> 15: c306b934-11ac-44f5-bdda-10b4671c69be   6.5360563  4.77872294
#> 16: f968b183-c5c5-49ad-9f92-06975ae15267  -4.5197170 -2.02682984
#> 17: bf1e713f-8b46-4400-ba5c-bdba82dd5869   5.3688411  1.11764111
#> 18: 55f228a3-d18a-4b64-8881-99691e848198   2.5665792 -1.21875214
#> 19: 3fb98baf-bca7-4544-a5b9-85f0bc95c2a8  -5.3691761 -0.01495275
#> 20: 47f93d63-5177-41b8-8424-3234a3293255  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
