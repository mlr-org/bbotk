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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-09-17 09:46:39
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-09-17 09:46:39
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-09-17 09:46:39
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-09-17 09:46:39
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-09-17 09:46:39
#>   6: finished -10.000000  0.5555556 -146.64198 2026-09-17 09:46:39
#>   7: finished -10.000000  1.6666667 -155.77778 2026-09-17 09:46:39
#>   8: finished -10.000000  2.7777778 -167.38272 2026-09-17 09:46:39
#>   9: finished -10.000000  3.8888889 -181.45679 2026-09-17 09:46:39
#>  10: finished -10.000000  5.0000000 -198.00000 2026-09-17 09:46:39
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-09-17 09:46:39
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-09-17 09:46:39
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-09-17 09:46:39
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-09-17 09:46:39
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-09-17 09:46:39
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-09-17 09:46:39
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-09-17 09:46:39
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-09-17 09:46:39
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-09-17 09:46:39
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-09-17 09:46:39
#>  21:   failed  10.000000  5.0000000         NA 2026-09-17 09:46:39
#>  22:   failed  10.000000  3.8888889         NA 2026-09-17 09:46:39
#>  23:   failed  10.000000  2.7777778         NA 2026-09-17 09:46:39
#>  24:   failed  10.000000  1.6666667         NA 2026-09-17 09:46:39
#>  25:   failed  10.000000  0.5555556         NA 2026-09-17 09:46:39
#>  26:   failed  10.000000 -0.5555556         NA 2026-09-17 09:46:39
#>  27:   failed  10.000000 -1.6666667         NA 2026-09-17 09:46:39
#>  28:   failed  10.000000 -2.7777778         NA 2026-09-17 09:46:39
#>  29:   failed  10.000000 -3.8888889         NA 2026-09-17 09:46:39
#>  30:   failed  10.000000 -5.0000000         NA 2026-09-17 09:46:39
#>  31:   failed   7.777778  5.0000000         NA 2026-09-17 09:46:39
#>  32:   failed   7.777778  3.8888889         NA 2026-09-17 09:46:39
#>  33:   failed   7.777778  2.7777778         NA 2026-09-17 09:46:39
#>  34:   failed   7.777778  1.6666667         NA 2026-09-17 09:46:39
#>  35:   failed   7.777778  0.5555556         NA 2026-09-17 09:46:39
#>  36:   failed   7.777778 -0.5555556         NA 2026-09-17 09:46:39
#>  37:   failed   7.777778 -1.6666667         NA 2026-09-17 09:46:39
#>  38:   failed   7.777778 -2.7777778         NA 2026-09-17 09:46:39
#>  39:   failed   7.777778 -3.8888889         NA 2026-09-17 09:46:39
#>  40:   failed   7.777778 -5.0000000         NA 2026-09-17 09:46:39
#>  41:   failed   5.555556  5.0000000         NA 2026-09-17 09:46:39
#>  42:   failed   5.555556  3.8888889         NA 2026-09-17 09:46:39
#>  43:   failed   5.555556  2.7777778         NA 2026-09-17 09:46:39
#>  44:   failed   5.555556  1.6666667         NA 2026-09-17 09:46:39
#>  45:   failed   5.555556  0.5555556         NA 2026-09-17 09:46:39
#>  46:   failed   5.555556 -0.5555556         NA 2026-09-17 09:46:39
#>  47:   failed   5.555556 -1.6666667         NA 2026-09-17 09:46:39
#>  48:   failed   5.555556 -2.7777778         NA 2026-09-17 09:46:39
#>  49:   failed   5.555556 -3.8888889         NA 2026-09-17 09:46:39
#>  50:   failed   5.555556 -5.0000000         NA 2026-09-17 09:46:39
#>  51:   failed   3.333333  5.0000000         NA 2026-09-17 09:46:39
#>  52:   failed   3.333333  3.8888889         NA 2026-09-17 09:46:39
#>  53:   failed   3.333333  2.7777778         NA 2026-09-17 09:46:39
#>  54:   failed   3.333333  1.6666667         NA 2026-09-17 09:46:39
#>  55:   failed   3.333333  0.5555556         NA 2026-09-17 09:46:39
#>  56:   failed   3.333333 -0.5555556         NA 2026-09-17 09:46:39
#>  57:   failed   3.333333 -1.6666667         NA 2026-09-17 09:46:39
#>  58:   failed   3.333333 -2.7777778         NA 2026-09-17 09:46:39
#>  59:   failed   3.333333 -3.8888889         NA 2026-09-17 09:46:39
#>  60:   failed   3.333333 -5.0000000         NA 2026-09-17 09:46:39
#>  61:   failed   1.111111  5.0000000         NA 2026-09-17 09:46:39
#>  62:   failed   1.111111  3.8888889         NA 2026-09-17 09:46:39
#>  63:   failed   1.111111  2.7777778         NA 2026-09-17 09:46:39
#>  64:   failed   1.111111  1.6666667         NA 2026-09-17 09:46:39
#>  65:   failed   1.111111  0.5555556         NA 2026-09-17 09:46:39
#>  66:   failed   1.111111 -0.5555556         NA 2026-09-17 09:46:39
#>  67:   failed   1.111111 -1.6666667         NA 2026-09-17 09:46:39
#>  68:   failed   1.111111 -2.7777778         NA 2026-09-17 09:46:39
#>  69:   failed   1.111111 -3.8888889         NA 2026-09-17 09:46:39
#>  70:   failed   1.111111 -5.0000000         NA 2026-09-17 09:46:39
#>  71:   failed  -1.111111  5.0000000         NA 2026-09-17 09:46:39
#>  72:   failed  -1.111111  3.8888889         NA 2026-09-17 09:46:39
#>  73:   failed  -1.111111  2.7777778         NA 2026-09-17 09:46:39
#>  74:   failed  -1.111111  1.6666667         NA 2026-09-17 09:46:39
#>  75:   failed  -1.111111  0.5555556         NA 2026-09-17 09:46:39
#>  76:   failed  -1.111111 -0.5555556         NA 2026-09-17 09:46:39
#>  77:   failed  -1.111111 -1.6666667         NA 2026-09-17 09:46:39
#>  78:   failed  -1.111111 -2.7777778         NA 2026-09-17 09:46:39
#>  79:   failed  -1.111111 -3.8888889         NA 2026-09-17 09:46:39
#>  80:   failed  -1.111111 -5.0000000         NA 2026-09-17 09:46:39
#>  81:   failed  -3.333333  5.0000000         NA 2026-09-17 09:46:39
#>  82:   failed  -3.333333  3.8888889         NA 2026-09-17 09:46:39
#>  83:   failed  -3.333333  2.7777778         NA 2026-09-17 09:46:39
#>  84:   failed  -3.333333  1.6666667         NA 2026-09-17 09:46:39
#>  85:   failed  -3.333333  0.5555556         NA 2026-09-17 09:46:39
#>  86:   failed  -3.333333 -0.5555556         NA 2026-09-17 09:46:39
#>  87:   failed  -3.333333 -1.6666667         NA 2026-09-17 09:46:39
#>  88:   failed  -3.333333 -2.7777778         NA 2026-09-17 09:46:39
#>  89:   failed  -3.333333 -3.8888889         NA 2026-09-17 09:46:39
#>  90:   failed  -3.333333 -5.0000000         NA 2026-09-17 09:46:39
#>  91:   failed  -5.555556  5.0000000         NA 2026-09-17 09:46:39
#>  92:   failed  -5.555556  3.8888889         NA 2026-09-17 09:46:39
#>  93:   failed  -5.555556  2.7777778         NA 2026-09-17 09:46:39
#>  94:   failed  -5.555556  1.6666667         NA 2026-09-17 09:46:39
#>  95:   failed  -5.555556  0.5555556         NA 2026-09-17 09:46:39
#>  96:   failed  -5.555556 -0.5555556         NA 2026-09-17 09:46:39
#>  97:   failed  -5.555556 -1.6666667         NA 2026-09-17 09:46:39
#>  98:   failed  -5.555556 -2.7777778         NA 2026-09-17 09:46:39
#>  99:   failed  -5.555556 -3.8888889         NA 2026-09-17 09:46:39
#> 100:   failed  -5.555556 -5.0000000         NA 2026-09-17 09:46:39
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   2: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   3: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   4: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   5: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   6: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   7: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   8: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>   9: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  10: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  11: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  12: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  13: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  14: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  15: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  16: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  17: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  18: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  19: sinking_raccoon_5315af3a 2026-09-17 09:46:40
#>  20: sinking_raccoon_5315af3a 2026-09-17 09:46:40
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
#>   1: c1dcb38e-a7c2-4359-a4d7-91a7250c29a9    [NULL]  -10.000000  -5.0000000
#>   2: 59f4a1a8-5bef-4ce8-9682-b6a74acd97ab    [NULL]  -10.000000  -3.8888889
#>   3: 50bf5255-bcd1-4ed2-b990-fad4f3b28934    [NULL]  -10.000000  -2.7777778
#>   4: e85b2461-b17f-43e0-9a4d-520302ebaadf    [NULL]  -10.000000  -1.6666667
#>   5: 82aaed1a-4196-45b7-a1fe-bec894fb8903    [NULL]  -10.000000  -0.5555556
#>   6: e3219a16-78a5-44df-a617-6db5445e151b    [NULL]  -10.000000   0.5555556
#>   7: a7f122a4-37c0-44fd-9934-f1d468df7dcf    [NULL]  -10.000000   1.6666667
#>   8: bbc6b260-11d7-4431-a7b6-91f697c4ec76    [NULL]  -10.000000   2.7777778
#>   9: f58675f4-1bd3-46b0-925e-a0d29342dbbc    [NULL]  -10.000000   3.8888889
#>  10: 0feb1a93-5823-4d3b-aade-30fd23dc1ba3    [NULL]  -10.000000   5.0000000
#>  11: a9693a36-ca0f-43e1-8323-6f1a48bd7a53    [NULL]   -7.777778  -5.0000000
#>  12: 7b297d47-759c-4bd7-91d5-285d728e02b9    [NULL]   -7.777778  -3.8888889
#>  13: 9eef06c7-3d87-43eb-8d36-b21d9c8253fd    [NULL]   -7.777778  -2.7777778
#>  14: 3363b1c2-8b65-4f67-b220-009e96b358c9    [NULL]   -7.777778  -1.6666667
#>  15: ae9465d0-1bd5-45a7-b929-aa03d28451c1    [NULL]   -7.777778  -0.5555556
#>  16: 1c2296eb-8f34-4724-b62c-07084f1b87d4    [NULL]   -7.777778   0.5555556
#>  17: d11d1c40-cc88-4938-a906-1d537d803c54    [NULL]   -7.777778   1.6666667
#>  18: f78954a4-8875-4f2a-b197-62b3182c6e9a    [NULL]   -7.777778   2.7777778
#>  19: 3ceb337c-af7d-4ed1-bfb7-47779470c52f    [NULL]   -7.777778   3.8888889
#>  20: 0be52564-4a05-4ea2-bd1c-b1619d151795    [NULL]   -7.777778   5.0000000
#>  21: 5449df17-4027-45c7-b6b7-1b90d3edd9d8 <list[1]>          NA          NA
#>  22: 67b0ecec-6e78-4e0c-a69e-988d6476a2e4 <list[1]>          NA          NA
#>  23: 95b14b67-a5d7-4b34-aa1c-c9618d16aaf5 <list[1]>          NA          NA
#>  24: 59290fda-9a5c-4b0f-8555-59d8e2b92691 <list[1]>          NA          NA
#>  25: 7e1f4223-c016-47d1-92a7-18c5863a1962 <list[1]>          NA          NA
#>  26: 4bfa2be9-b5eb-480b-be1c-1050a7c1076a <list[1]>          NA          NA
#>  27: fa5ab6bf-3f8c-4244-904e-b45c281d8334 <list[1]>          NA          NA
#>  28: 09500091-6146-434c-bb62-da15a2d52e9a <list[1]>          NA          NA
#>  29: c8fa838c-0ae1-41d0-94de-75dbbeb81d6a <list[1]>          NA          NA
#>  30: 3c1d719a-d8ed-445a-8e4a-5cd17d292830 <list[1]>          NA          NA
#>  31: 54fd5c02-78e4-4123-a814-3533300ff6da <list[1]>          NA          NA
#>  32: a41cab83-8271-46ca-aced-f6d60ab0e431 <list[1]>          NA          NA
#>  33: 0e74165c-17db-4c68-ad7e-2095f5c75f70 <list[1]>          NA          NA
#>  34: b3184587-3186-4292-9626-4d5a3c863c2e <list[1]>          NA          NA
#>  35: 14674cf0-048e-40d9-ba54-7ab85ce37af4 <list[1]>          NA          NA
#>  36: 73c0d879-f8c9-42bf-898a-098786467e28 <list[1]>          NA          NA
#>  37: a451114c-4c4e-4d34-ac53-3c649ed8eb41 <list[1]>          NA          NA
#>  38: d8c815c3-2cff-4ac1-a581-e4a43e27c9c7 <list[1]>          NA          NA
#>  39: b9b41be6-975b-4ad9-83f5-0377dcf1e713 <list[1]>          NA          NA
#>  40: c419cef4-2444-4e94-ad00-eb26c901bb49 <list[1]>          NA          NA
#>  41: 33ff9f62-2dd0-458d-9c63-8875108cc7bd <list[1]>          NA          NA
#>  42: 97e317d9-0d64-4360-b911-894843a5bd1a <list[1]>          NA          NA
#>  43: 5c407a4d-fa2a-42a2-af12-b0c9f48f4831 <list[1]>          NA          NA
#>  44: c74aaf2f-dfac-4a3e-8bea-e9920e983013 <list[1]>          NA          NA
#>  45: 700814e0-2e8e-4150-84a3-f3577f6c48ca <list[1]>          NA          NA
#>  46: b53d14fb-db04-458a-9cc8-d44e8fb1dae3 <list[1]>          NA          NA
#>  47: e44d7570-53ab-4de6-b269-f917f2282e74 <list[1]>          NA          NA
#>  48: 35192863-8339-49ab-9f3f-9eff7de8df61 <list[1]>          NA          NA
#>  49: 2df14e02-630b-4187-afab-cdae67a85276 <list[1]>          NA          NA
#>  50: 7a3db16e-1a55-43c1-a066-8250f0f1924d <list[1]>          NA          NA
#>  51: baf27cf7-be2e-415c-9105-8d6773d33a47 <list[1]>          NA          NA
#>  52: 5682c66f-5a59-4693-a31e-8ba1fd0a06c6 <list[1]>          NA          NA
#>  53: 9d208fd1-07c5-49a2-9460-afd9e0ade380 <list[1]>          NA          NA
#>  54: 77997485-104b-4c81-b7ce-fd662c977498 <list[1]>          NA          NA
#>  55: c783af04-28d8-43e3-9c2b-9844ade84e73 <list[1]>          NA          NA
#>  56: c5f659c4-153b-4059-96e6-738bafc769e5 <list[1]>          NA          NA
#>  57: 8bf083b4-03be-4eb7-b05e-042a7018be8a <list[1]>          NA          NA
#>  58: d3a8d164-760b-46ae-adf5-890e8af2dc0e <list[1]>          NA          NA
#>  59: 601c3893-572c-40ce-bafd-fdf28823f1e6 <list[1]>          NA          NA
#>  60: beb61ff7-1d4b-4ef2-a264-406f840a4b19 <list[1]>          NA          NA
#>  61: d6845d3e-3856-4d7b-8397-befacfac8f70 <list[1]>          NA          NA
#>  62: 21fbcd93-ab4a-413b-bd48-43a217f4d161 <list[1]>          NA          NA
#>  63: f487b132-9029-42cf-80b1-744a14450cfc <list[1]>          NA          NA
#>  64: a6b19a6d-4f75-4be3-b783-8ab96cec0780 <list[1]>          NA          NA
#>  65: 6dc4711d-aea6-4987-9a6f-375614b50344 <list[1]>          NA          NA
#>  66: 6e91c792-7806-44a6-9e6f-5bebd106b627 <list[1]>          NA          NA
#>  67: 2bf63bfb-84b1-4de9-ab03-43e9ac29cea9 <list[1]>          NA          NA
#>  68: bf70a251-86f4-4453-a0b5-5c8bdcf737b3 <list[1]>          NA          NA
#>  69: fb16199f-7233-47f9-be20-6873f2bad2af <list[1]>          NA          NA
#>  70: 5e6d203a-1cc7-4f65-bbce-7ef684638fa3 <list[1]>          NA          NA
#>  71: a84aec85-9bfa-4470-8997-a2f38613364b <list[1]>          NA          NA
#>  72: 323bee3b-2a9e-474b-8982-6a7e3f5f5436 <list[1]>          NA          NA
#>  73: 565ae5df-77f7-4518-a36b-62edbb68a0db <list[1]>          NA          NA
#>  74: 00f561e0-eeb6-41cf-8ec7-39ccb6e1fc55 <list[1]>          NA          NA
#>  75: c7facd9e-91f9-48ec-9e5a-97bff8a1a04b <list[1]>          NA          NA
#>  76: 0c02d563-ea4e-45d8-9da7-835b4236d8b5 <list[1]>          NA          NA
#>  77: 2dc458a4-2b28-4bc7-8158-fa71dd56723b <list[1]>          NA          NA
#>  78: f0da83af-b684-46c2-9fc6-34466f027a83 <list[1]>          NA          NA
#>  79: f9bef5de-25d1-41c2-8381-bb2dbf0f71e3 <list[1]>          NA          NA
#>  80: dfb8e199-947c-4ab0-a926-3248404facc7 <list[1]>          NA          NA
#>  81: 81a9fd44-7365-4e88-b8c3-bb64d0938ea8 <list[1]>          NA          NA
#>  82: e4c606c0-02bd-4f2f-84c2-636cf3464ad9 <list[1]>          NA          NA
#>  83: cd1694dd-aad9-44f5-b00c-017fd2ab4d09 <list[1]>          NA          NA
#>  84: 23ae3595-5647-4213-acfe-11e02a5d137a <list[1]>          NA          NA
#>  85: 261ebed8-3e23-4320-a75f-2188a93dc627 <list[1]>          NA          NA
#>  86: b939ea27-9abe-4156-84c5-e8cfad7aff30 <list[1]>          NA          NA
#>  87: 543a826f-56f3-4e17-8047-286668191b9e <list[1]>          NA          NA
#>  88: 6d917349-a48d-4311-b0aa-3e98602379fa <list[1]>          NA          NA
#>  89: 520df479-8eef-4dfa-a1ad-da62c198e900 <list[1]>          NA          NA
#>  90: af0c9b45-8e00-4032-a648-27ef014849d0 <list[1]>          NA          NA
#>  91: f49f1368-068b-40b8-ac49-5c1c1ce5a6db <list[1]>          NA          NA
#>  92: b3185910-9430-423b-89bd-b6af1c5fb2ad <list[1]>          NA          NA
#>  93: b491af5d-3e14-4064-b920-0f1ca6774929 <list[1]>          NA          NA
#>  94: 35ad92b9-5507-4e16-b5a0-caddb4906820 <list[1]>          NA          NA
#>  95: 138fa034-2c13-4c8d-9c26-bc619b52540b <list[1]>          NA          NA
#>  96: ef993f05-470f-4530-adfc-5083d398c430 <list[1]>          NA          NA
#>  97: 08772374-221c-4a84-ace4-e0a9d21c7a71 <list[1]>          NA          NA
#>  98: 357843c6-93ea-48fb-a601-7d703ba609d3 <list[1]>          NA          NA
#>  99: 856341b4-6dd0-4cbf-bd31-cf68add9841e <list[1]>          NA          NA
#> 100: 2ff85604-fe53-4403-a84d-7cdb57383eed <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
