# Non-linear Optimization

`OptimizerBatchNLoptr` class that implements non-linear optimization.
Calls
[`nloptr::nloptr()`](https://astamm.github.io/nloptr/reference/nloptr.html)
from package [nloptr](https://CRAN.R-project.org/package=nloptr).

## Source

Johnson, G S (2020). “The NLopt nonlinear-optimization package.”
<https://github.com/stevengj/nlopt>.

## Parameters

- `algorithm`:

  `character(1)`  
  Algorithm to use. See
  [`nloptr::nloptr.print.options()`](https://astamm.github.io/nloptr/reference/nloptr.print.options.html)
  for available algorithms.

- `x0`:

  [`numeric()`](https://rdrr.io/r/base/numeric.html)  
  Initial parameter values. Use `start_values` parameter to create
  `"random"` or `"center"` start values.

- `start_values`:

  `character(1)`  
  Create `"random"` start values or based on `"center"` of search space?
  In the latter case, it is the center of the parameters before a trafo
  is applied. Custom start values can be passed via the `x0` parameter.

- `approximate_eval_grad_f`:

  `logical(1)`  
  Should gradients be numerically approximated via finite differences
  ([nloptr::nl.grad](https://astamm.github.io/nloptr/reference/nl.grad.html)).
  Only required for certain algorithms. Note that function evaluations
  required for the numerical gradient approximation will be logged as
  usual and are not treated differently than regular function
  evaluations by, e.g.,
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s.

For the meaning of other control parameters, see
[`nloptr::nloptr()`](https://astamm.github.io/nloptr/reference/nloptr.html)
and
[`nloptr::nloptr.print.options()`](https://astamm.github.io/nloptr/reference/nloptr.print.options.html).

## Internal Termination Parameters

The algorithm can terminated with all
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s.
Additionally, the following internal termination parameters can be used:

- `stopval`:

  `numeric(1)`  
  Stop value. Deactivate with `-Inf`. Default is `-Inf`.

- `maxtime`:

  `integer(1)`  
  Maximum time. Deactivate with `-1L`. Default is `-1L`.

- `maxeval`:

  `integer(1)`  
  Maximum number of evaluations. Deactivate with `-1L`. Default is
  `-1L`.

- `xtol_rel`:

  `numeric(1)`  
  Relative tolerance. Original default is 10^-4. Deactivate with `-1`.
  Overwritten with `-1`.

- `xtol_abs`:

  `numeric(1)`  
  Absolute tolerance. Deactivate with `-1`. Default is `-1`.

- `ftol_rel`:

  `numeric(1)`  
  Relative tolerance. Deactivate with `-1`. Default is `-1`.

- `ftol_abs`:

  `numeric(1)`  
  Absolute tolerance. Deactivate with `-1`. Default is `-1`.

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
-\> `OptimizerBatchNLoptr`

## Methods

### Public methods

- [`OptimizerBatchNLoptr$new()`](#method-OptimizerBatchNLoptr-new)

- [`OptimizerBatchNLoptr$clone()`](#method-OptimizerBatchNLoptr-clone)

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

    OptimizerBatchNLoptr$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchNLoptr$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if nloptr is available
if (mlr3misc::require_namespaces("nloptr", quietly = TRUE)) {
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
optimizer = opt("nloptr", algorithm = "NLOPT_LN_BOBYQA")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$result
}
#>       x1    x2  x_domain     y
#>    <num> <num>    <list> <num>
#> 1:     2    -3 <list[2]>    10
```
