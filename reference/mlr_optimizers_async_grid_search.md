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

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncGridSearch`

## Methods

### Public methods

- [`OptimizerAsyncGridSearch$new()`](#method-OptimizerAsyncGridSearch-initialize)

- [`OptimizerAsyncGridSearch$optimize()`](#method-OptimizerAsyncGridSearch-optimize)

- [`OptimizerAsyncGridSearch$clone()`](#method-OptimizerAsyncGridSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-12 16:20:35
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-12 16:20:35
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-12 16:20:35
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-12 16:20:35
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-12 16:20:35
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-12 16:20:35
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-12 16:20:35
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-12 16:20:35
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-12 16:20:35
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-12 16:20:35
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-12 16:20:35
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-12 16:20:35
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-12 16:20:35
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-12 16:20:35
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-12 16:20:35
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-12 16:20:35
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-12 16:20:35
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-12 16:20:35
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-12 16:20:35
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-12 16:20:35
#>  21:   failed  10.000000  5.0000000         NA 2026-06-12 16:20:35
#>  22:   failed  10.000000  3.8888889         NA 2026-06-12 16:20:35
#>  23:   failed  10.000000  2.7777778         NA 2026-06-12 16:20:35
#>  24:   failed  10.000000  1.6666667         NA 2026-06-12 16:20:35
#>  25:   failed  10.000000  0.5555556         NA 2026-06-12 16:20:35
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-12 16:20:35
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-12 16:20:35
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-12 16:20:35
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-12 16:20:35
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-12 16:20:35
#>  31:   failed   7.777778  5.0000000         NA 2026-06-12 16:20:35
#>  32:   failed   7.777778  3.8888889         NA 2026-06-12 16:20:35
#>  33:   failed   7.777778  2.7777778         NA 2026-06-12 16:20:35
#>  34:   failed   7.777778  1.6666667         NA 2026-06-12 16:20:35
#>  35:   failed   7.777778  0.5555556         NA 2026-06-12 16:20:35
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-12 16:20:35
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-12 16:20:35
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-12 16:20:35
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-12 16:20:35
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-12 16:20:35
#>  41:   failed   5.555556  5.0000000         NA 2026-06-12 16:20:35
#>  42:   failed   5.555556  3.8888889         NA 2026-06-12 16:20:35
#>  43:   failed   5.555556  2.7777778         NA 2026-06-12 16:20:35
#>  44:   failed   5.555556  1.6666667         NA 2026-06-12 16:20:35
#>  45:   failed   5.555556  0.5555556         NA 2026-06-12 16:20:35
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-12 16:20:35
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-12 16:20:35
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-12 16:20:35
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-12 16:20:35
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-12 16:20:35
#>  51:   failed   3.333333  5.0000000         NA 2026-06-12 16:20:35
#>  52:   failed   3.333333  3.8888889         NA 2026-06-12 16:20:35
#>  53:   failed   3.333333  2.7777778         NA 2026-06-12 16:20:35
#>  54:   failed   3.333333  1.6666667         NA 2026-06-12 16:20:35
#>  55:   failed   3.333333  0.5555556         NA 2026-06-12 16:20:35
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-12 16:20:35
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-12 16:20:35
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-12 16:20:35
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-12 16:20:35
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-12 16:20:35
#>  61:   failed   1.111111  5.0000000         NA 2026-06-12 16:20:35
#>  62:   failed   1.111111  3.8888889         NA 2026-06-12 16:20:35
#>  63:   failed   1.111111  2.7777778         NA 2026-06-12 16:20:35
#>  64:   failed   1.111111  1.6666667         NA 2026-06-12 16:20:35
#>  65:   failed   1.111111  0.5555556         NA 2026-06-12 16:20:35
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-12 16:20:35
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-12 16:20:35
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-12 16:20:35
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-12 16:20:35
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-12 16:20:35
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-12 16:20:35
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-12 16:20:35
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-12 16:20:35
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-12 16:20:35
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-12 16:20:35
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-12 16:20:35
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-12 16:20:35
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-12 16:20:35
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-12 16:20:35
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-12 16:20:35
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-12 16:20:35
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-12 16:20:35
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-12 16:20:35
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-12 16:20:35
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-12 16:20:35
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-12 16:20:35
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-12 16:20:35
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-12 16:20:35
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-12 16:20:35
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-12 16:20:35
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-12 16:20:35
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-12 16:20:35
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-12 16:20:35
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-12 16:20:35
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-12 16:20:35
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-12 16:20:35
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-12 16:20:35
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-12 16:20:35
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-12 16:20:35
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-12 16:20:35
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-12 16:20:36 d683c887-e460-4dec-92a9-54926e20775a
#>   2: sinking_raccoon 2026-06-12 16:20:36 f2f5254e-14d6-48ce-a2c4-04666ba33fed
#>   3: sinking_raccoon 2026-06-12 16:20:36 e249b147-c9cf-467f-993c-c6b896fb9072
#>   4: sinking_raccoon 2026-06-12 16:20:36 e5c7e618-d7cb-438a-9765-0f1f02b510d6
#>   5: sinking_raccoon 2026-06-12 16:20:36 9a53a069-5bf6-4fd2-9441-b3759403a9c1
#>   6: sinking_raccoon 2026-06-12 16:20:36 2201742f-bbb0-4d0f-8bec-7e055fa0c523
#>   7: sinking_raccoon 2026-06-12 16:20:36 05636c66-b8b1-4100-bc02-81191661bb37
#>   8: sinking_raccoon 2026-06-12 16:20:36 0d027df1-8c00-4f7c-9528-8b662b1d0e14
#>   9: sinking_raccoon 2026-06-12 16:20:36 4f9beb79-f040-4657-94e1-1ec320a99522
#>  10: sinking_raccoon 2026-06-12 16:20:36 64427344-6e3b-4894-acb5-deb865a532c3
#>  11: sinking_raccoon 2026-06-12 16:20:36 6ef1b9b7-b951-4b56-b008-7c6e5a5b9580
#>  12: sinking_raccoon 2026-06-12 16:20:36 fb8853d3-b552-4361-a767-1924a13c8a4b
#>  13: sinking_raccoon 2026-06-12 16:20:36 1c8434bd-9853-4d57-8039-18e5986345c5
#>  14: sinking_raccoon 2026-06-12 16:20:36 35f49b21-dac9-4ff8-b0af-f576bd20e284
#>  15: sinking_raccoon 2026-06-12 16:20:36 0a41148e-94b8-4ce5-b37c-2b119f2d2a9d
#>  16: sinking_raccoon 2026-06-12 16:20:36 baa2f804-4c23-40a3-a529-b43d3568f195
#>  17: sinking_raccoon 2026-06-12 16:20:36 07abf305-476b-4ca1-a039-b04081f0a261
#>  18: sinking_raccoon 2026-06-12 16:20:36 73563c25-350c-4437-a43b-f38125c7d71b
#>  19: sinking_raccoon 2026-06-12 16:20:36 c74446c4-dafd-484d-b814-7f59ceea7efa
#>  20: sinking_raccoon 2026-06-12 16:20:36 7ad9c825-8ff8-4498-ad05-f12016ac35fc
#>  21:            <NA>                <NA> 517ba72f-97f4-4cc6-87a6-9ba2c9a78f87
#>  22:            <NA>                <NA> 087e62fe-945b-4da5-a91d-df1da57025f4
#>  23:            <NA>                <NA> 92f29e64-d36b-42a8-96f4-88a0a8c1336c
#>  24:            <NA>                <NA> 7151c307-2c0f-4d72-b333-533bda3cf9dd
#>  25:            <NA>                <NA> 5a0d4e8a-cb7e-4002-b030-c75ef896ded1
#>  26:            <NA>                <NA> cf142e13-2135-4a7f-bcdc-5a9fa60fb6c3
#>  27:            <NA>                <NA> b2b80450-aa65-484b-83ad-d8394d9c2c54
#>  28:            <NA>                <NA> 4cd84be6-ce2c-4819-aead-9160b363938f
#>  29:            <NA>                <NA> 961ec3c1-3e94-4a3f-a8e4-1693aa043d1e
#>  30:            <NA>                <NA> 6bd81bfa-9b37-40d2-b19c-0a49afb66e01
#>  31:            <NA>                <NA> f31726bf-0251-4469-848c-2087947c6585
#>  32:            <NA>                <NA> dc869068-a9bb-467e-a9f3-f3b38209a476
#>  33:            <NA>                <NA> aeb8d3e4-e803-49ac-b410-d824b83a9b2e
#>  34:            <NA>                <NA> 83800794-8121-4395-a371-ffef810b2a42
#>  35:            <NA>                <NA> 6a1333c6-5a9d-43f2-b422-3d558249c984
#>  36:            <NA>                <NA> e8d06643-79a4-46de-a4a6-9c488175b1b4
#>  37:            <NA>                <NA> 5b924ff6-ebb6-4d00-898b-d8fff092753c
#>  38:            <NA>                <NA> c24d8cf8-8bfa-4f8a-b73f-46125da1678b
#>  39:            <NA>                <NA> e7d4e9d3-b95e-40c5-8e5b-597b1c307e37
#>  40:            <NA>                <NA> c97fcf60-f723-41b5-9b83-39d9dba87e94
#>  41:            <NA>                <NA> 74cb6637-c6f7-4aed-96ae-7ead588a5964
#>  42:            <NA>                <NA> a213ec55-26a2-448c-96fa-57e3bb6e8e98
#>  43:            <NA>                <NA> 129afdfa-9397-42c1-b8fb-a806c197abca
#>  44:            <NA>                <NA> 95bce8f9-bfa3-4462-97f3-0640bc1b47d9
#>  45:            <NA>                <NA> c248d739-4732-4a77-96b2-7fec7aba7946
#>  46:            <NA>                <NA> 3650ecd1-e5fa-4025-92fc-8bc7423b0f97
#>  47:            <NA>                <NA> 38294a37-ff5b-4662-93f8-0b0a9c767176
#>  48:            <NA>                <NA> 18407c53-4c98-43df-904f-74a57feb4b37
#>  49:            <NA>                <NA> ac451ad4-aa98-4fe4-aa24-cf16c64df02f
#>  50:            <NA>                <NA> e91f034b-2d9f-43d9-9cae-c9c6f08d7633
#>  51:            <NA>                <NA> 155ca3eb-29ff-4ebd-b779-4251bbe1622a
#>  52:            <NA>                <NA> 6b7a540a-28c1-4d82-85dc-8eb7eedd9052
#>  53:            <NA>                <NA> ac8e7080-92fa-4df6-aa75-5a80dcf75b5c
#>  54:            <NA>                <NA> dfb6b029-aa1d-45dc-8398-ef6517b1f90c
#>  55:            <NA>                <NA> 026ab322-28a1-4d7e-a92b-cd21b8a6ecfc
#>  56:            <NA>                <NA> 50fda40f-057c-49a3-b970-4da791f2f675
#>  57:            <NA>                <NA> 3901aa37-2940-480a-9a9d-7caef25416f4
#>  58:            <NA>                <NA> 12634a1a-ea20-4847-9adc-e6cc38296633
#>  59:            <NA>                <NA> e8214efb-20d3-47f8-9027-d47b96ccc79c
#>  60:            <NA>                <NA> a969f582-4065-4e50-8d93-748f7b64214b
#>  61:            <NA>                <NA> 6855ffd5-20cc-4ba8-b82f-7aec4ca4d6b2
#>  62:            <NA>                <NA> e2c337fd-fa46-4d6f-9c1b-6df613d766a6
#>  63:            <NA>                <NA> 5a04280f-c3cc-4718-ac5c-a8e43e86813d
#>  64:            <NA>                <NA> ad1e84b2-f6de-4554-bcfc-5e19b3c10a9b
#>  65:            <NA>                <NA> 4aaa8bdd-923d-435f-8d0d-c9a93aa09952
#>  66:            <NA>                <NA> a62b84a8-7e18-461f-a54d-1f0e184eb96a
#>  67:            <NA>                <NA> ed492bbd-604c-4d17-b5db-2db14f6e4766
#>  68:            <NA>                <NA> ca730fac-8e4a-40f4-9408-9aab19d63faa
#>  69:            <NA>                <NA> c82d4554-9383-49f2-a3a9-d9a1bf39ebd9
#>  70:            <NA>                <NA> ae365629-2c87-4380-b798-a7bcc18239f8
#>  71:            <NA>                <NA> 153a0f3f-7fb4-437a-b9df-ec0ff3b914df
#>  72:            <NA>                <NA> a9d5d295-4ccc-4516-86fa-3782c78a5a97
#>  73:            <NA>                <NA> e770ea25-d2ec-4c51-bbbe-ffc660febc69
#>  74:            <NA>                <NA> e11d1d5d-a951-45ab-b95c-a7fe99e54438
#>  75:            <NA>                <NA> df970bfe-6c75-41aa-adfe-e55eb417de8a
#>  76:            <NA>                <NA> b01b00af-8dff-40e1-a9da-260a25537a3c
#>  77:            <NA>                <NA> a6c41213-eaf8-4ba8-a1b6-562905f05c8f
#>  78:            <NA>                <NA> c099409e-f504-424e-9faa-83493d927884
#>  79:            <NA>                <NA> 40cfda5d-f10c-424c-9a07-e82db7e28ad5
#>  80:            <NA>                <NA> 47e31202-6e7e-4d29-be86-c4e6c11758b9
#>  81:            <NA>                <NA> 0c12c053-9884-47f0-8986-66eae9ef3f63
#>  82:            <NA>                <NA> 945b08ba-e82d-4587-8d1d-a22bfd15fc9f
#>  83:            <NA>                <NA> d826f821-dbfe-4416-8384-bdd47427f429
#>  84:            <NA>                <NA> 393745c8-b9b6-4116-9903-32b39bbd89ef
#>  85:            <NA>                <NA> 94fb67d6-c74d-47bf-a529-0267bd2f8eb8
#>  86:            <NA>                <NA> 7bae6a33-728b-49fe-8978-c3bab198e99b
#>  87:            <NA>                <NA> 73e99be2-14d3-4a56-a350-a854fb003751
#>  88:            <NA>                <NA> 5563fa37-dd46-437a-8168-db1e66020a36
#>  89:            <NA>                <NA> 51a986ec-4a41-4450-b0b4-1e16d58edd17
#>  90:            <NA>                <NA> 8a6a92be-a23b-43c1-812b-744e8dcccc4d
#>  91:            <NA>                <NA> fa3116ce-87e8-4cf8-89af-1f10d9e86dab
#>  92:            <NA>                <NA> ae77ed04-a55e-425c-b6eb-bae0c84a5433
#>  93:            <NA>                <NA> 5d31b68f-ef43-4a05-aeff-f5a5cae25aa8
#>  94:            <NA>                <NA> 14f01ddc-5f4c-4970-abcb-1e82412d74c6
#>  95:            <NA>                <NA> aa615ff3-9a9f-4065-92ed-b65efac05b63
#>  96:            <NA>                <NA> 485ac100-373e-4136-8de2-3b0608465a66
#>  97:            <NA>                <NA> 7c838e92-d256-4a9d-9ae5-43f3bd959639
#>  98:            <NA>                <NA> afb9db4f-4358-4341-80a3-0c836ee9d898
#>  99:            <NA>                <NA> 0f2493f2-c7ea-44d5-bb74-f147d4bfb3c6
#> 100:            <NA>                <NA> 00adf7b9-6ccb-4845-af46-3d95bb607d8d
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
