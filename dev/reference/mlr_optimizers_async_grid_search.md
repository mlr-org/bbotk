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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-09 17:41:29
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-09 17:41:29
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-09 17:41:29
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-09 17:41:29
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-09 17:41:29
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-09 17:41:29
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-09 17:41:29
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-09 17:41:29
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-09 17:41:29
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-09 17:41:29
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-09 17:41:29
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-09 17:41:29
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-09 17:41:29
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-09 17:41:29
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-09 17:41:29
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-09 17:41:29
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-09 17:41:29
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-09 17:41:29
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-09 17:41:29
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-09 17:41:29
#>  21:   failed  10.000000  5.0000000         NA 2026-06-09 17:41:29
#>  22:   failed  10.000000  3.8888889         NA 2026-06-09 17:41:29
#>  23:   failed  10.000000  2.7777778         NA 2026-06-09 17:41:29
#>  24:   failed  10.000000  1.6666667         NA 2026-06-09 17:41:29
#>  25:   failed  10.000000  0.5555556         NA 2026-06-09 17:41:29
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-09 17:41:29
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-09 17:41:29
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-09 17:41:29
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-09 17:41:29
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-09 17:41:29
#>  31:   failed   7.777778  5.0000000         NA 2026-06-09 17:41:29
#>  32:   failed   7.777778  3.8888889         NA 2026-06-09 17:41:29
#>  33:   failed   7.777778  2.7777778         NA 2026-06-09 17:41:29
#>  34:   failed   7.777778  1.6666667         NA 2026-06-09 17:41:29
#>  35:   failed   7.777778  0.5555556         NA 2026-06-09 17:41:29
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-09 17:41:29
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-09 17:41:29
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-09 17:41:29
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-09 17:41:29
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-09 17:41:29
#>  41:   failed   5.555556  5.0000000         NA 2026-06-09 17:41:29
#>  42:   failed   5.555556  3.8888889         NA 2026-06-09 17:41:29
#>  43:   failed   5.555556  2.7777778         NA 2026-06-09 17:41:29
#>  44:   failed   5.555556  1.6666667         NA 2026-06-09 17:41:29
#>  45:   failed   5.555556  0.5555556         NA 2026-06-09 17:41:29
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-09 17:41:29
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-09 17:41:29
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-09 17:41:29
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-09 17:41:29
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-09 17:41:29
#>  51:   failed   3.333333  5.0000000         NA 2026-06-09 17:41:29
#>  52:   failed   3.333333  3.8888889         NA 2026-06-09 17:41:29
#>  53:   failed   3.333333  2.7777778         NA 2026-06-09 17:41:29
#>  54:   failed   3.333333  1.6666667         NA 2026-06-09 17:41:29
#>  55:   failed   3.333333  0.5555556         NA 2026-06-09 17:41:29
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-09 17:41:29
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-09 17:41:29
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-09 17:41:29
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-09 17:41:29
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-09 17:41:29
#>  61:   failed   1.111111  5.0000000         NA 2026-06-09 17:41:29
#>  62:   failed   1.111111  3.8888889         NA 2026-06-09 17:41:29
#>  63:   failed   1.111111  2.7777778         NA 2026-06-09 17:41:29
#>  64:   failed   1.111111  1.6666667         NA 2026-06-09 17:41:29
#>  65:   failed   1.111111  0.5555556         NA 2026-06-09 17:41:29
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-09 17:41:29
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-09 17:41:29
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-09 17:41:29
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-09 17:41:29
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-09 17:41:29
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-09 17:41:29
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-09 17:41:29
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-09 17:41:29
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-09 17:41:29
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-09 17:41:29
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-09 17:41:29
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-09 17:41:29
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-09 17:41:29
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-09 17:41:29
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-09 17:41:29
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-09 17:41:29
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-09 17:41:29
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-09 17:41:29
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-09 17:41:29
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-09 17:41:29
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-09 17:41:29
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-09 17:41:29
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-09 17:41:29
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-09 17:41:29
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-09 17:41:29
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-09 17:41:29
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-09 17:41:29
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-09 17:41:29
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-09 17:41:29
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-09 17:41:29
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-09 17:41:29
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-09 17:41:29
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-09 17:41:29
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-09 17:41:29
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-09 17:41:29
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-09 17:41:30 7aac3d59-8236-481b-9387-ea7aa59235af
#>   2: sinking_raccoon 2026-06-09 17:41:30 e330c7dc-52f7-4fcc-8a1f-442793bceb57
#>   3: sinking_raccoon 2026-06-09 17:41:30 71844a57-5784-4e17-8ff2-22ac6dbb6482
#>   4: sinking_raccoon 2026-06-09 17:41:30 cb13252a-1ca1-4d60-ace6-3653c93e3eab
#>   5: sinking_raccoon 2026-06-09 17:41:30 786580d9-0f33-4edd-93fe-d91fa3d36643
#>   6: sinking_raccoon 2026-06-09 17:41:30 378594e7-6824-43d0-a7a9-5d2db3f46315
#>   7: sinking_raccoon 2026-06-09 17:41:30 06558190-6082-4762-b2a2-65c13aa4e660
#>   8: sinking_raccoon 2026-06-09 17:41:30 27b4634b-aaf3-4d5b-8c88-01fb2953c946
#>   9: sinking_raccoon 2026-06-09 17:41:30 ee42930f-5aad-4f3e-8f38-76eb46ef0787
#>  10: sinking_raccoon 2026-06-09 17:41:30 f820e9be-161e-47f9-82d4-c65f39135bfb
#>  11: sinking_raccoon 2026-06-09 17:41:30 e3cdbb08-22a6-4ef9-b86c-285647597528
#>  12: sinking_raccoon 2026-06-09 17:41:30 3d1a7cda-f7b1-481c-9dcd-0323dcad6390
#>  13: sinking_raccoon 2026-06-09 17:41:30 24d1c195-26b5-4da9-bca1-15325ba17893
#>  14: sinking_raccoon 2026-06-09 17:41:30 fdc575d2-c530-43b2-b9c5-945a1bbe1a04
#>  15: sinking_raccoon 2026-06-09 17:41:30 c71510fc-b288-4ebb-ac55-e91d7f9e3d5f
#>  16: sinking_raccoon 2026-06-09 17:41:30 16e24dd1-75b1-43ff-87ab-19026161e026
#>  17: sinking_raccoon 2026-06-09 17:41:30 18585f60-6d0c-45a8-9d12-b3a771c47be7
#>  18: sinking_raccoon 2026-06-09 17:41:30 db77b6ad-02df-4e18-97fb-75eba6c8203f
#>  19: sinking_raccoon 2026-06-09 17:41:30 48588c61-e12c-4c35-96c2-1ffafea7fcba
#>  20: sinking_raccoon 2026-06-09 17:41:30 4b4f8d06-e9c6-4893-ae40-b95e64d19cf3
#>  21:            <NA>                <NA> 360ba969-d05c-4e1a-81d8-65d94509fb92
#>  22:            <NA>                <NA> 96f85e20-98ef-429a-83ec-df2a9de6caef
#>  23:            <NA>                <NA> 0941bde6-f738-411f-a134-e86f68c6c11b
#>  24:            <NA>                <NA> 7ba872d8-f7f8-47c9-9761-90acdeadf49f
#>  25:            <NA>                <NA> 8fdf548e-0af2-46a0-ad0e-b579e3001a54
#>  26:            <NA>                <NA> 8033b4bc-b567-4e2d-a496-313c7738892e
#>  27:            <NA>                <NA> b3696ea4-f3e1-428f-9503-3a7fdd7fb4f2
#>  28:            <NA>                <NA> 21fe8be1-082b-4eb7-a40a-0d592fcc2e74
#>  29:            <NA>                <NA> 2c52db5c-a1b5-4feb-8703-aec248907f69
#>  30:            <NA>                <NA> c4969449-7a26-4b37-896e-ac951fbff53d
#>  31:            <NA>                <NA> 733f51fa-8a82-4ffb-88ce-4b202793f728
#>  32:            <NA>                <NA> 78b96c97-5009-4882-8d05-3e55d5d4ef51
#>  33:            <NA>                <NA> 258c5efc-c8a3-4fbc-9dfd-150e97481bad
#>  34:            <NA>                <NA> 24c0d396-86b6-4291-b870-4c7fa6ca5861
#>  35:            <NA>                <NA> 7b7d2bab-6dcb-4d74-ad5d-b7359046b641
#>  36:            <NA>                <NA> deec9622-1d1e-4452-862a-bfe0a9175963
#>  37:            <NA>                <NA> 39b47714-1db5-43e6-81b4-da24857bd113
#>  38:            <NA>                <NA> 0afe0347-d76c-4f3a-bb1c-885d74be0785
#>  39:            <NA>                <NA> e581050c-7a32-447e-a29d-5e00de56ab44
#>  40:            <NA>                <NA> 9c6dae6a-2c04-4d2e-8f25-5b510ca8ee66
#>  41:            <NA>                <NA> d95fcb73-0630-4644-93ef-acd0c9169b41
#>  42:            <NA>                <NA> d8b48e2d-0419-4af8-b3b5-06a06b8f35c0
#>  43:            <NA>                <NA> 1a4914dc-01da-4da8-bd3c-86fe7bfe4266
#>  44:            <NA>                <NA> 7cb47af8-8302-4a2e-9294-023f08437632
#>  45:            <NA>                <NA> fe5d28f8-6fcc-40fe-8f03-e19a203ff306
#>  46:            <NA>                <NA> a8f3f87e-a2c8-4124-bfbd-033630ee929b
#>  47:            <NA>                <NA> b7d10275-56e0-4796-9cf5-6c4cc8e737fc
#>  48:            <NA>                <NA> cca2354d-1090-41f7-b11a-4fbe72074144
#>  49:            <NA>                <NA> a7a04f03-fc34-426e-9031-f158e0a887e7
#>  50:            <NA>                <NA> 07a7a4e9-08f5-4141-b306-7a56f7e4acc2
#>  51:            <NA>                <NA> bf908616-8ae8-4bb9-b404-95bd72693d50
#>  52:            <NA>                <NA> 76558b3d-e279-45b0-98cf-02e0fde034b2
#>  53:            <NA>                <NA> 566406da-5365-4042-9a92-d5e83a621458
#>  54:            <NA>                <NA> ffab9c31-063e-4e8b-8cff-b8a7571e0fb6
#>  55:            <NA>                <NA> dff609ec-64dc-44ac-b6f2-90125c8c4b4b
#>  56:            <NA>                <NA> 3e3c70cc-d52f-4589-9476-167519a23f89
#>  57:            <NA>                <NA> 50c45c2b-5b75-4b52-bc25-6ff1e45fb6b1
#>  58:            <NA>                <NA> fb6a670d-c7f6-4adc-98ce-f108a31722e7
#>  59:            <NA>                <NA> dc85789d-174c-4af5-be57-ab76ffa86f0f
#>  60:            <NA>                <NA> 43277f0d-972b-42db-8630-41df254a0ea2
#>  61:            <NA>                <NA> 6c8a7672-b9f3-451f-b5ad-786321b0e1f5
#>  62:            <NA>                <NA> 891c24fc-db29-41df-abf5-9f5e981f00ef
#>  63:            <NA>                <NA> 28273d6c-4035-43d1-b6e7-1b1e9a29fb33
#>  64:            <NA>                <NA> e9096002-8f4d-4959-b7d1-8b45d72689d4
#>  65:            <NA>                <NA> ea5dabf7-bb73-479f-b6a9-6644e92d5995
#>  66:            <NA>                <NA> c80f9853-7ce1-4f16-8c62-502b5749f5c2
#>  67:            <NA>                <NA> ca039877-2619-4a2e-b8f0-e1ebb565fe42
#>  68:            <NA>                <NA> 7f14b0cc-b4a4-40bc-a49c-663207782c98
#>  69:            <NA>                <NA> 73d9f845-24f3-43d2-9132-d1516ceef05f
#>  70:            <NA>                <NA> f8681992-c3a0-42de-a7a5-2fa9e33e314a
#>  71:            <NA>                <NA> 1409610e-bfcb-4e50-b4c0-289675605d62
#>  72:            <NA>                <NA> e5e7149e-0fdf-434e-a395-a198ed5fdf49
#>  73:            <NA>                <NA> f64b81ce-b410-46ae-aa51-1933c7cfaebf
#>  74:            <NA>                <NA> b2b4af70-ed08-4028-b5a4-11a3c9996cad
#>  75:            <NA>                <NA> 2fd8d2f6-bb6b-4caa-85b7-0e4ef41e4152
#>  76:            <NA>                <NA> 3684cc0d-e568-4aa5-9e43-b64cf3b78dc0
#>  77:            <NA>                <NA> d4482695-4083-444e-b299-dbd6474edb33
#>  78:            <NA>                <NA> 237ee5f3-9d13-4241-a502-fa87df0ccedd
#>  79:            <NA>                <NA> 4a3fe851-c871-4784-b8d2-dc1e2e4928a9
#>  80:            <NA>                <NA> ba3f56f1-d163-41c8-9ee3-1a9ba4463358
#>  81:            <NA>                <NA> 1e82d402-faf9-4fb5-b0ee-d4ef4f08784c
#>  82:            <NA>                <NA> a6ac2272-1cfe-4a7a-bccc-2d4b40a83d26
#>  83:            <NA>                <NA> 81d563c9-cfcb-4cbd-b2fa-5088fc91b84d
#>  84:            <NA>                <NA> 2aeefbf6-d941-4dd4-8d71-3e77bea4cd93
#>  85:            <NA>                <NA> d9e1aba0-b312-4f25-96bc-6617dedd93fa
#>  86:            <NA>                <NA> 089d827b-9ed9-4e19-b5b4-f0bdc4fe836d
#>  87:            <NA>                <NA> 7246730d-c5d2-4dc9-b7d3-177c937c36b8
#>  88:            <NA>                <NA> 67fa65b3-7ece-49a8-96a9-9c060476d71d
#>  89:            <NA>                <NA> 7846b13e-3109-42e3-9deb-1f8e1b5d19de
#>  90:            <NA>                <NA> 69a6bfe7-1b02-4b31-a5ed-70379a88c3b7
#>  91:            <NA>                <NA> 2f076150-ab51-4f99-ab36-60987ef179d8
#>  92:            <NA>                <NA> 109581f6-dca5-4192-bb39-9c8e7978f71d
#>  93:            <NA>                <NA> 0bae4814-06e5-4b59-bb49-ef3d8fa34bf8
#>  94:            <NA>                <NA> 5789b3b0-29e1-41f1-a11d-18b692edda05
#>  95:            <NA>                <NA> 15bd54cf-bec2-417e-91de-99480c5ee21d
#>  96:            <NA>                <NA> a6806696-ed71-4bab-9cba-f1b4478f72a0
#>  97:            <NA>                <NA> 24750c70-55f4-444b-8387-3f4a49214ffa
#>  98:            <NA>                <NA> 5fd98b2e-b7b4-4841-b5ca-cd4dae5b885f
#>  99:            <NA>                <NA> 2e2108e1-fcfc-4445-823d-1163d99cebe5
#> 100:            <NA>                <NA> 75e4df30-b2f2-4e6d-959c-bfeb54414210
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
