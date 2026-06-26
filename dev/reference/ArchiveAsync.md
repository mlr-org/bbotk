# Rush Data Storage

The `ArchiveAsync` stores all evaluated points and performance scores in
a [rush::Rush](https://rush.mlr-org.com/reference/Rush.html) data base.

## S3 Methods

- `as.data.table(archive)`  
  ArchiveAsync -\>
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Returns a tabular view of all performed function calls of the
  Objective. The `x_domain` column is unnested to separate columns.

## Super class

[`Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md) -\>
`ArchiveAsync`

## Public fields

- `rush`:

  (`Rush`)  
  Rush controller for parallel optimization.

## Active bindings

- `data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all finished points.

- `queued_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all queued points.

- `running_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all running points.

- `finished_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all finished points.

- `failed_data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Data table with all failed points.

- `n_queued`:

  (`integer(1)`)  
  Number of queued points.

- `n_running`:

  (`integer(1)`)  
  Number of running points.

- `n_finished`:

  (`integer(1)`)  
  Number of finished points.

- `n_failed`:

  (`integer(1)`)  
  Number of failed points.

- `n_evals`:

  (`integer(1)`)  
  Number of evaluations stored in the archive.

## Methods

### Public methods

- [`ArchiveAsync$new()`](#method-ArchiveAsync-initialize)

- [`ArchiveAsync$push_points()`](#method-ArchiveAsync-push_points)

- [`ArchiveAsync$push_point()`](#method-ArchiveAsync-push_point)

- [`ArchiveAsync$push_running_points()`](#method-ArchiveAsync-push_running_points)

- [`ArchiveAsync$push_running_point()`](#method-ArchiveAsync-push_running_point)

- [`ArchiveAsync$push_finished_points()`](#method-ArchiveAsync-push_finished_points)

- [`ArchiveAsync$push_finished_point()`](#method-ArchiveAsync-push_finished_point)

- [`ArchiveAsync$push_failed_points()`](#method-ArchiveAsync-push_failed_points)

- [`ArchiveAsync$push_failed_point()`](#method-ArchiveAsync-push_failed_point)

- [`ArchiveAsync$pop_point()`](#method-ArchiveAsync-pop_point)

- [`ArchiveAsync$finish_points()`](#method-ArchiveAsync-finish_points)

- [`ArchiveAsync$finish_point()`](#method-ArchiveAsync-finish_point)

- [`ArchiveAsync$fail_points()`](#method-ArchiveAsync-fail_points)

- [`ArchiveAsync$fail_point()`](#method-ArchiveAsync-fail_point)

- [`ArchiveAsync$push_result()`](#method-ArchiveAsync-push_result)

- [`ArchiveAsync$data_with_state()`](#method-ArchiveAsync-data_with_state)

- [`ArchiveAsync$best()`](#method-ArchiveAsync-best)

- [`ArchiveAsync$nds_selection()`](#method-ArchiveAsync-nds_selection)

- [`ArchiveAsync$clear()`](#method-ArchiveAsync-clear)

- [`ArchiveAsync$clone()`](#method-ArchiveAsync-clone)

Inherited methods

- [`Archive$format()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-format)
- [`Archive$help()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-help)
- [`Archive$print()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-print)

------------------------------------------------------------------------

### `ArchiveAsync$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveAsync$new(search_space, codomain, check_values = FALSE, rush)

#### Arguments

- `search_space`:

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

- `codomain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies codomain of function. Most importantly the tags of each
  output "Parameter" define whether it should be minimized or maximized.
  The default is to minimize each component.

- `check_values`:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

- `rush`:

  (`Rush`)  
  If a rush instance is supplied, the tuning runs without batches.

------------------------------------------------------------------------

### `ArchiveAsync$push_points()`

Push queued points to the archive.

#### Usage

    ArchiveAsync$push_points(xss, xss_extra = NULL, extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `xss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$push_point()`

Push a single queued point to the archive.

#### Usage

    ArchiveAsync$push_point(xs, xs_extra = NULL, extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `xs_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$push_running_points()`

Push running points to the archive.

#### Usage

    ArchiveAsync$push_running_points(xss, xss_extra = NULL, extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `xss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$push_running_point()`

Push running point to the archive.

#### Usage

    ArchiveAsync$push_running_point(xs, xs_extra = NULL, extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `xs_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$push_finished_points()`

Push finished points to the archive.

#### Usage

    ArchiveAsync$push_finished_points(xss, yss, xss_extra = NULL, yss_extra = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `yss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of results.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `yss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

------------------------------------------------------------------------

### `ArchiveAsync$push_finished_point()`

Push a single finished point to the archive.

#### Usage

    ArchiveAsync$push_finished_point(xs, ys, xs_extra = NULL, ys_extra = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `ys`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `xs_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

- `ys_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsync$push_failed_points()`

Push failed points to the archive.

#### Usage

    ArchiveAsync$push_failed_points(xss, xss_extra = NULL, conditions = NULL)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

- `xss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `conditions`:

  (`list` \| `NULL`)  
  List of conditions for each failed point. If `NULL`, a generic error
  message is used.

------------------------------------------------------------------------

### `ArchiveAsync$push_failed_point()`

Push a single failed point to the archive.

#### Usage

    ArchiveAsync$push_failed_point(xs, xs_extra = NULL, condition = NULL)

#### Arguments

- `xs`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of point values.

- `xs_extra`:

  (`named list()` \| `NULL`)  
  Named list of additional information.

- `condition`:

  (`any` \| `NULL`)  
  Condition of the failed point. If `NULL`, a generic error message is
  used.

------------------------------------------------------------------------

### `ArchiveAsync$pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsync$pop_point()

------------------------------------------------------------------------

### `ArchiveAsync$finish_points()`

Save the results of multiple running points and move them to the
finished points.

#### Usage

    ArchiveAsync$finish_points(
      keys,
      yss,
      x_domains,
      yss_extra = NULL,
      extra = NULL
    )

#### Arguments

- `keys`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys of the points.

- `yss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of results.

- `x_domains`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of transformed point values.

- `yss_extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  List of named lists of additional information.

- `extra`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html) \|
  `NULL`)  
  Deprecated argument for additional information. Use `yss_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$finish_point()`

Save the results of a running point and move it to the finished points.

#### Usage

    ArchiveAsync$finish_point(key, ys, x_domain, ys_extra = NULL, extra = NULL)

#### Arguments

- `key`:

  (`character(1)`)  
  Key of the point.

- `ys`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `x_domain`:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named list of transformed point values.

- `ys_extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Named list of additional information.

- `extra`:

  (named [`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Deprecated argument for additional information. Use `ys_extra`
  instead.

------------------------------------------------------------------------

### `ArchiveAsync$fail_points()`

Move multiple running points to the failed points.

#### Usage

    ArchiveAsync$fail_points(keys, conditions = NULL)

#### Arguments

- `keys`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys of the points.

- `conditions`:

  ([`list()`](https://rdrr.io/r/base/list.html) \| `NULL`)  
  Conditions of the failed points.

------------------------------------------------------------------------

### `ArchiveAsync$fail_point()`

Move a running point to the failed points.

#### Usage

    ArchiveAsync$fail_point(key, condition = NULL)

#### Arguments

- `key`:

  (`character(1)`)  
  Key of the point.

- `condition`:

  (`any` \| `NULL`)  
  Condition of the failed point.

------------------------------------------------------------------------

### `ArchiveAsync$push_result()`

Deprecated. Use `$finish_point()` instead.

#### Usage

    ArchiveAsync$push_result(key, ys, x_domain, extra = NULL)

#### Arguments

- `key`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Key of the point.

- `ys`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of results.

- `x_domain`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of transformed point values.

- `extra`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsync$data_with_state()`

Fetch points with a specific state.

#### Usage

    ArchiveAsync$data_with_state(
      fields = c("worker_id", "xs", "ys", "xs_extra", "ys_extra", "condition"),
      states = c("queued", "running", "finished", "failed")
    )

#### Arguments

- `fields`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Fields to fetch. Defaults to
  `c("worker_id", "xs", "ys", "xs_extra", "ys_extra", "condition")`.

- `states`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  States of the tasks to be fetched. Defaults to
  `c("queued", "running", "finished", "failed")`.

------------------------------------------------------------------------

### `ArchiveAsync$best()`

Returns the best scoring evaluation(s). For single-crit optimization,
the solution that minimizes / maximizes the objective function. For
multi-crit optimization, the Pareto set / front.

#### Usage

    ArchiveAsync$best(n_select = 1, ties_method = "first")

#### Arguments

- `n_select`:

  (`integer(1L)`)  
  Amount of points to select. Ignored for multi-crit optimization.

- `ties_method`:

  (`character(1L)`)  
  Method to break ties when multiple points have the same score. Either
  `"first"` (default) or `"random"`. Ignored for multi-crit
  optimization. If `n_select > 1L`, the tie method is ignored and the
  first point is returned.

#### Returns

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)

------------------------------------------------------------------------

### `ArchiveAsync$nds_selection()`

Calculate best points w.r.t. non dominated sorting with hypervolume
contribution.

#### Usage

    ArchiveAsync$nds_selection(n_select = 1, ref_point = NULL)

#### Arguments

- `n_select`:

  (`integer(1L)`)  
  Amount of points to select.

- `ref_point`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Reference point for hypervolume.

#### Returns

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)

------------------------------------------------------------------------

### `ArchiveAsync$clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveAsync$clear()

------------------------------------------------------------------------

### `ArchiveAsync$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ArchiveAsync$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (mlr3misc::require_namespaces(c("rush", "redux", "mirai"), quietly = TRUE) &&
  redux::redis_available()) {
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
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# all evaluated configuration
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)

# reset the rush data base
instance$rush$reset()
}
```
