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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-28 07:04:04  8761
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-28 07:04:04  8761
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-28 07:04:04  8761
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-28 07:04:04  8761
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-28 07:04:04  8761
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-28 07:04:04  8761
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-28 07:04:04  8761
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-28 07:04:04  8761
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-28 07:04:04  8761
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-28 07:04:04  8761
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-28 07:04:04  8761
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-28 07:04:04  8761
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-28 07:04:04  8761
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-28 07:04:04  8761
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-28 07:04:04  8761
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-28 07:04:04  8761
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-28 07:04:04  8761
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-28 07:04:04  8761
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-28 07:04:04  8761
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-28 07:04:04  8761
#>  21:   failed  10.000000  5.0000000         NA 2026-02-28 07:04:04    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-28 07:04:04    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-28 07:04:04    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-28 07:04:04    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-28 07:04:04    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-28 07:04:04    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-28 07:04:04    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-28 07:04:04    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-28 07:04:04    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-28 07:04:04    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-28 07:04:04    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-28 07:04:04    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-28 07:04:04    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-28 07:04:04    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-28 07:04:04    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-28 07:04:04    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-28 07:04:04    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-28 07:04:04    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-28 07:04:04    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-28 07:04:04    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-28 07:04:04    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-28 07:04:04    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-28 07:04:04    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-28 07:04:04    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-28 07:04:04    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-28 07:04:04    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-28 07:04:04    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-28 07:04:04    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-28 07:04:04    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-28 07:04:04    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-28 07:04:04    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-28 07:04:04    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-28 07:04:04    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-28 07:04:04    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-28 07:04:04    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-28 07:04:04    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-28 07:04:04    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-28 07:04:04    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-28 07:04:04    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-28 07:04:04    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-28 07:04:04    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-28 07:04:04    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-28 07:04:04    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-28 07:04:04    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-28 07:04:04    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-28 07:04:04    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-28 07:04:04    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-28 07:04:05
#>   2: academical_guineapig 2026-02-28 07:04:05
#>   3: academical_guineapig 2026-02-28 07:04:05
#>   4: academical_guineapig 2026-02-28 07:04:05
#>   5: academical_guineapig 2026-02-28 07:04:05
#>   6: academical_guineapig 2026-02-28 07:04:05
#>   7: academical_guineapig 2026-02-28 07:04:05
#>   8: academical_guineapig 2026-02-28 07:04:05
#>   9: academical_guineapig 2026-02-28 07:04:05
#>  10: academical_guineapig 2026-02-28 07:04:05
#>  11: academical_guineapig 2026-02-28 07:04:05
#>  12: academical_guineapig 2026-02-28 07:04:05
#>  13: academical_guineapig 2026-02-28 07:04:05
#>  14: academical_guineapig 2026-02-28 07:04:05
#>  15: academical_guineapig 2026-02-28 07:04:05
#>  16: academical_guineapig 2026-02-28 07:04:05
#>  17: academical_guineapig 2026-02-28 07:04:05
#>  18: academical_guineapig 2026-02-28 07:04:05
#>  19: academical_guineapig 2026-02-28 07:04:05
#>  20: academical_guineapig 2026-02-28 07:04:05
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
#>   1: ad0717f0-92c1-453a-9925-f6eec9a060dc                    <NA>  -10.000000
#>   2: e6007fbe-b97a-4d25-b0f9-ae31c2f08869                    <NA>  -10.000000
#>   3: a0c70d93-6fa9-4712-bd63-445f07cbcd9e                    <NA>  -10.000000
#>   4: dd6296f0-5a35-4105-849c-98daaff3bb65                    <NA>  -10.000000
#>   5: cbc314e0-ca71-4972-a074-6005e5827dee                    <NA>  -10.000000
#>   6: 589bfa3a-ba7d-4623-adb1-9d10ce23f823                    <NA>  -10.000000
#>   7: 83307eee-c36b-4383-8f1b-80c90f56bde1                    <NA>  -10.000000
#>   8: f99972ba-6d79-4abc-9b2c-705eb928f7a3                    <NA>  -10.000000
#>   9: 55d27dbf-e384-4586-9047-a5e05a769ad3                    <NA>  -10.000000
#>  10: fc0dae6c-62dd-4f06-b6fc-ffa8fc28a2eb                    <NA>  -10.000000
#>  11: b234ebfd-0aea-449e-bde1-de178f91e201                    <NA>   -7.777778
#>  12: f6b28777-2d24-44ef-aa3a-d2ae0f0f5803                    <NA>   -7.777778
#>  13: 07b9f394-5e96-468a-a9fe-040e69e6aa7e                    <NA>   -7.777778
#>  14: d138ce87-1cb4-44ab-b1cb-73cc95008615                    <NA>   -7.777778
#>  15: 6617b027-4c78-4ff2-93e4-26f7d238cb27                    <NA>   -7.777778
#>  16: a482f525-544e-4122-9e34-1bca0d383eaa                    <NA>   -7.777778
#>  17: 6dd0c82a-449e-41cd-b750-0f22a39e792f                    <NA>   -7.777778
#>  18: 969f77d6-42d0-411b-ba4f-0b19b1534736                    <NA>   -7.777778
#>  19: 3179473c-c44a-413d-81b1-79420e2a9656                    <NA>   -7.777778
#>  20: 2c09e438-2164-4bc3-890b-5633f8e6b29f                    <NA>   -7.777778
#>  21: e058fe1e-5f28-4623-afec-74f51f50b965 Optimization terminated          NA
#>  22: c95b2857-38bc-4e50-8834-5cc0dd61e814 Optimization terminated          NA
#>  23: a0a58bed-0c54-4e07-bb6d-6a0012c1923f Optimization terminated          NA
#>  24: 064a215d-fb42-4603-84bf-8c0862703f25 Optimization terminated          NA
#>  25: 1a6be23c-352e-4708-911d-6812ed1ca4f3 Optimization terminated          NA
#>  26: 79c3057f-e683-4434-9485-d136c9215bf7 Optimization terminated          NA
#>  27: 268507ae-1eb7-4898-8c7b-2b8ff86e537d Optimization terminated          NA
#>  28: 6c77d389-e15a-49d6-9a8d-0fed50a332a1 Optimization terminated          NA
#>  29: 5ccd318d-f112-472e-9f3a-04d3f60498ba Optimization terminated          NA
#>  30: 55eeb22b-605a-445c-ae2b-0349becc72ef Optimization terminated          NA
#>  31: c82fe053-da69-47f0-a6bc-0a6702e59433 Optimization terminated          NA
#>  32: a1728d6c-e9a2-459b-883c-d9d9378351f5 Optimization terminated          NA
#>  33: 5bea9b36-f952-4eef-9db2-13d91c875621 Optimization terminated          NA
#>  34: fb071c6b-1a7d-4de9-8b95-83183a906849 Optimization terminated          NA
#>  35: 32aa2e55-671d-4ee3-a05f-41b601978d2c Optimization terminated          NA
#>  36: 7b3c6e27-b8e8-4d69-b943-724b988dd3b7 Optimization terminated          NA
#>  37: a212b571-eef7-4f74-9529-2ff2e1d79790 Optimization terminated          NA
#>  38: 8456a9f7-0a01-49ef-8c3e-a6a4893885e5 Optimization terminated          NA
#>  39: 05b80e21-d65a-4110-b974-4308a2f68656 Optimization terminated          NA
#>  40: d4f1f801-1005-4837-9712-8c82ad680e5c Optimization terminated          NA
#>  41: 5942952c-a2a0-46ef-a34c-bc8daa6c9a89 Optimization terminated          NA
#>  42: 3a4c43e5-0528-4b50-839c-866ff6988b1a Optimization terminated          NA
#>  43: dfdbe7d8-48ff-44fd-91ab-11d1eab7b6da Optimization terminated          NA
#>  44: c0e71787-59a9-43e0-96c8-fdbdcce9e624 Optimization terminated          NA
#>  45: fc2c4feb-4d8b-48b0-a7e9-8e32529082cd Optimization terminated          NA
#>  46: fb78103f-1ce4-42d1-b6a5-ee45bab2ee89 Optimization terminated          NA
#>  47: 33b53575-2b21-4b4d-8171-09a6fcd5840b Optimization terminated          NA
#>  48: 6df06c10-3c93-41e1-b1d7-e7edfaaa9b23 Optimization terminated          NA
#>  49: 63af2c66-f7e2-411d-993a-b6043ddc6270 Optimization terminated          NA
#>  50: 94622602-9cc6-472e-a864-d89d9d0d3607 Optimization terminated          NA
#>  51: d5eee6fe-b906-4e6c-9a62-e7c8d08449c2 Optimization terminated          NA
#>  52: 47de9191-b741-4ea4-bbf3-e261ad08fea7 Optimization terminated          NA
#>  53: dd176858-a474-414d-ae76-2966fb5bc944 Optimization terminated          NA
#>  54: cb17615f-3f81-4c06-8caf-1a78d5285c49 Optimization terminated          NA
#>  55: 0e800818-5806-4e52-83e4-7bf0d3228dd4 Optimization terminated          NA
#>  56: 2424fa97-a1d7-40de-8f4d-4bc5f8fca00a Optimization terminated          NA
#>  57: ea2a7143-43a0-412f-abca-a8952fa2893d Optimization terminated          NA
#>  58: 7f8b4bc2-fc41-4598-81e7-b096013bc16a Optimization terminated          NA
#>  59: 63100229-bded-472b-8ce0-c9eba35091f7 Optimization terminated          NA
#>  60: d9bb36b1-a0e7-4eec-b550-adcbad47ec29 Optimization terminated          NA
#>  61: 0ed7abc8-acb8-4c52-850d-66619e7572a3 Optimization terminated          NA
#>  62: 7725eaa0-1006-4153-bf18-81a5f07eb01e Optimization terminated          NA
#>  63: 1cbcbf34-19cd-454f-9f8c-9de4bb968526 Optimization terminated          NA
#>  64: 2100d5fb-ac46-40a6-b46e-369dd357e098 Optimization terminated          NA
#>  65: f65c1094-ce6d-4548-8dd9-f6dd9689dbda Optimization terminated          NA
#>  66: 147121c9-d2ac-4942-be4b-4276d3e37689 Optimization terminated          NA
#>  67: 98a53606-06df-4c75-bc78-9a9270fc59f3 Optimization terminated          NA
#>  68: 83647ffc-4c4e-4fe9-93a7-1d92ffe919ee Optimization terminated          NA
#>  69: 4afa8208-d3ee-48b0-b843-f0c1af5cefbb Optimization terminated          NA
#>  70: 22ac7a5d-6ca8-4acd-b856-e072eac6a9b2 Optimization terminated          NA
#>  71: 878ebc82-2c37-446d-bb98-cec04040efe3 Optimization terminated          NA
#>  72: cd2c7271-2ba2-48eb-9367-0d27784f9798 Optimization terminated          NA
#>  73: 3d9b7154-711e-4e01-8dac-f7ddaca3f162 Optimization terminated          NA
#>  74: 8ffdd589-a4d1-4ece-963b-97fa008e03d7 Optimization terminated          NA
#>  75: f730c8d2-ee34-47bf-bf03-9a7f4a3a082f Optimization terminated          NA
#>  76: 740aaa1d-7ddb-4af6-a28b-bef6eee098f9 Optimization terminated          NA
#>  77: bf3805d6-ded9-437e-8723-3495c63d6507 Optimization terminated          NA
#>  78: 505b845b-3fdd-4bbe-a97e-1514bb81227d Optimization terminated          NA
#>  79: 5f63b492-6eb4-4398-8502-b1574ff951a9 Optimization terminated          NA
#>  80: 36c54ffb-8e08-40a5-8d7a-3ba1b1c44a41 Optimization terminated          NA
#>  81: 863a1d0b-a8b6-4ff3-a3a8-6553f7f70cca Optimization terminated          NA
#>  82: 652ff529-4353-47c8-a151-7e5b3dba5988 Optimization terminated          NA
#>  83: a166f38b-feff-49f6-8f1b-b1ff7a88b969 Optimization terminated          NA
#>  84: cd98bfa7-d8d6-430d-ba4f-455f393c6377 Optimization terminated          NA
#>  85: 6d71c3fd-fafe-43a1-89f5-d53eb2ffbf63 Optimization terminated          NA
#>  86: 4aedf62c-9798-49b2-804e-72dd90aab352 Optimization terminated          NA
#>  87: df123e6f-0891-4770-8396-e35af3855f94 Optimization terminated          NA
#>  88: 685d6f85-6e58-4467-97c6-68198609a071 Optimization terminated          NA
#>  89: fd23a84e-b14c-43b9-9574-434aea4dffe4 Optimization terminated          NA
#>  90: e76a7254-6532-40f1-ac72-fa7bc44d1b99 Optimization terminated          NA
#>  91: 3fdd7328-f979-46e4-bacb-2656d18bdc4b Optimization terminated          NA
#>  92: cede28e3-9a13-48a4-b0f1-4225d2f3e51d Optimization terminated          NA
#>  93: 223d0e37-0aad-493b-bcc9-ca1f54ce8d7a Optimization terminated          NA
#>  94: db4e8df6-a286-4c51-ad19-fa5b9d875eba Optimization terminated          NA
#>  95: b550f846-dd1a-4574-a677-e7d18c7c495f Optimization terminated          NA
#>  96: 4e754cc2-7cb8-41f2-846c-e338600da40f Optimization terminated          NA
#>  97: 72ff5329-be04-4de7-96dc-be2c01ca3e65 Optimization terminated          NA
#>  98: 6239e887-79a6-499f-a269-a3534669a541 Optimization terminated          NA
#>  99: 89a0e3cd-3fe5-427c-bf13-db4bca4bc54d Optimization terminated          NA
#> 100: 85d918d0-2081-4491-8997-26df12eee2f5 Optimization terminated          NA
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
