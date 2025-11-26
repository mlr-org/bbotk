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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-26 11:10:06  8298
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-26 11:10:06  8298
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-26 11:10:06  8298
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-26 11:10:06  8298
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-26 11:10:06  8298
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-26 11:10:06  8298
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-26 11:10:06  8298
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-26 11:10:06  8298
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-26 11:10:06  8298
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-26 11:10:06  8298
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-26 11:10:06  8298
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-26 11:10:06  8298
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-26 11:10:06  8298
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-26 11:10:06  8298
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-26 11:10:06  8298
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-26 11:10:06  8298
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-26 11:10:06  8298
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-26 11:10:06  8298
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-26 11:10:06  8298
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-26 11:10:06  8298
#>  21:   failed  10.000000  5.0000000         NA 2025-11-26 11:10:06    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-26 11:10:06    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-26 11:10:06    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-26 11:10:06    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-26 11:10:06    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-26 11:10:06    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-26 11:10:06    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-26 11:10:06    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-26 11:10:06    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-26 11:10:06    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-26 11:10:06    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-26 11:10:06    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-26 11:10:06    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-26 11:10:06    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-26 11:10:06    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-26 11:10:06    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-26 11:10:06    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-26 11:10:06    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-26 11:10:06    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-26 11:10:06    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-26 11:10:06    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-26 11:10:06    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-26 11:10:06    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-26 11:10:06    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-26 11:10:06    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-26 11:10:06    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-26 11:10:06    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-26 11:10:06    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-26 11:10:06    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-26 11:10:06    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-26 11:10:06    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-26 11:10:06    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-26 11:10:06    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-26 11:10:06    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-26 11:10:06    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-26 11:10:06    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-26 11:10:06    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-26 11:10:06    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-26 11:10:06    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-26 11:10:06    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-26 11:10:06    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-26 11:10:06    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-26 11:10:06    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-26 11:10:06    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-26 11:10:06    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-26 11:10:06    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-26 11:10:06    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-26 11:10:07
#>   2: academical_guineapig 2025-11-26 11:10:07
#>   3: academical_guineapig 2025-11-26 11:10:07
#>   4: academical_guineapig 2025-11-26 11:10:07
#>   5: academical_guineapig 2025-11-26 11:10:07
#>   6: academical_guineapig 2025-11-26 11:10:07
#>   7: academical_guineapig 2025-11-26 11:10:07
#>   8: academical_guineapig 2025-11-26 11:10:07
#>   9: academical_guineapig 2025-11-26 11:10:07
#>  10: academical_guineapig 2025-11-26 11:10:07
#>  11: academical_guineapig 2025-11-26 11:10:07
#>  12: academical_guineapig 2025-11-26 11:10:07
#>  13: academical_guineapig 2025-11-26 11:10:07
#>  14: academical_guineapig 2025-11-26 11:10:07
#>  15: academical_guineapig 2025-11-26 11:10:07
#>  16: academical_guineapig 2025-11-26 11:10:07
#>  17: academical_guineapig 2025-11-26 11:10:07
#>  18: academical_guineapig 2025-11-26 11:10:07
#>  19: academical_guineapig 2025-11-26 11:10:07
#>  20: academical_guineapig 2025-11-26 11:10:07
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
#>   1: 25f929d4-5cc4-4148-b97d-e64c1f21e50c                    <NA>  -10.000000
#>   2: 751c7ca3-549d-4809-a354-c6bca594bb61                    <NA>  -10.000000
#>   3: 5c252f3b-bd66-4287-8c17-9c29f9b8507f                    <NA>  -10.000000
#>   4: 56f9b1c7-ef4c-4bbb-8cae-34f382924e78                    <NA>  -10.000000
#>   5: 92495377-d16d-47e6-82d6-bbd8a5669653                    <NA>  -10.000000
#>   6: 0e1594d3-58bb-4faa-9733-b5cdb7db78bb                    <NA>  -10.000000
#>   7: 5317182d-2a46-4596-92d0-15333f5d3f09                    <NA>  -10.000000
#>   8: 16f1c8f4-5fd0-42c6-a0f7-03440eb28341                    <NA>  -10.000000
#>   9: aed06600-bc41-4176-820b-cbc31e443751                    <NA>  -10.000000
#>  10: a29b0e9d-0485-4842-b073-6caf68c0d02e                    <NA>  -10.000000
#>  11: 77e6551e-777a-4332-86e9-b39cc8234cfd                    <NA>   -7.777778
#>  12: 30af7433-4dbc-41ca-8650-7d7ef56258c3                    <NA>   -7.777778
#>  13: 2490edcb-77a4-4f00-8e38-8494a5f226ac                    <NA>   -7.777778
#>  14: 58a13c9d-023a-4396-867b-4aa6040091ad                    <NA>   -7.777778
#>  15: df40165d-471c-45cb-a7f4-91a00445c31a                    <NA>   -7.777778
#>  16: 4d30613a-ab35-4727-9fea-a1d02feaa653                    <NA>   -7.777778
#>  17: 7643f891-3eca-4d9d-a242-b9ae2b68e4b3                    <NA>   -7.777778
#>  18: 5c1767fe-add0-4d0d-a783-63cfeaec598f                    <NA>   -7.777778
#>  19: 48976045-4706-469b-9240-1615d0ee1c33                    <NA>   -7.777778
#>  20: 45cbf721-b4c5-4597-bfe4-43c01878d738                    <NA>   -7.777778
#>  21: 9056412a-33d2-41a0-878b-bcee06912101 Optimization terminated          NA
#>  22: 10059351-d242-4cd8-a407-c62e0aa9edcf Optimization terminated          NA
#>  23: 829ce7fd-03cc-47f1-a79c-7582fe5ee749 Optimization terminated          NA
#>  24: 5d3fa7bc-d374-4ab0-8685-04e1be53abda Optimization terminated          NA
#>  25: f70aeaaa-4f04-415f-b03c-6cba08b0b91b Optimization terminated          NA
#>  26: ac4adb5d-629e-4358-bd6c-08089492f289 Optimization terminated          NA
#>  27: 73728d87-7651-49fc-b3d4-4d4e510f3416 Optimization terminated          NA
#>  28: 7216e527-1df0-4a87-a299-9b4276149fc3 Optimization terminated          NA
#>  29: 91906b43-c8b7-4f6a-b6f7-725fca6980d8 Optimization terminated          NA
#>  30: 8a923b94-7dd8-47e2-a1cb-8a0732d09027 Optimization terminated          NA
#>  31: 95ebe6a8-da75-47e8-8c03-363a3310b37c Optimization terminated          NA
#>  32: 009ccbda-30d7-44d2-a988-51087e0da05e Optimization terminated          NA
#>  33: 07145e86-be25-42ec-80ba-b1038c6b7f1e Optimization terminated          NA
#>  34: 72be3f72-2405-47d9-8fcb-95ad922d77be Optimization terminated          NA
#>  35: 786f3bc7-e003-43f1-80de-5518f86aadac Optimization terminated          NA
#>  36: 84d37549-b405-4c95-943c-99650275c7eb Optimization terminated          NA
#>  37: 391d21fb-5493-46b8-95f0-fba8981edc0f Optimization terminated          NA
#>  38: 17d75dd8-5d54-4d06-aa7f-773f3b0410fc Optimization terminated          NA
#>  39: da1eae06-dbb8-4271-a2ec-5b9b9ac66614 Optimization terminated          NA
#>  40: 08876540-ac78-440d-bc1f-9576508ba427 Optimization terminated          NA
#>  41: e6ef6aa2-7817-48b8-8f8d-fdab28bad399 Optimization terminated          NA
#>  42: 222e87a5-57ce-4503-8ae6-317ad22fba79 Optimization terminated          NA
#>  43: d602d120-c79e-4e7d-9a88-dc093669efab Optimization terminated          NA
#>  44: 8a5e0afd-2159-4072-ac1c-48e36b94b694 Optimization terminated          NA
#>  45: ea2c9001-8d05-4aac-ad37-9f875608a8a8 Optimization terminated          NA
#>  46: cf0ae69b-75e5-497a-aba1-98a8ac94505b Optimization terminated          NA
#>  47: 6d6a3213-2321-413a-9993-1c3be39f72c7 Optimization terminated          NA
#>  48: c6595ca0-67cf-4e9d-a15d-7eba4362c3d1 Optimization terminated          NA
#>  49: 9dcf0252-e867-4d76-adc4-639c0a931479 Optimization terminated          NA
#>  50: 11cbcefd-d23d-475d-8abd-94fc4b1b889a Optimization terminated          NA
#>  51: 13987a15-8edb-419f-b680-b9b5a04a4f07 Optimization terminated          NA
#>  52: 4dffb657-4ef5-4afb-a44f-5f1b07cac1ce Optimization terminated          NA
#>  53: ff4f100e-ac0c-4732-9787-8bf456b68ebb Optimization terminated          NA
#>  54: f8805e31-38e7-464c-8439-0bc71f8b2224 Optimization terminated          NA
#>  55: 4aaddafb-aec1-479f-ab92-48921205c0ab Optimization terminated          NA
#>  56: ea6227a1-a6e4-48f2-8e02-57b07a117f01 Optimization terminated          NA
#>  57: 7211d0b0-cd60-4d26-8cef-ce485c8315ac Optimization terminated          NA
#>  58: a27e700d-121c-4199-9c7c-cb5fa3594c92 Optimization terminated          NA
#>  59: 737d1c7d-c3ca-4f8f-a0d8-61e9df94737d Optimization terminated          NA
#>  60: 705d67b5-8e76-4a25-a993-fe8bdc1f1aae Optimization terminated          NA
#>  61: ca7871ed-c178-4284-a0ad-374e63bc2deb Optimization terminated          NA
#>  62: 48c6e1f7-4364-47d8-9ed1-b1136a9d83ac Optimization terminated          NA
#>  63: 49dd920e-1261-4eb1-ab27-32bd926c57e4 Optimization terminated          NA
#>  64: 16ee943a-be0b-4bf2-929f-c40d0b1ef141 Optimization terminated          NA
#>  65: e74e7c20-314d-4850-b59e-ddbaef1a8e4a Optimization terminated          NA
#>  66: 21ec7c82-ae23-4e4f-90e0-a6b53b12b8bf Optimization terminated          NA
#>  67: d02e1600-d34c-4342-80e8-b407e0b9b9ac Optimization terminated          NA
#>  68: a8bd1a65-691f-4553-a54d-d9da15501d83 Optimization terminated          NA
#>  69: ea510175-60e0-418b-8448-3def920128e5 Optimization terminated          NA
#>  70: 3928fd70-b54a-4579-ac3f-47d86e6539bb Optimization terminated          NA
#>  71: 719c1f17-018d-4559-bccb-f8640b09ed7c Optimization terminated          NA
#>  72: 45ea3bba-2f32-47af-854a-c68b6f619f18 Optimization terminated          NA
#>  73: 048669a3-6195-4555-b037-6c6fbe5b5681 Optimization terminated          NA
#>  74: 8edcd0c5-9d68-441f-8df5-efb5fee1a1a1 Optimization terminated          NA
#>  75: 02e84761-d4ab-442f-ac74-823ff0374c8e Optimization terminated          NA
#>  76: 39063dc6-fc2a-4c8d-8e28-667fe2d39479 Optimization terminated          NA
#>  77: 093781f0-71fc-4f29-97e9-e2c27a3c8064 Optimization terminated          NA
#>  78: ecf7e65f-ff6c-4699-bb48-1b6570e96a7d Optimization terminated          NA
#>  79: 0a44d7b5-b309-4cae-9340-2babd4a1285e Optimization terminated          NA
#>  80: dab9a9ab-f240-4f1f-86f7-a8c0f44c0805 Optimization terminated          NA
#>  81: 37070b9e-8f65-49ed-8a73-598f38b70f7a Optimization terminated          NA
#>  82: 8f482a40-8523-4e65-adc8-d0848a994c55 Optimization terminated          NA
#>  83: 0593c65d-394c-412f-8076-77ec3c551673 Optimization terminated          NA
#>  84: 67358dd8-7ef3-483e-b3eb-3a66d4f2b2db Optimization terminated          NA
#>  85: ed57cafb-0d52-4ba9-ab42-da8609234e0c Optimization terminated          NA
#>  86: 1e86e04e-8192-4c33-bb51-6d85c648b18d Optimization terminated          NA
#>  87: 49f7a47e-5d74-4cf5-aa5c-59275a8276a4 Optimization terminated          NA
#>  88: 0aadde59-8afa-4b4d-9755-96f24e620adc Optimization terminated          NA
#>  89: e4c55f8e-997f-4823-8403-b1728596eee3 Optimization terminated          NA
#>  90: 1d265bae-674b-48ce-8135-7bf168401a2e Optimization terminated          NA
#>  91: b9e4a7f7-60f1-4f89-bc7e-f4c9c992d30d Optimization terminated          NA
#>  92: 316d765d-0f4e-49e1-8730-8dfe5722b955 Optimization terminated          NA
#>  93: 2dbd6a13-ccec-4be9-aff9-d8b76e87a35d Optimization terminated          NA
#>  94: 2aab6f99-5346-41a9-a202-6a08dd44de27 Optimization terminated          NA
#>  95: e77b7d87-9513-4189-b91f-2982d77a5077 Optimization terminated          NA
#>  96: 5e34634e-21f4-4e1d-b304-1aa1a5852944 Optimization terminated          NA
#>  97: 9d5cd13b-e32d-44d5-bbd5-374f506d1ebb Optimization terminated          NA
#>  98: b19ae3a8-9d91-4e5f-9512-811b5a392957 Optimization terminated          NA
#>  99: 89f51a07-adb7-4f72-b58f-ab1f78be717c Optimization terminated          NA
#> 100: 172cca8f-5cb3-4e09-a033-3c5f5902972e Optimization terminated          NA
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
