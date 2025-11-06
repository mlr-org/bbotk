# Syntactic Sugar for Asynchronous Optimization Instance Construction

Function to construct an
[OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncSingleCrit.md)
and
[OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncMultiCrit.md).

## Usage

``` r
oi_async(
  objective,
  search_space = NULL,
  terminator,
  check_values = FALSE,
  callbacks = NULL,
  rush = NULL
)
```

## Arguments

- objective:

  ([Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md))  
  Objective function.

- search_space:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md) or
  it describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

- terminator:

  [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)  
  Termination criterion.

- check_values:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

- callbacks:

  (list of
  [mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html))  
  List of callbacks.

- rush:

  (`Rush`)  
  If a rush instance is supplied, the tuning runs without batches.

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
}
```
