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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-18 09:15:17
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-18 09:15:17
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-18 09:15:17
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-18 09:15:17
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-18 09:15:17
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-18 09:15:17
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-18 09:15:17
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-18 09:15:17
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-18 09:15:17
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-18 09:15:17
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-18 09:15:17
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-18 09:15:17
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-18 09:15:17
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-18 09:15:17
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-18 09:15:17
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-18 09:15:17
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-18 09:15:17
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-18 09:15:17
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-18 09:15:17
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-18 09:15:17
#>  21:   failed  10.000000  5.0000000         NA 2026-09-18 09:15:17
#>  22:   failed  10.000000  3.8888889         NA 2026-09-18 09:15:17
#>  23:   failed  10.000000  2.7777778         NA 2026-09-18 09:15:17
#>  24:   failed  10.000000  1.6666667         NA 2026-09-18 09:15:17
#>  25:   failed  10.000000  0.5555556         NA 2026-09-18 09:15:17
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-18 09:15:17
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-18 09:15:17
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-18 09:15:17
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-18 09:15:17
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-18 09:15:17
#>  31:   failed   7.777778  5.0000000         NA 2026-09-18 09:15:17
#>  32:   failed   7.777778  3.8888889         NA 2026-09-18 09:15:17
#>  33:   failed   7.777778  2.7777778         NA 2026-09-18 09:15:17
#>  34:   failed   7.777778  1.6666667         NA 2026-09-18 09:15:17
#>  35:   failed   7.777778  0.5555556         NA 2026-09-18 09:15:17
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-18 09:15:17
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-18 09:15:17
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-18 09:15:17
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-18 09:15:17
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-18 09:15:17
#>  41:   failed   5.555556  5.0000000         NA 2026-09-18 09:15:17
#>  42:   failed   5.555556  3.8888889         NA 2026-09-18 09:15:17
#>  43:   failed   5.555556  2.7777778         NA 2026-09-18 09:15:17
#>  44:   failed   5.555556  1.6666667         NA 2026-09-18 09:15:17
#>  45:   failed   5.555556  0.5555556         NA 2026-09-18 09:15:17
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-18 09:15:17
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-18 09:15:17
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-18 09:15:17
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-18 09:15:17
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-18 09:15:17
#>  51:   failed   3.333333  5.0000000         NA 2026-09-18 09:15:17
#>  52:   failed   3.333333  3.8888889         NA 2026-09-18 09:15:17
#>  53:   failed   3.333333  2.7777778         NA 2026-09-18 09:15:17
#>  54:   failed   3.333333  1.6666667         NA 2026-09-18 09:15:17
#>  55:   failed   3.333333  0.5555556         NA 2026-09-18 09:15:17
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-18 09:15:17
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-18 09:15:17
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-18 09:15:17
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-18 09:15:17
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-18 09:15:17
#>  61:   failed   1.111111  5.0000000         NA 2026-09-18 09:15:17
#>  62:   failed   1.111111  3.8888889         NA 2026-09-18 09:15:17
#>  63:   failed   1.111111  2.7777778         NA 2026-09-18 09:15:17
#>  64:   failed   1.111111  1.6666667         NA 2026-09-18 09:15:17
#>  65:   failed   1.111111  0.5555556         NA 2026-09-18 09:15:17
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-18 09:15:17
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-18 09:15:17
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-18 09:15:17
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-18 09:15:17
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-18 09:15:17
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-18 09:15:17
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-18 09:15:17
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-18 09:15:17
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-18 09:15:17
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-18 09:15:17
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-18 09:15:17
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-18 09:15:17
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-18 09:15:17
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-18 09:15:17
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-18 09:15:17
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-18 09:15:17
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-18 09:15:17
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-18 09:15:17
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-18 09:15:17
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-18 09:15:17
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-18 09:15:17
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-18 09:15:17
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-18 09:15:17
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-18 09:15:17
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-18 09:15:17
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-18 09:15:17
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-18 09:15:17
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-18 09:15:17
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-18 09:15:17
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-18 09:15:17
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-18 09:15:17
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-18 09:15:17
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-18 09:15:17
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-18 09:15:17
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-18 09:15:17
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   2: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   3: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   4: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   5: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   6: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   7: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   8: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>   9: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  10: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  11: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  12: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  13: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  14: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  15: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  16: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  17: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  18: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  19: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
#>  20: sinking_raccoon_010f0cc7 2026-09-18 09:15:18
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
#>   1: b0a5a816-9569-499f-bd86-5e0e036153dd    [NULL]  -10.000000  -5.0000000
#>   2: 0efdfeec-5512-4b9c-9180-b3172975b609    [NULL]  -10.000000  -3.8888889
#>   3: 57a9da0c-2575-490b-8b4d-97b3075585a0    [NULL]  -10.000000  -2.7777778
#>   4: b3349bc8-05d6-4b1e-8df8-99c20d2927ef    [NULL]  -10.000000  -1.6666667
#>   5: 5f88016e-a017-4574-8a1f-ccf2baca0b84    [NULL]  -10.000000  -0.5555556
#>   6: afb5b588-2da0-4e44-8ac4-8d4a691831a7    [NULL]  -10.000000   0.5555556
#>   7: 46fb1122-601b-4e6f-8843-f8b18cf2290e    [NULL]  -10.000000   1.6666667
#>   8: e1dfde67-d82f-49b2-835b-ed05b76d0869    [NULL]  -10.000000   2.7777778
#>   9: 0dcf2e6b-5f74-4cef-999d-e6fe28772fae    [NULL]  -10.000000   3.8888889
#>  10: b4180cc2-f18b-4e16-a019-504b86040708    [NULL]  -10.000000   5.0000000
#>  11: 7a2ef869-ebbd-4d17-87be-c977ce1faec5    [NULL]   -7.777778  -5.0000000
#>  12: fa2cacc9-22cd-457f-851a-194edd756f90    [NULL]   -7.777778  -3.8888889
#>  13: 069ab805-94ed-4ea5-8f32-ea4c852d471c    [NULL]   -7.777778  -2.7777778
#>  14: 7fa97c9a-f626-4644-807f-55440bd3110b    [NULL]   -7.777778  -1.6666667
#>  15: 2c19dd0d-6a09-41e6-9d1b-40861ee873a7    [NULL]   -7.777778  -0.5555556
#>  16: 9a89fd4e-59f4-4670-8110-1187ae40662a    [NULL]   -7.777778   0.5555556
#>  17: 16fdbbcc-5f38-48af-af11-265aa60dcfaa    [NULL]   -7.777778   1.6666667
#>  18: bafe7cf3-5174-49cb-8b4e-7237459770f4    [NULL]   -7.777778   2.7777778
#>  19: bb45c906-34b4-4a39-8dc7-b7319290ee88    [NULL]   -7.777778   3.8888889
#>  20: e7fd3dc3-171c-44e9-9514-7017df3c4b53    [NULL]   -7.777778   5.0000000
#>  21: 786bb1f1-6ec3-4bf2-9c2a-44b0a4c66185 <list[1]>          NA          NA
#>  22: 8d8b611d-a926-4532-8bbf-4aac9cd16d54 <list[1]>          NA          NA
#>  23: eb7e9766-943e-455d-a360-6f5d7d203b05 <list[1]>          NA          NA
#>  24: 05ddbcb8-1c00-4d07-acc5-bd8ee1dfdffd <list[1]>          NA          NA
#>  25: 694e1917-8d95-4e45-b238-0180b2233f63 <list[1]>          NA          NA
#>  26: 43bb9b2e-5d7a-48f9-b536-ef714b43d132 <list[1]>          NA          NA
#>  27: a864e4fe-4348-4f1b-9985-6fb82ff47374 <list[1]>          NA          NA
#>  28: 5f0b9ebf-a153-4b44-9df5-4b687d6005c2 <list[1]>          NA          NA
#>  29: c1e6d85c-c5f7-4c09-b981-411056778997 <list[1]>          NA          NA
#>  30: 53419b29-85c5-4b1d-9da3-9500908e3e8b <list[1]>          NA          NA
#>  31: 98ede8f1-6027-454d-a4c3-16157fe51616 <list[1]>          NA          NA
#>  32: de5033e3-4ab8-4814-8e95-862eeb49e44d <list[1]>          NA          NA
#>  33: d66350db-5b5f-488a-bc5d-de0e0ea9774e <list[1]>          NA          NA
#>  34: 0f00b0bd-d8ea-4457-9836-026edf6d6a79 <list[1]>          NA          NA
#>  35: 483b4140-6e91-4e22-bac7-b84c58567b32 <list[1]>          NA          NA
#>  36: 52eef30c-7bb0-42e8-9bbf-afa007357719 <list[1]>          NA          NA
#>  37: fa7d2b38-f616-4028-9e49-447216a59b49 <list[1]>          NA          NA
#>  38: da9c07ee-5e41-4651-8659-b37266c86bb8 <list[1]>          NA          NA
#>  39: 1aa6c16d-698d-4c51-9065-4a66941aa3b2 <list[1]>          NA          NA
#>  40: fcad296e-424b-464f-90b5-b4e593e79325 <list[1]>          NA          NA
#>  41: 154d53bf-c9ea-4794-82e4-742a96a0f5ac <list[1]>          NA          NA
#>  42: 78c3acbc-4616-45aa-ae7d-f326466821e9 <list[1]>          NA          NA
#>  43: ed723705-cb8d-4bdd-bc3f-da839c5f41aa <list[1]>          NA          NA
#>  44: c20167bc-952a-4517-85b4-c492627d2002 <list[1]>          NA          NA
#>  45: f5d9fbb3-c84b-48b0-9d82-89f0c6e62e48 <list[1]>          NA          NA
#>  46: 1c7c0d6c-a8ee-4842-aed1-673119667631 <list[1]>          NA          NA
#>  47: 37a41a35-172f-4071-a7ac-760c3fb55fc7 <list[1]>          NA          NA
#>  48: b9f02b70-ceea-4d4c-965e-970cd7d60eb3 <list[1]>          NA          NA
#>  49: 644b0268-416a-41e3-9171-4c0a4317a6db <list[1]>          NA          NA
#>  50: c1d4ae06-b941-4295-95d2-b8bd1d03dd70 <list[1]>          NA          NA
#>  51: f009c7d3-bacf-4cfe-a60b-7d29c1ad4165 <list[1]>          NA          NA
#>  52: 973b8ee2-4205-4eeb-9f19-f89673b06f38 <list[1]>          NA          NA
#>  53: c8793fca-cef7-476e-973c-12023d17b15e <list[1]>          NA          NA
#>  54: 4d616577-5a05-4ca2-9954-3bb6527cb9c9 <list[1]>          NA          NA
#>  55: 6091118c-cfa6-4803-af96-5904192af28a <list[1]>          NA          NA
#>  56: 42505cc9-d733-4f0e-8a93-fe26c2079ef1 <list[1]>          NA          NA
#>  57: 8168639d-d7cb-49bd-aa05-59240995364d <list[1]>          NA          NA
#>  58: 45a6f60f-0631-4bd9-ae03-d65097a4040b <list[1]>          NA          NA
#>  59: ad670a1e-d648-4b62-9c56-faacfae70880 <list[1]>          NA          NA
#>  60: 9ecc88a2-b33d-4fbf-8cad-d9e4c78e08b1 <list[1]>          NA          NA
#>  61: 5a5d58ee-f123-4408-9f4b-eb75abe687bc <list[1]>          NA          NA
#>  62: 96525d11-0b6c-4100-a73a-f78c76b65608 <list[1]>          NA          NA
#>  63: df6aacf2-435b-40f1-a13b-688ee57201d5 <list[1]>          NA          NA
#>  64: 8cccfcae-5fb5-4cae-a642-c2ab66550e2c <list[1]>          NA          NA
#>  65: f658b920-4965-4daf-a7a9-ccfa0cf5cb3c <list[1]>          NA          NA
#>  66: 1f444fbb-144a-4289-abaf-dfc9e6bcfdba <list[1]>          NA          NA
#>  67: 09f17f74-495a-411d-b7f3-2092a59fab09 <list[1]>          NA          NA
#>  68: fc3f4215-6609-4cc4-8034-37b0ca1e0e6c <list[1]>          NA          NA
#>  69: a9f92675-85a7-48ce-842d-be2d2b53cc86 <list[1]>          NA          NA
#>  70: fbce0513-48f7-4799-9100-69946bad453e <list[1]>          NA          NA
#>  71: e6a9ff53-86f8-46b5-b4a4-5d90893696e3 <list[1]>          NA          NA
#>  72: 6b99b5a4-fa96-4651-acfd-5a5a971b5020 <list[1]>          NA          NA
#>  73: 6c71d048-5cd7-4b15-ad8f-6c0dffa4d869 <list[1]>          NA          NA
#>  74: 33e16aa6-6d3e-4487-b8b1-4763576be831 <list[1]>          NA          NA
#>  75: 32516da1-4511-48de-a33c-88a86cee9dad <list[1]>          NA          NA
#>  76: 2899f2f8-ed20-4d93-ba42-54b20c675053 <list[1]>          NA          NA
#>  77: 88469054-b4c4-425a-af50-50c21e04ff8b <list[1]>          NA          NA
#>  78: f36597dd-47f7-489a-9e49-b1f52d94fa2b <list[1]>          NA          NA
#>  79: eb86d222-062a-41a7-8131-7ba3fb1fa8b9 <list[1]>          NA          NA
#>  80: a811a727-e99c-4169-b124-8a4d6c58ceca <list[1]>          NA          NA
#>  81: 515d74b1-ca0e-4c13-b8e1-e195d14394ae <list[1]>          NA          NA
#>  82: 711f0dc9-e637-4f9a-bbba-9fed449c106e <list[1]>          NA          NA
#>  83: 82335cca-8861-44b4-bb6e-724921997e52 <list[1]>          NA          NA
#>  84: 6bbf2f79-dc26-4590-aa7a-e904a7a1e4ab <list[1]>          NA          NA
#>  85: ada6cf73-e0be-4cbd-825d-5edb3a787d5c <list[1]>          NA          NA
#>  86: b205b55d-eaa1-492d-bbce-6e7528ac47d6 <list[1]>          NA          NA
#>  87: 74be896d-b860-44e7-b780-82b81a59d700 <list[1]>          NA          NA
#>  88: 3aa78c12-60a5-44ac-84b9-86df0cfd366c <list[1]>          NA          NA
#>  89: 09f8b393-8b52-4f7a-b9b1-fde76fd03c02 <list[1]>          NA          NA
#>  90: 5af0a4c2-f458-4a11-9dff-7ffe929a3493 <list[1]>          NA          NA
#>  91: d397cf6c-5b1b-44b3-a9ac-8427110b2ed5 <list[1]>          NA          NA
#>  92: 19091764-396a-464c-a189-ac3da35cde24 <list[1]>          NA          NA
#>  93: 01bf1b52-5c2a-48cc-ad24-e664c1b477fe <list[1]>          NA          NA
#>  94: 8c7627db-5489-48d2-ab63-efa2bfd88350 <list[1]>          NA          NA
#>  95: aa126572-b7da-4903-8685-c128ec41eb23 <list[1]>          NA          NA
#>  96: 43d7be95-266c-44b2-b7c4-ae55f16236c2 <list[1]>          NA          NA
#>  97: ffdabaf6-fab5-4902-95c5-067e7641791c <list[1]>          NA          NA
#>  98: d99ca318-dcd2-4e79-a2af-22653690e835 <list[1]>          NA          NA
#>  99: 01ef99d2-bb2e-4747-a30e-ff1b8acf1452 <list[1]>          NA          NA
#> 100: f7f6ed1e-c2a5-45c1-b8a8-537c70d74c24 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
