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
rush::rush_plan(worker_type = "mirai")
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
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-20 06:19:23
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-20 06:19:23
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-20 06:19:23
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-20 06:19:23
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-20 06:19:23
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-20 06:19:23
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-20 06:19:23
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-20 06:19:23
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-20 06:19:23
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-20 06:19:23
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-20 06:19:23
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-20 06:19:23
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-20 06:19:23
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-20 06:19:23
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-20 06:19:23
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-20 06:19:23
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-20 06:19:23
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-20 06:19:23
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-20 06:19:23
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-20 06:19:23
#>  21:   failed  10.000000  5.0000000         NA 2026-03-20 06:19:23
#>  22:   failed  10.000000  3.8888889         NA 2026-03-20 06:19:23
#>  23:   failed  10.000000  2.7777778         NA 2026-03-20 06:19:23
#>  24:   failed  10.000000  1.6666667         NA 2026-03-20 06:19:23
#>  25:   failed  10.000000  0.5555556         NA 2026-03-20 06:19:23
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-20 06:19:23
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-20 06:19:23
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-20 06:19:23
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-20 06:19:23
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-20 06:19:23
#>  31:   failed   7.777778  5.0000000         NA 2026-03-20 06:19:23
#>  32:   failed   7.777778  3.8888889         NA 2026-03-20 06:19:23
#>  33:   failed   7.777778  2.7777778         NA 2026-03-20 06:19:23
#>  34:   failed   7.777778  1.6666667         NA 2026-03-20 06:19:23
#>  35:   failed   7.777778  0.5555556         NA 2026-03-20 06:19:23
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-20 06:19:23
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-20 06:19:23
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-20 06:19:23
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-20 06:19:23
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-20 06:19:23
#>  41:   failed   5.555556  5.0000000         NA 2026-03-20 06:19:23
#>  42:   failed   5.555556  3.8888889         NA 2026-03-20 06:19:23
#>  43:   failed   5.555556  2.7777778         NA 2026-03-20 06:19:23
#>  44:   failed   5.555556  1.6666667         NA 2026-03-20 06:19:23
#>  45:   failed   5.555556  0.5555556         NA 2026-03-20 06:19:23
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-20 06:19:23
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-20 06:19:23
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-20 06:19:23
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-20 06:19:23
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-20 06:19:23
#>  51:   failed   3.333333  5.0000000         NA 2026-03-20 06:19:23
#>  52:   failed   3.333333  3.8888889         NA 2026-03-20 06:19:23
#>  53:   failed   3.333333  2.7777778         NA 2026-03-20 06:19:23
#>  54:   failed   3.333333  1.6666667         NA 2026-03-20 06:19:23
#>  55:   failed   3.333333  0.5555556         NA 2026-03-20 06:19:23
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-20 06:19:23
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-20 06:19:23
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-20 06:19:23
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-20 06:19:23
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-20 06:19:23
#>  61:   failed   1.111111  5.0000000         NA 2026-03-20 06:19:23
#>  62:   failed   1.111111  3.8888889         NA 2026-03-20 06:19:23
#>  63:   failed   1.111111  2.7777778         NA 2026-03-20 06:19:23
#>  64:   failed   1.111111  1.6666667         NA 2026-03-20 06:19:23
#>  65:   failed   1.111111  0.5555556         NA 2026-03-20 06:19:23
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-20 06:19:23
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-20 06:19:23
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-20 06:19:23
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-20 06:19:23
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-20 06:19:23
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-20 06:19:23
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-20 06:19:23
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-20 06:19:23
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-20 06:19:23
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-20 06:19:23
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-20 06:19:23
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-20 06:19:23
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-20 06:19:23
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-20 06:19:23
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-20 06:19:23
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-20 06:19:23
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-20 06:19:23
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-20 06:19:23
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-20 06:19:23
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-20 06:19:23
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-20 06:19:23
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-20 06:19:23
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-20 06:19:23
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-20 06:19:23
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-20 06:19:23
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-20 06:19:23
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-20 06:19:23
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-20 06:19:23
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-20 06:19:23
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-20 06:19:23
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-20 06:19:23
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-20 06:19:23
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-20 06:19:23
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-20 06:19:23
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-20 06:19:23
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-20 06:19:24 9487bca8-a2cb-40b6-ab7a-2a562b4808ec
#>   2: sinking_raccoon 2026-03-20 06:19:24 972834d1-9eeb-47d4-8b46-555ae4190936
#>   3: sinking_raccoon 2026-03-20 06:19:24 e4eee9a6-f11f-4a44-81f2-03ead22744f9
#>   4: sinking_raccoon 2026-03-20 06:19:24 ef02f999-43b1-417b-afd6-21fe19375105
#>   5: sinking_raccoon 2026-03-20 06:19:24 ca444835-ef1e-423e-b838-77d5b5db384c
#>   6: sinking_raccoon 2026-03-20 06:19:24 84ba841f-0728-4567-ae45-b372d40f6945
#>   7: sinking_raccoon 2026-03-20 06:19:24 65bcc8ac-f5c9-4354-b923-5b1d8a92ab9b
#>   8: sinking_raccoon 2026-03-20 06:19:24 8a818e1c-270c-4470-91fa-7122e1e1a520
#>   9: sinking_raccoon 2026-03-20 06:19:24 bb596165-0d90-4b20-b357-b417db8b3c33
#>  10: sinking_raccoon 2026-03-20 06:19:24 c2d7005c-6226-4792-bbe6-d541bbec30a5
#>  11: sinking_raccoon 2026-03-20 06:19:24 2d2327d9-048f-4e48-9a07-ee026a27b874
#>  12: sinking_raccoon 2026-03-20 06:19:24 57be7d57-7091-4a6e-86f9-e8b19f7d55aa
#>  13: sinking_raccoon 2026-03-20 06:19:24 1e0649a4-1021-4459-a6a8-697ef993e3cd
#>  14: sinking_raccoon 2026-03-20 06:19:24 aee92e03-ef2c-46c3-b458-87f8b4c7db82
#>  15: sinking_raccoon 2026-03-20 06:19:24 c7add42a-f8c6-41fe-b40d-bc3589e3db50
#>  16: sinking_raccoon 2026-03-20 06:19:24 bf067ffa-54c6-416d-9893-77d947bd4b8c
#>  17: sinking_raccoon 2026-03-20 06:19:24 af031b4f-ccc4-4d84-898f-5b142e7e1bbe
#>  18: sinking_raccoon 2026-03-20 06:19:24 1b63c33f-5a6d-4929-a943-68d00997683c
#>  19: sinking_raccoon 2026-03-20 06:19:24 28d63c58-8ae8-4ae5-9c9f-c40749793d64
#>  20: sinking_raccoon 2026-03-20 06:19:24 657accc5-c147-4c15-a44f-5433e52a4037
#>  21:            <NA>                <NA> e9ddfd24-1c66-4786-a1c0-23886dd7db40
#>  22:            <NA>                <NA> 3245d62e-031c-40bf-b326-3ac78409527e
#>  23:            <NA>                <NA> 19150405-4556-4876-bc25-b173a940a096
#>  24:            <NA>                <NA> 98fbf7ce-78d3-4d9f-9f05-1015b36bee27
#>  25:            <NA>                <NA> 1a62de1e-b56c-4413-a1c2-0fc5eb2c86fa
#>  26:            <NA>                <NA> 289b0962-474a-473b-bec3-26fae0a93e61
#>  27:            <NA>                <NA> 1f8a60e4-c902-4476-a87e-55236441fe41
#>  28:            <NA>                <NA> 5a20a62b-513c-4df9-bec3-f5b37d1894ae
#>  29:            <NA>                <NA> 09a0cc51-3aa5-4adf-9385-673677b469c7
#>  30:            <NA>                <NA> 338eb08e-3574-48b9-9ad5-76591bb0d40f
#>  31:            <NA>                <NA> 95d9e904-d1ef-4273-a0fe-7c6def59f8a3
#>  32:            <NA>                <NA> e7c06713-2a2e-4566-bac9-9aebbde2f9d7
#>  33:            <NA>                <NA> b0e2872d-6514-4a07-b866-065071af0563
#>  34:            <NA>                <NA> 041fc8b5-3289-4ba3-8567-bc09cc9dfaff
#>  35:            <NA>                <NA> d09bc6d0-0414-4e12-9c09-f38167794eb1
#>  36:            <NA>                <NA> a4268d3a-e193-4133-81dd-3f6fbedd3e2f
#>  37:            <NA>                <NA> 48de881c-4b95-4f17-8c95-4509244943e4
#>  38:            <NA>                <NA> 8ecc97d3-bb39-4ca0-8cad-e376b7304189
#>  39:            <NA>                <NA> 3c85034c-5182-472d-8612-777352fb535f
#>  40:            <NA>                <NA> c3a41dd3-389a-41bb-8d22-71e0891d980c
#>  41:            <NA>                <NA> 3d451fd8-b8c4-429e-be1a-63f0d87ff425
#>  42:            <NA>                <NA> ae0eb802-a6b8-4813-91be-e3d64cb59694
#>  43:            <NA>                <NA> 66200f54-5a0d-43bd-be13-084fb49422db
#>  44:            <NA>                <NA> 358eea88-89ef-43a2-bd9c-84af44dc427b
#>  45:            <NA>                <NA> a08be790-5597-46ca-a5c3-6ddb54361574
#>  46:            <NA>                <NA> 62a128f0-7662-4013-8c78-a8086cd5ae38
#>  47:            <NA>                <NA> 39677692-4841-46e6-a7f2-cdf78db95b15
#>  48:            <NA>                <NA> 21a10d88-c097-4519-9f88-8ba9c46d862c
#>  49:            <NA>                <NA> a272ee4f-d9df-44c7-937e-7e4127169c8c
#>  50:            <NA>                <NA> a0f330d1-9684-4068-a23c-a600b2c65750
#>  51:            <NA>                <NA> a1440c58-9279-416b-bfa8-191a60e0c94f
#>  52:            <NA>                <NA> 79ef9be0-78e2-4bf1-99e5-7eda4fdbe829
#>  53:            <NA>                <NA> 046da184-7e88-41ef-ac18-17f34aa78cbf
#>  54:            <NA>                <NA> 03424892-6db8-4010-820c-4c115a1eb823
#>  55:            <NA>                <NA> 8f243c9f-05bf-401d-856a-db0f84aabf10
#>  56:            <NA>                <NA> 9c2076d6-8f02-4219-87c4-1053fb3c643d
#>  57:            <NA>                <NA> 5146d52e-5a46-4aa2-9e15-907a67c0b223
#>  58:            <NA>                <NA> 3ff45fb4-ba1b-43e6-8f00-f099a82b9dd3
#>  59:            <NA>                <NA> e12400e9-c11c-409e-8806-d8912e784d88
#>  60:            <NA>                <NA> 5b0bdfdc-eb35-41cc-902c-5e498a8deeb5
#>  61:            <NA>                <NA> 3579a678-352c-4e9e-8103-ba3ac2dbc4c2
#>  62:            <NA>                <NA> 63e80ea8-595a-4f9b-b8e9-ba6bfb273ad9
#>  63:            <NA>                <NA> e5286312-ef78-48c3-bea7-efe851d66f9a
#>  64:            <NA>                <NA> b9d37d5c-70e2-4132-b32f-57829906c8e8
#>  65:            <NA>                <NA> da303b22-f376-4354-aea4-81e1c6316f13
#>  66:            <NA>                <NA> 026ecdf1-dee6-4b52-86c2-d61e2f6c1754
#>  67:            <NA>                <NA> 083217d4-bed7-4c63-a0ef-c231ee6fb63d
#>  68:            <NA>                <NA> 442240b1-1f76-4c35-b100-4b98abdd5671
#>  69:            <NA>                <NA> 136ca420-4b96-4a0d-ab21-e886139f6ad9
#>  70:            <NA>                <NA> 73855d7d-3608-4a1e-bb31-5c25a80bb9b5
#>  71:            <NA>                <NA> d0b7c2ab-af72-4460-865c-779c380c95b3
#>  72:            <NA>                <NA> a86012eb-e20a-46bb-bb10-7f5dfa759b44
#>  73:            <NA>                <NA> 92b70465-4b25-46a9-94c2-6c88676f0280
#>  74:            <NA>                <NA> b39c290e-904f-4215-80e9-2c4a379e403f
#>  75:            <NA>                <NA> 139790f7-cef6-465b-af8b-446302c5f9b5
#>  76:            <NA>                <NA> c73bde81-831b-476c-9987-0d26d65511cf
#>  77:            <NA>                <NA> 05ba7e7f-91ec-4fba-9d4d-9ae81ce432e6
#>  78:            <NA>                <NA> 5198697e-ae21-4747-9023-35a71f9b0b80
#>  79:            <NA>                <NA> f216a330-9db9-41cd-a0d4-fb2613d07176
#>  80:            <NA>                <NA> 8e2b9a2b-8e3a-4e4e-ada7-4a06d916f914
#>  81:            <NA>                <NA> 76605cf2-3241-455c-84e8-bad45c6386a6
#>  82:            <NA>                <NA> d88605c8-18ee-47b0-9d03-5c99e7bdab3d
#>  83:            <NA>                <NA> bbec55db-2596-4f46-82ae-704348826200
#>  84:            <NA>                <NA> 03318b8d-3953-43cb-b236-31a32d5ed699
#>  85:            <NA>                <NA> b82476d6-8137-4ef9-bb4f-3df302c3f7d0
#>  86:            <NA>                <NA> 47b4d1f9-624c-445a-8286-9272bee83ede
#>  87:            <NA>                <NA> b22dbcc8-12e7-4bea-a905-a918e75d55a6
#>  88:            <NA>                <NA> 6720b0af-341f-4ff8-98e6-f84263d4b23c
#>  89:            <NA>                <NA> e33b7284-8920-4ecd-81da-94eaf15f10d9
#>  90:            <NA>                <NA> 7466f9c1-1bc2-4463-869d-3065b27eee4f
#>  91:            <NA>                <NA> 9a362c53-d7b1-4b9b-88f5-005fb547d2be
#>  92:            <NA>                <NA> 5bfc6842-6212-473d-9ed5-2dc2f69256f6
#>  93:            <NA>                <NA> 8e68745a-33ef-4b1c-b2fd-feb58bc6c031
#>  94:            <NA>                <NA> fa30a059-c89b-45cb-9f92-ed9d7b5ce37c
#>  95:            <NA>                <NA> b61e4ff3-0865-4fc7-a979-c9c090d1b5e6
#>  96:            <NA>                <NA> 31816fd4-c859-410c-b27d-87dd097888ba
#>  97:            <NA>                <NA> 3ed47916-c3c7-4821-bc9b-8522f1844b85
#>  98:            <NA>                <NA> 8695d534-09b2-49c6-b7a1-22be463dd653
#>  99:            <NA>                <NA> ea3d518e-d69d-4829-9569-46f3a53c7dec
#> 100:            <NA>                <NA> e4f83304-f553-4ff6-a18a-af26ce02ab81
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>                      message x_domain_x1 x_domain_x2
#>                       <char>       <num>       <num>
#>   1:                    <NA>  -10.000000  -5.0000000
#>   2:                    <NA>  -10.000000  -3.8888889
#>   3:                    <NA>  -10.000000  -2.7777778
#>   4:                    <NA>  -10.000000  -1.6666667
#>   5:                    <NA>  -10.000000  -0.5555556
#>   6:                    <NA>  -10.000000   0.5555556
#>   7:                    <NA>  -10.000000   1.6666667
#>   8:                    <NA>  -10.000000   2.7777778
#>   9:                    <NA>  -10.000000   3.8888889
#>  10:                    <NA>  -10.000000   5.0000000
#>  11:                    <NA>   -7.777778  -5.0000000
#>  12:                    <NA>   -7.777778  -3.8888889
#>  13:                    <NA>   -7.777778  -2.7777778
#>  14:                    <NA>   -7.777778  -1.6666667
#>  15:                    <NA>   -7.777778  -0.5555556
#>  16:                    <NA>   -7.777778   0.5555556
#>  17:                    <NA>   -7.777778   1.6666667
#>  18:                    <NA>   -7.777778   2.7777778
#>  19:                    <NA>   -7.777778   3.8888889
#>  20:                    <NA>   -7.777778   5.0000000
#>  21: Optimization terminated          NA          NA
#>  22: Optimization terminated          NA          NA
#>  23: Optimization terminated          NA          NA
#>  24: Optimization terminated          NA          NA
#>  25: Optimization terminated          NA          NA
#>  26: Optimization terminated          NA          NA
#>  27: Optimization terminated          NA          NA
#>  28: Optimization terminated          NA          NA
#>  29: Optimization terminated          NA          NA
#>  30: Optimization terminated          NA          NA
#>  31: Optimization terminated          NA          NA
#>  32: Optimization terminated          NA          NA
#>  33: Optimization terminated          NA          NA
#>  34: Optimization terminated          NA          NA
#>  35: Optimization terminated          NA          NA
#>  36: Optimization terminated          NA          NA
#>  37: Optimization terminated          NA          NA
#>  38: Optimization terminated          NA          NA
#>  39: Optimization terminated          NA          NA
#>  40: Optimization terminated          NA          NA
#>  41: Optimization terminated          NA          NA
#>  42: Optimization terminated          NA          NA
#>  43: Optimization terminated          NA          NA
#>  44: Optimization terminated          NA          NA
#>  45: Optimization terminated          NA          NA
#>  46: Optimization terminated          NA          NA
#>  47: Optimization terminated          NA          NA
#>  48: Optimization terminated          NA          NA
#>  49: Optimization terminated          NA          NA
#>  50: Optimization terminated          NA          NA
#>  51: Optimization terminated          NA          NA
#>  52: Optimization terminated          NA          NA
#>  53: Optimization terminated          NA          NA
#>  54: Optimization terminated          NA          NA
#>  55: Optimization terminated          NA          NA
#>  56: Optimization terminated          NA          NA
#>  57: Optimization terminated          NA          NA
#>  58: Optimization terminated          NA          NA
#>  59: Optimization terminated          NA          NA
#>  60: Optimization terminated          NA          NA
#>  61: Optimization terminated          NA          NA
#>  62: Optimization terminated          NA          NA
#>  63: Optimization terminated          NA          NA
#>  64: Optimization terminated          NA          NA
#>  65: Optimization terminated          NA          NA
#>  66: Optimization terminated          NA          NA
#>  67: Optimization terminated          NA          NA
#>  68: Optimization terminated          NA          NA
#>  69: Optimization terminated          NA          NA
#>  70: Optimization terminated          NA          NA
#>  71: Optimization terminated          NA          NA
#>  72: Optimization terminated          NA          NA
#>  73: Optimization terminated          NA          NA
#>  74: Optimization terminated          NA          NA
#>  75: Optimization terminated          NA          NA
#>  76: Optimization terminated          NA          NA
#>  77: Optimization terminated          NA          NA
#>  78: Optimization terminated          NA          NA
#>  79: Optimization terminated          NA          NA
#>  80: Optimization terminated          NA          NA
#>  81: Optimization terminated          NA          NA
#>  82: Optimization terminated          NA          NA
#>  83: Optimization terminated          NA          NA
#>  84: Optimization terminated          NA          NA
#>  85: Optimization terminated          NA          NA
#>  86: Optimization terminated          NA          NA
#>  87: Optimization terminated          NA          NA
#>  88: Optimization terminated          NA          NA
#>  89: Optimization terminated          NA          NA
#>  90: Optimization terminated          NA          NA
#>  91: Optimization terminated          NA          NA
#>  92: Optimization terminated          NA          NA
#>  93: Optimization terminated          NA          NA
#>  94: Optimization terminated          NA          NA
#>  95: Optimization terminated          NA          NA
#>  96: Optimization terminated          NA          NA
#>  97: Optimization terminated          NA          NA
#>  98: Optimization terminated          NA          NA
#>  99: Optimization terminated          NA          NA
#> 100: Optimization terminated          NA          NA
#>                      message x_domain_x1 x_domain_x2
#>                       <char>       <num>       <num>
```
