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

[`bbotk::Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md)
-\>
[`bbotk::ArchiveAsync`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
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

- [`ArchiveAsyncFrozen$new()`](#method-ArchiveAsyncFrozen-new)

- [`ArchiveAsyncFrozen$push_points()`](#method-ArchiveAsyncFrozen-push_points)

- [`ArchiveAsyncFrozen$pop_point()`](#method-ArchiveAsyncFrozen-pop_point)

- [`ArchiveAsyncFrozen$push_running_point()`](#method-ArchiveAsyncFrozen-push_running_point)

- [`ArchiveAsyncFrozen$push_result()`](#method-ArchiveAsyncFrozen-push_result)

- [`ArchiveAsyncFrozen$push_failed_point()`](#method-ArchiveAsyncFrozen-push_failed_point)

- [`ArchiveAsyncFrozen$data_with_state()`](#method-ArchiveAsyncFrozen-data_with_state)

- [`ArchiveAsyncFrozen$clear()`](#method-ArchiveAsyncFrozen-clear)

- [`ArchiveAsyncFrozen$clone()`](#method-ArchiveAsyncFrozen-clone)

Inherited methods

- [`bbotk::Archive$format()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-format)
- [`bbotk::Archive$help()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-help)
- [`bbotk::Archive$print()`](https://bbotk.mlr-org.com/dev/reference/Archive.html#method-print)
- [`bbotk::ArchiveAsync$best()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-best)
- [`bbotk::ArchiveAsync$nds_selection()`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.html#method-nds_selection)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveAsyncFrozen$new(archive)

#### Arguments

- `archive`:

  ([ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md))  
  The archive to freeze.

------------------------------------------------------------------------

### Method `push_points()`

Push queued points to the archive.

#### Usage

    ArchiveAsyncFrozen$push_points(xss)

#### Arguments

- `xss`:

  (list of named [`list()`](https://rdrr.io/r/base/list.html))  
  List of named lists of point values.

------------------------------------------------------------------------

### Method `pop_point()`

Pop a point from the queue.

#### Usage

    ArchiveAsyncFrozen$pop_point()

------------------------------------------------------------------------

### Method `push_running_point()`

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

### Method `push_result()`

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

### Method `push_failed_point()`

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

### Method `data_with_state()`

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

### Method `clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveAsyncFrozen$clear()

------------------------------------------------------------------------

### Method `clone()`

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
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-03-20 06:19:03
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-03-20 06:19:03
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-03-20 06:19:03
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-03-20 06:19:03
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-03-20 06:19:03
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-03-20 06:19:03
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-03-20 06:19:03
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-03-20 06:19:03
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-03-20 06:19:03
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-03-20 06:19:03
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-03-20 06:19:03
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-03-20 06:19:03
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-03-20 06:19:03
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-03-20 06:19:03
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-03-20 06:19:03
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-03-20 06:19:03
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-03-20 06:19:03
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-03-20 06:19:03
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-03-20 06:19:03
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-03-20 06:19:03
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  2: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  3: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  4: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  5: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  6: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  7: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  8: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>  9: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 10: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 11: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 12: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 13: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 14: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 15: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 16: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 17: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 18: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 19: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#> 20: artsycraftsy_easteuropeanshepherd 2026-03-20 06:19:03
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: d9255148-a462-472f-a9aa-790ebceee40c  0.79964108  4.44173718
#>  2: 16221a0c-ed01-40e2-9958-94ff7d9b59a9  1.97171934  0.98977706
#>  3: 4ff9b928-107f-48a1-8859-b35f7a4597a8 -8.74678495  2.85974125
#>  4: 26720be9-6e26-476d-91c2-c4a0055a111b -8.86620125 -0.52683197
#>  5: ab7b9a77-22ee-4958-b1f1-ef5d68f3721e  0.07174052  2.66149936
#>  6: c722876f-78eb-427f-9760-4b60c8b79487 -7.51773958 -3.62287586
#>  7: 22660a6b-7288-4172-93f4-80716f9be1bc  5.70333065 -4.08089324
#>  8: f4f21308-bb20-4efd-8384-9c8c81a13652 -6.10767685  3.07812258
#>  9: 85322945-a062-44af-8682-f354c0ccd2ef  9.84218962  4.26953198
#> 10: 10a3df63-508c-4aeb-9c9b-505e025fab47 -9.43527839  3.90120726
#> 11: bd3d7c83-d175-4694-93ea-17f96f29b97d  7.50436097 -0.05695712
#> 12: 44ef1225-b6e0-49d2-9c45-b04ad9680f66 -0.84870267 -1.03129050
#> 13: 05a454fd-f661-4c21-8f7c-8e1ea82bda8f -0.03656525  0.22023930
#> 14: caaba230-9039-457e-92d6-57cf99480738 -8.26350117  0.25491344
#> 15: dccf16cb-8e7c-4738-a08d-09f707e52eed -2.40412588 -0.01124492
#> 16: e2e03c72-e945-4e01-a10a-ea31871fd091  2.25513226  4.70309719
#> 17: cdfc1c69-ac5f-4ffd-9950-df314d84d4fa -6.33460185 -3.98131188
#> 18: a11b66c4-3e87-4b2b-818a-af1144d77620 -7.94145157 -0.13848943
#> 19: 2436fd1c-d106-4089-a621-adcd83d7128e -9.00099977  2.14240782
#> 20: 9c0efacf-9f65-41e8-a93c-ca16cc629d88 -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
