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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-08 06:05:57
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-08 06:05:57
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-08 06:05:57
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-08 06:05:57
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-08 06:05:57
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-08 06:05:57
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-08 06:05:57
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-08 06:05:57
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-08 06:05:57
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-08 06:05:57
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-08 06:05:57
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-08 06:05:57
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-08 06:05:57
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-08 06:05:57
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-08 06:05:57
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-08 06:05:57
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-08 06:05:57
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-08 06:05:57
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-08 06:05:57
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-08 06:05:57
#>  21:   failed  10.000000  5.0000000         NA 2026-04-08 06:05:57
#>  22:   failed  10.000000  3.8888889         NA 2026-04-08 06:05:57
#>  23:   failed  10.000000  2.7777778         NA 2026-04-08 06:05:57
#>  24:   failed  10.000000  1.6666667         NA 2026-04-08 06:05:57
#>  25:   failed  10.000000  0.5555556         NA 2026-04-08 06:05:57
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-08 06:05:57
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-08 06:05:57
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-08 06:05:57
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-08 06:05:57
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-08 06:05:57
#>  31:   failed   7.777778  5.0000000         NA 2026-04-08 06:05:57
#>  32:   failed   7.777778  3.8888889         NA 2026-04-08 06:05:57
#>  33:   failed   7.777778  2.7777778         NA 2026-04-08 06:05:57
#>  34:   failed   7.777778  1.6666667         NA 2026-04-08 06:05:57
#>  35:   failed   7.777778  0.5555556         NA 2026-04-08 06:05:57
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-08 06:05:57
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-08 06:05:57
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-08 06:05:57
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-08 06:05:57
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-08 06:05:57
#>  41:   failed   5.555556  5.0000000         NA 2026-04-08 06:05:57
#>  42:   failed   5.555556  3.8888889         NA 2026-04-08 06:05:57
#>  43:   failed   5.555556  2.7777778         NA 2026-04-08 06:05:57
#>  44:   failed   5.555556  1.6666667         NA 2026-04-08 06:05:57
#>  45:   failed   5.555556  0.5555556         NA 2026-04-08 06:05:57
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-08 06:05:57
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-08 06:05:57
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-08 06:05:57
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-08 06:05:57
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-08 06:05:57
#>  51:   failed   3.333333  5.0000000         NA 2026-04-08 06:05:57
#>  52:   failed   3.333333  3.8888889         NA 2026-04-08 06:05:57
#>  53:   failed   3.333333  2.7777778         NA 2026-04-08 06:05:57
#>  54:   failed   3.333333  1.6666667         NA 2026-04-08 06:05:57
#>  55:   failed   3.333333  0.5555556         NA 2026-04-08 06:05:57
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-08 06:05:57
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-08 06:05:57
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-08 06:05:57
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-08 06:05:57
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-08 06:05:57
#>  61:   failed   1.111111  5.0000000         NA 2026-04-08 06:05:57
#>  62:   failed   1.111111  3.8888889         NA 2026-04-08 06:05:57
#>  63:   failed   1.111111  2.7777778         NA 2026-04-08 06:05:57
#>  64:   failed   1.111111  1.6666667         NA 2026-04-08 06:05:57
#>  65:   failed   1.111111  0.5555556         NA 2026-04-08 06:05:57
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-08 06:05:57
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-08 06:05:57
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-08 06:05:57
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-08 06:05:57
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-08 06:05:57
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-08 06:05:57
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-08 06:05:57
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-08 06:05:57
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-08 06:05:57
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-08 06:05:57
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-08 06:05:57
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-08 06:05:57
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-08 06:05:57
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-08 06:05:57
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-08 06:05:57
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-08 06:05:57
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-08 06:05:57
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-08 06:05:57
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-08 06:05:57
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-08 06:05:57
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-08 06:05:57
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-08 06:05:57
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-08 06:05:57
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-08 06:05:57
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-08 06:05:57
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-08 06:05:57
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-08 06:05:57
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-08 06:05:57
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-08 06:05:57
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-08 06:05:57
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-08 06:05:57
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-08 06:05:57
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-08 06:05:57
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-08 06:05:57
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-08 06:05:57
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-08 06:05:57 11429a0a-295f-4e67-b437-00665c3f9260
#>   2: sinking_raccoon 2026-04-08 06:05:58 427cb6e2-ecbe-4950-850c-af7936322045
#>   3: sinking_raccoon 2026-04-08 06:05:58 69ae48ee-b73a-4616-9764-e6f3ba826579
#>   4: sinking_raccoon 2026-04-08 06:05:58 ae1fb101-ad87-42ac-b4c7-e72eb8dbea07
#>   5: sinking_raccoon 2026-04-08 06:05:58 1a0f3028-bb1b-4ec1-ac6d-05e464d32459
#>   6: sinking_raccoon 2026-04-08 06:05:58 ee4a19ef-ede8-4c4e-b030-1b71230d19d6
#>   7: sinking_raccoon 2026-04-08 06:05:58 3b2db6ce-847b-4270-adde-9345977b9710
#>   8: sinking_raccoon 2026-04-08 06:05:58 736d649e-3f68-4f8d-ac5d-c4aa89ba7b8d
#>   9: sinking_raccoon 2026-04-08 06:05:58 436fcea8-3f1a-48e4-b449-d9aca6727be0
#>  10: sinking_raccoon 2026-04-08 06:05:58 6169c080-a7b9-475b-94fb-bd17110614cc
#>  11: sinking_raccoon 2026-04-08 06:05:58 cee78350-b09f-4c02-b422-a54656ee33b0
#>  12: sinking_raccoon 2026-04-08 06:05:58 3f0e003d-e1ec-4719-a47b-6b7e012079ad
#>  13: sinking_raccoon 2026-04-08 06:05:58 2e804b63-fd72-433a-942a-a9412eddb75c
#>  14: sinking_raccoon 2026-04-08 06:05:58 1be4a4f4-6ff7-4623-baec-b41342366964
#>  15: sinking_raccoon 2026-04-08 06:05:58 723ff814-73b4-40c1-a5bf-2e54d2e03e87
#>  16: sinking_raccoon 2026-04-08 06:05:58 8b45200b-b2fe-486d-8b23-4b2f82051b38
#>  17: sinking_raccoon 2026-04-08 06:05:58 95c45e33-6111-49b3-b65b-8a0a784f85b3
#>  18: sinking_raccoon 2026-04-08 06:05:58 55e570c2-ab84-4b3a-ba83-ea75c931f97a
#>  19: sinking_raccoon 2026-04-08 06:05:58 7a3b5f72-672b-4138-bc07-322319594e43
#>  20: sinking_raccoon 2026-04-08 06:05:58 0ebdb0e9-f9c5-4515-acf2-48130f7d6476
#>  21:            <NA>                <NA> 41cf1d22-74a2-4bca-bd29-f2c90a75cd5e
#>  22:            <NA>                <NA> ec75ddee-5b04-4951-899d-30a7be79207b
#>  23:            <NA>                <NA> 52725b3f-9445-4ea5-adc8-a68d0342cfac
#>  24:            <NA>                <NA> 817ae5a5-45b8-4bed-b30f-f7ef36c05895
#>  25:            <NA>                <NA> 81bcf139-7a07-4474-9223-01934d51a080
#>  26:            <NA>                <NA> ef889a66-b7dc-4caf-92f7-abbc40364505
#>  27:            <NA>                <NA> e3267bc6-7243-45ae-9dd2-7c030e78fa2b
#>  28:            <NA>                <NA> ae5ff35a-0ab5-46c9-80ee-d0f13c3c795c
#>  29:            <NA>                <NA> ed6c39c6-6ef2-4a34-8e8e-823e648bdd3c
#>  30:            <NA>                <NA> 953027bd-3512-4d06-aba7-47761554c74f
#>  31:            <NA>                <NA> 00994c4a-e41c-436e-9d2d-2cc454b31e97
#>  32:            <NA>                <NA> e6351dca-253b-4c0c-b2b1-e33a18d7d069
#>  33:            <NA>                <NA> 85aaefba-285d-4788-8f9c-3fca688fcb13
#>  34:            <NA>                <NA> 9bc5c799-dd23-47c9-a793-1fccceff95c7
#>  35:            <NA>                <NA> 0ec110d9-abad-4ead-bc35-4c01cb17661e
#>  36:            <NA>                <NA> 0d85a9b7-c014-40ba-bec0-6927afb7bb2d
#>  37:            <NA>                <NA> 128bcecb-9fd3-4def-8a42-de816a5f9c39
#>  38:            <NA>                <NA> 2b31d7f9-d604-4afa-8853-773861e9cba4
#>  39:            <NA>                <NA> 612677cd-b212-4402-9f80-73fa0f2b4836
#>  40:            <NA>                <NA> 1eb2e04d-abd4-4268-b5ed-050044d15766
#>  41:            <NA>                <NA> f6b87c21-953d-400d-9b06-66f4feddb4c4
#>  42:            <NA>                <NA> 76a3e638-56d7-4f08-980f-3a22603aa93d
#>  43:            <NA>                <NA> 1078aeea-8b98-4f26-b9ea-1709954dd28a
#>  44:            <NA>                <NA> 6ee3b0c5-4527-4dee-98d4-9de60f5ab516
#>  45:            <NA>                <NA> 6e520bc2-200b-4d28-8297-1f80909b3100
#>  46:            <NA>                <NA> 7e5d4e53-eada-4032-a860-d3e9321bf566
#>  47:            <NA>                <NA> 2fa51e52-7a5d-4e97-bf0d-d520c7f58cac
#>  48:            <NA>                <NA> de615d6b-6072-4291-a750-b6858121cc71
#>  49:            <NA>                <NA> 361af575-142b-4a46-9d61-dc41ff3f0b9e
#>  50:            <NA>                <NA> f708c859-dd84-43bd-8a58-834f5f1266cd
#>  51:            <NA>                <NA> 9e4608ef-2132-4400-af5e-b0d261785dd2
#>  52:            <NA>                <NA> e801fa5d-579f-4f94-bbf6-0f1b5afde160
#>  53:            <NA>                <NA> bb0a1e37-7055-4465-8bbd-a74f43229073
#>  54:            <NA>                <NA> 83490991-2f62-480d-9b9e-7277f2f0c798
#>  55:            <NA>                <NA> 6baf1a1d-b130-4394-974d-9b3a9b7836fb
#>  56:            <NA>                <NA> 2721168e-becf-44b1-8234-c2b9219497ba
#>  57:            <NA>                <NA> 8920629c-732a-43b0-a2f7-d848e9256e35
#>  58:            <NA>                <NA> b3539cfa-4ab9-44d9-a5e8-bb4a76092f94
#>  59:            <NA>                <NA> 47534612-da02-473c-8879-f432d4962b41
#>  60:            <NA>                <NA> 8c4feeb5-a534-48aa-9a9e-d70daae728d0
#>  61:            <NA>                <NA> 4e995475-4c6e-4e6d-8b02-8389402d5e24
#>  62:            <NA>                <NA> 3accd8bf-cd79-4082-88d4-daabdf64bc4d
#>  63:            <NA>                <NA> e56b0819-daf6-4062-b4be-dbafd0bdd0e1
#>  64:            <NA>                <NA> 5daa5f02-536e-4abc-ab52-c82e5ba4c41e
#>  65:            <NA>                <NA> 63a68135-6645-4924-a776-cde7bfe72336
#>  66:            <NA>                <NA> e151a3a1-640e-4fc3-a532-015cf2aefb62
#>  67:            <NA>                <NA> 2897dbfb-4461-46a9-93cf-d005cda9baa7
#>  68:            <NA>                <NA> d181e40e-fc86-4bbd-908c-36a50dd11592
#>  69:            <NA>                <NA> dc4fa68f-efb6-4210-9a6d-73ab924a2d2a
#>  70:            <NA>                <NA> 7d361d47-74c7-4805-a808-5fc0fadd0556
#>  71:            <NA>                <NA> 43c0b013-d931-41da-a5e4-3c29915821ef
#>  72:            <NA>                <NA> 7bf14a64-ee2a-4e6c-976c-fbb989b22d03
#>  73:            <NA>                <NA> b468b2ad-4915-4fd3-9020-d8f0f87b1fc8
#>  74:            <NA>                <NA> c2d5da73-338d-41a0-837e-de32b8343825
#>  75:            <NA>                <NA> ee056eb4-ba6a-49a7-99f1-6df06e1ee205
#>  76:            <NA>                <NA> a99425ce-38b8-4045-9fcb-2ce4a1448667
#>  77:            <NA>                <NA> 7b9fb004-f94a-41cb-84ac-04fc900983b6
#>  78:            <NA>                <NA> f1414441-5ba0-41bd-9151-8af816f6ae88
#>  79:            <NA>                <NA> b86ce970-e65d-4f29-bd4f-657a08f8c49b
#>  80:            <NA>                <NA> 70a2430c-f4fd-4fc7-b0b7-ceb29956b674
#>  81:            <NA>                <NA> 71db1d54-3110-433c-a7ef-09e62032ab56
#>  82:            <NA>                <NA> 0a866398-7e30-4f50-bd96-81f513b57ef1
#>  83:            <NA>                <NA> 106106a8-1c89-4b90-935e-a75e05d100f9
#>  84:            <NA>                <NA> 6bb54567-15cc-42fc-9a46-affcb695d435
#>  85:            <NA>                <NA> 7416eb5f-c165-42ef-8e23-c6039f947dcf
#>  86:            <NA>                <NA> 46b795fc-b9a4-478c-85fc-1086b6535725
#>  87:            <NA>                <NA> c295d6c9-8129-4216-87ee-6e07f00d574e
#>  88:            <NA>                <NA> 303788b9-d9a5-4093-9303-1a6ad360e02d
#>  89:            <NA>                <NA> a70e3287-6c7e-4ff5-8323-a87c781285ca
#>  90:            <NA>                <NA> 82ba5415-e0c7-4a16-ab9c-c0b97607a1fe
#>  91:            <NA>                <NA> 9ecbdfe3-c24d-444c-b09e-02f7718da49b
#>  92:            <NA>                <NA> 1cd8ea91-d556-4a0a-8897-ace94a9640f7
#>  93:            <NA>                <NA> 278267f2-8ea5-423b-a761-e82469bcc480
#>  94:            <NA>                <NA> 8e9a5a77-fe93-46c9-aa79-0de08a24a0df
#>  95:            <NA>                <NA> 8f310c09-5af6-45c9-af7b-2d90c5d9c1b9
#>  96:            <NA>                <NA> 5107a5e5-1d45-4123-9c5e-bca50d403433
#>  97:            <NA>                <NA> 2ff5e22e-cb88-4a75-a8a8-e9c777762da0
#>  98:            <NA>                <NA> 446e4d8b-16a7-4c31-ba1e-5833bbd649e2
#>  99:            <NA>                <NA> b6d98156-8bcf-4e4c-aa74-a182484b192a
#> 100:            <NA>                <NA> 801af31d-45a0-465b-9aad-6cf87677fa69
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
