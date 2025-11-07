# Optimization via Covariance Matrix Adaptation Evolution Strategy

`OptimizerBatchCmaes` class that implements CMA-ES. Calls
[`adagio::pureCMAES()`](https://rdrr.io/pkg/adagio/man/cmaes.html) from
package [adagio](https://CRAN.R-project.org/package=adagio). The
algorithm is typically applied to search space dimensions between three
and fifty. Lower search space dimensions might crash.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("cmaes")
    opt("cmaes")

## Parameters

- `sigma`:

  `numeric(1)`

- `start_values`:

  `character(1)`  
  Create `"random"` start values or based on `"center"` of search space?
  In the latter case, it is the center of the parameters before a trafo
  is applied. If set to `"custom"`, the start values can be passed via
  the `start` parameter.

- `start`:

  [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Custom start values. Only applicable if `start_values` parameter is
  set to `"custom"`.

For the meaning of the control parameters, see
[`adagio::pureCMAES()`](https://rdrr.io/pkg/adagio/man/cmaes.html). Note
that we have removed all control parameters which refer to the
termination of the algorithm and where our terminators allow to obtain
the same behavior.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
-\> `OptimizerBatchCmaes`

## Methods

### Public methods

- [`OptimizerBatchCmaes$new()`](#method-OptimizerBatchCmaes-new)

- [`OptimizerBatchCmaes$clone()`](#method-OptimizerBatchCmaes-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchCmaes$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchCmaes$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if GenSA is available
if (mlr3misc::require_namespaces("adagio", quietly = TRUE)) {
# define the objective function
fun = function(xs) {
  list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 - (xs[[3]] + 4)^2 + 10)
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5),
  x3 = p_dbl(-5, 5)
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
optimizer = opt("cmaes")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$result
}
#>          x1    x2        x3  x_domain         y
#>       <num> <num>     <num>    <list>     <num>
#> 1: 3.649141    -5 0.3082349 <list[3]> -15.28056
```
