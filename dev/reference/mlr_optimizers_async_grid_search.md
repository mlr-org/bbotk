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
#>   1: finished -10.000000 -5.0000000 -138.00000 2026-03-05 07:59:09  9399
#>   2: finished -10.000000 -3.8888889 -134.79012 2026-03-05 07:59:09  9399
#>   3: finished -10.000000 -2.7777778 -134.04938 2026-03-05 07:59:09  9399
#>   4: finished -10.000000 -1.6666667 -135.77778 2026-03-05 07:59:09  9399
#>   5: finished -10.000000 -0.5555556 -139.97531 2026-03-05 07:59:09  9399
#>   6: finished -10.000000  0.5555556 -146.64198 2026-03-05 07:59:09  9399
#>   7: finished -10.000000  1.6666667 -155.77778 2026-03-05 07:59:09  9399
#>   8: finished -10.000000  2.7777778 -167.38272 2026-03-05 07:59:09  9399
#>   9: finished -10.000000  3.8888889 -181.45679 2026-03-05 07:59:09  9399
#>  10: finished -10.000000  5.0000000 -198.00000 2026-03-05 07:59:09  9399
#>  11: finished  -7.777778 -5.0000000  -89.60494 2026-03-05 07:59:09  9399
#>  12: finished  -7.777778 -3.8888889  -86.39506 2026-03-05 07:59:09  9399
#>  13: finished  -7.777778 -2.7777778  -85.65432 2026-03-05 07:59:09  9399
#>  14: finished  -7.777778 -1.6666667  -87.38272 2026-03-05 07:59:09  9399
#>  15: finished  -7.777778 -0.5555556  -91.58025 2026-03-05 07:59:09  9399
#>  16: finished  -7.777778  0.5555556  -98.24691 2026-03-05 07:59:09  9399
#>  17: finished  -7.777778  1.6666667 -107.38272 2026-03-05 07:59:09  9399
#>  18: finished  -7.777778  2.7777778 -118.98765 2026-03-05 07:59:09  9399
#>  19: finished  -7.777778  3.8888889 -133.06173 2026-03-05 07:59:09  9399
#>  20: finished  -7.777778  5.0000000 -149.60494 2026-03-05 07:59:09  9399
#>  21:   failed  10.000000  5.0000000         NA 2026-03-05 07:59:09    NA
#>  22:   failed  10.000000  3.8888889         NA 2026-03-05 07:59:09    NA
#>  23:   failed  10.000000  2.7777778         NA 2026-03-05 07:59:09    NA
#>  24:   failed  10.000000  1.6666667         NA 2026-03-05 07:59:09    NA
#>  25:   failed  10.000000  0.5555556         NA 2026-03-05 07:59:09    NA
#>  26:   failed  10.000000 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  27:   failed  10.000000 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  28:   failed  10.000000 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  29:   failed  10.000000 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  30:   failed  10.000000 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  31:   failed   7.777778  5.0000000         NA 2026-03-05 07:59:09    NA
#>  32:   failed   7.777778  3.8888889         NA 2026-03-05 07:59:09    NA
#>  33:   failed   7.777778  2.7777778         NA 2026-03-05 07:59:09    NA
#>  34:   failed   7.777778  1.6666667         NA 2026-03-05 07:59:09    NA
#>  35:   failed   7.777778  0.5555556         NA 2026-03-05 07:59:09    NA
#>  36:   failed   7.777778 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  37:   failed   7.777778 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  38:   failed   7.777778 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  39:   failed   7.777778 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  40:   failed   7.777778 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  41:   failed   5.555556  5.0000000         NA 2026-03-05 07:59:09    NA
#>  42:   failed   5.555556  3.8888889         NA 2026-03-05 07:59:09    NA
#>  43:   failed   5.555556  2.7777778         NA 2026-03-05 07:59:09    NA
#>  44:   failed   5.555556  1.6666667         NA 2026-03-05 07:59:09    NA
#>  45:   failed   5.555556  0.5555556         NA 2026-03-05 07:59:09    NA
#>  46:   failed   5.555556 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  47:   failed   5.555556 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  48:   failed   5.555556 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  49:   failed   5.555556 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  50:   failed   5.555556 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  51:   failed   3.333333  5.0000000         NA 2026-03-05 07:59:09    NA
#>  52:   failed   3.333333  3.8888889         NA 2026-03-05 07:59:09    NA
#>  53:   failed   3.333333  2.7777778         NA 2026-03-05 07:59:09    NA
#>  54:   failed   3.333333  1.6666667         NA 2026-03-05 07:59:09    NA
#>  55:   failed   3.333333  0.5555556         NA 2026-03-05 07:59:09    NA
#>  56:   failed   3.333333 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  57:   failed   3.333333 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  58:   failed   3.333333 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  59:   failed   3.333333 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  60:   failed   3.333333 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  61:   failed   1.111111  5.0000000         NA 2026-03-05 07:59:09    NA
#>  62:   failed   1.111111  3.8888889         NA 2026-03-05 07:59:09    NA
#>  63:   failed   1.111111  2.7777778         NA 2026-03-05 07:59:09    NA
#>  64:   failed   1.111111  1.6666667         NA 2026-03-05 07:59:09    NA
#>  65:   failed   1.111111  0.5555556         NA 2026-03-05 07:59:09    NA
#>  66:   failed   1.111111 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  67:   failed   1.111111 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  68:   failed   1.111111 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  69:   failed   1.111111 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  70:   failed   1.111111 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  71:   failed  -1.111111  5.0000000         NA 2026-03-05 07:59:09    NA
#>  72:   failed  -1.111111  3.8888889         NA 2026-03-05 07:59:09    NA
#>  73:   failed  -1.111111  2.7777778         NA 2026-03-05 07:59:09    NA
#>  74:   failed  -1.111111  1.6666667         NA 2026-03-05 07:59:09    NA
#>  75:   failed  -1.111111  0.5555556         NA 2026-03-05 07:59:09    NA
#>  76:   failed  -1.111111 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  77:   failed  -1.111111 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  78:   failed  -1.111111 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  79:   failed  -1.111111 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  80:   failed  -1.111111 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  81:   failed  -3.333333  5.0000000         NA 2026-03-05 07:59:09    NA
#>  82:   failed  -3.333333  3.8888889         NA 2026-03-05 07:59:09    NA
#>  83:   failed  -3.333333  2.7777778         NA 2026-03-05 07:59:09    NA
#>  84:   failed  -3.333333  1.6666667         NA 2026-03-05 07:59:09    NA
#>  85:   failed  -3.333333  0.5555556         NA 2026-03-05 07:59:09    NA
#>  86:   failed  -3.333333 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  87:   failed  -3.333333 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  88:   failed  -3.333333 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  89:   failed  -3.333333 -3.8888889         NA 2026-03-05 07:59:09    NA
#>  90:   failed  -3.333333 -5.0000000         NA 2026-03-05 07:59:09    NA
#>  91:   failed  -5.555556  5.0000000         NA 2026-03-05 07:59:09    NA
#>  92:   failed  -5.555556  3.8888889         NA 2026-03-05 07:59:09    NA
#>  93:   failed  -5.555556  2.7777778         NA 2026-03-05 07:59:09    NA
#>  94:   failed  -5.555556  1.6666667         NA 2026-03-05 07:59:09    NA
#>  95:   failed  -5.555556  0.5555556         NA 2026-03-05 07:59:09    NA
#>  96:   failed  -5.555556 -0.5555556         NA 2026-03-05 07:59:09    NA
#>  97:   failed  -5.555556 -1.6666667         NA 2026-03-05 07:59:09    NA
#>  98:   failed  -5.555556 -2.7777778         NA 2026-03-05 07:59:09    NA
#>  99:   failed  -5.555556 -3.8888889         NA 2026-03-05 07:59:09    NA
#> 100:   failed  -5.555556 -5.0000000         NA 2026-03-05 07:59:09    NA
#>         state         x1         x2          y        timestamp_xs   pid
#>        <char>      <num>      <num>      <num>              <POSc> <int>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>   1: academical_guineapig 2026-03-05 07:59:09
#>   2: academical_guineapig 2026-03-05 07:59:09
#>   3: academical_guineapig 2026-03-05 07:59:09
#>   4: academical_guineapig 2026-03-05 07:59:09
#>   5: academical_guineapig 2026-03-05 07:59:09
#>   6: academical_guineapig 2026-03-05 07:59:09
#>   7: academical_guineapig 2026-03-05 07:59:09
#>   8: academical_guineapig 2026-03-05 07:59:10
#>   9: academical_guineapig 2026-03-05 07:59:10
#>  10: academical_guineapig 2026-03-05 07:59:10
#>  11: academical_guineapig 2026-03-05 07:59:10
#>  12: academical_guineapig 2026-03-05 07:59:10
#>  13: academical_guineapig 2026-03-05 07:59:10
#>  14: academical_guineapig 2026-03-05 07:59:10
#>  15: academical_guineapig 2026-03-05 07:59:10
#>  16: academical_guineapig 2026-03-05 07:59:10
#>  17: academical_guineapig 2026-03-05 07:59:10
#>  18: academical_guineapig 2026-03-05 07:59:10
#>  19: academical_guineapig 2026-03-05 07:59:10
#>  20: academical_guineapig 2026-03-05 07:59:10
#>  21:                 <NA>                <NA>
#>  22:                 <NA>                <NA>
#>  23:                 <NA>                <NA>
#>  24:                 <NA>                <NA>
#>  25:                 <NA>                <NA>
#>  26:                 <NA>                <NA>
#>  27:                 <NA>                <NA>
#>  28:                 <NA>                <NA>
#>  29:                 <NA>                <NA>
#>  30:                 <NA>                <NA>
#>  31:                 <NA>                <NA>
#>  32:                 <NA>                <NA>
#>  33:                 <NA>                <NA>
#>  34:                 <NA>                <NA>
#>  35:                 <NA>                <NA>
#>  36:                 <NA>                <NA>
#>  37:                 <NA>                <NA>
#>  38:                 <NA>                <NA>
#>  39:                 <NA>                <NA>
#>  40:                 <NA>                <NA>
#>  41:                 <NA>                <NA>
#>  42:                 <NA>                <NA>
#>  43:                 <NA>                <NA>
#>  44:                 <NA>                <NA>
#>  45:                 <NA>                <NA>
#>  46:                 <NA>                <NA>
#>  47:                 <NA>                <NA>
#>  48:                 <NA>                <NA>
#>  49:                 <NA>                <NA>
#>  50:                 <NA>                <NA>
#>  51:                 <NA>                <NA>
#>  52:                 <NA>                <NA>
#>  53:                 <NA>                <NA>
#>  54:                 <NA>                <NA>
#>  55:                 <NA>                <NA>
#>  56:                 <NA>                <NA>
#>  57:                 <NA>                <NA>
#>  58:                 <NA>                <NA>
#>  59:                 <NA>                <NA>
#>  60:                 <NA>                <NA>
#>  61:                 <NA>                <NA>
#>  62:                 <NA>                <NA>
#>  63:                 <NA>                <NA>
#>  64:                 <NA>                <NA>
#>  65:                 <NA>                <NA>
#>  66:                 <NA>                <NA>
#>  67:                 <NA>                <NA>
#>  68:                 <NA>                <NA>
#>  69:                 <NA>                <NA>
#>  70:                 <NA>                <NA>
#>  71:                 <NA>                <NA>
#>  72:                 <NA>                <NA>
#>  73:                 <NA>                <NA>
#>  74:                 <NA>                <NA>
#>  75:                 <NA>                <NA>
#>  76:                 <NA>                <NA>
#>  77:                 <NA>                <NA>
#>  78:                 <NA>                <NA>
#>  79:                 <NA>                <NA>
#>  80:                 <NA>                <NA>
#>  81:                 <NA>                <NA>
#>  82:                 <NA>                <NA>
#>  83:                 <NA>                <NA>
#>  84:                 <NA>                <NA>
#>  85:                 <NA>                <NA>
#>  86:                 <NA>                <NA>
#>  87:                 <NA>                <NA>
#>  88:                 <NA>                <NA>
#>  89:                 <NA>                <NA>
#>  90:                 <NA>                <NA>
#>  91:                 <NA>                <NA>
#>  92:                 <NA>                <NA>
#>  93:                 <NA>                <NA>
#>  94:                 <NA>                <NA>
#>  95:                 <NA>                <NA>
#>  96:                 <NA>                <NA>
#>  97:                 <NA>                <NA>
#>  98:                 <NA>                <NA>
#>  99:                 <NA>                <NA>
#> 100:                 <NA>                <NA>
#>                 worker_id        timestamp_ys
#>                    <char>              <POSc>
#>                                      keys                 message x_domain_x1
#>                                    <char>                  <char>       <num>
#>   1: 8408c615-14a1-4b9d-b33f-63247816a629                    <NA>  -10.000000
#>   2: 838862ee-2e94-43f1-8bd1-3f98296fd1f6                    <NA>  -10.000000
#>   3: b1fa2f10-dec1-484a-bfc4-185182312708                    <NA>  -10.000000
#>   4: d07f7c5e-58bd-4066-9127-d7a5dc14606e                    <NA>  -10.000000
#>   5: 21fd53ba-5163-4510-b547-a9887125c0b2                    <NA>  -10.000000
#>   6: e3807e9f-2413-4a55-8312-ff62ddf54aa4                    <NA>  -10.000000
#>   7: 756c3f7e-b3a2-42bd-8656-0923967be8bd                    <NA>  -10.000000
#>   8: 79377250-ba0e-41c5-ba48-da0b04b48661                    <NA>  -10.000000
#>   9: 84213ea6-27dc-414f-b8d9-6e38a4c34168                    <NA>  -10.000000
#>  10: 1f692cff-b31b-4964-bf86-a651acddb1fc                    <NA>  -10.000000
#>  11: 40fdc39c-3c53-4380-a98e-731b68cd46bf                    <NA>   -7.777778
#>  12: 921c2ea2-c97c-453d-95f5-ca39f433c1e8                    <NA>   -7.777778
#>  13: a3c37270-8d9c-4242-bd20-16c9dd336d79                    <NA>   -7.777778
#>  14: 068432fb-c18e-4305-b7fa-a42295bf4719                    <NA>   -7.777778
#>  15: b8dc45cb-cc82-4843-8d3e-080c9183b8f0                    <NA>   -7.777778
#>  16: d0e668db-5b72-4f4a-9d22-b04e17c9895e                    <NA>   -7.777778
#>  17: b672f111-1612-4549-9de2-fde8b5ac3c3d                    <NA>   -7.777778
#>  18: 857a0ead-02e3-4cbf-a939-6355f96f5ff0                    <NA>   -7.777778
#>  19: 0f74fe68-cbd0-4c8c-9b3c-9a96c8003fba                    <NA>   -7.777778
#>  20: afe41ef1-bb59-4f5c-98cd-7f4dd8b52cb2                    <NA>   -7.777778
#>  21: 72496f7d-8afd-498c-8a03-b6886c837198 Optimization terminated          NA
#>  22: 26c07290-3829-46ca-b499-b942407a35d8 Optimization terminated          NA
#>  23: 973e9e04-04aa-49bf-802f-243d4cec09ca Optimization terminated          NA
#>  24: a3e7ed1d-f325-4967-ab44-95972663016e Optimization terminated          NA
#>  25: d723174d-c919-4ddb-9f02-ffe20d6bb30d Optimization terminated          NA
#>  26: dd9d8be6-85ad-47ef-9b5e-a838bf55e39c Optimization terminated          NA
#>  27: 5c09605d-c526-4ee3-a562-34df70365c42 Optimization terminated          NA
#>  28: 21dee110-9fb1-45e5-bedb-e7051373eb3b Optimization terminated          NA
#>  29: 00b416bc-a195-4e38-a9be-79481c0eb5cf Optimization terminated          NA
#>  30: 314d46e1-f165-4fee-ad70-d7715c74641f Optimization terminated          NA
#>  31: 028e0ddf-792f-4335-951b-b0252812624c Optimization terminated          NA
#>  32: b7372067-aad9-410f-9372-b536c78d194c Optimization terminated          NA
#>  33: f41be2ba-b8d0-4cec-b33b-15cc404cf14c Optimization terminated          NA
#>  34: 640be6c2-6aa6-4d7c-8942-b41d6c2be758 Optimization terminated          NA
#>  35: 705bfeba-1403-43af-8d5c-18f25919ea14 Optimization terminated          NA
#>  36: 9b1fd692-3284-4d3c-b7f8-dd18e4fcac6f Optimization terminated          NA
#>  37: bbd5a095-07d3-4b82-823e-0f18e75f0c31 Optimization terminated          NA
#>  38: 4fef0d6b-20ae-4bc7-9af6-b6ac5f1e5e15 Optimization terminated          NA
#>  39: 56ef12bd-9c1a-4507-89ec-e6d428d3b57c Optimization terminated          NA
#>  40: 7a1c6dc6-5515-4dd0-85eb-1adfb8dcd40c Optimization terminated          NA
#>  41: f290ba86-97f1-4b7c-8fd2-3ae098928c18 Optimization terminated          NA
#>  42: 57ef3f96-e378-4441-b1bd-2319e8b40d87 Optimization terminated          NA
#>  43: 5752ae26-287b-41b4-a50f-fcfc03d9c625 Optimization terminated          NA
#>  44: 6dcb3049-5894-41ee-bd93-b2e1daf2eae3 Optimization terminated          NA
#>  45: 4491af93-6c19-40e4-b15e-1affe6d16a9f Optimization terminated          NA
#>  46: f4f4a9a8-2cf9-4014-ba57-d8fa5305ed5a Optimization terminated          NA
#>  47: 56c0cda5-3e09-484b-a6ef-50257c776111 Optimization terminated          NA
#>  48: e1bb8591-8f27-499e-9ce7-41e2af4e1613 Optimization terminated          NA
#>  49: 6deaf706-63e4-40b8-b5d6-c0e23cf7ba3a Optimization terminated          NA
#>  50: 06d4e20f-992b-4186-ac71-f7951ff3b63f Optimization terminated          NA
#>  51: 81f29048-7017-46d0-a6e5-1a9495086439 Optimization terminated          NA
#>  52: b4f7afd1-5ca7-4b92-bd06-367b6506defd Optimization terminated          NA
#>  53: ec67b128-0024-4c71-a445-89978775cc1b Optimization terminated          NA
#>  54: 09f0d930-dbe6-4c1e-8661-ec5724352485 Optimization terminated          NA
#>  55: 99bb2a0e-a8fd-44b2-933a-e3eaf4942c99 Optimization terminated          NA
#>  56: 33c70eac-e6ed-4d8d-aa29-8b060b37587e Optimization terminated          NA
#>  57: 7f7adf07-346c-4f0f-9189-88670f56f702 Optimization terminated          NA
#>  58: 81c584bc-61a1-4700-acb8-0b9d6391ac13 Optimization terminated          NA
#>  59: c930b605-c3a3-4d7b-9abf-c4143e3a7cde Optimization terminated          NA
#>  60: 2524ee04-d110-49af-a364-2aa76d9d7951 Optimization terminated          NA
#>  61: 402bb9b5-9b0a-483b-9782-20a10631294d Optimization terminated          NA
#>  62: 3337281c-d957-40e8-a89a-25c8de363551 Optimization terminated          NA
#>  63: 2cd5e8b2-50a3-4820-b15d-5cd6ccdce55a Optimization terminated          NA
#>  64: 6af3198f-c05f-4d3c-be72-34f527e4bb3a Optimization terminated          NA
#>  65: a74c7ff4-69f3-4929-beb8-23d3f01484ea Optimization terminated          NA
#>  66: 6beab2e4-445a-42ef-9fe1-eea54739b273 Optimization terminated          NA
#>  67: 232309a4-1958-403e-81ca-246fad7795da Optimization terminated          NA
#>  68: cfe7acfb-cef4-415b-8c62-6c4d2851e4ea Optimization terminated          NA
#>  69: dbe6d161-5807-4002-bcd2-5573b3358a04 Optimization terminated          NA
#>  70: bcc6b7f6-b84f-4704-83a4-068f0c1e4d19 Optimization terminated          NA
#>  71: 269af30b-87a1-4be9-9546-83e566e8bb4a Optimization terminated          NA
#>  72: 051efc88-4594-4c76-a701-50c800cf9d4a Optimization terminated          NA
#>  73: c25b2b33-7f0b-4650-b993-4491b0e0ba74 Optimization terminated          NA
#>  74: 16f15943-341f-4374-8432-54e92f35a0eb Optimization terminated          NA
#>  75: 98f6a4f6-ef3a-4158-81d3-10149ff1d95a Optimization terminated          NA
#>  76: 6ba3f576-6363-487f-90e7-481e134d45cc Optimization terminated          NA
#>  77: 7ce3a41d-92ee-4ab4-a9cc-1ab5bee959d9 Optimization terminated          NA
#>  78: 52812b56-1226-4b71-a158-a364597c847c Optimization terminated          NA
#>  79: 80af86f5-b048-421c-ad0a-c55be4e88b81 Optimization terminated          NA
#>  80: 94e9e318-5371-432b-84c0-ea14bc436eba Optimization terminated          NA
#>  81: b3d341df-bd65-4e2e-a7e2-579af0e42108 Optimization terminated          NA
#>  82: 059c14e0-6dee-4501-85fc-1ac4e4ac6d1c Optimization terminated          NA
#>  83: 0d2a52f4-8b29-4eed-b7a5-3080adba7f4a Optimization terminated          NA
#>  84: a1816a89-cd2e-4091-bb9b-fb1ece66724c Optimization terminated          NA
#>  85: a14d1014-8ed8-4600-9052-f95ca09cd798 Optimization terminated          NA
#>  86: 1ca6cd2c-587b-43b7-81ec-e8bead8f597c Optimization terminated          NA
#>  87: 623a653e-4580-4050-87a7-5392cf4f54d5 Optimization terminated          NA
#>  88: 69731c0d-c8f9-4821-8cd0-4f0c14e3beba Optimization terminated          NA
#>  89: ebff4347-e925-462a-924e-1928104bee99 Optimization terminated          NA
#>  90: 8a783f45-e9c3-40d8-9795-fad5a73c006e Optimization terminated          NA
#>  91: 7c4a20e0-ec19-4bf2-9a39-258becc6874c Optimization terminated          NA
#>  92: 4099813f-d27a-4e10-9e75-0a9c7ecb258b Optimization terminated          NA
#>  93: 10bf4b23-7621-466d-9c88-03a98d0b060e Optimization terminated          NA
#>  94: 9359aa0c-4c1c-4e0c-9bf8-dd9211768806 Optimization terminated          NA
#>  95: b3234235-5522-478d-82ca-abb69050c35d Optimization terminated          NA
#>  96: 021bc9c2-a4b0-4dce-ab81-a2a59e4e399e Optimization terminated          NA
#>  97: b6f58118-5426-4175-bfd8-62a1c9c32876 Optimization terminated          NA
#>  98: 860db00a-e21b-4e6a-9ae4-e120b6aef824 Optimization terminated          NA
#>  99: bd14e793-8d81-46e4-af83-4366140fb803 Optimization terminated          NA
#> 100: 5026a432-85f5-4006-8728-978d67a7aab8 Optimization terminated          NA
#>                                      keys                 message x_domain_x1
#>                                    <char>                  <char>       <num>
#>      x_domain_x2
#>            <num>
#>   1:  -5.0000000
#>   2:  -3.8888889
#>   3:  -2.7777778
#>   4:  -1.6666667
#>   5:  -0.5555556
#>   6:   0.5555556
#>   7:   1.6666667
#>   8:   2.7777778
#>   9:   3.8888889
#>  10:   5.0000000
#>  11:  -5.0000000
#>  12:  -3.8888889
#>  13:  -2.7777778
#>  14:  -1.6666667
#>  15:  -0.5555556
#>  16:   0.5555556
#>  17:   1.6666667
#>  18:   2.7777778
#>  19:   3.8888889
#>  20:   5.0000000
#>  21:          NA
#>  22:          NA
#>  23:          NA
#>  24:          NA
#>  25:          NA
#>  26:          NA
#>  27:          NA
#>  28:          NA
#>  29:          NA
#>  30:          NA
#>  31:          NA
#>  32:          NA
#>  33:          NA
#>  34:          NA
#>  35:          NA
#>  36:          NA
#>  37:          NA
#>  38:          NA
#>  39:          NA
#>  40:          NA
#>  41:          NA
#>  42:          NA
#>  43:          NA
#>  44:          NA
#>  45:          NA
#>  46:          NA
#>  47:          NA
#>  48:          NA
#>  49:          NA
#>  50:          NA
#>  51:          NA
#>  52:          NA
#>  53:          NA
#>  54:          NA
#>  55:          NA
#>  56:          NA
#>  57:          NA
#>  58:          NA
#>  59:          NA
#>  60:          NA
#>  61:          NA
#>  62:          NA
#>  63:          NA
#>  64:          NA
#>  65:          NA
#>  66:          NA
#>  67:          NA
#>  68:          NA
#>  69:          NA
#>  70:          NA
#>  71:          NA
#>  72:          NA
#>  73:          NA
#>  74:          NA
#>  75:          NA
#>  76:          NA
#>  77:          NA
#>  78:          NA
#>  79:          NA
#>  80:          NA
#>  81:          NA
#>  82:          NA
#>  83:          NA
#>  84:          NA
#>  85:          NA
#>  86:          NA
#>  87:          NA
#>  88:          NA
#>  89:          NA
#>  90:          NA
#>  91:          NA
#>  92:          NA
#>  93:          NA
#>  94:          NA
#>  95:          NA
#>  96:          NA
#>  97:          NA
#>  98:          NA
#>  99:          NA
#> 100:          NA
#>      x_domain_x2
#>            <num>
```
