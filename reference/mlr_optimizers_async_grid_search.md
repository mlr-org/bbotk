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

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-28 07:01:01  9211
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-28 07:01:01  9211
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-28 07:01:01  9211
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-28 07:01:01  9211
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-28 07:01:01  9211
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-28 07:01:01  9211
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-28 07:01:01  9211
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-28 07:01:01  9211
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-28 07:01:01  9211
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-28 07:01:01  9211
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-28 07:01:01  9211
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-28 07:01:01  9211
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-28 07:01:01  9211
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-28 07:01:01  9211
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-28 07:01:01  9211
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-28 07:01:01  9211
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-28 07:01:01  9211
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-28 07:01:01  9211
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-28 07:01:01  9211
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-28 07:01:01  9211
#>  21:   failed  10.000000  5.0000000         NA 2026-02-28 07:01:01    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-28 07:01:01    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-28 07:01:01    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-28 07:01:01    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-28 07:01:01    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-28 07:01:01    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-28 07:01:01    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-28 07:01:01    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-28 07:01:01    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-28 07:01:01    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-28 07:01:01    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-28 07:01:01    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-28 07:01:01    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-28 07:01:01    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-28 07:01:01    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-28 07:01:01    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-28 07:01:01    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-28 07:01:01    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-28 07:01:01    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-28 07:01:01    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-28 07:01:01    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-28 07:01:01    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-28 07:01:01    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-28 07:01:01    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-28 07:01:01    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-28 07:01:01    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-28 07:01:01    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-28 07:01:01    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-28 07:01:01    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-28 07:01:01    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-28 07:01:01    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-28 07:01:01    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-28 07:01:01    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-28 07:01:01    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-28 07:01:01    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-28 07:01:01    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-28 07:01:01    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-28 07:01:01    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-28 07:01:01    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-28 07:01:01    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-28 07:01:01    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-28 07:01:01    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-28 07:01:01    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-28 07:01:01    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-28 07:01:01    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-28 07:01:01    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-28 07:01:01    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-28 07:01:02
#>   2: academical_guineapig 2026-02-28 07:01:02
#>   3: academical_guineapig 2026-02-28 07:01:02
#>   4: academical_guineapig 2026-02-28 07:01:02
#>   5: academical_guineapig 2026-02-28 07:01:02
#>   6: academical_guineapig 2026-02-28 07:01:02
#>   7: academical_guineapig 2026-02-28 07:01:02
#>   8: academical_guineapig 2026-02-28 07:01:02
#>   9: academical_guineapig 2026-02-28 07:01:02
#>  10: academical_guineapig 2026-02-28 07:01:02
#>  11: academical_guineapig 2026-02-28 07:01:02
#>  12: academical_guineapig 2026-02-28 07:01:02
#>  13: academical_guineapig 2026-02-28 07:01:02
#>  14: academical_guineapig 2026-02-28 07:01:02
#>  15: academical_guineapig 2026-02-28 07:01:02
#>  16: academical_guineapig 2026-02-28 07:01:02
#>  17: academical_guineapig 2026-02-28 07:01:02
#>  18: academical_guineapig 2026-02-28 07:01:02
#>  19: academical_guineapig 2026-02-28 07:01:02
#>  20: academical_guineapig 2026-02-28 07:01:02
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
#>                    <char>              <POSc>
#>                                      keys                 message x_domain_x1
#>                                    <char>                  <char>       <num>
#>   1: 5e86d179-9dbd-4aa4-9af0-bb375fcccafa                    <NA>  -10.000000
#>   2: 8772bbb2-8677-4a53-9608-82e440ab0ccf                    <NA>  -10.000000
#>   3: 8eafb8d1-915b-4f50-9e79-abca7876e83c                    <NA>  -10.000000
#>   4: f188108b-b27d-4ada-be34-4a70e19e6d4c                    <NA>  -10.000000
#>   5: 98ca73ac-2234-4c62-b9d5-cc05fe7a01c0                    <NA>  -10.000000
#>   6: 68b48dbd-b571-4063-a3a2-8794bd549182                    <NA>  -10.000000
#>   7: 503b868a-f228-4313-9943-501e06e9432a                    <NA>  -10.000000
#>   8: 61983684-6a44-4ffd-9905-507655fc3d2c                    <NA>  -10.000000
#>   9: b67fe573-69da-42bb-a225-6783174e3da1                    <NA>  -10.000000
#>  10: 98b0d341-241f-402a-a91c-65c18b3c5cfe                    <NA>  -10.000000
#>  11: f74cc5a5-b604-4b27-acdb-07340d06555a                    <NA>   -7.777778
#>  12: eeaa73f4-a8cf-4f72-b43c-a6a1c93196cd                    <NA>   -7.777778
#>  13: 0c00749b-3d47-45d1-abd8-f4fc2ed295db                    <NA>   -7.777778
#>  14: 6234d7c1-bbc7-4ed1-9787-84843890980c                    <NA>   -7.777778
#>  15: 11d3d599-422f-4f00-a848-f74756ff530c                    <NA>   -7.777778
#>  16: 371ee025-a10d-4b9f-b486-367773266cbb                    <NA>   -7.777778
#>  17: 4e4f5e01-42c2-4907-bf1d-008d5235cd15                    <NA>   -7.777778
#>  18: f84fc436-43e9-4d17-8f21-9bc225e66454                    <NA>   -7.777778
#>  19: 1139e6a3-ff2d-46d9-9388-0403d200f233                    <NA>   -7.777778
#>  20: 9370bd43-e700-4feb-bb6e-7dddb5a74738                    <NA>   -7.777778
#>  21: 70337c8c-7f22-4529-8e81-cd001dc79897 Optimization terminated          NA
#>  22: 31cc6d4f-efd6-4628-9879-9711626cf247 Optimization terminated          NA
#>  23: 057fb893-c141-4fe4-93f6-f166dccdce15 Optimization terminated          NA
#>  24: 1ff3ae3f-93b3-41e9-a69d-95289536a401 Optimization terminated          NA
#>  25: ef607735-9e1c-4599-95c6-3efa08edc57f Optimization terminated          NA
#>  26: 8f96abc9-6660-4aaa-81ba-ba3da332e571 Optimization terminated          NA
#>  27: 474de77c-3a9a-4ee8-83f1-0ff2f55b4340 Optimization terminated          NA
#>  28: 7673c237-0ae6-4f1c-a0d6-d87ef4bff8e3 Optimization terminated          NA
#>  29: dd3f2bf0-3877-44ac-b66f-cf45bdc7e04a Optimization terminated          NA
#>  30: 6e75cd1f-6bcd-431a-a5df-f19870562a96 Optimization terminated          NA
#>  31: a318e00a-412f-4b3d-b2ac-11431aea333c Optimization terminated          NA
#>  32: 04624805-ec8f-444b-a4dd-2a03487a9393 Optimization terminated          NA
#>  33: 92cbc50c-da73-4a11-8241-cdfc00c77695 Optimization terminated          NA
#>  34: f01dccde-144f-4652-b4ce-ad4bb415384e Optimization terminated          NA
#>  35: f2604be4-2c2a-4265-bb33-9cede92bcf79 Optimization terminated          NA
#>  36: c9e5464b-0073-475b-bc72-9fd9725089c1 Optimization terminated          NA
#>  37: 58173cb6-89ff-4ca3-8fd6-7104f65f7886 Optimization terminated          NA
#>  38: 293ff7ea-3749-48a9-8cff-d54225f3407e Optimization terminated          NA
#>  39: 552a8f12-f08f-44f6-8667-182972719c7e Optimization terminated          NA
#>  40: 338e77c2-4e80-4498-acdc-18e1ac65effd Optimization terminated          NA
#>  41: cc3bcb43-0c2a-41cf-96f0-198c5dd5869d Optimization terminated          NA
#>  42: 91c07788-593e-43d9-aae2-e608a36ae488 Optimization terminated          NA
#>  43: 81e2a6d9-547d-46e1-809d-94479f69cde2 Optimization terminated          NA
#>  44: f8e59407-d87d-4d76-bf70-851e7226effb Optimization terminated          NA
#>  45: 15d00dc2-5083-4f10-8475-ef69081cfc52 Optimization terminated          NA
#>  46: c4f129b9-f6c5-431c-ba65-bedd9e20bf18 Optimization terminated          NA
#>  47: 203fa750-f487-459c-87c0-7c793621b08c Optimization terminated          NA
#>  48: be54602e-c65f-4e60-8732-22b382b25151 Optimization terminated          NA
#>  49: aaf5bc40-36f9-4672-b2db-554b0d876baf Optimization terminated          NA
#>  50: ed2e0cd7-8cf0-492a-9bde-e8e8921948a1 Optimization terminated          NA
#>  51: a5bd499a-6eac-4803-ab0e-5e7dc5a198fb Optimization terminated          NA
#>  52: 39805f28-ec28-4285-869c-a88c5a9cd175 Optimization terminated          NA
#>  53: 9290599d-5fa8-4646-8612-70bda72d5563 Optimization terminated          NA
#>  54: 4cd214db-d70f-440c-a584-d10157b13074 Optimization terminated          NA
#>  55: 12a3f1c3-7bdb-4571-b19f-3f681452cad5 Optimization terminated          NA
#>  56: f5c4d406-53f4-41fe-8d48-5352b660f2d3 Optimization terminated          NA
#>  57: b078b6c8-ce94-4fc3-b030-193922ff5f3c Optimization terminated          NA
#>  58: 3a3f3418-5dc8-4826-88d0-ad850c56681c Optimization terminated          NA
#>  59: 963681b7-116e-4004-b3d0-1dd47e445b35 Optimization terminated          NA
#>  60: 199813d2-ffec-478e-a97f-1ab4498e7eb3 Optimization terminated          NA
#>  61: 420f6be4-9e0f-4144-8fe1-e580b573f49d Optimization terminated          NA
#>  62: ba065511-0c42-48d6-b57d-2901f4dde70c Optimization terminated          NA
#>  63: 22b0eded-ac17-4ba5-8c68-dfbe39ddbd8b Optimization terminated          NA
#>  64: a68fc484-d990-445b-8a9a-eebe7bd590ef Optimization terminated          NA
#>  65: 046eedab-c1ef-46b6-a6f8-c27eddc8e850 Optimization terminated          NA
#>  66: a2523249-e903-460b-8435-ac8afc5eff93 Optimization terminated          NA
#>  67: 4e8ecaf1-d011-4791-b5ef-6dfa989be94b Optimization terminated          NA
#>  68: d29e9d17-f8d8-480e-8472-cd299cd8ebe9 Optimization terminated          NA
#>  69: 920f6cd3-19d6-489c-938e-c58dba5e80bc Optimization terminated          NA
#>  70: 45b4a860-e654-4350-b1f7-be44d7141be1 Optimization terminated          NA
#>  71: 9965dd8e-0f63-496f-9a55-ee819198e716 Optimization terminated          NA
#>  72: d139ef27-285b-4436-b9e0-03f92e0833e0 Optimization terminated          NA
#>  73: a2915943-9637-40b9-9e8a-8ed8796b0679 Optimization terminated          NA
#>  74: 2ab255b6-0dc4-464f-b819-b2f7a3b2296a Optimization terminated          NA
#>  75: e9f98e63-c592-481f-a787-af309ff4294d Optimization terminated          NA
#>  76: b6507d5e-9851-4155-a8fd-8690371f58b4 Optimization terminated          NA
#>  77: 5101d157-1b5c-4dc0-b45d-6d6c0dfcd086 Optimization terminated          NA
#>  78: 663e1ac3-dcb3-458c-920d-f79b5cf47dea Optimization terminated          NA
#>  79: 81df4c3c-7356-4b16-8aa4-9c281e27d9af Optimization terminated          NA
#>  80: f7c6bd96-85af-4f11-ab31-4e99ec68b623 Optimization terminated          NA
#>  81: 688430da-e1d7-4bb6-92ab-bc738b7815ba Optimization terminated          NA
#>  82: 134a701c-2862-4ab6-ad37-43b1c7061462 Optimization terminated          NA
#>  83: 876419a8-3662-4323-87d0-39dfef814ccd Optimization terminated          NA
#>  84: dee84760-2337-46c0-a2a8-83b2dfdee7a4 Optimization terminated          NA
#>  85: 479a191f-0c80-4561-bdf0-1e8e8f20b257 Optimization terminated          NA
#>  86: fa416f1c-7cac-49af-acff-a888b7aad51d Optimization terminated          NA
#>  87: 9b14f5bd-0e25-4403-abc7-6a6d35125fcf Optimization terminated          NA
#>  88: 1820c490-1947-43be-974d-c8846ea0f78e Optimization terminated          NA
#>  89: 83e54534-96fa-4744-9128-d21d95296b0c Optimization terminated          NA
#>  90: 41555e0d-fb3a-4fad-ae48-d95da0cc0df5 Optimization terminated          NA
#>  91: 43694d77-8b59-4fce-96e9-36e2c07bce87 Optimization terminated          NA
#>  92: 576b886b-bf1c-457f-8142-ad82c86b028d Optimization terminated          NA
#>  93: 194289f4-051f-4c1f-a116-8db1da5b2698 Optimization terminated          NA
#>  94: 650c4d3c-cca5-47e3-b432-d6095144532a Optimization terminated          NA
#>  95: a7e46ad8-cf43-4c60-a45f-8e83756c2282 Optimization terminated          NA
#>  96: b983b298-97a4-42c9-b00d-e834bebdf78b Optimization terminated          NA
#>  97: 5a96cbc2-f117-49a9-bd8c-73185d2ebeb8 Optimization terminated          NA
#>  98: 45cb025c-b80f-4307-a62b-3678a217e00c Optimization terminated          NA
#>  99: d3edcc38-aa00-4771-934c-0a6642826398 Optimization terminated          NA
#> 100: ead9d68e-0e73-4421-96b7-9fcdc74a7cb4 Optimization terminated          NA
#>                                      keys                 message x_domain_x1
#>                                    <char>                  <char>       <num>
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
#>            <num>
```
