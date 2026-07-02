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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-07-02 09:45:02
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-07-02 09:45:02
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-07-02 09:45:02
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-07-02 09:45:02
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-07-02 09:45:02
#>   6: finished -10.000000  0.5555556 -146.64198 2026-07-02 09:45:02
#>   7: finished -10.000000  1.6666667 -155.77778 2026-07-02 09:45:02
#>   8: finished -10.000000  2.7777778 -167.38272 2026-07-02 09:45:02
#>   9: finished -10.000000  3.8888889 -181.45679 2026-07-02 09:45:02
#>  10: finished -10.000000  5.0000000 -198.00000 2026-07-02 09:45:02
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-07-02 09:45:02
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-07-02 09:45:02
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-07-02 09:45:02
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-07-02 09:45:02
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-07-02 09:45:02
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-07-02 09:45:02
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-07-02 09:45:02
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-07-02 09:45:02
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-07-02 09:45:02
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-07-02 09:45:02
#>  21:   failed  10.000000  5.0000000         NA 2026-07-02 09:45:02
#>  22:   failed  10.000000  3.8888889         NA 2026-07-02 09:45:02
#>  23:   failed  10.000000  2.7777778         NA 2026-07-02 09:45:02
#>  24:   failed  10.000000  1.6666667         NA 2026-07-02 09:45:02
#>  25:   failed  10.000000  0.5555556         NA 2026-07-02 09:45:02
#>  26:   failed  10.000000 -0.5555556         NA 2026-07-02 09:45:02
#>  27:   failed  10.000000 -1.6666667         NA 2026-07-02 09:45:02
#>  28:   failed  10.000000 -2.7777778         NA 2026-07-02 09:45:02
#>  29:   failed  10.000000 -3.8888889         NA 2026-07-02 09:45:02
#>  30:   failed  10.000000 -5.0000000         NA 2026-07-02 09:45:02
#>  31:   failed   7.777778  5.0000000         NA 2026-07-02 09:45:02
#>  32:   failed   7.777778  3.8888889         NA 2026-07-02 09:45:02
#>  33:   failed   7.777778  2.7777778         NA 2026-07-02 09:45:02
#>  34:   failed   7.777778  1.6666667         NA 2026-07-02 09:45:02
#>  35:   failed   7.777778  0.5555556         NA 2026-07-02 09:45:02
#>  36:   failed   7.777778 -0.5555556         NA 2026-07-02 09:45:02
#>  37:   failed   7.777778 -1.6666667         NA 2026-07-02 09:45:02
#>  38:   failed   7.777778 -2.7777778         NA 2026-07-02 09:45:02
#>  39:   failed   7.777778 -3.8888889         NA 2026-07-02 09:45:02
#>  40:   failed   7.777778 -5.0000000         NA 2026-07-02 09:45:02
#>  41:   failed   5.555556  5.0000000         NA 2026-07-02 09:45:02
#>  42:   failed   5.555556  3.8888889         NA 2026-07-02 09:45:02
#>  43:   failed   5.555556  2.7777778         NA 2026-07-02 09:45:02
#>  44:   failed   5.555556  1.6666667         NA 2026-07-02 09:45:02
#>  45:   failed   5.555556  0.5555556         NA 2026-07-02 09:45:02
#>  46:   failed   5.555556 -0.5555556         NA 2026-07-02 09:45:02
#>  47:   failed   5.555556 -1.6666667         NA 2026-07-02 09:45:02
#>  48:   failed   5.555556 -2.7777778         NA 2026-07-02 09:45:02
#>  49:   failed   5.555556 -3.8888889         NA 2026-07-02 09:45:02
#>  50:   failed   5.555556 -5.0000000         NA 2026-07-02 09:45:02
#>  51:   failed   3.333333  5.0000000         NA 2026-07-02 09:45:02
#>  52:   failed   3.333333  3.8888889         NA 2026-07-02 09:45:02
#>  53:   failed   3.333333  2.7777778         NA 2026-07-02 09:45:02
#>  54:   failed   3.333333  1.6666667         NA 2026-07-02 09:45:02
#>  55:   failed   3.333333  0.5555556         NA 2026-07-02 09:45:02
#>  56:   failed   3.333333 -0.5555556         NA 2026-07-02 09:45:02
#>  57:   failed   3.333333 -1.6666667         NA 2026-07-02 09:45:02
#>  58:   failed   3.333333 -2.7777778         NA 2026-07-02 09:45:02
#>  59:   failed   3.333333 -3.8888889         NA 2026-07-02 09:45:02
#>  60:   failed   3.333333 -5.0000000         NA 2026-07-02 09:45:02
#>  61:   failed   1.111111  5.0000000         NA 2026-07-02 09:45:02
#>  62:   failed   1.111111  3.8888889         NA 2026-07-02 09:45:02
#>  63:   failed   1.111111  2.7777778         NA 2026-07-02 09:45:02
#>  64:   failed   1.111111  1.6666667         NA 2026-07-02 09:45:02
#>  65:   failed   1.111111  0.5555556         NA 2026-07-02 09:45:02
#>  66:   failed   1.111111 -0.5555556         NA 2026-07-02 09:45:02
#>  67:   failed   1.111111 -1.6666667         NA 2026-07-02 09:45:02
#>  68:   failed   1.111111 -2.7777778         NA 2026-07-02 09:45:02
#>  69:   failed   1.111111 -3.8888889         NA 2026-07-02 09:45:02
#>  70:   failed   1.111111 -5.0000000         NA 2026-07-02 09:45:02
#>  71:   failed  -1.111111  5.0000000         NA 2026-07-02 09:45:02
#>  72:   failed  -1.111111  3.8888889         NA 2026-07-02 09:45:02
#>  73:   failed  -1.111111  2.7777778         NA 2026-07-02 09:45:02
#>  74:   failed  -1.111111  1.6666667         NA 2026-07-02 09:45:02
#>  75:   failed  -1.111111  0.5555556         NA 2026-07-02 09:45:02
#>  76:   failed  -1.111111 -0.5555556         NA 2026-07-02 09:45:02
#>  77:   failed  -1.111111 -1.6666667         NA 2026-07-02 09:45:02
#>  78:   failed  -1.111111 -2.7777778         NA 2026-07-02 09:45:02
#>  79:   failed  -1.111111 -3.8888889         NA 2026-07-02 09:45:02
#>  80:   failed  -1.111111 -5.0000000         NA 2026-07-02 09:45:02
#>  81:   failed  -3.333333  5.0000000         NA 2026-07-02 09:45:02
#>  82:   failed  -3.333333  3.8888889         NA 2026-07-02 09:45:02
#>  83:   failed  -3.333333  2.7777778         NA 2026-07-02 09:45:02
#>  84:   failed  -3.333333  1.6666667         NA 2026-07-02 09:45:02
#>  85:   failed  -3.333333  0.5555556         NA 2026-07-02 09:45:02
#>  86:   failed  -3.333333 -0.5555556         NA 2026-07-02 09:45:02
#>  87:   failed  -3.333333 -1.6666667         NA 2026-07-02 09:45:02
#>  88:   failed  -3.333333 -2.7777778         NA 2026-07-02 09:45:02
#>  89:   failed  -3.333333 -3.8888889         NA 2026-07-02 09:45:02
#>  90:   failed  -3.333333 -5.0000000         NA 2026-07-02 09:45:02
#>  91:   failed  -5.555556  5.0000000         NA 2026-07-02 09:45:02
#>  92:   failed  -5.555556  3.8888889         NA 2026-07-02 09:45:02
#>  93:   failed  -5.555556  2.7777778         NA 2026-07-02 09:45:02
#>  94:   failed  -5.555556  1.6666667         NA 2026-07-02 09:45:02
#>  95:   failed  -5.555556  0.5555556         NA 2026-07-02 09:45:02
#>  96:   failed  -5.555556 -0.5555556         NA 2026-07-02 09:45:02
#>  97:   failed  -5.555556 -1.6666667         NA 2026-07-02 09:45:02
#>  98:   failed  -5.555556 -2.7777778         NA 2026-07-02 09:45:02
#>  99:   failed  -5.555556 -3.8888889         NA 2026-07-02 09:45:02
#> 100:   failed  -5.555556 -5.0000000         NA 2026-07-02 09:45:02
#>         state         x1         x2          y        timestamp_xs
#>        <char>      <num>      <num>      <num>              <POSc>
#>            worker_id        timestamp_ys                                 keys
#>               <char>              <POSc>                               <char>
#>   1: sinking_raccoon 2026-07-02 09:45:03 5e767541-e05d-477d-9168-107f90d6a848
#>   2: sinking_raccoon 2026-07-02 09:45:03 fc3551f4-771e-432e-85ad-286e3320a24b
#>   3: sinking_raccoon 2026-07-02 09:45:03 8290db9e-3540-4b14-ac8b-28dcefc84b39
#>   4: sinking_raccoon 2026-07-02 09:45:03 f09eb945-dcdb-4b95-97d3-c65b0f73e1be
#>   5: sinking_raccoon 2026-07-02 09:45:03 7b84a08d-1ffd-495a-986b-86a2dd12ef81
#>   6: sinking_raccoon 2026-07-02 09:45:03 30551584-5ca5-4a1c-8a72-579a1e06259d
#>   7: sinking_raccoon 2026-07-02 09:45:03 ad2d6bef-f821-48d8-b1d7-bdcf6d2f1945
#>   8: sinking_raccoon 2026-07-02 09:45:03 246ec9c8-372c-4088-97dc-046bb8382127
#>   9: sinking_raccoon 2026-07-02 09:45:03 60848e9d-0b83-4cb4-997b-07994eb1b6d6
#>  10: sinking_raccoon 2026-07-02 09:45:03 122a38aa-9ce3-499b-9c74-5f1a6594850c
#>  11: sinking_raccoon 2026-07-02 09:45:03 9a02418e-bb75-4a7c-af20-120ca46bffc9
#>  12: sinking_raccoon 2026-07-02 09:45:03 6b4b8cd6-96ec-4cda-bb1f-56fa98d2739e
#>  13: sinking_raccoon 2026-07-02 09:45:03 143a3bfc-a877-4f7a-81ee-4c4064dd3101
#>  14: sinking_raccoon 2026-07-02 09:45:03 b68e8d30-ef11-49ed-a443-3cc363ead70e
#>  15: sinking_raccoon 2026-07-02 09:45:03 632b4343-9f6a-46c3-bb56-e88d92b1e333
#>  16: sinking_raccoon 2026-07-02 09:45:03 b9b188e6-6717-43c4-823e-61c407c1f649
#>  17: sinking_raccoon 2026-07-02 09:45:03 c123b017-1c8f-4b3b-bc50-a94edfe8ce16
#>  18: sinking_raccoon 2026-07-02 09:45:03 a3d4d715-360a-4b85-af95-24c199e25c16
#>  19: sinking_raccoon 2026-07-02 09:45:03 998b20da-472a-43fd-b948-667a2c5777ab
#>  20: sinking_raccoon 2026-07-02 09:45:03 8f9282e8-bf07-484e-8520-53c731caa6a2
#>  21:            <NA>                <NA> 022644aa-3e8a-4c11-ac97-fff287b98004
#>  22:            <NA>                <NA> 8c507d07-7c9f-4370-8f64-4865806c46e1
#>  23:            <NA>                <NA> 48b1c950-a0b0-4a8b-9264-7d83c58d0548
#>  24:            <NA>                <NA> 51ad2797-8791-4fb8-bc91-40aac9ddc9bf
#>  25:            <NA>                <NA> e40cb41a-9d93-460c-be77-ef03db53ff4f
#>  26:            <NA>                <NA> 2d86278e-3f15-487a-978f-3ef4ed7b48f3
#>  27:            <NA>                <NA> 3ac9e284-8541-4b1a-8b5a-28f53d82e69d
#>  28:            <NA>                <NA> ffb0c7fd-4a72-4d27-98eb-7d0447d4ece2
#>  29:            <NA>                <NA> a7a02d21-8391-404d-a18e-085e8911a302
#>  30:            <NA>                <NA> 25c51d42-7898-41c1-be33-b5678efb1b62
#>  31:            <NA>                <NA> 00aa2bfb-1d07-453b-ac10-cc73a10aa56b
#>  32:            <NA>                <NA> d502ad7b-d950-4dec-955e-ed7156071ceb
#>  33:            <NA>                <NA> 3833424a-5500-4e53-8384-45be7d514871
#>  34:            <NA>                <NA> 5943eeb5-a80d-4e1b-a596-f3bb6ac6f673
#>  35:            <NA>                <NA> ed23e945-4b24-4f81-81db-f4de7a21be8b
#>  36:            <NA>                <NA> e3c6f7b4-2eae-485a-9021-9ad97cfd512f
#>  37:            <NA>                <NA> 330fc997-744e-4414-8ddb-ab3695018c10
#>  38:            <NA>                <NA> 00d1fe09-c676-4a28-b786-6fe5859b5204
#>  39:            <NA>                <NA> c7495506-8946-4fde-b0cc-e92144316315
#>  40:            <NA>                <NA> fbf8f5b1-fbbb-47e1-bc8b-1d4a98aa6f2b
#>  41:            <NA>                <NA> 9eb119cb-4134-439b-b566-58f41eef4e81
#>  42:            <NA>                <NA> c1f0d938-69bf-48f4-980c-6edc88662a67
#>  43:            <NA>                <NA> ebed237b-0966-48fb-9b27-2f778cb3b817
#>  44:            <NA>                <NA> deb97dd7-1225-4c99-b1f2-90aada03bf69
#>  45:            <NA>                <NA> e85fa712-f9af-4d1e-bf2e-0d0ed9d36169
#>  46:            <NA>                <NA> 68fad651-898a-4410-a1ae-4bf7384d0d7d
#>  47:            <NA>                <NA> 83d62b2b-34d6-4a47-9b1a-f00337f59550
#>  48:            <NA>                <NA> b1cf5180-768e-466c-9062-d61c6147f949
#>  49:            <NA>                <NA> a7b2b961-1b17-4b80-8225-09d1f79dcf7a
#>  50:            <NA>                <NA> 21b75ab8-9ffe-49f6-a0d1-c4b453d03dfd
#>  51:            <NA>                <NA> c7471ccd-71a6-4506-9613-4dc58b64b6bc
#>  52:            <NA>                <NA> 8b21003f-9e1c-432f-a288-c970b2861531
#>  53:            <NA>                <NA> 4db5dc78-508e-48d5-bc47-51ef0715658d
#>  54:            <NA>                <NA> 92d1fa04-cdc7-4a2b-a0ea-fba1c83a2861
#>  55:            <NA>                <NA> 8b17f34d-2969-4c73-993c-bcc594ebf121
#>  56:            <NA>                <NA> ce35b262-97b4-4521-800b-48dee0cf92c8
#>  57:            <NA>                <NA> 2b45a9bf-f9cd-4f80-ba0f-ade75dbf960d
#>  58:            <NA>                <NA> 5335ef34-66af-4ab3-8ec5-3d60886b6c5c
#>  59:            <NA>                <NA> e8c78b9b-d95a-419d-bff9-3bee5412d7ac
#>  60:            <NA>                <NA> bed06a0f-ba5b-43c3-9362-3a65b8a5c480
#>  61:            <NA>                <NA> 69e05dc4-5882-4890-b2db-39d193f2ff09
#>  62:            <NA>                <NA> 6ca29160-9568-4289-81a8-4f9c0dbe08ef
#>  63:            <NA>                <NA> 96b3bb32-e8bb-453b-b83d-9afafc8291d7
#>  64:            <NA>                <NA> 21f870da-aeb8-426e-a4c4-b72ef0f6c423
#>  65:            <NA>                <NA> 45f81a56-81a5-41cb-919d-8a87dbc7d28d
#>  66:            <NA>                <NA> 58fc6e50-c8ad-42a8-ac70-eff8b931dcd5
#>  67:            <NA>                <NA> 12ccdbd3-8c4e-4a5c-a7f0-690d0ba0b1e3
#>  68:            <NA>                <NA> bbfae238-cb6a-409c-a9a9-69975f64e836
#>  69:            <NA>                <NA> ef0df9fa-b935-4ec5-8c4d-52e899120c59
#>  70:            <NA>                <NA> 829cc25e-5a94-4002-abcb-72bffad52e6a
#>  71:            <NA>                <NA> 296cdeac-3dac-4e3f-84f8-e628dd0d46be
#>  72:            <NA>                <NA> decfeab0-bc2f-4c0b-9904-bb1178aa42a0
#>  73:            <NA>                <NA> 86df2d38-6f6f-4ebb-9a0a-db584988efb2
#>  74:            <NA>                <NA> 963a1f73-057b-4fab-ba4c-6b01094386bc
#>  75:            <NA>                <NA> 5720d13f-8333-49d5-9e65-b0e38d4014c1
#>  76:            <NA>                <NA> df76664b-50d6-48c0-89bb-97a2bdc50f52
#>  77:            <NA>                <NA> 2f623395-fdb5-485b-ae3d-b6e8402427a2
#>  78:            <NA>                <NA> 590d902c-e613-4340-b537-0838233fcdda
#>  79:            <NA>                <NA> c40e8a62-d103-42c3-886f-eb9010c90b54
#>  80:            <NA>                <NA> 784cfeae-f720-4b2a-b63c-4d4f694e3020
#>  81:            <NA>                <NA> 0dae932c-d5f5-48c1-b8d7-bdae6d371aa8
#>  82:            <NA>                <NA> 635b3147-c57e-4d1e-98a6-7257d4b39912
#>  83:            <NA>                <NA> dc1844d4-f4ba-4dd6-bf9c-e95a930e2cc1
#>  84:            <NA>                <NA> c801aafe-566b-4396-ae67-60ef5290b631
#>  85:            <NA>                <NA> 9cf06402-b2f1-435e-b8ad-6760f856f54e
#>  86:            <NA>                <NA> a950b990-39f7-4eaf-9770-38f58ff3b736
#>  87:            <NA>                <NA> 55860ef1-4468-44f7-8ead-8237fadb3018
#>  88:            <NA>                <NA> 6095b203-ab80-41bc-8f9e-f7eb874bcfa8
#>  89:            <NA>                <NA> a445d5ae-9718-491d-8e76-84db223a4de3
#>  90:            <NA>                <NA> d09a0256-3230-43f7-8158-f86e6f44dda6
#>  91:            <NA>                <NA> b5d8bdbc-01a4-4574-9ea0-5506939025ea
#>  92:            <NA>                <NA> a3a5703b-c5e4-4cd6-98b8-5f74676add4e
#>  93:            <NA>                <NA> d5c889be-2d5a-4ad2-a1ed-a9d21bfa1b9c
#>  94:            <NA>                <NA> 39374b73-83d9-4f51-a26c-90498ccc6bd7
#>  95:            <NA>                <NA> 652d1d74-cde9-4ebd-bd73-ccb4be2e9004
#>  96:            <NA>                <NA> 630b2ae1-4f21-47a8-b712-61745365cd1c
#>  97:            <NA>                <NA> d380e1cc-322a-4150-a125-cc9715ce34dc
#>  98:            <NA>                <NA> debfe840-c94b-4382-a9af-942b8eb45e77
#>  99:            <NA>                <NA> ed58adf6-075e-4e5d-8f50-10d029389a6d
#> 100:            <NA>                <NA> f202e4b2-9dfb-4083-a2f4-93c949d0a16a
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
