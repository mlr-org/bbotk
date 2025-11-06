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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-06 11:18:38 11668
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-06 11:18:38 11668
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-06 11:18:38 11668
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-06 11:18:38 11668
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-06 11:18:38 11668
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-06 11:18:38 11668
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-06 11:18:38 11668
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-06 11:18:38 11668
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-06 11:18:38 11668
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-06 11:18:38 11668
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-06 11:18:38 11668
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-06 11:18:38 11668
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-06 11:18:38 11668
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-06 11:18:38 11668
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-06 11:18:38 11668
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-06 11:18:38 11668
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-06 11:18:38 11668
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-06 11:18:38 11668
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-06 11:18:38 11668
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-06 11:18:38 11668
#>  21:   failed  10.000000  5.0000000         NA 2025-11-06 11:18:38    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-06 11:18:38    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-06 11:18:38    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-06 11:18:38    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-06 11:18:38    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-06 11:18:38    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-06 11:18:38    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-06 11:18:38    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-06 11:18:38    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-06 11:18:38    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-06 11:18:38    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-06 11:18:38    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-06 11:18:38    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-06 11:18:38    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-06 11:18:38    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-06 11:18:38    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-06 11:18:38    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-06 11:18:38    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-06 11:18:38    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-06 11:18:38    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-06 11:18:38    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-06 11:18:38    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-06 11:18:38    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-06 11:18:38    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-06 11:18:38    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-06 11:18:38    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-06 11:18:38    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-06 11:18:38    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-06 11:18:38    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-06 11:18:38    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-06 11:18:38    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-06 11:18:38    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-06 11:18:38    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-06 11:18:38    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-06 11:18:38    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-06 11:18:38    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-06 11:18:38    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-06 11:18:38    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-06 11:18:38    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-06 11:18:38    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-06 11:18:38    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-06 11:18:38    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-06 11:18:38    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-06 11:18:38    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-06 11:18:38    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-06 11:18:38    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-06 11:18:38    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-06 11:18:39
#>   2: academical_guineapig 2025-11-06 11:18:39
#>   3: academical_guineapig 2025-11-06 11:18:39
#>   4: academical_guineapig 2025-11-06 11:18:39
#>   5: academical_guineapig 2025-11-06 11:18:39
#>   6: academical_guineapig 2025-11-06 11:18:39
#>   7: academical_guineapig 2025-11-06 11:18:39
#>   8: academical_guineapig 2025-11-06 11:18:39
#>   9: academical_guineapig 2025-11-06 11:18:39
#>  10: academical_guineapig 2025-11-06 11:18:39
#>  11: academical_guineapig 2025-11-06 11:18:39
#>  12: academical_guineapig 2025-11-06 11:18:39
#>  13: academical_guineapig 2025-11-06 11:18:39
#>  14: academical_guineapig 2025-11-06 11:18:39
#>  15: academical_guineapig 2025-11-06 11:18:39
#>  16: academical_guineapig 2025-11-06 11:18:39
#>  17: academical_guineapig 2025-11-06 11:18:39
#>  18: academical_guineapig 2025-11-06 11:18:39
#>  19: academical_guineapig 2025-11-06 11:18:39
#>  20: academical_guineapig 2025-11-06 11:18:39
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
#>   1: a124d2af-75d5-42a6-97cf-31dc8f6a6d5b                    <NA>  -10.000000
#>   2: 74a4cc96-9834-495a-80ba-44580aee08d1                    <NA>  -10.000000
#>   3: 5043f723-7c08-4b27-a4bd-aa451d84c71d                    <NA>  -10.000000
#>   4: 2ec6104b-ce47-4e5a-8ddf-f96ff0449a55                    <NA>  -10.000000
#>   5: 9d17e925-f7dd-48ca-9fdf-99b856d95ad0                    <NA>  -10.000000
#>   6: 0d7becf4-6c26-42a1-84df-c493c0a026f5                    <NA>  -10.000000
#>   7: 115b5585-ef7c-4454-98f2-0286baae68b3                    <NA>  -10.000000
#>   8: c52ad2ed-2af0-4935-8512-1c2a3b96509b                    <NA>  -10.000000
#>   9: 1b4a0ab5-2145-44fa-a15c-5686f9efc5ac                    <NA>  -10.000000
#>  10: 4f93fe07-0795-42a8-9fd2-25b277356fa9                    <NA>  -10.000000
#>  11: 2dc26703-866f-4e80-82e5-87cc961f992f                    <NA>   -7.777778
#>  12: 8f86a84f-6c81-43f1-b5fa-b9b167493490                    <NA>   -7.777778
#>  13: 00550e9c-e2dd-45f6-9253-5ed09fe94627                    <NA>   -7.777778
#>  14: 137a7b91-5531-48bc-bda9-3d776d62b575                    <NA>   -7.777778
#>  15: c01e1651-3029-44c6-a8aa-4624d9bebf5c                    <NA>   -7.777778
#>  16: 6421d07f-d0bb-4600-bf17-d8ddab7ac98e                    <NA>   -7.777778
#>  17: 6fe94c13-b818-46fa-8756-2818cf417fdd                    <NA>   -7.777778
#>  18: 27b253e9-feac-4ba6-ba28-fb3351441aa9                    <NA>   -7.777778
#>  19: 2b70a781-f515-4b74-946e-9db8637c537b                    <NA>   -7.777778
#>  20: 23af1d48-3f2e-4045-8e7f-b927206e9e86                    <NA>   -7.777778
#>  21: 0da05940-0e7e-486f-8ee1-7e3f8a82eea9 Optimization terminated          NA
#>  22: 90af29bd-c045-4409-8650-d3e32361dfe2 Optimization terminated          NA
#>  23: ef306bf6-a308-4a05-8c20-c5d6f9180f22 Optimization terminated          NA
#>  24: a76e3470-0959-4095-b41e-b2b6cc4fb4ad Optimization terminated          NA
#>  25: e718404f-f38f-47de-8ff0-6aa181774ba3 Optimization terminated          NA
#>  26: 486fd83e-4ec4-4c7b-bd96-a4173a629580 Optimization terminated          NA
#>  27: 2cb673a8-329c-43f5-81ea-5269c2692d57 Optimization terminated          NA
#>  28: b2e6bc9f-7a5a-4454-9999-c916fd5fb6f5 Optimization terminated          NA
#>  29: d3c21a60-4183-499e-9177-cb35e29ac85e Optimization terminated          NA
#>  30: 39ab0bee-0d07-4d23-bf48-33da686c4a05 Optimization terminated          NA
#>  31: d546b32b-019d-4671-b499-c3b037db61bd Optimization terminated          NA
#>  32: 29897958-d8e6-4253-b9a0-adc2bc1f03fe Optimization terminated          NA
#>  33: 76bf5b97-ab50-4b82-ad1f-6151bb020390 Optimization terminated          NA
#>  34: 26933c65-ddd7-4305-a6ff-56615a04e340 Optimization terminated          NA
#>  35: 2aa8bf7e-57e1-4edd-b1ee-7fef1364eefb Optimization terminated          NA
#>  36: dd5efbe7-73b3-4a82-822c-973e57435d08 Optimization terminated          NA
#>  37: 2eac8df8-db6c-4b22-a148-09a374ab7e62 Optimization terminated          NA
#>  38: cc20b41a-937d-42cd-8897-9fdd7bb6e5d1 Optimization terminated          NA
#>  39: 3fea96e8-f89e-43aa-962e-1fae71e04e26 Optimization terminated          NA
#>  40: a0e04d5c-6992-41dc-9412-aed331cb21ec Optimization terminated          NA
#>  41: 3a5d02c9-64b9-4b3f-8942-09e265a6198f Optimization terminated          NA
#>  42: 4a8d867e-6b68-45da-8462-eab65a0be7ff Optimization terminated          NA
#>  43: 95fa4cd9-b8a8-4e51-bd18-0d236499fcdf Optimization terminated          NA
#>  44: 3cd9b9a3-0990-470c-ace8-8853ef209ade Optimization terminated          NA
#>  45: 4846fa31-0ccc-4519-a9d2-fe57db053e8b Optimization terminated          NA
#>  46: 7c24d251-eb1d-4b85-95c3-892d80cbf045 Optimization terminated          NA
#>  47: 5f2713a6-aa7b-4dc3-88ad-a0f9166bc6d5 Optimization terminated          NA
#>  48: 56c42c45-a4f9-4675-b754-c143d2854022 Optimization terminated          NA
#>  49: 99649362-bb81-4c4a-9ef7-0604c7ca07a4 Optimization terminated          NA
#>  50: 26b7eabf-cdc2-438c-b011-e3cccdaf98dc Optimization terminated          NA
#>  51: 313acea2-b403-4be4-add4-002f354b41ea Optimization terminated          NA
#>  52: da2e2f90-cbe4-42df-8953-de6ed4b8b57d Optimization terminated          NA
#>  53: f8842e07-30e9-427e-a72e-dc6ddd9185a1 Optimization terminated          NA
#>  54: ac3ef646-967a-41c7-b819-0efe763ba071 Optimization terminated          NA
#>  55: 8f070a9f-eb41-43e6-9d07-4602ae7919fa Optimization terminated          NA
#>  56: 31c6ae85-3c37-403f-974d-2544a4127c3c Optimization terminated          NA
#>  57: 4e1a53ec-3f40-4b23-8728-07c58f5f2b7b Optimization terminated          NA
#>  58: fd9a91d2-e0a3-41c1-a4b1-41d2ccff6374 Optimization terminated          NA
#>  59: 31b42687-8bac-421b-85d2-c5c1b93bad11 Optimization terminated          NA
#>  60: d72cbfe6-9bf6-490a-b29c-f6141abd15e6 Optimization terminated          NA
#>  61: fc4c7a37-b1a3-49b4-a515-9da5602ab27f Optimization terminated          NA
#>  62: 2707b050-57b5-44d6-830a-140f31d81982 Optimization terminated          NA
#>  63: 45feab28-bd4f-44e7-9e58-7912a36fedaa Optimization terminated          NA
#>  64: 31c01ed5-7b72-4018-8149-34d2abc97963 Optimization terminated          NA
#>  65: 01f7230a-56ca-4e7c-abf5-599af1bf3ed0 Optimization terminated          NA
#>  66: 9a8b2aea-af6b-4f6f-893b-75d46af5e21f Optimization terminated          NA
#>  67: 8ca8580b-b0f8-4b12-a568-cb0d2b7e1653 Optimization terminated          NA
#>  68: ec606c7a-cf3b-445c-99e9-28e3ba41b2b1 Optimization terminated          NA
#>  69: 6c7e2d67-4ffb-47ad-ac31-9b022f8c1165 Optimization terminated          NA
#>  70: 5be1ac8b-86cf-46c5-9e0e-78a70059f5fc Optimization terminated          NA
#>  71: 24e96387-12c2-45d5-ae6b-aa562c2d230d Optimization terminated          NA
#>  72: 72642fb7-fa38-4a6c-befd-eeefcba1d7ba Optimization terminated          NA
#>  73: 7438d2d4-ba38-49f6-b504-a27d0e5e1074 Optimization terminated          NA
#>  74: 5009aeba-54a4-4f17-a7ab-313f4fe5140a Optimization terminated          NA
#>  75: 63a9cc10-cc03-4d92-b202-835e8949c30d Optimization terminated          NA
#>  76: 428a6da0-7d7d-4490-ad7b-c40503556341 Optimization terminated          NA
#>  77: b658567e-85b9-44e1-8d8e-f8da18a4e1d9 Optimization terminated          NA
#>  78: c2ddfc5d-9540-4250-9c1e-b72d292d7b4a Optimization terminated          NA
#>  79: ecd9032e-862e-40eb-89b8-fdb2f31fdf11 Optimization terminated          NA
#>  80: 11468b37-10b3-42ac-9f29-682b77d427f7 Optimization terminated          NA
#>  81: b6336323-585b-4ff5-8265-5fa96b7d0156 Optimization terminated          NA
#>  82: fcb58a6e-4b94-41dc-962c-04d2b81d51e1 Optimization terminated          NA
#>  83: 5e550022-d7af-4ae7-80ec-d26ed8b1734a Optimization terminated          NA
#>  84: a612dc9b-3713-42a7-ae23-efafff835816 Optimization terminated          NA
#>  85: 7af8e1d6-77fa-4d0e-8f6f-de1bb9231c92 Optimization terminated          NA
#>  86: 3f092667-ae00-431f-88e3-683b019136a3 Optimization terminated          NA
#>  87: 0aee85aa-c49e-478e-a94c-90aa45eafdc3 Optimization terminated          NA
#>  88: 3a1e2fbd-5f60-45d7-a042-5d089e74b4f8 Optimization terminated          NA
#>  89: bfb09458-c530-4d81-99c8-f62b401eca99 Optimization terminated          NA
#>  90: 83150be0-3bfb-408f-973b-ca81fed4c219 Optimization terminated          NA
#>  91: ee4a9022-d60f-457b-abaf-6283a727c656 Optimization terminated          NA
#>  92: f8d80a6b-366c-4e97-afc0-35772abb6d3e Optimization terminated          NA
#>  93: 15071b77-63ca-41fd-ae21-034988c3eaa7 Optimization terminated          NA
#>  94: c99abeea-a878-406c-a083-8ccc90fc878b Optimization terminated          NA
#>  95: e90c7dd9-58c8-4e4e-9622-d5addc86b415 Optimization terminated          NA
#>  96: 0b38c0e6-bc9e-4fe5-852b-94ea6a4cb24b Optimization terminated          NA
#>  97: 7cec0214-9740-41b0-839c-d6021df98969 Optimization terminated          NA
#>  98: e23123f2-af7a-467e-9b48-488876437dbe Optimization terminated          NA
#>  99: d8fb3be2-9301-4ea9-817c-6c481e0cc404 Optimization terminated          NA
#> 100: aa0cc62e-5b1c-449f-b2af-b1786943b584 Optimization terminated          NA
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
