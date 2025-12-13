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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-new)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncGridSearch$new()

------------------------------------------------------------------------

### Method [`optimize()`](https://rdrr.io/r/stats/optimize.html)

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncGridSearch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

------------------------------------------------------------------------

### Method `clone()`

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
rush::rush_plan(worker_type = "remote")
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
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-12-13 11:48:15  8393
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-12-13 11:48:15  8393
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-12-13 11:48:15  8393
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-12-13 11:48:15  8393
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-12-13 11:48:15  8393
#>   6: finished -10.000000  0.5555556 -146.64198 2025-12-13 11:48:15  8393
#>   7: finished -10.000000  1.6666667 -155.77778 2025-12-13 11:48:15  8393
#>   8: finished -10.000000  2.7777778 -167.38272 2025-12-13 11:48:15  8393
#>   9: finished -10.000000  3.8888889 -181.45679 2025-12-13 11:48:15  8393
#>  10: finished -10.000000  5.0000000 -198.00000 2025-12-13 11:48:15  8393
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-12-13 11:48:15  8393
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-12-13 11:48:15  8393
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-12-13 11:48:15  8393
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-12-13 11:48:15  8393
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-12-13 11:48:15  8393
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-12-13 11:48:15  8393
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-12-13 11:48:15  8393
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-12-13 11:48:15  8393
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-12-13 11:48:15  8393
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-12-13 11:48:15  8393
#>  21:   failed  10.000000  5.0000000         NA 2025-12-13 11:48:15    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-12-13 11:48:15    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-12-13 11:48:15    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-12-13 11:48:15    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-12-13 11:48:15    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-12-13 11:48:15    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-12-13 11:48:15    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-12-13 11:48:15    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-12-13 11:48:15    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-12-13 11:48:15    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-12-13 11:48:15    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-12-13 11:48:15    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-12-13 11:48:15    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-12-13 11:48:15    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-12-13 11:48:15    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-12-13 11:48:15    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-12-13 11:48:15    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-12-13 11:48:15    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-12-13 11:48:15    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-12-13 11:48:15    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-12-13 11:48:15    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-12-13 11:48:15    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-12-13 11:48:15    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-12-13 11:48:15    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-12-13 11:48:15    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-12-13 11:48:15    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-12-13 11:48:15    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-12-13 11:48:15    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-12-13 11:48:15    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-12-13 11:48:15    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-12-13 11:48:15    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-12-13 11:48:15    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-12-13 11:48:15    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-12-13 11:48:15    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-12-13 11:48:15    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-12-13 11:48:15    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-12-13 11:48:15    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-12-13 11:48:15    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-12-13 11:48:15    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-12-13 11:48:15    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-12-13 11:48:15    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-12-13 11:48:15    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-12-13 11:48:15    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-12-13 11:48:15    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-12-13 11:48:15    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-12-13 11:48:15    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-12-13 11:48:15    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-12-13 11:48:16
#>   2: academical_guineapig 2025-12-13 11:48:16
#>   3: academical_guineapig 2025-12-13 11:48:16
#>   4: academical_guineapig 2025-12-13 11:48:16
#>   5: academical_guineapig 2025-12-13 11:48:16
#>   6: academical_guineapig 2025-12-13 11:48:16
#>   7: academical_guineapig 2025-12-13 11:48:16
#>   8: academical_guineapig 2025-12-13 11:48:16
#>   9: academical_guineapig 2025-12-13 11:48:16
#>  10: academical_guineapig 2025-12-13 11:48:16
#>  11: academical_guineapig 2025-12-13 11:48:16
#>  12: academical_guineapig 2025-12-13 11:48:16
#>  13: academical_guineapig 2025-12-13 11:48:16
#>  14: academical_guineapig 2025-12-13 11:48:16
#>  15: academical_guineapig 2025-12-13 11:48:16
#>  16: academical_guineapig 2025-12-13 11:48:16
#>  17: academical_guineapig 2025-12-13 11:48:16
#>  18: academical_guineapig 2025-12-13 11:48:16
#>  19: academical_guineapig 2025-12-13 11:48:16
#>  20: academical_guineapig 2025-12-13 11:48:16
#>  21:                 <NA>                <NA>
#>  22:                 <NA>                <NA>
#>  23:                 <NA>                <NA>
#>  24:                 <NA>                <NA>
#>  25:                 <NA>                <NA>
#>  26:                 <NA>                <NA>
#>  27:                 <NA>                <NA>
#>  28:                 <NA>                <NA>
#>  29:                 <NA>                <NA>
#>  30:                 <NA>                <NA>
#>  31:                 <NA>                <NA>
#>  32:                 <NA>                <NA>
#>  33:                 <NA>                <NA>
#>  34:                 <NA>                <NA>
#>  35:                 <NA>                <NA>
#>  36:                 <NA>                <NA>
#>  37:                 <NA>                <NA>
#>  38:                 <NA>                <NA>
#>  39:                 <NA>                <NA>
#>  40:                 <NA>                <NA>
#>  41:                 <NA>                <NA>
#>  42:                 <NA>                <NA>
#>  43:                 <NA>                <NA>
#>  44:                 <NA>                <NA>
#>  45:                 <NA>                <NA>
#>  46:                 <NA>                <NA>
#>  47:                 <NA>                <NA>
#>  48:                 <NA>                <NA>
#>  49:                 <NA>                <NA>
#>  50:                 <NA>                <NA>
#>  51:                 <NA>                <NA>
#>  52:                 <NA>                <NA>
#>  53:                 <NA>                <NA>
#>  54:                 <NA>                <NA>
#>  55:                 <NA>                <NA>
#>  56:                 <NA>                <NA>
#>  57:                 <NA>                <NA>
#>  58:                 <NA>                <NA>
#>  59:                 <NA>                <NA>
#>  60:                 <NA>                <NA>
#>  61:                 <NA>                <NA>
#>  62:                 <NA>                <NA>
#>  63:                 <NA>                <NA>
#>  64:                 <NA>                <NA>
#>  65:                 <NA>                <NA>
#>  66:                 <NA>                <NA>
#>  67:                 <NA>                <NA>
#>  68:                 <NA>                <NA>
#>  69:                 <NA>                <NA>
#>  70:                 <NA>                <NA>
#>  71:                 <NA>                <NA>
#>  72:                 <NA>                <NA>
#>  73:                 <NA>                <NA>
#>  74:                 <NA>                <NA>
#>  75:                 <NA>                <NA>
#>  76:                 <NA>                <NA>
#>  77:                 <NA>                <NA>
#>  78:                 <NA>                <NA>
#>  79:                 <NA>                <NA>
#>  80:                 <NA>                <NA>
#>  81:                 <NA>                <NA>
#>  82:                 <NA>                <NA>
#>  83:                 <NA>                <NA>
#>  84:                 <NA>                <NA>
#>  85:                 <NA>                <NA>
#>  86:                 <NA>                <NA>
#>  87:                 <NA>                <NA>
#>  88:                 <NA>                <NA>
#>  89:                 <NA>                <NA>
#>  90:                 <NA>                <NA>
#>  91:                 <NA>                <NA>
#>  92:                 <NA>                <NA>
#>  93:                 <NA>                <NA>
#>  94:                 <NA>                <NA>
#>  95:                 <NA>                <NA>
#>  96:                 <NA>                <NA>
#>  97:                 <NA>                <NA>
#>  98:                 <NA>                <NA>
#>  99:                 <NA>                <NA>
#> 100:                 <NA>                <NA>
#>                 worker_id        timestamp_ys
#>                                      keys                 message x_domain_x1
#>                                    <char>                  <char>       <num>
#>   1: 6bdbfd53-d7c9-4ba4-b7ca-d6431acc0697                    <NA>  -10.000000
#>   2: eb32d188-01e9-4ff0-a287-8682fa70a235                    <NA>  -10.000000
#>   3: 4100eb86-5396-4274-b993-26cb2207444f                    <NA>  -10.000000
#>   4: 907051ea-5d7a-400c-a2e3-40c8192ab455                    <NA>  -10.000000
#>   5: f8e50af8-30c1-4786-9ccd-898121aa8f9a                    <NA>  -10.000000
#>   6: c6f98822-8bee-49fb-9b29-99466e91fc5c                    <NA>  -10.000000
#>   7: cd7d875d-2871-4607-aa58-e4b3b2d43c4a                    <NA>  -10.000000
#>   8: fd67e5ed-5297-475b-b6bb-0783260dc276                    <NA>  -10.000000
#>   9: ba7809da-5ff9-4a9a-90de-5f00d88b95f1                    <NA>  -10.000000
#>  10: 359f7775-da27-4ab7-849e-5ad65cf27686                    <NA>  -10.000000
#>  11: f8129dc3-01c4-4574-8d0e-4d745a43a151                    <NA>   -7.777778
#>  12: aceca4d8-5776-47a1-b970-f9ac412910b7                    <NA>   -7.777778
#>  13: 0ca77151-4376-4e3a-a3ac-8139ac36889a                    <NA>   -7.777778
#>  14: 46eb32a7-c793-45f5-ac0c-7ef9f0a021fd                    <NA>   -7.777778
#>  15: 415053df-1c48-4cbc-b075-8fd1aaa10d24                    <NA>   -7.777778
#>  16: ff4f1710-37d6-495d-929c-f6da775d1f50                    <NA>   -7.777778
#>  17: 3326693f-440e-4d6c-90b5-c6e323459bc4                    <NA>   -7.777778
#>  18: 09e739d6-d029-4fa0-99bd-b056c82dc604                    <NA>   -7.777778
#>  19: 2706858f-bf57-40bd-9410-d557111bd367                    <NA>   -7.777778
#>  20: 0ab23e81-40d0-4d16-a130-6acb3f348921                    <NA>   -7.777778
#>  21: 42ac0fc8-1221-4c11-94c9-a8be0ceedf81 Optimization terminated          NA
#>  22: 4a6a6af3-ee35-4919-bd9d-2c802ac3de98 Optimization terminated          NA
#>  23: 4ba600d4-a11d-4473-9fb0-7517db222ae5 Optimization terminated          NA
#>  24: f4ca5c6a-ce69-49e4-9206-bbc37affc3e0 Optimization terminated          NA
#>  25: b4d44a3b-f6e6-4c6f-a2ce-f06c33540d4a Optimization terminated          NA
#>  26: d489eb60-d325-40eb-88bb-24fe6818f9a1 Optimization terminated          NA
#>  27: 8a48a9bc-e9a7-4034-8de0-e7a2beb06d05 Optimization terminated          NA
#>  28: 22921006-3255-48c7-aa0a-6d92b5790318 Optimization terminated          NA
#>  29: 530823fc-e49e-4d07-b35b-0ed247e063dc Optimization terminated          NA
#>  30: 6b8e2ae0-7a74-47b4-8126-575d8913e64f Optimization terminated          NA
#>  31: 611488d2-8a37-4058-b399-dd7e0cd732ac Optimization terminated          NA
#>  32: 27446039-c828-4ab5-8cdd-cd15832504f6 Optimization terminated          NA
#>  33: 210f4e82-f224-4498-9413-ddc7f96f8823 Optimization terminated          NA
#>  34: 2ddb66b8-00be-4d0c-8958-f24f243db233 Optimization terminated          NA
#>  35: dc8b6bf9-6e9f-4914-9b08-cc28ff32547e Optimization terminated          NA
#>  36: d6cd4f16-6dbc-4fe5-92ac-9415d804b069 Optimization terminated          NA
#>  37: e86be86e-8d88-4a36-b6aa-acc57a5751da Optimization terminated          NA
#>  38: 10d57a99-7b08-4e1f-befa-2c4d2f85c489 Optimization terminated          NA
#>  39: b1ca66ae-d361-4a14-92fb-1788f5219cc8 Optimization terminated          NA
#>  40: 556c7840-d715-407a-a27d-fae4a0cfac5c Optimization terminated          NA
#>  41: c1852b60-b27d-4b6e-b0b2-bc95f361f743 Optimization terminated          NA
#>  42: dc5fc25a-eb8d-4b96-a4fb-2ceef675012d Optimization terminated          NA
#>  43: 590a4b88-faa1-4771-97a2-70881c003a6d Optimization terminated          NA
#>  44: 5bcb9ade-b825-4491-becc-faec3cda659b Optimization terminated          NA
#>  45: 0c8171ab-91ff-468a-b78c-855dc0e3ced4 Optimization terminated          NA
#>  46: aacdd416-a378-4b62-9e1a-ef15c7367151 Optimization terminated          NA
#>  47: 88bfe857-ddc8-40ad-8a4d-a76deb4a6c21 Optimization terminated          NA
#>  48: e49df850-8db2-475b-8c79-7a8a5f3f1e10 Optimization terminated          NA
#>  49: 5667c24e-215e-4e77-9060-aa050ae1906f Optimization terminated          NA
#>  50: df7cf0a7-f944-4cf7-9d41-c5fb43b1a196 Optimization terminated          NA
#>  51: a94e027f-f0a6-452f-8281-737fc21ad253 Optimization terminated          NA
#>  52: f97a04d4-520f-4756-b64b-ddd195c711c0 Optimization terminated          NA
#>  53: 78f4e394-d62a-4899-803c-b45d789150d9 Optimization terminated          NA
#>  54: f2102e42-9327-4ca6-b40d-0b948ae7dcb1 Optimization terminated          NA
#>  55: 6254dd62-1240-432e-b09d-dd31846155b3 Optimization terminated          NA
#>  56: bba10ba2-178c-4ee6-a954-a94ee911b676 Optimization terminated          NA
#>  57: 46f8cb04-d7fd-4a91-9496-a678024de6b3 Optimization terminated          NA
#>  58: 8462de89-158c-4cba-a461-6eb72a94dc11 Optimization terminated          NA
#>  59: 01982bc9-566d-429b-8dd1-52282f3b6ce0 Optimization terminated          NA
#>  60: 83a76310-b21b-407c-91b8-a9f34cf30518 Optimization terminated          NA
#>  61: c3f685ce-ffb0-4cbb-b5fd-7b860b587daa Optimization terminated          NA
#>  62: 68ed53ae-9d68-4cfb-960f-7e8e2b10d1eb Optimization terminated          NA
#>  63: d1c8e148-6927-4758-a615-7ed35bd46d21 Optimization terminated          NA
#>  64: 134d1975-b434-4011-95ab-f4d7864246fa Optimization terminated          NA
#>  65: 962992be-e35f-4e76-840a-85c7453be992 Optimization terminated          NA
#>  66: 31257047-6413-452e-8041-1e699966d1dc Optimization terminated          NA
#>  67: 64ef7330-f630-4b4d-8421-e83afc568d41 Optimization terminated          NA
#>  68: 3baf8174-5bac-4dd4-9251-aa6de01f7dfa Optimization terminated          NA
#>  69: dc5525a8-e72c-4f62-81c4-7d41eba71755 Optimization terminated          NA
#>  70: 5823e3aa-9b74-474a-8f1a-ceb99f09aef7 Optimization terminated          NA
#>  71: 825b7b11-540e-4cd8-8e6f-21784681e6e5 Optimization terminated          NA
#>  72: 6e01d01e-0c88-4864-bc93-0d73b3f090f5 Optimization terminated          NA
#>  73: 50040a55-d378-4921-9c7a-b335f1d08e61 Optimization terminated          NA
#>  74: 46eb55d2-23cd-4353-a7c9-27ecd9804024 Optimization terminated          NA
#>  75: 7c9edf03-cc98-4ba6-b702-7a96321d6d19 Optimization terminated          NA
#>  76: fb7511c9-e48c-454d-a010-b9161083b3bb Optimization terminated          NA
#>  77: 018c5376-8bc0-4e4f-bc3d-fc27205e8acd Optimization terminated          NA
#>  78: 20c9ee27-28bf-40e2-b928-bc94d38c3e4e Optimization terminated          NA
#>  79: 23f1ff11-8892-40e5-83fe-bbfa3f24497d Optimization terminated          NA
#>  80: 2e4d76f6-4901-4a8d-938b-750c9bf98b24 Optimization terminated          NA
#>  81: 80fd9831-2f39-4cc5-8bd6-1348ef2102a4 Optimization terminated          NA
#>  82: d308786d-1bdd-43c5-8715-c3d2c36aabf6 Optimization terminated          NA
#>  83: 38d400eb-d19e-428e-8bef-bf1cd956441f Optimization terminated          NA
#>  84: f7952f74-0fa9-497e-8b50-74c516ed6535 Optimization terminated          NA
#>  85: dc3ad339-7993-41a1-b0c5-400dc409b99a Optimization terminated          NA
#>  86: 95060024-063f-443b-9f72-f27669233016 Optimization terminated          NA
#>  87: 843b2ac0-476c-4338-ad2c-fbe3a389049d Optimization terminated          NA
#>  88: f28c2f1f-f44f-43f2-9d62-480848d0ea6a Optimization terminated          NA
#>  89: 848523dd-59ae-4f7a-b185-19140632038e Optimization terminated          NA
#>  90: 66f1f5ff-5501-408f-8d42-c2d9e903bd4e Optimization terminated          NA
#>  91: ee17509a-a5b1-4374-a4e2-fe8d05893b81 Optimization terminated          NA
#>  92: fb4fef50-0ac3-4960-a339-3bbe8a4a6637 Optimization terminated          NA
#>  93: 1be1f8d3-c9fa-4917-827d-1c630f0eb5d0 Optimization terminated          NA
#>  94: 7c605770-948b-4993-a080-1c8ff692d36c Optimization terminated          NA
#>  95: 65f7fc33-bc9a-4007-8b13-4b620db2611f Optimization terminated          NA
#>  96: d005062b-5ae2-4103-a244-ee7d80f1fbce Optimization terminated          NA
#>  97: e383abe2-b6b0-4e0c-b751-5e9cdb03a357 Optimization terminated          NA
#>  98: d8cf601f-8713-45f3-8189-16303bf707c3 Optimization terminated          NA
#>  99: a05243b4-0cb4-400f-a57b-4fba5ac488ba Optimization terminated          NA
#> 100: 9968fd14-4103-48cf-b5d1-4579be20257c Optimization terminated          NA
#>                                      keys                 message x_domain_x1
#>      x_domain_x2
#>            <num>
#>   1:  -5.0000000
#>   2:  -3.8888889
#>   3:  -2.7777778
#>   4:  -1.6666667
#>   5:  -0.5555556
#>   6:   0.5555556
#>   7:   1.6666667
#>   8:   2.7777778
#>   9:   3.8888889
#>  10:   5.0000000
#>  11:  -5.0000000
#>  12:  -3.8888889
#>  13:  -2.7777778
#>  14:  -1.6666667
#>  15:  -0.5555556
#>  16:   0.5555556
#>  17:   1.6666667
#>  18:   2.7777778
#>  19:   3.8888889
#>  20:   5.0000000
#>  21:          NA
#>  22:          NA
#>  23:          NA
#>  24:          NA
#>  25:          NA
#>  26:          NA
#>  27:          NA
#>  28:          NA
#>  29:          NA
#>  30:          NA
#>  31:          NA
#>  32:          NA
#>  33:          NA
#>  34:          NA
#>  35:          NA
#>  36:          NA
#>  37:          NA
#>  38:          NA
#>  39:          NA
#>  40:          NA
#>  41:          NA
#>  42:          NA
#>  43:          NA
#>  44:          NA
#>  45:          NA
#>  46:          NA
#>  47:          NA
#>  48:          NA
#>  49:          NA
#>  50:          NA
#>  51:          NA
#>  52:          NA
#>  53:          NA
#>  54:          NA
#>  55:          NA
#>  56:          NA
#>  57:          NA
#>  58:          NA
#>  59:          NA
#>  60:          NA
#>  61:          NA
#>  62:          NA
#>  63:          NA
#>  64:          NA
#>  65:          NA
#>  66:          NA
#>  67:          NA
#>  68:          NA
#>  69:          NA
#>  70:          NA
#>  71:          NA
#>  72:          NA
#>  73:          NA
#>  74:          NA
#>  75:          NA
#>  76:          NA
#>  77:          NA
#>  78:          NA
#>  79:          NA
#>  80:          NA
#>  81:          NA
#>  82:          NA
#>  83:          NA
#>  84:          NA
#>  85:          NA
#>  86:          NA
#>  87:          NA
#>  88:          NA
#>  89:          NA
#>  90:          NA
#>  91:          NA
#>  92:          NA
#>  93:          NA
#>  94:          NA
#>  95:          NA
#>  96:          NA
#>  97:          NA
#>  98:          NA
#>  99:          NA
#> 100:          NA
#>      x_domain_x2
```
