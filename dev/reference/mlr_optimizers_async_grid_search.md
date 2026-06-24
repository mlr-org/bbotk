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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-24 06:52:11
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-24 06:52:11
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-24 06:52:11
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-24 06:52:11
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-24 06:52:11
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-24 06:52:11
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-24 06:52:11
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-24 06:52:11
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-24 06:52:11
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-24 06:52:11
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-24 06:52:11
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-24 06:52:11
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-24 06:52:11
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-24 06:52:11
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-24 06:52:11
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-24 06:52:11
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-24 06:52:11
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-24 06:52:11
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-24 06:52:11
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-24 06:52:11
#>  21:   failed  10.000000  5.0000000         NA 2026-06-24 06:52:11
#>  22:   failed  10.000000  3.8888889         NA 2026-06-24 06:52:11
#>  23:   failed  10.000000  2.7777778         NA 2026-06-24 06:52:11
#>  24:   failed  10.000000  1.6666667         NA 2026-06-24 06:52:11
#>  25:   failed  10.000000  0.5555556         NA 2026-06-24 06:52:11
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-24 06:52:11
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-24 06:52:11
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-24 06:52:11
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-24 06:52:11
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-24 06:52:11
#>  31:   failed   7.777778  5.0000000         NA 2026-06-24 06:52:11
#>  32:   failed   7.777778  3.8888889         NA 2026-06-24 06:52:11
#>  33:   failed   7.777778  2.7777778         NA 2026-06-24 06:52:11
#>  34:   failed   7.777778  1.6666667         NA 2026-06-24 06:52:11
#>  35:   failed   7.777778  0.5555556         NA 2026-06-24 06:52:11
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-24 06:52:11
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-24 06:52:11
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-24 06:52:11
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-24 06:52:11
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-24 06:52:11
#>  41:   failed   5.555556  5.0000000         NA 2026-06-24 06:52:11
#>  42:   failed   5.555556  3.8888889         NA 2026-06-24 06:52:11
#>  43:   failed   5.555556  2.7777778         NA 2026-06-24 06:52:11
#>  44:   failed   5.555556  1.6666667         NA 2026-06-24 06:52:11
#>  45:   failed   5.555556  0.5555556         NA 2026-06-24 06:52:11
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-24 06:52:11
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-24 06:52:11
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-24 06:52:11
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-24 06:52:11
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-24 06:52:11
#>  51:   failed   3.333333  5.0000000         NA 2026-06-24 06:52:11
#>  52:   failed   3.333333  3.8888889         NA 2026-06-24 06:52:11
#>  53:   failed   3.333333  2.7777778         NA 2026-06-24 06:52:11
#>  54:   failed   3.333333  1.6666667         NA 2026-06-24 06:52:11
#>  55:   failed   3.333333  0.5555556         NA 2026-06-24 06:52:11
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-24 06:52:11
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-24 06:52:11
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-24 06:52:11
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-24 06:52:11
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-24 06:52:11
#>  61:   failed   1.111111  5.0000000         NA 2026-06-24 06:52:11
#>  62:   failed   1.111111  3.8888889         NA 2026-06-24 06:52:11
#>  63:   failed   1.111111  2.7777778         NA 2026-06-24 06:52:11
#>  64:   failed   1.111111  1.6666667         NA 2026-06-24 06:52:11
#>  65:   failed   1.111111  0.5555556         NA 2026-06-24 06:52:11
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-24 06:52:11
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-24 06:52:11
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-24 06:52:11
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-24 06:52:11
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-24 06:52:11
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-24 06:52:11
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-24 06:52:11
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-24 06:52:11
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-24 06:52:11
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-24 06:52:11
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-24 06:52:11
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-24 06:52:11
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-24 06:52:11
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-24 06:52:11
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-24 06:52:11
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-24 06:52:11
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-24 06:52:11
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-24 06:52:11
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-24 06:52:11
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-24 06:52:11
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-24 06:52:11
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-24 06:52:11
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-24 06:52:11
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-24 06:52:11
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-24 06:52:11
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-24 06:52:11
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-24 06:52:11
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-24 06:52:11
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-24 06:52:11
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-24 06:52:11
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-24 06:52:11
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-24 06:52:11
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-24 06:52:11
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-24 06:52:11
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-24 06:52:11
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-24 06:52:12 7c537f75-6427-4060-8be4-6ca998f4bd48
#>   2: sinking_raccoon 2026-06-24 06:52:12 98b6a2ea-2ef1-4b8c-a6c6-f560e8bb6bed
#>   3: sinking_raccoon 2026-06-24 06:52:12 5e454495-1bc3-42d1-95d9-a7b94a29eeff
#>   4: sinking_raccoon 2026-06-24 06:52:12 81b56f66-743f-477d-834a-f21f9e1a591e
#>   5: sinking_raccoon 2026-06-24 06:52:12 375288fc-fb19-4ead-9094-eb37b110d8f4
#>   6: sinking_raccoon 2026-06-24 06:52:12 569290b4-9b3e-44f8-822e-c765945863f4
#>   7: sinking_raccoon 2026-06-24 06:52:12 a001a0a0-98d2-4fac-b937-e13f5d119ca5
#>   8: sinking_raccoon 2026-06-24 06:52:12 53894413-4b44-42f2-9b14-b870352bc822
#>   9: sinking_raccoon 2026-06-24 06:52:12 7d2ff98a-3f95-4f38-b916-ca515071c9cc
#>  10: sinking_raccoon 2026-06-24 06:52:12 58ff079b-9984-41b6-9336-4b7ca1406755
#>  11: sinking_raccoon 2026-06-24 06:52:12 4cea9219-0fbd-4993-9983-c1272d07c43f
#>  12: sinking_raccoon 2026-06-24 06:52:12 9bc55601-fa0b-43ce-a6cd-f84009ee8917
#>  13: sinking_raccoon 2026-06-24 06:52:12 fe093e95-8c4a-4d77-b30a-46e95d51d808
#>  14: sinking_raccoon 2026-06-24 06:52:12 5ac119e2-e5ab-4251-900d-e90f0fccea54
#>  15: sinking_raccoon 2026-06-24 06:52:12 6d1139ce-2f23-41e2-ac2a-4127fa679248
#>  16: sinking_raccoon 2026-06-24 06:52:12 ef175c85-7a8a-4d7b-b150-7fea5de773ee
#>  17: sinking_raccoon 2026-06-24 06:52:12 8bb8ecc9-45d1-4ed2-ab92-7acaf80150d8
#>  18: sinking_raccoon 2026-06-24 06:52:12 9e16e35b-cb49-4873-af70-fe2a6f4ddfdc
#>  19: sinking_raccoon 2026-06-24 06:52:12 3da6834f-90bc-4e0e-a8dc-ec7ca2c23d5b
#>  20: sinking_raccoon 2026-06-24 06:52:12 f315d3ed-29e5-4bc8-ad6e-b5fceee95e41
#>  21:            <NA>                <NA> f8ddf27b-99ca-4f82-829c-1e29336ae175
#>  22:            <NA>                <NA> 1a8cb78a-0985-4db4-8bb1-8bf976f37295
#>  23:            <NA>                <NA> f77206cb-30ce-4b98-94c7-ef67168c77e8
#>  24:            <NA>                <NA> 653c5924-79bf-41f7-a646-32cdcca3a805
#>  25:            <NA>                <NA> bdadf71f-5553-4f70-af50-9fa7867fda68
#>  26:            <NA>                <NA> 76f4cb9f-6c6d-4e75-ba4e-53eaa20f924e
#>  27:            <NA>                <NA> 73640819-a61a-4814-81fc-edbf9a921f1d
#>  28:            <NA>                <NA> 8cc6aeaa-0e95-447c-b5cf-cfa9c84999c3
#>  29:            <NA>                <NA> ac8e7974-762b-42b6-91a1-b9bc99e26ac1
#>  30:            <NA>                <NA> c7ad108d-c117-4a27-8aea-c82a2d50fc79
#>  31:            <NA>                <NA> e84196cc-ab29-46d5-8f7a-c6bf4e0ff9b9
#>  32:            <NA>                <NA> 14b2d127-24cd-4309-a2e4-a980871af6f6
#>  33:            <NA>                <NA> c20435a8-ea16-450f-816e-b081e4eee383
#>  34:            <NA>                <NA> 4c4031ea-090f-4eba-af44-98c7f5feff1a
#>  35:            <NA>                <NA> a1652a59-5a5c-49b9-8300-0fac69e8cd4c
#>  36:            <NA>                <NA> a5741700-eca5-4f0b-81cb-7ed8a3cc8820
#>  37:            <NA>                <NA> 20c32a25-f8d1-4215-bd07-2106f7f18ae0
#>  38:            <NA>                <NA> b855c394-db14-4cf9-a961-efba637d71b1
#>  39:            <NA>                <NA> 69ef5998-cb65-4791-a1aa-73df0f0644d4
#>  40:            <NA>                <NA> d58bc1f9-208e-4c7b-bc5a-a1c4af7d99d8
#>  41:            <NA>                <NA> c28f2f39-b3fd-47ed-9491-aa419d4e9757
#>  42:            <NA>                <NA> b5f6a53a-51e2-415f-98b9-2fb23c15f699
#>  43:            <NA>                <NA> 4eae02cc-9d15-4147-8e7e-ee091ede72d3
#>  44:            <NA>                <NA> 690a7543-4985-47ac-a4f3-57490f18b258
#>  45:            <NA>                <NA> 646412ff-0a99-41bc-b67a-68498aba7de1
#>  46:            <NA>                <NA> 87aedfa4-0e87-40a3-8103-94b351088dd0
#>  47:            <NA>                <NA> 162f08ca-e0e7-4b5e-88dc-1b2b356144c1
#>  48:            <NA>                <NA> 9c8685a5-9be9-4725-9707-40a54ce0c63a
#>  49:            <NA>                <NA> 56fcc97a-31a3-4337-938f-3568a24ee3d3
#>  50:            <NA>                <NA> 5346fd12-6253-4a44-a2e7-1ffde9e6b3e7
#>  51:            <NA>                <NA> b0172018-de06-49dd-b059-aaaac6143725
#>  52:            <NA>                <NA> 2623e4c4-8ced-4c97-ac16-f644f7883102
#>  53:            <NA>                <NA> 9c47f37c-48e3-418b-bade-c1d1503a7519
#>  54:            <NA>                <NA> 56cc7625-680e-4d8b-9c5c-ed10b79097a8
#>  55:            <NA>                <NA> c9491e1a-fa9b-4191-b550-9f5897672a6e
#>  56:            <NA>                <NA> 0dd310fe-c80e-4451-a47f-155ebd6fe020
#>  57:            <NA>                <NA> a0d47b29-ea15-4cbc-bf4d-94471edd855b
#>  58:            <NA>                <NA> 147f4e3a-a9c3-4d54-ab6c-568ca641a70f
#>  59:            <NA>                <NA> 12fac9ce-6465-4e9c-8d61-20c16652ecf7
#>  60:            <NA>                <NA> f4708b73-c145-46c6-9a1d-faef111cb093
#>  61:            <NA>                <NA> 26c16ebe-db7a-4bed-a7c9-61c40103ae45
#>  62:            <NA>                <NA> c49499dc-d1e6-48d5-8883-69d00caf7357
#>  63:            <NA>                <NA> 11dfc119-fd19-4ce2-89fc-f849b009d26d
#>  64:            <NA>                <NA> 102fe9a4-15be-4352-b375-02fba05f9aac
#>  65:            <NA>                <NA> 4c80f5ea-ccf7-4bf2-bf7b-6a8307331cbd
#>  66:            <NA>                <NA> 38ab5669-856a-4149-b0a9-1a1c66ab9a5c
#>  67:            <NA>                <NA> ffacfd46-c824-40a9-a5ec-889e3ade5154
#>  68:            <NA>                <NA> 452d65c7-ec6d-4252-8f79-5a7f8c838052
#>  69:            <NA>                <NA> 8ff9f57d-9b97-42e4-8f15-5af6af2bd10e
#>  70:            <NA>                <NA> baaa5151-87e8-435d-82ef-232f99cc9f0c
#>  71:            <NA>                <NA> 1b5b16b3-2cfc-41d8-a821-36f54aaabe84
#>  72:            <NA>                <NA> 70dd4cb5-bfec-4a93-9270-907a2ec22168
#>  73:            <NA>                <NA> a8afabf3-a20c-4452-8545-b1a58c7a08f0
#>  74:            <NA>                <NA> d7775bc2-920b-422e-a696-7d803693d097
#>  75:            <NA>                <NA> fe5777f4-29fb-4470-980e-aa80eea5e407
#>  76:            <NA>                <NA> de9adb2b-8bf9-42f9-b735-b7536aa154ae
#>  77:            <NA>                <NA> 97d6e54c-f4c0-4ebe-bd80-2b5abef6fafc
#>  78:            <NA>                <NA> b8862b27-0855-4d47-9920-ae3271316cb3
#>  79:            <NA>                <NA> 8c960945-4728-4d6c-89b3-84c80805de82
#>  80:            <NA>                <NA> 2bb33f6d-6772-492c-b0f5-10a5d7a11de7
#>  81:            <NA>                <NA> b59921ba-fca8-4ea8-88fd-8fd9bd9cfbb0
#>  82:            <NA>                <NA> 4b8f5c62-a3bd-4663-b552-500979f3c2ed
#>  83:            <NA>                <NA> c00c50ec-8d8a-4db1-af44-1720025c81b6
#>  84:            <NA>                <NA> 232bcd8a-95de-444f-b9c0-f7fe20039994
#>  85:            <NA>                <NA> 39013b85-8041-43f7-bccd-f4470c501c3f
#>  86:            <NA>                <NA> 124357e4-ae40-45e1-93e6-9144897d6640
#>  87:            <NA>                <NA> 409f9b51-061c-44f4-808c-865d40b355ef
#>  88:            <NA>                <NA> c7bf5b63-ac9a-4aa3-b987-706032aa9008
#>  89:            <NA>                <NA> 50b7551d-3ef6-4770-b500-01f140e56944
#>  90:            <NA>                <NA> 8b63fbb2-dc8f-4b16-9895-a3d0d87b462c
#>  91:            <NA>                <NA> 7ae3b9ba-34c1-4735-86b1-53fc0326f5ff
#>  92:            <NA>                <NA> 3d1d6957-cb86-4fae-852f-068f63f9df0f
#>  93:            <NA>                <NA> 6ad26bc0-abdf-4f4c-8bac-82e7f4c1ad68
#>  94:            <NA>                <NA> 45b26cd7-78ab-4e8c-9ed2-06f95743cdb8
#>  95:            <NA>                <NA> 50a71434-67cd-4c66-b8a2-31b7ceadc7e8
#>  96:            <NA>                <NA> 7f2921fe-57cd-4473-aa7b-759e38e08b33
#>  97:            <NA>                <NA> 5a9d5dd9-e307-48ff-9ef0-3c1ba1520d96
#>  98:            <NA>                <NA> 0bacfb7b-b6a0-4066-8f3a-9fc24012a34d
#>  99:            <NA>                <NA> fee8eb30-cc50-4fe7-993a-955eb542fed8
#> 100:            <NA>                <NA> 22d83981-3854-44ec-aad7-7ba3b2e6fbfa
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>                 message x_domain_x1 x_domain_x2
#>                  <char>       <num>       <num>
#>   1:               <NA>  -10.000000  -5.0000000
#>   2:               <NA>  -10.000000  -3.8888889
#>   3:               <NA>  -10.000000  -2.7777778
#>   4:               <NA>  -10.000000  -1.6666667
#>   5:               <NA>  -10.000000  -0.5555556
#>   6:               <NA>  -10.000000   0.5555556
#>   7:               <NA>  -10.000000   1.6666667
#>   8:               <NA>  -10.000000   2.7777778
#>   9:               <NA>  -10.000000   3.8888889
#>  10:               <NA>  -10.000000   5.0000000
#>  11:               <NA>   -7.777778  -5.0000000
#>  12:               <NA>   -7.777778  -3.8888889
#>  13:               <NA>   -7.777778  -2.7777778
#>  14:               <NA>   -7.777778  -1.6666667
#>  15:               <NA>   -7.777778  -0.5555556
#>  16:               <NA>   -7.777778   0.5555556
#>  17:               <NA>   -7.777778   1.6666667
#>  18:               <NA>   -7.777778   2.7777778
#>  19:               <NA>   -7.777778   3.8888889
#>  20:               <NA>   -7.777778   5.0000000
#>  21: Removed from queue          NA          NA
#>  22: Removed from queue          NA          NA
#>  23: Removed from queue          NA          NA
#>  24: Removed from queue          NA          NA
#>  25: Removed from queue          NA          NA
#>  26: Removed from queue          NA          NA
#>  27: Removed from queue          NA          NA
#>  28: Removed from queue          NA          NA
#>  29: Removed from queue          NA          NA
#>  30: Removed from queue          NA          NA
#>  31: Removed from queue          NA          NA
#>  32: Removed from queue          NA          NA
#>  33: Removed from queue          NA          NA
#>  34: Removed from queue          NA          NA
#>  35: Removed from queue          NA          NA
#>  36: Removed from queue          NA          NA
#>  37: Removed from queue          NA          NA
#>  38: Removed from queue          NA          NA
#>  39: Removed from queue          NA          NA
#>  40: Removed from queue          NA          NA
#>  41: Removed from queue          NA          NA
#>  42: Removed from queue          NA          NA
#>  43: Removed from queue          NA          NA
#>  44: Removed from queue          NA          NA
#>  45: Removed from queue          NA          NA
#>  46: Removed from queue          NA          NA
#>  47: Removed from queue          NA          NA
#>  48: Removed from queue          NA          NA
#>  49: Removed from queue          NA          NA
#>  50: Removed from queue          NA          NA
#>  51: Removed from queue          NA          NA
#>  52: Removed from queue          NA          NA
#>  53: Removed from queue          NA          NA
#>  54: Removed from queue          NA          NA
#>  55: Removed from queue          NA          NA
#>  56: Removed from queue          NA          NA
#>  57: Removed from queue          NA          NA
#>  58: Removed from queue          NA          NA
#>  59: Removed from queue          NA          NA
#>  60: Removed from queue          NA          NA
#>  61: Removed from queue          NA          NA
#>  62: Removed from queue          NA          NA
#>  63: Removed from queue          NA          NA
#>  64: Removed from queue          NA          NA
#>  65: Removed from queue          NA          NA
#>  66: Removed from queue          NA          NA
#>  67: Removed from queue          NA          NA
#>  68: Removed from queue          NA          NA
#>  69: Removed from queue          NA          NA
#>  70: Removed from queue          NA          NA
#>  71: Removed from queue          NA          NA
#>  72: Removed from queue          NA          NA
#>  73: Removed from queue          NA          NA
#>  74: Removed from queue          NA          NA
#>  75: Removed from queue          NA          NA
#>  76: Removed from queue          NA          NA
#>  77: Removed from queue          NA          NA
#>  78: Removed from queue          NA          NA
#>  79: Removed from queue          NA          NA
#>  80: Removed from queue          NA          NA
#>  81: Removed from queue          NA          NA
#>  82: Removed from queue          NA          NA
#>  83: Removed from queue          NA          NA
#>  84: Removed from queue          NA          NA
#>  85: Removed from queue          NA          NA
#>  86: Removed from queue          NA          NA
#>  87: Removed from queue          NA          NA
#>  88: Removed from queue          NA          NA
#>  89: Removed from queue          NA          NA
#>  90: Removed from queue          NA          NA
#>  91: Removed from queue          NA          NA
#>  92: Removed from queue          NA          NA
#>  93: Removed from queue          NA          NA
#>  94: Removed from queue          NA          NA
#>  95: Removed from queue          NA          NA
#>  96: Removed from queue          NA          NA
#>  97: Removed from queue          NA          NA
#>  98: Removed from queue          NA          NA
#>  99: Removed from queue          NA          NA
#> 100: Removed from queue          NA          NA
#>                 message x_domain_x1 x_domain_x2
#>                  <char>       <num>       <num>
```
