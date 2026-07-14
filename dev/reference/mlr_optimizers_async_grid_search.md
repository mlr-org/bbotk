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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-14 10:25:18
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-14 10:25:18
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-14 10:25:18
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-14 10:25:18
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-14 10:25:18
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-14 10:25:18
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-14 10:25:18
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-14 10:25:18
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-14 10:25:18
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-14 10:25:18
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-14 10:25:18
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-14 10:25:18
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-14 10:25:18
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-14 10:25:18
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-14 10:25:18
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-14 10:25:18
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-14 10:25:18
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-14 10:25:18
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-14 10:25:18
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-14 10:25:18
#>  21:   failed  10.000000  5.0000000         NA 2026-07-14 10:25:18
#>  22:   failed  10.000000  3.8888889         NA 2026-07-14 10:25:18
#>  23:   failed  10.000000  2.7777778         NA 2026-07-14 10:25:18
#>  24:   failed  10.000000  1.6666667         NA 2026-07-14 10:25:18
#>  25:   failed  10.000000  0.5555556         NA 2026-07-14 10:25:18
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-14 10:25:18
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-14 10:25:18
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-14 10:25:18
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-14 10:25:18
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-14 10:25:18
#>  31:   failed   7.777778  5.0000000         NA 2026-07-14 10:25:18
#>  32:   failed   7.777778  3.8888889         NA 2026-07-14 10:25:18
#>  33:   failed   7.777778  2.7777778         NA 2026-07-14 10:25:18
#>  34:   failed   7.777778  1.6666667         NA 2026-07-14 10:25:18
#>  35:   failed   7.777778  0.5555556         NA 2026-07-14 10:25:18
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-14 10:25:18
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-14 10:25:18
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-14 10:25:18
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-14 10:25:18
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-14 10:25:18
#>  41:   failed   5.555556  5.0000000         NA 2026-07-14 10:25:18
#>  42:   failed   5.555556  3.8888889         NA 2026-07-14 10:25:18
#>  43:   failed   5.555556  2.7777778         NA 2026-07-14 10:25:18
#>  44:   failed   5.555556  1.6666667         NA 2026-07-14 10:25:18
#>  45:   failed   5.555556  0.5555556         NA 2026-07-14 10:25:18
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-14 10:25:18
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-14 10:25:18
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-14 10:25:18
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-14 10:25:18
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-14 10:25:18
#>  51:   failed   3.333333  5.0000000         NA 2026-07-14 10:25:18
#>  52:   failed   3.333333  3.8888889         NA 2026-07-14 10:25:18
#>  53:   failed   3.333333  2.7777778         NA 2026-07-14 10:25:18
#>  54:   failed   3.333333  1.6666667         NA 2026-07-14 10:25:18
#>  55:   failed   3.333333  0.5555556         NA 2026-07-14 10:25:18
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-14 10:25:18
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-14 10:25:18
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-14 10:25:18
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-14 10:25:18
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-14 10:25:18
#>  61:   failed   1.111111  5.0000000         NA 2026-07-14 10:25:18
#>  62:   failed   1.111111  3.8888889         NA 2026-07-14 10:25:18
#>  63:   failed   1.111111  2.7777778         NA 2026-07-14 10:25:18
#>  64:   failed   1.111111  1.6666667         NA 2026-07-14 10:25:18
#>  65:   failed   1.111111  0.5555556         NA 2026-07-14 10:25:18
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-14 10:25:18
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-14 10:25:18
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-14 10:25:18
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-14 10:25:18
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-14 10:25:18
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-14 10:25:18
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-14 10:25:18
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-14 10:25:18
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-14 10:25:18
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-14 10:25:18
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-14 10:25:18
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-14 10:25:18
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-14 10:25:18
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-14 10:25:18
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-14 10:25:18
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-14 10:25:18
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-14 10:25:18
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-14 10:25:18
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-14 10:25:18
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-14 10:25:18
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-14 10:25:18
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-14 10:25:18
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-14 10:25:18
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-14 10:25:18
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-14 10:25:18
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-14 10:25:18
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-14 10:25:18
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-14 10:25:18
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-14 10:25:18
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-14 10:25:18
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-14 10:25:18
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-14 10:25:18
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-14 10:25:18
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-14 10:25:18
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-14 10:25:18
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   2: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   3: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   4: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   5: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   6: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   7: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   8: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>   9: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  10: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  11: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  12: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  13: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  14: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  15: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  16: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  17: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  18: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  19: sinking_raccoon_bc091589 2026-07-14 10:25:19
#>  20: sinking_raccoon_bc091589 2026-07-14 10:25:19
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
#>   1: fe36fbc4-0709-485f-bdc3-08ac28f6fa37    [NULL]  -10.000000  -5.0000000
#>   2: 97900403-a945-4e7f-b5a0-2029351c20de    [NULL]  -10.000000  -3.8888889
#>   3: e5f0ef77-c7b2-4728-89c8-f978c5eed75b    [NULL]  -10.000000  -2.7777778
#>   4: a968c0f9-5114-4493-a991-e2764fc0a0a7    [NULL]  -10.000000  -1.6666667
#>   5: da1d7cd7-3586-4ac9-ba40-4d4ea11d29ab    [NULL]  -10.000000  -0.5555556
#>   6: 74118a2a-b2ba-406b-ae77-3d0af009bf38    [NULL]  -10.000000   0.5555556
#>   7: 9f8f8c22-7e96-4664-9671-b02beed28a3f    [NULL]  -10.000000   1.6666667
#>   8: be749856-03e9-4cd3-b010-1e66ec356e22    [NULL]  -10.000000   2.7777778
#>   9: 377c2e4c-507f-4745-9096-965a9ee7a28a    [NULL]  -10.000000   3.8888889
#>  10: 05a45520-20de-48ab-83c7-fdf6433b9662    [NULL]  -10.000000   5.0000000
#>  11: 0c0e8cc0-820c-4ecc-b834-26698069bfa5    [NULL]   -7.777778  -5.0000000
#>  12: 434c03af-dd74-44c4-8af5-6146ad3933a6    [NULL]   -7.777778  -3.8888889
#>  13: 7c2fabb1-7d14-431a-bef9-be87e46e1e11    [NULL]   -7.777778  -2.7777778
#>  14: d8f519c1-141a-4ffb-811d-d9755520262e    [NULL]   -7.777778  -1.6666667
#>  15: f6f164f8-e2fb-4cda-8025-676fd880e93c    [NULL]   -7.777778  -0.5555556
#>  16: 99b881b5-2c5a-4c76-8baf-ad399b75c095    [NULL]   -7.777778   0.5555556
#>  17: ea9a4e22-a9c5-4dad-88e1-0176f0607903    [NULL]   -7.777778   1.6666667
#>  18: 63c25caa-3d32-48da-9e04-2d6c9ffe298b    [NULL]   -7.777778   2.7777778
#>  19: 29674e7d-2496-4b64-9b07-261eb7edb1c8    [NULL]   -7.777778   3.8888889
#>  20: 2557def6-108d-4ff0-8308-3a71b2b800f4    [NULL]   -7.777778   5.0000000
#>  21: dec62e9f-2a19-4534-9e35-eefd876d6c7a <list[1]>          NA          NA
#>  22: 0f3f588c-881d-4cdc-97a3-e31db45f77be <list[1]>          NA          NA
#>  23: 627d2665-221f-482f-93fc-d6efdeec8bdf <list[1]>          NA          NA
#>  24: 07aab9eb-ea68-4337-8dcb-5ab5b775195b <list[1]>          NA          NA
#>  25: e6210ce2-7e7d-4ba6-905d-3f3e1c5f4aa1 <list[1]>          NA          NA
#>  26: 209376f7-ddc0-4378-a48a-22f4d00f113c <list[1]>          NA          NA
#>  27: 41381ffc-a198-4ebd-bd13-30b63ca058eb <list[1]>          NA          NA
#>  28: a8c82d96-822f-4c51-b3ae-3abd7a14ee13 <list[1]>          NA          NA
#>  29: 512628e3-e686-4bab-bcfa-5a439d8b4d5b <list[1]>          NA          NA
#>  30: 3dd1d49f-6274-413b-b3f5-21db3f1ec7b0 <list[1]>          NA          NA
#>  31: 4dbef9a8-b463-4561-929b-c242c46436f0 <list[1]>          NA          NA
#>  32: 2e0db4d7-4b22-46f7-86ba-2a2b076d32ac <list[1]>          NA          NA
#>  33: 3a6c4726-f15d-485d-a435-423716de59f8 <list[1]>          NA          NA
#>  34: 4cd03df3-c72c-4c73-9733-cc544d9bf3b1 <list[1]>          NA          NA
#>  35: 19904f13-b628-4f23-9cb0-c79c06ee1285 <list[1]>          NA          NA
#>  36: 8559178c-28d3-437f-b819-8bc518364c39 <list[1]>          NA          NA
#>  37: 0d856b50-fd38-462c-9185-dd7063d2d615 <list[1]>          NA          NA
#>  38: 208417c7-c168-4e24-82d3-6fee909d6a92 <list[1]>          NA          NA
#>  39: e1f1d307-0e46-4aeb-94d0-6d439bc5dfbd <list[1]>          NA          NA
#>  40: 8a7f5ac2-a841-4989-81c6-b5f54f8d4a12 <list[1]>          NA          NA
#>  41: 05cfb68a-8411-4760-8e32-f94e9e620c1a <list[1]>          NA          NA
#>  42: d8d97f89-62f7-4b29-a962-0ace911bf0a6 <list[1]>          NA          NA
#>  43: ee46fb15-8308-4487-8c82-a1a59977f646 <list[1]>          NA          NA
#>  44: 3329fb0b-345b-4bfe-aaac-0c2097961479 <list[1]>          NA          NA
#>  45: f959bc2e-6b89-4eb4-b1d2-7520f97aad79 <list[1]>          NA          NA
#>  46: 1b83a6fc-a36b-4108-aa17-35a5877750ba <list[1]>          NA          NA
#>  47: a037ec94-35a7-49e1-99ab-1dd856ac546d <list[1]>          NA          NA
#>  48: d7dfef54-0886-45dd-aaea-8c0f41d2df73 <list[1]>          NA          NA
#>  49: 55dd01f1-eb76-4888-aec7-7a70c3f9762b <list[1]>          NA          NA
#>  50: bf9cc236-ea81-4d31-80f4-8e9a43d1a697 <list[1]>          NA          NA
#>  51: 60cc4179-5d0e-4f7c-91c9-621d52923271 <list[1]>          NA          NA
#>  52: 9cd28188-7388-4a8a-ac07-607a3fd77fdf <list[1]>          NA          NA
#>  53: 810a3678-56a3-48c7-92d1-e3ffba611a7d <list[1]>          NA          NA
#>  54: a47f8c5a-0ec5-4adc-8b7e-ff2b583de8a6 <list[1]>          NA          NA
#>  55: e7de93ca-f21c-4b65-8330-50d460179471 <list[1]>          NA          NA
#>  56: 8b3cf0ac-336d-41b6-b6da-88b712b4ec79 <list[1]>          NA          NA
#>  57: 1dc8bb99-2874-4c8d-abf2-91c394514217 <list[1]>          NA          NA
#>  58: c2b83181-709b-4e89-a8f2-1eb4e3dbb96f <list[1]>          NA          NA
#>  59: e4edc12c-cb9c-4ea0-946b-7fe205331c3f <list[1]>          NA          NA
#>  60: 19583fef-4fd1-457d-8ba3-12cbcc81d4b1 <list[1]>          NA          NA
#>  61: b1acf766-3850-47cb-a7e9-c36f273b1ad0 <list[1]>          NA          NA
#>  62: 4509b2af-beda-4a28-b66b-b634875f1682 <list[1]>          NA          NA
#>  63: cbb494ec-01f9-48ea-97b7-2987fea6e4bb <list[1]>          NA          NA
#>  64: 6f56856a-ed5d-468d-bc36-5b2bc50faf3a <list[1]>          NA          NA
#>  65: a84c0dcf-fa2a-424e-9c67-8129678e1ed2 <list[1]>          NA          NA
#>  66: c4fbf613-b646-4e47-a63a-dec5be953960 <list[1]>          NA          NA
#>  67: 8f4cbb7e-b00e-4da9-9864-a0121915cfd3 <list[1]>          NA          NA
#>  68: 21992d7b-4bd4-4b5a-8856-b1fc56e3eb85 <list[1]>          NA          NA
#>  69: 080b8e44-ecaa-4b32-9f50-095250c2ee14 <list[1]>          NA          NA
#>  70: e1116909-99f9-4931-984d-45378935cf77 <list[1]>          NA          NA
#>  71: befe1249-0df6-457b-8101-12f0aad33ea7 <list[1]>          NA          NA
#>  72: 92495d90-cc19-4376-bb0f-f9e71d7abfe0 <list[1]>          NA          NA
#>  73: c4c13050-ebf6-4620-8c5f-39e11988f948 <list[1]>          NA          NA
#>  74: eb0105fb-7878-40cf-9779-aff89d2cfab4 <list[1]>          NA          NA
#>  75: 593946f3-1577-4b7b-bde1-836d7c48567c <list[1]>          NA          NA
#>  76: 24996543-9853-4f15-a529-24c8009b785b <list[1]>          NA          NA
#>  77: 2f3c81ec-19e2-4bcb-a480-acacf14b8d20 <list[1]>          NA          NA
#>  78: 2c43f5cd-0f47-4167-b369-2430a115f155 <list[1]>          NA          NA
#>  79: e16f4427-94f2-455a-a222-cd032210ef56 <list[1]>          NA          NA
#>  80: dde421aa-7d59-4342-a79c-ef68e3e25f01 <list[1]>          NA          NA
#>  81: 8f43b2a6-0f22-4fd0-96ac-c76c31d2851e <list[1]>          NA          NA
#>  82: 83b0b687-42ce-442f-ac24-1341fadc613b <list[1]>          NA          NA
#>  83: ad67a4d5-e3bb-4fb3-a009-36c98aadf5b9 <list[1]>          NA          NA
#>  84: e727ba16-4e85-49ef-ab7a-fef97819fc56 <list[1]>          NA          NA
#>  85: c794d499-703a-4f0f-bdb7-21cb63012147 <list[1]>          NA          NA
#>  86: 6c0592c0-325e-4f61-b478-e2cb03849989 <list[1]>          NA          NA
#>  87: 63bea90f-0555-4f63-b16d-5049c32d10b5 <list[1]>          NA          NA
#>  88: 597f9fa8-72bb-4636-a283-d53d23030b50 <list[1]>          NA          NA
#>  89: 7bbfa54a-16a9-4935-8440-bc941eb101dd <list[1]>          NA          NA
#>  90: 607cad16-61ba-4f5f-a08a-3b022934aba2 <list[1]>          NA          NA
#>  91: 7d60b860-064f-4907-ba59-f2177756ceff <list[1]>          NA          NA
#>  92: 826f4bd0-99e1-4881-b48a-9cf9705ff307 <list[1]>          NA          NA
#>  93: 6ee7c26f-0152-4228-8a9e-e56f0e14c682 <list[1]>          NA          NA
#>  94: e9da4153-703c-45fc-86dc-babeaa9f0901 <list[1]>          NA          NA
#>  95: 744d2434-e2cd-43d9-b588-8efa5bc2f2f7 <list[1]>          NA          NA
#>  96: c8bafe26-391d-40fa-988f-bfbe39f33676 <list[1]>          NA          NA
#>  97: 945d6a3b-5bbe-4f65-a5c4-24f25f6aaf34 <list[1]>          NA          NA
#>  98: 21afb062-67a4-4c0b-a49a-b82bd4d787ea <list[1]>          NA          NA
#>  99: fab50ed3-75a2-4bbe-b0fd-63fc206c615b <list[1]>          NA          NA
#> 100: e57fbf47-a0c2-4c78-98c1-45127abf9718 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
