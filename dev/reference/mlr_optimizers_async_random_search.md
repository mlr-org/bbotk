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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-20 06:19:27
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-20 06:19:27
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-20 06:19:27
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-20 06:19:27
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-20 06:19:27
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-20 06:19:27
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-20 06:19:27
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-20 06:19:27
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-20 06:19:27
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-20 06:19:27
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-20 06:19:27
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-20 06:19:27
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-20 06:19:27
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-20 06:19:27
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-20 06:19:27
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-20 06:19:27
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-20 06:19:27
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-20 06:19:27
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-20 06:19:27
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-20 06:19:27
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  2: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  3: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  4: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  5: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  6: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  7: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  8: narrow_xinjiangovenator 2026-03-20 06:19:27
#>  9: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 10: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 11: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 12: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 13: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 14: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 15: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 16: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 17: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 18: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 19: narrow_xinjiangovenator 2026-03-20 06:19:27
#> 20: narrow_xinjiangovenator 2026-03-20 06:19:27
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 3048202a-e429-4c3a-b764-9748ca8434ca   7.0005899  0.64849173
#>  2: dd44418d-3f8e-4a52-9e59-ff18d42777a1  -4.7273068  1.55118543
#>  3: 3edda94f-c91e-4e70-9586-23cd37b9678f  -8.3142357 -0.84808989
#>  4: 676e7f79-00fe-4b69-8dd2-6f1f0f5c0bda   7.4495551  2.57767647
#>  5: df2e9f5d-4f1f-414c-a52d-f63546f9940a   7.5065666  1.81294693
#>  6: a88d28c5-ef06-444e-8fe1-d8cf6eecb298  -9.8478251 -2.69770124
#>  7: ce0f4e2a-f5c7-4feb-ad4c-e42f47c06b62   0.3870992  2.09953629
#>  8: 1baf7e61-d787-4ed5-ad3e-7984c926d0a3   9.1887166  1.95032306
#>  9: 27f863e7-576c-470f-8fe9-abff8c24bcba  -6.7320590 -4.50562770
#> 10: ef6d85e0-67d7-4d36-a99a-cfc00daac0d5   0.9955564 -3.63495767
#> 11: 157abefe-4ba4-46a3-897b-67b831673a95   1.9339031  3.60780233
#> 12: ec1423ae-f155-468f-accd-d67eeca58838  -3.6334861 -0.37274046
#> 13: 18a7cb0b-c39b-4d88-a940-6217bb2341d7  -1.3406191 -2.02690225
#> 14: 8f50e45b-75d0-48bb-9d3d-ed9c3525983e  -5.8805572 -2.81415540
#> 15: ec404f6a-f95b-4a10-91d6-ea44dd43530d   6.5360563  4.77872294
#> 16: 341edea7-f3ab-4857-a044-b830fdfefabc  -4.5197170 -2.02682984
#> 17: e6ef4cc3-c3c2-46ac-8478-6d1829efc31d   5.3688411  1.11764111
#> 18: a0f5f365-0d25-44cf-85f8-956e931c1317   2.5665792 -1.21875214
#> 19: 8d307420-40f6-466c-8353-d41ce00702ef  -5.3691761 -0.01495275
#> 20: 4cf9a632-bc83-4e53-ba82-af39aff8e5cf  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
