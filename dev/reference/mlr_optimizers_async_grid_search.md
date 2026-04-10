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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-10 10:49:09
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-10 10:49:09
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-10 10:49:09
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-10 10:49:09
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-10 10:49:09
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-10 10:49:09
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-10 10:49:09
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-10 10:49:09
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-10 10:49:09
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-10 10:49:09
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-10 10:49:09
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-10 10:49:09
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-10 10:49:09
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-10 10:49:09
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-10 10:49:09
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-10 10:49:09
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-10 10:49:09
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-10 10:49:09
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-10 10:49:09
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-10 10:49:09
#>  21:   failed  10.000000  5.0000000         NA 2026-04-10 10:49:09
#>  22:   failed  10.000000  3.8888889         NA 2026-04-10 10:49:09
#>  23:   failed  10.000000  2.7777778         NA 2026-04-10 10:49:09
#>  24:   failed  10.000000  1.6666667         NA 2026-04-10 10:49:09
#>  25:   failed  10.000000  0.5555556         NA 2026-04-10 10:49:09
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-10 10:49:09
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-10 10:49:09
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-10 10:49:09
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-10 10:49:09
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-10 10:49:09
#>  31:   failed   7.777778  5.0000000         NA 2026-04-10 10:49:09
#>  32:   failed   7.777778  3.8888889         NA 2026-04-10 10:49:09
#>  33:   failed   7.777778  2.7777778         NA 2026-04-10 10:49:09
#>  34:   failed   7.777778  1.6666667         NA 2026-04-10 10:49:09
#>  35:   failed   7.777778  0.5555556         NA 2026-04-10 10:49:09
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-10 10:49:09
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-10 10:49:09
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-10 10:49:09
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-10 10:49:09
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-10 10:49:09
#>  41:   failed   5.555556  5.0000000         NA 2026-04-10 10:49:09
#>  42:   failed   5.555556  3.8888889         NA 2026-04-10 10:49:09
#>  43:   failed   5.555556  2.7777778         NA 2026-04-10 10:49:09
#>  44:   failed   5.555556  1.6666667         NA 2026-04-10 10:49:09
#>  45:   failed   5.555556  0.5555556         NA 2026-04-10 10:49:09
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-10 10:49:09
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-10 10:49:09
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-10 10:49:09
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-10 10:49:09
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-10 10:49:09
#>  51:   failed   3.333333  5.0000000         NA 2026-04-10 10:49:09
#>  52:   failed   3.333333  3.8888889         NA 2026-04-10 10:49:09
#>  53:   failed   3.333333  2.7777778         NA 2026-04-10 10:49:09
#>  54:   failed   3.333333  1.6666667         NA 2026-04-10 10:49:09
#>  55:   failed   3.333333  0.5555556         NA 2026-04-10 10:49:09
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-10 10:49:09
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-10 10:49:09
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-10 10:49:09
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-10 10:49:09
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-10 10:49:09
#>  61:   failed   1.111111  5.0000000         NA 2026-04-10 10:49:09
#>  62:   failed   1.111111  3.8888889         NA 2026-04-10 10:49:09
#>  63:   failed   1.111111  2.7777778         NA 2026-04-10 10:49:09
#>  64:   failed   1.111111  1.6666667         NA 2026-04-10 10:49:09
#>  65:   failed   1.111111  0.5555556         NA 2026-04-10 10:49:09
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-10 10:49:09
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-10 10:49:09
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-10 10:49:09
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-10 10:49:09
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-10 10:49:09
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-10 10:49:09
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-10 10:49:09
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-10 10:49:09
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-10 10:49:09
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-10 10:49:09
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-10 10:49:09
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-10 10:49:09
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-10 10:49:09
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-10 10:49:09
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-10 10:49:09
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-10 10:49:09
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-10 10:49:09
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-10 10:49:09
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-10 10:49:09
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-10 10:49:09
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-10 10:49:09
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-10 10:49:09
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-10 10:49:09
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-10 10:49:09
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-10 10:49:09
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-10 10:49:09
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-10 10:49:09
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-10 10:49:09
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-10 10:49:09
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-10 10:49:09
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-10 10:49:09
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-10 10:49:09
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-10 10:49:09
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-10 10:49:09
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-10 10:49:09
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-10 10:49:10 6912aa8a-8a13-480f-a128-e1320f95de4f
#>   2: sinking_raccoon 2026-04-10 10:49:10 79ec7fdc-6e56-48ae-9783-bbf0970cae49
#>   3: sinking_raccoon 2026-04-10 10:49:10 6d3b1117-3670-4d11-b6c4-5f101d47e185
#>   4: sinking_raccoon 2026-04-10 10:49:10 9d3a0e24-1c35-4576-9d91-464b6275fa0f
#>   5: sinking_raccoon 2026-04-10 10:49:10 3a1f4188-b54f-41b7-9aba-18712efdcd7c
#>   6: sinking_raccoon 2026-04-10 10:49:10 0648d2ae-dc45-4fa0-847b-ed81301a407e
#>   7: sinking_raccoon 2026-04-10 10:49:10 8dec0f61-06b5-449d-bba7-4c564d8d85bb
#>   8: sinking_raccoon 2026-04-10 10:49:10 7aa74f38-f52c-4fd0-be20-c98bf7fcde55
#>   9: sinking_raccoon 2026-04-10 10:49:10 2c6028e9-03e0-499b-b5bf-6a5dfc9c1ca7
#>  10: sinking_raccoon 2026-04-10 10:49:10 8f9737f5-adfc-42fd-b5e4-332386b7ec9f
#>  11: sinking_raccoon 2026-04-10 10:49:10 aa9e7bae-0cdf-4af9-979d-4379187be0a6
#>  12: sinking_raccoon 2026-04-10 10:49:10 46cbbe1a-7592-4fa0-b324-adafb4982fca
#>  13: sinking_raccoon 2026-04-10 10:49:10 69a33d36-5c13-4aee-a8d3-3c4038fd9cd3
#>  14: sinking_raccoon 2026-04-10 10:49:10 2a3a708a-3d89-494b-81c7-77683efaa627
#>  15: sinking_raccoon 2026-04-10 10:49:10 1e27cd9b-045f-4b00-82e0-f851455cee34
#>  16: sinking_raccoon 2026-04-10 10:49:10 8a5cdb9c-cac9-4d4d-a345-9e1f5e114fa3
#>  17: sinking_raccoon 2026-04-10 10:49:10 604e7b5e-15a4-4505-bf95-5507a9aa5621
#>  18: sinking_raccoon 2026-04-10 10:49:10 4637a7ee-000e-4722-a244-081144cc461d
#>  19: sinking_raccoon 2026-04-10 10:49:10 c7981691-4b30-4163-9eaf-211c386a1cf3
#>  20: sinking_raccoon 2026-04-10 10:49:10 b36f45d0-c457-4fe0-913b-4ce391d8db1c
#>  21:            <NA>                <NA> 05ccabac-0acd-492c-b14f-3eccef0d8d39
#>  22:            <NA>                <NA> 999f9a1f-708b-4bf8-a165-9f1506597897
#>  23:            <NA>                <NA> d8513c60-afb9-4bc8-9a3a-4b30d7d0fb2f
#>  24:            <NA>                <NA> 42a68f24-b01e-4168-95d6-cedbec590314
#>  25:            <NA>                <NA> fec90d38-4832-479d-a829-8488ff6bfa20
#>  26:            <NA>                <NA> ca030c05-a8f2-46c5-837d-829ff4222a0c
#>  27:            <NA>                <NA> 44adc4bf-0683-4222-8478-f5a37486808c
#>  28:            <NA>                <NA> 4f738eaf-523b-444e-a301-611e4e4d737c
#>  29:            <NA>                <NA> 7cd63e6c-c44b-44be-bb11-b90885c58376
#>  30:            <NA>                <NA> bcc38761-df6c-4e68-beee-89d9d6f26d73
#>  31:            <NA>                <NA> cf094aa0-49ec-4674-9af2-a449193a99cc
#>  32:            <NA>                <NA> 449b1e1b-1ffc-4212-a7bf-245b76f7edc2
#>  33:            <NA>                <NA> 8a9d72fa-3268-48c7-a4c7-8d410bec7caa
#>  34:            <NA>                <NA> d02acadf-f773-44d2-941d-64e712e847a9
#>  35:            <NA>                <NA> 57e086f6-c9d3-4aa1-b987-d6ad79667865
#>  36:            <NA>                <NA> 95aea5be-d64c-45ab-9041-67f2db7e143a
#>  37:            <NA>                <NA> 5c3291c4-8939-444a-b733-fbc7825938fd
#>  38:            <NA>                <NA> 18b17afb-526d-43ed-b7cd-ad3694a5938b
#>  39:            <NA>                <NA> 82927b95-1555-4e5d-b783-157f0319256d
#>  40:            <NA>                <NA> 2c8431aa-c298-45a4-ae2f-468bda7782e6
#>  41:            <NA>                <NA> 8675609e-a844-4ad2-97cd-d4236f9b9a25
#>  42:            <NA>                <NA> 4438837f-814f-40d8-acfa-aae8510117b6
#>  43:            <NA>                <NA> 17ce2893-f072-4f98-9500-c388cc0bd790
#>  44:            <NA>                <NA> ea8aa338-5473-4d70-a104-612e610674a0
#>  45:            <NA>                <NA> 1a41146d-ae28-4d92-abc0-4e38f00da9e1
#>  46:            <NA>                <NA> a6e520e0-d1a9-4b48-9ecb-283396333129
#>  47:            <NA>                <NA> 66c865bc-c6ef-4b90-bcfb-64daf368ede6
#>  48:            <NA>                <NA> 4c7d6f54-ff4e-4b96-b361-102c081f7746
#>  49:            <NA>                <NA> 10343b96-a425-4bb7-937c-a01d47e5a7b4
#>  50:            <NA>                <NA> 159dd9a3-16ee-45b2-8d34-3c54c6d86559
#>  51:            <NA>                <NA> 0c1777ba-8a3f-40c6-8424-f19c70d3026a
#>  52:            <NA>                <NA> 17382f6f-490f-4aac-9af5-8a279a3dca14
#>  53:            <NA>                <NA> 267a872c-20f1-4f0e-a4e0-604b4d6363a5
#>  54:            <NA>                <NA> 4b9858da-7de4-45ee-8ead-c90e55101678
#>  55:            <NA>                <NA> bd54e18b-b8df-4f15-9f22-8b9801f3d78c
#>  56:            <NA>                <NA> 325fca6d-a844-4bb4-8a2c-47bcce8d97c1
#>  57:            <NA>                <NA> 70e034da-72de-4723-b19a-5d8180485ab4
#>  58:            <NA>                <NA> 8fbf56d3-59e7-4d63-802e-5227a4d37906
#>  59:            <NA>                <NA> 7fd4b6d7-7f4c-4aba-b947-8aa3d30c811b
#>  60:            <NA>                <NA> 35fe77a5-ae07-490a-9678-f442c3152703
#>  61:            <NA>                <NA> 7b2d04a1-3c97-4695-8ba7-b3987ee798b4
#>  62:            <NA>                <NA> f6c46cce-57aa-4906-98b6-e8aa9babdc5a
#>  63:            <NA>                <NA> f2c9bd1a-1342-49fa-8f87-357c51b1ae45
#>  64:            <NA>                <NA> 809bd1cd-8f71-4107-852c-0305d8ff877e
#>  65:            <NA>                <NA> b28285d6-4659-433d-8079-bfab93fd26a4
#>  66:            <NA>                <NA> cade9be1-8d7a-491a-9971-4d8db60a8f74
#>  67:            <NA>                <NA> e7339762-422a-4162-b4c7-2ec2693bc137
#>  68:            <NA>                <NA> 5684b22e-cdc3-4e27-8f34-b08bb915833e
#>  69:            <NA>                <NA> 3e3b6648-e049-44f7-9856-b0a6565a1b70
#>  70:            <NA>                <NA> 04ee513f-bb8a-44c1-b3af-1de090b3fc72
#>  71:            <NA>                <NA> 0bfe6752-b0bb-4905-80d4-909c517c150d
#>  72:            <NA>                <NA> 8a214f8d-f987-43ce-b8f2-050b6a636b0f
#>  73:            <NA>                <NA> 3b7da4e6-9390-4cb0-84f0-d587326aee86
#>  74:            <NA>                <NA> 0ccd9494-60d1-486c-bffd-636fce69aeed
#>  75:            <NA>                <NA> 165c961a-3612-4595-b2ff-f86a06cd203c
#>  76:            <NA>                <NA> 99b3403d-504d-4545-be56-4a2a3ce3af1c
#>  77:            <NA>                <NA> 5d5a0018-b660-473f-8b53-78e3bc95e6b3
#>  78:            <NA>                <NA> 47ca0e23-d825-43d3-a46e-75d39baaaf2d
#>  79:            <NA>                <NA> 7ab014e2-14be-47dd-88c4-31d958649382
#>  80:            <NA>                <NA> c2220277-17e4-418c-9c58-f58c123da734
#>  81:            <NA>                <NA> b54b650d-85d6-4f32-a30f-a5b559d38f6f
#>  82:            <NA>                <NA> cdfc8eae-5ed3-41a7-bd5c-b0ea4c0921df
#>  83:            <NA>                <NA> 1a99a6d5-aa70-4e7f-9fbe-d6b0317925c6
#>  84:            <NA>                <NA> 20f9eb14-528f-48d0-bd4f-278e418b42c0
#>  85:            <NA>                <NA> b3280dd1-e36b-40e2-828a-41935f88a8e9
#>  86:            <NA>                <NA> bc50400b-60d5-42ca-9870-02a9e92e00e0
#>  87:            <NA>                <NA> fc89c75d-5a80-40f8-9309-bdd03f537166
#>  88:            <NA>                <NA> f4b4049f-d3ee-4acf-a88d-81b77dbeef3b
#>  89:            <NA>                <NA> a3456286-2967-43bd-84da-8a92f7e8601a
#>  90:            <NA>                <NA> d146268f-0d1d-430c-ae89-29eb6febc6cf
#>  91:            <NA>                <NA> 2d824f1b-4763-4edd-962b-f235541ea3d6
#>  92:            <NA>                <NA> 77b83b19-7549-451e-9970-a2c46b8f811d
#>  93:            <NA>                <NA> b8b567bf-5f6f-4726-b983-0b4d18aa9869
#>  94:            <NA>                <NA> 6f87f222-34c1-4067-a3ce-3ecb926d852a
#>  95:            <NA>                <NA> 1d12dd77-5074-4c1f-b9d2-b575be53d1f9
#>  96:            <NA>                <NA> f67fc17f-8daf-42e0-a494-0186eb49b6dc
#>  97:            <NA>                <NA> 264769cb-91e9-40ce-aab2-225a1cb43443
#>  98:            <NA>                <NA> 9043805b-dffd-4148-a2a6-58b95ee36884
#>  99:            <NA>                <NA> 7e7738bf-60b5-4a24-be5c-26fc7d302811
#> 100:            <NA>                <NA> d9ebd7fd-9f47-4732-bfdf-d579e92582d6
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
