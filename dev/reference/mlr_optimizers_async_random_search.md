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
#>        state         x1          x2           y        timestamp_xs   pid
#>       <char>      <num>       <num>       <num>              <POSc> <int>
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-09 09:07:17 17138
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-09 09:07:17 17138
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-09 09:07:17 17138
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-09 09:07:17 17138
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-09 09:07:17 17138
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-09 09:07:17 17138
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-09 09:07:17 17138
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-09 09:07:17 17138
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-09 09:07:17 17138
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-09 09:07:17 17138
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-09 09:07:17 17138
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-09 09:07:17 17138
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-09 09:07:17 17138
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-09 09:07:17 17138
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-09 09:07:17 17138
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-09 09:07:17 17138
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-09 09:07:17 17138
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-09 09:07:17 17138
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-09 09:07:17 17138
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-09 09:07:17 17138
#>        state         x1          x2           y        timestamp_xs   pid
#>       <char>      <num>       <num>       <num>              <POSc> <int>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  2: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  3: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  4: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  5: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  6: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  7: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  8: narrow_xinjiangovenator 2026-03-09 09:07:17
#>  9: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 10: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 11: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 12: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 13: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 14: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 15: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 16: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 17: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 18: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 19: narrow_xinjiangovenator 2026-03-09 09:07:17
#> 20: narrow_xinjiangovenator 2026-03-09 09:07:17
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 6484bf34-f99a-42a8-a43a-2bbf9a7354f1   7.0005899  0.64849173
#>  2: ea7a9288-89b1-4e1c-98e3-12f94c097917  -4.7273068  1.55118543
#>  3: 935b3c53-31f5-4fe7-b34f-5e22ff08f8f7  -8.3142357 -0.84808989
#>  4: 0fbb6c5f-499f-4fac-8309-2dd18a761e0d   7.4495551  2.57767647
#>  5: 229f5504-8bd5-42f0-aa49-9c89dbc289d4   7.5065666  1.81294693
#>  6: 8e4349ec-3551-425d-bb91-02170deb8dca  -9.8478251 -2.69770124
#>  7: dae70ec3-0dc5-4ebc-be34-da42aa06f56e   0.3870992  2.09953629
#>  8: 245f9d4f-d7cc-4329-b1ab-10300ac0fcd7   9.1887166  1.95032306
#>  9: 84bc82ef-7bdf-4c73-8bdb-86af7f6c8314  -6.7320590 -4.50562770
#> 10: a0cbe9ba-51f3-4f13-9659-c0183700d999   0.9955564 -3.63495767
#> 11: 4d3d9855-0196-4a0a-bc55-3fa45b73a70b   1.9339031  3.60780233
#> 12: 0dfa8e78-3ea8-47f1-88a6-94b5cbc90abf  -3.6334861 -0.37274046
#> 13: 9cfeb2df-bde8-4a11-a294-aadea670ee91  -1.3406191 -2.02690225
#> 14: 8716ec83-0838-4baf-9e95-4e4dae4b4d0e  -5.8805572 -2.81415540
#> 15: 58c6b6ae-8340-47d8-8003-3d7092103c83   6.5360563  4.77872294
#> 16: cdca479d-73ad-4657-8bc7-2af0a94ae4ef  -4.5197170 -2.02682984
#> 17: 0041cd96-bdcb-4784-9fec-3862bf566cf8   5.3688411  1.11764111
#> 18: 1cd458fd-7259-4761-81a1-51fe543b58f6   2.5665792 -1.21875214
#> 19: 8196a61c-3177-446b-a249-b702799a172a  -5.3691761 -0.01495275
#> 20: b58aa360-ea7e-4421-8571-ea473b092c7a  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
