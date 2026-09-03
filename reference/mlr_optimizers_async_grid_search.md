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

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 10:50:32
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 10:50:32
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 10:50:32
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 10:50:32
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 10:50:32
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 10:50:32
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 10:50:32
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 10:50:32
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 10:50:32
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 10:50:32
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 10:50:32
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 10:50:32
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 10:50:32
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 10:50:32
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 10:50:32
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 10:50:32
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 10:50:32
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 10:50:32
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 10:50:32
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 10:50:32
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 10:50:32
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 10:50:32
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 10:50:32
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 10:50:32
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 10:50:32
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 10:50:32
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 10:50:32
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 10:50:32
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 10:50:32
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 10:50:32
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 10:50:32
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 10:50:32
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 10:50:32
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 10:50:32
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 10:50:32
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 10:50:32
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 10:50:32
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 10:50:32
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 10:50:32
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 10:50:32
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 10:50:32
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 10:50:32
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 10:50:32
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 10:50:32
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 10:50:32
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 10:50:32
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 10:50:32
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 10:50:32
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 10:50:32
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 10:50:32
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 10:50:32
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 10:50:32
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 10:50:32
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 10:50:32
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 10:50:32
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 10:50:32
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 10:50:32
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 10:50:32
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 10:50:32
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 10:50:32
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 10:50:32
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 10:50:32
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 10:50:32
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 10:50:32
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 10:50:32
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 10:50:32
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 10:50:32
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 10:50:32
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 10:50:32
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 10:50:32
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 10:50:32
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 10:50:32
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 10:50:32
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 10:50:32
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 10:50:32
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 10:50:32
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 10:50:32
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 10:50:32
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 10:50:32
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 10:50:32
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 10:50:32
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 10:50:32
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 10:50:32
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 10:50:32
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 10:50:32
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 10:50:32
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 10:50:32
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 10:50:32
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 10:50:32
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 10:50:32
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 10:50:32
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 10:50:32
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 10:50:32
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 10:50:32
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 10:50:32
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 10:50:32
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 10:50:32
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 10:50:32
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 10:50:32
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 10:50:32
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   2: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   3: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   4: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   5: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   6: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   7: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   8: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>   9: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  10: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  11: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  12: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  13: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  14: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  15: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  16: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  17: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  18: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  19: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
#>  20: sinking_raccoon_26b7b6b2 2026-09-03 10:50:33
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
#>   1: a090018e-ed9c-4234-a5f3-70b467a61caf    [NULL]  -10.000000  -5.0000000
#>   2: a1c4555c-21d8-48a2-8dcb-60f58cf8868f    [NULL]  -10.000000  -3.8888889
#>   3: ae29edf4-e244-4018-bb99-d086d4afdbb9    [NULL]  -10.000000  -2.7777778
#>   4: a150d32b-c926-4441-9991-0dffb06a799e    [NULL]  -10.000000  -1.6666667
#>   5: 350ab0c2-f7f9-4d35-b0cc-375967fee757    [NULL]  -10.000000  -0.5555556
#>   6: 20f9dd75-d6a2-4037-a028-762eec95845a    [NULL]  -10.000000   0.5555556
#>   7: 7cb7976d-d162-4290-a8ba-d4eaef979ed3    [NULL]  -10.000000   1.6666667
#>   8: 31a09ee0-3eb8-4883-862c-e322e76058f4    [NULL]  -10.000000   2.7777778
#>   9: dcc2f7e7-cf9c-4093-a5d6-018797561220    [NULL]  -10.000000   3.8888889
#>  10: 9c5b7f35-3084-4f36-81f1-f306d24cc40f    [NULL]  -10.000000   5.0000000
#>  11: cb719955-cf7c-47e3-a025-c355dfb2ba2a    [NULL]   -7.777778  -5.0000000
#>  12: a9b0a4f5-7730-47c1-9e02-ec39584edd0b    [NULL]   -7.777778  -3.8888889
#>  13: a77454d4-9224-455c-8568-b2575971f12c    [NULL]   -7.777778  -2.7777778
#>  14: 647056c7-796d-49d0-9a18-cc067d685120    [NULL]   -7.777778  -1.6666667
#>  15: 6159b769-289e-44b3-a6b6-4b4724895b52    [NULL]   -7.777778  -0.5555556
#>  16: 323c4293-7387-4885-839f-30806b8f3777    [NULL]   -7.777778   0.5555556
#>  17: fa57026d-8224-4342-9c7f-c2b17708344d    [NULL]   -7.777778   1.6666667
#>  18: 0b6e47fa-9fab-4e9f-9c83-1041caeb29e6    [NULL]   -7.777778   2.7777778
#>  19: 76e0d3ab-0c54-426b-add0-0d8b81ade9e8    [NULL]   -7.777778   3.8888889
#>  20: 31fef480-ae65-4d23-914f-fc3eac4ad8a0    [NULL]   -7.777778   5.0000000
#>  21: 638dbd3d-f4ee-47e8-b19d-ccaf04fa7a65 <list[1]>          NA          NA
#>  22: d36ffe35-fed6-411f-a540-f0965b781ea7 <list[1]>          NA          NA
#>  23: a7b145aa-6bba-4b33-8758-b8b80d5a0b51 <list[1]>          NA          NA
#>  24: 199e3176-69d1-499d-8757-ff25843ad3f3 <list[1]>          NA          NA
#>  25: 71e755dc-7d4e-4f1c-91d2-41c9a62a322f <list[1]>          NA          NA
#>  26: d7720856-99fe-4c02-a2c4-e786bfd41363 <list[1]>          NA          NA
#>  27: 59a3adf5-1f94-4d13-a5fe-d4687f455a38 <list[1]>          NA          NA
#>  28: 1ee4416e-9e86-4819-aed4-3ac49a3b899f <list[1]>          NA          NA
#>  29: 885dc799-d230-46ad-9a40-96de155a736b <list[1]>          NA          NA
#>  30: c2bf65a5-c6fa-47bb-8395-57232bfdaa63 <list[1]>          NA          NA
#>  31: 76a9dddd-0093-4986-988a-aeb4e39c007e <list[1]>          NA          NA
#>  32: bb49f8b2-2a06-4854-89fd-0db48230f560 <list[1]>          NA          NA
#>  33: 74b5f7e6-d67f-4f4e-9525-d99c34074336 <list[1]>          NA          NA
#>  34: e2befa7d-e649-42ee-95c2-2ab9ab9a8d89 <list[1]>          NA          NA
#>  35: 64d891a8-2ff7-4c99-9b4d-78e7ee10b617 <list[1]>          NA          NA
#>  36: 583a8f92-5a9c-4c6f-8aaf-3e1946ada31d <list[1]>          NA          NA
#>  37: 547882be-ef4b-45ec-ad52-106a7682b092 <list[1]>          NA          NA
#>  38: c834e4b2-d8a6-41f1-b809-4ada4aa2d665 <list[1]>          NA          NA
#>  39: 0985b3cf-9539-4479-a76d-79685936746b <list[1]>          NA          NA
#>  40: 9f044cb0-dc35-46e3-8824-379d660e85aa <list[1]>          NA          NA
#>  41: 996e6aa1-afb9-4279-a428-f5ce871f3579 <list[1]>          NA          NA
#>  42: 41f78016-44b5-47df-a3de-184fdb76d439 <list[1]>          NA          NA
#>  43: 60ad5817-7e9c-4e08-8a13-7558544f474d <list[1]>          NA          NA
#>  44: 08341112-85a9-47b4-9273-ab67ca2384de <list[1]>          NA          NA
#>  45: 85271ccf-da23-4b71-a6ac-fc644ad3abeb <list[1]>          NA          NA
#>  46: 44c1aad5-be84-4beb-8629-354210c7642b <list[1]>          NA          NA
#>  47: c23698f1-2264-4c41-aee7-8d1620c94e6e <list[1]>          NA          NA
#>  48: e8d3ce18-1bd2-4aa4-b165-f23565661a87 <list[1]>          NA          NA
#>  49: ac479b8a-a21a-47f0-9156-6f812a95b8e3 <list[1]>          NA          NA
#>  50: 1cfeb4db-22ef-41f7-ad8e-e7de572f584b <list[1]>          NA          NA
#>  51: 01ef398d-7036-4e9d-9128-7688d3c79cc2 <list[1]>          NA          NA
#>  52: 90cf2190-b302-4c1c-9e76-f82ad747697b <list[1]>          NA          NA
#>  53: b1b641ee-b97e-452a-9641-d4b637e56101 <list[1]>          NA          NA
#>  54: 3fffe911-c936-4aff-b3de-0ac7149ab1f5 <list[1]>          NA          NA
#>  55: a5e9fce1-f383-4ad3-a438-d140ecf5e3f1 <list[1]>          NA          NA
#>  56: 805257e1-66dc-4c2e-b127-b64d0b422993 <list[1]>          NA          NA
#>  57: c0c182fb-a003-46bb-868e-30fe97d14281 <list[1]>          NA          NA
#>  58: 06201dde-335b-4dc8-a93f-ef8760a4cf0f <list[1]>          NA          NA
#>  59: 7b3dc156-5c7d-46f9-8b24-aafee9dad554 <list[1]>          NA          NA
#>  60: 527b9f2d-2a21-43cb-83ec-d736e98401ac <list[1]>          NA          NA
#>  61: 96864408-9b54-4fb9-bb76-c08e23a1f9de <list[1]>          NA          NA
#>  62: b730f095-586b-4db4-9384-89bfdcf9ec5d <list[1]>          NA          NA
#>  63: c337b944-e3cb-4060-8ed4-c2a8cfa3f0fa <list[1]>          NA          NA
#>  64: df87f893-b0b2-499c-9a93-22bcd2cbc790 <list[1]>          NA          NA
#>  65: 750da140-85a8-4708-9589-3f72c393cfd2 <list[1]>          NA          NA
#>  66: 59c26b6f-0d6a-4c0c-a98b-47f13a276f3f <list[1]>          NA          NA
#>  67: 07e9f70e-63ed-4f65-9a6a-cf3b1b8ff9e4 <list[1]>          NA          NA
#>  68: 189c7b11-bde4-4c86-a97e-71c3942c9847 <list[1]>          NA          NA
#>  69: 4a677e7b-6ee9-438d-8d61-7c8e3dde0391 <list[1]>          NA          NA
#>  70: 0892a03e-276c-45c1-a832-0e3d5962d2b7 <list[1]>          NA          NA
#>  71: 153bda19-557a-4a6d-9ebb-d5c2b4de2cc5 <list[1]>          NA          NA
#>  72: 99e1a255-9d3b-403d-b101-32d291dd608d <list[1]>          NA          NA
#>  73: 7ca01900-56c1-467d-b429-3fb19740b22e <list[1]>          NA          NA
#>  74: ae02e651-55fc-4fa7-826f-8073f9aab785 <list[1]>          NA          NA
#>  75: 13332f8d-eca2-4bef-8811-8d070425440d <list[1]>          NA          NA
#>  76: 0c4ca974-f297-4a8b-bfe4-05f25871fe23 <list[1]>          NA          NA
#>  77: d21e7dcf-6ed8-4455-8643-3bb48a7d0b2c <list[1]>          NA          NA
#>  78: 5fbad51b-97b1-46da-b3cb-b6ce4e2e7c9b <list[1]>          NA          NA
#>  79: 4b9ec8be-1542-4fb2-93c7-aa79b776e59c <list[1]>          NA          NA
#>  80: 26d151b1-5e32-4bba-85ca-a55e15a18058 <list[1]>          NA          NA
#>  81: d6055ca4-2849-4bb2-b43b-fb2b53d97ec3 <list[1]>          NA          NA
#>  82: bfa00433-5dc7-4d3b-bab4-438a43ddb569 <list[1]>          NA          NA
#>  83: cc69c15a-c023-4aff-95b3-46d5e089be08 <list[1]>          NA          NA
#>  84: 0553bc65-e57b-4e6d-a4eb-1ae51b92bbaa <list[1]>          NA          NA
#>  85: d50c1a24-9627-4ae5-95af-d3b548d9ec47 <list[1]>          NA          NA
#>  86: 1cc9bfd0-ce50-46ab-ae88-b30693d1125b <list[1]>          NA          NA
#>  87: ef522034-b68a-487c-8bd4-7a89b8edc6be <list[1]>          NA          NA
#>  88: fef768f7-46bf-46a9-ac56-d4226ce7d1ee <list[1]>          NA          NA
#>  89: 34156c07-8c4b-457a-bc5b-2664fca6bbed <list[1]>          NA          NA
#>  90: c3210991-2e40-45d2-afc9-a20b6897f3c2 <list[1]>          NA          NA
#>  91: 18b9631e-9f85-4a54-aea2-5d936801981e <list[1]>          NA          NA
#>  92: d88a5e9f-721a-46fb-81a8-b71b22711634 <list[1]>          NA          NA
#>  93: 8022727f-b215-439c-a159-fd9d6a686226 <list[1]>          NA          NA
#>  94: 57c8530f-2c42-4303-90b2-a1293c17c416 <list[1]>          NA          NA
#>  95: 869c32d5-482c-403d-9312-4884aae2a230 <list[1]>          NA          NA
#>  96: 3f204aea-b7b7-4f92-b792-2df820c25ae5 <list[1]>          NA          NA
#>  97: bb6f350e-acbe-41a6-ac90-6b056469909d <list[1]>          NA          NA
#>  98: 669fd8b3-7600-415b-b641-4b54cf8746b1 <list[1]>          NA          NA
#>  99: 07375061-cdd0-40b5-96b8-d6801c61a83d <list[1]>          NA          NA
#> 100: 1b68248e-5012-4163-9966-1343c0bca684 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
