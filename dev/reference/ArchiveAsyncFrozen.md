# Frozen Rush Data Storage

Freezes the Redis data base of an
[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
to a
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).
No further points can be added to the archive but the data can be
accessed and analyzed. Useful when the Redis data base is not
permanently available. Use the callback
[bbotk.async_freeze_archive](https://bbotk.mlr-org.com/dev/reference/bbotk.async_freeze_archive.md)
to freeze the archive after the optimization has finished.

## S3 Methods

- `as.data.table(archive)`  
  [ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
  -\>
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Returns a tabular view of all performed function calls of the
  Objective. The `x_domain` column is unnested to separate columns.

## See also

[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)

## Super classes

[`Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md) -\>
[`ArchiveAsync`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
-\> `ArchiveAsyncFrozen`

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

- [`ArchiveAsyncFrozen$new()`](#method-ArchiveAsyncFrozen-initialize)

- [`ArchiveAsyncFrozen$push_points()`](#method-ArchiveAsyncFrozen-push_points)

- [`ArchiveAsyncFrozen$pop_point()`](#method-ArchiveAsyncFrozen-pop_point)

- [`ArchiveAsyncFrozen$push_running_point()`](#method-ArchiveAsyncFrozen-push_running_point)

- [`ArchiveAsyncFrozen$push_result()`](#method-ArchiveAsyncFrozen-push_result)

- [`ArchiveAsyncFrozen$push_failed_point()`](#method-ArchiveAsyncFrozen-push_failed_point)

- [`ArchiveAsyncFrozen$data_with_state()`](#method-ArchiveAsyncFrozen-data_with_state)

- [`ArchiveAsyncFrozen$clear()`](#method-ArchiveAsyncFrozen-clear)

- [`ArchiveAsyncFrozen$clone()`](#method-ArchiveAsyncFrozen-clone)

Inherited methods

- [`Archive$format()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-format)
- [`Archive$help()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-help)
- [`Archive$print()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-print)
- [`ArchiveAsync$best()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-best)
- [`ArchiveAsync$nds_selection()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-nds_selection)

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveAsyncFrozen$new(archive)

#### Arguments

- `archive`:

  ([ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md))  
  The archive to freeze.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_points()`

Push queued points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_points(xss)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsyncFrozen$pop_point()

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_running_point()`

Push running point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_running_point(xs, extra = NULL)

#### Arguments

- `xs`:

  (named `list`)  
  Named list of point values.

- `extra`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list of additional information.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$push_result()`

Push result to the archive.

#### Usage

    ArchiveAsyncFrozen$push_result(key, ys, x_domain, extra = NULL)

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

### `ArchiveAsyncFrozen$push_failed_point()`

Push failed point to the archive.

#### Usage

    ArchiveAsyncFrozen$push_failed_point(key, message)

#### Arguments

- `key`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Key of the point.

- `message`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Error message.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$data_with_state()`

Fetch points with a specific state.

#### Usage

    ArchiveAsyncFrozen$data_with_state(
      fields = c("xs", "ys", "xs_extra", "worker_extra", "ys_extra", "condition"),
      states = c("queued", "running", "finished", "failed"),
      reset_cache = FALSE
    )

#### Arguments

- `fields`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Fields to fetch. Defaults to
  `c("xs", "ys", "xs_extra", "worker_extra", "ys_extra")`.

- `states`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  States of the tasks to be fetched. Defaults to
  `c("queued", "running", "finished", "failed")`.

- `reset_cache`:

  (`logical(1)`)  
  Whether to reset the cache of the finished points.

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveAsyncFrozen$clear()

------------------------------------------------------------------------

### `ArchiveAsyncFrozen$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ArchiveAsyncFrozen$clone(deep = FALSE)

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
rush::rush_plan(worker_type = "mirai")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 20),
  callback = clbk("bbotk.async_freeze_archive")
)

# load optimizer
optimizer = opt("async_random_search")

# trigger optimization
optimizer$optimize(instance)

# frozen archive
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>  1: finished -6.21358293  0.2769503  -68.201348 2026-06-11 08:55:53
#>  2: finished -2.62264757  4.2779729  -64.337761 2026-06-11 08:55:53
#>  3: finished  6.84682656  3.2309502  -52.316468 2026-06-11 08:55:53
#>  4: finished -1.96786549 -3.4438612   -5.940969 2026-06-11 08:55:53
#>  5: finished -9.86571338  2.5243351 -161.313432 2026-06-11 08:55:54
#>  6: finished  0.01208465  3.1304511  -31.534238 2026-06-11 08:55:54
#>  7: finished -4.77998488  1.4299587  -55.592729 2026-06-11 08:55:54
#>  8: finished  7.57503606  1.3830058  -40.291767 2026-06-11 08:55:54
#>  9: finished  8.01326577 -2.8537699  -26.180748 2026-06-11 08:55:54
#> 10: finished  5.39871055  2.9134685  -36.520343 2026-06-11 08:55:54
#> 11: finished  4.82894640 -0.2106949   -5.783161 2026-06-11 08:55:54
#> 12: finished  2.92831418 -0.4491262    2.631276 2026-06-11 08:55:54
#> 13: finished -2.48881904  1.6091926  -31.394153 2026-06-11 08:55:54
#> 14: finished  2.11332211  1.0427817   -6.356925 2026-06-11 08:55:54
#> 15: finished  0.87403046  4.3072392  -44.663553 2026-06-11 08:55:54
#> 16: finished -5.88500581 -0.9916228  -56.206896 2026-06-11 08:55:54
#> 17: finished  4.08136954  3.9785972  -43.032918 2026-06-11 08:55:54
#> 18: finished -7.80489880 -3.6260806  -86.528017 2026-06-11 08:55:54
#> 19: finished -9.37102033 -3.4632716 -119.514724 2026-06-11 08:55:54
#> 20: finished  5.22167868  0.7561287  -14.487716 2026-06-11 08:55:54
#>        state          x1         x2           y        timestamp_xs
#>       <char>       <num>      <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:53
#>  2: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:53
#>  3: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:53
#>  4: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>  5: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>  6: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>  7: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>  8: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>  9: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 10: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 11: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 12: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 13: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 14: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 15: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 16: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 17: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 18: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 19: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#> 20: artsycraftsy_easteuropeanshepherd 2026-06-11 08:55:54
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: ab5202f6-adee-4575-9665-e04042c2d014 -6.21358293   0.2769503
#>  2: 1b03a7b9-62dd-48a0-974a-e54c9d7e78d7 -2.62264757   4.2779729
#>  3: f52345db-9653-4b88-abe8-6ffefd607408  6.84682656   3.2309502
#>  4: c14229b9-c415-4e37-b53f-de8dcfe0dfab -1.96786549  -3.4438612
#>  5: 315967f7-1f7b-4aab-80ed-2edb967d70b4 -9.86571338   2.5243351
#>  6: a203da9a-6f52-4bb5-b48b-438a7ef039c7  0.01208465   3.1304511
#>  7: a70c8b76-5067-4736-8bdc-3e83c9a15301 -4.77998488   1.4299587
#>  8: c4343fb9-4b4a-4718-979b-d331201b5236  7.57503606   1.3830058
#>  9: 55489c5c-1a31-4468-94db-09651b8ff0ad  8.01326577  -2.8537699
#> 10: 6eea0c28-72dd-4717-88bc-a6e6e0c2d065  5.39871055   2.9134685
#> 11: 40802c29-1f97-4a89-8769-e030d724d52c  4.82894640  -0.2106949
#> 12: 2b1cb509-08df-4d8b-9584-78db5a9d0ca0  2.92831418  -0.4491262
#> 13: ba46e866-6214-4379-9418-3d51ea4703c8 -2.48881904   1.6091926
#> 14: 3cd4570c-753c-47f5-a257-f2aa9a78cd2c  2.11332211   1.0427817
#> 15: 119e2d53-b44f-4d48-acc9-dc02fc8314da  0.87403046   4.3072392
#> 16: faae38a7-a187-42b5-afe4-ef46cf06a60c -5.88500581  -0.9916228
#> 17: 54d80bc7-e0e7-4c90-9bcb-e75275189d6e  4.08136954   3.9785972
#> 18: 95e57a3c-4807-458a-80c7-9c81e8f5a464 -7.80489880  -3.6260806
#> 19: e217cec5-b80d-438f-93f4-0a70a4740b9e -9.37102033  -3.4632716
#> 20: 6f7a82c8-273c-4b0d-bddd-752c44d1defe  5.22167868   0.7561287
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
