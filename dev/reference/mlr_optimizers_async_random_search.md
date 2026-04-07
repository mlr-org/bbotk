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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-04-07 07:11:16
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-04-07 07:11:16
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-04-07 07:11:16
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-04-07 07:11:16
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-04-07 07:11:16
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-04-07 07:11:16
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-04-07 07:11:16
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-04-07 07:11:16
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-04-07 07:11:16
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-04-07 07:11:16
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-04-07 07:11:16
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-04-07 07:11:16
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-04-07 07:11:16
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-04-07 07:11:16
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-04-07 07:11:16
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-04-07 07:11:16
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-04-07 07:11:16
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-04-07 07:11:16
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-04-07 07:11:16
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-04-07 07:11:16
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  2: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  3: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  4: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  5: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  6: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  7: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  8: narrow_xinjiangovenator 2026-04-07 07:11:16
#>  9: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 10: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 11: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 12: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 13: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 14: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 15: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 16: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 17: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 18: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 19: narrow_xinjiangovenator 2026-04-07 07:11:16
#> 20: narrow_xinjiangovenator 2026-04-07 07:11:16
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: f95b4231-5fba-46fa-966a-1c3091c77012   7.0005899  0.64849173
#>  2: c51cbe91-4811-4e46-9acb-2a68df8f5589  -4.7273068  1.55118543
#>  3: 39c21c1e-5f3c-4445-9ff7-e22c5852112f  -8.3142357 -0.84808989
#>  4: f21c463b-8a3a-44a7-bdcd-f9b47203e95c   7.4495551  2.57767647
#>  5: ccfe8be9-62e9-4644-a413-8f6ea45bd3e3   7.5065666  1.81294693
#>  6: 37cac454-e465-43aa-978c-97902d402f1e  -9.8478251 -2.69770124
#>  7: fa8b7630-b2f4-4d96-8967-6ff0e9249963   0.3870992  2.09953629
#>  8: c162cd60-b129-4b95-9ea3-fc4fe6fbba62   9.1887166  1.95032306
#>  9: 96b607c1-2218-4d6b-b337-0640d1f146cc  -6.7320590 -4.50562770
#> 10: 8c7a35f5-afd5-43d5-9fbf-9eedc27d7b18   0.9955564 -3.63495767
#> 11: c81a8125-3cfb-44a2-b054-a5902ff39e27   1.9339031  3.60780233
#> 12: d9950b45-be6d-4916-ac91-7d7aab19c085  -3.6334861 -0.37274046
#> 13: 8ec2f39b-a203-45b4-9d3c-c8e743a69c73  -1.3406191 -2.02690225
#> 14: a11b808a-0359-42a6-8ffe-2fa8f76d044f  -5.8805572 -2.81415540
#> 15: c52a8434-c3c0-4ae5-85c9-ad612ac2ba74   6.5360563  4.77872294
#> 16: 99be6543-8c6b-4783-bd57-66bbf76e2f92  -4.5197170 -2.02682984
#> 17: e8d81272-baf7-43eb-b73c-80658a9086f0   5.3688411  1.11764111
#> 18: c8e048ef-2037-456b-ac0d-ca46d3889417   2.5665792 -1.21875214
#> 19: bd1c3471-75f4-4167-a126-8f30427fbff0  -5.3691761 -0.01495275
#> 20: 52711e02-10a7-4811-8bb9-1813b8551709  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
