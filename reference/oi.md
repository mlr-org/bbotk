# Syntactic Sugar for Optimization Instance Construction

Function to construct a
[OptimInstanceBatchSingleCrit](https://bbotk.mlr-org.com/reference/OptimInstanceBatchSingleCrit.md)
and
[OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/reference/OptimInstanceBatchMultiCrit.md).

## Usage

``` r
oi(
  objective,
  search_space = NULL,
  terminator,
  callbacks = NULL,
  check_values = TRUE,
  keep_evals = "all"
)
```

## Arguments

- objective:

  ([Objective](https://bbotk.mlr-org.com/reference/Objective.md))  
  Objective function.

- search_space:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md) or it
  describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

- terminator:

  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)  
  Termination criterion.

- callbacks:

  (list of
  [mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html))  
  List of callbacks.

- check_values:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

- keep_evals:

  (`character(1)`)  
  Keep `all` or only `best` evaluations in archive?

## Examples

``` r
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
```
