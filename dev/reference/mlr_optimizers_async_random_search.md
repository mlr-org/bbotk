# Asynchronous Optimization via Random Search

`OptimizerAsyncRandomSearch` class that implements a simple Random
Search.

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

    mlr_optimizers$get("async_random_search")
    opt("async_random_search")

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncRandomSearch`

## Methods

### Public methods

- [`OptimizerAsyncRandomSearch$new()`](#method-OptimizerAsyncRandomSearch-new)

- [`OptimizerAsyncRandomSearch$clone()`](#method-OptimizerAsyncRandomSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerAsync$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncRandomSearch$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncRandomSearch$clone(deep = FALSE)

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
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>  1: finished -8.6401429 -0.22082921 -110.93643045 2026-02-27 14:19:32  9846
#>  2: finished  2.6451261 -0.47433125    3.20480965 2026-02-27 14:19:33  9846
#>  3: finished  6.6553863 -4.98604438  -15.61699363 2026-02-27 14:19:33  9846
#>  4: finished  5.0158969 -1.16851633   -2.44996658 2026-02-27 14:19:33  9846
#>  5: finished -4.2982254  4.20337792  -81.55629675 2026-02-27 14:19:33  9846
#>  6: finished -5.3318011  3.07859096  -80.70457510 2026-02-27 14:19:33  9846
#>  7: finished -1.2947935  4.44486001  -56.28160502 2026-02-27 14:19:33  9846
#>  8: finished  4.4867714 -4.92985296    0.09163568 2026-02-27 14:19:33  9846
#>  9: finished -4.1477403  2.28072295  -55.68074611 2026-02-27 14:19:33  9846
#> 10: finished -5.6137151  4.91263287 -110.57841706 2026-02-27 14:19:33  9846
#> 11: finished  0.5407374 -0.53103894    1.77478382 2026-02-27 14:19:33  9846
#> 12: finished -5.7833451 -3.39854730  -50.73930118 2026-02-27 14:19:33  9846
#> 13: finished -8.4307422  4.47890861 -154.73445725 2026-02-27 14:19:33  9846
#> 14: finished  7.1022916 -0.75569363  -21.07029075 2026-02-27 14:19:33  9846
#> 15: finished  5.9002467 -2.48642191   -5.47568658 2026-02-27 14:19:33  9846
#> 16: finished  4.0407162 -0.43184476   -0.75994399 2026-02-27 14:19:33  9846
#> 17: finished -7.4830553 -2.92798538  -79.93352300 2026-02-27 14:19:33  9846
#> 18: finished -3.9849409 -1.06526646  -29.56271169 2026-02-27 14:19:33  9846
#> 19: finished -2.3908942  0.02101378  -18.40647620 2026-02-27 14:19:33  9846
#> 20: finished  0.8103813  4.51596998  -47.90499748 2026-02-27 14:19:33  9846
#>        state         x1          x2             y        timestamp_xs   pid
#>       <char>      <num>       <num>         <num>              <POSc> <int>
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>  1: papery_hog 2026-02-27 14:19:32 cb2e3843-eee0-4d08-938a-44df9cf419a6
#>  2: papery_hog 2026-02-27 14:19:33 6dd17412-0c48-4274-8b25-0a4e1a4579da
#>  3: papery_hog 2026-02-27 14:19:33 168b826a-4e9a-446b-a434-da21fa49f7fc
#>  4: papery_hog 2026-02-27 14:19:33 eefe0157-92ef-4f12-a055-0411b52eb07c
#>  5: papery_hog 2026-02-27 14:19:33 a0d57c53-d1ba-4351-bbfd-a68a17ac31f6
#>  6: papery_hog 2026-02-27 14:19:33 219d9e40-d55f-4e7d-a28f-eff45648431a
#>  7: papery_hog 2026-02-27 14:19:33 bdbeeb20-ebc3-482d-ad67-b9590fbe2f3c
#>  8: papery_hog 2026-02-27 14:19:33 670dca56-18dc-4099-b2a1-a0168f10b073
#>  9: papery_hog 2026-02-27 14:19:33 1d1327f5-34c5-4280-826c-cec561c660f7
#> 10: papery_hog 2026-02-27 14:19:33 eef112e3-47ef-4ab8-b22a-f505bdf0ff9c
#> 11: papery_hog 2026-02-27 14:19:33 e5206d74-04a4-4859-8b74-7d5ec033e29a
#> 12: papery_hog 2026-02-27 14:19:33 0c31e055-8e8e-4c4c-9560-45f6865af859
#> 13: papery_hog 2026-02-27 14:19:33 60ab8cdb-a332-4d3a-adbd-e24b64b77b96
#> 14: papery_hog 2026-02-27 14:19:33 63c6c8af-293f-4795-9595-45903e7e9602
#> 15: papery_hog 2026-02-27 14:19:33 1c748375-0783-4f11-9da2-36ec9d6ec50c
#> 16: papery_hog 2026-02-27 14:19:33 bb681594-71cc-4ee0-b30d-5060faf23d04
#> 17: papery_hog 2026-02-27 14:19:33 a282af6a-0b61-496c-af2f-6225de5c235a
#> 18: papery_hog 2026-02-27 14:19:33 75ae5001-a66a-4638-a540-d64f0a138a1d
#> 19: papery_hog 2026-02-27 14:19:33 24a56dd7-8798-418d-925b-229a0262028b
#> 20: papery_hog 2026-02-27 14:19:33 2edcab9f-bf9a-4933-9b6e-9fe1c0af1ffb
#>      worker_id        timestamp_ys                                 keys
#>         <char>              <POSc>                               <char>
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
#>  1:  -8.6401429 -0.22082921
#>  2:   2.6451261 -0.47433125
#>  3:   6.6553863 -4.98604438
#>  4:   5.0158969 -1.16851633
#>  5:  -4.2982254  4.20337792
#>  6:  -5.3318011  3.07859096
#>  7:  -1.2947935  4.44486001
#>  8:   4.4867714 -4.92985296
#>  9:  -4.1477403  2.28072295
#> 10:  -5.6137151  4.91263287
#> 11:   0.5407374 -0.53103894
#> 12:  -5.7833451 -3.39854730
#> 13:  -8.4307422  4.47890861
#> 14:   7.1022916 -0.75569363
#> 15:   5.9002467 -2.48642191
#> 16:   4.0407162 -0.43184476
#> 17:  -7.4830553 -2.92798538
#> 18:  -3.9849409 -1.06526646
#> 19:  -2.3908942  0.02101378
#> 20:   0.8103813  4.51596998
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
```
