# Generalized Simulated Annealing

`OptimizerBatchGenSA` class that implements generalized simulated
annealing. Calls
[`GenSA::GenSA()`](https://rdrr.io/pkg/GenSA/man/GenSA.html) from
package [GenSA](https://CRAN.R-project.org/package=GenSA).

## Source

Tsallis C, Stariolo DA (1996). “Generalized simulated annealing.”
*Physica A: Statistical Mechanics and its Applications*, **233**(1-2),
395–406.
[doi:10.1016/s0378-4371(96)00271-3](https://doi.org/10.1016/s0378-4371%2896%2900271-3)
.

Xiang Y, Gubian S, Suomela B, Hoeng J (2013). “Generalized Simulated
Annealing for Global Optimization: The GenSA Package.” *The R Journal*,
**5**(1), 13.
[doi:10.32614/rj-2013-002](https://doi.org/10.32614/rj-2013-002) .

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("gensa")
    opt("gensa")

## Parameters

- `par`:

  [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Initial parameter values. Default is `NULL`, in which case, default
  values will be generated automatically.

- `start_values`:

  `character(1)`  
  Create `"random"` start values or based on `"center"` of search space?
  In the latter case, it is the center of the parameters before a trafo
  is applied. By default, `nloptr` will generate start values
  automatically. Custom start values can be passed via the `par`
  parameter.

For the meaning of the control parameters, see
[`GenSA::GenSA()`](https://rdrr.io/pkg/GenSA/man/GenSA.html). Note that
[`GenSA::GenSA()`](https://rdrr.io/pkg/GenSA/man/GenSA.html) uses
`smooth = TRUE` as a default. In the case of using this optimizer for
Hyperparameter Optimization you may want to set `smooth = FALSE`.

## Internal Termination Parameters

The algorithm can terminated with all
[Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)s.
Additionally, the following internal termination parameters can be used:

- `maxit`:

  `integer(1)`  
  Maximum number of iterations. Original default is `5000`. Overwritten
  with `.Machine$integer.max`.

- `threshold.stop`:

  `numeric(1)`  
  Threshold stop. Deactivated with `NULL`. Default is `NULL`.

- `nb.stop.improvement`:

  `integer(1)`  
  Number of stop improvement. Deactivated with `-1L`. Default is `-1L`.

- `max.call`:

  `integer(1)`  
  Maximum number of calls. Original default is `1e7`. Overwritten with
  `.Machine$integer.max`.

- `max.time`:

  `integer(1)`  
  Maximum time. Deactivate with `NULL`. Default is `NULL`.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchGenSA`

## Methods

### Public methods

- [`OptimizerBatchGenSA$new()`](#method-OptimizerBatchGenSA-new)

- [`OptimizerBatchGenSA$clone()`](#method-OptimizerBatchGenSA-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchGenSA$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchGenSA$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if GenSA is available
if (mlr3misc::require_namespaces("GenSA", quietly = TRUE)) {
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

# initialize instance
instance = oi(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)

# load optimizer
optimizer = opt("gensa")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$result
}
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.998884 -2.998197 <list[2]> 9.999996
```
