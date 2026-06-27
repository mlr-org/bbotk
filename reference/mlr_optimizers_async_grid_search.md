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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-27 12:47:05
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-27 12:47:05
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-27 12:47:05
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-27 12:47:05
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-27 12:47:05
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-27 12:47:05
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-27 12:47:05
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-27 12:47:05
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-27 12:47:05
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-27 12:47:05
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-27 12:47:05
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-27 12:47:05
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-27 12:47:05
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-27 12:47:05
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-27 12:47:05
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-27 12:47:05
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-27 12:47:05
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-27 12:47:05
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-27 12:47:05
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-27 12:47:05
#>  21:   failed  10.000000  5.0000000         NA 2026-06-27 12:47:05
#>  22:   failed  10.000000  3.8888889         NA 2026-06-27 12:47:05
#>  23:   failed  10.000000  2.7777778         NA 2026-06-27 12:47:05
#>  24:   failed  10.000000  1.6666667         NA 2026-06-27 12:47:05
#>  25:   failed  10.000000  0.5555556         NA 2026-06-27 12:47:05
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-27 12:47:05
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-27 12:47:05
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-27 12:47:05
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-27 12:47:05
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-27 12:47:05
#>  31:   failed   7.777778  5.0000000         NA 2026-06-27 12:47:05
#>  32:   failed   7.777778  3.8888889         NA 2026-06-27 12:47:05
#>  33:   failed   7.777778  2.7777778         NA 2026-06-27 12:47:05
#>  34:   failed   7.777778  1.6666667         NA 2026-06-27 12:47:05
#>  35:   failed   7.777778  0.5555556         NA 2026-06-27 12:47:05
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-27 12:47:05
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-27 12:47:05
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-27 12:47:05
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-27 12:47:05
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-27 12:47:05
#>  41:   failed   5.555556  5.0000000         NA 2026-06-27 12:47:05
#>  42:   failed   5.555556  3.8888889         NA 2026-06-27 12:47:05
#>  43:   failed   5.555556  2.7777778         NA 2026-06-27 12:47:05
#>  44:   failed   5.555556  1.6666667         NA 2026-06-27 12:47:05
#>  45:   failed   5.555556  0.5555556         NA 2026-06-27 12:47:05
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-27 12:47:05
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-27 12:47:05
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-27 12:47:05
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-27 12:47:05
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-27 12:47:05
#>  51:   failed   3.333333  5.0000000         NA 2026-06-27 12:47:05
#>  52:   failed   3.333333  3.8888889         NA 2026-06-27 12:47:05
#>  53:   failed   3.333333  2.7777778         NA 2026-06-27 12:47:05
#>  54:   failed   3.333333  1.6666667         NA 2026-06-27 12:47:05
#>  55:   failed   3.333333  0.5555556         NA 2026-06-27 12:47:05
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-27 12:47:05
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-27 12:47:05
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-27 12:47:05
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-27 12:47:05
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-27 12:47:05
#>  61:   failed   1.111111  5.0000000         NA 2026-06-27 12:47:05
#>  62:   failed   1.111111  3.8888889         NA 2026-06-27 12:47:05
#>  63:   failed   1.111111  2.7777778         NA 2026-06-27 12:47:05
#>  64:   failed   1.111111  1.6666667         NA 2026-06-27 12:47:05
#>  65:   failed   1.111111  0.5555556         NA 2026-06-27 12:47:05
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-27 12:47:05
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-27 12:47:05
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-27 12:47:05
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-27 12:47:05
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-27 12:47:05
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-27 12:47:05
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-27 12:47:05
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-27 12:47:05
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-27 12:47:05
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-27 12:47:05
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-27 12:47:05
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-27 12:47:05
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-27 12:47:05
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-27 12:47:05
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-27 12:47:05
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-27 12:47:05
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-27 12:47:05
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-27 12:47:05
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-27 12:47:05
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-27 12:47:05
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-27 12:47:05
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-27 12:47:05
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-27 12:47:05
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-27 12:47:05
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-27 12:47:05
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-27 12:47:05
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-27 12:47:05
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-27 12:47:05
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-27 12:47:05
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-27 12:47:05
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-27 12:47:05
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-27 12:47:05
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-27 12:47:05
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-27 12:47:05
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-27 12:47:05
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-27 12:47:06 8c324076-f317-4670-8bf7-91925011913d
#>   2: sinking_raccoon 2026-06-27 12:47:06 9603d5f2-8864-49a3-9fbb-59d186ec0179
#>   3: sinking_raccoon 2026-06-27 12:47:06 8ad76c01-8895-483c-a5b4-438fe5e5f1c5
#>   4: sinking_raccoon 2026-06-27 12:47:06 e3cb3ba2-1c9e-4a8a-b9f3-179705030a4b
#>   5: sinking_raccoon 2026-06-27 12:47:06 756e11ea-8552-490c-a81c-f4e4c66e1ed2
#>   6: sinking_raccoon 2026-06-27 12:47:06 d70e83a0-f94c-4042-95e1-02252698c442
#>   7: sinking_raccoon 2026-06-27 12:47:06 13c08cd2-ef2c-4433-be75-18069f3706f8
#>   8: sinking_raccoon 2026-06-27 12:47:06 22004421-5242-40be-9ad4-fd70716561d8
#>   9: sinking_raccoon 2026-06-27 12:47:06 ab2eef25-613b-43ec-a369-5bbb6af7a1f9
#>  10: sinking_raccoon 2026-06-27 12:47:06 192e2d67-f0ee-4c8d-af94-997f2e741b84
#>  11: sinking_raccoon 2026-06-27 12:47:06 f5c6bc69-4a8c-4799-8ef6-54f7ec2c26e4
#>  12: sinking_raccoon 2026-06-27 12:47:06 77bed3b9-05f5-4e0c-b8d8-732cbb8584af
#>  13: sinking_raccoon 2026-06-27 12:47:06 c9b1a150-ce97-4270-94f2-40c845ca4ef0
#>  14: sinking_raccoon 2026-06-27 12:47:06 c829e9a3-1586-41a7-bfab-e4374953cd91
#>  15: sinking_raccoon 2026-06-27 12:47:06 244690bc-52a6-42f3-924d-00e5e59b7ef0
#>  16: sinking_raccoon 2026-06-27 12:47:06 fd62b1d3-5fb0-473d-a3b0-1b106cbf2fdb
#>  17: sinking_raccoon 2026-06-27 12:47:06 b52a44a6-7f94-419a-a506-70e437932316
#>  18: sinking_raccoon 2026-06-27 12:47:06 4e9ea76a-1848-4bc7-b8d4-f909c0ea0840
#>  19: sinking_raccoon 2026-06-27 12:47:06 e5c50c5c-9320-4447-941f-8418b67c1200
#>  20: sinking_raccoon 2026-06-27 12:47:06 2324a3cd-96a3-4ef5-a804-d114ae2a5ed1
#>  21:            <NA>                <NA> 61d00281-492f-484b-87a2-50e09fa7c702
#>  22:            <NA>                <NA> 4c982957-7bc0-46e4-b258-e70c716373e6
#>  23:            <NA>                <NA> 7cfc5711-b20b-491b-9fb5-1306a8b03b06
#>  24:            <NA>                <NA> 7585e781-f9eb-4088-be5d-8ba17290eb06
#>  25:            <NA>                <NA> 5fbd86a6-4ada-44d2-9337-6ecc4c352f97
#>  26:            <NA>                <NA> 481ce12e-eb65-4521-b827-92d32da47e41
#>  27:            <NA>                <NA> 47e19523-9c66-407a-afd0-15fa7e36987a
#>  28:            <NA>                <NA> c7025b12-e96d-44af-9668-4772ab046c3c
#>  29:            <NA>                <NA> 1601ec38-2bcc-4637-9e9d-a10d798c3e14
#>  30:            <NA>                <NA> d5d9e2ef-54aa-4af9-a6a9-2c4e41d16535
#>  31:            <NA>                <NA> 8bf96b1e-6ee5-4c8c-9eb1-2ad6e855f0b6
#>  32:            <NA>                <NA> 75557834-f5c8-40ad-aeaa-78328219d2d4
#>  33:            <NA>                <NA> ca93829b-643b-49f1-810c-40abbc0b91ff
#>  34:            <NA>                <NA> 0f814a41-e648-4887-8df0-b798fcb200fb
#>  35:            <NA>                <NA> a025f3e2-2bdd-4a5f-8bc9-74f0e309104b
#>  36:            <NA>                <NA> 91c0b9ec-2fef-4e5f-8a41-b35e1c75b6c4
#>  37:            <NA>                <NA> 156cec7d-adaf-4a20-a52a-5f7109f153f0
#>  38:            <NA>                <NA> 44496a64-ae04-4f75-a7d9-63bba5a2c86e
#>  39:            <NA>                <NA> 9ad137a0-495b-4369-9daa-0aaaa4b5d7b0
#>  40:            <NA>                <NA> fe5f1f4e-1cdf-4a1d-b978-fcefbc6c2c85
#>  41:            <NA>                <NA> c4844708-2868-4a34-a11b-2c069857035c
#>  42:            <NA>                <NA> 9921eae8-c592-40f6-9532-01165b3fc8d8
#>  43:            <NA>                <NA> 8dd4d6c7-5bfe-4e4e-be87-953b6aee47ff
#>  44:            <NA>                <NA> 43145d0d-b306-41cd-8aa2-bf90b0dfa01f
#>  45:            <NA>                <NA> 9b96ca31-bfcc-421b-bb1f-83b4ee46ac43
#>  46:            <NA>                <NA> 4b420064-b531-4021-a771-69a878a5adfe
#>  47:            <NA>                <NA> 410ea13d-04e3-4dbf-9f59-acc7810825b6
#>  48:            <NA>                <NA> 9b3c75fa-1cc1-41f5-8569-b2a232704cb1
#>  49:            <NA>                <NA> 942711b8-2d67-4291-9d9a-ee2a3ecc497a
#>  50:            <NA>                <NA> 606a91ab-8677-459b-bfb3-88ae21ae1da3
#>  51:            <NA>                <NA> 277fd1d6-294d-4c40-b174-e77330b41a3f
#>  52:            <NA>                <NA> 53cdd84a-c8c2-475c-8ed6-61ca4dd90c49
#>  53:            <NA>                <NA> a99ef6f0-a2d6-420d-9f5e-8c8ab7913a07
#>  54:            <NA>                <NA> 073bebb0-5d13-4c27-b2b2-680b3896c3e2
#>  55:            <NA>                <NA> 6c8ba86b-7219-400e-bfdb-4c3accd68d4e
#>  56:            <NA>                <NA> 387694ca-e638-40ef-a56e-1e9a471b2465
#>  57:            <NA>                <NA> b4bd3db5-1325-4068-b6ad-94761105321a
#>  58:            <NA>                <NA> 1b9b57ad-e822-40ad-9937-8ab5a65a7068
#>  59:            <NA>                <NA> ae737a31-e1ba-438f-b4b5-b6111753514b
#>  60:            <NA>                <NA> 1c62d4c7-a3a3-4e76-a14f-7e4230ab7410
#>  61:            <NA>                <NA> 96a181c5-5871-4217-9712-4473195ad347
#>  62:            <NA>                <NA> 787e56ad-4688-410e-8497-6a17313aa7d5
#>  63:            <NA>                <NA> 2a168ae2-4d70-4ed0-87bd-5d3f7d7f34ae
#>  64:            <NA>                <NA> dc3223b6-ab06-4e94-b100-488809b8885a
#>  65:            <NA>                <NA> 3ad5eab4-b7c5-4e94-a7ae-cfaff906d8e7
#>  66:            <NA>                <NA> 8b19a383-b92b-4e53-b5b1-25dd5b3df5f0
#>  67:            <NA>                <NA> a26fbed5-b085-4652-abfd-fac816a872ab
#>  68:            <NA>                <NA> 7ebe09d0-f7c2-4866-b7fd-c8b9e2ca39ef
#>  69:            <NA>                <NA> 794fe555-589c-4828-9c90-c458ced16b3d
#>  70:            <NA>                <NA> d2d542a3-14b3-47be-8948-89350ab1cb46
#>  71:            <NA>                <NA> dc28caa1-3d5a-47c8-864a-1bf2073d3830
#>  72:            <NA>                <NA> eb4136c2-f72f-47e0-9695-349881c0e7e9
#>  73:            <NA>                <NA> 97290c72-aa8d-48f6-996c-59e7cd4e2519
#>  74:            <NA>                <NA> 228286f1-ef72-4e89-b3ef-e63d4d5a02ab
#>  75:            <NA>                <NA> ce91b87e-d03f-4644-b6d9-cb362782e9d1
#>  76:            <NA>                <NA> 087d9116-731e-49be-82ea-f8b616e3dbf6
#>  77:            <NA>                <NA> 49483e3a-6edd-4517-8a9d-4ee47bbe86d3
#>  78:            <NA>                <NA> 0b0ad8ac-8562-4334-8ba5-0edc99638f2d
#>  79:            <NA>                <NA> c978ff24-e29a-420e-9851-620525b3ed79
#>  80:            <NA>                <NA> b98ca8eb-724f-45fe-a725-2f94d7391ea4
#>  81:            <NA>                <NA> ba69c4be-db51-447f-b094-c06839b44039
#>  82:            <NA>                <NA> e1d77b1e-7e40-486d-9d3d-ab96c826606d
#>  83:            <NA>                <NA> e585c42f-0407-464e-a767-d5a13cb23c31
#>  84:            <NA>                <NA> 90da6734-3a56-4916-acfe-d6850af2a95a
#>  85:            <NA>                <NA> 6d1bf155-3d51-408c-a2d8-e8e04836a403
#>  86:            <NA>                <NA> eab94c12-012d-4d2d-b149-5d54b4f33159
#>  87:            <NA>                <NA> ff184885-d7ad-4e3c-8129-8e074c4b10f1
#>  88:            <NA>                <NA> c3db3d70-9ee1-4589-bc21-ddb3bf96ec5c
#>  89:            <NA>                <NA> e52c88ac-6d9e-4a24-9bcc-f5d232e18df5
#>  90:            <NA>                <NA> af20b2e0-28ee-4e85-a634-6d8f11bff4a2
#>  91:            <NA>                <NA> 1288fa98-4ff3-44aa-82c7-33b349083f68
#>  92:            <NA>                <NA> 978cfc24-ff30-4db5-8055-93440c83a26f
#>  93:            <NA>                <NA> b1aaeb2b-8509-40d6-b72a-002782487abf
#>  94:            <NA>                <NA> b2f39c3f-a364-49ae-bc66-293fe05686cd
#>  95:            <NA>                <NA> 8a3c37f9-0865-42ad-ab27-5df54c1cfdfe
#>  96:            <NA>                <NA> b2583b33-774d-4ee0-bfed-2851a8ee99f1
#>  97:            <NA>                <NA> 05097bc8-6bb8-4935-940f-4cf319703f79
#>  98:            <NA>                <NA> 9432173e-1897-4583-ae18-187fbb8e600e
#>  99:            <NA>                <NA> 21107e3c-54e0-411b-94d0-1de7dbb4436f
#> 100:            <NA>                <NA> febd884c-48e0-4b57-b17f-4343f749cc9d
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
