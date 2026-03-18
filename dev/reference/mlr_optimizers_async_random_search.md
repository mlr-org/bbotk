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
#>  1: finished  7.0005899  0.64849173  -28.317391 2026-03-18 14:00:49
#>  2: finished -4.7273068  1.55118543  -55.969945 2026-03-18 14:00:49
#>  3: finished -8.3142357 -0.84808989 -101.014174 2026-03-18 14:00:49
#>  4: finished  7.4495551  2.57767647  -50.808126 2026-03-18 14:00:49
#>  5: finished  7.5065666  1.81294693  -43.486734 2026-03-18 14:00:49
#>  6: finished -9.8478251 -2.69770124 -130.462345 2026-03-18 14:00:49
#>  7: finished  0.3870992  2.09953629  -18.606719 2026-03-18 14:00:49
#>  8: finished  9.1887166  1.95032306  -66.183344 2026-03-18 14:00:49
#>  9: finished -6.7320590 -4.50562770  -68.515769 2026-03-18 14:00:49
#> 10: finished  0.9955564 -3.63495767    8.587922 2026-03-18 14:00:49
#> 11: finished  1.9339031  3.60780233  -33.667420 2026-03-18 14:00:49
#> 12: finished -3.6334861 -0.37274046  -28.638658 2026-03-18 14:00:49
#> 13: finished -1.3406191 -2.02690225   -2.106655 2026-03-18 14:00:49
#> 14: finished -5.8805572 -2.81415540  -52.137720 2026-03-18 14:00:49
#> 15: finished  6.5360563  4.77872294  -71.084338 2026-03-18 14:00:49
#> 16: finished -4.5197170 -2.02682984  -33.453771 2026-03-18 14:00:49
#> 17: finished  5.3688411  1.11764111  -18.304059 2026-03-18 14:00:49
#> 18: finished  2.5665792 -1.21875214    6.506144 2026-03-18 14:00:49
#> 19: finished -5.3691761 -0.01495275  -53.215263 2026-03-18 14:00:49
#> 20: finished -6.3526726  1.61537696  -81.068844 2026-03-18 14:00:49
#>        state         x1          x2           y        timestamp_xs
#>       <char>      <num>       <num>       <num>              <POSc>
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>  1: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  2: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  3: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  4: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  5: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  6: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  7: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  8: narrow_xinjiangovenator 2026-03-18 14:00:49
#>  9: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 10: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 11: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 12: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 13: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 14: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 15: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 16: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 17: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 18: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 19: narrow_xinjiangovenator 2026-03-18 14:00:49
#> 20: narrow_xinjiangovenator 2026-03-18 14:00:49
#>                   worker_id        timestamp_ys
#>                      <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: e275da45-b3fb-4297-a891-e312bf71b103   7.0005899  0.64849173
#>  2: 1ec0efde-a91a-4e29-8c89-1bad7d5c651d  -4.7273068  1.55118543
#>  3: f3ae6614-d433-43e3-ba37-5b06b7278451  -8.3142357 -0.84808989
#>  4: c55c57f0-e62d-4d26-af4a-d828a144573b   7.4495551  2.57767647
#>  5: c6319958-b123-4be2-be7f-06b0f68a9aec   7.5065666  1.81294693
#>  6: ff56b093-e7b9-455e-b1bd-7f744f653a00  -9.8478251 -2.69770124
#>  7: 72d51c9a-6cb7-4ef9-8c70-9c7ab0018a8f   0.3870992  2.09953629
#>  8: 07acb8c9-526b-4dc8-8e98-5006b3bf9442   9.1887166  1.95032306
#>  9: d8687b55-5e5e-40da-9226-d8128c227be5  -6.7320590 -4.50562770
#> 10: 0c119239-b4d4-45fe-86d2-15d9ce1808de   0.9955564 -3.63495767
#> 11: c1729815-8f7f-476d-86bb-e9f3598863de   1.9339031  3.60780233
#> 12: 9aa04f84-3c0e-4bbe-ab5b-906a28afc7b2  -3.6334861 -0.37274046
#> 13: cc96757a-8711-4e9f-9af2-71df37e9ac96  -1.3406191 -2.02690225
#> 14: 443ec801-e9c6-46b7-ab22-b659b5bdd729  -5.8805572 -2.81415540
#> 15: 5c1e288d-bcbf-40b9-9e19-2f1a90bb847c   6.5360563  4.77872294
#> 16: 26cdafc7-b82d-4b7c-9f58-4ab6a29eba1b  -4.5197170 -2.02682984
#> 17: 2d8e0629-5567-4321-84a6-8fde118bd5e6   5.3688411  1.11764111
#> 18: cf5c0fc3-20f8-44d7-9c20-28576eaf7b70   2.5665792 -1.21875214
#> 19: 7d4aacc9-9896-46c5-995b-6f55d79ea51b  -5.3691761 -0.01495275
#> 20: 38598e1f-d039-4ab0-a34b-61100fee2697  -6.3526726  1.61537696
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
