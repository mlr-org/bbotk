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

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-new)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-26 11:04:04  8231
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-26 11:04:04  8231
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-26 11:04:04  8231
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-26 11:04:04  8231
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-26 11:04:04  8231
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-26 11:04:04  8231
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-26 11:04:04  8231
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-26 11:04:04  8231
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-26 11:04:04  8231
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-26 11:04:04  8231
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-26 11:04:04  8231
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-26 11:04:04  8231
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-26 11:04:04  8231
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-26 11:04:04  8231
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-26 11:04:04  8231
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-26 11:04:04  8231
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-26 11:04:04  8231
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-26 11:04:04  8231
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-26 11:04:04  8231
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-26 11:04:04  8231
#>  21:   failed  10.000000  5.0000000         NA 2025-11-26 11:04:04    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-26 11:04:04    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-26 11:04:04    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-26 11:04:04    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-26 11:04:04    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-26 11:04:04    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-26 11:04:04    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-26 11:04:04    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-26 11:04:04    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-26 11:04:04    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-26 11:04:04    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-26 11:04:04    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-26 11:04:04    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-26 11:04:04    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-26 11:04:04    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-26 11:04:04    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-26 11:04:04    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-26 11:04:04    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-26 11:04:04    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-26 11:04:04    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-26 11:04:04    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-26 11:04:04    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-26 11:04:04    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-26 11:04:04    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-26 11:04:04    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-26 11:04:04    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-26 11:04:04    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-26 11:04:04    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-26 11:04:04    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-26 11:04:04    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-26 11:04:04    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-26 11:04:04    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-26 11:04:04    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-26 11:04:04    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-26 11:04:04    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-26 11:04:04    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-26 11:04:04    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-26 11:04:04    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-26 11:04:04    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-26 11:04:04    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-26 11:04:04    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-26 11:04:04    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-26 11:04:04    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-26 11:04:04    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-26 11:04:04    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-26 11:04:04    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-26 11:04:04    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-26 11:04:05
#>   2: academical_guineapig 2025-11-26 11:04:05
#>   3: academical_guineapig 2025-11-26 11:04:05
#>   4: academical_guineapig 2025-11-26 11:04:05
#>   5: academical_guineapig 2025-11-26 11:04:05
#>   6: academical_guineapig 2025-11-26 11:04:05
#>   7: academical_guineapig 2025-11-26 11:04:05
#>   8: academical_guineapig 2025-11-26 11:04:05
#>   9: academical_guineapig 2025-11-26 11:04:05
#>  10: academical_guineapig 2025-11-26 11:04:05
#>  11: academical_guineapig 2025-11-26 11:04:05
#>  12: academical_guineapig 2025-11-26 11:04:05
#>  13: academical_guineapig 2025-11-26 11:04:05
#>  14: academical_guineapig 2025-11-26 11:04:05
#>  15: academical_guineapig 2025-11-26 11:04:05
#>  16: academical_guineapig 2025-11-26 11:04:05
#>  17: academical_guineapig 2025-11-26 11:04:05
#>  18: academical_guineapig 2025-11-26 11:04:05
#>  19: academical_guineapig 2025-11-26 11:04:05
#>  20: academical_guineapig 2025-11-26 11:04:05
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
#>   1: fc88a332-35f8-45fa-b86f-71a8c1fedbb5                    <NA>  -10.000000
#>   2: 9558aace-1673-4b88-ab6b-5f9d3f54db1d                    <NA>  -10.000000
#>   3: 4a97dada-3e7b-4856-8c85-88da47f2d2da                    <NA>  -10.000000
#>   4: a7098d42-dd29-491d-b6f6-c7de78e7c9cd                    <NA>  -10.000000
#>   5: 7312ee06-5f81-46be-bb68-95b2ab18f734                    <NA>  -10.000000
#>   6: 7acdcc5d-7fa7-4cbf-a077-669cff087809                    <NA>  -10.000000
#>   7: 4ab689ed-72d0-49ea-af97-94a4e1b1faac                    <NA>  -10.000000
#>   8: b4814c1e-608b-439e-8be6-e41cfd1572b3                    <NA>  -10.000000
#>   9: fd4963aa-19b3-48ce-b3aa-c4d10da9f271                    <NA>  -10.000000
#>  10: 00154f09-3192-407e-9fea-40635460a657                    <NA>  -10.000000
#>  11: 3d732707-387c-47b9-84d7-724edab7358c                    <NA>   -7.777778
#>  12: c3cf7584-1d6a-4e6f-955f-24ab0d280060                    <NA>   -7.777778
#>  13: 44ad5b1f-e007-4582-8046-dd232b1d108f                    <NA>   -7.777778
#>  14: 09f94384-9786-4086-ac8a-370767aadfe3                    <NA>   -7.777778
#>  15: a34290f3-68d3-4da3-9b20-116bb2aec31b                    <NA>   -7.777778
#>  16: 83a69e88-efea-448b-9e51-252b9dbde45d                    <NA>   -7.777778
#>  17: 34ad534a-9588-4d6d-833e-b13149e8e9e0                    <NA>   -7.777778
#>  18: c8348dc8-01ae-4b74-90dd-1a419f14a49b                    <NA>   -7.777778
#>  19: 085ebf71-41a5-47ab-bae9-55b1f49c1691                    <NA>   -7.777778
#>  20: 17884c02-754d-470a-b459-998bb0e732d6                    <NA>   -7.777778
#>  21: cee98a14-345a-4fce-9d19-8a8eae38820a Optimization terminated          NA
#>  22: 8a847c8d-7641-4360-a6c0-0c0672bb7684 Optimization terminated          NA
#>  23: 5e394a3d-5eaf-49c9-aab3-72f2dc30a5b8 Optimization terminated          NA
#>  24: b18fe5f3-b478-470f-b34f-af00d4f9d768 Optimization terminated          NA
#>  25: a7fbc219-0756-4589-816b-e74df59c4313 Optimization terminated          NA
#>  26: ba410afe-4110-4692-9af6-d18afad6ff92 Optimization terminated          NA
#>  27: 57f6eea4-0b15-4f9a-833b-c3b022b9cddf Optimization terminated          NA
#>  28: 9d168276-d248-485e-8fe2-c954bf7de89d Optimization terminated          NA
#>  29: 5e27d479-a3e7-4e7c-9e2d-6f4f8383b9a1 Optimization terminated          NA
#>  30: 0a555dc2-7f0c-465b-a712-544944939d6b Optimization terminated          NA
#>  31: 1619fc1b-a993-4482-b7b2-bb8ed3dccea8 Optimization terminated          NA
#>  32: 19767b4b-3618-40f7-a2a9-a7e0954699a0 Optimization terminated          NA
#>  33: 20ec4e05-c991-4318-8175-53533f5f4455 Optimization terminated          NA
#>  34: 2528ac07-a6e3-44ab-a931-341aa7dfebbb Optimization terminated          NA
#>  35: 0347c483-7c7c-49a0-a22e-dff5cd914d06 Optimization terminated          NA
#>  36: 1fb77436-4101-43ad-9bd3-5f64d7e3d6e8 Optimization terminated          NA
#>  37: bda32c31-9a8a-4acf-bdec-e4e88f5861ae Optimization terminated          NA
#>  38: 82dcc159-9d8c-4163-82f1-9eeec52d2c5b Optimization terminated          NA
#>  39: b9239ce5-18fb-45e6-9e97-d4a456461f04 Optimization terminated          NA
#>  40: 37b22a2a-f959-4df3-a07a-abd86175c74d Optimization terminated          NA
#>  41: 82e29c2b-bdb4-4be3-8641-550325c0dddf Optimization terminated          NA
#>  42: cba898b5-be80-4b0f-8279-70624c2def13 Optimization terminated          NA
#>  43: e6702581-dfbb-4f22-b625-e1663cc76ad2 Optimization terminated          NA
#>  44: 90ad98c0-fb3c-4372-a20d-6851f5bee816 Optimization terminated          NA
#>  45: 403e7652-494a-4e32-b833-664f25804275 Optimization terminated          NA
#>  46: e3fe7760-0243-47d4-a6ad-a19420bf9c00 Optimization terminated          NA
#>  47: af76b9fc-8817-45ab-a230-9df7b7fca241 Optimization terminated          NA
#>  48: 16e2fd76-ede7-454b-9884-19a9bea2e5c3 Optimization terminated          NA
#>  49: da151b37-26e3-4b52-9a91-3a35eb2104f4 Optimization terminated          NA
#>  50: b4f50191-3934-49da-867a-4c5f9312f8ee Optimization terminated          NA
#>  51: 0b6ffdd3-31ac-40f0-ba0a-aed8f3b25fb7 Optimization terminated          NA
#>  52: 9d4c1a42-02af-44a5-8041-892472b28661 Optimization terminated          NA
#>  53: 6f3d430c-a029-444e-bb23-c1b8b5d12d94 Optimization terminated          NA
#>  54: 6b9d53e0-dd79-4404-84ff-da8448469c35 Optimization terminated          NA
#>  55: eb399adb-33d8-4b2d-a84c-ced0f25861d6 Optimization terminated          NA
#>  56: 994be52d-5733-40e9-a2c8-24227951634e Optimization terminated          NA
#>  57: da778f32-3205-4bbb-9e97-bc1c7cbe12d5 Optimization terminated          NA
#>  58: b4f19364-8a4d-4ab3-a2ae-e449934fa83e Optimization terminated          NA
#>  59: a90ad9d1-b875-4ca9-967f-632b9ce80e24 Optimization terminated          NA
#>  60: 419db46a-d906-40e4-8c99-9c1fda6e05f3 Optimization terminated          NA
#>  61: e51706a7-f4be-4311-a511-71d3740f519b Optimization terminated          NA
#>  62: 9e567472-4fe4-4784-a5ce-b87cc789dec1 Optimization terminated          NA
#>  63: b1dd4268-ed31-4c6f-b844-b7d1f71d224c Optimization terminated          NA
#>  64: b6e6da73-dcbf-4b9b-b4e4-d8e5fc3ea1fc Optimization terminated          NA
#>  65: d4d08399-4c85-4ab8-8b48-ca3539dd0dc6 Optimization terminated          NA
#>  66: 69ce5718-e700-4387-975d-42ba681d5ebe Optimization terminated          NA
#>  67: b8aff454-1632-4395-b644-55c7184a53bc Optimization terminated          NA
#>  68: 740b53ef-29a2-4437-9fba-04099483fa3c Optimization terminated          NA
#>  69: d2a30ee1-b4c2-465d-9091-510dd06c3345 Optimization terminated          NA
#>  70: 471d4d13-f75d-44e0-994b-562e24fba1d1 Optimization terminated          NA
#>  71: ebdd210b-1039-47d9-a0c3-2c5fb8e566c9 Optimization terminated          NA
#>  72: 48fd3b7a-94fa-4794-b128-9873ba8dbfbd Optimization terminated          NA
#>  73: 019c93e8-9668-41c1-9785-62f2d2fa1ef0 Optimization terminated          NA
#>  74: d0aaf4ba-8d4e-49a2-a440-6339597edb8b Optimization terminated          NA
#>  75: bee6e1a9-240a-4bcd-abc2-e9c2ab348d99 Optimization terminated          NA
#>  76: d039103c-ec5f-4cef-8307-520376963d74 Optimization terminated          NA
#>  77: cea3b004-e7a9-411c-a790-f4496d5ec8e4 Optimization terminated          NA
#>  78: d938f3c9-d291-4eec-8668-6d2bfb7b5eb5 Optimization terminated          NA
#>  79: 567b181e-2002-4e7c-b92d-0ca10b52ab14 Optimization terminated          NA
#>  80: 1eb9cdaf-3baa-4f81-89e3-68a23110023c Optimization terminated          NA
#>  81: 46a4a8ce-86d3-4339-a2ed-4c358545458d Optimization terminated          NA
#>  82: c966d5d2-ce02-49b7-86f5-39bfec5f5f86 Optimization terminated          NA
#>  83: b9eba8fb-ea57-40c3-ba7f-acafb4f196d8 Optimization terminated          NA
#>  84: 1182b6f8-8f0e-4a53-89d1-d21b611d6138 Optimization terminated          NA
#>  85: bf6cce90-4a1b-45af-be4c-37adc5cf33d9 Optimization terminated          NA
#>  86: 03fe4b1f-0a9d-46ca-9c06-da7d304a18cc Optimization terminated          NA
#>  87: 835d8596-c2b6-4f31-94ce-c0130c254cf6 Optimization terminated          NA
#>  88: 3ade0573-3dce-43d8-b6a2-01e3390ecc45 Optimization terminated          NA
#>  89: 0cac2e93-5ce4-476c-9d11-3c5e3a1d644b Optimization terminated          NA
#>  90: ea71652b-5591-4965-a567-9835a63fbca9 Optimization terminated          NA
#>  91: 35a64d85-2a28-4118-a953-2eca18b2d6bf Optimization terminated          NA
#>  92: b77fbc72-0da7-40d9-bb1b-69941485e21d Optimization terminated          NA
#>  93: 7469f150-ea53-4121-8ab0-71fc4ab4ff83 Optimization terminated          NA
#>  94: f9c9e251-eeb3-4f90-91cc-9b99a93ee7e0 Optimization terminated          NA
#>  95: cf60363e-c414-436c-8e38-b079b1ea6343 Optimization terminated          NA
#>  96: 6d557332-ac40-41b3-8c7e-930a32363220 Optimization terminated          NA
#>  97: c8893216-7685-43db-8828-197b6f0a1679 Optimization terminated          NA
#>  98: 6427970b-4ebc-4b8a-a87e-d08d65c9f06c Optimization terminated          NA
#>  99: b3144e1e-cba2-43e4-af8d-6bcd770709d9 Optimization terminated          NA
#> 100: f7bca1da-3971-4cf9-b7ef-5c2a61917e9e Optimization terminated          NA
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
