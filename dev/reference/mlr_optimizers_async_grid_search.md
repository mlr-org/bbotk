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
#>   1: finished -10.000000 -5.0000000 -138.00000 2025-11-21 18:13:55 28691
#>   2: finished -10.000000 -3.8888889 -134.79012 2025-11-21 18:13:55 28691
#>   3: finished -10.000000 -2.7777778 -134.04938 2025-11-21 18:13:55 28691
#>   4: finished -10.000000 -1.6666667 -135.77778 2025-11-21 18:13:55 28691
#>   5: finished -10.000000 -0.5555556 -139.97531 2025-11-21 18:13:55 28691
#>   6: finished -10.000000  0.5555556 -146.64198 2025-11-21 18:13:55 28691
#>   7: finished -10.000000  1.6666667 -155.77778 2025-11-21 18:13:55 28691
#>   8: finished -10.000000  2.7777778 -167.38272 2025-11-21 18:13:55 28691
#>   9: finished -10.000000  3.8888889 -181.45679 2025-11-21 18:13:55 28691
#>  10: finished -10.000000  5.0000000 -198.00000 2025-11-21 18:13:55 28691
#>  11: finished  -7.777778 -5.0000000  -89.60494 2025-11-21 18:13:55 28691
#>  12: finished  -7.777778 -3.8888889  -86.39506 2025-11-21 18:13:55 28691
#>  13: finished  -7.777778 -2.7777778  -85.65432 2025-11-21 18:13:55 28691
#>  14: finished  -7.777778 -1.6666667  -87.38272 2025-11-21 18:13:55 28691
#>  15: finished  -7.777778 -0.5555556  -91.58025 2025-11-21 18:13:55 28691
#>  16: finished  -7.777778  0.5555556  -98.24691 2025-11-21 18:13:55 28691
#>  17: finished  -7.777778  1.6666667 -107.38272 2025-11-21 18:13:55 28691
#>  18: finished  -7.777778  2.7777778 -118.98765 2025-11-21 18:13:55 28691
#>  19: finished  -7.777778  3.8888889 -133.06173 2025-11-21 18:13:55 28691
#>  20: finished  -7.777778  5.0000000 -149.60494 2025-11-21 18:13:55 28691
#>  21:   failed  10.000000  5.0000000         NA 2025-11-21 18:13:55    NA
#>  22:   failed  10.000000  3.8888889         NA 2025-11-21 18:13:55    NA
#>  23:   failed  10.000000  2.7777778         NA 2025-11-21 18:13:55    NA
#>  24:   failed  10.000000  1.6666667         NA 2025-11-21 18:13:55    NA
#>  25:   failed  10.000000  0.5555556         NA 2025-11-21 18:13:55    NA
#>  26:   failed  10.000000 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  27:   failed  10.000000 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  28:   failed  10.000000 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  29:   failed  10.000000 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  30:   failed  10.000000 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  31:   failed   7.777778  5.0000000         NA 2025-11-21 18:13:55    NA
#>  32:   failed   7.777778  3.8888889         NA 2025-11-21 18:13:55    NA
#>  33:   failed   7.777778  2.7777778         NA 2025-11-21 18:13:55    NA
#>  34:   failed   7.777778  1.6666667         NA 2025-11-21 18:13:55    NA
#>  35:   failed   7.777778  0.5555556         NA 2025-11-21 18:13:55    NA
#>  36:   failed   7.777778 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  37:   failed   7.777778 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  38:   failed   7.777778 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  39:   failed   7.777778 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  40:   failed   7.777778 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  41:   failed   5.555556  5.0000000         NA 2025-11-21 18:13:55    NA
#>  42:   failed   5.555556  3.8888889         NA 2025-11-21 18:13:55    NA
#>  43:   failed   5.555556  2.7777778         NA 2025-11-21 18:13:55    NA
#>  44:   failed   5.555556  1.6666667         NA 2025-11-21 18:13:55    NA
#>  45:   failed   5.555556  0.5555556         NA 2025-11-21 18:13:55    NA
#>  46:   failed   5.555556 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  47:   failed   5.555556 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  48:   failed   5.555556 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  49:   failed   5.555556 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  50:   failed   5.555556 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  51:   failed   3.333333  5.0000000         NA 2025-11-21 18:13:55    NA
#>  52:   failed   3.333333  3.8888889         NA 2025-11-21 18:13:55    NA
#>  53:   failed   3.333333  2.7777778         NA 2025-11-21 18:13:55    NA
#>  54:   failed   3.333333  1.6666667         NA 2025-11-21 18:13:55    NA
#>  55:   failed   3.333333  0.5555556         NA 2025-11-21 18:13:55    NA
#>  56:   failed   3.333333 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  57:   failed   3.333333 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  58:   failed   3.333333 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  59:   failed   3.333333 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  60:   failed   3.333333 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  61:   failed   1.111111  5.0000000         NA 2025-11-21 18:13:55    NA
#>  62:   failed   1.111111  3.8888889         NA 2025-11-21 18:13:55    NA
#>  63:   failed   1.111111  2.7777778         NA 2025-11-21 18:13:55    NA
#>  64:   failed   1.111111  1.6666667         NA 2025-11-21 18:13:55    NA
#>  65:   failed   1.111111  0.5555556         NA 2025-11-21 18:13:55    NA
#>  66:   failed   1.111111 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  67:   failed   1.111111 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  68:   failed   1.111111 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  69:   failed   1.111111 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  70:   failed   1.111111 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  71:   failed  -1.111111  5.0000000         NA 2025-11-21 18:13:55    NA
#>  72:   failed  -1.111111  3.8888889         NA 2025-11-21 18:13:55    NA
#>  73:   failed  -1.111111  2.7777778         NA 2025-11-21 18:13:55    NA
#>  74:   failed  -1.111111  1.6666667         NA 2025-11-21 18:13:55    NA
#>  75:   failed  -1.111111  0.5555556         NA 2025-11-21 18:13:55    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  81:   failed  -3.333333  5.0000000         NA 2025-11-21 18:13:55    NA
#>  82:   failed  -3.333333  3.8888889         NA 2025-11-21 18:13:55    NA
#>  83:   failed  -3.333333  2.7777778         NA 2025-11-21 18:13:55    NA
#>  84:   failed  -3.333333  1.6666667         NA 2025-11-21 18:13:55    NA
#>  85:   failed  -3.333333  0.5555556         NA 2025-11-21 18:13:55    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2025-11-21 18:13:55    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2025-11-21 18:13:55    NA
#>  91:   failed  -5.555556  5.0000000         NA 2025-11-21 18:13:55    NA
#>  92:   failed  -5.555556  3.8888889         NA 2025-11-21 18:13:55    NA
#>  93:   failed  -5.555556  2.7777778         NA 2025-11-21 18:13:55    NA
#>  94:   failed  -5.555556  1.6666667         NA 2025-11-21 18:13:55    NA
#>  95:   failed  -5.555556  0.5555556         NA 2025-11-21 18:13:55    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2025-11-21 18:13:55    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2025-11-21 18:13:55    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2025-11-21 18:13:55    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2025-11-21 18:13:55    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2025-11-21 18:13:55    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2025-11-21 18:13:56
#>   2: academical_guineapig 2025-11-21 18:13:56
#>   3: academical_guineapig 2025-11-21 18:13:56
#>   4: academical_guineapig 2025-11-21 18:13:56
#>   5: academical_guineapig 2025-11-21 18:13:56
#>   6: academical_guineapig 2025-11-21 18:13:56
#>   7: academical_guineapig 2025-11-21 18:13:56
#>   8: academical_guineapig 2025-11-21 18:13:56
#>   9: academical_guineapig 2025-11-21 18:13:56
#>  10: academical_guineapig 2025-11-21 18:13:56
#>  11: academical_guineapig 2025-11-21 18:13:56
#>  12: academical_guineapig 2025-11-21 18:13:56
#>  13: academical_guineapig 2025-11-21 18:13:56
#>  14: academical_guineapig 2025-11-21 18:13:56
#>  15: academical_guineapig 2025-11-21 18:13:56
#>  16: academical_guineapig 2025-11-21 18:13:56
#>  17: academical_guineapig 2025-11-21 18:13:56
#>  18: academical_guineapig 2025-11-21 18:13:56
#>  19: academical_guineapig 2025-11-21 18:13:56
#>  20: academical_guineapig 2025-11-21 18:13:56
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
#>   1: a6947e47-f4ed-4ad0-8f4c-8781fc3a1cbc                    <NA>  -10.000000
#>   2: 02b87092-f5d2-4131-b7dd-ad7b9e259dee                    <NA>  -10.000000
#>   3: a02cecb1-635c-47a6-a8a3-d4036b7c22c0                    <NA>  -10.000000
#>   4: 670f401e-f2b9-420a-b7f5-867e3dc91058                    <NA>  -10.000000
#>   5: 1cff437a-8043-49eb-b196-55225fb7a011                    <NA>  -10.000000
#>   6: 02b6f278-183e-4067-a5ca-fd76f18c2a47                    <NA>  -10.000000
#>   7: c71533a6-0f14-4675-87ee-397abba599f3                    <NA>  -10.000000
#>   8: 96d6fa0e-58d3-4a0a-a5d7-1d13fb79477b                    <NA>  -10.000000
#>   9: 26b6b199-748a-43ec-aab0-6f2299bbf253                    <NA>  -10.000000
#>  10: 193d6015-821c-45f7-9698-9d5b1ce2a993                    <NA>  -10.000000
#>  11: b48949bb-6fd4-4265-afad-fa3f03afe0de                    <NA>   -7.777778
#>  12: d77b2b6b-6f4f-4b48-9341-08c351ad2286                    <NA>   -7.777778
#>  13: 464af14f-95d1-4220-abcd-156c2bd5f8c5                    <NA>   -7.777778
#>  14: 0243d4af-9cf0-4b7d-9a98-4d9f33466a2f                    <NA>   -7.777778
#>  15: 76da6149-a5ce-4d1d-824a-b9f5089a4f61                    <NA>   -7.777778
#>  16: 8010ca90-30ef-41eb-bde2-afa20ed82776                    <NA>   -7.777778
#>  17: d94d25a6-7adf-4ae0-b4db-f0a9c6e6d652                    <NA>   -7.777778
#>  18: a813a9c7-bf3b-4c3b-b59e-b20a320edc99                    <NA>   -7.777778
#>  19: 94e7f52f-791c-4562-9bd7-2c5beb9df1ad                    <NA>   -7.777778
#>  20: fa019b03-01ed-48f5-a82b-ffe44a36097f                    <NA>   -7.777778
#>  21: 82af287b-873c-4e20-9d00-695a8211c413 Optimization terminated          NA
#>  22: 340ae5a9-7e43-4d69-8b44-39aeb536825c Optimization terminated          NA
#>  23: 740d7697-fc0e-4c23-a69f-dcfa9ef9347f Optimization terminated          NA
#>  24: 979dde17-622c-4014-9196-5b9ee1d0befe Optimization terminated          NA
#>  25: c4effa3c-faed-4865-b21b-890129d45b00 Optimization terminated          NA
#>  26: db2cf78b-2146-4c65-a17d-5d199cb72bb0 Optimization terminated          NA
#>  27: b000d076-749f-430a-ab9b-a9f0b3aa14a0 Optimization terminated          NA
#>  28: 61f90203-8e73-483d-a6ce-e57ea4607dcb Optimization terminated          NA
#>  29: 5b13b8f0-d716-458f-8cc1-879a15bab1b5 Optimization terminated          NA
#>  30: 4eea2002-8feb-472f-b85e-2eda6318002d Optimization terminated          NA
#>  31: 0cb47059-9913-4fff-9b1f-a1e3fac390c6 Optimization terminated          NA
#>  32: 33ac12e2-dff1-448b-9ecd-984fb64a148d Optimization terminated          NA
#>  33: ab288a98-4f46-4531-ae10-32331c27e928 Optimization terminated          NA
#>  34: d3f46171-0256-4cf0-8c4e-d8b579d00597 Optimization terminated          NA
#>  35: ed97707c-d80e-4b04-bee2-f668a169b589 Optimization terminated          NA
#>  36: e54a6a2a-3bb5-4c94-ab0f-38d509c68a24 Optimization terminated          NA
#>  37: 60146b21-a031-4ef7-bf7e-5ae8c9ad71df Optimization terminated          NA
#>  38: bd5a57f2-19c9-452d-808d-c6504d8e61b6 Optimization terminated          NA
#>  39: b6812525-e61e-4709-991e-bb6b2f2f9ea8 Optimization terminated          NA
#>  40: d9405ed0-c1b5-4fa5-8a24-0b36bf6276df Optimization terminated          NA
#>  41: 5e88952e-38bb-45b0-a8de-ce93c01f55c3 Optimization terminated          NA
#>  42: e3bf6ad6-9ed5-4203-b269-447afadcfda0 Optimization terminated          NA
#>  43: 6dc8663b-fd96-4297-b43f-dae6dc025672 Optimization terminated          NA
#>  44: b1ff6925-5d92-4257-801c-b760f6946860 Optimization terminated          NA
#>  45: f4023491-2f07-4463-9833-385dd3195a66 Optimization terminated          NA
#>  46: de4cb39d-4e4a-426a-95e2-456a33ce9351 Optimization terminated          NA
#>  47: 63b36dfd-f757-4938-b992-57d001ec0f75 Optimization terminated          NA
#>  48: b09333a8-1cd7-4d9b-b9cf-7fc42961c9c1 Optimization terminated          NA
#>  49: 7d049f12-3f09-40b7-8326-9025467068d7 Optimization terminated          NA
#>  50: df3e2e22-c6a5-4579-b3fc-1460a0312524 Optimization terminated          NA
#>  51: 27e4d892-ce39-49e1-973d-e043cf0cc9ac Optimization terminated          NA
#>  52: ad984743-3e42-41d9-8960-c814f420b21a Optimization terminated          NA
#>  53: c9270d89-8aad-4d33-8e63-6df0ff04fe99 Optimization terminated          NA
#>  54: 0b91b2b1-34db-4fb4-bf70-57da2a44c12e Optimization terminated          NA
#>  55: a16e43e1-41d1-4c67-93e5-ac0a348847c6 Optimization terminated          NA
#>  56: cc876595-68dc-4ddf-b2f3-654a381c21e1 Optimization terminated          NA
#>  57: b20c91e9-2eca-42a9-86d2-855028279436 Optimization terminated          NA
#>  58: 27f6d7cf-cb82-4f3f-8502-f86c280785fa Optimization terminated          NA
#>  59: c22ed6e2-8077-4616-b578-97163f42fe39 Optimization terminated          NA
#>  60: 4de5e1a2-489f-4577-825f-ed0fe173b12a Optimization terminated          NA
#>  61: eba3a70a-c0fd-42ee-b27d-3995f4e3690c Optimization terminated          NA
#>  62: fe7f51a8-4f1a-403f-9225-941c4c95f31f Optimization terminated          NA
#>  63: 8570e7f7-84c8-486d-8e82-a3ad5d3445bf Optimization terminated          NA
#>  64: 25f3251e-d4be-4f72-862e-51e06823ca2b Optimization terminated          NA
#>  65: b5cabb7d-d985-4c66-bab8-c2c286a54c6c Optimization terminated          NA
#>  66: a6eb545b-7d4a-459e-94ef-b4ea60a08180 Optimization terminated          NA
#>  67: 33d541c2-36c0-45c1-9638-b7c1615f64ea Optimization terminated          NA
#>  68: a9da266b-a0b5-46ff-af52-39269cf4032b Optimization terminated          NA
#>  69: b85b3cd5-51e2-490b-ba7b-875b06a21eda Optimization terminated          NA
#>  70: b923d017-1be1-400b-a869-61c410b55cb0 Optimization terminated          NA
#>  71: 649db739-86a9-4084-bc49-d62404b6b814 Optimization terminated          NA
#>  72: e2dbb57a-15c0-4dcd-8275-d09e99ee8b06 Optimization terminated          NA
#>  73: c7ddd700-987c-4cc1-8f63-3e40de7109da Optimization terminated          NA
#>  74: 3f2d730b-2428-45a4-92c9-b9e3ee0666fd Optimization terminated          NA
#>  75: f4495d86-94c6-4693-831f-2b3effa94259 Optimization terminated          NA
#>  76: 60938178-a1d5-49bb-9277-0a42ecb531ac Optimization terminated          NA
#>  77: 0ec829dc-b8fa-48d3-bb19-be0a4fcacb89 Optimization terminated          NA
#>  78: 01d01b46-a25f-4474-ac0a-075c11cb782b Optimization terminated          NA
#>  79: f13182b8-bc9f-4a41-a222-954b17409091 Optimization terminated          NA
#>  80: 7c2f78d5-31f8-44b6-8cda-cb74530741cb Optimization terminated          NA
#>  81: 637fe554-deb7-4214-ab2a-cb8b5e97bf54 Optimization terminated          NA
#>  82: be33bea9-47fa-46c7-a90d-5ca3070ba1e8 Optimization terminated          NA
#>  83: d24549cf-70ba-473f-968b-c7ad1276f923 Optimization terminated          NA
#>  84: 57f4c48a-a681-453b-9024-7760a37d7c88 Optimization terminated          NA
#>  85: c6acd0e6-4e28-4a52-b1e0-67dfdf7aabcb Optimization terminated          NA
#>  86: 65262bd3-7d21-440c-b4c8-574643bc1a31 Optimization terminated          NA
#>  87: f74b08c0-c3dd-4b4a-841b-e66d307bbc21 Optimization terminated          NA
#>  88: 1deab7f8-e1db-467d-ac30-bd4c7b24488f Optimization terminated          NA
#>  89: 0f2d7a9f-2d55-4768-bc7b-4f9530d57ab3 Optimization terminated          NA
#>  90: c5b8d4b6-1ff6-47c1-93f0-5258452fb20a Optimization terminated          NA
#>  91: 64d1ab84-565d-4958-acd4-b7575a63d19c Optimization terminated          NA
#>  92: 6bccc236-d206-4f30-839b-3c8342b1c5f7 Optimization terminated          NA
#>  93: c5c3c82e-3541-407d-9fde-ac872bead2e4 Optimization terminated          NA
#>  94: 26b79df5-19c6-4908-a9b7-93ab26957b1b Optimization terminated          NA
#>  95: 527490b9-9efc-46eb-8dad-3aebe3ecb385 Optimization terminated          NA
#>  96: 4166103b-41fc-4673-b68d-5aa113e89c2b Optimization terminated          NA
#>  97: 10187538-216b-4069-8dba-4ff5be9fe346 Optimization terminated          NA
#>  98: a1ca9b23-f40b-42f2-a775-b2f40af90663 Optimization terminated          NA
#>  99: 2985c121-1cba-4ee3-83b0-270e7c77068c Optimization terminated          NA
#> 100: 32429c51-acb9-4233-b9c0-5623a72eeee3 Optimization terminated          NA
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
