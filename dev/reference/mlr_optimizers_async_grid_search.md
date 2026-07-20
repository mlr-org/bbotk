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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-20 08:47:20
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-20 08:47:20
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-20 08:47:20
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-20 08:47:20
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-20 08:47:20
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-20 08:47:20
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-20 08:47:20
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-20 08:47:20
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-20 08:47:20
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-20 08:47:20
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-20 08:47:20
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-20 08:47:20
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-20 08:47:20
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-20 08:47:20
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-20 08:47:20
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-20 08:47:20
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-20 08:47:20
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-20 08:47:20
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-20 08:47:20
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-20 08:47:20
#>  21:   failed  10.000000  5.0000000         NA 2026-07-20 08:47:20
#>  22:   failed  10.000000  3.8888889         NA 2026-07-20 08:47:20
#>  23:   failed  10.000000  2.7777778         NA 2026-07-20 08:47:20
#>  24:   failed  10.000000  1.6666667         NA 2026-07-20 08:47:20
#>  25:   failed  10.000000  0.5555556         NA 2026-07-20 08:47:20
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-20 08:47:20
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-20 08:47:20
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-20 08:47:20
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-20 08:47:20
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-20 08:47:20
#>  31:   failed   7.777778  5.0000000         NA 2026-07-20 08:47:20
#>  32:   failed   7.777778  3.8888889         NA 2026-07-20 08:47:20
#>  33:   failed   7.777778  2.7777778         NA 2026-07-20 08:47:20
#>  34:   failed   7.777778  1.6666667         NA 2026-07-20 08:47:20
#>  35:   failed   7.777778  0.5555556         NA 2026-07-20 08:47:20
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-20 08:47:20
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-20 08:47:20
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-20 08:47:20
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-20 08:47:20
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-20 08:47:20
#>  41:   failed   5.555556  5.0000000         NA 2026-07-20 08:47:20
#>  42:   failed   5.555556  3.8888889         NA 2026-07-20 08:47:20
#>  43:   failed   5.555556  2.7777778         NA 2026-07-20 08:47:20
#>  44:   failed   5.555556  1.6666667         NA 2026-07-20 08:47:20
#>  45:   failed   5.555556  0.5555556         NA 2026-07-20 08:47:20
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-20 08:47:20
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-20 08:47:20
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-20 08:47:20
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-20 08:47:20
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-20 08:47:20
#>  51:   failed   3.333333  5.0000000         NA 2026-07-20 08:47:20
#>  52:   failed   3.333333  3.8888889         NA 2026-07-20 08:47:20
#>  53:   failed   3.333333  2.7777778         NA 2026-07-20 08:47:20
#>  54:   failed   3.333333  1.6666667         NA 2026-07-20 08:47:20
#>  55:   failed   3.333333  0.5555556         NA 2026-07-20 08:47:20
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-20 08:47:20
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-20 08:47:20
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-20 08:47:20
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-20 08:47:20
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-20 08:47:20
#>  61:   failed   1.111111  5.0000000         NA 2026-07-20 08:47:20
#>  62:   failed   1.111111  3.8888889         NA 2026-07-20 08:47:20
#>  63:   failed   1.111111  2.7777778         NA 2026-07-20 08:47:20
#>  64:   failed   1.111111  1.6666667         NA 2026-07-20 08:47:20
#>  65:   failed   1.111111  0.5555556         NA 2026-07-20 08:47:20
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-20 08:47:20
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-20 08:47:20
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-20 08:47:20
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-20 08:47:20
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-20 08:47:20
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-20 08:47:20
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-20 08:47:20
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-20 08:47:20
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-20 08:47:20
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-20 08:47:20
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-20 08:47:20
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-20 08:47:20
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-20 08:47:20
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-20 08:47:20
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-20 08:47:20
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-20 08:47:20
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-20 08:47:20
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-20 08:47:20
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-20 08:47:20
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-20 08:47:20
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-20 08:47:20
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-20 08:47:20
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-20 08:47:20
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-20 08:47:20
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-20 08:47:20
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-20 08:47:20
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-20 08:47:20
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-20 08:47:20
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-20 08:47:20
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-20 08:47:20
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-20 08:47:20
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-20 08:47:20
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-20 08:47:20
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-20 08:47:20
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-20 08:47:20
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   2: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   3: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   4: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   5: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   6: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   7: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   8: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>   9: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  10: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  11: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  12: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  13: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  14: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  15: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  16: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  17: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  18: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  19: sinking_raccoon_a810f83f 2026-07-20 08:47:21
#>  20: sinking_raccoon_a810f83f 2026-07-20 08:47:21
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
#>   1: d1645756-f587-4584-8688-d350218f3a78    [NULL]  -10.000000  -5.0000000
#>   2: 3a02feab-47c4-427e-9846-35cfb3b832ae    [NULL]  -10.000000  -3.8888889
#>   3: 8b00f4c1-81a0-48cb-b774-56eec48c01ac    [NULL]  -10.000000  -2.7777778
#>   4: f804b80a-7446-40be-a116-e6f498f079e0    [NULL]  -10.000000  -1.6666667
#>   5: e27c8b98-1c20-49aa-bc10-c8d644a4dfee    [NULL]  -10.000000  -0.5555556
#>   6: 6ccedab7-d673-4253-99fa-5db37dafec39    [NULL]  -10.000000   0.5555556
#>   7: da161a5a-7718-4062-9c2e-a150ee7a6afa    [NULL]  -10.000000   1.6666667
#>   8: dee8ae94-f556-4601-9e38-9903c464b272    [NULL]  -10.000000   2.7777778
#>   9: d08089b5-c5fb-45e1-8028-38e38f3c3467    [NULL]  -10.000000   3.8888889
#>  10: bff88897-4f1f-4bd1-a435-c5bc13a79df5    [NULL]  -10.000000   5.0000000
#>  11: a15fa372-e4ff-43a6-8882-113c519f0006    [NULL]   -7.777778  -5.0000000
#>  12: e450e808-a65e-48f0-87c7-baf8c2aa6cf0    [NULL]   -7.777778  -3.8888889
#>  13: ce068ea2-0e4d-440a-92ab-f502d2890f37    [NULL]   -7.777778  -2.7777778
#>  14: 2df580ff-2f33-4de2-9d2e-8b82decc8e8d    [NULL]   -7.777778  -1.6666667
#>  15: f27b2338-f747-4dd5-b787-e94286f42dfd    [NULL]   -7.777778  -0.5555556
#>  16: b40f8e4c-f12e-4b07-8ab9-a5209250ea7f    [NULL]   -7.777778   0.5555556
#>  17: a165ee8f-bf95-4445-b969-188934587b08    [NULL]   -7.777778   1.6666667
#>  18: c795bbf4-4a87-4e56-9e04-ba0b6db01e8c    [NULL]   -7.777778   2.7777778
#>  19: 8a5abc65-3c4e-4d5c-afa1-03429f48c743    [NULL]   -7.777778   3.8888889
#>  20: 5d38ae80-60ec-4269-b7ed-f6d43d12b472    [NULL]   -7.777778   5.0000000
#>  21: 28b6e82d-7ff0-4842-9bdb-3ada7643c71d <list[1]>          NA          NA
#>  22: 5a825c6c-f942-4b1f-a6bc-779cf470be6d <list[1]>          NA          NA
#>  23: 382b0a27-51c3-4c39-b3d5-8319aa8a2402 <list[1]>          NA          NA
#>  24: 9ee8bc2e-9dbd-4e5c-b7a1-72a2f229d653 <list[1]>          NA          NA
#>  25: 41085136-3ba3-4646-9ef2-49b6bb3ae029 <list[1]>          NA          NA
#>  26: f1265ac9-e88d-4946-9f88-c0df5ce6cc7d <list[1]>          NA          NA
#>  27: c21a1f06-9edb-4a19-99ce-88830b54c1f9 <list[1]>          NA          NA
#>  28: b5bc3a70-d571-4e3a-8d8c-c5da575da2ac <list[1]>          NA          NA
#>  29: ffaf35b1-55ce-46ef-a24d-02f42b4abd10 <list[1]>          NA          NA
#>  30: 4749bd7c-3b8a-4db2-82c1-b876979ce8ea <list[1]>          NA          NA
#>  31: 74dc166a-cb92-4ffb-9630-b05693b4c19b <list[1]>          NA          NA
#>  32: 1d0517ac-2f1e-4362-b151-dbf10eaf51a7 <list[1]>          NA          NA
#>  33: c9332087-8ea1-4279-b426-24cb8a5a5e4d <list[1]>          NA          NA
#>  34: 09e4edd8-6051-4cd7-a3f7-eb6419c38474 <list[1]>          NA          NA
#>  35: e18091d3-ae10-41e1-ae8b-8b1f12288ed2 <list[1]>          NA          NA
#>  36: 9121e8cb-92c8-46a0-81de-af0542a66d35 <list[1]>          NA          NA
#>  37: 5f6dd41b-0d23-495e-b33e-9169fe80dacc <list[1]>          NA          NA
#>  38: 33dc457f-e368-49df-b916-0ecdc20f0a11 <list[1]>          NA          NA
#>  39: ac84227f-076e-40ba-b71b-cb689eca64ef <list[1]>          NA          NA
#>  40: 22ad5057-a2e9-40d6-a969-a2ae70435706 <list[1]>          NA          NA
#>  41: 16313b87-0cd2-4825-9e95-96937c01a261 <list[1]>          NA          NA
#>  42: 119ce9ad-b1e0-4279-8481-fa5b4a1f188b <list[1]>          NA          NA
#>  43: 30677fd0-1f58-4578-a55e-e830f84cc418 <list[1]>          NA          NA
#>  44: 387a86d1-8643-4a74-9094-bf697d9c8bcf <list[1]>          NA          NA
#>  45: 128e675f-2120-4327-90ff-9a8dda11b4d4 <list[1]>          NA          NA
#>  46: 6c415e21-8180-4cb5-9914-362ed75cdebd <list[1]>          NA          NA
#>  47: 36f7dd84-4144-4dd2-b01a-a3ee4c0e5959 <list[1]>          NA          NA
#>  48: b86a1981-7a30-4498-b6a8-bdcc2ed3877f <list[1]>          NA          NA
#>  49: f970c228-5f77-435c-a6c2-36cb29c18ef2 <list[1]>          NA          NA
#>  50: c81fd2b7-7908-4e6b-aecc-bb6c6d0defc7 <list[1]>          NA          NA
#>  51: 6f56162a-f5dd-47b2-a238-245931970ac0 <list[1]>          NA          NA
#>  52: f34f5194-0fa3-4976-a5e5-2647fe19adb2 <list[1]>          NA          NA
#>  53: 31f02a7c-fbad-4c38-9bc0-9a52a861ca05 <list[1]>          NA          NA
#>  54: 7c775174-5057-4734-9f71-8a3aa58c39e1 <list[1]>          NA          NA
#>  55: d7e4f25a-e953-4f73-9c31-e1fb8ee6c13b <list[1]>          NA          NA
#>  56: d6e5b066-71bb-47c1-a143-9282336d4d18 <list[1]>          NA          NA
#>  57: 3e9461ac-5df8-4354-a048-b552c4f198cf <list[1]>          NA          NA
#>  58: 0eaaac19-11af-4d0a-8fab-5a898ec35ed4 <list[1]>          NA          NA
#>  59: d9fefe70-579d-4c5c-9056-9befb6e85349 <list[1]>          NA          NA
#>  60: 30dc891a-79e3-4793-b852-4a34bf13da79 <list[1]>          NA          NA
#>  61: 440fb396-23ad-4e10-bc6f-6c308211934d <list[1]>          NA          NA
#>  62: fb10bf09-fe41-4a7c-b889-cd6076f5c1a8 <list[1]>          NA          NA
#>  63: ca698f01-18ca-46ac-805c-d98e1d8d1bdf <list[1]>          NA          NA
#>  64: 1563f6e6-23fb-4c8e-8f07-c4dccc0f901b <list[1]>          NA          NA
#>  65: 98fc463e-91ba-4e93-9a5f-596c36cd58e7 <list[1]>          NA          NA
#>  66: 104fc1fe-7ce8-4c36-ae08-4d82f47efc77 <list[1]>          NA          NA
#>  67: 128579e6-1fe5-4ff0-bd13-d5a10d50889e <list[1]>          NA          NA
#>  68: 109dac1f-8d49-4bea-bf90-f78ee3d03496 <list[1]>          NA          NA
#>  69: 6667a779-99b4-4f86-b86b-0f695e8164ba <list[1]>          NA          NA
#>  70: d116aa25-636a-4a27-ae1f-33c856950d94 <list[1]>          NA          NA
#>  71: 403e8a00-79f4-4f3b-b171-b5d97c8b46f1 <list[1]>          NA          NA
#>  72: 9041f634-04e0-4d07-aa9a-a776eded214f <list[1]>          NA          NA
#>  73: 0b69b675-2fab-491e-a0a0-8135b6385904 <list[1]>          NA          NA
#>  74: 59af2312-45f8-44b9-a94a-3dbfce97c297 <list[1]>          NA          NA
#>  75: 156aca9c-5a99-40f7-a20c-6020ec65cf26 <list[1]>          NA          NA
#>  76: f3987288-fd69-4a91-803f-da31c7863c10 <list[1]>          NA          NA
#>  77: 3b5bf841-ce65-4ba2-94f0-2c6598ddc973 <list[1]>          NA          NA
#>  78: 2a398e6b-a5b8-40e1-ad4d-6975b1e17194 <list[1]>          NA          NA
#>  79: 189e77c3-2647-4976-b998-d0418ce92f4e <list[1]>          NA          NA
#>  80: 68acc81b-3d92-4ff2-b3c2-d75fb77388ea <list[1]>          NA          NA
#>  81: 72140d27-417c-4c58-bc72-74a0ba5d1016 <list[1]>          NA          NA
#>  82: 96288de4-b21e-40fb-93ae-3975f3c34026 <list[1]>          NA          NA
#>  83: 9df1d081-e969-45e8-8329-781996bf7ddd <list[1]>          NA          NA
#>  84: 9b8cd170-ccc0-45f4-aeab-e227817926c5 <list[1]>          NA          NA
#>  85: 591d7dcd-1d1b-489d-9db9-1d45ae0bb2d0 <list[1]>          NA          NA
#>  86: 476ab5a1-a261-44fb-b803-24566f9a639e <list[1]>          NA          NA
#>  87: 9bde3986-4e8b-4900-b69c-ab71e6641341 <list[1]>          NA          NA
#>  88: eeaa8196-ca04-4671-887f-5cf1bd3ca44c <list[1]>          NA          NA
#>  89: b2af09eb-89d1-4718-ac86-ae74f7ae1214 <list[1]>          NA          NA
#>  90: 9e11b855-1b0f-4b38-a7af-d98c24a3c7f4 <list[1]>          NA          NA
#>  91: 7be9e831-dd7a-43a7-828f-f146c24073d5 <list[1]>          NA          NA
#>  92: c2605fa1-073d-4269-aac8-2e8db2f1f8e9 <list[1]>          NA          NA
#>  93: 38ae516b-053a-431f-a203-cc64b1887b7c <list[1]>          NA          NA
#>  94: b1c20822-a85c-49e0-9b47-4a5e13be39e7 <list[1]>          NA          NA
#>  95: 74c1ba7a-79e3-49b2-bf1e-158b03204f21 <list[1]>          NA          NA
#>  96: d9529678-7d78-4f72-91be-cad7c547f052 <list[1]>          NA          NA
#>  97: d8d83ada-6365-4e55-9879-208bb4bf51c9 <list[1]>          NA          NA
#>  98: 38f8d923-bcb5-4463-a678-bc9a1505052d <list[1]>          NA          NA
#>  99: d5556fdb-0298-40c9-a55e-e0a4d736e04b <list[1]>          NA          NA
#> 100: 47ded72c-53e4-4034-877a-a7fdb7be61eb <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
