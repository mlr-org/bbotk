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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-03 12:10:54
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-03 12:10:54
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-03 12:10:54
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-03 12:10:54
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-03 12:10:54
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-03 12:10:54
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-03 12:10:54
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-03 12:10:54
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-03 12:10:54
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-03 12:10:54
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-03 12:10:54
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-03 12:10:54
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-03 12:10:54
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-03 12:10:54
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-03 12:10:54
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-03 12:10:54
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-03 12:10:54
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-03 12:10:54
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-03 12:10:54
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-03 12:10:54
#>  21:   failed  10.000000  5.0000000         NA 2026-09-03 12:10:54
#>  22:   failed  10.000000  3.8888889         NA 2026-09-03 12:10:54
#>  23:   failed  10.000000  2.7777778         NA 2026-09-03 12:10:54
#>  24:   failed  10.000000  1.6666667         NA 2026-09-03 12:10:54
#>  25:   failed  10.000000  0.5555556         NA 2026-09-03 12:10:54
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-03 12:10:54
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-03 12:10:54
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-03 12:10:54
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-03 12:10:54
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-03 12:10:54
#>  31:   failed   7.777778  5.0000000         NA 2026-09-03 12:10:54
#>  32:   failed   7.777778  3.8888889         NA 2026-09-03 12:10:54
#>  33:   failed   7.777778  2.7777778         NA 2026-09-03 12:10:54
#>  34:   failed   7.777778  1.6666667         NA 2026-09-03 12:10:54
#>  35:   failed   7.777778  0.5555556         NA 2026-09-03 12:10:54
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-03 12:10:54
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-03 12:10:54
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-03 12:10:54
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-03 12:10:54
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-03 12:10:54
#>  41:   failed   5.555556  5.0000000         NA 2026-09-03 12:10:54
#>  42:   failed   5.555556  3.8888889         NA 2026-09-03 12:10:54
#>  43:   failed   5.555556  2.7777778         NA 2026-09-03 12:10:54
#>  44:   failed   5.555556  1.6666667         NA 2026-09-03 12:10:54
#>  45:   failed   5.555556  0.5555556         NA 2026-09-03 12:10:54
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-03 12:10:54
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-03 12:10:54
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-03 12:10:54
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-03 12:10:54
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-03 12:10:54
#>  51:   failed   3.333333  5.0000000         NA 2026-09-03 12:10:54
#>  52:   failed   3.333333  3.8888889         NA 2026-09-03 12:10:54
#>  53:   failed   3.333333  2.7777778         NA 2026-09-03 12:10:54
#>  54:   failed   3.333333  1.6666667         NA 2026-09-03 12:10:54
#>  55:   failed   3.333333  0.5555556         NA 2026-09-03 12:10:54
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-03 12:10:54
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-03 12:10:54
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-03 12:10:54
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-03 12:10:54
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-03 12:10:54
#>  61:   failed   1.111111  5.0000000         NA 2026-09-03 12:10:54
#>  62:   failed   1.111111  3.8888889         NA 2026-09-03 12:10:54
#>  63:   failed   1.111111  2.7777778         NA 2026-09-03 12:10:54
#>  64:   failed   1.111111  1.6666667         NA 2026-09-03 12:10:54
#>  65:   failed   1.111111  0.5555556         NA 2026-09-03 12:10:54
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-03 12:10:54
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-03 12:10:54
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-03 12:10:54
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-03 12:10:54
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-03 12:10:54
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-03 12:10:54
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-03 12:10:54
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-03 12:10:54
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-03 12:10:54
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-03 12:10:54
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-03 12:10:54
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-03 12:10:54
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-03 12:10:54
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-03 12:10:54
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-03 12:10:54
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-03 12:10:54
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-03 12:10:54
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-03 12:10:54
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-03 12:10:54
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-03 12:10:54
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-03 12:10:54
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-03 12:10:54
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-03 12:10:54
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-03 12:10:54
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-03 12:10:54
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-03 12:10:54
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-03 12:10:54
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-03 12:10:54
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-03 12:10:54
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-03 12:10:54
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-03 12:10:54
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-03 12:10:54
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-03 12:10:54
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-03 12:10:54
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-03 12:10:54
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   2: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   3: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   4: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   5: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   6: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   7: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   8: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>   9: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  10: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  11: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  12: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  13: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  14: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  15: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  16: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  17: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  18: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  19: sinking_raccoon_45120eea 2026-09-03 12:10:55
#>  20: sinking_raccoon_45120eea 2026-09-03 12:10:55
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
#>   1: a938820b-185e-4590-9899-c972ee8d05a4    [NULL]  -10.000000  -5.0000000
#>   2: 2ae1f76d-a9e6-4082-98ec-849ffa9746d1    [NULL]  -10.000000  -3.8888889
#>   3: dcc695f8-d1a2-48b7-983e-1d82aa85556f    [NULL]  -10.000000  -2.7777778
#>   4: 969a30eb-ddca-459d-9a5b-5029c41816f0    [NULL]  -10.000000  -1.6666667
#>   5: fae79ae1-78db-43f0-ac8c-1cd759a8cb34    [NULL]  -10.000000  -0.5555556
#>   6: e27cff13-030d-4b63-a9ca-f288f4a6b522    [NULL]  -10.000000   0.5555556
#>   7: c327a509-0709-49c7-a66d-d0eca2bd2bee    [NULL]  -10.000000   1.6666667
#>   8: 2744dd82-d300-4753-83a7-69e111c9d582    [NULL]  -10.000000   2.7777778
#>   9: ad1e93b2-3de4-4b27-98e8-eeab50e745b5    [NULL]  -10.000000   3.8888889
#>  10: fe0be7f5-6fa7-4d7c-8b01-d7c310604036    [NULL]  -10.000000   5.0000000
#>  11: daf7463c-8487-4908-a9e7-285d4f3b585e    [NULL]   -7.777778  -5.0000000
#>  12: 39c1c261-d56e-46fd-9509-d4e6bc10c48b    [NULL]   -7.777778  -3.8888889
#>  13: 130100fe-980b-407e-a758-c1c8d427cff8    [NULL]   -7.777778  -2.7777778
#>  14: efbb4b4b-987a-44d0-ab78-425139490444    [NULL]   -7.777778  -1.6666667
#>  15: c31a8646-5033-4163-8918-132e0228b670    [NULL]   -7.777778  -0.5555556
#>  16: 15a723ad-6db8-489d-84be-fd3311e62d37    [NULL]   -7.777778   0.5555556
#>  17: d6b3f368-c9cc-4a42-978b-a613d6cddd33    [NULL]   -7.777778   1.6666667
#>  18: 275ab945-5c2f-428f-84eb-82046bf9d4a8    [NULL]   -7.777778   2.7777778
#>  19: 1081f6d3-ae6b-422d-85da-e2e9e06165de    [NULL]   -7.777778   3.8888889
#>  20: 7ba1c81a-d20b-4cdb-9ed1-ccdb5b315a7f    [NULL]   -7.777778   5.0000000
#>  21: 639701d7-f436-4952-9abe-c7c526a14118 <list[1]>          NA          NA
#>  22: 59cf5217-40d6-40c2-ab2e-d58107e1dbea <list[1]>          NA          NA
#>  23: c3bba4e3-50f9-48e5-a11d-fdf11c090065 <list[1]>          NA          NA
#>  24: ebaef9cc-0542-4c0f-aa6b-6a5709cedbeb <list[1]>          NA          NA
#>  25: 7f8c22a6-cf2d-46f3-8f01-97588113e2b6 <list[1]>          NA          NA
#>  26: 5fe7578b-7f98-4472-bee6-026aca3d2814 <list[1]>          NA          NA
#>  27: d8a76b61-ecc7-49cb-9a00-35b6da5d9d39 <list[1]>          NA          NA
#>  28: b03b3ad2-e871-4114-bf39-5f23edcef1db <list[1]>          NA          NA
#>  29: 43737fe4-8307-48f4-af9e-3f03e17a01f1 <list[1]>          NA          NA
#>  30: 984cd052-8289-4a27-9aa2-09b8d68a5770 <list[1]>          NA          NA
#>  31: 4dc837ee-2352-47c4-9f49-3f8d65e5c912 <list[1]>          NA          NA
#>  32: ebb91b85-c131-4290-b96b-8ca129c50dd9 <list[1]>          NA          NA
#>  33: f57964a2-873e-4cd4-87cc-3f997e63361a <list[1]>          NA          NA
#>  34: 4c18c47e-34fc-4afa-947c-e853a2bbeb49 <list[1]>          NA          NA
#>  35: 7ce27bf0-4472-45f0-a8f0-09f119a8f6ae <list[1]>          NA          NA
#>  36: b5946914-44ab-428b-8781-ccb1e7e9dc6c <list[1]>          NA          NA
#>  37: 5a3b3319-6b2b-4fb7-bdee-206294c19810 <list[1]>          NA          NA
#>  38: b8f75a6e-ca76-470e-9bbb-9b222e8252c1 <list[1]>          NA          NA
#>  39: bca8131a-8660-4c19-a861-c2cc14a78400 <list[1]>          NA          NA
#>  40: 44d089f9-dfba-4077-96e4-d62c3328b6af <list[1]>          NA          NA
#>  41: ceb28814-f62d-45aa-aa5f-b0b3c540478e <list[1]>          NA          NA
#>  42: 863ece69-5029-4875-be22-dcd456344021 <list[1]>          NA          NA
#>  43: 7f0ea4b6-8265-4f10-8cb4-9aa8b4fcbed6 <list[1]>          NA          NA
#>  44: 901dfa26-3bb8-4499-8c52-9255b339045f <list[1]>          NA          NA
#>  45: 118078d4-1b57-4124-aaa7-ffcb0b0a371e <list[1]>          NA          NA
#>  46: a310dd27-ab25-4bbb-a77c-7e152efe9e95 <list[1]>          NA          NA
#>  47: a8576a89-6aa1-4691-adc1-1b5322500085 <list[1]>          NA          NA
#>  48: 945224f9-47a2-4064-a03b-fbe12dc5d1e5 <list[1]>          NA          NA
#>  49: c643dd9d-0b0d-42f5-a0fc-aeee0c26527d <list[1]>          NA          NA
#>  50: a955f410-a2b2-4c80-927b-88272ad10973 <list[1]>          NA          NA
#>  51: 52eeaed2-688e-4638-8496-6d5f5739f3a3 <list[1]>          NA          NA
#>  52: 3748d8b6-a1bf-4c7f-9658-f3617cbc5f5b <list[1]>          NA          NA
#>  53: 1b522a67-bd09-4e45-9a5e-45a4f359c47b <list[1]>          NA          NA
#>  54: 16a5e451-9f3b-4b20-aeb7-54a8f06c33ac <list[1]>          NA          NA
#>  55: 81de84bc-f91d-4a01-849e-dfb32b5444b3 <list[1]>          NA          NA
#>  56: d1fdade1-dec5-4925-856f-b48c6bd8720c <list[1]>          NA          NA
#>  57: fe271bd1-1e29-4530-b5c6-f82900625c65 <list[1]>          NA          NA
#>  58: d513595d-9b78-41bf-a589-7746ecafe44b <list[1]>          NA          NA
#>  59: dd85a314-9eab-475c-bfa0-7602d86b1471 <list[1]>          NA          NA
#>  60: 84b26280-e08f-45c7-a05e-c129706867a1 <list[1]>          NA          NA
#>  61: 59ccef9e-63ec-4181-b1a0-a25c9c779006 <list[1]>          NA          NA
#>  62: 9a0cf8e4-d7be-4db2-ab18-8ad5ca52c4f2 <list[1]>          NA          NA
#>  63: 6a61b3a2-b2ee-4270-9356-4b63f7ae7c61 <list[1]>          NA          NA
#>  64: 0389e1d1-6a69-44ed-97af-bad3834f899c <list[1]>          NA          NA
#>  65: 19700b6e-ca0b-4d26-9da1-6f2c179c0955 <list[1]>          NA          NA
#>  66: 0ed96b15-7220-4047-b5d2-c661d9ec1095 <list[1]>          NA          NA
#>  67: dc0209b0-a22a-4e57-bfe6-9504e7bd39b6 <list[1]>          NA          NA
#>  68: a2b45420-28d4-4142-a48e-2fc0e2bb8424 <list[1]>          NA          NA
#>  69: fc50bbfd-2d94-41b1-a4aa-b5a376123c58 <list[1]>          NA          NA
#>  70: 113118d6-badd-481a-8e9d-87c6e00a68d0 <list[1]>          NA          NA
#>  71: 2d8bb830-4db4-4686-9b50-04761c54d7f2 <list[1]>          NA          NA
#>  72: 2b9bba89-adfc-467e-accf-02b1278d20e9 <list[1]>          NA          NA
#>  73: 2f62ef35-29e0-4014-b7f5-bedcbfde7fad <list[1]>          NA          NA
#>  74: de706c18-cd2f-4b5c-aff7-074c5a05d8fb <list[1]>          NA          NA
#>  75: 50bb91ff-958d-42d1-9c26-c216e883d6e6 <list[1]>          NA          NA
#>  76: 8400eac7-278f-4d02-9548-2ab3fe581999 <list[1]>          NA          NA
#>  77: 7d108dcb-2875-4730-8a9e-ef1702f12e83 <list[1]>          NA          NA
#>  78: f3424f16-b5d5-423d-a6ee-3d41a6087097 <list[1]>          NA          NA
#>  79: 53904f88-08f6-4ff1-bdec-7201b623da8e <list[1]>          NA          NA
#>  80: 6d6b2791-313b-4cba-917d-ddeb3d9bf8cc <list[1]>          NA          NA
#>  81: 0afa3d49-c7e9-4f1f-9732-8a34654d309b <list[1]>          NA          NA
#>  82: 2d775751-097c-4d16-a71f-e7236e63d287 <list[1]>          NA          NA
#>  83: b943926b-4da2-46f4-a84d-2969eae492e1 <list[1]>          NA          NA
#>  84: 709315c0-22cf-487a-8bb7-7273cccda765 <list[1]>          NA          NA
#>  85: 10b38a90-f09f-4ec8-92fe-065fe1e149f4 <list[1]>          NA          NA
#>  86: 11619205-2d08-4fd4-a6e3-8f43b124d142 <list[1]>          NA          NA
#>  87: a0cb7e6f-9220-41d6-9b0a-efa8fc276755 <list[1]>          NA          NA
#>  88: b9539eea-3b71-4773-b972-37fa206697aa <list[1]>          NA          NA
#>  89: b578cd0c-e44d-47c5-9309-2c58633230b7 <list[1]>          NA          NA
#>  90: e6c434db-be68-41a6-a4ce-d46bb9e507ea <list[1]>          NA          NA
#>  91: 2975a2f3-4274-4d43-a3ff-e2fa58111b14 <list[1]>          NA          NA
#>  92: 000e02f4-8ac6-4d3c-823c-78437b9ceb7d <list[1]>          NA          NA
#>  93: cabb2126-665c-4ab5-8ca2-70ac76ddaaff <list[1]>          NA          NA
#>  94: ff7ba950-82ef-4288-8b1a-2267c3eaa1fa <list[1]>          NA          NA
#>  95: c7fa0e50-3db0-41bb-843b-724fcb1eacc5 <list[1]>          NA          NA
#>  96: 843f5f97-330f-4c87-b2ae-bc43b3ccd601 <list[1]>          NA          NA
#>  97: 032d8e56-17b0-4e00-985f-2e56698035b2 <list[1]>          NA          NA
#>  98: 9e36c9c6-1165-4938-af9a-6d7a75bf54f9 <list[1]>          NA          NA
#>  99: 07988497-2b91-4811-85d0-9e3feb76b0ca <list[1]>          NA          NA
#> 100: 484736f6-5261-4c20-98f4-de562efa4c36 <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
