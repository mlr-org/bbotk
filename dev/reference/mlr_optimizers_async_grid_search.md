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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-06-26 10:11:02
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-06-26 10:11:02
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-06-26 10:11:02
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-06-26 10:11:02
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-06-26 10:11:02
#>   6: finished -10.000000  0.5555556 -146.64198 2026-06-26 10:11:02
#>   7: finished -10.000000  1.6666667 -155.77778 2026-06-26 10:11:02
#>   8: finished -10.000000  2.7777778 -167.38272 2026-06-26 10:11:02
#>   9: finished -10.000000  3.8888889 -181.45679 2026-06-26 10:11:02
#>  10: finished -10.000000  5.0000000 -198.00000 2026-06-26 10:11:02
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-06-26 10:11:02
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-06-26 10:11:02
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-06-26 10:11:02
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-06-26 10:11:02
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-06-26 10:11:02
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-06-26 10:11:02
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-06-26 10:11:02
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-06-26 10:11:02
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-06-26 10:11:02
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-06-26 10:11:02
#>  21:   failed  10.000000  5.0000000         NA 2026-06-26 10:11:02
#>  22:   failed  10.000000  3.8888889         NA 2026-06-26 10:11:02
#>  23:   failed  10.000000  2.7777778         NA 2026-06-26 10:11:02
#>  24:   failed  10.000000  1.6666667         NA 2026-06-26 10:11:02
#>  25:   failed  10.000000  0.5555556         NA 2026-06-26 10:11:02
#>  26:   failed  10.000000 -0.5555556         NA 2026-06-26 10:11:02
#>  27:   failed  10.000000 -1.6666667         NA 2026-06-26 10:11:02
#>  28:   failed  10.000000 -2.7777778         NA 2026-06-26 10:11:02
#>  29:   failed  10.000000 -3.8888889         NA 2026-06-26 10:11:02
#>  30:   failed  10.000000 -5.0000000         NA 2026-06-26 10:11:02
#>  31:   failed   7.777778  5.0000000         NA 2026-06-26 10:11:02
#>  32:   failed   7.777778  3.8888889         NA 2026-06-26 10:11:02
#>  33:   failed   7.777778  2.7777778         NA 2026-06-26 10:11:02
#>  34:   failed   7.777778  1.6666667         NA 2026-06-26 10:11:02
#>  35:   failed   7.777778  0.5555556         NA 2026-06-26 10:11:02
#>  36:   failed   7.777778 -0.5555556         NA 2026-06-26 10:11:02
#>  37:   failed   7.777778 -1.6666667         NA 2026-06-26 10:11:02
#>  38:   failed   7.777778 -2.7777778         NA 2026-06-26 10:11:02
#>  39:   failed   7.777778 -3.8888889         NA 2026-06-26 10:11:02
#>  40:   failed   7.777778 -5.0000000         NA 2026-06-26 10:11:02
#>  41:   failed   5.555556  5.0000000         NA 2026-06-26 10:11:02
#>  42:   failed   5.555556  3.8888889         NA 2026-06-26 10:11:02
#>  43:   failed   5.555556  2.7777778         NA 2026-06-26 10:11:02
#>  44:   failed   5.555556  1.6666667         NA 2026-06-26 10:11:02
#>  45:   failed   5.555556  0.5555556         NA 2026-06-26 10:11:02
#>  46:   failed   5.555556 -0.5555556         NA 2026-06-26 10:11:02
#>  47:   failed   5.555556 -1.6666667         NA 2026-06-26 10:11:02
#>  48:   failed   5.555556 -2.7777778         NA 2026-06-26 10:11:02
#>  49:   failed   5.555556 -3.8888889         NA 2026-06-26 10:11:02
#>  50:   failed   5.555556 -5.0000000         NA 2026-06-26 10:11:02
#>  51:   failed   3.333333  5.0000000         NA 2026-06-26 10:11:02
#>  52:   failed   3.333333  3.8888889         NA 2026-06-26 10:11:02
#>  53:   failed   3.333333  2.7777778         NA 2026-06-26 10:11:02
#>  54:   failed   3.333333  1.6666667         NA 2026-06-26 10:11:02
#>  55:   failed   3.333333  0.5555556         NA 2026-06-26 10:11:02
#>  56:   failed   3.333333 -0.5555556         NA 2026-06-26 10:11:02
#>  57:   failed   3.333333 -1.6666667         NA 2026-06-26 10:11:02
#>  58:   failed   3.333333 -2.7777778         NA 2026-06-26 10:11:02
#>  59:   failed   3.333333 -3.8888889         NA 2026-06-26 10:11:02
#>  60:   failed   3.333333 -5.0000000         NA 2026-06-26 10:11:02
#>  61:   failed   1.111111  5.0000000         NA 2026-06-26 10:11:02
#>  62:   failed   1.111111  3.8888889         NA 2026-06-26 10:11:02
#>  63:   failed   1.111111  2.7777778         NA 2026-06-26 10:11:02
#>  64:   failed   1.111111  1.6666667         NA 2026-06-26 10:11:02
#>  65:   failed   1.111111  0.5555556         NA 2026-06-26 10:11:02
#>  66:   failed   1.111111 -0.5555556         NA 2026-06-26 10:11:02
#>  67:   failed   1.111111 -1.6666667         NA 2026-06-26 10:11:02
#>  68:   failed   1.111111 -2.7777778         NA 2026-06-26 10:11:02
#>  69:   failed   1.111111 -3.8888889         NA 2026-06-26 10:11:02
#>  70:   failed   1.111111 -5.0000000         NA 2026-06-26 10:11:02
#>  71:   failed  -1.111111  5.0000000         NA 2026-06-26 10:11:02
#>  72:   failed  -1.111111  3.8888889         NA 2026-06-26 10:11:02
#>  73:   failed  -1.111111  2.7777778         NA 2026-06-26 10:11:02
#>  74:   failed  -1.111111  1.6666667         NA 2026-06-26 10:11:02
#>  75:   failed  -1.111111  0.5555556         NA 2026-06-26 10:11:02
#>  76:   failed  -1.111111 -0.5555556         NA 2026-06-26 10:11:02
#>  77:   failed  -1.111111 -1.6666667         NA 2026-06-26 10:11:02
#>  78:   failed  -1.111111 -2.7777778         NA 2026-06-26 10:11:02
#>  79:   failed  -1.111111 -3.8888889         NA 2026-06-26 10:11:02
#>  80:   failed  -1.111111 -5.0000000         NA 2026-06-26 10:11:02
#>  81:   failed  -3.333333  5.0000000         NA 2026-06-26 10:11:02
#>  82:   failed  -3.333333  3.8888889         NA 2026-06-26 10:11:02
#>  83:   failed  -3.333333  2.7777778         NA 2026-06-26 10:11:02
#>  84:   failed  -3.333333  1.6666667         NA 2026-06-26 10:11:02
#>  85:   failed  -3.333333  0.5555556         NA 2026-06-26 10:11:02
#>  86:   failed  -3.333333 -0.5555556         NA 2026-06-26 10:11:02
#>  87:   failed  -3.333333 -1.6666667         NA 2026-06-26 10:11:02
#>  88:   failed  -3.333333 -2.7777778         NA 2026-06-26 10:11:02
#>  89:   failed  -3.333333 -3.8888889         NA 2026-06-26 10:11:02
#>  90:   failed  -3.333333 -5.0000000         NA 2026-06-26 10:11:02
#>  91:   failed  -5.555556  5.0000000         NA 2026-06-26 10:11:02
#>  92:   failed  -5.555556  3.8888889         NA 2026-06-26 10:11:02
#>  93:   failed  -5.555556  2.7777778         NA 2026-06-26 10:11:02
#>  94:   failed  -5.555556  1.6666667         NA 2026-06-26 10:11:02
#>  95:   failed  -5.555556  0.5555556         NA 2026-06-26 10:11:02
#>  96:   failed  -5.555556 -0.5555556         NA 2026-06-26 10:11:02
#>  97:   failed  -5.555556 -1.6666667         NA 2026-06-26 10:11:02
#>  98:   failed  -5.555556 -2.7777778         NA 2026-06-26 10:11:02
#>  99:   failed  -5.555556 -3.8888889         NA 2026-06-26 10:11:02
#> 100:   failed  -5.555556 -5.0000000         NA 2026-06-26 10:11:02
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-06-26 10:11:03 b35b617d-97a3-4daf-9fb6-034defe0ef56
#>   2: sinking_raccoon 2026-06-26 10:11:03 26929fd8-a83f-42b7-8ca4-884203c4cad0
#>   3: sinking_raccoon 2026-06-26 10:11:03 68b16b2f-60b3-4abc-a951-c2e82c456d1c
#>   4: sinking_raccoon 2026-06-26 10:11:03 47cbb549-ea2a-47eb-80dc-ceef895c1787
#>   5: sinking_raccoon 2026-06-26 10:11:03 c6355b5b-b293-4c02-8d49-d86ae6eae120
#>   6: sinking_raccoon 2026-06-26 10:11:03 96740803-cc5c-40f2-92c1-946084c12efd
#>   7: sinking_raccoon 2026-06-26 10:11:03 458c8817-fdb0-47af-aeca-bec39f50dff7
#>   8: sinking_raccoon 2026-06-26 10:11:03 f0e2e66a-159e-454b-829a-07b65cebb8e6
#>   9: sinking_raccoon 2026-06-26 10:11:03 904ef1d9-ce4e-4aad-a710-d2f4417c3e84
#>  10: sinking_raccoon 2026-06-26 10:11:03 8c541a33-da39-41d2-99ba-6e39a4614320
#>  11: sinking_raccoon 2026-06-26 10:11:03 f646371f-97e8-494d-83a0-5192d4e214f4
#>  12: sinking_raccoon 2026-06-26 10:11:03 199e6ae7-630d-40d4-9999-88b1353e6932
#>  13: sinking_raccoon 2026-06-26 10:11:03 eeb22549-ffbc-4aa2-ab6d-70b61e934e54
#>  14: sinking_raccoon 2026-06-26 10:11:03 066617e2-50c0-4a1c-9291-9d93ff92a75a
#>  15: sinking_raccoon 2026-06-26 10:11:04 a9181356-242c-4b42-8035-cb25aca79f0a
#>  16: sinking_raccoon 2026-06-26 10:11:04 7abf4612-fd39-40d9-b2f0-89f87ee5014a
#>  17: sinking_raccoon 2026-06-26 10:11:04 0671a149-a027-4fc3-abe8-7634a8280082
#>  18: sinking_raccoon 2026-06-26 10:11:04 26f300b4-a5fd-43e2-88c7-e94a88ec3249
#>  19: sinking_raccoon 2026-06-26 10:11:04 1c8d1686-22b6-4825-a770-4e7af8b63da8
#>  20: sinking_raccoon 2026-06-26 10:11:04 9d8afcde-579b-4363-aaf9-bacd48d096c9
#>  21:            <NA>                <NA> ffcf0f09-a975-40ab-bc0d-0c5ddc38c3d0
#>  22:            <NA>                <NA> 7800adef-b0d1-4d49-8497-59573b04c558
#>  23:            <NA>                <NA> 74a9d0b4-fc9c-4e7a-a2b5-676e9232df5c
#>  24:            <NA>                <NA> b38bceef-4ba9-4756-bca5-71eef1883e3b
#>  25:            <NA>                <NA> b4555c51-d459-49ae-9d5a-15596996f118
#>  26:            <NA>                <NA> f298a67e-5f90-4c30-9db0-bff4ae05df6d
#>  27:            <NA>                <NA> 90610af5-6855-4ae0-ab4e-f53f827d4fa1
#>  28:            <NA>                <NA> 97a8dec8-6bf8-4b6f-800d-3fc2edb9a3dc
#>  29:            <NA>                <NA> 36d33310-3074-449d-9e11-a4c99d125408
#>  30:            <NA>                <NA> fc5bb593-defc-4799-abe8-21c5559fbaf3
#>  31:            <NA>                <NA> 563e0664-e926-4eee-84d4-8addb0df8d24
#>  32:            <NA>                <NA> de45df5b-2688-410f-8e93-efc1fe791aad
#>  33:            <NA>                <NA> 047dc289-2261-4595-87c1-39b2b09cf2fa
#>  34:            <NA>                <NA> 9df34f89-d575-4670-a72a-2bfc13e4274e
#>  35:            <NA>                <NA> 54c591a5-642e-455b-ba05-008879245a9a
#>  36:            <NA>                <NA> c60ba228-210c-4bc7-83be-03d30896a9c1
#>  37:            <NA>                <NA> 60613083-151e-462e-a21c-7a4dc9798ad2
#>  38:            <NA>                <NA> fa938b36-9b10-4b4f-a004-892452d7cbfb
#>  39:            <NA>                <NA> 43ed60b3-3dbc-492c-af92-f37d77186af5
#>  40:            <NA>                <NA> 484c3c96-0515-4d96-88c4-171224093a87
#>  41:            <NA>                <NA> 86c93360-4ada-4472-8e2a-d6a9b1d66f19
#>  42:            <NA>                <NA> c475ba56-4b11-4463-a18a-de2d393e0d5f
#>  43:            <NA>                <NA> 4a0f26ed-1f8b-45a8-983b-e5e159792f9b
#>  44:            <NA>                <NA> de3fba2d-11ff-46e5-a7bb-7ff05c11ae73
#>  45:            <NA>                <NA> 9f8a9121-4ec4-4cc0-ae99-c17965b52f1b
#>  46:            <NA>                <NA> 5754fa94-a2a0-4204-ac3e-b34c5d552e22
#>  47:            <NA>                <NA> 4f0f1142-8894-4da9-b071-c2b5e70d79ba
#>  48:            <NA>                <NA> 3ca3b9cc-2f46-4b10-9b66-8321d98e8225
#>  49:            <NA>                <NA> 9485906d-46d0-4a88-a17c-3374711ef24d
#>  50:            <NA>                <NA> f9cf5860-fc1f-4c1d-aee6-94a905e64ad7
#>  51:            <NA>                <NA> b865691e-3659-4308-a011-5b7ba8d8561a
#>  52:            <NA>                <NA> dbba7dc0-5105-4647-b8cb-afe20c452d67
#>  53:            <NA>                <NA> 55165e0c-104e-4b28-a14d-da1f940af785
#>  54:            <NA>                <NA> ad0bd86e-ceff-4dc5-b46d-603431d4bb8e
#>  55:            <NA>                <NA> f9e26d9a-1365-4b98-88a4-e508b0233282
#>  56:            <NA>                <NA> 52d96940-67ba-40dc-b8c4-15d68960f2f7
#>  57:            <NA>                <NA> a06cf9c3-9563-4bdc-a2cc-d9a8194b3006
#>  58:            <NA>                <NA> 2ac5b40d-1aa1-4f13-83ef-99e4409a1e0d
#>  59:            <NA>                <NA> 8fa55b1b-0d5f-4eda-a71d-54444ce4ec1e
#>  60:            <NA>                <NA> 5049ab43-efd3-4b86-b5db-9edbfb380000
#>  61:            <NA>                <NA> e199f0b6-7416-4d29-a8f9-cff485caa303
#>  62:            <NA>                <NA> 35905442-bab3-4595-bde8-ed0f651d21c9
#>  63:            <NA>                <NA> 2a9c9c68-f7f7-48ed-b742-264a4b6389da
#>  64:            <NA>                <NA> f5855d79-2cb7-4883-bc64-e93cebc54f5a
#>  65:            <NA>                <NA> 06b30488-d9ca-4fae-8f7c-d5f32fd28683
#>  66:            <NA>                <NA> 1a772136-2aa1-40db-ad3b-988809263c22
#>  67:            <NA>                <NA> ae49ef25-76ad-4ec6-9341-4796ee53ce69
#>  68:            <NA>                <NA> 4a3172e5-d8c2-4565-93b3-12b1fd1a4f15
#>  69:            <NA>                <NA> fb529dbc-dab1-4f0a-ad21-791d65490e68
#>  70:            <NA>                <NA> f2e2ffda-cc4b-4162-8d74-8836f6559cb6
#>  71:            <NA>                <NA> 60edbca4-c435-42d6-afc6-88166bd9146e
#>  72:            <NA>                <NA> 6b36620d-bf24-4473-a0f4-3df113de1362
#>  73:            <NA>                <NA> c3c07b46-0900-4559-8b90-a66e3574fa5c
#>  74:            <NA>                <NA> 7582fa9f-a3d4-4295-b480-39917de09b9a
#>  75:            <NA>                <NA> 26b26191-490c-4e08-8b11-74511f925632
#>  76:            <NA>                <NA> cda9a20e-0b58-43dd-87aa-4bf758396deb
#>  77:            <NA>                <NA> d9b394e8-1e99-4e38-8045-0ac0e348e605
#>  78:            <NA>                <NA> 95a079ca-7d70-4d4d-9742-064604f8566f
#>  79:            <NA>                <NA> d51f405c-6623-4912-9d90-a90f975dfe5e
#>  80:            <NA>                <NA> 55962377-6e33-4c5e-9b56-4aba8a62ce9d
#>  81:            <NA>                <NA> b0878afb-aa5d-4fa8-a038-02c39c68be46
#>  82:            <NA>                <NA> 85e3d3d6-145c-4ccb-8a56-80d6934d45df
#>  83:            <NA>                <NA> b611a35d-7023-48e5-9a3a-765a2a7ad594
#>  84:            <NA>                <NA> a23e7919-4459-409f-80b7-c14b17a77550
#>  85:            <NA>                <NA> 456e18ff-1645-4097-a6d7-8250ba2dfe6c
#>  86:            <NA>                <NA> 994c859e-b7ac-4f12-9baf-1d9b14ef19f4
#>  87:            <NA>                <NA> f04e6f6e-3435-4811-981c-e8da7a2f3653
#>  88:            <NA>                <NA> 715a3d00-f006-4016-8452-09412dd68be1
#>  89:            <NA>                <NA> afa284c9-171c-409e-99bd-4f58c71b7b5c
#>  90:            <NA>                <NA> 3e33a7da-b94a-49c2-ba45-fab471b89129
#>  91:            <NA>                <NA> 5d7e9977-395f-4090-b09b-1f3ead840e07
#>  92:            <NA>                <NA> 21253863-4801-4b21-8cc1-aedead546cc7
#>  93:            <NA>                <NA> 505ee1f6-c2ca-4959-a14a-5b1ea8d2a4a8
#>  94:            <NA>                <NA> 0b09ed28-4303-4ab8-9d7c-fd6ac8e48cc8
#>  95:            <NA>                <NA> 90429458-403b-44a0-8bd3-0cfa5ae1feae
#>  96:            <NA>                <NA> 7059fa17-ea34-428a-ba2c-9b639208fbec
#>  97:            <NA>                <NA> 32a8aa00-af85-4015-bcbd-9b0e816f9f0c
#>  98:            <NA>                <NA> e7d051de-e9b5-4774-ba02-923eb6f5873c
#>  99:            <NA>                <NA> 64539a24-814a-47bb-bc08-34e61ad634f6
#> 100:            <NA>                <NA> 93be9804-0772-4c94-af61-85d1c4d2808d
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
