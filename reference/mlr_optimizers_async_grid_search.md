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

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_grid_search")
    opt("async_grid_search")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of points to try in a batch.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-new)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-08 06:02:58
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-08 06:02:58
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-08 06:02:58
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-08 06:02:58
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-08 06:02:58
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-08 06:02:58
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-08 06:02:58
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-08 06:02:58
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-08 06:02:58
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-08 06:02:58
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-08 06:02:58
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-08 06:02:58
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-08 06:02:58
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-08 06:02:58
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-08 06:02:58
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-08 06:02:58
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-08 06:02:58
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-08 06:02:58
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-08 06:02:58
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-08 06:02:58
#>  21:   failed  10.000000  5.0000000         NA 2026-04-08 06:02:58
#>  22:   failed  10.000000  3.8888889         NA 2026-04-08 06:02:58
#>  23:   failed  10.000000  2.7777778         NA 2026-04-08 06:02:58
#>  24:   failed  10.000000  1.6666667         NA 2026-04-08 06:02:58
#>  25:   failed  10.000000  0.5555556         NA 2026-04-08 06:02:58
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-08 06:02:58
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-08 06:02:58
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-08 06:02:58
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-08 06:02:58
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-08 06:02:58
#>  31:   failed   7.777778  5.0000000         NA 2026-04-08 06:02:58
#>  32:   failed   7.777778  3.8888889         NA 2026-04-08 06:02:58
#>  33:   failed   7.777778  2.7777778         NA 2026-04-08 06:02:58
#>  34:   failed   7.777778  1.6666667         NA 2026-04-08 06:02:58
#>  35:   failed   7.777778  0.5555556         NA 2026-04-08 06:02:58
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-08 06:02:58
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-08 06:02:58
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-08 06:02:58
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-08 06:02:58
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-08 06:02:58
#>  41:   failed   5.555556  5.0000000         NA 2026-04-08 06:02:58
#>  42:   failed   5.555556  3.8888889         NA 2026-04-08 06:02:58
#>  43:   failed   5.555556  2.7777778         NA 2026-04-08 06:02:58
#>  44:   failed   5.555556  1.6666667         NA 2026-04-08 06:02:58
#>  45:   failed   5.555556  0.5555556         NA 2026-04-08 06:02:58
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-08 06:02:58
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-08 06:02:58
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-08 06:02:58
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-08 06:02:58
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-08 06:02:58
#>  51:   failed   3.333333  5.0000000         NA 2026-04-08 06:02:58
#>  52:   failed   3.333333  3.8888889         NA 2026-04-08 06:02:58
#>  53:   failed   3.333333  2.7777778         NA 2026-04-08 06:02:58
#>  54:   failed   3.333333  1.6666667         NA 2026-04-08 06:02:58
#>  55:   failed   3.333333  0.5555556         NA 2026-04-08 06:02:58
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-08 06:02:58
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-08 06:02:58
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-08 06:02:58
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-08 06:02:58
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-08 06:02:58
#>  61:   failed   1.111111  5.0000000         NA 2026-04-08 06:02:58
#>  62:   failed   1.111111  3.8888889         NA 2026-04-08 06:02:58
#>  63:   failed   1.111111  2.7777778         NA 2026-04-08 06:02:58
#>  64:   failed   1.111111  1.6666667         NA 2026-04-08 06:02:58
#>  65:   failed   1.111111  0.5555556         NA 2026-04-08 06:02:58
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-08 06:02:58
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-08 06:02:58
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-08 06:02:58
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-08 06:02:58
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-08 06:02:58
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-08 06:02:58
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-08 06:02:58
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-08 06:02:58
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-08 06:02:58
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-08 06:02:58
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-08 06:02:58
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-08 06:02:58
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-08 06:02:58
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-08 06:02:58
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-08 06:02:58
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-08 06:02:58
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-08 06:02:58
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-08 06:02:58
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-08 06:02:58
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-08 06:02:58
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-08 06:02:58
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-08 06:02:58
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-08 06:02:58
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-08 06:02:58
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-08 06:02:58
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-08 06:02:58
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-08 06:02:58
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-08 06:02:58
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-08 06:02:58
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-08 06:02:58
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-08 06:02:58
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-08 06:02:58
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-08 06:02:58
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-08 06:02:58
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-08 06:02:58
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-08 06:02:59 1f76a243-5ffc-4718-b572-6710e208c738
#>   2: sinking_raccoon 2026-04-08 06:02:59 76b318ea-8822-44a1-a9d4-c23aab3bbd8a
#>   3: sinking_raccoon 2026-04-08 06:02:59 3d0fac0c-4728-4a31-ad0d-1f62cc8130ee
#>   4: sinking_raccoon 2026-04-08 06:02:59 f8197382-aa18-4b89-b95b-ce6091217c9d
#>   5: sinking_raccoon 2026-04-08 06:02:59 8f9641ce-c9bc-4d25-af22-aa7b6efc1113
#>   6: sinking_raccoon 2026-04-08 06:02:59 1bfcdfd7-2489-47f0-8b4a-04ca84c9aff4
#>   7: sinking_raccoon 2026-04-08 06:02:59 6ece4002-1955-4d66-9a20-b029890ea670
#>   8: sinking_raccoon 2026-04-08 06:02:59 09f8c3be-bc57-4fd1-a613-74eb6fb10c97
#>   9: sinking_raccoon 2026-04-08 06:02:59 f65cc79e-4796-49b5-9e9c-b9b246c3eb6f
#>  10: sinking_raccoon 2026-04-08 06:02:59 99bec8d3-7253-4721-b2f0-749929264495
#>  11: sinking_raccoon 2026-04-08 06:02:59 69a7c496-b01f-4bba-a67a-9964302cf44d
#>  12: sinking_raccoon 2026-04-08 06:02:59 3e8d49e8-22db-48d5-845c-98ca265afa52
#>  13: sinking_raccoon 2026-04-08 06:02:59 c9fb7332-53a5-4308-900d-3d05e188e02b
#>  14: sinking_raccoon 2026-04-08 06:02:59 843afefd-e0e3-4fec-8265-60792876f5fc
#>  15: sinking_raccoon 2026-04-08 06:02:59 b54dcf33-80c6-4eca-a221-889e43128e0b
#>  16: sinking_raccoon 2026-04-08 06:02:59 b088e60d-21d4-485f-a256-2746818edefc
#>  17: sinking_raccoon 2026-04-08 06:02:59 3afba7f4-cad9-4fc7-ae9e-5d223b651ca9
#>  18: sinking_raccoon 2026-04-08 06:02:59 447b4bb0-72c6-4be1-bcaa-23a00632918f
#>  19: sinking_raccoon 2026-04-08 06:02:59 a90bcee4-d325-4530-a7c2-2d5a710222ef
#>  20: sinking_raccoon 2026-04-08 06:02:59 46cdde8a-c24a-4a8e-958c-4dec0a6b2cec
#>  21:            <NA>                <NA> 84cef4b7-1376-42a0-b487-9f11c1163429
#>  22:            <NA>                <NA> f7e4ad59-66de-4c93-b249-4e7be402b20e
#>  23:            <NA>                <NA> 2e0647e7-6bc5-4b7a-b895-36b88149d50d
#>  24:            <NA>                <NA> 03de5376-20c7-4831-9677-8d21b43f092b
#>  25:            <NA>                <NA> bf125ee9-4fd2-4783-b15a-c21e3328975a
#>  26:            <NA>                <NA> aedfb457-270f-4128-a2a0-6bfceacbf91c
#>  27:            <NA>                <NA> 3f9b0d67-24d6-46d0-af44-ca53eff25106
#>  28:            <NA>                <NA> 05765aa8-c60c-4ad3-bbca-ebc1beb3c32b
#>  29:            <NA>                <NA> f9f7b76e-5491-47fb-b79b-df82dc5d1470
#>  30:            <NA>                <NA> 2a23565c-1fc7-4dc2-bbbd-4c81a499addd
#>  31:            <NA>                <NA> c4b69c9f-5dc7-41c7-86a5-99faad314e8c
#>  32:            <NA>                <NA> 1dff4d89-eadd-4934-93b4-372aa3f0afb1
#>  33:            <NA>                <NA> f5632d14-a7cb-4fed-99cd-93f48b10102e
#>  34:            <NA>                <NA> dec60ea4-d0cf-4756-ba1e-756f04a1ec6d
#>  35:            <NA>                <NA> 0285a44b-0f4a-467c-84f0-abf0a6ce7b31
#>  36:            <NA>                <NA> 9c1facad-0bf4-4ffd-abce-351acae1a4b0
#>  37:            <NA>                <NA> 2261bfa2-c135-425b-9d87-7bcdc90a8009
#>  38:            <NA>                <NA> c41a1f19-0104-4d13-884a-8e5e5b7a9414
#>  39:            <NA>                <NA> a210f039-bb70-4b6d-87df-0382a36e8973
#>  40:            <NA>                <NA> ee3a832e-bbb0-411d-be81-da064cff76ac
#>  41:            <NA>                <NA> 5d0b3faf-d851-4385-8090-324c03653989
#>  42:            <NA>                <NA> 1d7e9a74-0a0e-438b-a0f6-4a2256d28cac
#>  43:            <NA>                <NA> 3e3201fa-e0ab-48b5-835d-5ee09f601b6c
#>  44:            <NA>                <NA> 53c2e6af-04af-476f-bb91-f268df000931
#>  45:            <NA>                <NA> e272dd20-57f9-4fa8-bca1-4eea06324af0
#>  46:            <NA>                <NA> f0fc030c-f5e0-4a31-a138-e323d48cd7a7
#>  47:            <NA>                <NA> d4843d17-6f1d-406d-8f15-984a43838919
#>  48:            <NA>                <NA> caa649fb-80ca-4e4c-be98-5d0c1e78884a
#>  49:            <NA>                <NA> cf1b5822-5c47-44a1-a061-a80461ddf38c
#>  50:            <NA>                <NA> 9c3ca00b-5db1-4b82-91e4-f858fcfff4e9
#>  51:            <NA>                <NA> 88199086-806e-4f8b-9936-68c4a09932f4
#>  52:            <NA>                <NA> 4e4b8ce9-ebe5-4617-9f99-6ad8484af6c5
#>  53:            <NA>                <NA> 8227a358-4cc0-4f33-8ca5-9a6ba739dd8a
#>  54:            <NA>                <NA> 40ea8e3d-56eb-43ca-95fb-79ab0b51ccef
#>  55:            <NA>                <NA> e84faa71-d04b-4d0b-8f0c-5fadc274cb54
#>  56:            <NA>                <NA> 716d89a0-d376-481d-a72f-00eda8f5081e
#>  57:            <NA>                <NA> 85327b1a-f748-4590-95b9-139c1efb008a
#>  58:            <NA>                <NA> 37569174-fbda-48bd-ab24-b27e061b70c1
#>  59:            <NA>                <NA> ca9120bd-a1d4-4b6e-8fc1-a3ed53d47126
#>  60:            <NA>                <NA> 12d5a34c-b5cf-46c1-8cb8-5eb824c47c1c
#>  61:            <NA>                <NA> eff2b317-ead8-4dee-9b8d-4ca0132f7fd6
#>  62:            <NA>                <NA> 8eb66ea6-beb2-4628-9602-a6ef1d86e5ff
#>  63:            <NA>                <NA> 857b3d4d-5ac0-4955-ac01-938f9ff8112d
#>  64:            <NA>                <NA> f2aa95e4-7e78-4902-9e90-a7627ffed844
#>  65:            <NA>                <NA> 973047cc-e5aa-4a4e-91d4-8fcada8e9c2f
#>  66:            <NA>                <NA> 56fba7ab-4175-4bc9-8785-fffe2cabd94a
#>  67:            <NA>                <NA> 68a57ef8-0652-4d7c-9e6c-f4798a07039b
#>  68:            <NA>                <NA> 859886b3-c631-4b2c-9fc4-82dbe67f182a
#>  69:            <NA>                <NA> 18a65dc2-b2cb-486d-b7e4-05c1308772ee
#>  70:            <NA>                <NA> 2684dec6-425e-43cc-af0e-4aeafa65b6b7
#>  71:            <NA>                <NA> 89fe0e0f-c52b-4016-a173-4f66dc3a2c5d
#>  72:            <NA>                <NA> 95711890-7abb-41c9-9063-59db487e7586
#>  73:            <NA>                <NA> d4c8e2c0-b78d-424c-a6e6-a6cbe76d0888
#>  74:            <NA>                <NA> 3d79c0b8-05be-41d2-b6f2-6c0d75b864d8
#>  75:            <NA>                <NA> 8f5d11fe-1b72-4864-b746-3c06343d8866
#>  76:            <NA>                <NA> 85c39d5b-b719-4fcb-b903-63c11e33c330
#>  77:            <NA>                <NA> 2cbcb96c-6385-4fd2-9cde-cf01f382f674
#>  78:            <NA>                <NA> 988f71c0-8c02-4538-9e5a-93b6cb4c7532
#>  79:            <NA>                <NA> 5dbbb4e9-867a-4f35-90a4-d2f46c9fea82
#>  80:            <NA>                <NA> 1b6c5e54-a788-42d6-9e60-f38fdf0b7984
#>  81:            <NA>                <NA> 02477254-537e-42e3-8cc8-1eec842d16e1
#>  82:            <NA>                <NA> 5e697cbe-ebc8-43ea-9ae0-984bbd8ea504
#>  83:            <NA>                <NA> d148c1de-2718-4154-b20b-e250bc997ab8
#>  84:            <NA>                <NA> e50b9a17-953d-4fde-a7af-100adc2da144
#>  85:            <NA>                <NA> 2cc2a3b0-c4dc-47c5-8a6b-18134755ee21
#>  86:            <NA>                <NA> 82e9759a-8a3f-4bfe-b7f8-f420773bf9b9
#>  87:            <NA>                <NA> bebf7e67-c0e8-4c28-ae8a-e77d9ea9fb8c
#>  88:            <NA>                <NA> ef436ac3-8a7d-40a6-9ec2-00eaa0e922a0
#>  89:            <NA>                <NA> 771e857e-8436-410c-8baa-8c8d2c21b36a
#>  90:            <NA>                <NA> 7d3c5aba-7d2a-4235-8129-ada1db339260
#>  91:            <NA>                <NA> 7f90603a-2735-4b81-bbb0-06480233b87c
#>  92:            <NA>                <NA> 5ee77938-241e-41ff-aeee-7b5d78a59b6d
#>  93:            <NA>                <NA> fef1e41d-ceba-42b9-ac0d-ef99938bef92
#>  94:            <NA>                <NA> a43a8b4b-567d-4192-8cf8-9a3efe9e1718
#>  95:            <NA>                <NA> a836bcf3-4213-40dc-aa83-95408395314d
#>  96:            <NA>                <NA> 76b14e32-0b6b-418d-a86b-088c789404f0
#>  97:            <NA>                <NA> 194adeb2-8631-478d-9c0c-74375e2e8d3d
#>  98:            <NA>                <NA> 67c57c3e-1aa6-47e5-afda-831c319f36f4
#>  99:            <NA>                <NA> fc9528e8-5975-4fc8-b0b2-eaf1122cc06d
#> 100:            <NA>                <NA> 4f7562ff-be65-4fff-841f-34c5fe952bfe
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
