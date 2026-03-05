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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-05 08:52:24  8760
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-05 08:52:24  8760
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-05 08:52:24  8760
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-05 08:52:24  8760
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-05 08:52:24  8760
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-05 08:52:24  8760
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-05 08:52:24  8760
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-05 08:52:24  8760
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-05 08:52:24  8760
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-05 08:52:24  8760
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-05 08:52:24  8760
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-05 08:52:24  8760
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-05 08:52:24  8760
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-05 08:52:24  8760
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-05 08:52:24  8760
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-05 08:52:24  8760
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-05 08:52:24  8760
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-05 08:52:24  8760
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-05 08:52:24  8760
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-05 08:52:24  8760
#>  21:   failed  10.000000  5.0000000         NA 2026-03-05 08:52:24    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-03-05 08:52:24    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-03-05 08:52:24    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-03-05 08:52:24    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-03-05 08:52:24    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-03-05 08:52:24    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-03-05 08:52:24    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-03-05 08:52:24    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-03-05 08:52:24    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-03-05 08:52:24    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-03-05 08:52:24    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-03-05 08:52:24    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-03-05 08:52:24    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-03-05 08:52:24    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-03-05 08:52:24    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-03-05 08:52:24    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-03-05 08:52:24    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-03-05 08:52:24    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-03-05 08:52:24    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-03-05 08:52:24    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-03-05 08:52:24    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-03-05 08:52:24    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-03-05 08:52:24    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-03-05 08:52:24    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-03-05 08:52:24    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-05 08:52:24    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-05 08:52:24    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-05 08:52:24    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-05 08:52:24    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-05 08:52:24    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-05 08:52:24    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-05 08:52:24    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-05 08:52:24    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-05 08:52:24    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-05 08:52:24    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-05 08:52:24    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-05 08:52:24    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-05 08:52:24    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-05 08:52:24    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-05 08:52:24    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-05 08:52:24    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-05 08:52:24    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-05 08:52:24    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-05 08:52:24    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-05 08:52:24    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-05 08:52:24    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-05 08:52:24    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-03-05 08:52:25
#>   2: academical_guineapig 2026-03-05 08:52:25
#>   3: academical_guineapig 2026-03-05 08:52:25
#>   4: academical_guineapig 2026-03-05 08:52:25
#>   5: academical_guineapig 2026-03-05 08:52:25
#>   6: academical_guineapig 2026-03-05 08:52:25
#>   7: academical_guineapig 2026-03-05 08:52:25
#>   8: academical_guineapig 2026-03-05 08:52:25
#>   9: academical_guineapig 2026-03-05 08:52:25
#>  10: academical_guineapig 2026-03-05 08:52:25
#>  11: academical_guineapig 2026-03-05 08:52:25
#>  12: academical_guineapig 2026-03-05 08:52:25
#>  13: academical_guineapig 2026-03-05 08:52:25
#>  14: academical_guineapig 2026-03-05 08:52:25
#>  15: academical_guineapig 2026-03-05 08:52:25
#>  16: academical_guineapig 2026-03-05 08:52:25
#>  17: academical_guineapig 2026-03-05 08:52:25
#>  18: academical_guineapig 2026-03-05 08:52:25
#>  19: academical_guineapig 2026-03-05 08:52:25
#>  20: academical_guineapig 2026-03-05 08:52:25
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
#>   1: d7e2c63e-1298-4b4a-8c9b-b5dbd3e3d0ad                    <NA>  -10.000000
#>   2: 1e219204-6886-4926-8e2f-4bedfdd0b531                    <NA>  -10.000000
#>   3: aeeb679b-b633-492a-bec1-682f47f1320c                    <NA>  -10.000000
#>   4: bbf0209f-5fe4-4384-b821-8f19e579fa89                    <NA>  -10.000000
#>   5: cc8afccb-6c23-4802-a3cc-be411503e6f8                    <NA>  -10.000000
#>   6: f0e40e94-2995-4ec2-8400-4ea23cb2b4f5                    <NA>  -10.000000
#>   7: ba29575d-48fd-46f4-8a4f-17e785c41f07                    <NA>  -10.000000
#>   8: eab70ad3-3b15-465b-a027-6b7b5c6e040e                    <NA>  -10.000000
#>   9: e24962ff-88af-462b-8003-df4e4eb6db97                    <NA>  -10.000000
#>  10: 554424fa-6144-48b9-b8b3-e2d75ac7fb99                    <NA>  -10.000000
#>  11: 27c47acf-8b32-4ecf-8a28-00ca3534b843                    <NA>   -7.777778
#>  12: 744ead49-a94b-4faf-80b8-ff8baeb02090                    <NA>   -7.777778
#>  13: b73123ac-7290-468e-8127-3fd15e07b1ea                    <NA>   -7.777778
#>  14: c1ffbdb3-ad0e-4156-ab14-5e85be306358                    <NA>   -7.777778
#>  15: 7bccea77-f793-44e1-af27-02dfabb7f888                    <NA>   -7.777778
#>  16: 9c1e6cc8-93c0-43f0-86ab-d5a535a6b6fa                    <NA>   -7.777778
#>  17: 821f549d-411f-4004-a850-03f7c1378073                    <NA>   -7.777778
#>  18: 87fd10d0-3bba-4afe-a4e6-efa30059ee77                    <NA>   -7.777778
#>  19: e567b3c1-d8f9-4412-a999-c2e48148c4ca                    <NA>   -7.777778
#>  20: a4b81e4b-289f-44ca-8cd3-d8e18e309e4b                    <NA>   -7.777778
#>  21: da3121e7-f69a-4d4a-9c6d-a8e8b4689c51 Optimization terminated          NA
#>  22: e29d6147-df41-4fda-8ddf-e97c33b6f27b Optimization terminated          NA
#>  23: c043c51f-9360-4789-adc4-1bbb87270773 Optimization terminated          NA
#>  24: d774b296-b2a6-4020-90ed-3fbd218eccc3 Optimization terminated          NA
#>  25: 2da06c6b-8376-4a53-ab16-e98235745d8a Optimization terminated          NA
#>  26: 2a4c534e-702c-49ac-8cbd-6aa2e13f5b06 Optimization terminated          NA
#>  27: 14a8b0f6-1ad8-4c53-b9c0-b7383d354ba8 Optimization terminated          NA
#>  28: 904da25b-ed59-43b1-990f-97be6729aafa Optimization terminated          NA
#>  29: baba8571-6315-4c17-b475-a046a6af2d5f Optimization terminated          NA
#>  30: 643df6a4-e033-4e09-9f15-9a5e537f38b2 Optimization terminated          NA
#>  31: 2f080fd6-92b2-4f9d-bed6-b9ba88eafeb0 Optimization terminated          NA
#>  32: 026be482-7606-4bdb-8bcb-1bd3a623fe51 Optimization terminated          NA
#>  33: 9ba5b49a-3993-4123-a734-5ef0bb0fb482 Optimization terminated          NA
#>  34: 6a12da39-333c-4eb3-b491-31f57ae6c932 Optimization terminated          NA
#>  35: 106bf859-d0e6-4acd-bb24-a60a6529faa2 Optimization terminated          NA
#>  36: e502a811-8c27-48a2-a156-0b0556d867b9 Optimization terminated          NA
#>  37: 76c16085-e42d-43f0-8dee-eefa85a8c33b Optimization terminated          NA
#>  38: bb871d8a-5df7-468f-b59e-56800f2df052 Optimization terminated          NA
#>  39: 70ff7bf8-d54f-493f-8858-68df04785921 Optimization terminated          NA
#>  40: 9170492f-a3c5-4f20-9aaf-a8c3c3cb089b Optimization terminated          NA
#>  41: e85c5d70-88d3-4f51-9ee5-33db8868b6d2 Optimization terminated          NA
#>  42: 98efb32e-343a-4f42-9266-e8738a8ac7cc Optimization terminated          NA
#>  43: d7d17cf3-b546-45b9-b2be-ccf219b5d763 Optimization terminated          NA
#>  44: a928e23f-21ef-4bae-aeaa-82ff3d6e318d Optimization terminated          NA
#>  45: 23b24236-9a0c-4f93-8080-1b101f642195 Optimization terminated          NA
#>  46: ec869fde-6b44-422f-a665-226717c93930 Optimization terminated          NA
#>  47: 2eb75abd-62b6-4225-bd4f-33fc2f533240 Optimization terminated          NA
#>  48: 19aa6eeb-17bb-498f-a81c-894348a933fb Optimization terminated          NA
#>  49: 81a52d3d-8c10-4520-b105-c34bbf4f1151 Optimization terminated          NA
#>  50: 9e983df6-b670-452b-8249-efbbd94cae67 Optimization terminated          NA
#>  51: 7608ea89-2ca9-4b0b-b2e4-dcd82c5ede83 Optimization terminated          NA
#>  52: ee4b8d04-b541-45ee-8e06-65c6ec469b20 Optimization terminated          NA
#>  53: 87c0a346-3872-4f76-afd6-db2c7a2f8713 Optimization terminated          NA
#>  54: efca4e06-3ed9-4332-b89d-e9e3e4323bc1 Optimization terminated          NA
#>  55: 8e85fd60-41c3-400c-9024-f0be35a24383 Optimization terminated          NA
#>  56: 9f877a0b-8560-4006-99c3-13ad714ddeb4 Optimization terminated          NA
#>  57: 77bc0de1-21aa-44b8-9876-2dd5a4d0f47b Optimization terminated          NA
#>  58: 2cc395ec-bd98-41af-80c6-a190bffbeaad Optimization terminated          NA
#>  59: cdcad108-d7d0-4797-ad97-344a51a5b0c1 Optimization terminated          NA
#>  60: 56af771c-56bb-4d26-9d93-eab0ca8c71f9 Optimization terminated          NA
#>  61: 0590141f-08f4-4ed0-82df-9187046da58a Optimization terminated          NA
#>  62: f933aa08-f7dc-4db5-bd3f-f8dd0305d626 Optimization terminated          NA
#>  63: 1baae8b0-3b11-4f88-81e8-cdc2d6d038f4 Optimization terminated          NA
#>  64: 45b4e1ea-ea66-499b-a1f6-88ae497fbf0f Optimization terminated          NA
#>  65: 99ec1042-8bb1-4dc2-9809-80acac89dee8 Optimization terminated          NA
#>  66: d924b528-d502-4640-b662-712dfadb1669 Optimization terminated          NA
#>  67: 68f3ad05-10d0-4818-8e04-9ed4dbb7f6f0 Optimization terminated          NA
#>  68: 6205b964-374f-4214-8e42-07f7c4017ab5 Optimization terminated          NA
#>  69: 1105f12f-16a2-4d79-802a-2f93264d8f0e Optimization terminated          NA
#>  70: d4a0f8ac-b0d0-4617-93cf-87d7c9879d90 Optimization terminated          NA
#>  71: 3cc54e20-83ab-42a7-9546-82c62c441015 Optimization terminated          NA
#>  72: 711ca167-2e2c-46d8-a364-b213b5f89d42 Optimization terminated          NA
#>  73: 80862c20-3cf1-400d-9558-ea5b0380a9e3 Optimization terminated          NA
#>  74: 7ec49a4b-72ec-46db-9507-faa77b7b443d Optimization terminated          NA
#>  75: 4401d3e8-9c1e-446b-b9ae-b7b10886f530 Optimization terminated          NA
#>  76: dccb1c39-bc80-4594-bc31-27f2197000ed Optimization terminated          NA
#>  77: bccf38cb-35a3-4ae8-8122-8efb365b74e7 Optimization terminated          NA
#>  78: f0143814-53ca-4f2d-be3b-a63732b67939 Optimization terminated          NA
#>  79: cae06ca7-23b0-4ef9-99a2-7a6503ac4d1b Optimization terminated          NA
#>  80: 9b7ba6f6-4ff7-42ae-a111-eff6f4918690 Optimization terminated          NA
#>  81: 232ddd05-86f5-450c-a6cb-8dfd1455fded Optimization terminated          NA
#>  82: abacaf61-ca35-4eaf-a8fc-211285a3e1a9 Optimization terminated          NA
#>  83: f740eb95-ee9a-4f32-a444-888ce827c4a3 Optimization terminated          NA
#>  84: b0a28c4a-8ed5-4b07-a736-55e061fc9a0d Optimization terminated          NA
#>  85: d790601a-793e-40fb-9d81-f030bbc65601 Optimization terminated          NA
#>  86: eec03ca7-f0f0-42c1-bab2-800f91bd72e0 Optimization terminated          NA
#>  87: d5dfe789-9cba-4d68-915f-525265170347 Optimization terminated          NA
#>  88: c879a71f-5aa9-43e5-81e1-4c7f6de1fd1d Optimization terminated          NA
#>  89: 721a3dc6-a9c7-4e8a-8c06-382afd85b053 Optimization terminated          NA
#>  90: 68d2b687-c7d0-48a0-8c57-f814c66652d6 Optimization terminated          NA
#>  91: 3b014716-1534-4086-a0f5-a2d1096ba697 Optimization terminated          NA
#>  92: aad76b52-8298-4ece-b11c-569c16114ecd Optimization terminated          NA
#>  93: cd011560-28d8-4c91-8b0a-f3d8d8975147 Optimization terminated          NA
#>  94: 6542afa5-75be-4fb7-848c-95939dbe0a2c Optimization terminated          NA
#>  95: 7fdf2d10-08d8-4b7c-aad0-6d46ea6643f6 Optimization terminated          NA
#>  96: b0dc6828-e855-43eb-9341-29296f182dc4 Optimization terminated          NA
#>  97: 5e5567dd-763c-4090-9098-95859df5f983 Optimization terminated          NA
#>  98: 8cc0750d-6dc4-41ef-bce3-c303bea51e1a Optimization terminated          NA
#>  99: 84af29d1-b0c4-475d-b961-702c1e82b5bb Optimization terminated          NA
#> 100: 283886a5-ade5-4002-a832-8514f4cefea9 Optimization terminated          NA
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
