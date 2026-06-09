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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-09 16:20:10
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-09 16:20:10
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-09 16:20:10
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-09 16:20:10
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-09 16:20:10
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-09 16:20:10
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-09 16:20:10
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-09 16:20:10
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-09 16:20:10
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-09 16:20:10
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-09 16:20:10
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-09 16:20:10
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-09 16:20:10
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-09 16:20:10
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-09 16:20:10
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-09 16:20:10
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-09 16:20:10
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-09 16:20:10
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-09 16:20:10
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-09 16:20:10
#>  21:   failed  10.000000  5.0000000         NA 2026-06-09 16:20:10
#>  22:   failed  10.000000  3.8888889         NA 2026-06-09 16:20:10
#>  23:   failed  10.000000  2.7777778         NA 2026-06-09 16:20:10
#>  24:   failed  10.000000  1.6666667         NA 2026-06-09 16:20:10
#>  25:   failed  10.000000  0.5555556         NA 2026-06-09 16:20:10
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-09 16:20:10
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-09 16:20:10
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-09 16:20:10
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-09 16:20:10
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-09 16:20:10
#>  31:   failed   7.777778  5.0000000         NA 2026-06-09 16:20:10
#>  32:   failed   7.777778  3.8888889         NA 2026-06-09 16:20:10
#>  33:   failed   7.777778  2.7777778         NA 2026-06-09 16:20:10
#>  34:   failed   7.777778  1.6666667         NA 2026-06-09 16:20:10
#>  35:   failed   7.777778  0.5555556         NA 2026-06-09 16:20:10
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-09 16:20:10
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-09 16:20:10
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-09 16:20:10
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-09 16:20:10
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-09 16:20:10
#>  41:   failed   5.555556  5.0000000         NA 2026-06-09 16:20:10
#>  42:   failed   5.555556  3.8888889         NA 2026-06-09 16:20:10
#>  43:   failed   5.555556  2.7777778         NA 2026-06-09 16:20:10
#>  44:   failed   5.555556  1.6666667         NA 2026-06-09 16:20:10
#>  45:   failed   5.555556  0.5555556         NA 2026-06-09 16:20:10
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-09 16:20:10
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-09 16:20:10
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-09 16:20:10
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-09 16:20:10
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-09 16:20:10
#>  51:   failed   3.333333  5.0000000         NA 2026-06-09 16:20:10
#>  52:   failed   3.333333  3.8888889         NA 2026-06-09 16:20:10
#>  53:   failed   3.333333  2.7777778         NA 2026-06-09 16:20:10
#>  54:   failed   3.333333  1.6666667         NA 2026-06-09 16:20:10
#>  55:   failed   3.333333  0.5555556         NA 2026-06-09 16:20:10
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-09 16:20:10
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-09 16:20:10
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-09 16:20:10
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-09 16:20:10
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-09 16:20:10
#>  61:   failed   1.111111  5.0000000         NA 2026-06-09 16:20:10
#>  62:   failed   1.111111  3.8888889         NA 2026-06-09 16:20:10
#>  63:   failed   1.111111  2.7777778         NA 2026-06-09 16:20:10
#>  64:   failed   1.111111  1.6666667         NA 2026-06-09 16:20:10
#>  65:   failed   1.111111  0.5555556         NA 2026-06-09 16:20:10
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-09 16:20:10
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-09 16:20:10
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-09 16:20:10
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-09 16:20:10
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-09 16:20:10
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-09 16:20:10
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-09 16:20:10
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-09 16:20:10
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-09 16:20:10
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-09 16:20:10
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-09 16:20:10
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-09 16:20:10
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-09 16:20:10
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-09 16:20:10
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-09 16:20:10
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-09 16:20:10
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-09 16:20:10
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-09 16:20:10
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-09 16:20:10
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-09 16:20:10
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-09 16:20:10
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-09 16:20:10
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-09 16:20:10
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-09 16:20:10
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-09 16:20:10
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-09 16:20:10
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-09 16:20:10
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-09 16:20:10
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-09 16:20:10
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-09 16:20:10
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-09 16:20:10
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-09 16:20:10
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-09 16:20:10
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-09 16:20:10
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-09 16:20:10
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-09 16:20:11 8bccc67c-1694-4de5-9424-3891c3e40ed9
#>   2: sinking_raccoon 2026-06-09 16:20:11 cb95308b-1620-4a1a-8426-d773ca31ad90
#>   3: sinking_raccoon 2026-06-09 16:20:11 408d9e6c-1020-4529-9200-b8fb91a1cc3c
#>   4: sinking_raccoon 2026-06-09 16:20:11 342a8208-4519-479f-9154-440f9c4c869a
#>   5: sinking_raccoon 2026-06-09 16:20:11 950d38c1-3f77-4914-b1bd-0e1859c3ef9a
#>   6: sinking_raccoon 2026-06-09 16:20:11 662f57a2-fb5e-4e56-b9d7-50fa850ac8a5
#>   7: sinking_raccoon 2026-06-09 16:20:11 1e3d1c59-04c4-40da-a3c1-310c5de212e5
#>   8: sinking_raccoon 2026-06-09 16:20:11 0c06c8ae-6b38-4b2c-93b4-5537a7b283b6
#>   9: sinking_raccoon 2026-06-09 16:20:11 2757f138-25f1-4a52-8d84-467f6adac2ad
#>  10: sinking_raccoon 2026-06-09 16:20:11 1e69ebd9-a082-4dc4-b092-81adc1fa0484
#>  11: sinking_raccoon 2026-06-09 16:20:11 c4086d02-f9ac-4c15-a633-8358c69e2bac
#>  12: sinking_raccoon 2026-06-09 16:20:11 bad56a12-0b98-439c-980f-cb2e15b9f921
#>  13: sinking_raccoon 2026-06-09 16:20:11 c9c0ff62-0c50-4a74-bf66-9d362b76c567
#>  14: sinking_raccoon 2026-06-09 16:20:11 397d5f3d-4e4e-41fb-94ce-6fc33bcd7ce8
#>  15: sinking_raccoon 2026-06-09 16:20:11 c9d6e3b0-e58a-4e21-bd44-4b34d9f3cd9a
#>  16: sinking_raccoon 2026-06-09 16:20:11 a8342087-c8ac-4c13-affc-143f13cf95ee
#>  17: sinking_raccoon 2026-06-09 16:20:11 c5411073-5d9f-4bf8-ad8b-811dd68c4849
#>  18: sinking_raccoon 2026-06-09 16:20:11 d4e50f53-5ecb-4e61-bfa1-1acff4971242
#>  19: sinking_raccoon 2026-06-09 16:20:11 c7085381-9c57-41eb-8514-0cc51b3b6ef0
#>  20: sinking_raccoon 2026-06-09 16:20:11 2adfcd53-1357-4301-9feb-051c4c7a2265
#>  21:            <NA>                <NA> b7057b46-c865-4e4f-b331-f3906c893a92
#>  22:            <NA>                <NA> 6ca7042c-aefc-4b1e-a0e4-3e003a4c9242
#>  23:            <NA>                <NA> e0220c93-7cc5-49b5-9536-c23f1470aabc
#>  24:            <NA>                <NA> c0968993-a0fa-40e1-af97-b2653e1e7042
#>  25:            <NA>                <NA> 8455542f-eb2c-4d75-8e57-91a36e9ce963
#>  26:            <NA>                <NA> 7d55bd02-5114-4dbe-9311-68fbd592d748
#>  27:            <NA>                <NA> 05455eb0-4b9a-496b-9719-f12bf62806b3
#>  28:            <NA>                <NA> c4735c9f-3063-4227-86ef-7e303f34a09f
#>  29:            <NA>                <NA> e07a55b7-bc02-44a1-86a4-8bf50498d828
#>  30:            <NA>                <NA> 270d7ebd-1d7f-48e7-ba1d-f2e91b977865
#>  31:            <NA>                <NA> e3057ea5-077e-4199-8c35-49d5dd62916c
#>  32:            <NA>                <NA> 9875d9b3-f2af-4440-aec6-b7188f832754
#>  33:            <NA>                <NA> 48ba1463-013d-4c69-8825-ee6973d19e7f
#>  34:            <NA>                <NA> 17ae53db-1b4f-4697-a682-50646bfbf1ec
#>  35:            <NA>                <NA> 892a395c-439c-40be-862b-c16f3ba664a0
#>  36:            <NA>                <NA> a2b7d746-6756-433f-b9c3-ff0d0858b12d
#>  37:            <NA>                <NA> 113cb7b8-6b7b-4cf8-84a4-cefbd14f69b8
#>  38:            <NA>                <NA> 2c4d2a69-27ee-4ba4-8305-ceaa8e1cf844
#>  39:            <NA>                <NA> 3cf3b6c1-7126-4722-92f6-79cc5f6c8e49
#>  40:            <NA>                <NA> 1b9046ee-2e91-4889-9682-5a85099d4c75
#>  41:            <NA>                <NA> 778efd2e-f053-480c-9b7c-0af6c545b378
#>  42:            <NA>                <NA> c1f88745-3f62-47cc-8871-bfe6dd49ce2b
#>  43:            <NA>                <NA> 8c2edd18-b4e5-4c03-a53f-395cc2db562d
#>  44:            <NA>                <NA> e679ed68-02bf-40f5-ad16-6888021b4d03
#>  45:            <NA>                <NA> de622f1c-1b5f-48f8-a4b9-cfaec08a943a
#>  46:            <NA>                <NA> 778f4bf0-ea38-48d0-9c62-6ebbae370fb8
#>  47:            <NA>                <NA> af692bee-8437-49ac-867a-97aeadc08d1e
#>  48:            <NA>                <NA> dbbfcc7f-8186-4f41-b258-c5eea4340586
#>  49:            <NA>                <NA> 6c692801-85b0-42a3-941d-cd8682a6e1a8
#>  50:            <NA>                <NA> 2f19fe3b-7d91-4ce5-81cd-e4b87827f630
#>  51:            <NA>                <NA> 659179b6-eaae-41ca-8aab-86e93a0cf1c1
#>  52:            <NA>                <NA> 5947dc5a-64b1-4714-8d2d-bc1970e6a009
#>  53:            <NA>                <NA> f196bb6c-0c5a-45d3-bfc7-b1227a06836a
#>  54:            <NA>                <NA> 256c860a-70fe-47a4-bccc-864629a38915
#>  55:            <NA>                <NA> 4868b008-d20c-415a-b424-724d9fe9da38
#>  56:            <NA>                <NA> 0d3f8eed-050c-4e5a-aef6-4f78126ba710
#>  57:            <NA>                <NA> 3165e9b1-1a6e-4053-b675-a1f1c539d8cd
#>  58:            <NA>                <NA> 3edf52a6-2c06-4540-b8b7-f1b2241f2808
#>  59:            <NA>                <NA> bc336ab9-fb94-47b3-8a64-cb9a3186b161
#>  60:            <NA>                <NA> b775e848-6cdf-4028-93d1-c210937be4b0
#>  61:            <NA>                <NA> dbd7cc01-147a-4157-82f2-56d612bbf000
#>  62:            <NA>                <NA> 9a573521-fe24-4c4a-8f57-a51767a48120
#>  63:            <NA>                <NA> 5b1fed23-e767-4092-8892-404b14f0b45d
#>  64:            <NA>                <NA> f1111395-48f2-43ee-a6b5-b8013a27e550
#>  65:            <NA>                <NA> a4cc5253-9a09-45de-9c2c-7fd745c92eac
#>  66:            <NA>                <NA> ede0c7dc-b83a-4e19-9945-e4ca7b6e9653
#>  67:            <NA>                <NA> 81d6b7a3-916a-4997-a0d8-b4bd0783c78b
#>  68:            <NA>                <NA> a73f4880-2c0a-4a36-ab59-2c9130b88c36
#>  69:            <NA>                <NA> ce008e01-9d9a-4cca-95f4-d4da9cffbd5c
#>  70:            <NA>                <NA> b6c82a7e-9ca6-488a-b94e-1d517650c68a
#>  71:            <NA>                <NA> a879cc2e-a7a0-40ed-8e0c-340ce27b3154
#>  72:            <NA>                <NA> 53609a02-b3f1-46b4-8206-ece1ba5c9206
#>  73:            <NA>                <NA> 7aa78287-5eec-4b3f-ae0a-05e5129f376e
#>  74:            <NA>                <NA> 65366f28-e1cd-42ed-8cb7-53e4467501fa
#>  75:            <NA>                <NA> 6fd54692-fe62-45d9-aca5-7a8acea9b5a6
#>  76:            <NA>                <NA> cf918bc2-d534-4480-88d9-d39c3536a48b
#>  77:            <NA>                <NA> 5ef3768d-4139-407d-87ce-ba203f7da758
#>  78:            <NA>                <NA> f1e6c0cc-60f0-454e-a37c-f33e66f37ce9
#>  79:            <NA>                <NA> fbccf59a-4338-447c-8590-8920bc8f77db
#>  80:            <NA>                <NA> 9a750094-7e81-43b3-a113-f4a4892ca2d8
#>  81:            <NA>                <NA> 7abd9e60-1024-42ec-a9c6-d22c8d7c9837
#>  82:            <NA>                <NA> 8b29eafc-1c21-4c94-b779-391105e3a898
#>  83:            <NA>                <NA> 47e975db-013e-4505-98a0-23d3bd36837f
#>  84:            <NA>                <NA> 25199857-f14b-49a5-b757-580efff8e82e
#>  85:            <NA>                <NA> 440127a7-7ede-42a1-82bc-e59b517fc845
#>  86:            <NA>                <NA> 6e3afe38-b0fa-4660-9a51-59e48a120228
#>  87:            <NA>                <NA> 776cb3c7-61b2-402c-957a-0c9120b4f23b
#>  88:            <NA>                <NA> dbc2ff3e-1a7b-4753-bc26-61a301c0daed
#>  89:            <NA>                <NA> 0861c75d-1cad-4246-a69f-aacde895cf68
#>  90:            <NA>                <NA> cdb53757-8afd-4d34-8159-58c8d704a424
#>  91:            <NA>                <NA> a717fbbf-d541-4e41-941f-2f5d22d8796a
#>  92:            <NA>                <NA> 4f33a0ae-dc07-4851-b452-7811ec8bf802
#>  93:            <NA>                <NA> ca9df2a1-f59c-4756-8243-7153ab595079
#>  94:            <NA>                <NA> 57ad2d2f-21b4-460e-88be-744578dc647b
#>  95:            <NA>                <NA> 1557cc0a-b1f7-4175-aa7d-3a3c075a6266
#>  96:            <NA>                <NA> a4b730ae-cd54-4e1d-bf32-b4a193aaeb55
#>  97:            <NA>                <NA> 3fbe98ea-93c2-4e26-bfd8-a7552d9bb14e
#>  98:            <NA>                <NA> 2cc52bc1-5563-4742-a06a-b45fa6cd1a97
#>  99:            <NA>                <NA> aa0014ea-081e-4026-a286-c2d2cb431ae2
#> 100:            <NA>                <NA> 493ea6c1-e252-43e7-b76c-12554c833683
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
