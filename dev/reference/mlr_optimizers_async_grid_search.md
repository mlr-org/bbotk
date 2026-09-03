# Asynchronous Optimization via Grid Search

`OptimizerAsyncGridSearch` class that implements a grid search. The grid
is constructed as a Cartesian product over discretized values per
parameter, see
[`paradox::generate_design_grid()`](https://paradox.mlr-org.com/reference/generate_design_grid.html).
The points of the grid are evaluated in a random order.

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

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncGridSearch$new()

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$optimize()`

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncGridSearch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncGridSearch$clone(deep = FALSE)

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
optimizer = opt("async_grid_search", resolution = 10)

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 11:46:03
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 11:46:03
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 11:46:03
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 11:46:03
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 11:46:03
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 11:46:03
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 11:46:03
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 11:46:03
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 11:46:03
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 11:46:03
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 11:46:03
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 11:46:03
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 11:46:03
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 11:46:03
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 11:46:03
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 11:46:03
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 11:46:03
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 11:46:03
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 11:46:03
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 11:46:03
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 11:46:03
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 11:46:03
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 11:46:03
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 11:46:03
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 11:46:03
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 11:46:03
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 11:46:03
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 11:46:03
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 11:46:03
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 11:46:03
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 11:46:03
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 11:46:03
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 11:46:03
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 11:46:03
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 11:46:03
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 11:46:03
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 11:46:03
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 11:46:03
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 11:46:03
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 11:46:03
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 11:46:03
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 11:46:03
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 11:46:03
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 11:46:03
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 11:46:03
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 11:46:03
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 11:46:03
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 11:46:03
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 11:46:03
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 11:46:03
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 11:46:03
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 11:46:03
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 11:46:03
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 11:46:03
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 11:46:03
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 11:46:03
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 11:46:03
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 11:46:03
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 11:46:03
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 11:46:03
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 11:46:03
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 11:46:03
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 11:46:03
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 11:46:03
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 11:46:03
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 11:46:03
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 11:46:03
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 11:46:03
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 11:46:03
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 11:46:03
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 11:46:03
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 11:46:03
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 11:46:03
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 11:46:03
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 11:46:03
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 11:46:03
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 11:46:03
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 11:46:03
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 11:46:03
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 11:46:03
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 11:46:03
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 11:46:03
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 11:46:03
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 11:46:03
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 11:46:03
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 11:46:03
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 11:46:03
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 11:46:03
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 11:46:03
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 11:46:03
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 11:46:03
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 11:46:03
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 11:46:03
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 11:46:03
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 11:46:03
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 11:46:03
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 11:46:03
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 11:46:03
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 11:46:03
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 11:46:03
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   2: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   3: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   4: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   5: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   6: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   7: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   8: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>   9: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  10: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  11: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  12: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  13: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  14: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  15: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  16: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  17: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  18: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  19: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  20: sinking_raccoon_ee2dcbeb 2026-09-03 11:46:04
#>  21:                     <NA>                <NA>
#>  22:                     <NA>                <NA>
#>  23:                     <NA>                <NA>
#>  24:                     <NA>                <NA>
#>  25:                     <NA>                <NA>
#>  26:                     <NA>                <NA>
#>  27:                     <NA>                <NA>
#>  28:                     <NA>                <NA>
#>  29:                     <NA>                <NA>
#>  30:                     <NA>                <NA>
#>  31:                     <NA>                <NA>
#>  32:                     <NA>                <NA>
#>  33:                     <NA>                <NA>
#>  34:                     <NA>                <NA>
#>  35:                     <NA>                <NA>
#>  36:                     <NA>                <NA>
#>  37:                     <NA>                <NA>
#>  38:                     <NA>                <NA>
#>  39:                     <NA>                <NA>
#>  40:                     <NA>                <NA>
#>  41:                     <NA>                <NA>
#>  42:                     <NA>                <NA>
#>  43:                     <NA>                <NA>
#>  44:                     <NA>                <NA>
#>  45:                     <NA>                <NA>
#>  46:                     <NA>                <NA>
#>  47:                     <NA>                <NA>
#>  48:                     <NA>                <NA>
#>  49:                     <NA>                <NA>
#>  50:                     <NA>                <NA>
#>  51:                     <NA>                <NA>
#>  52:                     <NA>                <NA>
#>  53:                     <NA>                <NA>
#>  54:                     <NA>                <NA>
#>  55:                     <NA>                <NA>
#>  56:                     <NA>                <NA>
#>  57:                     <NA>                <NA>
#>  58:                     <NA>                <NA>
#>  59:                     <NA>                <NA>
#>  60:                     <NA>                <NA>
#>  61:                     <NA>                <NA>
#>  62:                     <NA>                <NA>
#>  63:                     <NA>                <NA>
#>  64:                     <NA>                <NA>
#>  65:                     <NA>                <NA>
#>  66:                     <NA>                <NA>
#>  67:                     <NA>                <NA>
#>  68:                     <NA>                <NA>
#>  69:                     <NA>                <NA>
#>  70:                     <NA>                <NA>
#>  71:                     <NA>                <NA>
#>  72:                     <NA>                <NA>
#>  73:                     <NA>                <NA>
#>  74:                     <NA>                <NA>
#>  75:                     <NA>                <NA>
#>  76:                     <NA>                <NA>
#>  77:                     <NA>                <NA>
#>  78:                     <NA>                <NA>
#>  79:                     <NA>                <NA>
#>  80:                     <NA>                <NA>
#>  81:                     <NA>                <NA>
#>  82:                     <NA>                <NA>
#>  83:                     <NA>                <NA>
#>  84:                     <NA>                <NA>
#>  85:                     <NA>                <NA>
#>  86:                     <NA>                <NA>
#>  87:                     <NA>                <NA>
#>  88:                     <NA>                <NA>
#>  89:                     <NA>                <NA>
#>  90:                     <NA>                <NA>
#>  91:                     <NA>                <NA>
#>  92:                     <NA>                <NA>
#>  93:                     <NA>                <NA>
#>  94:                     <NA>                <NA>
#>  95:                     <NA>                <NA>
#>  96:                     <NA>                <NA>
#>  97:                     <NA>                <NA>
#>  98:                     <NA>                <NA>
#>  99:                     <NA>                <NA>
#> 100:                     <NA>                <NA>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
#>   1: 5eeef8e9-40c2-43c3-b3e7-f1efa6e036f1    [NULL]  -10.000000  -5.0000000
#>   2: 507ac6f6-4146-4622-87d1-e7b69a58654f    [NULL]  -10.000000  -3.8888889
#>   3: 21d37ac4-6209-416d-83d4-5280aeb0c73a    [NULL]  -10.000000  -2.7777778
#>   4: 91e192d9-af79-43dc-9509-bee81e61568d    [NULL]  -10.000000  -1.6666667
#>   5: 1585c8cf-42ba-466f-ba8f-5ad012e52f0f    [NULL]  -10.000000  -0.5555556
#>   6: 190da9ac-e431-4ce9-83ac-c5131a03bbef    [NULL]  -10.000000   0.5555556
#>   7: 3c4032be-646b-44bf-b524-75626ceeee2e    [NULL]  -10.000000   1.6666667
#>   8: 0a332f4f-cde5-470d-8f01-21c151317dca    [NULL]  -10.000000   2.7777778
#>   9: 2061d759-23c9-484a-b793-6a2067d7823d    [NULL]  -10.000000   3.8888889
#>  10: 96549adb-905f-41a5-be10-240aac952624    [NULL]  -10.000000   5.0000000
#>  11: 012a5e9a-b590-4b1c-b52f-55a865f665f6    [NULL]   -7.777778  -5.0000000
#>  12: 58a368bc-5d77-4ee9-958f-298d3c3c1a8b    [NULL]   -7.777778  -3.8888889
#>  13: b5e7e7c3-635f-48a7-85b2-fd5dca26176d    [NULL]   -7.777778  -2.7777778
#>  14: 417dd111-06fe-4796-b2f7-789d2647a60c    [NULL]   -7.777778  -1.6666667
#>  15: b743bf00-8c96-49ec-9a2c-0b73f85523c8    [NULL]   -7.777778  -0.5555556
#>  16: e20e6ff0-91c6-4591-951a-445fd0fa022e    [NULL]   -7.777778   0.5555556
#>  17: 494ea7a0-ed6d-49d1-9bcf-edca5e0a0520    [NULL]   -7.777778   1.6666667
#>  18: f18408ed-afd2-4fbb-9b94-f6e2df1e5c29    [NULL]   -7.777778   2.7777778
#>  19: fcf61ce6-5e13-4d35-ad7a-2ddb6f39208e    [NULL]   -7.777778   3.8888889
#>  20: 53db9fbf-1c5e-4185-91c9-41f82524db8f    [NULL]   -7.777778   5.0000000
#>  21: f7d6cdda-45a1-4926-8d72-797fe556cb57 <list[1]>          NA          NA
#>  22: 5d10e0de-61c5-403b-a39b-983e5fc1bdd8 <list[1]>          NA          NA
#>  23: 4585a879-0c0c-4b8f-92ed-0a5de4f8fb5a <list[1]>          NA          NA
#>  24: 8572e9ca-b78b-42a9-9a66-ab86bcccbd9f <list[1]>          NA          NA
#>  25: b4814294-0673-4409-bdc4-551c8799b4a8 <list[1]>          NA          NA
#>  26: cf4ca634-ad1d-4168-a413-99749352d852 <list[1]>          NA          NA
#>  27: 7b7a1f76-ee8f-4e32-8289-8dfedd653fbd <list[1]>          NA          NA
#>  28: fb712515-8b42-4530-8840-686fabcd8f3a <list[1]>          NA          NA
#>  29: 5b3e654e-ea1f-4604-b723-1c537e57dc86 <list[1]>          NA          NA
#>  30: 245814c6-bd51-45e7-9a2f-4e8dcdbf5be1 <list[1]>          NA          NA
#>  31: 89022593-a7c9-41dc-97f9-f02385577583 <list[1]>          NA          NA
#>  32: 376a2994-1c1f-427b-a433-1929c07b92cf <list[1]>          NA          NA
#>  33: db752bfb-5cbf-4bf2-a5eb-7e2ed3c28a37 <list[1]>          NA          NA
#>  34: ef24b72a-cbae-4bc2-8f3e-900737a2b1d9 <list[1]>          NA          NA
#>  35: 2aab0eb2-e440-408c-889b-05211fb1e2ab <list[1]>          NA          NA
#>  36: 152b3847-15bb-4f31-8362-23ef382ceb2b <list[1]>          NA          NA
#>  37: 3dcdacee-8117-4111-b1f3-0b16ad256139 <list[1]>          NA          NA
#>  38: 592cdfef-399c-44f2-910b-13f05fdfee2b <list[1]>          NA          NA
#>  39: eae84ebd-1849-4193-b69b-723c9b29d4ff <list[1]>          NA          NA
#>  40: 648f684d-c08d-466e-aa74-6a4f99b55c08 <list[1]>          NA          NA
#>  41: 5e885774-136c-4fb5-9c8a-f2d14c88c234 <list[1]>          NA          NA
#>  42: bb3ad568-a087-412a-83d7-ac44298af2d3 <list[1]>          NA          NA
#>  43: 974dd51d-a78e-4bb1-b094-2fed166f2bcb <list[1]>          NA          NA
#>  44: 41fc58b2-c72a-4a64-ab9e-46c5cfeead74 <list[1]>          NA          NA
#>  45: f043ccb1-31e9-4fa7-8f34-3693c23467bc <list[1]>          NA          NA
#>  46: d7e60de3-0c06-467f-9013-62542dd1e2d7 <list[1]>          NA          NA
#>  47: 552f9358-5137-4138-bd26-9903f33f449c <list[1]>          NA          NA
#>  48: 6d6cfff0-260d-411c-a48a-705d5493aece <list[1]>          NA          NA
#>  49: 1f5c237b-d148-458c-a36b-cf1dd4873577 <list[1]>          NA          NA
#>  50: ef734c41-98fb-44b0-95ea-052f8c2699ad <list[1]>          NA          NA
#>  51: 0a875b34-5fcf-46ef-bcdb-e44cdc0f223d <list[1]>          NA          NA
#>  52: 3ccfc3da-0773-403d-8e65-19cb1f9ca8db <list[1]>          NA          NA
#>  53: 812ce1a8-0d60-4a1c-9b4a-a669fd169ef4 <list[1]>          NA          NA
#>  54: 08e49a89-1d05-4748-b4cc-50c3281dbd1f <list[1]>          NA          NA
#>  55: 5ad520cd-d1ec-4538-adbe-0e774627ca9d <list[1]>          NA          NA
#>  56: cd194877-45de-4b69-b446-322a46d64e9d <list[1]>          NA          NA
#>  57: 5bc61e7f-f8f1-4086-9a37-7941f60ed6ad <list[1]>          NA          NA
#>  58: e5b18eae-11d1-4eee-9c6c-06ceaa26e8da <list[1]>          NA          NA
#>  59: f5f1472c-0dc4-4e9d-91cb-5b808dc0b28d <list[1]>          NA          NA
#>  60: 737edbaf-42d9-4204-a0c3-556c65e38a72 <list[1]>          NA          NA
#>  61: e4d4a91e-81a5-4943-b3a3-61ef3df7d1e3 <list[1]>          NA          NA
#>  62: 96ab46dc-5f6e-46ec-9968-ca299bbd9ff3 <list[1]>          NA          NA
#>  63: 30228b84-aaad-48df-8f25-87b572a325a0 <list[1]>          NA          NA
#>  64: b0dfc2c4-1ea8-45a8-bb84-9d5abc8470f0 <list[1]>          NA          NA
#>  65: 9d15c6cf-107b-4039-9892-2175d699a287 <list[1]>          NA          NA
#>  66: e81d0d8b-6438-4c83-937a-3a02b454bfe2 <list[1]>          NA          NA
#>  67: bc97b18e-26f5-4fd0-9240-5349124edb79 <list[1]>          NA          NA
#>  68: 962ed386-8da7-4204-a563-e9fcf8f1f834 <list[1]>          NA          NA
#>  69: 07e2bd41-a669-419e-b456-e11e3ccf3d26 <list[1]>          NA          NA
#>  70: b51edb5d-6b4e-4e70-8611-77672cb65034 <list[1]>          NA          NA
#>  71: 79b3dc8a-6969-4914-94f5-8011a0092d30 <list[1]>          NA          NA
#>  72: 77426acf-7d0d-441b-b274-a8ad7dc66372 <list[1]>          NA          NA
#>  73: ee3da0c7-188e-4403-9b0a-cbbc099fd3a2 <list[1]>          NA          NA
#>  74: 45908cb7-5274-4f4d-b27b-645af9f09cd8 <list[1]>          NA          NA
#>  75: 672d2816-d768-415d-b008-a73668d7af53 <list[1]>          NA          NA
#>  76: 08d573b1-03fe-47af-87e0-f726adeafbf8 <list[1]>          NA          NA
#>  77: 99bd3eaa-d9d9-4c26-934c-438e282c1f9e <list[1]>          NA          NA
#>  78: fb581df5-835d-47e0-9fad-fdd708598e6a <list[1]>          NA          NA
#>  79: e9364874-95e0-49df-8320-3ef2164dea71 <list[1]>          NA          NA
#>  80: 123ba98d-5930-4026-aecb-e40bc2cee67d <list[1]>          NA          NA
#>  81: 25e64a06-d9c4-4273-9abf-a58b725d7347 <list[1]>          NA          NA
#>  82: dc11e31a-40fd-49bf-b073-f13828fb036d <list[1]>          NA          NA
#>  83: 4f973250-419d-4903-aceb-a5840d5e8b8a <list[1]>          NA          NA
#>  84: b3e3a5c1-b8c4-4ed4-aeee-8fbe1fbc7676 <list[1]>          NA          NA
#>  85: 6f177195-edd8-445e-9dbe-b1669d4953e5 <list[1]>          NA          NA
#>  86: 86f7caf8-5848-45f1-a3b2-39be7bd256d3 <list[1]>          NA          NA
#>  87: 74197728-1b39-432f-8278-9e6927b761c2 <list[1]>          NA          NA
#>  88: 8ce6b7f9-3f1c-4c0d-8216-4acc539c8eb4 <list[1]>          NA          NA
#>  89: b118d93f-0059-4321-95ef-2994ee3028f3 <list[1]>          NA          NA
#>  90: 66d3e2db-d8d7-4b0e-8fb8-d08efd396202 <list[1]>          NA          NA
#>  91: 212a6387-97f4-41af-9aba-c077d3244580 <list[1]>          NA          NA
#>  92: ef4b1c74-2ac0-4ac2-aaa2-27c74b2b4a49 <list[1]>          NA          NA
#>  93: 10046690-7a78-4ab2-b9f0-db3c248daad9 <list[1]>          NA          NA
#>  94: 18b3e6d1-a289-48e1-b584-e054120e639f <list[1]>          NA          NA
#>  95: 893e9095-3ff2-437b-a5ca-21de74b9950a <list[1]>          NA          NA
#>  96: ac770214-6c89-4ce8-a7c9-91a79851033f <list[1]>          NA          NA
#>  97: e2b245f7-a32c-4a9a-a187-292fa43f63c4 <list[1]>          NA          NA
#>  98: 1f3132ea-8328-4da4-a33b-b2ec53ed2ec1 <list[1]>          NA          NA
#>  99: bb366a58-a464-45e7-b294-8078a8bfe773 <list[1]>          NA          NA
#> 100: 390cc77e-f099-4de1-af09-8d57e513c331 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
