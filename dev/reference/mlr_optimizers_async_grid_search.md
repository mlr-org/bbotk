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

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncGridSearch$new()

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$optimize()`

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncGridSearch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### `OptimizerAsyncGridSearch$clone()`

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-12 16:23:44
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-12 16:23:44
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-12 16:23:44
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-12 16:23:44
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-12 16:23:44
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-12 16:23:44
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-12 16:23:44
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-12 16:23:44
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-12 16:23:44
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-12 16:23:44
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-12 16:23:44
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-12 16:23:44
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-12 16:23:44
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-12 16:23:44
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-12 16:23:44
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-12 16:23:44
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-12 16:23:44
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-12 16:23:44
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-12 16:23:44
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-12 16:23:44
#>  21:   failed  10.000000  5.0000000         NA 2026-06-12 16:23:44
#>  22:   failed  10.000000  3.8888889         NA 2026-06-12 16:23:44
#>  23:   failed  10.000000  2.7777778         NA 2026-06-12 16:23:44
#>  24:   failed  10.000000  1.6666667         NA 2026-06-12 16:23:44
#>  25:   failed  10.000000  0.5555556         NA 2026-06-12 16:23:44
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-12 16:23:44
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-12 16:23:44
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-12 16:23:44
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-12 16:23:44
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-12 16:23:44
#>  31:   failed   7.777778  5.0000000         NA 2026-06-12 16:23:44
#>  32:   failed   7.777778  3.8888889         NA 2026-06-12 16:23:44
#>  33:   failed   7.777778  2.7777778         NA 2026-06-12 16:23:44
#>  34:   failed   7.777778  1.6666667         NA 2026-06-12 16:23:44
#>  35:   failed   7.777778  0.5555556         NA 2026-06-12 16:23:44
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-12 16:23:44
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-12 16:23:44
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-12 16:23:44
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-12 16:23:44
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-12 16:23:44
#>  41:   failed   5.555556  5.0000000         NA 2026-06-12 16:23:44
#>  42:   failed   5.555556  3.8888889         NA 2026-06-12 16:23:44
#>  43:   failed   5.555556  2.7777778         NA 2026-06-12 16:23:44
#>  44:   failed   5.555556  1.6666667         NA 2026-06-12 16:23:44
#>  45:   failed   5.555556  0.5555556         NA 2026-06-12 16:23:44
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-12 16:23:44
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-12 16:23:44
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-12 16:23:44
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-12 16:23:44
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-12 16:23:44
#>  51:   failed   3.333333  5.0000000         NA 2026-06-12 16:23:44
#>  52:   failed   3.333333  3.8888889         NA 2026-06-12 16:23:44
#>  53:   failed   3.333333  2.7777778         NA 2026-06-12 16:23:44
#>  54:   failed   3.333333  1.6666667         NA 2026-06-12 16:23:44
#>  55:   failed   3.333333  0.5555556         NA 2026-06-12 16:23:44
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-12 16:23:44
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-12 16:23:44
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-12 16:23:44
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-12 16:23:44
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-12 16:23:44
#>  61:   failed   1.111111  5.0000000         NA 2026-06-12 16:23:44
#>  62:   failed   1.111111  3.8888889         NA 2026-06-12 16:23:44
#>  63:   failed   1.111111  2.7777778         NA 2026-06-12 16:23:44
#>  64:   failed   1.111111  1.6666667         NA 2026-06-12 16:23:44
#>  65:   failed   1.111111  0.5555556         NA 2026-06-12 16:23:44
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-12 16:23:44
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-12 16:23:44
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-12 16:23:44
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-12 16:23:44
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-12 16:23:44
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-12 16:23:44
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-12 16:23:44
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-12 16:23:44
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-12 16:23:44
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-12 16:23:44
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-12 16:23:44
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-12 16:23:44
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-12 16:23:44
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-12 16:23:44
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-12 16:23:44
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-12 16:23:44
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-12 16:23:44
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-12 16:23:44
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-12 16:23:44
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-12 16:23:44
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-12 16:23:44
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-12 16:23:44
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-12 16:23:44
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-12 16:23:44
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-12 16:23:44
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-12 16:23:44
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-12 16:23:44
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-12 16:23:44
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-12 16:23:44
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-12 16:23:44
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-12 16:23:44
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-12 16:23:44
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-12 16:23:44
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-12 16:23:44
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-12 16:23:44
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-12 16:23:45 590da8aa-93ed-4555-80c0-7e68affe1442
#>   2: sinking_raccoon 2026-06-12 16:23:45 3172622a-a9ce-4fe3-9b57-46d6ac9afa82
#>   3: sinking_raccoon 2026-06-12 16:23:45 80bc7f3e-8c98-475b-8ead-f3558fa30b53
#>   4: sinking_raccoon 2026-06-12 16:23:45 214136c3-9e4a-4836-9f04-7705417fa103
#>   5: sinking_raccoon 2026-06-12 16:23:45 64a29e00-11e6-4a33-8b37-95c4d1a61bd9
#>   6: sinking_raccoon 2026-06-12 16:23:45 1aa26a36-19a5-476a-b9a6-3ae2d7d4e363
#>   7: sinking_raccoon 2026-06-12 16:23:45 a7496a18-7ecd-46d3-8d55-94f93aea76cc
#>   8: sinking_raccoon 2026-06-12 16:23:45 66b7d957-b86c-4fa6-8cf7-4c5abd68550c
#>   9: sinking_raccoon 2026-06-12 16:23:45 0d90dd75-40a5-481b-a991-8b33e29d29e1
#>  10: sinking_raccoon 2026-06-12 16:23:45 ab19239f-f59c-4b56-b9af-76749af46d08
#>  11: sinking_raccoon 2026-06-12 16:23:45 b6ddc3e2-727f-4a12-9e52-9163a0999669
#>  12: sinking_raccoon 2026-06-12 16:23:45 26b5a8c1-381f-4900-b696-d0e3d995d3db
#>  13: sinking_raccoon 2026-06-12 16:23:45 fdbf7251-ac8e-407b-8bc7-4dfeafd343ef
#>  14: sinking_raccoon 2026-06-12 16:23:45 5696572f-825d-4c5c-9adb-56afc2d20c33
#>  15: sinking_raccoon 2026-06-12 16:23:45 e302c4b3-f88f-4ec3-8608-b4d0949af1ca
#>  16: sinking_raccoon 2026-06-12 16:23:45 8a8fecc0-8e15-4071-b023-5c06b207d883
#>  17: sinking_raccoon 2026-06-12 16:23:45 a163b2a3-684c-4c38-99af-05c8854f388e
#>  18: sinking_raccoon 2026-06-12 16:23:45 d3612a8c-270d-426e-a880-df03a7a74ef1
#>  19: sinking_raccoon 2026-06-12 16:23:45 d0a31fa7-c9d3-482a-b29f-2995a1f7a2af
#>  20: sinking_raccoon 2026-06-12 16:23:45 ce431555-cfd0-4ecc-b21c-a6f914bc3a1c
#>  21:            <NA>                <NA> 09a95bca-f1cc-497b-88e3-e1cf33477023
#>  22:            <NA>                <NA> 1efb261e-6661-4542-afca-96e06c2f7046
#>  23:            <NA>                <NA> 7376166b-de28-4b73-a63a-93a94b25ef9d
#>  24:            <NA>                <NA> 5f608d61-4306-4cb6-80f9-afd8d5421fdf
#>  25:            <NA>                <NA> 402a3e7c-1894-4d07-955b-48a9d53486a4
#>  26:            <NA>                <NA> 75ae1cbc-2ba9-4e5e-95a5-ab3b490a26c7
#>  27:            <NA>                <NA> 0f589f77-3699-40b2-b6d9-747d9be1121b
#>  28:            <NA>                <NA> c16e171f-cd81-464e-a78f-3cb51516f42d
#>  29:            <NA>                <NA> 081aab7c-bfff-4e67-9ff0-380db5d85fce
#>  30:            <NA>                <NA> 0021bb81-375f-4d42-a2ea-c1890298e4d1
#>  31:            <NA>                <NA> a9ed8a11-835a-4863-a3ae-a6f2c9a39dc9
#>  32:            <NA>                <NA> a22eb95f-b19a-4ec2-a126-e5e2960dfc3b
#>  33:            <NA>                <NA> 50328687-ae4c-4072-92ab-85b3b9d81092
#>  34:            <NA>                <NA> 6b91f927-54f9-418a-8e19-6d73e4ce67b0
#>  35:            <NA>                <NA> 1eae4cea-c6b1-4fc0-b5ab-5acfa0a14f19
#>  36:            <NA>                <NA> aa1e04b0-6c98-462d-98a3-56011101dd8a
#>  37:            <NA>                <NA> 5754e99f-3364-48a8-ac51-ee92f6d83c66
#>  38:            <NA>                <NA> f0d6ab50-0f31-4afc-a563-54a9bb0d148c
#>  39:            <NA>                <NA> 46c4e607-83eb-458d-bea4-50f0c31faef7
#>  40:            <NA>                <NA> a27f5d95-0710-4cec-8251-c7ec231ecbbc
#>  41:            <NA>                <NA> 266fa239-08cd-495d-910c-8a67c3534846
#>  42:            <NA>                <NA> 205c6a58-497f-43e1-b460-7fe15743a4b0
#>  43:            <NA>                <NA> aa72d428-09c7-4ecc-a6c8-f41038042437
#>  44:            <NA>                <NA> d16df80f-1fb0-44fa-9e27-2c58d47c062d
#>  45:            <NA>                <NA> b46741b8-e736-4eb6-81e0-ef0435d96f17
#>  46:            <NA>                <NA> 0ebdabd7-d203-4728-b763-4956f79a1cd3
#>  47:            <NA>                <NA> de5755b6-670b-4abe-bcb5-09cd5891ed18
#>  48:            <NA>                <NA> ead287ee-1eeb-46ef-a64e-5677257f8ff8
#>  49:            <NA>                <NA> 55345032-40e8-42ec-a1da-98a52486b1d0
#>  50:            <NA>                <NA> 7d966089-df68-4fe3-b7d8-b5a7eb248977
#>  51:            <NA>                <NA> 6491c913-d2fc-4721-877e-e744f9fb1a56
#>  52:            <NA>                <NA> e810bcd1-0f5b-4cd3-8bcc-ba67f0d6702d
#>  53:            <NA>                <NA> d34d7d1c-ceb3-43fe-a38d-2d959c4e941c
#>  54:            <NA>                <NA> 42862449-4156-46fd-a9d9-e3894fc5b640
#>  55:            <NA>                <NA> 60eb098e-8755-403b-82b3-a651f7bed57f
#>  56:            <NA>                <NA> fc616472-ac80-499e-af6a-69420ac5f3ab
#>  57:            <NA>                <NA> a19082b7-3275-4022-9700-c35680f1291e
#>  58:            <NA>                <NA> 66c33a94-0caf-40c9-b23f-0a658586e899
#>  59:            <NA>                <NA> 0362d6f5-a7b9-427e-b3df-96bbcb399e89
#>  60:            <NA>                <NA> ea689ceb-3bf9-4205-95a9-d91f5704c047
#>  61:            <NA>                <NA> 57b0b8f4-67ad-4732-9369-958bc79a0589
#>  62:            <NA>                <NA> ec7d0e50-2907-40c2-aee7-85c9615c54de
#>  63:            <NA>                <NA> 583aa830-85c6-46f8-b745-659e393dbc8b
#>  64:            <NA>                <NA> 815266af-7c18-4e6e-9d34-0fdd97fbec28
#>  65:            <NA>                <NA> 0d20f92f-550f-48d2-834b-dd47a7ceaad8
#>  66:            <NA>                <NA> 560c5689-e833-4113-8cad-0831cdf84e59
#>  67:            <NA>                <NA> f72c14c1-d6cf-4f95-9e96-f659e80ffd4a
#>  68:            <NA>                <NA> e80b10dd-23b1-4a8a-bd67-dff9e6ceed39
#>  69:            <NA>                <NA> 8f8260ed-2b53-4ea6-86ea-5378583cf766
#>  70:            <NA>                <NA> a02bdf97-643d-4cf3-9551-89c2e5df2589
#>  71:            <NA>                <NA> f69973ff-ed00-4d97-8060-ce3ae58ecf52
#>  72:            <NA>                <NA> 985264a5-eadb-42ad-896b-0113fafbbe92
#>  73:            <NA>                <NA> d357c638-bb50-45ee-94f4-e0f49462e320
#>  74:            <NA>                <NA> f4ea32fa-0077-4cf5-81f9-cfd590a9bd42
#>  75:            <NA>                <NA> bd1130bd-ae12-478d-992d-853532b0da10
#>  76:            <NA>                <NA> 1338915e-7dcf-4617-bd26-2512591a383d
#>  77:            <NA>                <NA> 5c1633fa-163d-4267-85b9-427488dee132
#>  78:            <NA>                <NA> 23e468ea-9725-42a1-a1e7-b2f299371e3f
#>  79:            <NA>                <NA> 9ed5fe06-583e-456c-8e53-bb655a1af9b1
#>  80:            <NA>                <NA> 7071ea68-889d-48f1-ab7b-d374a7966f1e
#>  81:            <NA>                <NA> 0ffc72a3-3003-4af7-8155-6325c98517f6
#>  82:            <NA>                <NA> e0930cbe-472b-4b0e-b419-158cc679642f
#>  83:            <NA>                <NA> c4b284eb-2781-46d6-98f2-19736d6c4d66
#>  84:            <NA>                <NA> b47fac8b-1ea2-478d-a57b-09a93c9aaee5
#>  85:            <NA>                <NA> 41de79ae-7a16-4f16-b344-e4bbc675ae88
#>  86:            <NA>                <NA> faf4e3cc-0fee-4902-81c0-7e437ceaaa2c
#>  87:            <NA>                <NA> 0bf01fb6-f1bc-4aa3-9b4e-3add73849d1d
#>  88:            <NA>                <NA> ad32b33d-cb00-4288-a624-d73d18619461
#>  89:            <NA>                <NA> 613bec1d-1961-4752-8783-81469831610a
#>  90:            <NA>                <NA> 428f8cae-d29e-424c-aa5a-66683d4c7554
#>  91:            <NA>                <NA> 55b2c6cc-0ccf-4344-addd-847e88808267
#>  92:            <NA>                <NA> 0b762576-0958-43b5-94cc-8b7dde5c6d30
#>  93:            <NA>                <NA> e8a98d0b-fc9f-4312-b80b-bf3ea8116cf3
#>  94:            <NA>                <NA> 00fac483-39be-403e-b6cc-bd4ce9b9e771
#>  95:            <NA>                <NA> e92e8477-8c20-4877-a468-8ce4c4043983
#>  96:            <NA>                <NA> 9c3f51c2-3a31-4fa9-bed3-f72cd973bebd
#>  97:            <NA>                <NA> 9982220d-a876-42fe-9c7c-dac853d24482
#>  98:            <NA>                <NA> ec8bfc3e-1feb-4616-9f4f-a275107609f3
#>  99:            <NA>                <NA> 64694104-f387-46e7-b104-db1e92864507
#> 100:            <NA>                <NA> f5a444bf-3cc7-4200-9c8a-179df8fceb29
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
