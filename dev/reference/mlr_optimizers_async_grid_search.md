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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-12-13 11:32:31  9151
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-12-13 11:32:31  9151
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-12-13 11:32:31  9151
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-12-13 11:32:31  9151
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-12-13 11:32:31  9151
#>   6: finished -10.000000  0.5555556 -146.64198 2025-12-13 11:32:31  9151
#>   7: finished -10.000000  1.6666667 -155.77778 2025-12-13 11:32:31  9151
#>   8: finished -10.000000  2.7777778 -167.38272 2025-12-13 11:32:31  9151
#>   9: finished -10.000000  3.8888889 -181.45679 2025-12-13 11:32:31  9151
#>  10: finished -10.000000  5.0000000 -198.00000 2025-12-13 11:32:31  9151
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-12-13 11:32:31  9151
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-12-13 11:32:31  9151
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-12-13 11:32:31  9151
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-12-13 11:32:31  9151
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-12-13 11:32:31  9151
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-12-13 11:32:31  9151
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-12-13 11:32:31  9151
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-12-13 11:32:31  9151
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-12-13 11:32:31  9151
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-12-13 11:32:31  9151
#>  21:   failed  10.000000  5.0000000         NA 2025-12-13 11:32:31    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-12-13 11:32:31    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-12-13 11:32:31    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-12-13 11:32:31    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-12-13 11:32:31    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-12-13 11:32:31    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-12-13 11:32:31    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-12-13 11:32:31    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-12-13 11:32:31    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-12-13 11:32:31    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-12-13 11:32:31    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-12-13 11:32:31    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-12-13 11:32:31    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-12-13 11:32:31    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-12-13 11:32:31    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-12-13 11:32:31    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-12-13 11:32:31    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-12-13 11:32:31    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-12-13 11:32:31    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-12-13 11:32:31    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-12-13 11:32:31    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-12-13 11:32:31    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-12-13 11:32:31    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-12-13 11:32:31    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-12-13 11:32:31    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-12-13 11:32:31    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-12-13 11:32:31    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-12-13 11:32:31    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-12-13 11:32:31    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-12-13 11:32:31    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-12-13 11:32:31    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-12-13 11:32:31    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-12-13 11:32:31    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-12-13 11:32:31    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-12-13 11:32:31    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-12-13 11:32:31    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-12-13 11:32:31    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-12-13 11:32:31    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-12-13 11:32:31    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-12-13 11:32:31    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-12-13 11:32:31    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-12-13 11:32:31    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-12-13 11:32:31    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-12-13 11:32:31    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-12-13 11:32:31    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-12-13 11:32:31    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-12-13 11:32:31    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-12-13 11:32:32
#>   2: academical_guineapig 2025-12-13 11:32:32
#>   3: academical_guineapig 2025-12-13 11:32:32
#>   4: academical_guineapig 2025-12-13 11:32:32
#>   5: academical_guineapig 2025-12-13 11:32:32
#>   6: academical_guineapig 2025-12-13 11:32:32
#>   7: academical_guineapig 2025-12-13 11:32:32
#>   8: academical_guineapig 2025-12-13 11:32:32
#>   9: academical_guineapig 2025-12-13 11:32:32
#>  10: academical_guineapig 2025-12-13 11:32:32
#>  11: academical_guineapig 2025-12-13 11:32:32
#>  12: academical_guineapig 2025-12-13 11:32:32
#>  13: academical_guineapig 2025-12-13 11:32:32
#>  14: academical_guineapig 2025-12-13 11:32:32
#>  15: academical_guineapig 2025-12-13 11:32:32
#>  16: academical_guineapig 2025-12-13 11:32:32
#>  17: academical_guineapig 2025-12-13 11:32:32
#>  18: academical_guineapig 2025-12-13 11:32:32
#>  19: academical_guineapig 2025-12-13 11:32:32
#>  20: academical_guineapig 2025-12-13 11:32:32
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
#>   1: 6f5b4116-c625-4884-8610-7d6e7487c7b0                    <NA>  -10.000000
#>   2: 73e28561-d8da-414c-a7af-63316dc678e9                    <NA>  -10.000000
#>   3: f1235d6e-89f5-4ba9-acd3-53b15fda30c6                    <NA>  -10.000000
#>   4: cdbe9a2f-272e-462d-87ad-c66d3dfa28c7                    <NA>  -10.000000
#>   5: 7f014409-a52b-4174-b941-0b250ad6055f                    <NA>  -10.000000
#>   6: 212fb9f7-338c-42d2-b2aa-070cfd372b0b                    <NA>  -10.000000
#>   7: e7649900-c101-4159-92cc-fb4eab165066                    <NA>  -10.000000
#>   8: 5740fbec-a779-47e7-98a2-2baea0db2a98                    <NA>  -10.000000
#>   9: 174fb362-7580-487e-9562-2cd0b4fbb468                    <NA>  -10.000000
#>  10: c7300632-28e9-451a-a4e9-5a8134a220e8                    <NA>  -10.000000
#>  11: 56063432-346b-40ed-80cd-9b267a4153b2                    <NA>   -7.777778
#>  12: 4b25a556-d96c-47dd-9942-840fdd6f8c4a                    <NA>   -7.777778
#>  13: a340ce71-5711-47da-826a-fc8145a908cd                    <NA>   -7.777778
#>  14: dc1fef93-279b-4710-9600-f16425759139                    <NA>   -7.777778
#>  15: 23a96bd0-9405-41b8-9fe1-b742c1d47a3d                    <NA>   -7.777778
#>  16: 5861dd59-c693-4298-8bae-df9a20330ee5                    <NA>   -7.777778
#>  17: 50c62d23-a7c3-4e45-8fab-808d45c02116                    <NA>   -7.777778
#>  18: 7ba64e77-6922-4499-8bb9-a92feec6d1d7                    <NA>   -7.777778
#>  19: 3f957edc-0e48-4a17-8520-027c6ca4f227                    <NA>   -7.777778
#>  20: 835301be-37f4-4185-be9f-f1cea1c9e5b0                    <NA>   -7.777778
#>  21: e6cf9ab0-8c2b-4e86-96b3-49639102378d Optimization terminated          NA
#>  22: a329842c-9c4c-4bae-8348-043458999758 Optimization terminated          NA
#>  23: cb2705c5-7e47-448b-bc1d-d849f13836b5 Optimization terminated          NA
#>  24: 0fc7fbbf-73b2-463b-9be4-6a673d635698 Optimization terminated          NA
#>  25: 6d1e058e-7d47-43fa-a0bf-c2aa77b5ebf9 Optimization terminated          NA
#>  26: 3f4517c8-271b-48bf-8c61-a8d1793afdef Optimization terminated          NA
#>  27: 990620e9-bf9f-4a8d-9b34-a1366435c651 Optimization terminated          NA
#>  28: d53b7706-104d-43ce-9e62-111aac30cb49 Optimization terminated          NA
#>  29: de9230e2-6db0-4a5f-a343-0b953a03741b Optimization terminated          NA
#>  30: 7b5014ba-d86e-4e3f-9848-c7ebff5c1da0 Optimization terminated          NA
#>  31: e260b27b-1550-4fd5-9f64-efa760a0f0fa Optimization terminated          NA
#>  32: 2ab0923d-6966-473b-a538-1bde1e835132 Optimization terminated          NA
#>  33: 76bab846-0d6f-45ff-9f32-b6003a1498de Optimization terminated          NA
#>  34: db95be13-d046-402f-bbc6-74055ef2b48b Optimization terminated          NA
#>  35: 226f0f7e-b5ea-4ba6-8707-fbdcc4a8040f Optimization terminated          NA
#>  36: 1336ae7c-8a59-4860-93d0-1034f60c6acd Optimization terminated          NA
#>  37: 0d1f3070-186c-4b04-b740-a621499b3c3d Optimization terminated          NA
#>  38: 2de754bb-5a5f-42aa-b961-613e0e7e4729 Optimization terminated          NA
#>  39: 8b27a2d5-f6d9-47c6-8c2d-d96cccd035b4 Optimization terminated          NA
#>  40: a3573a7d-1a12-4546-b52e-1f1f3d160e92 Optimization terminated          NA
#>  41: d4c85071-acba-4fec-a362-fb7b2ad5a5d9 Optimization terminated          NA
#>  42: 5301292c-2e7a-4d09-bc94-dfa8341efc72 Optimization terminated          NA
#>  43: 5d542895-9de5-4bb7-bd88-3322c778283d Optimization terminated          NA
#>  44: 0f672dcd-8267-4ab3-97b5-c77fdb0aa077 Optimization terminated          NA
#>  45: c753a6ef-a3f2-4480-a9fc-a7a01e917edc Optimization terminated          NA
#>  46: 2657505c-36ed-4366-82fa-0bfcac807fb6 Optimization terminated          NA
#>  47: 1bfe318c-250d-4dee-adb4-6fb43cc66a84 Optimization terminated          NA
#>  48: 9bf5910e-108a-4ba3-b2ff-cdbf13adca11 Optimization terminated          NA
#>  49: e006ba8e-6b85-4b49-b31b-602128005460 Optimization terminated          NA
#>  50: 61084d14-6a7b-4703-8318-68cd75c00c5a Optimization terminated          NA
#>  51: a5eb5088-23cd-4095-b75e-74c172391e53 Optimization terminated          NA
#>  52: 192009e1-9ead-4014-8e89-8e67130927ff Optimization terminated          NA
#>  53: 6e061cf7-3283-4e3f-8d46-79c33c0f3e54 Optimization terminated          NA
#>  54: 6fe64cae-e5f6-4943-9020-60bbe00339e3 Optimization terminated          NA
#>  55: efc6ca6e-72bd-4bd4-ae82-c62e49fa661c Optimization terminated          NA
#>  56: 43e0cfed-1e5e-498f-9e60-fff229dd85f7 Optimization terminated          NA
#>  57: ee8dc4e5-9bf1-4858-ac5c-f3cd79bbbf8b Optimization terminated          NA
#>  58: ae20d76b-e62b-4085-aa49-eaa329edaafc Optimization terminated          NA
#>  59: f83c56b7-449f-4490-8060-ba2ca4471bb7 Optimization terminated          NA
#>  60: bb45838f-058d-4b5c-ae28-fe6ee6a49094 Optimization terminated          NA
#>  61: 2bcd2ea1-d58e-4a8d-a034-07da10bfdaa5 Optimization terminated          NA
#>  62: ca6c3b53-922f-426b-a22b-95e6ae4bad62 Optimization terminated          NA
#>  63: b03f0ed3-71e8-4097-9beb-cacd911fa3e4 Optimization terminated          NA
#>  64: 134213ba-779e-4695-a9d9-976f1d20dd99 Optimization terminated          NA
#>  65: c915e678-ddac-4739-b2be-b28563aac918 Optimization terminated          NA
#>  66: f6bcc3a3-c7a1-406e-93fd-7afe3374f701 Optimization terminated          NA
#>  67: 78cba0ea-dadc-4f00-9f66-8dadde85873d Optimization terminated          NA
#>  68: fdb47038-654e-4f86-8597-f48a56e590b3 Optimization terminated          NA
#>  69: a9019db2-abda-4a4d-a2e2-1a2f778e9a41 Optimization terminated          NA
#>  70: 398a57ef-8678-4a76-8fea-7258de835d43 Optimization terminated          NA
#>  71: e2c8fefe-9e1e-442a-afad-39274f086b55 Optimization terminated          NA
#>  72: 9ed827b3-5aa1-4479-95d5-2c5b9f0a054f Optimization terminated          NA
#>  73: 431ed62c-42cb-4250-88bb-b1e5f8680614 Optimization terminated          NA
#>  74: 4aa78d3f-5e50-4065-b7ae-e6d45b4d56e7 Optimization terminated          NA
#>  75: f88e2aef-4817-4548-b08e-730a30c4fbdf Optimization terminated          NA
#>  76: 080374df-5628-48c9-881a-1248ceba299a Optimization terminated          NA
#>  77: b22e2a5d-f35d-4015-9f94-1b753f7382ea Optimization terminated          NA
#>  78: 906510da-2d9d-427b-9d9f-909c5f949940 Optimization terminated          NA
#>  79: 33176341-a9d9-401f-8e27-feeb2b6ef79c Optimization terminated          NA
#>  80: 7e6864c7-6800-4082-a1c2-febddebc5ef0 Optimization terminated          NA
#>  81: a238a893-d4f5-498b-89e4-616006ecdbe5 Optimization terminated          NA
#>  82: 3c833b66-866b-4712-8491-3779c28f56b2 Optimization terminated          NA
#>  83: 3c63f4b4-522e-4100-ae75-c7d20bc7ac41 Optimization terminated          NA
#>  84: 40cb4557-5d54-416e-8d71-b64c2089c2e8 Optimization terminated          NA
#>  85: 37b82aae-8414-4b63-abe0-0da7496c517e Optimization terminated          NA
#>  86: 5afbc2a3-6622-4ad7-b3a4-adf370cc17b4 Optimization terminated          NA
#>  87: 580a6148-5bb0-4290-9343-bc0839cd53b1 Optimization terminated          NA
#>  88: bccbea69-c4bf-48fa-8c00-4ab81893037d Optimization terminated          NA
#>  89: e62f5d27-9427-4b36-99ec-a6b7053be682 Optimization terminated          NA
#>  90: 3c01c5d7-cd5d-4843-a62c-1309755b6cd3 Optimization terminated          NA
#>  91: ab7abafa-8770-4bd3-bcc3-ccecd5fa4cab Optimization terminated          NA
#>  92: 3ea1fbe0-6086-4823-9734-7d1670a91fdf Optimization terminated          NA
#>  93: 7cf9b842-c354-495d-afdb-3b32c7f7dec3 Optimization terminated          NA
#>  94: 52a1b963-6705-49c0-954e-24539aec19cb Optimization terminated          NA
#>  95: 7636c2a7-5c02-46dd-8026-c1db2bdd4e48 Optimization terminated          NA
#>  96: edad26f0-cbb4-4b76-a269-561d542dd4c1 Optimization terminated          NA
#>  97: c9c87640-ecea-4a11-bf7c-0a2ee662e1e3 Optimization terminated          NA
#>  98: 99d5f836-d0c0-4fac-9ce8-fb843229f3c4 Optimization terminated          NA
#>  99: 3da1115b-6e7a-4ede-8ce7-6a39a8811b0a Optimization terminated          NA
#> 100: 7d8eb2de-3054-441c-9529-8a00ea555c5b Optimization terminated          NA
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
