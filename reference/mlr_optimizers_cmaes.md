# Optimization via Covariance Matrix Adaptation Evolution Strategy

`OptimizerBatchCmaes` class that implements CMA-ES. Calls
[`libcmaesr::cmaes()`](https://libcmaesr.mlr-org.com/reference/cmaes.html)
from package [libcmaesr](https://CRAN.R-project.org/package=libcmaesr),
which is a lightweight interface to the `libcmaes` C++ library. The
algorithm is typically applied to search space dimensions between three
and fifty.

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

- `seed`:

  `integer(1)`  
  Seed of the random number generator of `libcmaes`. Unset by default,
  in which case the generator is seeded from R and the optimization is
  reproducible with [`set.seed()`](https://rdrr.io/r/base/Random.html).

All remaining parameters are passed to
[`libcmaesr::cmaes_control()`](https://libcmaesr.mlr-org.com/reference/cmaes_control.html),
see there for their meaning. Note that we have removed all control
parameters which refer to the termination of the algorithm and where our
terminators allow to obtain the same behavior, i.e. `max_fevals`,
`max_iter`, and `ftarget`. The internal convergence criteria of the
algorithm still apply, so the optimization can stop before the
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) is
triggered.

## Batch evaluation

The optimizer evaluates a whole generation of `lambda` points in one
batch. The
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) is only
checked between generations, so the number of evaluations can exceed the
budget of
[TerminatorEvals](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md)
by up to `lambda - 1` points.

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

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerBatch`](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
-\> `OptimizerBatchCmaes`

## Methods

### Public methods

- [`OptimizerBatchCmaes$new()`](#method-OptimizerBatchCmaes-initialize)

- [`OptimizerBatchCmaes$clone()`](#method-OptimizerBatchCmaes-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchCmaes$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchCmaes$new()

------------------------------------------------------------------------

### `OptimizerBatchCmaes$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchCmaes$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if libcmaesr is available
if (mlr3misc::require_namespaces("libcmaesr", quietly = TRUE)) {
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
#>          x1       x2        x3  x_domain         y
#>       <num>    <num>     <num>    <list>     <num>
#> 1: 2.018607 2.802398 -3.736987 <list[3]> -23.73735
```
