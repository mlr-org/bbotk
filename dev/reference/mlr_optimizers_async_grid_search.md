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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-10 10:22:01
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-10 10:22:01
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-10 10:22:01
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-10 10:22:01
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-10 10:22:01
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-10 10:22:01
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-10 10:22:01
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-10 10:22:01
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-10 10:22:01
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-10 10:22:01
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-10 10:22:01
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-10 10:22:01
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-10 10:22:01
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-10 10:22:01
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-10 10:22:01
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-10 10:22:01
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-10 10:22:01
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-10 10:22:01
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-10 10:22:01
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-10 10:22:01
#>  21:   failed  10.000000  5.0000000         NA 2026-04-10 10:22:01
#>  22:   failed  10.000000  3.8888889         NA 2026-04-10 10:22:01
#>  23:   failed  10.000000  2.7777778         NA 2026-04-10 10:22:01
#>  24:   failed  10.000000  1.6666667         NA 2026-04-10 10:22:01
#>  25:   failed  10.000000  0.5555556         NA 2026-04-10 10:22:01
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-10 10:22:01
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-10 10:22:01
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-10 10:22:01
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-10 10:22:01
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-10 10:22:01
#>  31:   failed   7.777778  5.0000000         NA 2026-04-10 10:22:01
#>  32:   failed   7.777778  3.8888889         NA 2026-04-10 10:22:01
#>  33:   failed   7.777778  2.7777778         NA 2026-04-10 10:22:01
#>  34:   failed   7.777778  1.6666667         NA 2026-04-10 10:22:01
#>  35:   failed   7.777778  0.5555556         NA 2026-04-10 10:22:01
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-10 10:22:01
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-10 10:22:01
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-10 10:22:01
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-10 10:22:01
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-10 10:22:01
#>  41:   failed   5.555556  5.0000000         NA 2026-04-10 10:22:01
#>  42:   failed   5.555556  3.8888889         NA 2026-04-10 10:22:01
#>  43:   failed   5.555556  2.7777778         NA 2026-04-10 10:22:01
#>  44:   failed   5.555556  1.6666667         NA 2026-04-10 10:22:01
#>  45:   failed   5.555556  0.5555556         NA 2026-04-10 10:22:01
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-10 10:22:01
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-10 10:22:01
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-10 10:22:01
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-10 10:22:01
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-10 10:22:01
#>  51:   failed   3.333333  5.0000000         NA 2026-04-10 10:22:01
#>  52:   failed   3.333333  3.8888889         NA 2026-04-10 10:22:01
#>  53:   failed   3.333333  2.7777778         NA 2026-04-10 10:22:01
#>  54:   failed   3.333333  1.6666667         NA 2026-04-10 10:22:01
#>  55:   failed   3.333333  0.5555556         NA 2026-04-10 10:22:01
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-10 10:22:01
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-10 10:22:01
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-10 10:22:01
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-10 10:22:01
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-10 10:22:01
#>  61:   failed   1.111111  5.0000000         NA 2026-04-10 10:22:01
#>  62:   failed   1.111111  3.8888889         NA 2026-04-10 10:22:01
#>  63:   failed   1.111111  2.7777778         NA 2026-04-10 10:22:01
#>  64:   failed   1.111111  1.6666667         NA 2026-04-10 10:22:01
#>  65:   failed   1.111111  0.5555556         NA 2026-04-10 10:22:01
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-10 10:22:01
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-10 10:22:01
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-10 10:22:01
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-10 10:22:01
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-10 10:22:01
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-10 10:22:01
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-10 10:22:01
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-10 10:22:01
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-10 10:22:01
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-10 10:22:01
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-10 10:22:01
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-10 10:22:01
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-10 10:22:01
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-10 10:22:01
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-10 10:22:01
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-10 10:22:01
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-10 10:22:01
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-10 10:22:01
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-10 10:22:01
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-10 10:22:01
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-10 10:22:01
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-10 10:22:01
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-10 10:22:01
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-10 10:22:01
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-10 10:22:01
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-10 10:22:01
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-10 10:22:01
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-10 10:22:01
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-10 10:22:01
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-10 10:22:01
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-10 10:22:01
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-10 10:22:01
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-10 10:22:01
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-10 10:22:01
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-10 10:22:01
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-10 10:22:02 c098909a-1926-4ed5-a23c-0d70b92dfc84
#>   2: sinking_raccoon 2026-04-10 10:22:02 2abd849e-8558-436b-8d53-ad5010b73a96
#>   3: sinking_raccoon 2026-04-10 10:22:02 67eb570e-4e49-47e3-9cd6-77bd08e23690
#>   4: sinking_raccoon 2026-04-10 10:22:02 3b2a6b01-9766-4690-814f-0be568e8b6af
#>   5: sinking_raccoon 2026-04-10 10:22:02 b27dd2b5-e889-4ab8-81e0-4018add9da2b
#>   6: sinking_raccoon 2026-04-10 10:22:02 2a20a843-4bb1-4d90-9ec8-0c6b97147e63
#>   7: sinking_raccoon 2026-04-10 10:22:02 2968cd86-a335-4c43-8bb5-7980b10cc3fa
#>   8: sinking_raccoon 2026-04-10 10:22:02 4aaaca0d-cc3a-426c-99b4-2932e393b64b
#>   9: sinking_raccoon 2026-04-10 10:22:02 d69d0092-1b1c-4fdb-bd8a-240783ca9b1e
#>  10: sinking_raccoon 2026-04-10 10:22:02 92a7d9fc-1f6d-41ac-a335-c602cd34bc1a
#>  11: sinking_raccoon 2026-04-10 10:22:02 a8132726-1510-4277-bca6-0336f584d479
#>  12: sinking_raccoon 2026-04-10 10:22:02 b53fd03f-5cbf-45b1-813b-998c14def3eb
#>  13: sinking_raccoon 2026-04-10 10:22:02 7ede5025-a020-47d2-8eba-fd04b2f7c10b
#>  14: sinking_raccoon 2026-04-10 10:22:02 23b0b964-83b7-445a-9cc7-d8f59cbb9e6a
#>  15: sinking_raccoon 2026-04-10 10:22:02 73b38c6b-9575-4d3e-8c84-0a7ab44bb4cb
#>  16: sinking_raccoon 2026-04-10 10:22:02 31232739-631d-45fd-a7c6-7de96eba2ac4
#>  17: sinking_raccoon 2026-04-10 10:22:02 17baf2b0-273c-4e18-b7cc-91173b7fbf0e
#>  18: sinking_raccoon 2026-04-10 10:22:02 9fd30d2c-e737-4414-83c7-e570967978c5
#>  19: sinking_raccoon 2026-04-10 10:22:02 c654bde5-9858-4ad9-bff1-c3bf6a04a3c1
#>  20: sinking_raccoon 2026-04-10 10:22:02 9e5e5687-2a87-4859-9665-562e2e5fc669
#>  21:            <NA>                <NA> 10a33dfe-a6bc-417d-afc0-8a93c992a395
#>  22:            <NA>                <NA> 9ecc0218-fe02-48e3-ae7e-a8028a0ef0f6
#>  23:            <NA>                <NA> d01174ab-ea07-4dc8-9ff1-fd07f0553e87
#>  24:            <NA>                <NA> 1efe541e-169d-46cb-bf66-ae108e77eb89
#>  25:            <NA>                <NA> bb15b1bd-fcbe-4149-a2d9-0309c6e4cf78
#>  26:            <NA>                <NA> 80accca1-e0f2-4ab0-9c29-db29fec9f63f
#>  27:            <NA>                <NA> 5bb7876c-0d12-43c0-a149-fdbe48642f2b
#>  28:            <NA>                <NA> 6720a03a-8145-4aa6-9eca-45979c84d793
#>  29:            <NA>                <NA> 331a1297-f941-4fa7-a888-f2a7e0e601e4
#>  30:            <NA>                <NA> 6fca281a-b368-4569-9da4-8abff902206e
#>  31:            <NA>                <NA> 30d037be-86c5-4e21-93ff-641c436d7c60
#>  32:            <NA>                <NA> cf783f15-76b1-40eb-8eac-a76d21e3eb49
#>  33:            <NA>                <NA> 2d584f91-a1a6-4ef6-bb71-5534e4c3a8da
#>  34:            <NA>                <NA> 078115c4-c548-4043-835a-c117b754d5a3
#>  35:            <NA>                <NA> bc04cc74-36b8-46e8-9380-f220d53cce6a
#>  36:            <NA>                <NA> 2a9fc783-3d45-49c7-aa0f-dedfe6d2bce2
#>  37:            <NA>                <NA> abee0758-5fe1-48dd-aa78-378737966d5d
#>  38:            <NA>                <NA> 968f4852-63ae-401d-b8c2-c331dfbd61b0
#>  39:            <NA>                <NA> 2111a7e1-7399-4059-8462-3b193490972c
#>  40:            <NA>                <NA> 3c385d40-e104-41f4-afe5-2aef9688c22e
#>  41:            <NA>                <NA> 62ced2c6-1827-4e9b-8966-75e48fe63da4
#>  42:            <NA>                <NA> 4231106a-39ac-4b25-89f6-f80f4e08c03f
#>  43:            <NA>                <NA> 9be84156-71c5-4b23-9d34-44a9b595eabc
#>  44:            <NA>                <NA> 0c7f0d66-3c50-4a5f-b8d5-59123b6ec7b7
#>  45:            <NA>                <NA> 3256b4a0-6404-4651-afda-05da8399ce2e
#>  46:            <NA>                <NA> e9b51bf4-15dc-4f58-b4a8-bac83aabc598
#>  47:            <NA>                <NA> 2cb662cb-de18-4400-a9a2-c355e27fe006
#>  48:            <NA>                <NA> 8ba1ac6c-65dc-49d2-9ee0-2126c29be912
#>  49:            <NA>                <NA> ad75096f-03b8-4bf8-9fd2-a84ff576c83c
#>  50:            <NA>                <NA> 43c4fcad-c880-4024-b0b7-d57b5a5619d9
#>  51:            <NA>                <NA> 4a584e66-9ee1-4d90-b110-175e28e77f46
#>  52:            <NA>                <NA> a65d6f86-2962-48da-b293-128fb80350b5
#>  53:            <NA>                <NA> c7c68360-4eab-4d3c-9b94-7d3ca5596b03
#>  54:            <NA>                <NA> 88197ce1-0b43-4de8-bcdc-828ec435718f
#>  55:            <NA>                <NA> 3a5e0050-65ee-4fbd-9b8b-09a3e1596f02
#>  56:            <NA>                <NA> a7faeec9-56aa-4157-a39b-72e967284ca5
#>  57:            <NA>                <NA> 99b55b89-d026-4373-b210-24caa162e00c
#>  58:            <NA>                <NA> b5b32c4d-0432-4e08-9c26-9d725d9f635b
#>  59:            <NA>                <NA> b385963f-2968-436d-86db-911b769fd683
#>  60:            <NA>                <NA> 54ef5803-026d-4e13-aadd-d2a4db0438da
#>  61:            <NA>                <NA> 427af545-1b44-4bb1-8488-158fe939288b
#>  62:            <NA>                <NA> f72601b5-7acf-4bac-bcdf-44712cbf7b24
#>  63:            <NA>                <NA> 71b6cd28-9fda-4c37-ae88-8c38587596ab
#>  64:            <NA>                <NA> 1a6d12bb-a076-4c36-ba9d-06375f7226fa
#>  65:            <NA>                <NA> 06ef2276-6edb-4fa4-93b3-6332d3af6054
#>  66:            <NA>                <NA> 2fe63d16-65e5-4fdd-9e4e-f712e5c7a5ca
#>  67:            <NA>                <NA> 6f01054d-8c0c-4f9b-8f8d-e30c00c2f040
#>  68:            <NA>                <NA> 8eec2064-8caa-4f25-a0ce-ab2bf2a4e598
#>  69:            <NA>                <NA> 3ae940fb-4bba-4e93-b80f-9df499414638
#>  70:            <NA>                <NA> 93dc354c-37fb-42b8-8d91-350182f0ce16
#>  71:            <NA>                <NA> 701e227c-f943-4ebf-903f-1cd822f7e323
#>  72:            <NA>                <NA> a3a76071-6b4a-4637-860b-b6a86ff6cf9a
#>  73:            <NA>                <NA> c5294ffb-4c3f-41ac-8bec-2b68afa13843
#>  74:            <NA>                <NA> 6827b6a0-d28f-45eb-88a3-e8cfb7e1446b
#>  75:            <NA>                <NA> c2e4f5e3-f9b4-489e-aae6-314d30f0c127
#>  76:            <NA>                <NA> 5a8a47d9-5b45-4fa5-856d-9e9685cf6d16
#>  77:            <NA>                <NA> 39fdde83-09a4-4d17-9f5b-5524e9a69577
#>  78:            <NA>                <NA> 17859ce2-fc53-49d2-9bf1-7c26c22206dc
#>  79:            <NA>                <NA> 40b3080b-9b0d-43d8-a19d-57b462121bfb
#>  80:            <NA>                <NA> ac279c10-d08a-4201-9be1-b8adf1bbc52a
#>  81:            <NA>                <NA> 4c6d17f1-26fb-43ca-82fb-d4a6eb8103d6
#>  82:            <NA>                <NA> 6634c6cc-ad53-40a5-9bed-7e9e825243a9
#>  83:            <NA>                <NA> 731e8128-a7ac-4557-a634-b6a2c5e1936e
#>  84:            <NA>                <NA> e82c1425-1c57-496d-9905-16e4cfab686d
#>  85:            <NA>                <NA> aaf1d266-bb13-4ab6-af1b-c8d49cfa6b24
#>  86:            <NA>                <NA> 47a0ef2b-3a62-4a8a-8688-e2f3b440ae4f
#>  87:            <NA>                <NA> 7d0c52fc-86e7-4895-bde7-6316e7f67b51
#>  88:            <NA>                <NA> 84eed47c-3891-4a8b-acfd-b2f01a0cc137
#>  89:            <NA>                <NA> 91b75fc0-00be-41f9-b55b-0b31e82df0ec
#>  90:            <NA>                <NA> 98052308-aac4-4ce9-b1d0-892e50b53045
#>  91:            <NA>                <NA> 272dd9eb-c38d-4a6d-885b-4db6637cf5f5
#>  92:            <NA>                <NA> f8fbfc4d-f5a8-4d56-9c4d-b9486f8afed4
#>  93:            <NA>                <NA> 96c39a61-e72b-4acb-b5fa-cabf5838b190
#>  94:            <NA>                <NA> 5fe76429-c878-416f-92c4-a27b50f459df
#>  95:            <NA>                <NA> ce48387f-1e3e-4b94-a324-488af0671b71
#>  96:            <NA>                <NA> 2a358fa3-376d-49be-a5aa-e857006fd82c
#>  97:            <NA>                <NA> 2c262b5d-3a80-4cc9-be9e-ef956d80cc90
#>  98:            <NA>                <NA> 34299c64-907c-4ec7-ba66-00dff9e1bda2
#>  99:            <NA>                <NA> 4d0978e6-a7f6-49a6-8fb5-ce55f8e55fe6
#> 100:            <NA>                <NA> 48290c73-4619-49c9-b545-4c0c89ad7edf
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
