# Run Optimizers Sequentially

`OptimizerBatchChain` allows to run multiple
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
sequentially.

For each
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
an (optional) additional
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) can be
specified during construction. While the original
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) of the
[OptimInstanceBatch](https://bbotk.mlr-org.com/reference/OptimInstanceBatch.md)
guards the optimization process as a whole, the additional
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s guard
each individual
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md).

The optimization process works as follows: The first
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
is run on the
[OptimInstanceBatch](https://bbotk.mlr-org.com/reference/OptimInstanceBatch.md)
relying on a
[TerminatorCombo](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md)
of the original
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) of the
[OptimInstanceBatch](https://bbotk.mlr-org.com/reference/OptimInstanceBatch.md)
and the (optional) additional
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) as
passed during construction. Once this
[TerminatorCombo](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md)
indicates termination (usually via the additional
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)), the
second
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
is run. This continues for all optimizers unless the original
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) of the
[OptimInstanceBatch](https://bbotk.mlr-org.com/reference/OptimInstanceBatch.md)
indicates termination.

OptimizerBatchChain can also be used for random restarts of the same
[Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) (if
applicable) by setting the
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) of the
[OptimInstanceBatch](https://bbotk.mlr-org.com/reference/OptimInstanceBatch.md)
to
[TerminatorNone](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md)
and setting identical additional
[Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s during
construction.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("chain")
    opt("chain")

## Parameters

Parameters are inherited from the individual
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
and collected as a
[paradox::ParamSetCollection](https://paradox.mlr-org.com/reference/ParamSetCollection.html)
(with `set_id`s potentially postfixed via `_1`, `_2`, ..., if the same
[OptimizerBatch](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
are used multiple times).

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
-\> `OptimizerBatchChain`

## Methods

### Public methods

- [`OptimizerBatchChain$new()`](#method-OptimizerBatchChain-new)

- [`OptimizerBatchChain$clone()`](#method-OptimizerBatchChain-clone)

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

    OptimizerBatchChain$new(
      optimizers,
      terminators = rep(list(NULL), length(optimizers))
    )

#### Arguments

- `optimizers`:

  (list of
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md)s).

- `terminators`:

  (list of
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s \|
  NULL).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchChain$clone(deep = FALSE)

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
  terminator = trm("evals", n_evals = 10)
)

# load optimizer
optimizer = opt("chain",
  optimizers = list(opt("random_search"), opt("grid_search")),
  terminators = list(trm("evals", n_evals = 5), trm("evals", n_evals = 5))
)

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$result
}
#>          x1        x2  x_domain         y
#>       <num>     <num>    <list>     <num>
#> 1: 1.111111 0.5555556 <list[2]> -3.432099
```
