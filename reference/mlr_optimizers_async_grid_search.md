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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-07 11:47:42  9859
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-07 11:47:42  9859
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-07 11:47:42  9859
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-07 11:47:42  9859
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-07 11:47:42  9859
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-07 11:47:42  9859
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-07 11:47:42  9859
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-07 11:47:42  9859
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-07 11:47:42  9859
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-07 11:47:42  9859
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-07 11:47:42  9859
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-07 11:47:42  9859
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-07 11:47:42  9859
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-07 11:47:42  9859
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-07 11:47:42  9859
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-07 11:47:42  9859
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-07 11:47:42  9859
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-07 11:47:42  9859
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-07 11:47:42  9859
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-07 11:47:42  9859
#>  21:   failed  10.000000  5.0000000         NA 2025-11-07 11:47:42    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-07 11:47:42    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-07 11:47:42    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-07 11:47:42    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-07 11:47:42    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-07 11:47:42    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-07 11:47:42    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-07 11:47:42    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-07 11:47:42    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-07 11:47:42    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-07 11:47:42    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-07 11:47:42    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-07 11:47:42    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-07 11:47:42    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-07 11:47:42    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-07 11:47:42    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-07 11:47:42    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-07 11:47:42    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-07 11:47:42    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-07 11:47:42    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-07 11:47:42    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-07 11:47:42    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-07 11:47:42    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-07 11:47:42    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-07 11:47:42    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-07 11:47:42    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-07 11:47:42    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-07 11:47:42    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-07 11:47:42    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-07 11:47:42    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-07 11:47:42    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-07 11:47:42    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-07 11:47:42    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-07 11:47:42    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-07 11:47:42    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-07 11:47:42    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-07 11:47:42    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-07 11:47:42    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-07 11:47:42    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-07 11:47:42    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-07 11:47:42    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-07 11:47:42    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-07 11:47:42    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-07 11:47:42    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-07 11:47:42    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-07 11:47:42    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-07 11:47:42    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-07 11:47:43
#>   2: academical_guineapig 2025-11-07 11:47:43
#>   3: academical_guineapig 2025-11-07 11:47:43
#>   4: academical_guineapig 2025-11-07 11:47:43
#>   5: academical_guineapig 2025-11-07 11:47:43
#>   6: academical_guineapig 2025-11-07 11:47:43
#>   7: academical_guineapig 2025-11-07 11:47:43
#>   8: academical_guineapig 2025-11-07 11:47:43
#>   9: academical_guineapig 2025-11-07 11:47:43
#>  10: academical_guineapig 2025-11-07 11:47:43
#>  11: academical_guineapig 2025-11-07 11:47:43
#>  12: academical_guineapig 2025-11-07 11:47:43
#>  13: academical_guineapig 2025-11-07 11:47:43
#>  14: academical_guineapig 2025-11-07 11:47:43
#>  15: academical_guineapig 2025-11-07 11:47:43
#>  16: academical_guineapig 2025-11-07 11:47:43
#>  17: academical_guineapig 2025-11-07 11:47:43
#>  18: academical_guineapig 2025-11-07 11:47:43
#>  19: academical_guineapig 2025-11-07 11:47:43
#>  20: academical_guineapig 2025-11-07 11:47:43
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
#>   1: d3a694a7-e70f-4198-ab1c-f9ebbed0a3d2                    <NA>  -10.000000
#>   2: ba64bb5e-fe3c-4d39-92da-1d355bc67fd5                    <NA>  -10.000000
#>   3: 2b00b1aa-9b54-426b-9012-e4c7e4fe09c8                    <NA>  -10.000000
#>   4: d3da6eb6-9a0b-45d4-b8c2-b6bef3f4b3b4                    <NA>  -10.000000
#>   5: fc41baef-4f7b-4e9c-9aa1-67db923fe84c                    <NA>  -10.000000
#>   6: e64bfb11-9728-43b9-b89e-53f7fcd816fe                    <NA>  -10.000000
#>   7: 085d4ed2-761b-4126-91a4-f864b9180845                    <NA>  -10.000000
#>   8: 20f21872-7a26-462f-b517-1aa08f219863                    <NA>  -10.000000
#>   9: efe90ebc-d22f-40c1-9eb0-8e24865f3d52                    <NA>  -10.000000
#>  10: 94178144-c8ea-4c3c-a596-9082379756da                    <NA>  -10.000000
#>  11: 32c9dff9-635e-4df2-8ad1-47851c223a53                    <NA>   -7.777778
#>  12: 53b865a1-e559-4a75-b38e-f2a8e9cb3876                    <NA>   -7.777778
#>  13: e5fa4d8c-96bc-469e-a1e9-da022312a2fc                    <NA>   -7.777778
#>  14: f9cb9d1a-e5ea-46f8-8e85-97dec6ac8d37                    <NA>   -7.777778
#>  15: 5ed64d57-7491-42de-80e3-87ad91dfe9bd                    <NA>   -7.777778
#>  16: 02854056-d645-4f5f-9b56-e816fff3bdba                    <NA>   -7.777778
#>  17: 27876a29-d008-4c50-ae1d-87ff20e6215c                    <NA>   -7.777778
#>  18: 75946c85-01b9-419a-81bc-b617d1378afd                    <NA>   -7.777778
#>  19: 696cf895-b53b-4da3-876a-cd8fa703aa0b                    <NA>   -7.777778
#>  20: 1f8e4213-cf23-4708-ae5c-0ef4cf43a11d                    <NA>   -7.777778
#>  21: 398d962f-16c1-4e0b-a2b4-a0e1c629bb96 Optimization terminated          NA
#>  22: 6ec53769-2b43-4d94-a19b-4d60ee5e33e3 Optimization terminated          NA
#>  23: 6478ac73-bc71-43ca-b166-8e1d1279fde5 Optimization terminated          NA
#>  24: ef08659d-7610-4289-a5f9-6f238dd0cf48 Optimization terminated          NA
#>  25: 28cf7e1d-3278-44e0-9aa0-620cc6d6c87f Optimization terminated          NA
#>  26: 2a1537ee-2586-4aa1-9876-18d696c404dc Optimization terminated          NA
#>  27: 04b915b0-3e88-4d08-905f-2ea6884e8f1e Optimization terminated          NA
#>  28: da6756e1-33d8-48ef-9877-407cf8cec6c4 Optimization terminated          NA
#>  29: 3f27f384-6edc-469e-9686-e9e857670cac Optimization terminated          NA
#>  30: 059f0841-1a96-439e-ae71-c91348c6ac1c Optimization terminated          NA
#>  31: f44cb0e1-7135-4829-9e99-0d7026b5ec65 Optimization terminated          NA
#>  32: 14f2d00a-311d-4257-8a51-2f2fd68b585c Optimization terminated          NA
#>  33: 3f40f391-1549-4666-b87a-bd8869ac52a1 Optimization terminated          NA
#>  34: b2b3f3aa-6c2e-49e3-954e-f9e7e6d369a1 Optimization terminated          NA
#>  35: bb6e95de-1096-4868-a775-37775d41ae4e Optimization terminated          NA
#>  36: d28ba997-afbe-474e-8061-71acc751b951 Optimization terminated          NA
#>  37: 1cf31824-1ec6-4585-8a39-156014b273aa Optimization terminated          NA
#>  38: 43f6ceaa-e5a7-47ff-920d-f818af347266 Optimization terminated          NA
#>  39: 0a352bc7-d1e5-4257-bffd-2bf5931b944a Optimization terminated          NA
#>  40: c5fc09e2-0bfa-4367-bd51-857d2669804b Optimization terminated          NA
#>  41: 50e8f22c-f832-4837-ac8a-ad1a91597d2f Optimization terminated          NA
#>  42: 07d706ea-367e-4818-abb3-a884928cb9f7 Optimization terminated          NA
#>  43: 01c37d7f-0b05-4c07-a295-f5e4ed7f6475 Optimization terminated          NA
#>  44: 52e87992-db8e-432e-97c9-eaba121ffdf8 Optimization terminated          NA
#>  45: b0486613-a5e5-4ad5-92ee-ca1cfdf24680 Optimization terminated          NA
#>  46: 9dfa3b31-4195-4300-ad75-f13639ca589b Optimization terminated          NA
#>  47: 004fc67f-b5fd-4ca1-8484-fee85e1a1a18 Optimization terminated          NA
#>  48: b529f1d8-065c-47e4-b30e-b46c8d4bed77 Optimization terminated          NA
#>  49: 26a5be61-5fc3-4f80-b099-cb2d58c432bd Optimization terminated          NA
#>  50: 243e2a7a-298b-4ca3-9b64-5ca11ae346d5 Optimization terminated          NA
#>  51: 07033d73-23c9-488b-8a61-93ca63e3bf3c Optimization terminated          NA
#>  52: 2d0b8ad2-f5b7-4460-9918-5ec1d8d90cee Optimization terminated          NA
#>  53: 0ea9ee4a-596e-4376-953b-48955df87294 Optimization terminated          NA
#>  54: 1e3d0fe1-4950-444b-ac20-5a07c9e6d33c Optimization terminated          NA
#>  55: 87cf4b1c-f0f7-46f5-b680-bd19f5019ddd Optimization terminated          NA
#>  56: 18ff2595-77fc-40fa-b3cb-537d0495b03a Optimization terminated          NA
#>  57: 7c0db7b6-6b96-42cd-904d-d54fc19af6ff Optimization terminated          NA
#>  58: 44cf30e8-db5a-474a-a081-8f6a91368dc7 Optimization terminated          NA
#>  59: 51ea9174-6752-40cb-ad5d-3223c7799e0b Optimization terminated          NA
#>  60: ead44160-5089-4eb4-a466-79d099db5dea Optimization terminated          NA
#>  61: d46f0f50-8938-44db-8874-f853aec585cd Optimization terminated          NA
#>  62: 9478d465-75a3-475b-a4d6-ef625b3d9ba8 Optimization terminated          NA
#>  63: 1d271d05-0456-4641-b080-e81420c5232d Optimization terminated          NA
#>  64: 1b70ca0c-d9a2-4006-91d3-e513a4c8f439 Optimization terminated          NA
#>  65: d245dfda-82b6-48eb-b942-05ff53a7f52b Optimization terminated          NA
#>  66: ece43586-9f6d-40e7-a6f4-67ee00dd5420 Optimization terminated          NA
#>  67: eb4fab04-5e1c-461c-b9bf-ce7807501591 Optimization terminated          NA
#>  68: 11de00b1-f9ca-4d55-b4af-4b5b21228287 Optimization terminated          NA
#>  69: 3f7b4db5-be44-45a2-8cd7-30218e10a215 Optimization terminated          NA
#>  70: 492ec6ea-d9d4-429a-b002-9b65595519b9 Optimization terminated          NA
#>  71: 64b1aad4-187a-4af3-b8b5-746ec2d6702e Optimization terminated          NA
#>  72: c9a45cb0-a84e-41a9-981a-f586aad1cf2c Optimization terminated          NA
#>  73: 4d3bca57-4dd2-46a1-b315-53e40dd09d8f Optimization terminated          NA
#>  74: d41fc213-01a6-40fb-b6cf-dfda1fa29cad Optimization terminated          NA
#>  75: 5b65ece7-408a-4361-8be0-5d6220fa98f8 Optimization terminated          NA
#>  76: 68db6a2f-a2e0-4692-8bdf-ab48c33df674 Optimization terminated          NA
#>  77: 4035e256-9a9a-46d5-8316-004d7defd9e5 Optimization terminated          NA
#>  78: 0973e353-7fc5-424a-95c9-3dbd34bef6da Optimization terminated          NA
#>  79: 340b2a97-cfc3-4095-8c33-d6e99d82d506 Optimization terminated          NA
#>  80: 5e28c5a8-81a9-4143-99be-7fe8f031dd45 Optimization terminated          NA
#>  81: cb33ce6e-9ed7-4c49-b781-c42f9a6912d7 Optimization terminated          NA
#>  82: 4b1dd0de-ce4b-40d0-8e7d-26ae0aeb7faf Optimization terminated          NA
#>  83: 010cb5fc-0dd4-4eea-88bf-3ae1366902d2 Optimization terminated          NA
#>  84: 4a1464de-fd68-4827-93f9-517a4e270b20 Optimization terminated          NA
#>  85: 80ae7cf7-48d0-44c5-beeb-5bc3a2a1e723 Optimization terminated          NA
#>  86: 127e59ba-fb34-4df3-b059-4f22abda76cb Optimization terminated          NA
#>  87: 3ea72427-944f-4a7c-972f-ff2f01163e9c Optimization terminated          NA
#>  88: e9d32eb2-8acf-4fc8-b39d-60714377bd92 Optimization terminated          NA
#>  89: 2781eb3d-d5ba-43a8-a636-23192fdaae58 Optimization terminated          NA
#>  90: 59902e0a-e30f-4ee2-869c-d7bf4e124e4f Optimization terminated          NA
#>  91: c53a5bd9-0085-4518-92a9-a2ee316329e9 Optimization terminated          NA
#>  92: 4d7bd9d2-5c3e-4123-9108-bfb61c32af1d Optimization terminated          NA
#>  93: dc6704a5-1d3f-46c7-9573-e05c1027c51d Optimization terminated          NA
#>  94: 564ce6fb-3ee5-4a83-939d-4be5fb1cb704 Optimization terminated          NA
#>  95: 5be559fd-1928-49b5-8967-849a33e235ed Optimization terminated          NA
#>  96: 3e96a9c3-210b-4acf-ae26-9d3a56dd3231 Optimization terminated          NA
#>  97: 4c79b684-8b5f-4986-8882-aa1969e361f6 Optimization terminated          NA
#>  98: 6fd7a9f2-0903-4e66-bea8-a0c1513b9279 Optimization terminated          NA
#>  99: 61a54216-398f-45dd-bf4e-f24992a3c509 Optimization terminated          NA
#> 100: b8ffa1f1-22b0-4cac-b5ad-753b3c691843 Optimization terminated          NA
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
