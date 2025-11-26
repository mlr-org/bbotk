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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-26 11:07:15  8240
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-26 11:07:15  8240
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-26 11:07:15  8240
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-26 11:07:15  8240
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-26 11:07:15  8240
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-26 11:07:15  8240
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-26 11:07:15  8240
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-26 11:07:15  8240
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-26 11:07:15  8240
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-26 11:07:15  8240
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-26 11:07:15  8240
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-26 11:07:15  8240
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-26 11:07:15  8240
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-26 11:07:15  8240
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-26 11:07:15  8240
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-26 11:07:15  8240
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-26 11:07:15  8240
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-26 11:07:15  8240
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-26 11:07:15  8240
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-26 11:07:15  8240
#>  21:   failed  10.000000  5.0000000         NA 2025-11-26 11:07:15    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-26 11:07:15    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-26 11:07:15    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-26 11:07:15    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-26 11:07:15    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-26 11:07:15    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-26 11:07:15    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-26 11:07:15    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-26 11:07:15    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-26 11:07:15    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-26 11:07:15    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-26 11:07:15    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-26 11:07:15    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-26 11:07:15    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-26 11:07:15    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-26 11:07:15    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-26 11:07:15    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-26 11:07:15    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-26 11:07:15    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-26 11:07:15    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-26 11:07:15    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-26 11:07:15    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-26 11:07:15    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-26 11:07:15    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-26 11:07:15    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-26 11:07:15    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-26 11:07:15    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-26 11:07:15    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-26 11:07:15    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-26 11:07:15    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-26 11:07:15    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-26 11:07:15    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-26 11:07:15    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-26 11:07:15    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-26 11:07:15    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-26 11:07:15    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-26 11:07:15    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-26 11:07:15    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-26 11:07:15    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-26 11:07:15    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-26 11:07:15    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-26 11:07:15    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-26 11:07:15    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-26 11:07:15    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-26 11:07:15    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-26 11:07:15    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-26 11:07:15    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-26 11:07:15
#>   2: academical_guineapig 2025-11-26 11:07:15
#>   3: academical_guineapig 2025-11-26 11:07:15
#>   4: academical_guineapig 2025-11-26 11:07:15
#>   5: academical_guineapig 2025-11-26 11:07:15
#>   6: academical_guineapig 2025-11-26 11:07:15
#>   7: academical_guineapig 2025-11-26 11:07:15
#>   8: academical_guineapig 2025-11-26 11:07:15
#>   9: academical_guineapig 2025-11-26 11:07:15
#>  10: academical_guineapig 2025-11-26 11:07:15
#>  11: academical_guineapig 2025-11-26 11:07:15
#>  12: academical_guineapig 2025-11-26 11:07:15
#>  13: academical_guineapig 2025-11-26 11:07:15
#>  14: academical_guineapig 2025-11-26 11:07:15
#>  15: academical_guineapig 2025-11-26 11:07:15
#>  16: academical_guineapig 2025-11-26 11:07:15
#>  17: academical_guineapig 2025-11-26 11:07:15
#>  18: academical_guineapig 2025-11-26 11:07:15
#>  19: academical_guineapig 2025-11-26 11:07:15
#>  20: academical_guineapig 2025-11-26 11:07:15
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
#>   1: ac805816-fddd-446d-95d9-317100839bf6                    <NA>  -10.000000
#>   2: f7549e15-8314-4ae4-9a22-27d101c6c87b                    <NA>  -10.000000
#>   3: 81b5fd47-626a-41b1-b17e-52793fecec11                    <NA>  -10.000000
#>   4: 93c9cbb4-4ba4-4c64-abab-b9c5a6fe7ef6                    <NA>  -10.000000
#>   5: cdeb7f0e-8b81-42e9-a0cc-4cb842cf70b3                    <NA>  -10.000000
#>   6: 74e3ca04-75b1-4e79-a10f-47406e007646                    <NA>  -10.000000
#>   7: 00c36bf7-19db-452c-95be-5aab592d6999                    <NA>  -10.000000
#>   8: 04b4937a-0fe8-49bc-878d-7ae8e52af969                    <NA>  -10.000000
#>   9: 1506a11c-3448-486e-adeb-8e329bf93f51                    <NA>  -10.000000
#>  10: 68fc28d4-edb6-4f63-b92f-9c2dce1f4a7d                    <NA>  -10.000000
#>  11: e835fe0b-2920-4f95-91b0-a21df6cbe4a9                    <NA>   -7.777778
#>  12: b561b7ea-df8d-4413-93d5-966810760e10                    <NA>   -7.777778
#>  13: ffe01471-f61f-4916-bdca-7224da814f13                    <NA>   -7.777778
#>  14: dd28b7c9-e03e-43e1-8935-82d4cf6abc16                    <NA>   -7.777778
#>  15: d3a3bad5-3430-4bfa-bc9c-b029844c7aee                    <NA>   -7.777778
#>  16: 9c4fb1cc-bdc5-4035-9dfb-da1b2607ddd4                    <NA>   -7.777778
#>  17: d1b89348-34da-4c27-81e2-c541d4f79ab5                    <NA>   -7.777778
#>  18: 895da7d0-87a9-496c-abbd-deb3fc348cec                    <NA>   -7.777778
#>  19: 11c6041b-3463-4da5-a208-63e3e0f6e72e                    <NA>   -7.777778
#>  20: 729f6371-359c-441e-86d0-2727fc11034f                    <NA>   -7.777778
#>  21: de639ebc-f960-4a41-a5b7-5c5b3c69e883 Optimization terminated          NA
#>  22: b6bc14b8-727e-4d26-bb64-0f12d1b91aaf Optimization terminated          NA
#>  23: ce1c9ced-2de7-45e2-8f6c-6833102e8676 Optimization terminated          NA
#>  24: 15380bb7-e640-4def-92c0-e4c78958fcbf Optimization terminated          NA
#>  25: 6c3d8331-33cc-4490-b5dc-aaabdce05378 Optimization terminated          NA
#>  26: 8e74c2e8-1107-4965-979d-c630cf112fef Optimization terminated          NA
#>  27: e7f0346b-2e50-44e5-98f0-1b3af7e666dd Optimization terminated          NA
#>  28: 41ca641e-0cac-4846-9ef8-12fa66cee96c Optimization terminated          NA
#>  29: 683c223d-0acc-4877-9e80-ad716c661b98 Optimization terminated          NA
#>  30: 545d568a-e89d-449e-a4a3-a6454dee6ec0 Optimization terminated          NA
#>  31: 655b9163-c956-4201-8985-17768fe7e9b9 Optimization terminated          NA
#>  32: e491ce35-1869-43a5-9e62-7e0445290e8b Optimization terminated          NA
#>  33: 5596cf50-8fdf-43cc-a9e2-b9bef2ff4053 Optimization terminated          NA
#>  34: 03bca462-a8c7-4379-880a-4037971b3ca6 Optimization terminated          NA
#>  35: c76d9e03-cccc-4b0a-8d99-7e70fb58d315 Optimization terminated          NA
#>  36: 92ef8bd7-4395-43cc-9a71-66aae0ba3d67 Optimization terminated          NA
#>  37: 2e42ffb3-2a94-4b3b-b2aa-4b70b5b7617d Optimization terminated          NA
#>  38: 2694173a-1039-45cd-8540-cbe149b69c17 Optimization terminated          NA
#>  39: 522232ff-4cec-4c36-8fb9-a8b1d6484c94 Optimization terminated          NA
#>  40: df8fa897-9f8e-4860-a0f7-a59707978dfa Optimization terminated          NA
#>  41: 78d88068-7430-4927-b76f-f86c61bbf4ba Optimization terminated          NA
#>  42: 5b2dfea3-c3fa-45df-a8f4-59e8d5e2b670 Optimization terminated          NA
#>  43: 4b0717b0-afd3-4a83-9c48-2e4a6bd86488 Optimization terminated          NA
#>  44: d6f25cd2-aaf7-4520-a056-dba442097040 Optimization terminated          NA
#>  45: 4f78ce80-5ef8-4953-a22a-a6f02e1a679e Optimization terminated          NA
#>  46: 45ab6c0f-4afc-43b5-a5e7-0dd0adb33bb5 Optimization terminated          NA
#>  47: 8c5f72ed-43ca-4f92-84a1-855fb9a11d18 Optimization terminated          NA
#>  48: 415bd6ac-da00-4280-9472-0b1e01d8f5a0 Optimization terminated          NA
#>  49: f514e6b1-8837-4d71-a4d7-594cc0e8c16f Optimization terminated          NA
#>  50: 940f96bf-84ef-48a8-bace-8e4148ca4f65 Optimization terminated          NA
#>  51: 6d6bdd6a-eb4a-47ac-8a52-f69ac5480516 Optimization terminated          NA
#>  52: f210ab1b-44c0-4e37-947a-b4448b110fc0 Optimization terminated          NA
#>  53: 2219f9c3-7997-43a1-a903-ea80795d0b75 Optimization terminated          NA
#>  54: 22220a60-8a9f-4460-b976-92033570d099 Optimization terminated          NA
#>  55: 0bb184b1-9b6e-478d-b71c-8cbb9706f6fc Optimization terminated          NA
#>  56: 25eebb0a-dca6-4790-b2a5-d8c5ed3b0ce5 Optimization terminated          NA
#>  57: 8853bcda-e3ef-4626-b5bd-f591218a1b8b Optimization terminated          NA
#>  58: 172592f2-f634-4a76-8878-037872fe9724 Optimization terminated          NA
#>  59: 67b2bbe3-861a-4f43-8d17-4fae8e6358e6 Optimization terminated          NA
#>  60: 401adca2-cc6f-49c4-8ce0-268053b170d1 Optimization terminated          NA
#>  61: 4771bc7a-be93-42cf-8dcb-f48d5e674966 Optimization terminated          NA
#>  62: ebb4301d-e52d-49df-8ebc-b9d150fe777b Optimization terminated          NA
#>  63: 08af9701-2f15-4493-82ea-e60e9e9e87b7 Optimization terminated          NA
#>  64: b7e9cbcb-b356-455b-9855-592103f0b1f0 Optimization terminated          NA
#>  65: d706d19c-4f7d-422f-b30c-15782df59e11 Optimization terminated          NA
#>  66: 1ee0ecf7-acbb-4c01-a506-543d5226cccd Optimization terminated          NA
#>  67: d0082af6-367a-40e2-be94-c5ab251dad7d Optimization terminated          NA
#>  68: e32fbefe-a271-4b76-9147-acebcbeca7c9 Optimization terminated          NA
#>  69: 95470c9b-18a9-4414-9d81-e4a64f4d962a Optimization terminated          NA
#>  70: 1bcfdf8b-f359-4964-be89-386eb08e8fb6 Optimization terminated          NA
#>  71: 8bddfc51-fe34-4e6c-b37a-aa2a90fa7ae0 Optimization terminated          NA
#>  72: e057f2fa-3ed2-4f04-82c4-d588d64b3f09 Optimization terminated          NA
#>  73: 2841872f-a3d7-427e-b5ec-682fc89b1f64 Optimization terminated          NA
#>  74: 519d94c3-2e61-40fd-8358-c1d160e21c52 Optimization terminated          NA
#>  75: 7ab52524-64e7-4fbf-a67d-f3df1f4cab43 Optimization terminated          NA
#>  76: 945d60b3-66ca-4663-a1e7-dd375ddd425a Optimization terminated          NA
#>  77: 5b185997-50de-4d1c-9ab7-3b61294c28e2 Optimization terminated          NA
#>  78: f7516f72-69d2-435d-ab71-2e5308e44483 Optimization terminated          NA
#>  79: 28d67b54-986c-47d6-a79b-d456c98f9e80 Optimization terminated          NA
#>  80: ff898866-d23c-48ef-b84b-8653e8c4f36b Optimization terminated          NA
#>  81: c2f8babf-2aac-410f-a30a-61aea50af1a5 Optimization terminated          NA
#>  82: f51b50a4-dfdb-4c9a-adc1-f27f10167212 Optimization terminated          NA
#>  83: 97463ca0-1bf2-46bd-800f-cd3638a6eb8e Optimization terminated          NA
#>  84: 8897da24-6b36-468f-a758-dc2ae5cc1e04 Optimization terminated          NA
#>  85: d0ca7a64-c382-408c-a8d8-3fb48ee12f23 Optimization terminated          NA
#>  86: 2fd794e5-33c3-4405-bc33-daf7a59cea9f Optimization terminated          NA
#>  87: aecaae9a-8b28-490b-97bc-9fe4812490e0 Optimization terminated          NA
#>  88: 74e2c092-cbbb-43d4-b6bf-8ab67f9025dc Optimization terminated          NA
#>  89: 1dca149d-1f21-4d02-ad26-7f35bfacc552 Optimization terminated          NA
#>  90: 91d6c9c8-3563-4041-a64f-21454b20a4ac Optimization terminated          NA
#>  91: c0489c50-8f02-466e-91f0-28e0487d39e7 Optimization terminated          NA
#>  92: 8904cfb7-28e8-4207-969f-cb17434290e0 Optimization terminated          NA
#>  93: 8bdb6fa2-ab49-4c0c-96a6-ac631d85d172 Optimization terminated          NA
#>  94: 989b3268-978e-4b7a-843a-2d62af0c1727 Optimization terminated          NA
#>  95: 90e2943e-04eb-4201-94fa-102e9357537d Optimization terminated          NA
#>  96: 4d0644db-64bf-4102-b6d6-25dcfda21425 Optimization terminated          NA
#>  97: 6ee325f2-eb91-49f1-8dcd-42d476ff1cd4 Optimization terminated          NA
#>  98: f0a20d08-c6c2-40e8-95d7-243e43253e3b Optimization terminated          NA
#>  99: 8b2f3f67-6873-412a-bdbc-f8626f223cfd Optimization terminated          NA
#> 100: 137a7ef6-f22b-443a-b244-2a3ca644a7c1 Optimization terminated          NA
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
