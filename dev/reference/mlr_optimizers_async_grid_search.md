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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-11 08:59:44
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-11 08:59:44
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-11 08:59:44
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-11 08:59:44
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-11 08:59:44
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-11 08:59:44
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-11 08:59:44
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-11 08:59:44
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-11 08:59:44
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-11 08:59:44
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-11 08:59:44
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-11 08:59:44
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-11 08:59:44
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-11 08:59:44
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-11 08:59:44
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-11 08:59:44
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-11 08:59:44
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-11 08:59:44
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-11 08:59:44
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-11 08:59:44
#>  21:   failed  10.000000  5.0000000         NA 2026-06-11 08:59:44
#>  22:   failed  10.000000  3.8888889         NA 2026-06-11 08:59:44
#>  23:   failed  10.000000  2.7777778         NA 2026-06-11 08:59:44
#>  24:   failed  10.000000  1.6666667         NA 2026-06-11 08:59:44
#>  25:   failed  10.000000  0.5555556         NA 2026-06-11 08:59:44
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-11 08:59:44
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-11 08:59:44
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-11 08:59:44
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-11 08:59:44
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-11 08:59:44
#>  31:   failed   7.777778  5.0000000         NA 2026-06-11 08:59:44
#>  32:   failed   7.777778  3.8888889         NA 2026-06-11 08:59:44
#>  33:   failed   7.777778  2.7777778         NA 2026-06-11 08:59:44
#>  34:   failed   7.777778  1.6666667         NA 2026-06-11 08:59:44
#>  35:   failed   7.777778  0.5555556         NA 2026-06-11 08:59:44
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-11 08:59:44
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-11 08:59:44
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-11 08:59:44
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-11 08:59:44
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-11 08:59:44
#>  41:   failed   5.555556  5.0000000         NA 2026-06-11 08:59:44
#>  42:   failed   5.555556  3.8888889         NA 2026-06-11 08:59:44
#>  43:   failed   5.555556  2.7777778         NA 2026-06-11 08:59:44
#>  44:   failed   5.555556  1.6666667         NA 2026-06-11 08:59:44
#>  45:   failed   5.555556  0.5555556         NA 2026-06-11 08:59:44
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-11 08:59:44
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-11 08:59:44
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-11 08:59:44
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-11 08:59:44
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-11 08:59:44
#>  51:   failed   3.333333  5.0000000         NA 2026-06-11 08:59:44
#>  52:   failed   3.333333  3.8888889         NA 2026-06-11 08:59:44
#>  53:   failed   3.333333  2.7777778         NA 2026-06-11 08:59:44
#>  54:   failed   3.333333  1.6666667         NA 2026-06-11 08:59:44
#>  55:   failed   3.333333  0.5555556         NA 2026-06-11 08:59:44
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-11 08:59:44
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-11 08:59:44
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-11 08:59:44
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-11 08:59:44
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-11 08:59:44
#>  61:   failed   1.111111  5.0000000         NA 2026-06-11 08:59:44
#>  62:   failed   1.111111  3.8888889         NA 2026-06-11 08:59:44
#>  63:   failed   1.111111  2.7777778         NA 2026-06-11 08:59:44
#>  64:   failed   1.111111  1.6666667         NA 2026-06-11 08:59:44
#>  65:   failed   1.111111  0.5555556         NA 2026-06-11 08:59:44
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-11 08:59:44
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-11 08:59:44
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-11 08:59:44
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-11 08:59:44
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-11 08:59:44
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-11 08:59:44
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-11 08:59:44
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-11 08:59:44
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-11 08:59:44
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-11 08:59:44
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-11 08:59:44
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-11 08:59:44
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-11 08:59:44
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-11 08:59:44
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-11 08:59:44
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-11 08:59:44
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-11 08:59:44
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-11 08:59:44
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-11 08:59:44
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-11 08:59:44
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-11 08:59:44
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-11 08:59:44
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-11 08:59:44
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-11 08:59:44
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-11 08:59:44
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-11 08:59:44
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-11 08:59:44
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-11 08:59:44
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-11 08:59:44
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-11 08:59:44
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-11 08:59:44
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-11 08:59:44
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-11 08:59:44
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-11 08:59:44
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-11 08:59:44
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-11 08:59:45 85383152-6904-4a24-b94e-88858218a18e
#>   2: sinking_raccoon 2026-06-11 08:59:45 307c268d-ff5e-4f25-a478-5e97b6a680f2
#>   3: sinking_raccoon 2026-06-11 08:59:45 02cf8748-b5f9-46d0-ad3f-5f2b307c1c52
#>   4: sinking_raccoon 2026-06-11 08:59:45 bc101fc2-f497-4f07-8a6b-a3aef1dcdbcd
#>   5: sinking_raccoon 2026-06-11 08:59:45 ea3d0be2-9efd-4997-9216-aa37cf84117e
#>   6: sinking_raccoon 2026-06-11 08:59:45 81a910eb-5093-4a00-8731-f51c198b1490
#>   7: sinking_raccoon 2026-06-11 08:59:45 aa0871e7-b737-4bd2-829e-462ecba41cb8
#>   8: sinking_raccoon 2026-06-11 08:59:45 8967aac0-e703-4288-8a82-2474ad9fb303
#>   9: sinking_raccoon 2026-06-11 08:59:45 1f253a23-eb12-4cca-a3ea-87c6e99dbdef
#>  10: sinking_raccoon 2026-06-11 08:59:45 c025d57e-33e2-411d-9bc4-ab54b904ef62
#>  11: sinking_raccoon 2026-06-11 08:59:45 5fe0e7cd-0b4a-4f53-87ee-98faae188959
#>  12: sinking_raccoon 2026-06-11 08:59:45 9448dc1a-8830-45fc-85d5-601d39aceb7c
#>  13: sinking_raccoon 2026-06-11 08:59:45 2d2ed93d-df78-49a3-ab0c-b15deaceaa93
#>  14: sinking_raccoon 2026-06-11 08:59:45 479e7120-2fad-4540-a967-0825e5a52be4
#>  15: sinking_raccoon 2026-06-11 08:59:45 c885d761-cbb6-4eff-980c-911e8dbc05a4
#>  16: sinking_raccoon 2026-06-11 08:59:45 629e3666-4365-493f-a9ce-2b65fedf0c05
#>  17: sinking_raccoon 2026-06-11 08:59:45 6287f041-dd50-47ff-8e2c-6ec25515eb2c
#>  18: sinking_raccoon 2026-06-11 08:59:45 dc7439e2-7c45-4b4d-a5ea-0e886d0b1e4a
#>  19: sinking_raccoon 2026-06-11 08:59:45 9cab06e7-13e4-4887-983f-58ab15adeace
#>  20: sinking_raccoon 2026-06-11 08:59:45 cb586ff9-566d-4646-a5e2-769756194f67
#>  21:            <NA>                <NA> e8487166-efc1-408c-a067-3df7e559507d
#>  22:            <NA>                <NA> 2b56f917-8516-4327-aeb1-18abe7876b8e
#>  23:            <NA>                <NA> 15366503-8002-483d-a215-b75d30b43126
#>  24:            <NA>                <NA> cad9ad8f-bf09-4a3c-8338-606823fb3841
#>  25:            <NA>                <NA> 41023099-1424-46dc-9c72-060c98fcfb95
#>  26:            <NA>                <NA> c012ab73-e145-4154-bf69-97da26b6e9bd
#>  27:            <NA>                <NA> 37268819-6523-45dd-8072-57b84b7c6e6b
#>  28:            <NA>                <NA> a3bfeaac-f986-4ad8-92ff-7229c211edde
#>  29:            <NA>                <NA> 5ff48e6c-1e81-4a47-b49a-6559e0076453
#>  30:            <NA>                <NA> fcaa7f1d-8cac-4a51-b1e8-b44766c77e1d
#>  31:            <NA>                <NA> a55320bb-d8ab-472f-a874-d777b8bde4cc
#>  32:            <NA>                <NA> 7390887f-c791-4ac3-8d87-471f6c30a50f
#>  33:            <NA>                <NA> d188ef31-9aba-48ab-90d5-a4bc6d00bc76
#>  34:            <NA>                <NA> 34dd7fce-a1f7-4ce3-aa12-33e280709019
#>  35:            <NA>                <NA> b324dab1-36c5-47e4-bd64-0f26cb36a944
#>  36:            <NA>                <NA> dad00678-36cd-48b8-afbd-e29eeddcb4f5
#>  37:            <NA>                <NA> bba5b421-ceaf-49e5-9da3-63bde63a4ee6
#>  38:            <NA>                <NA> f82e8997-712d-4359-b287-84936b8d8e1b
#>  39:            <NA>                <NA> c0befe50-ed85-4af4-b46e-ee0ef7e06d05
#>  40:            <NA>                <NA> 0269cc2e-edc6-4946-bf9d-871047a47110
#>  41:            <NA>                <NA> e595f835-4eee-4bc1-b983-e3b0fecc07ec
#>  42:            <NA>                <NA> c1c0f302-98bd-4696-9577-0f048bd27395
#>  43:            <NA>                <NA> 52074650-4af4-4cca-9210-17d054debabf
#>  44:            <NA>                <NA> 3f517fce-65c0-4545-88ee-359f000efd86
#>  45:            <NA>                <NA> 9f349012-67a4-49f9-8764-b9f7c5377fa5
#>  46:            <NA>                <NA> 161dd215-3064-47e6-bbab-81427a71d316
#>  47:            <NA>                <NA> cbd052ad-ad28-48ce-b275-79df15505807
#>  48:            <NA>                <NA> ca89685c-4c64-4c90-a8ee-846f337db2a9
#>  49:            <NA>                <NA> 1a73df14-01db-4909-965c-e2f0855bec1a
#>  50:            <NA>                <NA> 9c1fb9c3-65df-4150-b931-0ff37ea68793
#>  51:            <NA>                <NA> f272a19e-f9a0-47ff-bcb5-b42536188743
#>  52:            <NA>                <NA> f3be530f-e0c5-46e4-94db-8b1379051a94
#>  53:            <NA>                <NA> 3eca0eee-5d6d-4900-83c6-f90063232880
#>  54:            <NA>                <NA> 92a01139-3a91-4f47-97a5-7fc561df2685
#>  55:            <NA>                <NA> 457de228-5532-4366-83d9-acbb2bdcb14f
#>  56:            <NA>                <NA> f2022fdf-b258-4383-a308-361b8b0f49fc
#>  57:            <NA>                <NA> 0dc5f4e2-43ba-4538-ae96-68fbeaef6970
#>  58:            <NA>                <NA> 95e65658-a33f-4709-8f62-844e155b3bb5
#>  59:            <NA>                <NA> d83af2ce-8da6-476b-8d02-a3813fb8c709
#>  60:            <NA>                <NA> 24039063-e28f-4ddd-950a-f5d769155d75
#>  61:            <NA>                <NA> b61aff0c-cbc6-495f-9fc8-687aaa6c4a1a
#>  62:            <NA>                <NA> af18d5dd-e5c2-4107-9397-285fefa176e2
#>  63:            <NA>                <NA> 41cc0307-6146-4c06-95b5-f03008561065
#>  64:            <NA>                <NA> b0b63ba1-40e4-4172-a489-3bb9fc11004b
#>  65:            <NA>                <NA> 9ca8ad49-69e1-4ca8-8bcc-f69585bd6fd2
#>  66:            <NA>                <NA> 27819979-350f-43fa-85ce-113098cddb1e
#>  67:            <NA>                <NA> 17fb500f-68dd-46f1-8ce6-b8babce23c66
#>  68:            <NA>                <NA> 23fc55bd-b803-4f5d-a45c-e9ab2520e679
#>  69:            <NA>                <NA> 856c4490-d3c3-4238-87aa-106e16b387cb
#>  70:            <NA>                <NA> 0c207a1c-a31c-4226-95a2-dc81ed0adbef
#>  71:            <NA>                <NA> 3578f430-fb67-4694-923f-914927bf4b0f
#>  72:            <NA>                <NA> d255074a-c770-4f48-92ac-3d6fadf88591
#>  73:            <NA>                <NA> abe92383-3f05-447c-8bb0-4edac4ae164e
#>  74:            <NA>                <NA> 18bb1afe-2899-4f1d-9da9-67cc1fca6e4a
#>  75:            <NA>                <NA> b8794761-9bc5-4d26-8d4f-a09c44c41e63
#>  76:            <NA>                <NA> 9cb1e966-52eb-4ecd-97ad-1c4026ee77ff
#>  77:            <NA>                <NA> 2f619551-a3ec-4e0f-b576-b40d20e5dbab
#>  78:            <NA>                <NA> 059f48ed-dba1-4152-8036-bce1bdc23c12
#>  79:            <NA>                <NA> b0a59076-d7a2-44fd-8070-409dc5d1d8d9
#>  80:            <NA>                <NA> c32954f9-0c67-43f9-88ba-5c895a8e1bd4
#>  81:            <NA>                <NA> c660406d-7e30-49ee-b665-17b6290c4c60
#>  82:            <NA>                <NA> f9691202-2cb4-497a-9f1c-70be86225348
#>  83:            <NA>                <NA> 98c241d8-dea9-4394-8c44-50d29666a833
#>  84:            <NA>                <NA> d2dfdd0a-c9c7-443a-a96e-c16dc08c33af
#>  85:            <NA>                <NA> 9a0765bb-79c5-4c2c-93fd-407cba89852f
#>  86:            <NA>                <NA> 3428971a-b206-4150-820d-3c81cc93e9c7
#>  87:            <NA>                <NA> 16ef6f51-4ee7-4654-958b-7ec360811e57
#>  88:            <NA>                <NA> 10c3343e-2a0f-4389-8867-155b5323ef19
#>  89:            <NA>                <NA> cd825d41-eb54-4c36-a65c-15de0e8bb07d
#>  90:            <NA>                <NA> 3af02250-d5b4-4deb-aa5a-57acffe0d271
#>  91:            <NA>                <NA> 1b14318b-dfbd-442a-bf1c-ac2bde2d2478
#>  92:            <NA>                <NA> 21f53483-7635-4d30-bbb6-29a0283c826e
#>  93:            <NA>                <NA> 11563d83-dfea-4c0a-9a73-200e690e45c9
#>  94:            <NA>                <NA> b88b8ae9-c895-404b-95e2-0e91201e3739
#>  95:            <NA>                <NA> 39df3e7c-f829-4063-8239-d81d803a3e63
#>  96:            <NA>                <NA> 58c299bf-df86-48dd-aa9e-25f3ce6c8ef1
#>  97:            <NA>                <NA> 8b933fcf-603a-44af-8293-dcfc088ca0c0
#>  98:            <NA>                <NA> 6202ca67-b747-4100-a511-75e2e8b59ba2
#>  99:            <NA>                <NA> f36de115-64a1-4b55-a2b5-7de34a7531ae
#> 100:            <NA>                <NA> 053cbeb4-80ba-4878-a272-1237a1c8bee5
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
