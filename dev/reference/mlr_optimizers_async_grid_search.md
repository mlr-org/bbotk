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
rush::rush_plan(worker_type = "remote")
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
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-09 09:07:13 17019
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-09 09:07:13 17019
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-09 09:07:13 17019
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-09 09:07:13 17019
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-09 09:07:13 17019
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-09 09:07:13 17019
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-09 09:07:13 17019
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-09 09:07:13 17019
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-09 09:07:13 17019
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-09 09:07:13 17019
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-09 09:07:13 17019
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-09 09:07:13 17019
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-09 09:07:13 17019
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-09 09:07:13 17019
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-09 09:07:13 17019
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-09 09:07:13 17019
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-09 09:07:13 17019
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-09 09:07:13 17019
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-09 09:07:13 17019
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-09 09:07:13 17019
#>  21:   failed  10.000000  5.0000000         NA 2026-03-09 09:07:13    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-03-09 09:07:13    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-03-09 09:07:13    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-03-09 09:07:13    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-03-09 09:07:13    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-03-09 09:07:13    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-03-09 09:07:13    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-03-09 09:07:13    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-03-09 09:07:13    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-03-09 09:07:13    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-03-09 09:07:13    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-03-09 09:07:13    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-03-09 09:07:13    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-03-09 09:07:13    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-03-09 09:07:13    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-03-09 09:07:13    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-03-09 09:07:13    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-03-09 09:07:13    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-03-09 09:07:13    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-03-09 09:07:13    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-03-09 09:07:13    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-03-09 09:07:13    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-03-09 09:07:13    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-03-09 09:07:13    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-03-09 09:07:13    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-09 09:07:13    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-09 09:07:13    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-09 09:07:13    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-09 09:07:13    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-09 09:07:13    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-09 09:07:13    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-09 09:07:13    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-09 09:07:13    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-09 09:07:13    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-09 09:07:13    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-09 09:07:13    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-09 09:07:13    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-09 09:07:13    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-09 09:07:13    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-09 09:07:13    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-09 09:07:13    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-09 09:07:13    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-09 09:07:13    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-09 09:07:13    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-09 09:07:13    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-09 09:07:13    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-09 09:07:13    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-09 09:07:14 1cb23797-ec9b-40b0-8ebf-d091e2b26791
#>   2: sinking_raccoon 2026-03-09 09:07:14 a2eed9f6-576c-4cba-bcd7-31a0d545342f
#>   3: sinking_raccoon 2026-03-09 09:07:14 c4475b48-9883-4a85-a8e6-79b6a06d757f
#>   4: sinking_raccoon 2026-03-09 09:07:14 d1fa787b-702a-4b85-9c70-c8bc0f27817f
#>   5: sinking_raccoon 2026-03-09 09:07:14 1d978c78-f55e-46bc-aa2f-9a60bfaf81a2
#>   6: sinking_raccoon 2026-03-09 09:07:14 5777c4e3-6d6d-4cd5-9785-ddb2abb5d2a6
#>   7: sinking_raccoon 2026-03-09 09:07:14 3542c3fe-48a1-4f15-9ae8-33969396f289
#>   8: sinking_raccoon 2026-03-09 09:07:14 1dd2436e-e276-4797-ae1a-11ac7f532cb0
#>   9: sinking_raccoon 2026-03-09 09:07:14 02a342e5-65d6-41df-bd04-fa43da6af603
#>  10: sinking_raccoon 2026-03-09 09:07:14 e7b4a3ba-8b61-4c20-a13c-9fc30c7412fe
#>  11: sinking_raccoon 2026-03-09 09:07:14 4f0dc055-8e13-435f-9431-d27b39d97245
#>  12: sinking_raccoon 2026-03-09 09:07:14 20de7370-01d7-4425-ac5b-333e5f281c20
#>  13: sinking_raccoon 2026-03-09 09:07:14 e2b29ef5-efd1-4a93-ad30-1399f9855f1c
#>  14: sinking_raccoon 2026-03-09 09:07:14 a4875e35-fc2d-45e4-97b1-b0efb4997d9d
#>  15: sinking_raccoon 2026-03-09 09:07:14 63f8f26d-3f85-4f4d-abfb-59858d9a5c13
#>  16: sinking_raccoon 2026-03-09 09:07:14 a34cd7c0-6bd6-4bd4-8865-f304013f991f
#>  17: sinking_raccoon 2026-03-09 09:07:14 9ef6338a-1b63-4427-9fbd-ff0d07c6d59a
#>  18: sinking_raccoon 2026-03-09 09:07:14 6df1e483-3ecf-4c3c-8437-80c67e664347
#>  19: sinking_raccoon 2026-03-09 09:07:14 1bbed3e1-806e-4c74-94b1-babb601c84a9
#>  20: sinking_raccoon 2026-03-09 09:07:14 d06aa231-449e-45e8-bfc7-d369dbbd05e2
#>  21:            <NA>                <NA> 9eabdac0-14be-4e2c-9e23-9a12b4b27b7b
#>  22:            <NA>                <NA> 19f53c65-fb1a-4d8d-acb1-39f6ec579241
#>  23:            <NA>                <NA> 975a7fbf-2418-410a-8d59-8e74bda57eff
#>  24:            <NA>                <NA> 8e8e9a9e-0eed-4d20-ac5e-6606b28b647e
#>  25:            <NA>                <NA> f71a0974-19fe-4529-b561-a50a078b816e
#>  26:            <NA>                <NA> 3b8a22e1-90e6-4fe4-8085-1767df97a05e
#>  27:            <NA>                <NA> a5f14a1f-dc69-498a-be2d-c87e95e49379
#>  28:            <NA>                <NA> 4fb809e0-0806-49a2-ad26-021af2d70ea2
#>  29:            <NA>                <NA> 552be6e2-5ad4-4ab2-bf32-9acf0474d6dc
#>  30:            <NA>                <NA> 793e5ce2-08d9-4688-a678-7563a6a7e4d2
#>  31:            <NA>                <NA> 7c2fe566-7bbe-4dce-aa28-d681745b30e2
#>  32:            <NA>                <NA> be07b653-e2ef-403a-b44b-9833be52fea1
#>  33:            <NA>                <NA> 4219c34e-3bfa-4ec9-ab3c-683ecb4ba787
#>  34:            <NA>                <NA> 6b186a77-28dd-45ee-b499-ed9e7e1c78ef
#>  35:            <NA>                <NA> b19293df-1d7a-48da-a591-d133e62b05b8
#>  36:            <NA>                <NA> bb0a38d9-6dfd-4526-bb80-0aaf20c5cc9d
#>  37:            <NA>                <NA> 46034744-2eac-4b4a-8c6f-604839b195f7
#>  38:            <NA>                <NA> 95c7c279-65e3-4b70-b6e2-4a538ce1187e
#>  39:            <NA>                <NA> 3ab521fa-7f90-4dbb-8553-75329da946b3
#>  40:            <NA>                <NA> 716f85c1-80c1-4df8-9421-0ca3d3612a0f
#>  41:            <NA>                <NA> 157bbc99-1752-43a9-be73-b87c2b637690
#>  42:            <NA>                <NA> bf45c7d1-516c-451f-857a-9e983f9eaf34
#>  43:            <NA>                <NA> e20af9fa-e8db-4ad1-8b7f-69b6891feaed
#>  44:            <NA>                <NA> 7d67f61f-0566-4593-91c5-b3fc874d39c2
#>  45:            <NA>                <NA> 39fe5c4a-29ce-425a-b938-3cb51084fa28
#>  46:            <NA>                <NA> 3b5f7e3e-1d3f-4c18-8afa-91ca171a0fa4
#>  47:            <NA>                <NA> aae49290-b779-4037-8a57-53af8d2f390c
#>  48:            <NA>                <NA> 8da2e136-6c66-4580-9fbe-6bf576001e29
#>  49:            <NA>                <NA> bcce8896-39cf-4181-aba9-32c708d34ca2
#>  50:            <NA>                <NA> fc0f1908-fde6-4874-80c3-4132699c3e41
#>  51:            <NA>                <NA> 959634da-4a5c-4bc6-b54e-b877e409889e
#>  52:            <NA>                <NA> 41ab9c06-1d48-41a9-b859-b71d8c8d987c
#>  53:            <NA>                <NA> 4986e7f0-fef0-4a94-88fb-6375b2aed03a
#>  54:            <NA>                <NA> 09abaee3-a4ed-4016-a2ef-be43d4797671
#>  55:            <NA>                <NA> df6bc54f-4a46-4459-b329-1a56c7966ac2
#>  56:            <NA>                <NA> 586bdc5f-3ca8-4ac2-9649-0921c2529872
#>  57:            <NA>                <NA> 76dce6bd-47e0-43d5-a6f7-73b1d780dd08
#>  58:            <NA>                <NA> 3c4f2c69-8d61-4b7c-bb41-9eae8175ef86
#>  59:            <NA>                <NA> c8fbd5ec-e8ef-4439-9eac-1d4cea935f1e
#>  60:            <NA>                <NA> 11061ca2-bb66-48fc-a7b9-9976956e9a2b
#>  61:            <NA>                <NA> fbee594b-fbf8-4c13-bfad-b701d404cf78
#>  62:            <NA>                <NA> f2f92936-057e-4ddb-9c73-e658a9969871
#>  63:            <NA>                <NA> 083bbfd7-adf6-47f4-adda-3eda5960addd
#>  64:            <NA>                <NA> 6d315bcf-8bb6-4dbe-b4ad-971da57491c8
#>  65:            <NA>                <NA> 6ecee445-dd9c-4900-b90b-36575d612f77
#>  66:            <NA>                <NA> 708aa993-eb73-4117-94c6-4b551af32dcc
#>  67:            <NA>                <NA> 69070a0e-18aa-4d04-9cb7-d3d93480dcb6
#>  68:            <NA>                <NA> aab76217-11a0-4be5-8e54-5a010ede128d
#>  69:            <NA>                <NA> 8a147f69-ef6d-4773-bf8d-272c47d1e0ba
#>  70:            <NA>                <NA> cc9559d0-d8c1-46c9-9c31-3eb3a115a6d0
#>  71:            <NA>                <NA> 9b421094-0313-4401-a628-9baae07d7b95
#>  72:            <NA>                <NA> 563a49b4-f234-4116-bb7e-365a9cc198a2
#>  73:            <NA>                <NA> f0f91d21-8329-4d99-9e78-1121806b5a5c
#>  74:            <NA>                <NA> ecdde8de-3efa-46ae-9f87-6109674c9d40
#>  75:            <NA>                <NA> 82420be8-86c4-430d-ae3c-b1961d5526a9
#>  76:            <NA>                <NA> 23f6d689-c2ca-471f-b155-05d235bf824a
#>  77:            <NA>                <NA> 9ae1427f-aefa-40b2-a680-4491d698eefa
#>  78:            <NA>                <NA> 65a3b24d-6ddc-46d1-91ca-137a01fa0b64
#>  79:            <NA>                <NA> 6578ffd7-6972-4e27-bc25-664cf5e539bd
#>  80:            <NA>                <NA> 719ce293-78ea-491e-93aa-a4f66235b68b
#>  81:            <NA>                <NA> ba6a1150-76da-4349-ba67-4e58faf08d19
#>  82:            <NA>                <NA> ca10fd32-8b58-4878-a9fb-d4a39b25c58c
#>  83:            <NA>                <NA> 43186096-921a-41d7-96d7-15d867e90957
#>  84:            <NA>                <NA> 2d94e277-9537-45cd-b1ac-46f7045e0b60
#>  85:            <NA>                <NA> 8fda3fc0-f5f9-41b3-80c2-1986fd1f9fee
#>  86:            <NA>                <NA> 2cc8bb90-9d13-4589-bf73-f204213ebc67
#>  87:            <NA>                <NA> ebadabc5-6e13-454b-8845-b337d664d09e
#>  88:            <NA>                <NA> 87c2f917-a9a9-4fee-a341-8726264fd95b
#>  89:            <NA>                <NA> e43b4dff-679f-4c9d-86c6-e401e90fe28f
#>  90:            <NA>                <NA> 973fcc0c-a6a1-41a1-b757-f9cd780c70c3
#>  91:            <NA>                <NA> 3e088cf0-f8cf-4705-9847-1e6443f0093e
#>  92:            <NA>                <NA> 8d42b61f-ce24-4d89-8860-f0187176d0ce
#>  93:            <NA>                <NA> fc734cae-5ba2-4ad7-b0aa-2406f4fddb93
#>  94:            <NA>                <NA> 74b88a35-5d23-4e56-aefc-99710966794d
#>  95:            <NA>                <NA> 09dd5e5b-a809-4972-9e96-f55a59cfc6de
#>  96:            <NA>                <NA> 6d9b13fa-b10b-46ed-a774-b4af80e61cb1
#>  97:            <NA>                <NA> 65246332-86cd-4a37-b20c-ea944314f37b
#>  98:            <NA>                <NA> 04469556-51ca-437c-8810-cdab2b722f20
#>  99:            <NA>                <NA> fcee6308-c805-4e7d-abdd-e9a3e518889f
#> 100:            <NA>                <NA> 84decece-dcc6-4504-8200-a586c2784427
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
