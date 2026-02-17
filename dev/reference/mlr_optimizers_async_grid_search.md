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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-02-17 15:05:13 14679
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-02-17 15:05:13 14679
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-02-17 15:05:13 14679
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-02-17 15:05:13 14679
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-02-17 15:05:13 14679
#>   6: finished -10.000000  0.5555556 -146.64198 2026-02-17 15:05:13 14679
#>   7: finished -10.000000  1.6666667 -155.77778 2026-02-17 15:05:13 14679
#>   8: finished -10.000000  2.7777778 -167.38272 2026-02-17 15:05:13 14679
#>   9: finished -10.000000  3.8888889 -181.45679 2026-02-17 15:05:13 14679
#>  10: finished -10.000000  5.0000000 -198.00000 2026-02-17 15:05:13 14679
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-02-17 15:05:13 14679
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-02-17 15:05:13 14679
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-02-17 15:05:13 14679
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-02-17 15:05:13 14679
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-02-17 15:05:13 14679
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-02-17 15:05:13 14679
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-02-17 15:05:13 14679
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-02-17 15:05:13 14679
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-02-17 15:05:13 14679
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-02-17 15:05:13 14679
#>  21:   failed  10.000000  5.0000000         NA 2026-02-17 15:05:13    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-02-17 15:05:13    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-02-17 15:05:13    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-02-17 15:05:13    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-02-17 15:05:13    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-02-17 15:05:13    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-02-17 15:05:13    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-02-17 15:05:13    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-02-17 15:05:13    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-02-17 15:05:13    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-02-17 15:05:13    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-02-17 15:05:13    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-02-17 15:05:13    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-02-17 15:05:13    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-02-17 15:05:13    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-02-17 15:05:13    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-02-17 15:05:13    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-02-17 15:05:13    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-02-17 15:05:13    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-02-17 15:05:13    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-02-17 15:05:13    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-02-17 15:05:13    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-02-17 15:05:13    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-02-17 15:05:13    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-02-17 15:05:13    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-02-17 15:05:13    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-02-17 15:05:13    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-02-17 15:05:13    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-02-17 15:05:13    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-02-17 15:05:13    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-02-17 15:05:13    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-02-17 15:05:13    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-02-17 15:05:13    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-02-17 15:05:13    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-02-17 15:05:13    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-02-17 15:05:13    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-02-17 15:05:13    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-02-17 15:05:13    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-02-17 15:05:13    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-02-17 15:05:13    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-02-17 15:05:13    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-02-17 15:05:13    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-02-17 15:05:13    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-02-17 15:05:13    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-02-17 15:05:13    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-02-17 15:05:13    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-02-17 15:05:13    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-02-17 15:05:14
#>   2: academical_guineapig 2026-02-17 15:05:14
#>   3: academical_guineapig 2026-02-17 15:05:14
#>   4: academical_guineapig 2026-02-17 15:05:14
#>   5: academical_guineapig 2026-02-17 15:05:14
#>   6: academical_guineapig 2026-02-17 15:05:14
#>   7: academical_guineapig 2026-02-17 15:05:14
#>   8: academical_guineapig 2026-02-17 15:05:14
#>   9: academical_guineapig 2026-02-17 15:05:14
#>  10: academical_guineapig 2026-02-17 15:05:14
#>  11: academical_guineapig 2026-02-17 15:05:14
#>  12: academical_guineapig 2026-02-17 15:05:14
#>  13: academical_guineapig 2026-02-17 15:05:14
#>  14: academical_guineapig 2026-02-17 15:05:14
#>  15: academical_guineapig 2026-02-17 15:05:14
#>  16: academical_guineapig 2026-02-17 15:05:14
#>  17: academical_guineapig 2026-02-17 15:05:14
#>  18: academical_guineapig 2026-02-17 15:05:14
#>  19: academical_guineapig 2026-02-17 15:05:14
#>  20: academical_guineapig 2026-02-17 15:05:14
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
#>   1: 63dc0958-f59b-4a46-b1e8-fdbfa56ccdd4                    <NA>  -10.000000
#>   2: a9056a15-2e55-4363-8c86-20a141198a51                    <NA>  -10.000000
#>   3: 8cbd6322-de98-4322-bf1b-f930e92bae33                    <NA>  -10.000000
#>   4: 24aa8c14-0b3c-4b70-993a-6454fa82cf52                    <NA>  -10.000000
#>   5: 2823786c-caeb-4787-9909-0ec1d789c8ed                    <NA>  -10.000000
#>   6: 03637c88-b120-497c-bbe1-e13d34afb22d                    <NA>  -10.000000
#>   7: 7089d86f-c9ed-49d7-aab5-e50a8eaeb059                    <NA>  -10.000000
#>   8: 8ca2e57b-241e-473d-a9f9-49c6b484468d                    <NA>  -10.000000
#>   9: 64e538fd-dd76-4d34-a197-e4316d7e2acb                    <NA>  -10.000000
#>  10: 6130cd78-9409-47c8-8ed3-06f379e0f4ef                    <NA>  -10.000000
#>  11: ce938321-4b46-4fd0-844c-0561861bbdb3                    <NA>   -7.777778
#>  12: 3980e508-4907-4cf1-a5b5-528b2456a072                    <NA>   -7.777778
#>  13: 0420fc07-a2ca-4b86-abee-fb1c2e6d0151                    <NA>   -7.777778
#>  14: 8a4e44d3-0e9d-45bb-89d5-02ff4a2627d9                    <NA>   -7.777778
#>  15: e8c0a842-95e1-41ba-9db6-20390556bead                    <NA>   -7.777778
#>  16: fbd3d140-cc39-49ec-94e5-0c546961e478                    <NA>   -7.777778
#>  17: 24eca1a7-9f6d-4dea-b4f3-bf291846ac1a                    <NA>   -7.777778
#>  18: b3f513fe-fd57-4aab-9155-3ccb6f96e8a0                    <NA>   -7.777778
#>  19: 603543e3-765d-4e78-87f9-801b4b4707c5                    <NA>   -7.777778
#>  20: 8dc89728-e882-4d51-91ff-2cd1b69af2fa                    <NA>   -7.777778
#>  21: c5a7e646-eb14-4ad2-9f65-814f1f804857 Optimization terminated          NA
#>  22: 50dec79c-6029-4bdc-8ed7-723fa42ef67f Optimization terminated          NA
#>  23: 41c44382-24f4-4dfb-9c56-ba554fab5e16 Optimization terminated          NA
#>  24: c706ae21-b28b-42ae-a6d5-6d4083441597 Optimization terminated          NA
#>  25: c1aa5944-9feb-404c-849d-ab113b07c0b5 Optimization terminated          NA
#>  26: 9a028a8a-d670-4153-9e3f-058f56c6d71c Optimization terminated          NA
#>  27: 346ba325-8660-4dd7-8d0f-ffc556e61ea6 Optimization terminated          NA
#>  28: e06b2525-e9f9-4785-9ac3-e0b92c23ed22 Optimization terminated          NA
#>  29: 8bd716d7-9cc2-4111-bbf5-25164e493eb1 Optimization terminated          NA
#>  30: c96da842-eaa4-49ba-a62b-9901d3ffeb72 Optimization terminated          NA
#>  31: 9e67083a-8516-4836-bfd4-dca50f059334 Optimization terminated          NA
#>  32: 6598fbc8-db03-4dd6-ad3e-7c199b6151d2 Optimization terminated          NA
#>  33: b56d7699-8007-4a44-93b0-2685d6234167 Optimization terminated          NA
#>  34: 3a0c0192-eda9-4510-a81a-b343b76aa76d Optimization terminated          NA
#>  35: dcd1c367-c1f9-4989-a242-39bd5eec3cca Optimization terminated          NA
#>  36: 5f97c1fa-46c0-4a81-ab1e-8fd96a5ed815 Optimization terminated          NA
#>  37: 59b3b7de-2ff6-4e7a-ac89-0c57438180c1 Optimization terminated          NA
#>  38: 4656499b-5b43-4f7f-949b-ed7aaf02bf04 Optimization terminated          NA
#>  39: 6107f627-8bf3-41e8-a644-744c32690dcc Optimization terminated          NA
#>  40: 2a453414-774f-4db8-a812-b78d5d7ad822 Optimization terminated          NA
#>  41: 6370eecb-2b92-4d97-bd5e-636f19d34a5c Optimization terminated          NA
#>  42: 1cbd0268-d87d-46d9-9875-d0cf5db5ef3a Optimization terminated          NA
#>  43: bd7b8b39-556a-4f4b-b76e-1bfa38c70fc4 Optimization terminated          NA
#>  44: 1f762dc4-ad95-49ab-bcd7-0c588a471192 Optimization terminated          NA
#>  45: ca011e35-998b-4635-a477-db337f1da5bf Optimization terminated          NA
#>  46: 067e0e2c-8cae-4806-a6be-084bf5b09654 Optimization terminated          NA
#>  47: 7004eb71-b5c3-44dc-8bec-d16c06045e15 Optimization terminated          NA
#>  48: eeaa138a-c5dd-45f0-9b51-f24a3aa03fe4 Optimization terminated          NA
#>  49: 4455b508-29eb-4c99-ab73-36f47f6f16e7 Optimization terminated          NA
#>  50: 41f2798c-9154-4371-93d8-e7bcddd6f3d6 Optimization terminated          NA
#>  51: f4e7e34a-f232-4b47-bbe2-64147d652853 Optimization terminated          NA
#>  52: f17400ad-fc94-4683-b63e-43eb49dc09b1 Optimization terminated          NA
#>  53: 9250314e-d43a-4aae-a2b6-6d0a1ef2e68c Optimization terminated          NA
#>  54: c2847cfa-4f62-4ea8-9de4-2139650e44d8 Optimization terminated          NA
#>  55: 906147d7-efa6-4a0a-9c62-a8115b2b8f60 Optimization terminated          NA
#>  56: 0a21ac6c-8c41-4828-a21e-6f1b97317ce9 Optimization terminated          NA
#>  57: a8233a94-1ab9-4fa9-b5c7-c53e0f568395 Optimization terminated          NA
#>  58: 96b6bace-a764-4df7-b01c-1b22ff667028 Optimization terminated          NA
#>  59: ce92454f-6e7c-4667-a1a7-e456afe294f6 Optimization terminated          NA
#>  60: 39324767-57cd-435b-a78e-b80a62babeec Optimization terminated          NA
#>  61: eaa4994a-9af9-4534-a4e6-82ec7700735e Optimization terminated          NA
#>  62: 3d6335d5-6160-4467-aa25-9b8a1ead54c1 Optimization terminated          NA
#>  63: 41de2e8c-1386-491a-a6cc-233fd58a812c Optimization terminated          NA
#>  64: 8b424370-ed54-44f0-87c1-4577681ada32 Optimization terminated          NA
#>  65: d3b0c50b-3a9e-4240-9dc1-c5e46c23c2bb Optimization terminated          NA
#>  66: 9dafb879-12ba-4a6b-b30d-1d305dbb4158 Optimization terminated          NA
#>  67: 74002e66-63b0-4d0a-9085-e2e4e38edf76 Optimization terminated          NA
#>  68: d5d17221-9c5f-4bfc-a56c-23e63807e850 Optimization terminated          NA
#>  69: bf8fb0a8-2dc7-4565-a68e-41bd77974413 Optimization terminated          NA
#>  70: c22a003d-275d-427b-b9ae-8f45033eacd2 Optimization terminated          NA
#>  71: 5b3542d8-8fd9-4a49-8ecd-dc2b50ef08f5 Optimization terminated          NA
#>  72: e356b232-9f39-416f-bf06-860ab22a9563 Optimization terminated          NA
#>  73: dcc1c59d-a818-40eb-8f13-2061ac008684 Optimization terminated          NA
#>  74: 3b300376-a8f4-4887-b588-dd7d59d78336 Optimization terminated          NA
#>  75: 6e5039a8-342a-4e17-9229-e66bcaa65b9d Optimization terminated          NA
#>  76: 25b62694-a32a-4009-8dc0-bc057aea8ed2 Optimization terminated          NA
#>  77: 5984e4e8-7453-49cb-b486-361d86c6bbda Optimization terminated          NA
#>  78: 7db4930b-e268-4afa-b001-a1c73ff740fd Optimization terminated          NA
#>  79: 2f5fb414-ab49-4eee-bb2d-8c1b997f9830 Optimization terminated          NA
#>  80: 8b720286-7fe2-409a-b305-8e6b94a6c332 Optimization terminated          NA
#>  81: cf5ae378-770f-4ace-a506-23b09d9c7b71 Optimization terminated          NA
#>  82: 98c1cf2a-330a-4845-b893-a1d527df7faf Optimization terminated          NA
#>  83: c6e668a0-a15a-47a7-9bdb-7e8da958b1f7 Optimization terminated          NA
#>  84: 21c5be70-a4cc-44b3-bf8e-4036a53ca64f Optimization terminated          NA
#>  85: 175a57f9-7a5d-4bf5-99e8-8e2da7ed84f9 Optimization terminated          NA
#>  86: 9bea90b2-9d41-415c-a18f-145ccab2fdc4 Optimization terminated          NA
#>  87: c01d7ee9-9099-491e-abe6-1f9924a97b37 Optimization terminated          NA
#>  88: 4173b5ca-5d2b-42ae-b895-0ca45cf13309 Optimization terminated          NA
#>  89: 94ec9dd0-03cb-483f-8905-ec1be097eecd Optimization terminated          NA
#>  90: 13d77a0b-a953-4bc7-8ddb-58d8d39540bf Optimization terminated          NA
#>  91: 7fd20efa-34c7-4ee5-9040-5bfce5a38186 Optimization terminated          NA
#>  92: 2865afd5-fe9d-4213-8b30-a151b7a601fb Optimization terminated          NA
#>  93: c5bc5777-e378-4c81-9f7d-710539c6b828 Optimization terminated          NA
#>  94: 44a22021-b283-4c2d-8b74-26ba83460adb Optimization terminated          NA
#>  95: a98731e1-803b-4d61-85b2-3f2320e7cbb5 Optimization terminated          NA
#>  96: 05816cf4-dc77-4b6b-9b26-cd0aa823be01 Optimization terminated          NA
#>  97: 1e88c781-3ba8-4051-b939-37d1c349283e Optimization terminated          NA
#>  98: b5b72e2a-7b30-4534-a157-4fb518574855 Optimization terminated          NA
#>  99: 581d98b9-5520-4b07-a14e-b245eadfc663 Optimization terminated          NA
#> 100: c2154820-ad8b-49af-a96f-9391dc103cf4 Optimization terminated          NA
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
