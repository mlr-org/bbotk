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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-05 09:12:09  8789
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-05 09:12:09  8789
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-05 09:12:09  8789
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-05 09:12:09  8789
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-05 09:12:09  8789
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-05 09:12:09  8789
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-05 09:12:09  8789
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-05 09:12:09  8789
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-05 09:12:09  8789
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-05 09:12:09  8789
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-05 09:12:09  8789
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-05 09:12:09  8789
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-05 09:12:09  8789
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-05 09:12:09  8789
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-05 09:12:09  8789
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-05 09:12:09  8789
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-05 09:12:09  8789
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-05 09:12:09  8789
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-05 09:12:09  8789
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-05 09:12:09  8789
#>  21:   failed  10.000000  5.0000000         NA 2026-03-05 09:12:09    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-03-05 09:12:09    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-03-05 09:12:09    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-03-05 09:12:09    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-03-05 09:12:09    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-03-05 09:12:09    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-03-05 09:12:09    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-03-05 09:12:09    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-03-05 09:12:09    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-03-05 09:12:09    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-03-05 09:12:09    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-03-05 09:12:09    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-03-05 09:12:09    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-03-05 09:12:09    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-03-05 09:12:09    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-03-05 09:12:09    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-03-05 09:12:09    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-03-05 09:12:09    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-03-05 09:12:09    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-03-05 09:12:09    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-03-05 09:12:09    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-03-05 09:12:09    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-03-05 09:12:09    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-03-05 09:12:09    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-03-05 09:12:09    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-05 09:12:09    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-05 09:12:09    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-05 09:12:09    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-05 09:12:09    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-05 09:12:09    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-05 09:12:09    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-05 09:12:09    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-05 09:12:09    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-05 09:12:09    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-05 09:12:09    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-05 09:12:09    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-05 09:12:09    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-05 09:12:09    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-05 09:12:09    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-05 09:12:09    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-05 09:12:09    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-05 09:12:09    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-05 09:12:09    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-05 09:12:09    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-05 09:12:09    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-05 09:12:09    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-05 09:12:09    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-03-05 09:12:10
#>   2: academical_guineapig 2026-03-05 09:12:10
#>   3: academical_guineapig 2026-03-05 09:12:10
#>   4: academical_guineapig 2026-03-05 09:12:10
#>   5: academical_guineapig 2026-03-05 09:12:10
#>   6: academical_guineapig 2026-03-05 09:12:10
#>   7: academical_guineapig 2026-03-05 09:12:10
#>   8: academical_guineapig 2026-03-05 09:12:10
#>   9: academical_guineapig 2026-03-05 09:12:10
#>  10: academical_guineapig 2026-03-05 09:12:10
#>  11: academical_guineapig 2026-03-05 09:12:10
#>  12: academical_guineapig 2026-03-05 09:12:10
#>  13: academical_guineapig 2026-03-05 09:12:10
#>  14: academical_guineapig 2026-03-05 09:12:10
#>  15: academical_guineapig 2026-03-05 09:12:10
#>  16: academical_guineapig 2026-03-05 09:12:10
#>  17: academical_guineapig 2026-03-05 09:12:10
#>  18: academical_guineapig 2026-03-05 09:12:10
#>  19: academical_guineapig 2026-03-05 09:12:10
#>  20: academical_guineapig 2026-03-05 09:12:10
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
#>   1: 99767959-1df3-4595-b269-6b779f097468                    <NA>  -10.000000
#>   2: f59e9de3-fb9e-496f-81c0-7f946100f968                    <NA>  -10.000000
#>   3: 19528c57-545e-41a2-b634-879a74b79737                    <NA>  -10.000000
#>   4: 5c68eb29-8552-4b0f-b57f-ed741b5f9430                    <NA>  -10.000000
#>   5: e4a747ee-7f31-4ba7-be42-bafd0196e744                    <NA>  -10.000000
#>   6: 46e97eda-92d8-4c58-80e9-56e6c3ce7981                    <NA>  -10.000000
#>   7: 3efb05f3-c410-4ef2-b04e-c96f03adbc13                    <NA>  -10.000000
#>   8: e7f5b7db-7b91-4dcf-b739-5ba48870168e                    <NA>  -10.000000
#>   9: 1cb3e135-ca6e-4c12-85d1-78c44365d6be                    <NA>  -10.000000
#>  10: 23fcf8d7-d7e4-404f-875a-b853c723c1b8                    <NA>  -10.000000
#>  11: 59b5df8e-123b-4aec-9d61-957685f111b7                    <NA>   -7.777778
#>  12: 18e6a9c4-db88-4cb0-9c77-a9ea4df5838a                    <NA>   -7.777778
#>  13: cf935c1a-0146-4dee-8c68-8593c2a220a9                    <NA>   -7.777778
#>  14: ac8633f8-debf-46a1-954c-7884250c39b7                    <NA>   -7.777778
#>  15: 71c0fbcc-269c-4c4e-a5f3-a60b75969822                    <NA>   -7.777778
#>  16: e234493e-fff0-48df-a85b-2b6a2f610ddd                    <NA>   -7.777778
#>  17: 3445eb48-b360-43ca-9a05-634793fb0210                    <NA>   -7.777778
#>  18: e1afbe85-c639-4a99-bd59-dad6cf805815                    <NA>   -7.777778
#>  19: 090315c8-7510-4846-94d5-aaa7719d0f9f                    <NA>   -7.777778
#>  20: 30946afc-fca7-4f22-9bbe-b1fce3b3b4a4                    <NA>   -7.777778
#>  21: 04a2911b-2edf-497f-8763-604ce79f18af Optimization terminated          NA
#>  22: b67f1cf5-adf3-4e54-bcc8-d7c9482fcd09 Optimization terminated          NA
#>  23: 6f5bf7e5-371b-4653-8d91-f77d06605db3 Optimization terminated          NA
#>  24: 04d08602-8c8e-4c8d-b92f-416661667c5a Optimization terminated          NA
#>  25: a35f55af-5613-4246-a24a-965a7bca4739 Optimization terminated          NA
#>  26: 1c25f759-5a89-4491-b6b3-637ce1f64d49 Optimization terminated          NA
#>  27: 1ffe4cbe-1d4d-43e2-bfca-9c068813ff55 Optimization terminated          NA
#>  28: e58fd49d-6f37-4ec6-a6b3-cba4a8b649cf Optimization terminated          NA
#>  29: 8c8c5449-a421-43aa-9f39-1827c675eb4b Optimization terminated          NA
#>  30: 41e11c03-aeed-46c3-a69d-6fed41e87c49 Optimization terminated          NA
#>  31: b6594c9c-20f3-4312-ad0d-292571bb5b82 Optimization terminated          NA
#>  32: b2c812c7-56cb-42fd-8402-f63435534b13 Optimization terminated          NA
#>  33: b0b6cfa0-dc8d-487a-9899-75d1b46d7d0a Optimization terminated          NA
#>  34: c745dddc-499e-42c9-a06c-80b9189c229f Optimization terminated          NA
#>  35: e7a641a9-5df7-48d1-863b-b7567a02171f Optimization terminated          NA
#>  36: db527497-91e7-41b5-b7fb-1f1a9764d84c Optimization terminated          NA
#>  37: d2359790-ccfb-4d88-a0b6-64f54c34be88 Optimization terminated          NA
#>  38: 321d4736-bd5f-4007-a267-76d750975cf7 Optimization terminated          NA
#>  39: 4e875bf7-6850-45e1-9b40-5f7f7fdeff63 Optimization terminated          NA
#>  40: 9cd0fc18-b138-460b-bd5b-0131aa0fb33f Optimization terminated          NA
#>  41: 9817932c-2045-4195-a7b2-c9cf4b2847c9 Optimization terminated          NA
#>  42: c9b121ed-8666-4e1f-b30e-d6871c0bd7ab Optimization terminated          NA
#>  43: 401db73a-6a29-4c5e-bf51-354f397b21af Optimization terminated          NA
#>  44: e8cef334-b7a2-4b2c-9a90-6179713f75f6 Optimization terminated          NA
#>  45: 04ba1f58-354e-49d6-8738-0e1b6976fbd7 Optimization terminated          NA
#>  46: f7ee41f4-b91e-4565-9701-9c377858bb42 Optimization terminated          NA
#>  47: 724d2a6a-fc42-4e65-90e9-5fc3e2b0f32b Optimization terminated          NA
#>  48: e4206c91-27f5-4b9a-bf87-f697bc783d30 Optimization terminated          NA
#>  49: 2335ec35-5dd8-4579-af10-147c8532e955 Optimization terminated          NA
#>  50: ad38a83b-2c5b-41ed-8916-981ba199fb84 Optimization terminated          NA
#>  51: 3100c03b-60b6-407f-b37f-5841d7b8e2d6 Optimization terminated          NA
#>  52: c0a9cbc2-33c3-48e8-b4a6-c337035d55c8 Optimization terminated          NA
#>  53: 80d34180-0d2b-49a8-b9b4-a8f7dee9ec3a Optimization terminated          NA
#>  54: 9a4e915d-60db-42cf-960c-c49af4c5031b Optimization terminated          NA
#>  55: b9c27131-e7bb-424f-a4ce-f16e468262a1 Optimization terminated          NA
#>  56: b29f49a4-cf82-43b8-b3ba-40fcdab7ecab Optimization terminated          NA
#>  57: 50e3e467-ed05-4d82-b828-2548e048c76d Optimization terminated          NA
#>  58: 6ce04ed2-0a13-47c1-bdc6-ec0c3f15eaf0 Optimization terminated          NA
#>  59: e09d73db-c9e6-46cf-add5-84f81f3d3a9b Optimization terminated          NA
#>  60: 25eb45e7-357f-4d47-9c24-7aac6884fa52 Optimization terminated          NA
#>  61: be666b7c-ea05-43bc-8d00-77df8a1aa2eb Optimization terminated          NA
#>  62: 3817807d-9ced-417a-b0fb-187376ebe05a Optimization terminated          NA
#>  63: 5cee80b8-e7e0-43db-88d2-8a3ea3d165d4 Optimization terminated          NA
#>  64: ac60d7e1-45cb-409e-950a-5fa63ed7ad2c Optimization terminated          NA
#>  65: 3016fe36-bac1-4105-a33a-db17f1943c04 Optimization terminated          NA
#>  66: f917b63f-d04c-46ab-88e9-7e2020a79a90 Optimization terminated          NA
#>  67: 23922090-6f45-4aa6-9029-4426ee171daa Optimization terminated          NA
#>  68: 14e4017c-3e1c-465e-98c0-93becd8dae23 Optimization terminated          NA
#>  69: 8c0a6444-beb7-4f62-9220-abbde7185ddb Optimization terminated          NA
#>  70: f46265f0-dc02-44e3-9d85-fd21932a3edb Optimization terminated          NA
#>  71: bc8d3d49-33d2-40b4-bb02-501de9898b53 Optimization terminated          NA
#>  72: cfd67921-bd93-468e-93a6-61a3abb39bcb Optimization terminated          NA
#>  73: cb2280a7-e1da-405e-bb33-ff75032800ae Optimization terminated          NA
#>  74: 36587020-1137-4308-a53f-d22961338887 Optimization terminated          NA
#>  75: f2ef37d0-9ef3-4e01-ba14-a4cac0f372cb Optimization terminated          NA
#>  76: fadb0311-95a5-423c-9132-be0e7a94b8a2 Optimization terminated          NA
#>  77: 05ecee99-8a7f-4c71-971e-0f5f806fae07 Optimization terminated          NA
#>  78: c6ce4de0-5a7a-4b21-bd04-70a66a81f33e Optimization terminated          NA
#>  79: 37ae1a2a-05fc-47c4-be75-aedc106ab41c Optimization terminated          NA
#>  80: 03d69238-a033-48e0-8e9d-78da68e07989 Optimization terminated          NA
#>  81: b597b9e9-edea-4959-a9cd-42abf277b943 Optimization terminated          NA
#>  82: 1d26163a-9baa-4a80-b960-84cef876d4bb Optimization terminated          NA
#>  83: d3712868-c01d-48c8-b085-7f9156bff64b Optimization terminated          NA
#>  84: 53ada5cc-2612-411c-abc3-92efd2554508 Optimization terminated          NA
#>  85: 04d1d426-6d4f-4cc7-8a09-5e5ed014a4de Optimization terminated          NA
#>  86: 173cce97-f611-4d43-9169-f4472951344f Optimization terminated          NA
#>  87: 3fa61831-f622-4fbf-9110-17f8a5ff338c Optimization terminated          NA
#>  88: 8d360a2d-099a-4749-a0fc-d6346b4188b4 Optimization terminated          NA
#>  89: 78910df3-d6fe-4009-8e8c-1fe5cb9c9a48 Optimization terminated          NA
#>  90: 9cb5f593-8891-4778-a4ac-3833587c89dd Optimization terminated          NA
#>  91: 0fe18bd5-dbb0-48bd-90cf-2c61d92383b9 Optimization terminated          NA
#>  92: eb200205-b22a-4eec-a076-67c0f7966891 Optimization terminated          NA
#>  93: 92a11715-ed71-4375-a2b3-bca90b77d74b Optimization terminated          NA
#>  94: 2505d108-c225-4b4e-b87a-ce5323d9f2ab Optimization terminated          NA
#>  95: a1604e52-d92e-4219-96fc-940d2f3e7871 Optimization terminated          NA
#>  96: 521cc7c1-6468-4cf4-ae90-06c2aad1ef8b Optimization terminated          NA
#>  97: 1c191d86-dd36-444d-84fa-2472442fe9a4 Optimization terminated          NA
#>  98: e4901db4-4ff2-49fd-9e9e-dc89fe46fb86 Optimization terminated          NA
#>  99: a14e823e-7636-4bb0-aa99-cb7a7b32827b Optimization terminated          NA
#> 100: 7de54282-b083-40ae-9e69-dde1476d74ca Optimization terminated          NA
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
