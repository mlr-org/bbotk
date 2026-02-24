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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-24 11:45:26  9842
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-24 11:45:26  9842
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-24 11:45:26  9842
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-24 11:45:26  9842
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-24 11:45:26  9842
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-24 11:45:26  9842
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-24 11:45:26  9842
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-24 11:45:26  9842
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-24 11:45:26  9842
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-24 11:45:26  9842
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-24 11:45:26  9842
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-24 11:45:26  9842
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-24 11:45:26  9842
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-24 11:45:26  9842
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-24 11:45:26  9842
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-24 11:45:26  9842
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-24 11:45:26  9842
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-24 11:45:26  9842
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-24 11:45:26  9842
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-24 11:45:26  9842
#>  21:   failed  10.000000  5.0000000         NA 2026-02-24 11:45:26    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-24 11:45:26    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-24 11:45:26    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-24 11:45:26    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-24 11:45:26    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-24 11:45:26    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-24 11:45:26    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-24 11:45:26    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-24 11:45:26    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-24 11:45:26    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-24 11:45:26    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-24 11:45:26    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-24 11:45:26    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-24 11:45:26    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-24 11:45:26    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-24 11:45:26    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-24 11:45:26    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-24 11:45:26    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-24 11:45:26    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-24 11:45:26    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-24 11:45:26    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-24 11:45:26    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-24 11:45:26    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-24 11:45:26    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-24 11:45:26    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-24 11:45:26    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-24 11:45:26    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-24 11:45:26    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-24 11:45:26    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-24 11:45:26    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-24 11:45:26    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-24 11:45:26    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-24 11:45:26    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-24 11:45:26    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-24 11:45:26    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-24 11:45:26    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-24 11:45:26    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-24 11:45:26    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-24 11:45:26    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-24 11:45:26    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-24 11:45:26    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-24 11:45:26    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-24 11:45:26    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-24 11:45:26    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-24 11:45:26    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-24 11:45:26    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-24 11:45:26    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-24 11:45:27
#>   2: academical_guineapig 2026-02-24 11:45:27
#>   3: academical_guineapig 2026-02-24 11:45:27
#>   4: academical_guineapig 2026-02-24 11:45:27
#>   5: academical_guineapig 2026-02-24 11:45:27
#>   6: academical_guineapig 2026-02-24 11:45:27
#>   7: academical_guineapig 2026-02-24 11:45:27
#>   8: academical_guineapig 2026-02-24 11:45:27
#>   9: academical_guineapig 2026-02-24 11:45:27
#>  10: academical_guineapig 2026-02-24 11:45:27
#>  11: academical_guineapig 2026-02-24 11:45:27
#>  12: academical_guineapig 2026-02-24 11:45:27
#>  13: academical_guineapig 2026-02-24 11:45:27
#>  14: academical_guineapig 2026-02-24 11:45:27
#>  15: academical_guineapig 2026-02-24 11:45:27
#>  16: academical_guineapig 2026-02-24 11:45:27
#>  17: academical_guineapig 2026-02-24 11:45:27
#>  18: academical_guineapig 2026-02-24 11:45:27
#>  19: academical_guineapig 2026-02-24 11:45:27
#>  20: academical_guineapig 2026-02-24 11:45:27
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
#>   1: 29592c86-5937-4856-9e41-ff8c08b93403                    <NA>  -10.000000
#>   2: 1995ab62-4ce4-42be-a8a4-1281e847a8af                    <NA>  -10.000000
#>   3: 0d707b91-3761-4a22-aea5-28655a347f09                    <NA>  -10.000000
#>   4: d7b0ed7f-4927-420b-879a-848bc3d4ec26                    <NA>  -10.000000
#>   5: 27aad188-749f-4971-8b0c-605a6cc9fe7e                    <NA>  -10.000000
#>   6: 9d54f69d-d96d-4b50-865f-afec8961d2fc                    <NA>  -10.000000
#>   7: c6f7d279-cb9a-4207-8fe4-cbfc780f622f                    <NA>  -10.000000
#>   8: 48ed5734-0e08-4dab-adf5-5a17245cfe4e                    <NA>  -10.000000
#>   9: d73d5715-7e2f-44c5-8e8e-d614cc335c74                    <NA>  -10.000000
#>  10: dc2a065a-6f89-4b84-b089-7a0b45cd9f83                    <NA>  -10.000000
#>  11: 9c8fbed6-27c0-435e-9e27-141f6c5f099a                    <NA>   -7.777778
#>  12: 63c80821-9d30-465e-be57-232e751da614                    <NA>   -7.777778
#>  13: 49ba5be8-bab8-4167-b9aa-5761556b1500                    <NA>   -7.777778
#>  14: 33be85d2-5191-437e-98e7-7dd0f43b36e7                    <NA>   -7.777778
#>  15: be207d24-264b-4927-98eb-49b5e4209c96                    <NA>   -7.777778
#>  16: 81e7fe90-cdd3-438c-849d-6f55fa74a4c5                    <NA>   -7.777778
#>  17: dc3980dc-d814-43c9-929c-584373f6e315                    <NA>   -7.777778
#>  18: a3c85581-3ac8-44f7-bd1a-c8b99af7c22f                    <NA>   -7.777778
#>  19: 8c9e7d83-3c16-4405-83ff-50f6eded616b                    <NA>   -7.777778
#>  20: d4b755e1-909b-469e-abc2-4ae1524b3146                    <NA>   -7.777778
#>  21: 10f6461d-4e3b-457d-a79a-4114a9badbbb Optimization terminated          NA
#>  22: c5101fa9-9730-458a-b63c-4edccb69de78 Optimization terminated          NA
#>  23: e4cfb4e4-d2e1-4150-b6bf-3d9a3b82d36d Optimization terminated          NA
#>  24: 5dfa215b-a7a4-4c97-81ad-9810bf297ff5 Optimization terminated          NA
#>  25: cb115578-2497-4e7b-943f-657ecbe85c95 Optimization terminated          NA
#>  26: 7f4478bc-6d44-4061-9e0e-59b185592b18 Optimization terminated          NA
#>  27: 7bc79c1c-ea41-427e-bb2a-54024579cbb6 Optimization terminated          NA
#>  28: a3749db1-0d7a-4817-9fae-64f10d14bb7a Optimization terminated          NA
#>  29: 4c9d9cb1-c76f-4ff0-b7e9-c763951e4a7a Optimization terminated          NA
#>  30: 1ebc3f4e-12ca-4a72-8e43-dfaaaec653a6 Optimization terminated          NA
#>  31: 5b220f57-c8b5-4d26-8437-94f3f1a1e8ee Optimization terminated          NA
#>  32: 6354e300-d3db-4033-a1a1-e8f49a3e5585 Optimization terminated          NA
#>  33: d3ecc0b4-9e62-40c3-8d68-87471751f918 Optimization terminated          NA
#>  34: 943b91c9-5519-47ee-b8c0-ffe681442b21 Optimization terminated          NA
#>  35: 8c3bf17f-6fe8-4b82-aaac-8718d452c46d Optimization terminated          NA
#>  36: 33e9ec3a-1863-4428-9088-cbc3d4e35cc9 Optimization terminated          NA
#>  37: 42e7c706-018c-4aa7-a0d5-7fd6d2ad3652 Optimization terminated          NA
#>  38: 618d962d-5d30-4a74-a6e8-4e38d1abe45f Optimization terminated          NA
#>  39: dd974bb7-0444-40dd-bd38-52f7a707b28d Optimization terminated          NA
#>  40: 7669f80d-bd6d-43ad-b5da-2d0c64d81c2f Optimization terminated          NA
#>  41: 2bdf0bf5-93f6-4bac-9067-7fe9a42e655b Optimization terminated          NA
#>  42: cbd99c00-c1e9-4ebc-b334-2d709e8f7ffe Optimization terminated          NA
#>  43: f0b4cb72-31a8-4303-a897-f96fb535f9db Optimization terminated          NA
#>  44: eacb35e2-81ca-47ff-878c-cb5a4dccbe93 Optimization terminated          NA
#>  45: 48cbb9de-977c-4a0d-a081-8e56c321e751 Optimization terminated          NA
#>  46: 9e23dba2-544f-4327-aa0d-69239c66ef51 Optimization terminated          NA
#>  47: 27df625d-30eb-4dfc-b597-e62a95b93586 Optimization terminated          NA
#>  48: b8bb43dc-3782-4206-bd06-5011ecc6b692 Optimization terminated          NA
#>  49: b2e216c5-c6f3-48df-9fe0-2f64418b43d9 Optimization terminated          NA
#>  50: 0587b539-f664-476e-afda-c80b95b3a027 Optimization terminated          NA
#>  51: 02e9eb3c-32da-4390-bf2c-f81ee33ea432 Optimization terminated          NA
#>  52: 937befe7-50ce-49bc-a226-4a6956334c19 Optimization terminated          NA
#>  53: ff64d723-8eb2-4c15-a7b2-476e1b26ab31 Optimization terminated          NA
#>  54: 2631d2a9-62f4-4228-bd57-b4fd4951159a Optimization terminated          NA
#>  55: 5a9fbc5e-981f-422d-b164-605bf45e2054 Optimization terminated          NA
#>  56: b511ed7b-c312-460a-9eed-4530b434244c Optimization terminated          NA
#>  57: 87bdf918-213b-4c6f-b478-8f3bd5389ac4 Optimization terminated          NA
#>  58: 64669ba0-6a70-4593-9d8f-ec0617464192 Optimization terminated          NA
#>  59: feb128bf-bdb3-4bb9-91f7-dfe2d9c8aa29 Optimization terminated          NA
#>  60: 265a79e6-84d6-4887-bd0d-9d5c25866059 Optimization terminated          NA
#>  61: d03aa87f-4de4-42db-8ef7-697faa07087c Optimization terminated          NA
#>  62: 2d2cd1a8-063e-4e08-ae19-276c0ee98c91 Optimization terminated          NA
#>  63: e38affe1-3c20-4025-8a52-f399ef6fcf91 Optimization terminated          NA
#>  64: 7cea5836-7a86-4b5e-8d41-7d4381215fef Optimization terminated          NA
#>  65: d4c4f260-9ad3-4eb8-90ef-ba2eca26b1ac Optimization terminated          NA
#>  66: 8147a3e3-6e3f-4eeb-9410-98636d1a2c02 Optimization terminated          NA
#>  67: b23d5d00-da15-4c9a-b8b5-26eed2f40326 Optimization terminated          NA
#>  68: 34522247-26db-4b6f-99fb-0bf9f6dae5ae Optimization terminated          NA
#>  69: 2b412871-725e-444f-8f90-99d2897cc18b Optimization terminated          NA
#>  70: 4ed8eef6-88d4-45db-ac90-07ed361108e5 Optimization terminated          NA
#>  71: 86f9eda3-5a38-45f7-a2a0-a19164a3a124 Optimization terminated          NA
#>  72: 6120f6ee-b47c-492a-8624-4f49f41211f3 Optimization terminated          NA
#>  73: 061cf4ca-7b5f-480b-b6c1-c47b4c780354 Optimization terminated          NA
#>  74: 06d8e600-9721-4fdd-a6c3-230d4e5cd360 Optimization terminated          NA
#>  75: a055b457-3768-446a-96a0-51189c089694 Optimization terminated          NA
#>  76: c66205c3-3b6b-4cc6-8a7f-615c52ff483f Optimization terminated          NA
#>  77: 76f48fb6-edbc-4be5-bbd2-dbfb29c4e521 Optimization terminated          NA
#>  78: 9bf1fc9f-44a4-48f7-afe7-5e9f4d92f22b Optimization terminated          NA
#>  79: 22bf6bf2-173a-4c11-8fe5-4896fccdde78 Optimization terminated          NA
#>  80: a825a94d-5f3b-4c95-8161-abcf411be1c0 Optimization terminated          NA
#>  81: 5ec51723-ba4c-4542-ab54-e810a4416dca Optimization terminated          NA
#>  82: f51eadb5-1b36-45e2-8953-1a38c6ae0add Optimization terminated          NA
#>  83: 94242079-99af-4770-8d00-28b60b438347 Optimization terminated          NA
#>  84: 82b93948-fd3d-4623-982b-f0e1adc6d545 Optimization terminated          NA
#>  85: 27457cf2-611a-473a-b86c-5c8307d2fb9f Optimization terminated          NA
#>  86: 8abc2615-eb08-4a34-a7e0-bb2bdf75029a Optimization terminated          NA
#>  87: bdf7b4d0-e386-417e-afbf-e01fab124577 Optimization terminated          NA
#>  88: 60e36c36-8014-48c9-85aa-731d104b2755 Optimization terminated          NA
#>  89: a997aec1-4399-4542-9f5a-b956c9e30ec7 Optimization terminated          NA
#>  90: 234b3be6-b845-4d0d-b022-ea11ce0193f9 Optimization terminated          NA
#>  91: df380d06-0b4d-4154-8bac-bd8230f5a466 Optimization terminated          NA
#>  92: cecc6251-70b7-4519-a9dd-bbd0c7681081 Optimization terminated          NA
#>  93: 074675c8-23c8-4b67-8f61-092932439d9a Optimization terminated          NA
#>  94: b46f84a5-a585-427a-afd7-7947cc7f4724 Optimization terminated          NA
#>  95: 74751d62-d2ec-481a-8276-b3dd94d11f66 Optimization terminated          NA
#>  96: 8ae39dab-0b27-468d-b629-7640ad42abce Optimization terminated          NA
#>  97: a1c172a6-2ecc-422c-a60c-00d275ff5bcc Optimization terminated          NA
#>  98: 8ff92e20-34b7-4414-8731-9547137f36ce Optimization terminated          NA
#>  99: bec7866a-944b-467b-8cc7-f9bacac9360d Optimization terminated          NA
#> 100: 0826b7e2-a33a-47d2-8a30-311d57b0fd0e Optimization terminated          NA
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
