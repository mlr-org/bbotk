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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-19 10:30:31
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-19 10:30:31
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-19 10:30:31
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-19 10:30:31
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-19 10:30:31
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-19 10:30:31
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-19 10:30:31
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-19 10:30:31
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-19 10:30:31
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-19 10:30:31
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-19 10:30:31
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-19 10:30:31
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-19 10:30:31
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-19 10:30:31
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-19 10:30:31
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-19 10:30:31
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-19 10:30:31
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-19 10:30:31
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-19 10:30:31
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-19 10:30:31
#>  21:   failed  10.000000  5.0000000         NA 2026-03-19 10:30:31
#>  22:   failed  10.000000  3.8888889         NA 2026-03-19 10:30:31
#>  23:   failed  10.000000  2.7777778         NA 2026-03-19 10:30:31
#>  24:   failed  10.000000  1.6666667         NA 2026-03-19 10:30:31
#>  25:   failed  10.000000  0.5555556         NA 2026-03-19 10:30:31
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-19 10:30:31
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-19 10:30:31
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-19 10:30:31
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-19 10:30:31
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-19 10:30:31
#>  31:   failed   7.777778  5.0000000         NA 2026-03-19 10:30:31
#>  32:   failed   7.777778  3.8888889         NA 2026-03-19 10:30:31
#>  33:   failed   7.777778  2.7777778         NA 2026-03-19 10:30:31
#>  34:   failed   7.777778  1.6666667         NA 2026-03-19 10:30:31
#>  35:   failed   7.777778  0.5555556         NA 2026-03-19 10:30:31
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-19 10:30:31
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-19 10:30:31
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-19 10:30:31
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-19 10:30:31
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-19 10:30:31
#>  41:   failed   5.555556  5.0000000         NA 2026-03-19 10:30:31
#>  42:   failed   5.555556  3.8888889         NA 2026-03-19 10:30:31
#>  43:   failed   5.555556  2.7777778         NA 2026-03-19 10:30:31
#>  44:   failed   5.555556  1.6666667         NA 2026-03-19 10:30:31
#>  45:   failed   5.555556  0.5555556         NA 2026-03-19 10:30:31
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-19 10:30:31
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-19 10:30:31
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-19 10:30:31
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-19 10:30:31
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-19 10:30:31
#>  51:   failed   3.333333  5.0000000         NA 2026-03-19 10:30:31
#>  52:   failed   3.333333  3.8888889         NA 2026-03-19 10:30:31
#>  53:   failed   3.333333  2.7777778         NA 2026-03-19 10:30:31
#>  54:   failed   3.333333  1.6666667         NA 2026-03-19 10:30:31
#>  55:   failed   3.333333  0.5555556         NA 2026-03-19 10:30:31
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-19 10:30:31
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-19 10:30:31
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-19 10:30:31
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-19 10:30:31
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-19 10:30:31
#>  61:   failed   1.111111  5.0000000         NA 2026-03-19 10:30:31
#>  62:   failed   1.111111  3.8888889         NA 2026-03-19 10:30:31
#>  63:   failed   1.111111  2.7777778         NA 2026-03-19 10:30:31
#>  64:   failed   1.111111  1.6666667         NA 2026-03-19 10:30:31
#>  65:   failed   1.111111  0.5555556         NA 2026-03-19 10:30:31
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-19 10:30:31
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-19 10:30:31
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-19 10:30:31
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-19 10:30:31
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-19 10:30:31
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-19 10:30:31
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-19 10:30:31
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-19 10:30:31
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-19 10:30:31
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-19 10:30:31
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-19 10:30:31
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-19 10:30:31
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-19 10:30:31
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-19 10:30:31
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-19 10:30:31
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-19 10:30:31
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-19 10:30:31
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-19 10:30:31
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-19 10:30:31
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-19 10:30:31
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-19 10:30:31
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-19 10:30:31
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-19 10:30:31
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-19 10:30:31
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-19 10:30:31
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-19 10:30:31
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-19 10:30:31
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-19 10:30:31
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-19 10:30:31
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-19 10:30:31
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-19 10:30:31
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-19 10:30:31
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-19 10:30:31
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-19 10:30:31
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-19 10:30:31
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-03-19 10:30:31 0b15008d-9305-45db-84c9-367f1da7256e
#>   2: sinking_raccoon 2026-03-19 10:30:31 6aeebd01-96f1-4774-9466-38b3582be2bc
#>   3: sinking_raccoon 2026-03-19 10:30:31 542ae197-e833-4c23-ab50-2d48d584606e
#>   4: sinking_raccoon 2026-03-19 10:30:31 33408f2e-dd35-41b9-b643-5c88e67042df
#>   5: sinking_raccoon 2026-03-19 10:30:32 30f62a64-fb45-416e-bf80-309079cd1e87
#>   6: sinking_raccoon 2026-03-19 10:30:32 f3af6e80-353f-4e16-a985-c01f599bf947
#>   7: sinking_raccoon 2026-03-19 10:30:32 b5599f7c-8c24-4f31-8ca5-cd1727d41d18
#>   8: sinking_raccoon 2026-03-19 10:30:32 d2603bf0-945f-4c30-b4a8-77aabe2b0b66
#>   9: sinking_raccoon 2026-03-19 10:30:32 e35cbb4c-fc62-4013-9088-7c1ee01c0994
#>  10: sinking_raccoon 2026-03-19 10:30:32 6f9e8d22-b74f-4704-bc53-62a96818c7c0
#>  11: sinking_raccoon 2026-03-19 10:30:32 5c67bc4a-c88e-492a-b2ad-926201d99cc3
#>  12: sinking_raccoon 2026-03-19 10:30:32 41d52a75-f82c-4e06-bec5-2ee43d6ac0ed
#>  13: sinking_raccoon 2026-03-19 10:30:32 3b3c8a2b-7b03-46e8-805b-36e0f05de8dd
#>  14: sinking_raccoon 2026-03-19 10:30:32 b487ecc2-c4c6-4d3f-80a4-0a9cf98df6bb
#>  15: sinking_raccoon 2026-03-19 10:30:32 7f05a872-52bf-457b-8f0d-e7c2ee8dcea1
#>  16: sinking_raccoon 2026-03-19 10:30:32 a59e9613-2e4a-43ca-b4a4-64b97f009a0c
#>  17: sinking_raccoon 2026-03-19 10:30:32 bbbc44f4-4ac2-438c-9fbb-c77b4596e159
#>  18: sinking_raccoon 2026-03-19 10:30:32 bc0bab6b-511b-4474-9069-0649814b5cd4
#>  19: sinking_raccoon 2026-03-19 10:30:32 1d7bf2af-3632-4219-9d31-656919e11156
#>  20: sinking_raccoon 2026-03-19 10:30:32 aed1aed3-9686-48da-889c-4bf75d5c169b
#>  21:            <NA>                <NA> 30df5d8d-545a-462d-84ab-f4a081f034a9
#>  22:            <NA>                <NA> 592106c0-5c66-42b7-9b8b-f4548be0d0fc
#>  23:            <NA>                <NA> e14f24da-76d1-4481-b04a-e1389484df0a
#>  24:            <NA>                <NA> 037fdc4e-d6cf-42c7-9f61-f9fa9d606927
#>  25:            <NA>                <NA> 03dab66c-bf7e-4fe3-a0f2-515d02facc62
#>  26:            <NA>                <NA> 534533b7-c65c-4af2-8ab5-8707673aab40
#>  27:            <NA>                <NA> 5ceab105-2c8b-4a15-9055-9bad26eebb7b
#>  28:            <NA>                <NA> 50b4a368-3392-4f4d-95a1-efa5f8112238
#>  29:            <NA>                <NA> d1d48030-3986-4fc3-a092-5a6d4b29dd3a
#>  30:            <NA>                <NA> 3cc98be2-18db-4522-8d0a-41c90aaac5c9
#>  31:            <NA>                <NA> b0f43e82-f53c-4c0c-a9b0-fd40f50be2f2
#>  32:            <NA>                <NA> 5f0a9249-5fde-4130-97ea-c4375015d0a7
#>  33:            <NA>                <NA> f0856641-e56d-44ec-80ce-c91f7c28e046
#>  34:            <NA>                <NA> 3c469b2e-1eb4-43b8-9b45-56d7c71321c2
#>  35:            <NA>                <NA> 281b70eb-5e36-4606-a405-7047c1036d9a
#>  36:            <NA>                <NA> de8d86d6-26f1-4418-957f-ad95ec4b4b68
#>  37:            <NA>                <NA> 5865ab1b-2c8a-4c87-a58e-1cec2a9b76fd
#>  38:            <NA>                <NA> 70773230-29c8-44d6-a621-434c26bf55d1
#>  39:            <NA>                <NA> 5f13140c-f11c-4b53-8f9a-ce2dba4ee390
#>  40:            <NA>                <NA> 55c40663-1c23-4e85-a764-e9188a0f06f2
#>  41:            <NA>                <NA> 7f999357-de64-43cc-8d81-c7ae0f73d300
#>  42:            <NA>                <NA> 763199ab-f32e-4133-a3ca-5f20a4ed48ac
#>  43:            <NA>                <NA> 1dca0273-0474-420e-a8ed-97dba865249e
#>  44:            <NA>                <NA> d92b2d44-f4f1-4366-92e1-685e577497eb
#>  45:            <NA>                <NA> 0a1e6f5d-997c-442a-849e-9bf0270b468f
#>  46:            <NA>                <NA> 65ab5d75-ddcd-4ab0-8c28-cbe666cc003e
#>  47:            <NA>                <NA> 1ba4dfaf-ae66-4862-a358-d12ef626d30d
#>  48:            <NA>                <NA> 970dbc91-a33a-4f9a-8ca5-1f23c62e71a5
#>  49:            <NA>                <NA> 4878c700-0aef-4abf-bf7b-d79d174a32d1
#>  50:            <NA>                <NA> 576b825f-2596-4f3b-ba52-0dd5c5bfea05
#>  51:            <NA>                <NA> 05846ef6-9d82-47eb-93b2-5f13339c2e49
#>  52:            <NA>                <NA> dfcc9691-0160-4736-84b7-ede481b93ed2
#>  53:            <NA>                <NA> b0480e5d-e7e0-4728-bb4c-09c022155179
#>  54:            <NA>                <NA> b63ac064-28ec-47a0-b25d-381c37dc202c
#>  55:            <NA>                <NA> 6d4ed638-b2f5-49e7-9fac-3f3d70ff8ac1
#>  56:            <NA>                <NA> ec4a9315-83fb-4f71-9c8e-4372240e3b8c
#>  57:            <NA>                <NA> d2eb4ae0-fdd4-4803-afe3-6ef9a6b97921
#>  58:            <NA>                <NA> 4f7b226e-7e2f-404b-bb01-57535f4b20a7
#>  59:            <NA>                <NA> 34204266-5bdd-4b32-a6ee-30404cfb2ceb
#>  60:            <NA>                <NA> d55b6b49-2c8e-4671-aadf-e57013edef38
#>  61:            <NA>                <NA> 344ffb11-3b7b-413e-8ca6-0ff1b94ddd34
#>  62:            <NA>                <NA> 15fc84d3-0594-49be-9777-5523f4c92290
#>  63:            <NA>                <NA> 7b1e0800-ad66-439b-9686-9afcb08a9535
#>  64:            <NA>                <NA> 25645bbc-bf14-4758-9892-03686c0cf37f
#>  65:            <NA>                <NA> 91a503d4-8bd8-407a-9c60-b62cc2e1fe64
#>  66:            <NA>                <NA> 55031c16-73e6-4137-84d3-b4ea872c5017
#>  67:            <NA>                <NA> df0062b1-c4a9-41b1-b5a3-2061328dda8e
#>  68:            <NA>                <NA> 0b209b96-d019-4f0b-af91-b42a4086ff22
#>  69:            <NA>                <NA> 60c4919b-324b-4f5f-8191-4bb91e4ef395
#>  70:            <NA>                <NA> 4fc56b11-e6e6-4f17-89be-d8fb55b36587
#>  71:            <NA>                <NA> 239aea15-9fd7-4435-a4f0-48f09cca4e8a
#>  72:            <NA>                <NA> 92fafb39-85d8-4290-b2ec-7f88bbf69374
#>  73:            <NA>                <NA> 3dbb1ccc-89af-4063-8856-c81fd21b5f74
#>  74:            <NA>                <NA> d9928a83-eca3-40db-90e8-a68c3edd26e7
#>  75:            <NA>                <NA> 86acc029-557d-40cf-8ed2-09ef91657b4b
#>  76:            <NA>                <NA> 9c4799eb-2780-4158-bb4d-979ec2a18479
#>  77:            <NA>                <NA> e4c6bdfd-479f-4c6c-b27f-52784bc4611b
#>  78:            <NA>                <NA> 756b863f-e854-4c38-8fea-3b8c42da6c57
#>  79:            <NA>                <NA> e9e34ac8-6453-4bf3-b90a-1c431494c61c
#>  80:            <NA>                <NA> 396de8f5-e612-4096-ad66-f544576afd52
#>  81:            <NA>                <NA> b51c513d-19b4-4ac8-a211-d58c27fbfd2d
#>  82:            <NA>                <NA> d930ad46-1276-4a64-b80e-a505ffbf8f1f
#>  83:            <NA>                <NA> d4c24861-57ef-4ed7-b556-fcce2957f0e8
#>  84:            <NA>                <NA> 4d103293-91f7-4b37-b395-dd6dd7b88114
#>  85:            <NA>                <NA> c54c6ee5-d608-4ec0-94d6-56fedecb1a57
#>  86:            <NA>                <NA> c97d2053-a219-4d07-b733-d92fe773dbba
#>  87:            <NA>                <NA> 2cc3aa39-e8b1-414a-a355-3b75846f4fd2
#>  88:            <NA>                <NA> 6e3c3543-d86a-45e4-b83f-03d792cce897
#>  89:            <NA>                <NA> 13d35b65-399d-4c4c-aedd-dd1995fa77e2
#>  90:            <NA>                <NA> dd774abf-6f30-4fc5-b8b9-1dc3a2fde492
#>  91:            <NA>                <NA> 4340a84b-adf8-4ae1-997a-61e15d6c7e76
#>  92:            <NA>                <NA> 4c9d61c5-3701-40c7-a6d1-b07fdb0c53a8
#>  93:            <NA>                <NA> eef70c8e-2370-4bc4-9869-fe5ffba8df48
#>  94:            <NA>                <NA> 54811b71-e9dc-4812-8fd2-4bf228791c6c
#>  95:            <NA>                <NA> f1623366-98ff-488d-9fec-a2103384b81d
#>  96:            <NA>                <NA> 0d7a1d68-63b5-4de4-bbe0-ea0ecfa7e0e7
#>  97:            <NA>                <NA> 67617349-5004-45bf-9c83-ff6a2a9cfca3
#>  98:            <NA>                <NA> f807f17b-249b-4bbf-b577-f1fda96f3a31
#>  99:            <NA>                <NA> ee623159-499c-4c91-b4ff-e72878554e2b
#> 100:            <NA>                <NA> 0d3b5036-6b63-4087-a9f4-3d0b664b1152
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
