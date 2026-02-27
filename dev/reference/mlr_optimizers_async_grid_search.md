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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-27 14:23:23  8803
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-27 14:23:23  8803
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-27 14:23:23  8803
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-27 14:23:23  8803
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-27 14:23:23  8803
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-27 14:23:23  8803
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-27 14:23:23  8803
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-27 14:23:23  8803
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-27 14:23:23  8803
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-27 14:23:23  8803
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-27 14:23:23  8803
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-27 14:23:23  8803
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-27 14:23:23  8803
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-27 14:23:23  8803
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-27 14:23:23  8803
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-27 14:23:23  8803
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-27 14:23:23  8803
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-27 14:23:23  8803
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-27 14:23:23  8803
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-27 14:23:23  8803
#>  21:   failed  10.000000  5.0000000         NA 2026-02-27 14:23:23    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-27 14:23:23    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-27 14:23:23    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-27 14:23:23    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-27 14:23:23    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-27 14:23:23    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-27 14:23:23    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-27 14:23:23    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-27 14:23:23    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-27 14:23:23    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-27 14:23:23    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-27 14:23:23    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-27 14:23:23    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-27 14:23:23    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-27 14:23:23    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-27 14:23:23    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-27 14:23:23    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-27 14:23:23    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-27 14:23:23    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-27 14:23:23    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-27 14:23:23    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-27 14:23:23    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-27 14:23:23    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-27 14:23:23    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-27 14:23:23    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-27 14:23:23    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-27 14:23:23    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-27 14:23:23    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-27 14:23:23    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-27 14:23:23    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-27 14:23:23    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-27 14:23:23    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-27 14:23:23    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-27 14:23:23    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-27 14:23:23    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-27 14:23:23    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-27 14:23:23    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-27 14:23:23    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-27 14:23:23    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-27 14:23:23    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-27 14:23:23    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-27 14:23:23    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-27 14:23:23    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-27 14:23:23    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-27 14:23:23    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-27 14:23:23    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-27 14:23:23    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-27 14:23:24
#>   2: academical_guineapig 2026-02-27 14:23:24
#>   3: academical_guineapig 2026-02-27 14:23:24
#>   4: academical_guineapig 2026-02-27 14:23:24
#>   5: academical_guineapig 2026-02-27 14:23:24
#>   6: academical_guineapig 2026-02-27 14:23:24
#>   7: academical_guineapig 2026-02-27 14:23:24
#>   8: academical_guineapig 2026-02-27 14:23:24
#>   9: academical_guineapig 2026-02-27 14:23:24
#>  10: academical_guineapig 2026-02-27 14:23:24
#>  11: academical_guineapig 2026-02-27 14:23:24
#>  12: academical_guineapig 2026-02-27 14:23:24
#>  13: academical_guineapig 2026-02-27 14:23:24
#>  14: academical_guineapig 2026-02-27 14:23:24
#>  15: academical_guineapig 2026-02-27 14:23:24
#>  16: academical_guineapig 2026-02-27 14:23:24
#>  17: academical_guineapig 2026-02-27 14:23:24
#>  18: academical_guineapig 2026-02-27 14:23:24
#>  19: academical_guineapig 2026-02-27 14:23:24
#>  20: academical_guineapig 2026-02-27 14:23:24
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
#>   1: 3d411707-cb08-43f1-84db-5a088bf43a1e                    <NA>  -10.000000
#>   2: d36eb334-6dff-4ec4-a346-fefe5c0e5a7f                    <NA>  -10.000000
#>   3: 8c3c69a5-d644-4ff9-9a29-1203eef06866                    <NA>  -10.000000
#>   4: 7d2cae0b-a990-4d35-8925-1e1c4a0ea966                    <NA>  -10.000000
#>   5: 909ddbed-ed61-497b-9cf7-8a419ec4ff4e                    <NA>  -10.000000
#>   6: 211f6a7d-9995-44ac-9d1d-b7e566491302                    <NA>  -10.000000
#>   7: 64f51c28-c556-48b8-9a89-bf29c4c89fbe                    <NA>  -10.000000
#>   8: f208502c-a10d-490a-8225-556a989fddc2                    <NA>  -10.000000
#>   9: 8175dfd0-3462-46ef-b212-6393754c70bc                    <NA>  -10.000000
#>  10: 8a9fbce3-6387-44e4-853a-2a7a21e2f1dd                    <NA>  -10.000000
#>  11: d47b0e9d-a066-493d-9eb5-09f9fd823d32                    <NA>   -7.777778
#>  12: 4acf82c8-0817-4821-a033-d5a9e5ba657e                    <NA>   -7.777778
#>  13: c7694ea8-339a-4d41-838f-54eff664ee26                    <NA>   -7.777778
#>  14: 31bc75e6-28f3-409b-8287-2bb7c8ad2484                    <NA>   -7.777778
#>  15: 93462b1a-c22f-497e-a221-35dc9f50ff5f                    <NA>   -7.777778
#>  16: 8894b0fb-dc94-452f-aed5-7709834a1415                    <NA>   -7.777778
#>  17: 074014d9-cdf8-4e0b-99d2-7056915039b6                    <NA>   -7.777778
#>  18: 5899fbd2-19df-4aa2-a044-359260059320                    <NA>   -7.777778
#>  19: 222e5b02-8224-401f-912b-50073196a0c7                    <NA>   -7.777778
#>  20: 5e81bdc8-2400-4c5e-9b09-b884314e5352                    <NA>   -7.777778
#>  21: 1e380ae2-ceb4-4bc9-8915-f539e5a5d82c Optimization terminated          NA
#>  22: eed44160-48b7-47b4-986c-2195dcacb2cc Optimization terminated          NA
#>  23: 0b7d92a5-b9e6-4ba3-92d0-527fbc6aabde Optimization terminated          NA
#>  24: 2347ce1b-ffdd-4027-88be-6d1971c029fd Optimization terminated          NA
#>  25: 8565f41d-1b15-41ee-a9ce-6dfb9229c536 Optimization terminated          NA
#>  26: 8a6f567e-ed80-4d04-aba7-df1aff405d46 Optimization terminated          NA
#>  27: 11807288-54c3-4a86-abec-defa99dfac24 Optimization terminated          NA
#>  28: 3211ede4-9435-45ac-9230-9eb73e025a32 Optimization terminated          NA
#>  29: 10b63bc8-a921-4e3b-a5ef-8693a376018f Optimization terminated          NA
#>  30: 5eb8742f-85ea-4bcd-868e-bd7d816b36bc Optimization terminated          NA
#>  31: 4146974c-ecf5-436e-bf74-d502f2222876 Optimization terminated          NA
#>  32: 822b2486-2e8e-48c6-a87c-864951a3b3bb Optimization terminated          NA
#>  33: 760ec6f1-d8f1-4074-8c0a-ce3306e0bf41 Optimization terminated          NA
#>  34: 77f4a264-8774-4b11-a4a2-b549520fbb9a Optimization terminated          NA
#>  35: 1a2cbd57-a61b-4d79-9922-a92e17034aea Optimization terminated          NA
#>  36: 52c67171-1331-413a-b83f-3e736f164d4b Optimization terminated          NA
#>  37: 7da5c43d-059f-454c-8b3d-bc88fa1a79ac Optimization terminated          NA
#>  38: e3bd9889-38f4-40d3-aa0e-773efc9d4273 Optimization terminated          NA
#>  39: aa10eb08-0dcd-40b7-8b26-d825aa64c9be Optimization terminated          NA
#>  40: 98bf3101-ca38-4741-a59b-4e42e9be5690 Optimization terminated          NA
#>  41: 734c5eee-7bb0-4af9-949b-d44cd12e1078 Optimization terminated          NA
#>  42: 846cb553-f4ea-4110-897c-f7c691eae8a9 Optimization terminated          NA
#>  43: fc1a94af-0876-4f30-9b22-0c211213d044 Optimization terminated          NA
#>  44: 744b3209-8f41-4c70-a9a9-ee4aa6977160 Optimization terminated          NA
#>  45: f29301f1-00a1-4622-958b-9edcb7759314 Optimization terminated          NA
#>  46: 1f9fa6d7-04d7-4630-9121-9f34862e31df Optimization terminated          NA
#>  47: 2461d08e-3ec8-4880-888b-5e30e09ea5a9 Optimization terminated          NA
#>  48: 5def041b-4b78-43af-a0ef-7b386b7ba3eb Optimization terminated          NA
#>  49: 27534931-21c0-4731-810b-ecb63816f607 Optimization terminated          NA
#>  50: 9c0a583a-382b-48ee-a01b-8de74200e673 Optimization terminated          NA
#>  51: 0ac96cb4-a0fc-41c6-9b51-2db73a1dd6a4 Optimization terminated          NA
#>  52: 8e7c881f-f298-48fb-939e-dafd5da23eb9 Optimization terminated          NA
#>  53: b8122e93-236c-4dc2-b811-f5e004a7391c Optimization terminated          NA
#>  54: 25505d65-75bb-47c8-8377-a49d2501759c Optimization terminated          NA
#>  55: 60391781-25ee-4cfb-9fc3-12413eafe1c5 Optimization terminated          NA
#>  56: 8e12f36b-7aac-4bea-aa5c-c18e9cf91bf8 Optimization terminated          NA
#>  57: 94ee02ec-9822-4b1f-9b6d-8f68160c8a5a Optimization terminated          NA
#>  58: f08e23d3-8e09-4c8d-a5cd-20ed7272a740 Optimization terminated          NA
#>  59: e242d8d1-6e88-417b-8cce-718283a3d61b Optimization terminated          NA
#>  60: 212ed090-fe0d-4c3a-9bdd-f1566fcb4c68 Optimization terminated          NA
#>  61: 9f19ff80-bc97-4903-b466-45210661059d Optimization terminated          NA
#>  62: 952e8fe7-c54f-4d6d-8815-54e1f5529619 Optimization terminated          NA
#>  63: 7e95666c-43b6-438e-a88d-fc7d0b55905a Optimization terminated          NA
#>  64: dc9ef8d9-d81c-42db-967e-b1927526b760 Optimization terminated          NA
#>  65: b08c4ef0-dcca-494f-ac8f-645afd92e392 Optimization terminated          NA
#>  66: a7f4692d-e472-40ea-9a8d-596aa1e81f00 Optimization terminated          NA
#>  67: 0fb32dd9-c461-44c4-867f-4ea57e3fcf15 Optimization terminated          NA
#>  68: 225bc002-9152-4c71-94ff-2cbe46ccc510 Optimization terminated          NA
#>  69: 6fb1a3f8-ba8d-4aee-ac24-5ddd1e5b5002 Optimization terminated          NA
#>  70: fd886b19-8278-4611-8de1-89b3290ed44b Optimization terminated          NA
#>  71: e5130cf2-c537-4761-bc71-cd10ce812c63 Optimization terminated          NA
#>  72: a44358b5-ca0f-4bde-995a-c2ab1ac6bec3 Optimization terminated          NA
#>  73: a2673422-4dcd-491c-8810-891bacaab88b Optimization terminated          NA
#>  74: cf1222c4-eaba-458a-899e-641f5067e93c Optimization terminated          NA
#>  75: a29e4133-d162-4bdd-a01e-0e1966f26c6b Optimization terminated          NA
#>  76: cbe4d009-fafa-4628-b38d-60707acbb548 Optimization terminated          NA
#>  77: 1b46b867-b6e9-4071-ae2b-7108372c64fa Optimization terminated          NA
#>  78: 76696fe2-be89-4741-abfd-b3d30faeb501 Optimization terminated          NA
#>  79: 8fd8f8bf-16a6-4d40-b0c4-f256183d4352 Optimization terminated          NA
#>  80: 9d28b06e-02c1-44cd-8dab-8a2b6faa816a Optimization terminated          NA
#>  81: 259e6bd7-7038-42b8-a7a8-156ae7a3287a Optimization terminated          NA
#>  82: bac95e5b-fafd-4aa7-886d-06fd2bb36a35 Optimization terminated          NA
#>  83: 0735c2a8-6e92-4ca2-9cff-a7bf650d1e3d Optimization terminated          NA
#>  84: 4eb0cc62-3d20-44d9-9f91-bd358e358c4e Optimization terminated          NA
#>  85: 10c8be02-78d0-4b95-bd67-faf2356ea9c5 Optimization terminated          NA
#>  86: a354aea1-e7c7-4180-8772-325715d794e2 Optimization terminated          NA
#>  87: 48b9a136-426a-4272-8da2-757ab4faa154 Optimization terminated          NA
#>  88: 43caf0bc-9e3d-492b-8f35-f1ef5cd38661 Optimization terminated          NA
#>  89: defdbeca-ea22-4468-b2a7-a248c1bdc800 Optimization terminated          NA
#>  90: 0900eb7b-6ee6-4bc9-b6c6-730de43849b8 Optimization terminated          NA
#>  91: 7586400b-22cd-4361-a5ac-c9d9918f2875 Optimization terminated          NA
#>  92: 252d9c3a-aa33-437b-956e-bf87b3c51205 Optimization terminated          NA
#>  93: 55939438-3361-4b6c-9306-cd139c420479 Optimization terminated          NA
#>  94: 908bcc98-3d7b-499a-9faa-a10ca86594d1 Optimization terminated          NA
#>  95: 8e8283c8-979f-4a12-ac13-06456ee5d596 Optimization terminated          NA
#>  96: cf0b3ebd-d809-4657-aff9-8f4bd23580a5 Optimization terminated          NA
#>  97: eba28df9-016e-4ca0-a36f-d0a00cf1fd0e Optimization terminated          NA
#>  98: 0dc4eda2-ae12-4bbd-b864-e0966d34a422 Optimization terminated          NA
#>  99: 3a6f6c37-9a62-43f8-b490-38e02cd98ab5 Optimization terminated          NA
#> 100: e851e590-35b0-4b6f-a096-a4921f211989 Optimization terminated          NA
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
