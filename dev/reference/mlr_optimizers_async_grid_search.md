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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-26 09:06:13  8316
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-26 09:06:13  8316
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-26 09:06:13  8316
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-26 09:06:13  8316
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-26 09:06:13  8316
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-26 09:06:13  8316
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-26 09:06:13  8316
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-26 09:06:13  8316
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-26 09:06:13  8316
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-26 09:06:13  8316
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-26 09:06:13  8316
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-26 09:06:13  8316
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-26 09:06:13  8316
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-26 09:06:13  8316
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-26 09:06:13  8316
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-26 09:06:13  8316
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-26 09:06:13  8316
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-26 09:06:13  8316
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-26 09:06:13  8316
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-26 09:06:13  8316
#>  21:   failed  10.000000  5.0000000         NA 2025-11-26 09:06:13    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-26 09:06:13    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-26 09:06:13    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-26 09:06:13    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-26 09:06:13    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-26 09:06:13    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-26 09:06:13    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-26 09:06:13    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-26 09:06:13    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-26 09:06:13    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-26 09:06:13    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-26 09:06:13    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-26 09:06:13    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-26 09:06:13    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-26 09:06:13    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-26 09:06:13    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-26 09:06:13    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-26 09:06:13    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-26 09:06:13    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-26 09:06:13    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-26 09:06:13    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-26 09:06:13    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-26 09:06:13    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-26 09:06:13    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-26 09:06:13    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-26 09:06:13    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-26 09:06:13    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-26 09:06:13    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-26 09:06:13    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-26 09:06:13    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-26 09:06:13    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-26 09:06:13    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-26 09:06:13    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-26 09:06:13    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-26 09:06:13    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-26 09:06:13    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-26 09:06:13    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-26 09:06:13    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-26 09:06:13    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-26 09:06:13    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-26 09:06:13    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-26 09:06:13    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-26 09:06:13    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-26 09:06:13    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-26 09:06:13    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-26 09:06:13    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-26 09:06:13    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-26 09:06:14
#>   2: academical_guineapig 2025-11-26 09:06:14
#>   3: academical_guineapig 2025-11-26 09:06:14
#>   4: academical_guineapig 2025-11-26 09:06:14
#>   5: academical_guineapig 2025-11-26 09:06:14
#>   6: academical_guineapig 2025-11-26 09:06:14
#>   7: academical_guineapig 2025-11-26 09:06:14
#>   8: academical_guineapig 2025-11-26 09:06:14
#>   9: academical_guineapig 2025-11-26 09:06:14
#>  10: academical_guineapig 2025-11-26 09:06:14
#>  11: academical_guineapig 2025-11-26 09:06:14
#>  12: academical_guineapig 2025-11-26 09:06:14
#>  13: academical_guineapig 2025-11-26 09:06:14
#>  14: academical_guineapig 2025-11-26 09:06:14
#>  15: academical_guineapig 2025-11-26 09:06:14
#>  16: academical_guineapig 2025-11-26 09:06:14
#>  17: academical_guineapig 2025-11-26 09:06:14
#>  18: academical_guineapig 2025-11-26 09:06:14
#>  19: academical_guineapig 2025-11-26 09:06:14
#>  20: academical_guineapig 2025-11-26 09:06:14
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
#>   1: 88233daa-8ee3-4aad-a637-cd27b5fb9843                    <NA>  -10.000000
#>   2: 20ea99f1-d16e-485e-bc10-08cae3f69e8d                    <NA>  -10.000000
#>   3: c84d91cd-3813-49a4-bde3-3a1ede15a10e                    <NA>  -10.000000
#>   4: a9542576-180f-4f44-b2ca-f4b8ccadd9d8                    <NA>  -10.000000
#>   5: 2438681d-fc06-4344-8045-08df798e343f                    <NA>  -10.000000
#>   6: 6114eede-0132-42a8-9f5c-872c3589899e                    <NA>  -10.000000
#>   7: 8bf145a2-8867-4f94-8c0f-afffb3d283ee                    <NA>  -10.000000
#>   8: 1e23d4b3-3d47-45eb-bcf4-7f1c74dc0105                    <NA>  -10.000000
#>   9: 3c31c9ec-066e-4b85-b843-1151c10fc243                    <NA>  -10.000000
#>  10: 506238ca-1168-4b9d-8eb2-1cbed258455f                    <NA>  -10.000000
#>  11: 92898fcf-0e06-4b27-88f3-fc9b4302432c                    <NA>   -7.777778
#>  12: 39ef09b9-21a0-4099-9d0c-ad355ba8b0fb                    <NA>   -7.777778
#>  13: 3d8104a5-fcee-4432-b240-1290f754bee7                    <NA>   -7.777778
#>  14: 3e7c509c-ff03-4499-bda6-afaa77054fd2                    <NA>   -7.777778
#>  15: a1adc754-bee9-4027-bad7-956c3ef50d03                    <NA>   -7.777778
#>  16: 30940687-6f5b-44ac-9ccb-9b267b74adc6                    <NA>   -7.777778
#>  17: ce08dddc-66ea-445c-a841-8e8385307ba6                    <NA>   -7.777778
#>  18: 855b14b5-5974-4040-bf1d-bfa762cb93bf                    <NA>   -7.777778
#>  19: e4a7a98a-df2b-49ce-957f-debd2a7341f7                    <NA>   -7.777778
#>  20: e82aef47-132e-4ca2-8de5-cead74403577                    <NA>   -7.777778
#>  21: fe43f91d-5698-4779-905a-e669d014d17d Optimization terminated          NA
#>  22: c2fb5b5c-0ea4-427b-b30d-1999d5918336 Optimization terminated          NA
#>  23: ecd3a694-a326-45df-b445-d6c0ba54878c Optimization terminated          NA
#>  24: 49c7502e-e40e-46b7-b0e7-697a01be9b45 Optimization terminated          NA
#>  25: 53f279e6-514b-4210-bf2e-dc1563a773ee Optimization terminated          NA
#>  26: 7d175655-fd73-4ed8-8e5c-1f8680645d1e Optimization terminated          NA
#>  27: 58ba8abc-7f58-425c-9ddf-b209ffe7aef1 Optimization terminated          NA
#>  28: 50fae3d0-15b6-45f8-94fd-91c2a9334ba6 Optimization terminated          NA
#>  29: 02fd7d09-8662-4898-941e-b476de1fab16 Optimization terminated          NA
#>  30: 804184d5-6bee-4061-8357-6eda56dd49bf Optimization terminated          NA
#>  31: 26dacc82-22ae-45d1-b8d6-d73bb0e1cb12 Optimization terminated          NA
#>  32: 7311ddd8-7539-4dc2-8ab0-dcfb360769c8 Optimization terminated          NA
#>  33: da8aff85-8e80-496d-bf56-92a439a3cfd8 Optimization terminated          NA
#>  34: 5a18fd21-475b-4421-9d0a-fc2497f41f00 Optimization terminated          NA
#>  35: 5454859d-5569-4a0b-9a76-db03444cc4f9 Optimization terminated          NA
#>  36: 8a7dbd30-a2d2-417a-9b64-4baea14c3e46 Optimization terminated          NA
#>  37: a0064956-fa9e-4ca5-978f-c84eab2a21ee Optimization terminated          NA
#>  38: 347c0424-3726-4216-b1f7-d3c1ee2b9485 Optimization terminated          NA
#>  39: 50ba9444-5362-4c2b-b4a6-23489fcaea62 Optimization terminated          NA
#>  40: 9a8da447-a6e3-494f-b703-81e20d6191ac Optimization terminated          NA
#>  41: 189a9061-66a0-489c-bd56-5d9959ce9c9e Optimization terminated          NA
#>  42: 3097ba2f-1b96-4748-b7dd-747d3d8e9800 Optimization terminated          NA
#>  43: a59ad5c5-2bb5-4b84-b0d1-76b5ba363628 Optimization terminated          NA
#>  44: e1e8e7a0-bd81-437b-b937-0c9f08484321 Optimization terminated          NA
#>  45: d4d7c661-15c4-4a13-acf8-12025a83be01 Optimization terminated          NA
#>  46: a81571db-e4ae-418b-a1f9-10a23bdd7878 Optimization terminated          NA
#>  47: a59f3a48-2106-4181-9a94-00d9fec3ec54 Optimization terminated          NA
#>  48: 7606e9fb-e536-4245-bdd5-14841bbe6682 Optimization terminated          NA
#>  49: 6752bcc3-7a52-4d8e-b43c-a8dd1de797ca Optimization terminated          NA
#>  50: 0b6424e6-9aa5-4629-a50c-c2b1bd9dc144 Optimization terminated          NA
#>  51: c0464b6f-3ccb-4aee-be21-e31f1195c28c Optimization terminated          NA
#>  52: dbff9c89-910e-421a-b3c5-bd2afdb28068 Optimization terminated          NA
#>  53: 666afd9d-9b90-4d18-85cb-af3530750586 Optimization terminated          NA
#>  54: ce58e604-5512-4d76-a76c-b7374abe5af5 Optimization terminated          NA
#>  55: 327878a6-394f-4f4e-a9b0-7973ee5c19db Optimization terminated          NA
#>  56: bbc756c4-7ba1-479c-9f46-f4647a5e0246 Optimization terminated          NA
#>  57: 3b5a1803-d808-48be-befe-e54e5d13f15b Optimization terminated          NA
#>  58: 783e6d6f-7814-4b7a-8dc5-caab35824dd6 Optimization terminated          NA
#>  59: 29592378-5c8a-4b13-aaf9-8b8376dcb1af Optimization terminated          NA
#>  60: de3cf803-99b5-4a8c-a56a-d838f5bd683f Optimization terminated          NA
#>  61: 5ec38398-1c5c-4e3b-bc36-25ebcda9b217 Optimization terminated          NA
#>  62: 128bb94a-5589-4e2d-9e9a-19a2b03cfffe Optimization terminated          NA
#>  63: 1e141b06-38ae-4004-a260-9208e7f33a55 Optimization terminated          NA
#>  64: e8cbfc6d-ffe2-412f-90fe-ee7107f093a1 Optimization terminated          NA
#>  65: 4d906cc4-172e-468b-b5f7-b080a8582769 Optimization terminated          NA
#>  66: 7421aba9-4ca2-4cfc-a054-d98868293d94 Optimization terminated          NA
#>  67: aa3eff7f-9b58-4d83-bb55-9e4da4126348 Optimization terminated          NA
#>  68: 031dd70c-b773-48fb-bff7-89058b011455 Optimization terminated          NA
#>  69: f8d7141c-5631-412a-bdc2-cce9c7a17447 Optimization terminated          NA
#>  70: 14f6e451-f833-451b-8151-9f8464cf0805 Optimization terminated          NA
#>  71: d1f5d935-c075-4d7a-8050-6ab566a15380 Optimization terminated          NA
#>  72: a6e97a6d-593e-4b1a-b9e2-a4ddd48ccbc8 Optimization terminated          NA
#>  73: d343ce9a-ad85-423d-ad78-d19122dcafcb Optimization terminated          NA
#>  74: 779baced-0b04-4af6-baf7-ec75b21a56d0 Optimization terminated          NA
#>  75: be3f3e67-0b8a-4982-a957-70bf6193093a Optimization terminated          NA
#>  76: 1b1f5f1d-1737-4ec3-9c1c-e6c2203c3119 Optimization terminated          NA
#>  77: fea55754-2b92-48d0-886f-f143ec2a0bbc Optimization terminated          NA
#>  78: 58ee6278-7e81-4f40-ab34-f78a02f0df94 Optimization terminated          NA
#>  79: cdd0b9b4-6ab6-44b5-ae75-1b3b8d56d2ce Optimization terminated          NA
#>  80: 978ae54a-ab51-4f0c-902f-17a9c1ac09f7 Optimization terminated          NA
#>  81: 5b0fafdc-466d-483c-8d91-27e1d092529f Optimization terminated          NA
#>  82: debb341a-d65c-4cbc-b47c-eca98ceab1c0 Optimization terminated          NA
#>  83: 645d1495-dda0-4c08-a075-fbe014419425 Optimization terminated          NA
#>  84: 71ab5588-a5f3-402d-973d-a9d34fa9f62b Optimization terminated          NA
#>  85: 88269027-2539-4117-b6c0-b12e75122d23 Optimization terminated          NA
#>  86: e2b4461e-5d0b-482a-a7e8-01bafb58a177 Optimization terminated          NA
#>  87: 1d4c184d-2822-4a01-9e4e-e8ee36549939 Optimization terminated          NA
#>  88: 4680c47d-a548-4d27-ae07-44d7efd632a4 Optimization terminated          NA
#>  89: 54107483-4ac6-4dff-b60e-51d989b68a66 Optimization terminated          NA
#>  90: 61d31b09-c4f9-4213-9f0f-fa5b8ff3a029 Optimization terminated          NA
#>  91: aac0d642-efa3-48e5-abf8-0649a55ac3df Optimization terminated          NA
#>  92: 82e6826b-d36e-495a-8af0-9b022d737305 Optimization terminated          NA
#>  93: 61f4f1e5-c798-4da6-a78a-3ce1102a3f5c Optimization terminated          NA
#>  94: 0cc9a68f-4819-498e-85e9-349a142e5dc0 Optimization terminated          NA
#>  95: 4557dac6-082c-4a0d-8861-dd0916704011 Optimization terminated          NA
#>  96: 8750bd4e-ac03-4403-8376-f2142a6897b2 Optimization terminated          NA
#>  97: 190c7fa8-2de2-44c9-a943-48a5cd968c9c Optimization terminated          NA
#>  98: f397e5a0-8cd7-470f-a250-0584a7372fe4 Optimization terminated          NA
#>  99: e1f0561a-a25a-4799-ac62-c6ee16a84a7c Optimization terminated          NA
#> 100: 26494c90-5a3c-4952-8882-5ac2ad96d785 Optimization terminated          NA
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
