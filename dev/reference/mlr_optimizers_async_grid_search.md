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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-04-07 07:11:11
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-04-07 07:11:11
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-04-07 07:11:11
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-04-07 07:11:11
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-04-07 07:11:11
#>   6: finished -10.000000  0.5555556 -146.64198 2026-04-07 07:11:11
#>   7: finished -10.000000  1.6666667 -155.77778 2026-04-07 07:11:11
#>   8: finished -10.000000  2.7777778 -167.38272 2026-04-07 07:11:11
#>   9: finished -10.000000  3.8888889 -181.45679 2026-04-07 07:11:11
#>  10: finished -10.000000  5.0000000 -198.00000 2026-04-07 07:11:11
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-04-07 07:11:11
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-04-07 07:11:11
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-04-07 07:11:11
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-04-07 07:11:11
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-04-07 07:11:11
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-04-07 07:11:11
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-04-07 07:11:11
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-04-07 07:11:11
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-04-07 07:11:11
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-04-07 07:11:11
#>  21:   failed  10.000000  5.0000000         NA 2026-04-07 07:11:11
#>  22:   failed  10.000000  3.8888889         NA 2026-04-07 07:11:11
#>  23:   failed  10.000000  2.7777778         NA 2026-04-07 07:11:11
#>  24:   failed  10.000000  1.6666667         NA 2026-04-07 07:11:11
#>  25:   failed  10.000000  0.5555556         NA 2026-04-07 07:11:11
#>  26:   failed  10.000000 -0.5555556         NA 2026-04-07 07:11:11
#>  27:   failed  10.000000 -1.6666667         NA 2026-04-07 07:11:11
#>  28:   failed  10.000000 -2.7777778         NA 2026-04-07 07:11:11
#>  29:   failed  10.000000 -3.8888889         NA 2026-04-07 07:11:11
#>  30:   failed  10.000000 -5.0000000         NA 2026-04-07 07:11:11
#>  31:   failed   7.777778  5.0000000         NA 2026-04-07 07:11:11
#>  32:   failed   7.777778  3.8888889         NA 2026-04-07 07:11:11
#>  33:   failed   7.777778  2.7777778         NA 2026-04-07 07:11:11
#>  34:   failed   7.777778  1.6666667         NA 2026-04-07 07:11:11
#>  35:   failed   7.777778  0.5555556         NA 2026-04-07 07:11:11
#>  36:   failed   7.777778 -0.5555556         NA 2026-04-07 07:11:11
#>  37:   failed   7.777778 -1.6666667         NA 2026-04-07 07:11:11
#>  38:   failed   7.777778 -2.7777778         NA 2026-04-07 07:11:11
#>  39:   failed   7.777778 -3.8888889         NA 2026-04-07 07:11:11
#>  40:   failed   7.777778 -5.0000000         NA 2026-04-07 07:11:11
#>  41:   failed   5.555556  5.0000000         NA 2026-04-07 07:11:11
#>  42:   failed   5.555556  3.8888889         NA 2026-04-07 07:11:11
#>  43:   failed   5.555556  2.7777778         NA 2026-04-07 07:11:11
#>  44:   failed   5.555556  1.6666667         NA 2026-04-07 07:11:11
#>  45:   failed   5.555556  0.5555556         NA 2026-04-07 07:11:11
#>  46:   failed   5.555556 -0.5555556         NA 2026-04-07 07:11:11
#>  47:   failed   5.555556 -1.6666667         NA 2026-04-07 07:11:11
#>  48:   failed   5.555556 -2.7777778         NA 2026-04-07 07:11:11
#>  49:   failed   5.555556 -3.8888889         NA 2026-04-07 07:11:11
#>  50:   failed   5.555556 -5.0000000         NA 2026-04-07 07:11:11
#>  51:   failed   3.333333  5.0000000         NA 2026-04-07 07:11:11
#>  52:   failed   3.333333  3.8888889         NA 2026-04-07 07:11:11
#>  53:   failed   3.333333  2.7777778         NA 2026-04-07 07:11:11
#>  54:   failed   3.333333  1.6666667         NA 2026-04-07 07:11:11
#>  55:   failed   3.333333  0.5555556         NA 2026-04-07 07:11:11
#>  56:   failed   3.333333 -0.5555556         NA 2026-04-07 07:11:11
#>  57:   failed   3.333333 -1.6666667         NA 2026-04-07 07:11:11
#>  58:   failed   3.333333 -2.7777778         NA 2026-04-07 07:11:11
#>  59:   failed   3.333333 -3.8888889         NA 2026-04-07 07:11:11
#>  60:   failed   3.333333 -5.0000000         NA 2026-04-07 07:11:11
#>  61:   failed   1.111111  5.0000000         NA 2026-04-07 07:11:11
#>  62:   failed   1.111111  3.8888889         NA 2026-04-07 07:11:11
#>  63:   failed   1.111111  2.7777778         NA 2026-04-07 07:11:11
#>  64:   failed   1.111111  1.6666667         NA 2026-04-07 07:11:11
#>  65:   failed   1.111111  0.5555556         NA 2026-04-07 07:11:11
#>  66:   failed   1.111111 -0.5555556         NA 2026-04-07 07:11:11
#>  67:   failed   1.111111 -1.6666667         NA 2026-04-07 07:11:11
#>  68:   failed   1.111111 -2.7777778         NA 2026-04-07 07:11:11
#>  69:   failed   1.111111 -3.8888889         NA 2026-04-07 07:11:11
#>  70:   failed   1.111111 -5.0000000         NA 2026-04-07 07:11:11
#>  71:   failed  -1.111111  5.0000000         NA 2026-04-07 07:11:11
#>  72:   failed  -1.111111  3.8888889         NA 2026-04-07 07:11:11
#>  73:   failed  -1.111111  2.7777778         NA 2026-04-07 07:11:11
#>  74:   failed  -1.111111  1.6666667         NA 2026-04-07 07:11:11
#>  75:   failed  -1.111111  0.5555556         NA 2026-04-07 07:11:11
#>  76:   failed  -1.111111 -0.5555556         NA 2026-04-07 07:11:11
#>  77:   failed  -1.111111 -1.6666667         NA 2026-04-07 07:11:11
#>  78:   failed  -1.111111 -2.7777778         NA 2026-04-07 07:11:11
#>  79:   failed  -1.111111 -3.8888889         NA 2026-04-07 07:11:11
#>  80:   failed  -1.111111 -5.0000000         NA 2026-04-07 07:11:11
#>  81:   failed  -3.333333  5.0000000         NA 2026-04-07 07:11:11
#>  82:   failed  -3.333333  3.8888889         NA 2026-04-07 07:11:11
#>  83:   failed  -3.333333  2.7777778         NA 2026-04-07 07:11:11
#>  84:   failed  -3.333333  1.6666667         NA 2026-04-07 07:11:11
#>  85:   failed  -3.333333  0.5555556         NA 2026-04-07 07:11:11
#>  86:   failed  -3.333333 -0.5555556         NA 2026-04-07 07:11:11
#>  87:   failed  -3.333333 -1.6666667         NA 2026-04-07 07:11:11
#>  88:   failed  -3.333333 -2.7777778         NA 2026-04-07 07:11:11
#>  89:   failed  -3.333333 -3.8888889         NA 2026-04-07 07:11:11
#>  90:   failed  -3.333333 -5.0000000         NA 2026-04-07 07:11:11
#>  91:   failed  -5.555556  5.0000000         NA 2026-04-07 07:11:11
#>  92:   failed  -5.555556  3.8888889         NA 2026-04-07 07:11:11
#>  93:   failed  -5.555556  2.7777778         NA 2026-04-07 07:11:11
#>  94:   failed  -5.555556  1.6666667         NA 2026-04-07 07:11:11
#>  95:   failed  -5.555556  0.5555556         NA 2026-04-07 07:11:11
#>  96:   failed  -5.555556 -0.5555556         NA 2026-04-07 07:11:11
#>  97:   failed  -5.555556 -1.6666667         NA 2026-04-07 07:11:11
#>  98:   failed  -5.555556 -2.7777778         NA 2026-04-07 07:11:11
#>  99:   failed  -5.555556 -3.8888889         NA 2026-04-07 07:11:11
#> 100:   failed  -5.555556 -5.0000000         NA 2026-04-07 07:11:11
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-04-07 07:11:12 d5d8e896-bf16-4f1a-935d-db8f42a1be8f
#>   2: sinking_raccoon 2026-04-07 07:11:12 40a20c0a-f24c-4ae8-b960-1cd183dc2531
#>   3: sinking_raccoon 2026-04-07 07:11:12 29db3f9b-33c1-40b0-8f6d-9c01a56950e0
#>   4: sinking_raccoon 2026-04-07 07:11:12 c7f611e1-f406-4b6b-b1b0-c188c851ed04
#>   5: sinking_raccoon 2026-04-07 07:11:12 1f1938c0-4528-4703-b43c-bbe82051a570
#>   6: sinking_raccoon 2026-04-07 07:11:12 bc319edf-81b4-4359-9c50-20f2ba0d4024
#>   7: sinking_raccoon 2026-04-07 07:11:12 7663b279-0360-4114-a0a0-158c57265078
#>   8: sinking_raccoon 2026-04-07 07:11:12 d415610a-d229-4aed-8a3b-b290448b9997
#>   9: sinking_raccoon 2026-04-07 07:11:12 c4ee46aa-ac53-474b-ad22-5c6d4de52fb6
#>  10: sinking_raccoon 2026-04-07 07:11:12 afb1a520-e7ff-4832-8c61-ea436644aef2
#>  11: sinking_raccoon 2026-04-07 07:11:12 f054898c-c072-487f-a399-9ddcb1597673
#>  12: sinking_raccoon 2026-04-07 07:11:12 88258081-a743-4891-bcb7-e2bb64ef3833
#>  13: sinking_raccoon 2026-04-07 07:11:12 5c1b0cc0-e2c0-4a18-b217-84ec2e09fb36
#>  14: sinking_raccoon 2026-04-07 07:11:12 6e28e1b4-d288-4811-9294-9220d77c3686
#>  15: sinking_raccoon 2026-04-07 07:11:12 11a60dbf-9f7e-416e-a874-2f1ee2dfa02d
#>  16: sinking_raccoon 2026-04-07 07:11:12 03a1ab2e-2a54-46c5-8a4f-99492402287b
#>  17: sinking_raccoon 2026-04-07 07:11:12 f6aaf603-05c1-4e2b-aaa7-f3af190d4ecc
#>  18: sinking_raccoon 2026-04-07 07:11:12 24989543-79c3-42bc-9a16-9db6d344cf5e
#>  19: sinking_raccoon 2026-04-07 07:11:12 78dc0415-4a1a-4320-8482-8cb8e8cedd41
#>  20: sinking_raccoon 2026-04-07 07:11:12 6ce48ce1-80d6-4958-8015-9f97a25a50ce
#>  21:            <NA>                <NA> d0583a52-10a4-4ec0-bfa3-d7189e101c5f
#>  22:            <NA>                <NA> 95cfe120-2756-4fa5-999f-11d2493548a2
#>  23:            <NA>                <NA> bb1aad08-c310-43bd-a908-e2a70f2b37f9
#>  24:            <NA>                <NA> 8e4e72a0-69d3-46f0-825e-cdac88b9cdfe
#>  25:            <NA>                <NA> 9d3aeb9d-8560-42fb-aab2-98bba1501679
#>  26:            <NA>                <NA> a781d597-2778-4437-baa1-c955dc543e05
#>  27:            <NA>                <NA> e2d96e32-5a48-4d97-b2b0-bf473f404795
#>  28:            <NA>                <NA> c264e9ec-f9cc-4563-a8fc-b85c4bd5302d
#>  29:            <NA>                <NA> eabf8ed3-87fc-4c32-b2e3-ff076b62e5b0
#>  30:            <NA>                <NA> a24d009f-0696-4516-b5f6-c4655ba23b61
#>  31:            <NA>                <NA> fefbec87-2093-4fe2-8b76-1a9b68b84600
#>  32:            <NA>                <NA> 39b5f1c8-8587-41b7-a745-469de967a7ec
#>  33:            <NA>                <NA> bb76f35b-80c6-43e0-be64-70a40f56bb88
#>  34:            <NA>                <NA> e6dabde8-09cc-4fc9-b85f-e040d8ee4c48
#>  35:            <NA>                <NA> 5556715c-e1f3-4ecc-9bca-f8b4225902a6
#>  36:            <NA>                <NA> 70fa2baa-d963-4249-8d8a-32cc768423fb
#>  37:            <NA>                <NA> 14bf9588-3705-43a5-8ff4-7036c434f032
#>  38:            <NA>                <NA> a84c5baf-da9c-4c57-b969-4905a1d4b2dc
#>  39:            <NA>                <NA> ac0bbae8-14f5-4306-885f-86a1c727e393
#>  40:            <NA>                <NA> 8872b9db-7491-489e-8f9a-fd031160c9f6
#>  41:            <NA>                <NA> 7964de8b-c67f-4bab-bca6-6e3036355923
#>  42:            <NA>                <NA> 99463530-f2fa-4d4b-8667-64cb58c11330
#>  43:            <NA>                <NA> 364c12d7-ee02-48c2-96e2-477101fe71b9
#>  44:            <NA>                <NA> c9dcda62-68fb-4090-b2eb-36ee6c78fdfa
#>  45:            <NA>                <NA> 0081abea-c394-4071-ad8d-0e75dd0488d6
#>  46:            <NA>                <NA> 2e0c708a-24a8-4718-9fac-a47b10777d5a
#>  47:            <NA>                <NA> 5e538cef-b682-4f7a-8449-ec165cb0f235
#>  48:            <NA>                <NA> 9026a061-3fbc-47b0-a455-0cf77f5cba9a
#>  49:            <NA>                <NA> 3a32d0eb-1d84-41f2-a205-8b7a9beb488e
#>  50:            <NA>                <NA> c5dce635-74aa-43f8-b0c4-fbb9a9014c4e
#>  51:            <NA>                <NA> 1bdd2569-6ef3-4f3e-a414-e51d5856bf56
#>  52:            <NA>                <NA> 35fd1119-2f56-48bb-9988-63235282216a
#>  53:            <NA>                <NA> 3d0bf974-3312-4d8b-a673-4293b8e258eb
#>  54:            <NA>                <NA> f6909058-32bd-4358-bd37-28a6af16e911
#>  55:            <NA>                <NA> aacffceb-866e-4c7f-bed9-4be857f9eda0
#>  56:            <NA>                <NA> 66043f9f-9c1c-47fc-9e37-2c0cffcbb8b0
#>  57:            <NA>                <NA> a7df2717-fbcb-407e-b34c-50e635b5f8f6
#>  58:            <NA>                <NA> 3708101d-bebd-4565-a12f-431d8b40ee18
#>  59:            <NA>                <NA> b0d00df3-0369-49f1-bd17-79d06f2a260e
#>  60:            <NA>                <NA> e44efff5-39dc-478e-84dc-c940215bea6a
#>  61:            <NA>                <NA> febfa1b3-754c-45ce-944b-f432fec227b8
#>  62:            <NA>                <NA> 092d8a8e-6b83-4087-8084-99c20ec4e6bc
#>  63:            <NA>                <NA> 468bec03-81df-43f9-be57-48b283bb9865
#>  64:            <NA>                <NA> 89bc794f-3f86-40dc-85f5-9fdf36b81cda
#>  65:            <NA>                <NA> 81475a1a-b242-46f1-b7b5-b21aca004c40
#>  66:            <NA>                <NA> 99454e56-170f-4ca3-9659-120e7645ac25
#>  67:            <NA>                <NA> 2f012bce-0abf-4aab-8c80-db7a662c97bd
#>  68:            <NA>                <NA> 37c2643e-de7f-4239-bc25-689303d660ff
#>  69:            <NA>                <NA> 0a2047a0-3c55-4e4c-b5bf-4a7ae3c2c6b7
#>  70:            <NA>                <NA> 5365f4f9-53f6-4f4e-88c5-0cb072a61809
#>  71:            <NA>                <NA> 7ca25de7-f162-44cb-b908-aa705110aa3b
#>  72:            <NA>                <NA> b1a927c0-09f7-4452-bfd6-b3e9af4cab5a
#>  73:            <NA>                <NA> a5d663d2-b3e8-466f-b1f5-adab7f3b7bff
#>  74:            <NA>                <NA> 50643ae3-6454-4b72-8b4c-d517a73abf2d
#>  75:            <NA>                <NA> db331188-bcf7-4ad2-bf65-6f58122fe014
#>  76:            <NA>                <NA> 12cae3dd-bb70-4b35-a4f4-b48188dc2539
#>  77:            <NA>                <NA> 8c978485-f0ee-466a-b6d9-095d2dff5522
#>  78:            <NA>                <NA> f1a1aa33-1de3-487e-b42b-6d6a26682eaf
#>  79:            <NA>                <NA> afbd60c9-7d7a-4276-b6b2-d6d50ff215ba
#>  80:            <NA>                <NA> 7bff399a-89ff-4cc8-a8d9-41834b46b20c
#>  81:            <NA>                <NA> ba22e01d-b550-4b39-87f0-2a87672fd158
#>  82:            <NA>                <NA> b718cfe2-c4c8-4cfe-8b19-1513d10baec1
#>  83:            <NA>                <NA> 57cab52c-16d2-49f9-a56c-ac7d6de338c2
#>  84:            <NA>                <NA> abf17603-1a91-42f6-8965-56e41b3697af
#>  85:            <NA>                <NA> 12f4a37a-314c-4ffd-b0be-00bdb08721c4
#>  86:            <NA>                <NA> bf1c82b7-b120-4e4b-ac16-591895c507ec
#>  87:            <NA>                <NA> bee26fb4-9129-4363-b89f-578b8d69eaad
#>  88:            <NA>                <NA> a8824baa-3978-4ebe-bbe4-58df8f2bab7f
#>  89:            <NA>                <NA> ca87948b-30fd-4586-9b2f-e306f616c0aa
#>  90:            <NA>                <NA> 33e6c65f-580c-401f-9355-1b3a0ab317f5
#>  91:            <NA>                <NA> 5a428f34-5dcc-4c3f-a0a7-a009245a8223
#>  92:            <NA>                <NA> 0ea9f78a-5010-4105-9e82-31e8523356e2
#>  93:            <NA>                <NA> 519c7807-9b2d-42d1-9418-f11b248cb4d9
#>  94:            <NA>                <NA> 3e0cf777-55f6-4967-b51c-5d08d4139887
#>  95:            <NA>                <NA> e4a0c6d4-aeb6-4fe7-9568-8328f1c8f248
#>  96:            <NA>                <NA> c29a3066-4ed9-4bcd-bc02-f29680c2e36d
#>  97:            <NA>                <NA> 14a57611-4bd9-456f-af79-03481cceaeff
#>  98:            <NA>                <NA> 4b3b8d4e-6903-4737-bbb1-6f4a23cc57f3
#>  99:            <NA>                <NA> 64e702a4-d38b-4dc9-aedb-ee1e27b2456b
#> 100:            <NA>                <NA> a6f38856-c57e-43f2-ab1a-ce008a227e80
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
