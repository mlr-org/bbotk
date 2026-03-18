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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-18 15:32:13
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-18 15:32:13
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-18 15:32:13
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-18 15:32:13
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-18 15:32:13
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-18 15:32:13
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-18 15:32:13
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-18 15:32:13
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-18 15:32:13
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-18 15:32:13
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-18 15:32:13
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-18 15:32:13
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-18 15:32:13
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-18 15:32:13
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-18 15:32:13
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-18 15:32:13
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-18 15:32:13
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-18 15:32:13
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-18 15:32:13
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-18 15:32:13
#>  21:   failed  10.000000  5.0000000         NA 2026-03-18 15:32:13
#>  22:   failed  10.000000  3.8888889         NA 2026-03-18 15:32:13
#>  23:   failed  10.000000  2.7777778         NA 2026-03-18 15:32:13
#>  24:   failed  10.000000  1.6666667         NA 2026-03-18 15:32:13
#>  25:   failed  10.000000  0.5555556         NA 2026-03-18 15:32:13
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-18 15:32:13
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-18 15:32:13
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-18 15:32:13
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-18 15:32:13
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-18 15:32:13
#>  31:   failed   7.777778  5.0000000         NA 2026-03-18 15:32:13
#>  32:   failed   7.777778  3.8888889         NA 2026-03-18 15:32:13
#>  33:   failed   7.777778  2.7777778         NA 2026-03-18 15:32:13
#>  34:   failed   7.777778  1.6666667         NA 2026-03-18 15:32:13
#>  35:   failed   7.777778  0.5555556         NA 2026-03-18 15:32:13
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-18 15:32:13
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-18 15:32:13
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-18 15:32:13
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-18 15:32:13
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-18 15:32:13
#>  41:   failed   5.555556  5.0000000         NA 2026-03-18 15:32:13
#>  42:   failed   5.555556  3.8888889         NA 2026-03-18 15:32:13
#>  43:   failed   5.555556  2.7777778         NA 2026-03-18 15:32:13
#>  44:   failed   5.555556  1.6666667         NA 2026-03-18 15:32:13
#>  45:   failed   5.555556  0.5555556         NA 2026-03-18 15:32:13
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-18 15:32:13
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-18 15:32:13
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-18 15:32:13
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-18 15:32:13
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-18 15:32:13
#>  51:   failed   3.333333  5.0000000         NA 2026-03-18 15:32:13
#>  52:   failed   3.333333  3.8888889         NA 2026-03-18 15:32:13
#>  53:   failed   3.333333  2.7777778         NA 2026-03-18 15:32:13
#>  54:   failed   3.333333  1.6666667         NA 2026-03-18 15:32:13
#>  55:   failed   3.333333  0.5555556         NA 2026-03-18 15:32:13
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-18 15:32:13
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-18 15:32:13
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-18 15:32:13
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-18 15:32:13
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-18 15:32:13
#>  61:   failed   1.111111  5.0000000         NA 2026-03-18 15:32:13
#>  62:   failed   1.111111  3.8888889         NA 2026-03-18 15:32:13
#>  63:   failed   1.111111  2.7777778         NA 2026-03-18 15:32:13
#>  64:   failed   1.111111  1.6666667         NA 2026-03-18 15:32:13
#>  65:   failed   1.111111  0.5555556         NA 2026-03-18 15:32:13
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-18 15:32:13
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-18 15:32:13
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-18 15:32:13
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-18 15:32:13
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-18 15:32:13
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-18 15:32:13
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-18 15:32:13
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-18 15:32:13
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-18 15:32:13
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-18 15:32:13
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-18 15:32:13
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-18 15:32:13
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-18 15:32:13
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-18 15:32:13
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-18 15:32:13
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-18 15:32:13
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-18 15:32:13
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-18 15:32:13
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-18 15:32:13
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-18 15:32:13
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-18 15:32:13
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-18 15:32:13
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-18 15:32:13
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-18 15:32:13
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-18 15:32:13
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-18 15:32:13
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-18 15:32:13
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-18 15:32:13
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-18 15:32:13
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-18 15:32:13
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-18 15:32:13
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-18 15:32:13
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-18 15:32:13
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-18 15:32:13
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-18 15:32:13
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-18 15:32:14 c9da9f15-4166-47ba-904a-77702065c475
#>   2: sinking_raccoon 2026-03-18 15:32:14 efe1bcc0-9189-43d9-935e-30af8e13ab50
#>   3: sinking_raccoon 2026-03-18 15:32:14 0efc4745-0170-4f85-a86b-e29020471316
#>   4: sinking_raccoon 2026-03-18 15:32:14 5c88f6f7-9cf0-4ca2-bb7c-5422149651bf
#>   5: sinking_raccoon 2026-03-18 15:32:14 d9f1d7a5-7600-4b69-a37b-2ca8ea1d685e
#>   6: sinking_raccoon 2026-03-18 15:32:14 14dadfb7-cfbf-4e94-a446-5d98818160f9
#>   7: sinking_raccoon 2026-03-18 15:32:14 71ffc644-7859-4654-9e75-153301d0a7da
#>   8: sinking_raccoon 2026-03-18 15:32:14 ce4cffb8-b285-4294-b393-f05792f2d6f1
#>   9: sinking_raccoon 2026-03-18 15:32:14 94803645-a947-4319-96f3-a533781ea99b
#>  10: sinking_raccoon 2026-03-18 15:32:14 3c866acf-8430-46de-8f92-592d2b5ebcd0
#>  11: sinking_raccoon 2026-03-18 15:32:14 40795062-b1cc-45b9-9952-af5cbd7924e8
#>  12: sinking_raccoon 2026-03-18 15:32:14 beb5426e-55db-4662-bfa9-9a651aa69a86
#>  13: sinking_raccoon 2026-03-18 15:32:14 4ff1ed7c-1259-42c6-9fab-de351a56dd6c
#>  14: sinking_raccoon 2026-03-18 15:32:14 718f9e70-b6f5-4e39-a95e-ac92986851c5
#>  15: sinking_raccoon 2026-03-18 15:32:14 1ffe2a0a-1662-476b-af74-30be3b19736b
#>  16: sinking_raccoon 2026-03-18 15:32:14 a7536dba-1496-40c4-a542-262daf89e94e
#>  17: sinking_raccoon 2026-03-18 15:32:14 8368a71a-26fd-480b-ba28-a8338ee09e5e
#>  18: sinking_raccoon 2026-03-18 15:32:14 0fc050ca-4c3b-4b19-b719-c5e1be459731
#>  19: sinking_raccoon 2026-03-18 15:32:14 0ac777f6-9edf-4db5-a24a-0dc8d768dae4
#>  20: sinking_raccoon 2026-03-18 15:32:14 e65d0688-fc99-4e47-ae77-f1967f655a0e
#>  21:            <NA>                <NA> d1fd4ff8-9021-40a3-9e73-a415d63be9c9
#>  22:            <NA>                <NA> 2e04f8b8-daa0-44c7-b30e-6ef128e1fb4e
#>  23:            <NA>                <NA> 1bc1e9d8-bc72-4642-994a-9d0651b6c0d9
#>  24:            <NA>                <NA> 5b99de1c-09fb-4177-98a8-6be3bd989c2b
#>  25:            <NA>                <NA> 2614a7dc-e674-47f3-9f96-54be6393aa7b
#>  26:            <NA>                <NA> 21e920e3-4f1d-4c5a-8a6d-8b771c9b3616
#>  27:            <NA>                <NA> bae127cf-16e6-4648-9e06-07d4da9bf4ff
#>  28:            <NA>                <NA> 235fab13-656a-4ecf-bbee-a504e8bd3634
#>  29:            <NA>                <NA> bfd13bb5-35fb-4620-9e49-34f293a53e23
#>  30:            <NA>                <NA> 7b3127da-7b58-44d6-ba0e-9ea14f57bff1
#>  31:            <NA>                <NA> b45f0cab-4b78-4cf8-9d65-b183cf6b3c98
#>  32:            <NA>                <NA> 87993822-8a68-4510-bfc7-86dc19e6962d
#>  33:            <NA>                <NA> b838197a-e354-4d40-af3c-fcd8237eb336
#>  34:            <NA>                <NA> aebd22c4-5134-45ab-a3b7-21f5f92ac178
#>  35:            <NA>                <NA> d89d61c9-b4c6-40a2-a833-bfd143a1a078
#>  36:            <NA>                <NA> a581cb51-4a3a-4ddd-ac6c-cc2af1113213
#>  37:            <NA>                <NA> 62ba5267-00e8-4020-969d-8610cabfe1a9
#>  38:            <NA>                <NA> 30cf1256-08ce-450f-9175-18907b65f62a
#>  39:            <NA>                <NA> 090cb784-b8f0-4d2f-8392-96b66c907084
#>  40:            <NA>                <NA> 994407dc-865b-4afc-97cb-4d04bc35f970
#>  41:            <NA>                <NA> b6ad9162-559b-451d-96c3-d60f92df3718
#>  42:            <NA>                <NA> 28bd6745-6a22-401e-b22b-43200f177415
#>  43:            <NA>                <NA> 1bbaa7c2-8173-4c59-860a-9d16e9b1adda
#>  44:            <NA>                <NA> 078f1a21-b42c-4859-a904-b93c2f189d62
#>  45:            <NA>                <NA> 04061820-1f6d-4ca6-83eb-760eb8fdc4f6
#>  46:            <NA>                <NA> 367d63bc-0ad8-4e77-b4b0-7f11bdc5e154
#>  47:            <NA>                <NA> 91f9bd7e-1197-4649-a06f-004c162ce030
#>  48:            <NA>                <NA> 794195e9-76c8-4438-8748-d427bf8e83ce
#>  49:            <NA>                <NA> b9603981-9227-4d68-a8c2-28d408cabd6e
#>  50:            <NA>                <NA> f6879af9-689e-4f34-b886-b731f7fcd99d
#>  51:            <NA>                <NA> e13aa98b-5ce5-4247-bb51-0e484eb4023d
#>  52:            <NA>                <NA> c43373c8-50a8-4f1c-abca-45c48832e334
#>  53:            <NA>                <NA> 93b571f4-c026-4a27-9076-efe37c89cc05
#>  54:            <NA>                <NA> e30a91ce-bcce-46ec-a6da-3e1a580451ae
#>  55:            <NA>                <NA> 648749b6-baf3-478f-a19e-0c2daf819af2
#>  56:            <NA>                <NA> b272d6cf-6312-4914-816a-bc8edd6a8306
#>  57:            <NA>                <NA> 01e58cb2-ffe1-49e7-a10d-6865f1a8c8a4
#>  58:            <NA>                <NA> 9e8ca203-549b-4fb3-acef-08f1f6193999
#>  59:            <NA>                <NA> ee1a0eb1-d0ee-42ab-882f-5cf053338dc9
#>  60:            <NA>                <NA> 70226b81-8c1c-4cfa-ad45-bef9bb66e7aa
#>  61:            <NA>                <NA> 89000bef-5754-4bf5-9f45-53331705341c
#>  62:            <NA>                <NA> 4729bcd1-55b4-49b6-9493-69741d7d5fca
#>  63:            <NA>                <NA> cf12a825-5f64-40f4-a826-a840a4203c74
#>  64:            <NA>                <NA> e567717d-6765-4a28-9092-0ee2b5b79709
#>  65:            <NA>                <NA> b05d4706-7b00-4012-874e-755fb3515211
#>  66:            <NA>                <NA> ab82aa99-904a-4d88-95fd-7e1089a21a5b
#>  67:            <NA>                <NA> dba4f3b8-6fe0-44f9-af05-914e77d07cb8
#>  68:            <NA>                <NA> a773a7e1-5290-4201-ae07-3ef60026fae2
#>  69:            <NA>                <NA> 1604bb58-baec-47fc-8142-d2b2fbeeb604
#>  70:            <NA>                <NA> d088e9fd-b00d-4106-830f-f4f7b61898e3
#>  71:            <NA>                <NA> 7ef466d6-d866-428c-8023-1316432f4cc5
#>  72:            <NA>                <NA> 59c111ba-3018-4fba-9dd4-2f3169187bc6
#>  73:            <NA>                <NA> 117f69cd-f8ea-4f0e-a759-1da9d75ad310
#>  74:            <NA>                <NA> 8a29bdf3-64e4-4531-995b-f6b43ab881ea
#>  75:            <NA>                <NA> 7836e790-a0d8-45ff-93ce-2a8261027709
#>  76:            <NA>                <NA> c30461d2-d5d7-42c3-8438-dce68fe2aa9e
#>  77:            <NA>                <NA> 9270ef45-61e6-4fed-97d3-096dd154acdf
#>  78:            <NA>                <NA> 7884f739-b124-4f01-b61e-986b38ada529
#>  79:            <NA>                <NA> 0da34984-ec27-4e6c-8c48-3ba6101aad0c
#>  80:            <NA>                <NA> 85c82687-cb0b-4c8d-bb44-7c1189c4c998
#>  81:            <NA>                <NA> 2ca761d8-48aa-433f-81b1-8051fc8f2a58
#>  82:            <NA>                <NA> dd7851e0-50bc-4cb5-b5ff-ada99d1bfa33
#>  83:            <NA>                <NA> 45997fd0-413e-4f7b-9ac0-3a764856282e
#>  84:            <NA>                <NA> 85d94dc2-26da-4759-8796-a3bb6824287f
#>  85:            <NA>                <NA> 30670125-f03e-4585-bae7-68f3adff97eb
#>  86:            <NA>                <NA> e1d1184e-826c-46bf-957f-c62ee8f4e34c
#>  87:            <NA>                <NA> 0a26b647-9b80-4d1f-9245-1955cf957866
#>  88:            <NA>                <NA> 186078fa-ffb2-4f66-a059-5e19fd458837
#>  89:            <NA>                <NA> afcbd4c5-ede7-4de2-8ef8-3f84c274b3a5
#>  90:            <NA>                <NA> eee7051c-ddf4-491a-b4c9-e4ffd9d85db5
#>  91:            <NA>                <NA> d5e57140-85c3-4026-93f2-cc058dba6bd2
#>  92:            <NA>                <NA> bbe17568-1195-4b01-985c-18bd6286ec0e
#>  93:            <NA>                <NA> 9b7072ff-a2fe-4cca-b8c8-8db49313c052
#>  94:            <NA>                <NA> d6bce910-dda6-4f68-a5c4-d65ff9070dd0
#>  95:            <NA>                <NA> 0c0e476c-4332-43a2-9fcf-50e9983e7688
#>  96:            <NA>                <NA> de4fa7b9-5f99-489c-b999-afbd9061fe2e
#>  97:            <NA>                <NA> 8f71933a-8f6d-4619-8bff-e585aad6aced
#>  98:            <NA>                <NA> 3ed1e2a4-ae9e-4203-b809-f6814fe8ec77
#>  99:            <NA>                <NA> ddddc07c-1c3e-4a05-b338-b251b0c6378d
#> 100:            <NA>                <NA> 99c66728-9249-4113-a9de-e726a7462b3d
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
