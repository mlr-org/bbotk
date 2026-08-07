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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-08-07 14:43:49
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-08-07 14:43:49
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-08-07 14:43:49
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-08-07 14:43:49
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-08-07 14:43:49
#>   6: finished -10.000000  0.5555556 -146.64198 2026-08-07 14:43:49
#>   7: finished -10.000000  1.6666667 -155.77778 2026-08-07 14:43:49
#>   8: finished -10.000000  2.7777778 -167.38272 2026-08-07 14:43:49
#>   9: finished -10.000000  3.8888889 -181.45679 2026-08-07 14:43:49
#>  10: finished -10.000000  5.0000000 -198.00000 2026-08-07 14:43:49
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-08-07 14:43:49
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-08-07 14:43:49
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-08-07 14:43:49
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-08-07 14:43:49
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-08-07 14:43:49
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-08-07 14:43:49
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-08-07 14:43:49
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-08-07 14:43:49
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-08-07 14:43:49
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-08-07 14:43:49
#>  21:   failed  10.000000  5.0000000         NA 2026-08-07 14:43:49
#>  22:   failed  10.000000  3.8888889         NA 2026-08-07 14:43:49
#>  23:   failed  10.000000  2.7777778         NA 2026-08-07 14:43:49
#>  24:   failed  10.000000  1.6666667         NA 2026-08-07 14:43:49
#>  25:   failed  10.000000  0.5555556         NA 2026-08-07 14:43:49
#>  26:   failed  10.000000 -0.5555556         NA 2026-08-07 14:43:49
#>  27:   failed  10.000000 -1.6666667         NA 2026-08-07 14:43:49
#>  28:   failed  10.000000 -2.7777778         NA 2026-08-07 14:43:49
#>  29:   failed  10.000000 -3.8888889         NA 2026-08-07 14:43:49
#>  30:   failed  10.000000 -5.0000000         NA 2026-08-07 14:43:49
#>  31:   failed   7.777778  5.0000000         NA 2026-08-07 14:43:49
#>  32:   failed   7.777778  3.8888889         NA 2026-08-07 14:43:49
#>  33:   failed   7.777778  2.7777778         NA 2026-08-07 14:43:49
#>  34:   failed   7.777778  1.6666667         NA 2026-08-07 14:43:49
#>  35:   failed   7.777778  0.5555556         NA 2026-08-07 14:43:49
#>  36:   failed   7.777778 -0.5555556         NA 2026-08-07 14:43:49
#>  37:   failed   7.777778 -1.6666667         NA 2026-08-07 14:43:49
#>  38:   failed   7.777778 -2.7777778         NA 2026-08-07 14:43:49
#>  39:   failed   7.777778 -3.8888889         NA 2026-08-07 14:43:49
#>  40:   failed   7.777778 -5.0000000         NA 2026-08-07 14:43:49
#>  41:   failed   5.555556  5.0000000         NA 2026-08-07 14:43:49
#>  42:   failed   5.555556  3.8888889         NA 2026-08-07 14:43:49
#>  43:   failed   5.555556  2.7777778         NA 2026-08-07 14:43:49
#>  44:   failed   5.555556  1.6666667         NA 2026-08-07 14:43:49
#>  45:   failed   5.555556  0.5555556         NA 2026-08-07 14:43:49
#>  46:   failed   5.555556 -0.5555556         NA 2026-08-07 14:43:49
#>  47:   failed   5.555556 -1.6666667         NA 2026-08-07 14:43:49
#>  48:   failed   5.555556 -2.7777778         NA 2026-08-07 14:43:49
#>  49:   failed   5.555556 -3.8888889         NA 2026-08-07 14:43:49
#>  50:   failed   5.555556 -5.0000000         NA 2026-08-07 14:43:49
#>  51:   failed   3.333333  5.0000000         NA 2026-08-07 14:43:49
#>  52:   failed   3.333333  3.8888889         NA 2026-08-07 14:43:49
#>  53:   failed   3.333333  2.7777778         NA 2026-08-07 14:43:49
#>  54:   failed   3.333333  1.6666667         NA 2026-08-07 14:43:49
#>  55:   failed   3.333333  0.5555556         NA 2026-08-07 14:43:49
#>  56:   failed   3.333333 -0.5555556         NA 2026-08-07 14:43:49
#>  57:   failed   3.333333 -1.6666667         NA 2026-08-07 14:43:49
#>  58:   failed   3.333333 -2.7777778         NA 2026-08-07 14:43:49
#>  59:   failed   3.333333 -3.8888889         NA 2026-08-07 14:43:49
#>  60:   failed   3.333333 -5.0000000         NA 2026-08-07 14:43:49
#>  61:   failed   1.111111  5.0000000         NA 2026-08-07 14:43:49
#>  62:   failed   1.111111  3.8888889         NA 2026-08-07 14:43:49
#>  63:   failed   1.111111  2.7777778         NA 2026-08-07 14:43:49
#>  64:   failed   1.111111  1.6666667         NA 2026-08-07 14:43:49
#>  65:   failed   1.111111  0.5555556         NA 2026-08-07 14:43:49
#>  66:   failed   1.111111 -0.5555556         NA 2026-08-07 14:43:49
#>  67:   failed   1.111111 -1.6666667         NA 2026-08-07 14:43:49
#>  68:   failed   1.111111 -2.7777778         NA 2026-08-07 14:43:49
#>  69:   failed   1.111111 -3.8888889         NA 2026-08-07 14:43:49
#>  70:   failed   1.111111 -5.0000000         NA 2026-08-07 14:43:49
#>  71:   failed  -1.111111  5.0000000         NA 2026-08-07 14:43:49
#>  72:   failed  -1.111111  3.8888889         NA 2026-08-07 14:43:49
#>  73:   failed  -1.111111  2.7777778         NA 2026-08-07 14:43:49
#>  74:   failed  -1.111111  1.6666667         NA 2026-08-07 14:43:49
#>  75:   failed  -1.111111  0.5555556         NA 2026-08-07 14:43:49
#>  76:   failed  -1.111111 -0.5555556         NA 2026-08-07 14:43:49
#>  77:   failed  -1.111111 -1.6666667         NA 2026-08-07 14:43:49
#>  78:   failed  -1.111111 -2.7777778         NA 2026-08-07 14:43:49
#>  79:   failed  -1.111111 -3.8888889         NA 2026-08-07 14:43:49
#>  80:   failed  -1.111111 -5.0000000         NA 2026-08-07 14:43:49
#>  81:   failed  -3.333333  5.0000000         NA 2026-08-07 14:43:49
#>  82:   failed  -3.333333  3.8888889         NA 2026-08-07 14:43:49
#>  83:   failed  -3.333333  2.7777778         NA 2026-08-07 14:43:49
#>  84:   failed  -3.333333  1.6666667         NA 2026-08-07 14:43:49
#>  85:   failed  -3.333333  0.5555556         NA 2026-08-07 14:43:49
#>  86:   failed  -3.333333 -0.5555556         NA 2026-08-07 14:43:49
#>  87:   failed  -3.333333 -1.6666667         NA 2026-08-07 14:43:49
#>  88:   failed  -3.333333 -2.7777778         NA 2026-08-07 14:43:49
#>  89:   failed  -3.333333 -3.8888889         NA 2026-08-07 14:43:49
#>  90:   failed  -3.333333 -5.0000000         NA 2026-08-07 14:43:49
#>  91:   failed  -5.555556  5.0000000         NA 2026-08-07 14:43:49
#>  92:   failed  -5.555556  3.8888889         NA 2026-08-07 14:43:49
#>  93:   failed  -5.555556  2.7777778         NA 2026-08-07 14:43:49
#>  94:   failed  -5.555556  1.6666667         NA 2026-08-07 14:43:49
#>  95:   failed  -5.555556  0.5555556         NA 2026-08-07 14:43:49
#>  96:   failed  -5.555556 -0.5555556         NA 2026-08-07 14:43:49
#>  97:   failed  -5.555556 -1.6666667         NA 2026-08-07 14:43:49
#>  98:   failed  -5.555556 -2.7777778         NA 2026-08-07 14:43:49
#>  99:   failed  -5.555556 -3.8888889         NA 2026-08-07 14:43:49
#> 100:   failed  -5.555556 -5.0000000         NA 2026-08-07 14:43:49
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#>   1: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   2: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   3: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   4: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   5: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   6: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   7: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   8: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>   9: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  10: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  11: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  12: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  13: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  14: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  15: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  16: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  17: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  18: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  19: sinking_raccoon_f675537a 2026-08-07 14:43:50
#>  20: sinking_raccoon_f675537a 2026-08-07 14:43:50
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
#>   1: a4077d1b-e4d6-4be0-8ddc-949a517fd470    [NULL]  -10.000000  -5.0000000
#>   2: 800e76e4-73cf-4e6e-82ec-ca978f538a83    [NULL]  -10.000000  -3.8888889
#>   3: f92f90b4-4174-4fc1-b160-b458595aa992    [NULL]  -10.000000  -2.7777778
#>   4: 5f1b8809-8c5e-4ccd-9741-d005e3d75149    [NULL]  -10.000000  -1.6666667
#>   5: c6568c09-3940-417a-80d0-3be102d00ed3    [NULL]  -10.000000  -0.5555556
#>   6: b3badd25-4f75-4584-a9e1-546d6d97d69a    [NULL]  -10.000000   0.5555556
#>   7: ee5ba50a-c2ba-49d7-923a-ac851650a777    [NULL]  -10.000000   1.6666667
#>   8: be276793-bd5a-40a1-89e4-994070fe6015    [NULL]  -10.000000   2.7777778
#>   9: e0cff18c-0ac8-438e-ba51-8ff280462ac4    [NULL]  -10.000000   3.8888889
#>  10: 3ac182d5-f960-4a0d-af0c-a5082326d7ed    [NULL]  -10.000000   5.0000000
#>  11: 24886b45-5fec-483b-a3ba-a5beddc36590    [NULL]   -7.777778  -5.0000000
#>  12: bb049eb5-f8a3-47c3-b03a-07df85ce8071    [NULL]   -7.777778  -3.8888889
#>  13: 66d068ee-e24d-4d3d-b5e2-113a3414e1cb    [NULL]   -7.777778  -2.7777778
#>  14: 9e48d63f-2857-49a9-94f5-36755c32a74d    [NULL]   -7.777778  -1.6666667
#>  15: cc8d6f30-2269-44a7-b510-cfbaa23c6d09    [NULL]   -7.777778  -0.5555556
#>  16: 362cba64-fb03-4fae-9cad-f6bbe899c437    [NULL]   -7.777778   0.5555556
#>  17: 3d816adc-555d-4805-b9f1-a714638fdb38    [NULL]   -7.777778   1.6666667
#>  18: 83590a0c-2925-4b4e-bd50-b4ffa41f066d    [NULL]   -7.777778   2.7777778
#>  19: 8bcfa928-30a3-4bab-afba-3ec769610c96    [NULL]   -7.777778   3.8888889
#>  20: c6116b96-e61c-47ea-8b7d-e1d1ef961896    [NULL]   -7.777778   5.0000000
#>  21: 7dcf73ab-9eaf-4dfc-a088-ad9659f9a659 <list[1]>          NA          NA
#>  22: ead6390f-aeea-4e32-8672-67630f00e792 <list[1]>          NA          NA
#>  23: 30ddc00d-9247-4593-a02a-13de0bef42a8 <list[1]>          NA          NA
#>  24: b1965c78-31e6-4d0e-a312-51da59ba39f5 <list[1]>          NA          NA
#>  25: 5434bcd2-a3d9-4102-b450-79a45a3a895f <list[1]>          NA          NA
#>  26: 1709b05e-4ec5-418a-a3b8-e3b065779255 <list[1]>          NA          NA
#>  27: 1b671b9c-8246-4d59-aef6-79a32c13c984 <list[1]>          NA          NA
#>  28: 4842a865-fabe-4cbb-953c-eccdd149156d <list[1]>          NA          NA
#>  29: eaf15377-6584-42cb-99b6-af78aa16532e <list[1]>          NA          NA
#>  30: 0e6b37be-68e4-4168-8a16-95d5f1655e27 <list[1]>          NA          NA
#>  31: bf41b32c-e88c-4582-859d-7483b5167364 <list[1]>          NA          NA
#>  32: dd561128-d6c6-407b-a82d-bebf73d05a70 <list[1]>          NA          NA
#>  33: 5ccd6b58-3d87-463a-9fe3-bbbb5059c83d <list[1]>          NA          NA
#>  34: 7edc7b48-586a-4278-ab55-35dedcce984e <list[1]>          NA          NA
#>  35: 8d5ea65a-8c74-4c02-8cbc-9da23733ef94 <list[1]>          NA          NA
#>  36: 5e05c886-cff7-4863-82e5-e887654accf5 <list[1]>          NA          NA
#>  37: 55b7b287-031b-4ad0-ab40-e9a37395bc2c <list[1]>          NA          NA
#>  38: d3e18b8e-c831-4c84-8093-29689622163f <list[1]>          NA          NA
#>  39: 560b3e72-74e2-45ee-8662-b0051a05d1db <list[1]>          NA          NA
#>  40: 7a26727a-3345-474b-8d49-4089d9fa65a8 <list[1]>          NA          NA
#>  41: 6d901867-8154-49ee-b790-647192c22d4b <list[1]>          NA          NA
#>  42: 0b04c3eb-ca34-4656-9d1c-d6c78e563368 <list[1]>          NA          NA
#>  43: a7a0b1a2-851e-4936-9f9b-4de6ecd92225 <list[1]>          NA          NA
#>  44: 32980782-1bb1-4b7d-8c25-fec3f21ac780 <list[1]>          NA          NA
#>  45: 9cbb8ba3-32ef-4498-a08a-33d3a30570fc <list[1]>          NA          NA
#>  46: 7fafe39a-5c51-485c-9873-786d02ad59b8 <list[1]>          NA          NA
#>  47: 2102153a-a956-4e76-abad-bb4d4eddf87b <list[1]>          NA          NA
#>  48: 24be266f-913e-4cc7-b99d-e4457222484d <list[1]>          NA          NA
#>  49: af7883eb-045a-4f9c-942b-c35afc241062 <list[1]>          NA          NA
#>  50: 6e5d0856-dde3-4aa8-bd5a-33d40196bca8 <list[1]>          NA          NA
#>  51: 81c1e593-c7f9-4461-97f1-aca1364656a1 <list[1]>          NA          NA
#>  52: bc9c3743-d678-45a0-81f8-28315899a797 <list[1]>          NA          NA
#>  53: 2653a5b1-d892-4529-8aed-947873a5e040 <list[1]>          NA          NA
#>  54: 965df19c-5fa6-412c-955c-5c6ffb87ee09 <list[1]>          NA          NA
#>  55: 4cddfee6-bb72-4094-b548-2f00462c5715 <list[1]>          NA          NA
#>  56: 1ffe866b-0728-47bd-a7b3-b59681190c00 <list[1]>          NA          NA
#>  57: b2f86d39-76f5-4777-9ef0-900d32ff2833 <list[1]>          NA          NA
#>  58: 77e16ba0-8a9a-48d0-a3ae-ada0f3c28f53 <list[1]>          NA          NA
#>  59: 84a3c55d-bda6-45dc-96f3-cfef5a71d2f0 <list[1]>          NA          NA
#>  60: 1efb248f-c9de-417d-8b2a-3f982eff2c7f <list[1]>          NA          NA
#>  61: 24e8779c-495c-4861-94d4-731cea0d9ea8 <list[1]>          NA          NA
#>  62: fda7bef3-ca43-498b-a797-3b00ec4b9c70 <list[1]>          NA          NA
#>  63: 0addb47a-9fd1-4156-896f-94e6ed79fd4a <list[1]>          NA          NA
#>  64: 8fff0fd0-76fd-45e0-9013-949a1e224a5b <list[1]>          NA          NA
#>  65: a406fbe0-df62-4226-b82c-bc8068fb9a7a <list[1]>          NA          NA
#>  66: 50b8e877-f33d-4b48-a6a7-cb04fa9681c0 <list[1]>          NA          NA
#>  67: ba8ae75b-6b82-4595-999e-c90df6a2f783 <list[1]>          NA          NA
#>  68: 967150b9-ae2e-4cd9-926c-6940e980fbc9 <list[1]>          NA          NA
#>  69: c905683b-9320-41c5-a17a-f75d1172d104 <list[1]>          NA          NA
#>  70: 646b8f78-9737-4454-ab38-28800f476ac9 <list[1]>          NA          NA
#>  71: 4a1a0e81-3e2c-40d9-84e7-2f985fcc2357 <list[1]>          NA          NA
#>  72: 3c3af10d-8fcf-49f9-acb3-8cc358329de0 <list[1]>          NA          NA
#>  73: 90c71d0d-5bce-4664-9519-99b67122e086 <list[1]>          NA          NA
#>  74: eca03597-49ed-43fd-a6ae-199098c840e4 <list[1]>          NA          NA
#>  75: f91aebe4-86c7-4e23-9afb-63a960772c65 <list[1]>          NA          NA
#>  76: f6b69cd2-a8da-4aca-b6d5-2d798e56cfba <list[1]>          NA          NA
#>  77: f13d2e51-971b-4777-a373-a55fd1a81026 <list[1]>          NA          NA
#>  78: 00ee9ac7-7898-4f1b-a37d-7fef6d5ef259 <list[1]>          NA          NA
#>  79: 11c86937-9101-4d9f-a32d-8fc585ea7ac1 <list[1]>          NA          NA
#>  80: 998311a4-5a67-4753-95e8-eabb216d7dc0 <list[1]>          NA          NA
#>  81: f22e58c4-aba1-41a9-bdc7-c8acf683d1bc <list[1]>          NA          NA
#>  82: 717e0eaf-bda6-4af1-94f3-c2a4448bde70 <list[1]>          NA          NA
#>  83: 315aff3e-a38c-424f-8033-d4b3bfe2c77c <list[1]>          NA          NA
#>  84: 9de52bf7-4483-4a5e-afa6-3659207d0dd6 <list[1]>          NA          NA
#>  85: 8f25d9e0-c131-43db-8093-46e306b90084 <list[1]>          NA          NA
#>  86: 652cca40-1c82-4c11-a74e-0d3fe6051e06 <list[1]>          NA          NA
#>  87: bc033ac0-4c3c-47e0-b595-eeae8f1733a5 <list[1]>          NA          NA
#>  88: fc3f49b7-c47f-45ab-9297-e8ea22693fb4 <list[1]>          NA          NA
#>  89: 5db90eea-ecec-436f-8355-1df3428f1900 <list[1]>          NA          NA
#>  90: c4514632-9ff1-41c3-bb79-da0f03b5b01a <list[1]>          NA          NA
#>  91: 81c522b8-1223-4af9-8c86-20a50f0bbbe1 <list[1]>          NA          NA
#>  92: 61e64939-5655-4b20-bd2d-af52ffc3b780 <list[1]>          NA          NA
#>  93: 0a985e39-d5cd-4c78-bf3d-971a65a4ee06 <list[1]>          NA          NA
#>  94: ef226c83-c633-47ff-9736-38cb35adb675 <list[1]>          NA          NA
#>  95: 7902d1f6-20d8-4394-8c1c-30735934ba64 <list[1]>          NA          NA
#>  96: c87c1e35-5745-4a3e-822b-d17e3cf598b0 <list[1]>          NA          NA
#>  97: b4a4a46e-03cf-4685-a456-335929766782 <list[1]>          NA          NA
#>  98: 205e4109-edd3-486a-a22b-bc42ec393141 <list[1]>          NA          NA
#>  99: 3e78ce3f-0e9b-4ce5-bd23-cf204c0c76f0 <list[1]>          NA          NA
#> 100: ffb0dd61-fdca-4bdd-93b8-9daceb959d6e <list[1]>          NA          NA
#>                                      keys condition x_domain_x1 x_domain_x2
#>                                    <char>    <list>       <num>       <num>
```
