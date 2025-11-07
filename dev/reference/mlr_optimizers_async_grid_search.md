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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-07 11:51:09  9549
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-07 11:51:09  9549
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-07 11:51:09  9549
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-07 11:51:09  9549
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-07 11:51:09  9549
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-07 11:51:09  9549
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-07 11:51:09  9549
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-07 11:51:09  9549
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-07 11:51:09  9549
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-07 11:51:09  9549
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-07 11:51:09  9549
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-07 11:51:09  9549
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-07 11:51:09  9549
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-07 11:51:09  9549
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-07 11:51:09  9549
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-07 11:51:09  9549
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-07 11:51:09  9549
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-07 11:51:09  9549
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-07 11:51:09  9549
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-07 11:51:09  9549
#>  21:   failed  10.000000  5.0000000         NA 2025-11-07 11:51:09    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-07 11:51:09    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-07 11:51:09    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-07 11:51:09    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-07 11:51:09    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-07 11:51:09    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-07 11:51:09    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-07 11:51:09    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-07 11:51:09    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-07 11:51:09    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-07 11:51:09    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-07 11:51:09    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-07 11:51:09    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-07 11:51:09    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-07 11:51:09    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-07 11:51:09    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-07 11:51:09    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-07 11:51:09    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-07 11:51:09    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-07 11:51:09    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-07 11:51:09    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-07 11:51:09    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-07 11:51:09    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-07 11:51:09    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-07 11:51:09    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-07 11:51:09    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-07 11:51:09    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-07 11:51:09    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-07 11:51:09    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-07 11:51:09    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-07 11:51:09    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-07 11:51:09    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-07 11:51:09    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-07 11:51:09    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-07 11:51:09    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-07 11:51:09    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-07 11:51:09    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-07 11:51:09    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-07 11:51:09    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-07 11:51:09    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-07 11:51:09    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-07 11:51:09    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-07 11:51:09    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-07 11:51:09    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-07 11:51:09    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-07 11:51:09    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-07 11:51:09    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-07 11:51:10
#>   2: academical_guineapig 2025-11-07 11:51:10
#>   3: academical_guineapig 2025-11-07 11:51:10
#>   4: academical_guineapig 2025-11-07 11:51:10
#>   5: academical_guineapig 2025-11-07 11:51:10
#>   6: academical_guineapig 2025-11-07 11:51:10
#>   7: academical_guineapig 2025-11-07 11:51:10
#>   8: academical_guineapig 2025-11-07 11:51:10
#>   9: academical_guineapig 2025-11-07 11:51:10
#>  10: academical_guineapig 2025-11-07 11:51:10
#>  11: academical_guineapig 2025-11-07 11:51:10
#>  12: academical_guineapig 2025-11-07 11:51:10
#>  13: academical_guineapig 2025-11-07 11:51:10
#>  14: academical_guineapig 2025-11-07 11:51:10
#>  15: academical_guineapig 2025-11-07 11:51:10
#>  16: academical_guineapig 2025-11-07 11:51:10
#>  17: academical_guineapig 2025-11-07 11:51:10
#>  18: academical_guineapig 2025-11-07 11:51:10
#>  19: academical_guineapig 2025-11-07 11:51:10
#>  20: academical_guineapig 2025-11-07 11:51:10
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
#>   1: fe256939-a8c5-4428-8dde-e6a4d2ff5b54                    <NA>  -10.000000
#>   2: 88bfb9e9-7903-4494-83d8-24c19397b4dd                    <NA>  -10.000000
#>   3: c4d9d230-cd19-4334-ac89-d8e36702d0d1                    <NA>  -10.000000
#>   4: 0921e8ec-400f-4786-91a1-8b595351f048                    <NA>  -10.000000
#>   5: c9bc35a3-dfc7-4d45-9faf-53cc2791aded                    <NA>  -10.000000
#>   6: af5ec930-e88c-4786-bf21-5d5352a389ce                    <NA>  -10.000000
#>   7: 2a285e1e-8d2f-4e59-9c69-dcc248536e8f                    <NA>  -10.000000
#>   8: 5673ea01-8568-470f-a848-2cacea0885c9                    <NA>  -10.000000
#>   9: 81e80536-2532-4bef-9d9b-a00404ccc474                    <NA>  -10.000000
#>  10: 4f44d940-ed0a-4443-aaf0-d81701b7324f                    <NA>  -10.000000
#>  11: 37e90a7e-dff8-4aa4-8a8b-250195fdca5c                    <NA>   -7.777778
#>  12: 90771e17-8ac2-40d2-b7a0-b4550cfc3724                    <NA>   -7.777778
#>  13: 66e0247c-c6f7-45c6-bb4a-060903269315                    <NA>   -7.777778
#>  14: 9ea0f3ce-7d45-4d3b-9f63-23dfcd59db90                    <NA>   -7.777778
#>  15: 55d7f32a-4755-4efc-ac4b-59aacd6c145b                    <NA>   -7.777778
#>  16: 5e02da15-9c85-4005-b058-d1b84765ddaf                    <NA>   -7.777778
#>  17: eb7c40bf-e271-4224-92ce-6e9d78f88923                    <NA>   -7.777778
#>  18: 27a8afcb-387e-4e54-a7dd-3d7d643d88a2                    <NA>   -7.777778
#>  19: 7555e092-fefd-4265-870f-e83d05882caf                    <NA>   -7.777778
#>  20: 9e6c4837-be9e-45b5-b5af-172c7f3c880c                    <NA>   -7.777778
#>  21: e9d12df5-30f6-40da-bfe0-6dd60ef2da50 Optimization terminated          NA
#>  22: e66cebed-4c07-46f2-afb6-6b308c3eb8dc Optimization terminated          NA
#>  23: 33cb6fb1-854c-45e1-81c1-60fce6fbc16a Optimization terminated          NA
#>  24: 69daa18b-481b-48a0-9fc5-b3da3fc1dd21 Optimization terminated          NA
#>  25: 2d923661-a471-4860-90ef-eee0a1ad50d5 Optimization terminated          NA
#>  26: 08f58aa2-e9cf-4f9a-bef4-9342b15cfbf2 Optimization terminated          NA
#>  27: 848b7ca7-db4e-4bbd-be7f-3a10e0b81f28 Optimization terminated          NA
#>  28: 5a5404c3-da95-495b-ad56-8f68b2872121 Optimization terminated          NA
#>  29: f3519a96-a59a-44c9-8f32-045f1e9cdcf1 Optimization terminated          NA
#>  30: 2755c46b-e4ab-4611-99a9-e690952d3a1e Optimization terminated          NA
#>  31: 102fc9ea-cf30-4c4d-81df-9feeeb835e63 Optimization terminated          NA
#>  32: 33f3e438-0aff-4c6d-b599-5763f3e683b0 Optimization terminated          NA
#>  33: 2522c480-f461-46fc-b26c-3a6dfb431b5f Optimization terminated          NA
#>  34: 8f1f6751-e5e0-4602-bf66-6737307e488b Optimization terminated          NA
#>  35: 98b1030d-cdd0-406b-980e-bd27777b6fe3 Optimization terminated          NA
#>  36: 982bb293-38c9-49eb-9d1c-00d045ba74f7 Optimization terminated          NA
#>  37: 3d5c3a90-09e8-4b5f-86e6-acd7a123a3f0 Optimization terminated          NA
#>  38: fea00b21-b8e5-4230-8599-e73b04da18aa Optimization terminated          NA
#>  39: eafd27bf-525c-4869-a431-f774a0d07e01 Optimization terminated          NA
#>  40: 10e40d4a-bdec-4a3c-995d-ce17b00ead3c Optimization terminated          NA
#>  41: 3c18449f-588e-4304-bf70-2cee98ad44f6 Optimization terminated          NA
#>  42: e75f6d6b-d5ef-4905-b495-b0acb128cd81 Optimization terminated          NA
#>  43: 596abd00-d786-4c2b-a3c9-e507ada9502f Optimization terminated          NA
#>  44: bbc063eb-5f96-4257-9c26-14e84a4a7c66 Optimization terminated          NA
#>  45: 48d175f0-1c36-4867-9b9e-7fadfc4fee7f Optimization terminated          NA
#>  46: a48cf8a0-8825-4a5c-bf8c-601a00071204 Optimization terminated          NA
#>  47: 0998b033-fef0-460d-9488-94b5c1c15260 Optimization terminated          NA
#>  48: 98c921a8-5335-4ee7-a35d-80802e7b9edf Optimization terminated          NA
#>  49: adebeb15-29b3-474c-9754-3e02226336ae Optimization terminated          NA
#>  50: 4d907a36-366d-4f8a-b6d6-cd4217fe1679 Optimization terminated          NA
#>  51: b6c9d451-572c-45a7-b0e8-e54006fa04c2 Optimization terminated          NA
#>  52: fdfc79af-4332-48a1-a51f-d8c68f8aa243 Optimization terminated          NA
#>  53: 9b2fade8-6969-4581-8970-8e3bffc803b7 Optimization terminated          NA
#>  54: f3651cb3-4cdf-4bc2-b1c8-63daa162311c Optimization terminated          NA
#>  55: 9206de92-737e-4eec-a6b0-78a87800df32 Optimization terminated          NA
#>  56: 27947fab-48fe-489f-aba2-c9773455d755 Optimization terminated          NA
#>  57: f6bca95e-ce56-432d-8cdb-1ea4965b090d Optimization terminated          NA
#>  58: a9bd2f96-89e5-4fd4-a3b2-8159b70725e7 Optimization terminated          NA
#>  59: 2eb4b93f-5e66-40f6-9cc7-cccf0a1a1f5e Optimization terminated          NA
#>  60: ba82439f-2bf0-4e92-929d-2f520534242f Optimization terminated          NA
#>  61: 43d01271-d6ca-40ea-bf8e-08dc41f96bfc Optimization terminated          NA
#>  62: b09656d4-70e8-4b79-b7dd-d0e49057a9a4 Optimization terminated          NA
#>  63: 21828ed3-9f5c-46ef-83d8-e044cdfb767a Optimization terminated          NA
#>  64: b653bcc4-1401-44ec-88f6-fb9e13856145 Optimization terminated          NA
#>  65: d98a88bb-e9ec-4c26-bed3-ba892e354b23 Optimization terminated          NA
#>  66: a426489c-8d7d-4308-9357-78e31ce566c0 Optimization terminated          NA
#>  67: f1e96622-0f67-453b-9b58-70c3eca43113 Optimization terminated          NA
#>  68: 6bcbdf51-d240-4b45-a198-0363a98b448d Optimization terminated          NA
#>  69: 42bdb238-3095-4ce6-be09-3d32a9f6aae9 Optimization terminated          NA
#>  70: b4b50eba-f642-4877-95e6-04af8e0a6ee7 Optimization terminated          NA
#>  71: 2a197864-a8b1-4b11-957a-8c2b8e0438e3 Optimization terminated          NA
#>  72: cac6b0c8-8be4-4d30-b7db-87028eebfe72 Optimization terminated          NA
#>  73: 032264f9-b7dc-4149-80e3-6e2352c7ada0 Optimization terminated          NA
#>  74: 37f5fa66-2343-45e3-9659-56c1afc6c00d Optimization terminated          NA
#>  75: f1204bec-7ac2-40ab-bc5e-bc4b4800fc80 Optimization terminated          NA
#>  76: 1292f49e-4760-4832-9cef-d11c3c7cee90 Optimization terminated          NA
#>  77: 02ff7863-65ff-40c4-b22d-cc4e7420c0df Optimization terminated          NA
#>  78: 078f658c-7364-4b9c-a638-c177353a6b3b Optimization terminated          NA
#>  79: 9a6f73c9-287c-4f34-a344-17bfcb6eb0bd Optimization terminated          NA
#>  80: 2d768591-592e-4ec7-a724-ef66ef0d7eeb Optimization terminated          NA
#>  81: 435e4cb5-f6b4-41f7-98a5-011ccea3d6c4 Optimization terminated          NA
#>  82: d5ab8a69-f329-4f37-8049-9ed2f1fa1c83 Optimization terminated          NA
#>  83: c10468db-66b8-4995-8192-8a834fddd938 Optimization terminated          NA
#>  84: a26a9dc4-6be0-474e-8b79-c57b69dd80cf Optimization terminated          NA
#>  85: 8ab6ef1b-c454-4041-beef-a5b79bdf281c Optimization terminated          NA
#>  86: 2aef95b4-8746-42d7-aff3-d70c857b1b24 Optimization terminated          NA
#>  87: 2bec52f8-c203-418f-b599-4f33531a694f Optimization terminated          NA
#>  88: eacfb36d-d881-47df-aa40-52013ce0ded9 Optimization terminated          NA
#>  89: f64a236d-49a9-4995-ba6a-a99d27b24dea Optimization terminated          NA
#>  90: 57446239-edc7-48e7-b18b-6f91669eb88d Optimization terminated          NA
#>  91: e0d22840-6de9-406f-b99c-f416c4087eaa Optimization terminated          NA
#>  92: be3fd32d-7c74-43d9-8ed2-b17469edba53 Optimization terminated          NA
#>  93: 2ac39739-7e85-4da9-b0ac-25d33fe8e3de Optimization terminated          NA
#>  94: 3b18f0e1-c9ad-4674-9275-f8f0da060856 Optimization terminated          NA
#>  95: 6f358440-08dc-4697-95d8-7514a2136dd5 Optimization terminated          NA
#>  96: 0260aa78-02f3-4b10-b0b4-9308860e86c8 Optimization terminated          NA
#>  97: ddf65b2d-bd57-44af-b9e1-b31812e67519 Optimization terminated          NA
#>  98: 7614dd75-34dd-4826-a997-39da45434b80 Optimization terminated          NA
#>  99: 4da9d2da-e827-4c9d-9b4b-20c17d3396db Optimization terminated          NA
#> 100: 3059949e-e6ec-428a-8cf6-4193922ef407 Optimization terminated          NA
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
