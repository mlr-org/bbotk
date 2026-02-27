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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-27 14:19:28  9747
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-27 14:19:28  9747
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-27 14:19:28  9747
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-27 14:19:28  9747
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-27 14:19:28  9747
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-27 14:19:28  9747
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-27 14:19:28  9747
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-27 14:19:28  9747
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-27 14:19:28  9747
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-27 14:19:28  9747
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-27 14:19:28  9747
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-27 14:19:28  9747
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-27 14:19:28  9747
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-27 14:19:28  9747
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-27 14:19:28  9747
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-27 14:19:28  9747
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-27 14:19:28  9747
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-27 14:19:28  9747
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-27 14:19:28  9747
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-27 14:19:28  9747
#>  21:   failed  10.000000  5.0000000         NA 2026-02-27 14:19:28    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-27 14:19:28    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-27 14:19:28    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-27 14:19:28    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-27 14:19:28    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-27 14:19:28    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-27 14:19:28    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-27 14:19:28    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-27 14:19:28    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-27 14:19:28    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-27 14:19:28    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-27 14:19:28    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-27 14:19:28    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-27 14:19:28    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-27 14:19:28    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-27 14:19:28    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-27 14:19:28    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-27 14:19:28    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-27 14:19:28    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-27 14:19:28    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-27 14:19:28    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-27 14:19:28    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-27 14:19:28    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-27 14:19:28    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-27 14:19:28    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-27 14:19:28    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-27 14:19:28    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-27 14:19:28    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-27 14:19:28    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-27 14:19:28    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-27 14:19:28    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-27 14:19:28    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-27 14:19:28    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-27 14:19:28    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-27 14:19:28    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-27 14:19:28    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-27 14:19:28    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-27 14:19:28    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-27 14:19:28    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-27 14:19:28    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-27 14:19:28    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-27 14:19:28    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-27 14:19:28    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-27 14:19:28    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-27 14:19:28    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-27 14:19:28    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-27 14:19:28    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-27 14:19:29
#>   2: academical_guineapig 2026-02-27 14:19:29
#>   3: academical_guineapig 2026-02-27 14:19:29
#>   4: academical_guineapig 2026-02-27 14:19:29
#>   5: academical_guineapig 2026-02-27 14:19:29
#>   6: academical_guineapig 2026-02-27 14:19:29
#>   7: academical_guineapig 2026-02-27 14:19:29
#>   8: academical_guineapig 2026-02-27 14:19:29
#>   9: academical_guineapig 2026-02-27 14:19:29
#>  10: academical_guineapig 2026-02-27 14:19:29
#>  11: academical_guineapig 2026-02-27 14:19:29
#>  12: academical_guineapig 2026-02-27 14:19:29
#>  13: academical_guineapig 2026-02-27 14:19:29
#>  14: academical_guineapig 2026-02-27 14:19:29
#>  15: academical_guineapig 2026-02-27 14:19:29
#>  16: academical_guineapig 2026-02-27 14:19:29
#>  17: academical_guineapig 2026-02-27 14:19:29
#>  18: academical_guineapig 2026-02-27 14:19:29
#>  19: academical_guineapig 2026-02-27 14:19:29
#>  20: academical_guineapig 2026-02-27 14:19:29
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
#>   1: 4ef8e3e5-74a3-4c94-94fb-9d8b328efab0                    <NA>  -10.000000
#>   2: b5adbe0d-25e8-4464-a710-4826901262f7                    <NA>  -10.000000
#>   3: 267ff290-d6b3-42a3-8a3a-b2b787b81936                    <NA>  -10.000000
#>   4: cd187630-7181-4dff-a3b6-a54eab22cfe3                    <NA>  -10.000000
#>   5: 78a1deb2-bec6-4311-aed3-44fa7072412a                    <NA>  -10.000000
#>   6: 4495bd82-ae3a-4b67-9c57-29b9c93db070                    <NA>  -10.000000
#>   7: b10369df-ffb4-4edd-bb12-bfb083ae98b6                    <NA>  -10.000000
#>   8: ce8351a6-9535-4991-b931-efbf961d1e85                    <NA>  -10.000000
#>   9: cc62c360-7f15-47ca-b8c2-e0a33bcb5225                    <NA>  -10.000000
#>  10: a5774277-dbe8-47a9-a9c2-ea100950ff27                    <NA>  -10.000000
#>  11: 809ab9cf-84ca-43b1-a3a6-a6841302e1d3                    <NA>   -7.777778
#>  12: 3f7fbe12-c483-4a5c-a0d3-16351497d484                    <NA>   -7.777778
#>  13: eebf559a-9e44-4dd0-b65d-19079f9968c0                    <NA>   -7.777778
#>  14: d15bc2d9-1d5c-4e79-87c8-f1ec6b7218c7                    <NA>   -7.777778
#>  15: 03a0d0ec-910b-451b-a900-eed03d2bf1bb                    <NA>   -7.777778
#>  16: c6d0544e-5406-4a45-9b1c-730de83b90b0                    <NA>   -7.777778
#>  17: 2db4606f-d4b0-4d72-9337-42eaf44b9cfa                    <NA>   -7.777778
#>  18: 0ac4fb41-24dd-4492-98ec-db98ca13aa57                    <NA>   -7.777778
#>  19: 33ec4379-e42f-452c-9739-cda95c4746e1                    <NA>   -7.777778
#>  20: 34cc5911-db24-4c0a-90f9-c08f734c09ed                    <NA>   -7.777778
#>  21: a3fb1fa0-692e-4487-aad5-416ac274f380 Optimization terminated          NA
#>  22: 1525d930-950b-452d-bace-86f7168806be Optimization terminated          NA
#>  23: 78872842-7528-42b9-a7ed-562d59683f6b Optimization terminated          NA
#>  24: 05b424ee-f62f-4d54-8d60-510904359160 Optimization terminated          NA
#>  25: a5802295-87ca-4185-84bd-bf58a00e07a7 Optimization terminated          NA
#>  26: 740fab51-5d5a-4c20-b500-d81fb5327937 Optimization terminated          NA
#>  27: 36290dbc-ca42-4a76-8aaa-2b617690d692 Optimization terminated          NA
#>  28: aa6b46cc-36f0-417d-abf8-6e4cd1b7a148 Optimization terminated          NA
#>  29: d28731ef-e12b-45db-a371-1d5e2ae7e48f Optimization terminated          NA
#>  30: 09c12781-9e07-418e-a008-5f946352c672 Optimization terminated          NA
#>  31: 92278888-1ad7-4502-b09c-40846f72336c Optimization terminated          NA
#>  32: 76ecfd73-7d2f-4c84-af00-249a11512c3a Optimization terminated          NA
#>  33: 2b4e3a42-1eab-45fe-b674-f6053756a114 Optimization terminated          NA
#>  34: 1e988b87-210d-4218-9119-aea399cfadee Optimization terminated          NA
#>  35: 58fc93a7-152f-4dc3-9fcd-16e76471ba4b Optimization terminated          NA
#>  36: 090b218d-a444-438f-b02a-64e4beeafd6f Optimization terminated          NA
#>  37: 902b5e46-9f76-4a02-a086-a5bd0e46cc5c Optimization terminated          NA
#>  38: 2a896fa4-a5a4-480e-a71f-02554ee07b73 Optimization terminated          NA
#>  39: 53a59b91-54a4-4a8e-b469-3308407b3a68 Optimization terminated          NA
#>  40: 73bf90b8-4800-4386-939a-0a061ff06f5d Optimization terminated          NA
#>  41: 6f7d7b0a-2dea-4e18-86a3-29ba2c156238 Optimization terminated          NA
#>  42: 9ccd83f5-f505-4d9a-a921-0ca61f901ec3 Optimization terminated          NA
#>  43: 5f3d7e45-605e-4e47-ba87-56ae1b6eefd4 Optimization terminated          NA
#>  44: 34b4b712-1cca-4cf5-bc00-9d6cb6ac3fa5 Optimization terminated          NA
#>  45: 2e6ce882-b8df-4729-86bb-c99f8aa89f10 Optimization terminated          NA
#>  46: 26205f98-4a04-42d2-8eaf-987a42229d9d Optimization terminated          NA
#>  47: ec300687-1fc7-4fb6-b900-3c97bf723bdf Optimization terminated          NA
#>  48: 7e122141-f6c4-40a8-bd61-183d3f29e1cd Optimization terminated          NA
#>  49: b5dfa6cb-e2e2-4b6f-a073-a1e541f91af1 Optimization terminated          NA
#>  50: 00268484-ca0e-429b-8b7e-218e8f91fa11 Optimization terminated          NA
#>  51: d4e4a23f-1efb-44ae-a05a-5a679a075cdc Optimization terminated          NA
#>  52: 20a29ef9-e997-4cb6-b589-14eb1198aa66 Optimization terminated          NA
#>  53: f22f0ce0-dfa3-4e0f-898c-099d63df8461 Optimization terminated          NA
#>  54: 772754c5-d9c8-41bf-a9f2-cd5984e31b1a Optimization terminated          NA
#>  55: 55fa2a12-aba4-4d4e-8d7c-b2c3a0267f40 Optimization terminated          NA
#>  56: 002d8b07-5ecc-4b6e-abe4-37da132fd5bc Optimization terminated          NA
#>  57: 98a937e5-b385-4b0e-a40f-c4281ec35b06 Optimization terminated          NA
#>  58: 72224c33-a89f-4d74-9b5d-5d0ba04bf672 Optimization terminated          NA
#>  59: fa047b8f-1960-4b81-b4bf-a5fd8c7af11f Optimization terminated          NA
#>  60: d635263b-cd95-4f30-a26c-3d0f4e0afff7 Optimization terminated          NA
#>  61: f334b144-0e6b-482f-abf9-8986ae959969 Optimization terminated          NA
#>  62: 7931734f-c2bb-4b64-aadd-202506cb0181 Optimization terminated          NA
#>  63: 0021b443-f745-487a-9c1b-4b556c04e6c3 Optimization terminated          NA
#>  64: 708ba27a-7fce-440d-849c-e83af2e0d8ae Optimization terminated          NA
#>  65: bc5e3a8d-4dbc-46f3-9e1a-fdbce28eed81 Optimization terminated          NA
#>  66: 4402ba80-d126-4f3b-afe9-92ca9cedac0d Optimization terminated          NA
#>  67: ced43d5c-871a-4f8a-bfda-15632ca9a727 Optimization terminated          NA
#>  68: 25d2e342-4764-4970-b6d0-d82b8d53d9fd Optimization terminated          NA
#>  69: 6a815b84-a52d-4856-b92b-c33498a8ca6d Optimization terminated          NA
#>  70: 3c6bbfae-44f0-48a8-b130-f7dbb78601c7 Optimization terminated          NA
#>  71: d6f0543b-b8f7-4b7d-9eb4-e1401b181ec7 Optimization terminated          NA
#>  72: bf58ce82-8594-4dc3-8e39-f6edefcfcabe Optimization terminated          NA
#>  73: 440c4448-fa88-4848-ad38-1984c207be37 Optimization terminated          NA
#>  74: e0a16372-b1b5-4ed1-8985-34b04da11811 Optimization terminated          NA
#>  75: a0d39150-4c8e-40e4-ba87-ba3e7c2103ca Optimization terminated          NA
#>  76: 61b9fbf5-bc62-4a93-8201-4e0bbe0f3681 Optimization terminated          NA
#>  77: aa84a858-070e-4d0a-8078-80a5c95153a5 Optimization terminated          NA
#>  78: 8c01f39c-552f-4917-aecf-62e358cae472 Optimization terminated          NA
#>  79: 3106c4ca-1993-4a34-b148-9079c4ec1e55 Optimization terminated          NA
#>  80: d00e1cc2-db75-4f45-aead-edf38672f520 Optimization terminated          NA
#>  81: 7e4d6a78-9762-472b-b50d-f05a60af3cd8 Optimization terminated          NA
#>  82: bd377e2e-02e2-4417-a034-0336f6832abe Optimization terminated          NA
#>  83: 7d369b3c-c0a6-4c40-aaf9-62ad6ee76d0f Optimization terminated          NA
#>  84: 16bf0117-2b59-49f6-9717-2fd94cec6d28 Optimization terminated          NA
#>  85: f4e0dd46-9504-4249-a5e8-6a48c27e15b2 Optimization terminated          NA
#>  86: 16933085-0989-44f3-abba-41a71dc8a372 Optimization terminated          NA
#>  87: f4465a3a-ea87-4fe9-8cbb-853965083001 Optimization terminated          NA
#>  88: 388846b7-52d5-4fb3-a4cb-ec5e25381dfa Optimization terminated          NA
#>  89: 9bbfb60a-aabb-418f-ad7c-1944f8b4d673 Optimization terminated          NA
#>  90: e62e7489-c1ce-4b85-9388-e149dfe7c93d Optimization terminated          NA
#>  91: b850dccf-ccae-4263-ab2f-bb974f606066 Optimization terminated          NA
#>  92: cb194f08-d206-4255-986a-c561049dc166 Optimization terminated          NA
#>  93: 808bd092-7962-43a7-9d5c-9c509fbb32a2 Optimization terminated          NA
#>  94: c4c6bf4d-8051-4ebc-bc0b-e4c1eca5a7a0 Optimization terminated          NA
#>  95: 4f992367-3a0b-437a-8203-39d1abd9ec2f Optimization terminated          NA
#>  96: d5364cd4-e946-4cbe-b29a-435d4294103f Optimization terminated          NA
#>  97: 62b95d80-da78-4f61-9bc9-dea18247fffa Optimization terminated          NA
#>  98: 41c68743-c277-49a1-8a77-035c073e730b Optimization terminated          NA
#>  99: c7bee82b-558c-4ebb-940b-57276b67ead5 Optimization terminated          NA
#> 100: 0408440f-0d1f-498b-82b2-cf84f7dc58ef Optimization terminated          NA
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
