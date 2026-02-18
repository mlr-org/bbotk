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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-18 13:47:21  8645
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-18 13:47:21  8645
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-18 13:47:21  8645
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-18 13:47:21  8645
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-18 13:47:21  8645
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-18 13:47:21  8645
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-18 13:47:21  8645
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-18 13:47:21  8645
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-18 13:47:21  8645
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-18 13:47:21  8645
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-18 13:47:21  8645
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-18 13:47:21  8645
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-18 13:47:21  8645
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-18 13:47:21  8645
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-18 13:47:21  8645
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-18 13:47:21  8645
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-18 13:47:21  8645
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-18 13:47:21  8645
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-18 13:47:21  8645
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-18 13:47:21  8645
#>  21:   failed  10.000000  5.0000000         NA 2026-02-18 13:47:21    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-18 13:47:21    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-18 13:47:21    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-18 13:47:21    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-18 13:47:21    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-18 13:47:21    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-18 13:47:21    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-18 13:47:21    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-18 13:47:21    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-18 13:47:21    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-18 13:47:21    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-18 13:47:21    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-18 13:47:21    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-18 13:47:21    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-18 13:47:21    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-18 13:47:21    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-18 13:47:21    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-18 13:47:21    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-18 13:47:21    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-18 13:47:21    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-18 13:47:21    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-18 13:47:21    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-18 13:47:21    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-18 13:47:21    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-18 13:47:21    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-18 13:47:21    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-18 13:47:21    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-18 13:47:21    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-18 13:47:21    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-18 13:47:21    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-18 13:47:21    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-18 13:47:21    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-18 13:47:21    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-18 13:47:21    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-18 13:47:21    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-18 13:47:21    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-18 13:47:21    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-18 13:47:21    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-18 13:47:21    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-18 13:47:21    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-18 13:47:21    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-18 13:47:21    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-18 13:47:21    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-18 13:47:21    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-18 13:47:21    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-18 13:47:21    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-18 13:47:21    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-18 13:47:22
#>   2: academical_guineapig 2026-02-18 13:47:22
#>   3: academical_guineapig 2026-02-18 13:47:22
#>   4: academical_guineapig 2026-02-18 13:47:22
#>   5: academical_guineapig 2026-02-18 13:47:22
#>   6: academical_guineapig 2026-02-18 13:47:22
#>   7: academical_guineapig 2026-02-18 13:47:22
#>   8: academical_guineapig 2026-02-18 13:47:22
#>   9: academical_guineapig 2026-02-18 13:47:22
#>  10: academical_guineapig 2026-02-18 13:47:22
#>  11: academical_guineapig 2026-02-18 13:47:22
#>  12: academical_guineapig 2026-02-18 13:47:22
#>  13: academical_guineapig 2026-02-18 13:47:22
#>  14: academical_guineapig 2026-02-18 13:47:22
#>  15: academical_guineapig 2026-02-18 13:47:22
#>  16: academical_guineapig 2026-02-18 13:47:22
#>  17: academical_guineapig 2026-02-18 13:47:22
#>  18: academical_guineapig 2026-02-18 13:47:22
#>  19: academical_guineapig 2026-02-18 13:47:22
#>  20: academical_guineapig 2026-02-18 13:47:22
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
#>   1: 0c0382f3-b534-4536-8e43-de3e7e4dbca0                    <NA>  -10.000000
#>   2: 255943fa-847a-4875-a997-8a0189f34c09                    <NA>  -10.000000
#>   3: dfb4bcc2-762a-499e-a2d8-13745b9c277b                    <NA>  -10.000000
#>   4: ccf5f4b5-d8ec-412e-9c0f-d173eee392da                    <NA>  -10.000000
#>   5: f9f723f4-a682-4bbb-b188-5c90be9c731d                    <NA>  -10.000000
#>   6: 604b2145-b679-484d-ad09-d964fbaccc4e                    <NA>  -10.000000
#>   7: 3194b393-1550-4f2d-829c-c6d57574f9ad                    <NA>  -10.000000
#>   8: 316e8ddb-2e2a-4318-a69c-c6a5f1f00b4e                    <NA>  -10.000000
#>   9: 96e9fa9e-051b-4490-a495-7cd4977e4f51                    <NA>  -10.000000
#>  10: e0205703-5532-48fc-83fe-e8d1e85ee438                    <NA>  -10.000000
#>  11: 81fd676c-9e4a-4abb-9ec5-ab3fea46e76c                    <NA>   -7.777778
#>  12: 5fe9a21a-cd84-4719-8ca9-cbebde17d29a                    <NA>   -7.777778
#>  13: 17407685-2729-4913-a6a3-135cc73b6f71                    <NA>   -7.777778
#>  14: ea9ff99f-534e-4cda-b6be-0f3b90c1f583                    <NA>   -7.777778
#>  15: 2e214ec9-8f68-4803-8954-fa323322b29d                    <NA>   -7.777778
#>  16: c449d825-6160-47a8-8714-de608efc21cd                    <NA>   -7.777778
#>  17: f0d90390-bf23-4ab8-817d-a94cfdbe9fa9                    <NA>   -7.777778
#>  18: 6b5fbfd8-95af-4d60-927d-92fcec1e32fe                    <NA>   -7.777778
#>  19: 9fd68db9-91aa-43e6-b24e-d2f28fc38f36                    <NA>   -7.777778
#>  20: af1ec7be-1252-4412-8c78-7bd2537728a3                    <NA>   -7.777778
#>  21: ce39f24c-6b5f-4043-875e-2ca02f2947df Optimization terminated          NA
#>  22: 39c51cd6-f28f-4bd0-a03e-aed0c30a0818 Optimization terminated          NA
#>  23: 7a71bffc-0552-443a-85e0-fef5e7aa3103 Optimization terminated          NA
#>  24: bf7f47a3-78fe-4e8d-ba60-20fdca922674 Optimization terminated          NA
#>  25: d26e2cc0-11a9-457a-8156-570b47e54322 Optimization terminated          NA
#>  26: 8b00a76d-5b9f-4cdf-a8d0-0d1a16e93c23 Optimization terminated          NA
#>  27: 063c9031-b8a8-4fdb-b0d9-c02b8c7c8626 Optimization terminated          NA
#>  28: e11e84f4-4b80-459a-9353-d13ff695d058 Optimization terminated          NA
#>  29: d39deeb3-a5df-4cb2-84bb-bce452bf0c75 Optimization terminated          NA
#>  30: 8f9d42a0-9eca-4223-9498-d9d41d3886ee Optimization terminated          NA
#>  31: 16943ab3-e009-45dc-b2a4-9c62f382d730 Optimization terminated          NA
#>  32: ff66feda-460c-4846-a464-23534e74d3b9 Optimization terminated          NA
#>  33: e84593e7-6514-4396-966c-155f36002678 Optimization terminated          NA
#>  34: bb098cc1-1eb5-465f-bca6-b09b95ebf60e Optimization terminated          NA
#>  35: 6003426d-b158-4c08-9f94-38d433ddb81f Optimization terminated          NA
#>  36: 6c3bc57c-1b07-4c8a-b7e7-008b77bb6689 Optimization terminated          NA
#>  37: 624247d0-386d-4618-99d1-a185f003647c Optimization terminated          NA
#>  38: 012b4903-ec77-40e4-b229-67160a7faeed Optimization terminated          NA
#>  39: 7a563eda-2a16-4302-a136-27e4bb2bd35f Optimization terminated          NA
#>  40: b85b3d23-e3a1-4ed8-9d4e-77b0c535e59b Optimization terminated          NA
#>  41: 30bb93e5-629f-4f68-8ec1-4c5e083bc22a Optimization terminated          NA
#>  42: 54226c18-b6e4-4c85-8de6-22fbc26d97c9 Optimization terminated          NA
#>  43: 03168451-ab5c-475f-84c4-80b7e737a06f Optimization terminated          NA
#>  44: fd10b7e1-aa96-444a-bd4f-e34e23217570 Optimization terminated          NA
#>  45: 2424ef9c-606f-49af-98e3-3d3d008aa4ba Optimization terminated          NA
#>  46: c657e632-fa6a-4b14-b5fa-dc58e3cce45b Optimization terminated          NA
#>  47: f63d605e-bd9a-4f65-bdb0-0478acef989d Optimization terminated          NA
#>  48: e5651420-efe7-4831-a56c-b3f13acd54de Optimization terminated          NA
#>  49: a6696257-f5e5-4c3e-b2fb-17cfab56f95b Optimization terminated          NA
#>  50: 5a9e85cb-a061-4049-a335-636e699826c6 Optimization terminated          NA
#>  51: 5681d125-23c8-4328-aa57-6abe2c4a596e Optimization terminated          NA
#>  52: 8112cac7-0a58-43ba-8d25-12b5c329e840 Optimization terminated          NA
#>  53: ead3a0e9-9924-4b6d-bf1c-7630c46f15d1 Optimization terminated          NA
#>  54: a75f3567-7de0-4de6-92d5-eef1862e9067 Optimization terminated          NA
#>  55: a2d63c18-25c0-4464-8be6-cbf0ed9406cf Optimization terminated          NA
#>  56: 077a622e-db12-4eab-9407-c8b5bb75fcbd Optimization terminated          NA
#>  57: 44aa607b-c2b6-4fd3-a61a-b2a876bd3864 Optimization terminated          NA
#>  58: 3dc6967d-2ddf-4416-a13e-e1698d033a80 Optimization terminated          NA
#>  59: e99c6f02-270d-45fc-8d9f-be6d9506375b Optimization terminated          NA
#>  60: a280afea-fb8d-4234-9611-93e673c069f8 Optimization terminated          NA
#>  61: c30d2ef0-593e-4c80-92a7-b2ec525c8bba Optimization terminated          NA
#>  62: 3f41df34-e4d6-446a-a3c7-44772b6fa81f Optimization terminated          NA
#>  63: c91a33ec-4717-41a8-a634-ca754f40924d Optimization terminated          NA
#>  64: 3d98fc3c-6587-4a59-874b-ee41e4b481a3 Optimization terminated          NA
#>  65: fb663191-6457-4bfd-a3ad-27e89a4bdd76 Optimization terminated          NA
#>  66: e42cb2eb-52cf-4fcd-9f33-db2e9e94219d Optimization terminated          NA
#>  67: 80890643-2c7f-4a94-aaad-5e0dd798f0a7 Optimization terminated          NA
#>  68: b73a53f0-458f-469c-a105-4275a257b737 Optimization terminated          NA
#>  69: de50894b-35c0-4228-8ea6-f6e70b77967b Optimization terminated          NA
#>  70: efed94d2-f2ca-4512-b7c9-3867bbb1e606 Optimization terminated          NA
#>  71: 07ffaab3-6052-4f44-9611-16063549c7d0 Optimization terminated          NA
#>  72: 04008896-4cf1-4f18-b5e0-92fe4934a349 Optimization terminated          NA
#>  73: a59a3033-80ab-4799-a5af-a440bd97ea1c Optimization terminated          NA
#>  74: a4ebd22d-fc30-4038-8995-879801d24d6a Optimization terminated          NA
#>  75: 0a9927e9-0fa8-4f68-bf10-8f1c733dba6a Optimization terminated          NA
#>  76: f19bda02-d0e3-48a1-8f24-dc4252138831 Optimization terminated          NA
#>  77: 0fc3d19e-61f9-4803-bc9a-464d6b6a4e1a Optimization terminated          NA
#>  78: 71181fee-5a30-4a3e-bf24-0cd00489e45a Optimization terminated          NA
#>  79: 291ce30e-353e-41d9-8ea0-8a55b7dca9ef Optimization terminated          NA
#>  80: 6b1d5c67-5b6e-4d63-bbd5-ba052285a254 Optimization terminated          NA
#>  81: ea7e10ad-dd89-4f72-ad01-511c82af3139 Optimization terminated          NA
#>  82: 484ec3a9-8961-4d10-ac07-15dcd76d7e45 Optimization terminated          NA
#>  83: 079a97b5-694b-4298-8945-05dfcc9a7c4b Optimization terminated          NA
#>  84: 190c8426-c9bf-498b-b858-de0ad0f16c03 Optimization terminated          NA
#>  85: 68d107a5-08f8-4bb6-bbbe-f1d8097a950e Optimization terminated          NA
#>  86: e4aff943-4d2b-4470-a995-7ec04b36f550 Optimization terminated          NA
#>  87: 67b8e138-4e94-4205-a726-f2947985cbbf Optimization terminated          NA
#>  88: cb80db02-0b23-41f6-8c77-8d5a4b96e087 Optimization terminated          NA
#>  89: 21e0a469-b692-4d40-a34c-1a422903bb31 Optimization terminated          NA
#>  90: 79104915-7f68-43c2-817c-0a1f88d94a67 Optimization terminated          NA
#>  91: 42c74ba1-8512-4cef-b09f-99ad9a50e4d3 Optimization terminated          NA
#>  92: 119989e5-72d2-4c67-837f-aa2ff64de443 Optimization terminated          NA
#>  93: 7d5b5408-4c16-4897-9971-9c5d95673283 Optimization terminated          NA
#>  94: 18d6ef77-b68e-44b5-afb1-e2f9bd683b96 Optimization terminated          NA
#>  95: 01849734-1c66-48a6-82eb-9e2ecf7c214e Optimization terminated          NA
#>  96: 6075aa1c-a834-4c5a-a0d1-e5621de9ed1f Optimization terminated          NA
#>  97: aafc9201-438e-4005-b880-44437393516a Optimization terminated          NA
#>  98: c29acc12-3f5f-43b5-a566-9bffc27a5b60 Optimization terminated          NA
#>  99: f6718e09-12cb-426d-96f0-ea58fc3fea88 Optimization terminated          NA
#> 100: 05631727-d27c-4829-9cb6-0850e0d1bc60 Optimization terminated          NA
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
