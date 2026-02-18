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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-18 10:57:49  8634
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-18 10:57:49  8634
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-18 10:57:49  8634
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-18 10:57:49  8634
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-18 10:57:49  8634
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-18 10:57:49  8634
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-18 10:57:49  8634
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-18 10:57:49  8634
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-18 10:57:49  8634
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-18 10:57:49  8634
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-18 10:57:49  8634
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-18 10:57:49  8634
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-18 10:57:49  8634
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-18 10:57:49  8634
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-18 10:57:49  8634
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-18 10:57:49  8634
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-18 10:57:49  8634
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-18 10:57:49  8634
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-18 10:57:49  8634
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-18 10:57:49  8634
#>  21:   failed  10.000000  5.0000000         NA 2026-02-18 10:57:49    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-18 10:57:49    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-18 10:57:49    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-18 10:57:49    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-18 10:57:49    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-18 10:57:49    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-18 10:57:49    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-18 10:57:49    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-18 10:57:49    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-18 10:57:49    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-18 10:57:49    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-18 10:57:49    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-18 10:57:49    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-18 10:57:49    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-18 10:57:49    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-18 10:57:49    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-18 10:57:49    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-18 10:57:49    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-18 10:57:49    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-18 10:57:49    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-18 10:57:49    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-18 10:57:49    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-18 10:57:49    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-18 10:57:49    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-18 10:57:49    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-18 10:57:49    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-18 10:57:49    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-18 10:57:49    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-18 10:57:49    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-18 10:57:49    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-18 10:57:49    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-18 10:57:49    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-18 10:57:49    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-18 10:57:49    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-18 10:57:49    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-18 10:57:49    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-18 10:57:49    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-18 10:57:49    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-18 10:57:49    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-18 10:57:49    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-18 10:57:49    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-18 10:57:49    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-18 10:57:49    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-18 10:57:49    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-18 10:57:49    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-18 10:57:49    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-18 10:57:49    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-18 10:57:50
#>   2: academical_guineapig 2026-02-18 10:57:50
#>   3: academical_guineapig 2026-02-18 10:57:50
#>   4: academical_guineapig 2026-02-18 10:57:50
#>   5: academical_guineapig 2026-02-18 10:57:50
#>   6: academical_guineapig 2026-02-18 10:57:50
#>   7: academical_guineapig 2026-02-18 10:57:50
#>   8: academical_guineapig 2026-02-18 10:57:50
#>   9: academical_guineapig 2026-02-18 10:57:50
#>  10: academical_guineapig 2026-02-18 10:57:50
#>  11: academical_guineapig 2026-02-18 10:57:50
#>  12: academical_guineapig 2026-02-18 10:57:50
#>  13: academical_guineapig 2026-02-18 10:57:50
#>  14: academical_guineapig 2026-02-18 10:57:50
#>  15: academical_guineapig 2026-02-18 10:57:50
#>  16: academical_guineapig 2026-02-18 10:57:50
#>  17: academical_guineapig 2026-02-18 10:57:50
#>  18: academical_guineapig 2026-02-18 10:57:50
#>  19: academical_guineapig 2026-02-18 10:57:50
#>  20: academical_guineapig 2026-02-18 10:57:50
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
#>   1: 82b4e938-be4b-4365-9839-e00fef217456                    <NA>  -10.000000
#>   2: 6dfcd916-7745-4833-9dd4-44543cc01c2b                    <NA>  -10.000000
#>   3: 9f8b405d-f741-498a-af25-f7c88184af43                    <NA>  -10.000000
#>   4: db9946b1-c4ed-4e4d-acd9-90713b3f608b                    <NA>  -10.000000
#>   5: 99f17b5f-334c-4e16-8d48-301b545f6f5f                    <NA>  -10.000000
#>   6: f711f52c-afeb-44a5-9fa1-da804f7a259b                    <NA>  -10.000000
#>   7: b519445b-c4d0-481d-b7fc-662b40272ce8                    <NA>  -10.000000
#>   8: e7e084ce-41d4-4a8e-82c2-d4f2ba12d45a                    <NA>  -10.000000
#>   9: 00b86401-8e9c-4785-bf33-a15d5750c94d                    <NA>  -10.000000
#>  10: 7aabf857-4651-410d-a477-69ef62e0e9a5                    <NA>  -10.000000
#>  11: 5a9cc3e1-0570-43cd-999f-54bf37fd3231                    <NA>   -7.777778
#>  12: 9e984172-453b-490e-aab0-51e978f74db4                    <NA>   -7.777778
#>  13: d66513da-5c6b-4e5d-aaed-53cf1aa17cd2                    <NA>   -7.777778
#>  14: a6f4ae33-76d3-4876-bd81-86b2a70be364                    <NA>   -7.777778
#>  15: 35d18ea5-3e24-40e6-9eff-8e9ba069b315                    <NA>   -7.777778
#>  16: 0dad933f-7af6-4fc0-8c4c-dc70d37d8889                    <NA>   -7.777778
#>  17: 0a7356e9-1204-4a6b-bc28-aa81e1cd8c5f                    <NA>   -7.777778
#>  18: b56eaed3-34cc-4336-b43f-5ef122b3f942                    <NA>   -7.777778
#>  19: 03e8847d-35e2-480f-81c8-515b97da3895                    <NA>   -7.777778
#>  20: b68b75ad-efc9-433a-96b7-dae77c5d5b34                    <NA>   -7.777778
#>  21: dedf5dbe-ea5b-4b54-ac68-ccc5b11698e2 Optimization terminated          NA
#>  22: c8773511-f9ca-4401-a89c-785defca303e Optimization terminated          NA
#>  23: 9bb65d2d-8c5a-40c6-b549-3ad981d66f1a Optimization terminated          NA
#>  24: d0e4cb15-0f1e-41c1-a60b-2a9d619e0824 Optimization terminated          NA
#>  25: 99ae68f2-d5f7-4871-b92d-c95e79ef3511 Optimization terminated          NA
#>  26: 8a0e9f0d-0112-48b9-973c-42bf37582219 Optimization terminated          NA
#>  27: e776d6ae-d265-4bc1-8c31-b1885008c454 Optimization terminated          NA
#>  28: 2cc79950-158f-442e-baa7-bc9b026eee40 Optimization terminated          NA
#>  29: cc548387-9891-4305-aa35-eca9255ea3fc Optimization terminated          NA
#>  30: be4c9f8e-e1d6-4c47-92d1-89b957a00034 Optimization terminated          NA
#>  31: a2a1a68d-f606-46cb-b10c-27adcbd3adbe Optimization terminated          NA
#>  32: 77cbb942-6206-48b3-9702-1ceecc26746c Optimization terminated          NA
#>  33: c062c1ff-2330-46d9-9882-63b425e63d4e Optimization terminated          NA
#>  34: 1145e4bc-6a51-4fdf-b896-1f5d7b3df5ac Optimization terminated          NA
#>  35: 573a26f1-026a-4d9f-bc0a-067de58360d8 Optimization terminated          NA
#>  36: 9006717c-75a8-4a1d-bb15-0e084ad71c15 Optimization terminated          NA
#>  37: 0b71f621-ba02-4111-bac6-064865955009 Optimization terminated          NA
#>  38: cf73e4a1-2e64-49e2-8bde-0889abfed64f Optimization terminated          NA
#>  39: 95c4b104-31f8-49c3-b852-ae26d74b55ca Optimization terminated          NA
#>  40: b0ddad26-6284-4afe-8a6a-1cd65645a576 Optimization terminated          NA
#>  41: 54dbbce8-c82b-405c-82dc-0b4692e10f6a Optimization terminated          NA
#>  42: 4a0e0fb1-92b8-44a4-bd30-f09a1ffebdf7 Optimization terminated          NA
#>  43: 78e3cc97-a6f8-44a1-9700-33059b0e6f98 Optimization terminated          NA
#>  44: 80129dde-d48c-43ec-9bdd-75c8d94a83b3 Optimization terminated          NA
#>  45: ef7c16fb-b25d-4e5b-9095-5114f5697759 Optimization terminated          NA
#>  46: a4324ffd-cbb1-4612-b45c-bc0ff28fcae2 Optimization terminated          NA
#>  47: 6611a8bb-2342-46a5-9524-4d10643b1a71 Optimization terminated          NA
#>  48: 48fe7966-b555-4c06-ac40-afac1a2555b2 Optimization terminated          NA
#>  49: 95ba8c1e-b4f9-4fec-a855-04a90ac5335c Optimization terminated          NA
#>  50: 36ff0f30-9335-4ff6-b088-165f15cb4382 Optimization terminated          NA
#>  51: f2179dec-cb63-411c-bd34-e8e8b34868c8 Optimization terminated          NA
#>  52: 9458208b-27a4-4e05-a668-cbe7d3260978 Optimization terminated          NA
#>  53: 19934046-bc49-4e28-b4bf-0b36f00cde4c Optimization terminated          NA
#>  54: 7412e221-b0f0-4b70-bdb8-ff11890b6e8d Optimization terminated          NA
#>  55: c4ed5ea0-fa78-4e93-9957-f3a90118d495 Optimization terminated          NA
#>  56: 1674cb33-e3c9-4c36-8ecf-6a039be6c42e Optimization terminated          NA
#>  57: 38b7d41c-9d49-47eb-82b7-f904e44c7fce Optimization terminated          NA
#>  58: 76d8ba82-fe5f-48e8-b720-da340c13b409 Optimization terminated          NA
#>  59: 22ddb4d7-f4d7-4b7f-9995-79e8c56725c7 Optimization terminated          NA
#>  60: 272dc11b-f556-49f1-9854-4b5047c4a0dc Optimization terminated          NA
#>  61: 09576583-596b-486d-86ea-4f7a6cc447fb Optimization terminated          NA
#>  62: 969f7530-6cef-4a95-9e5b-df7b25c375d2 Optimization terminated          NA
#>  63: be025ea6-a807-4ed4-8e6a-97c39b04ba3a Optimization terminated          NA
#>  64: 418f7bb9-382d-4fe9-83fa-cdbd2cdfb12f Optimization terminated          NA
#>  65: ecbbe0bc-dd42-401b-885d-8092117e3ac7 Optimization terminated          NA
#>  66: f507e915-03ce-4bb2-8b09-a641c21cecbb Optimization terminated          NA
#>  67: 059207f8-0d7b-408b-885c-1dfb4c8fcab9 Optimization terminated          NA
#>  68: 4057f11e-8e13-4c57-9a67-5b20ce272cc0 Optimization terminated          NA
#>  69: f228e76f-4cba-485d-90ce-49b1ccc85924 Optimization terminated          NA
#>  70: 08c1ee53-5e6d-42b0-9642-d8cc054c1bfd Optimization terminated          NA
#>  71: 32375ab3-aefd-491a-8aa0-6d108f35de6e Optimization terminated          NA
#>  72: 11ffe2f4-0059-47c9-996e-8eb91895fe55 Optimization terminated          NA
#>  73: 590b8b43-5408-4cbf-b6ae-0c2c90736873 Optimization terminated          NA
#>  74: 3088bb33-b4de-4ede-839f-e32816676c23 Optimization terminated          NA
#>  75: 2367a8b4-f8bd-41b2-a564-7b665df463bf Optimization terminated          NA
#>  76: 6d012b11-6909-4b65-afa9-2b791d7df179 Optimization terminated          NA
#>  77: 9eea667f-b71c-4964-92ad-a9aae0c77004 Optimization terminated          NA
#>  78: b8cbad90-97fe-4e39-8607-92279b483456 Optimization terminated          NA
#>  79: 21be3b81-1ca7-41e2-8181-a2f540cdace0 Optimization terminated          NA
#>  80: 1cba9e0b-1e14-4fe7-abeb-2339f9342758 Optimization terminated          NA
#>  81: 37710f89-2e65-4173-a374-cc84f30a3a8a Optimization terminated          NA
#>  82: a4323f3f-8294-49b3-a50a-c946e9e5d719 Optimization terminated          NA
#>  83: c7d4a795-9b4f-401d-a93c-c528fa5ff8b1 Optimization terminated          NA
#>  84: 51f82047-feff-4ce4-946e-1684555bd2d4 Optimization terminated          NA
#>  85: 5cac3a73-f0ac-4790-8732-355a8b55a80a Optimization terminated          NA
#>  86: 39c2243e-9267-4bfb-8b4d-ad0a4ba78cef Optimization terminated          NA
#>  87: bd6c47a2-8bcc-445f-a745-f0e9ed7d0b70 Optimization terminated          NA
#>  88: f8073bdc-e711-46c0-893d-90dc76010a82 Optimization terminated          NA
#>  89: d2aa5f01-b1bf-4a54-94a5-4563ed1d306e Optimization terminated          NA
#>  90: 26c17809-f65b-423b-b4d6-bcc59b4ad44e Optimization terminated          NA
#>  91: 218fdf4b-5ca4-46fd-b4cc-86402a35c4d7 Optimization terminated          NA
#>  92: 7ccedc83-1d38-4148-bb11-0a6c81cea8ff Optimization terminated          NA
#>  93: 84c198be-da63-4cdd-b54a-58044fb8995a Optimization terminated          NA
#>  94: f9cc8509-a221-4b3a-8f0f-5d56a6ec2ab0 Optimization terminated          NA
#>  95: 29c6f4c0-88fe-428f-adcb-f7bce8177a23 Optimization terminated          NA
#>  96: e9438a13-fe74-4273-9644-82b77c80f599 Optimization terminated          NA
#>  97: 228c26b0-554c-4ba5-b533-58d5e8c2f2af Optimization terminated          NA
#>  98: a8ea3e8c-2efe-4246-b311-1b307a220ad0 Optimization terminated          NA
#>  99: 5fbdaa82-6251-4dcc-b8ac-7f9ab938caae Optimization terminated          NA
#> 100: c5231d76-5bd4-47f2-bbc6-3b5d8ce2a71c Optimization terminated          NA
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
