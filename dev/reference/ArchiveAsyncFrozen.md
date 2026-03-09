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
rush::rush_plan(worker_type = "remote")
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
#>        state          x1          x2           y        timestamp_xs   pid
#>       <char>       <num>       <num>       <num>              <POSc> <int>
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-03-09 09:06:52 16086
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-03-09 09:06:52 16086
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-03-09 09:06:52 16086
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-03-09 09:06:52 16086
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-03-09 09:06:52 16086
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-03-09 09:06:52 16086
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-03-09 09:06:52 16086
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-03-09 09:06:52 16086
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-03-09 09:06:52 16086
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-03-09 09:06:52 16086
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-03-09 09:06:52 16086
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-03-09 09:06:52 16086
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-03-09 09:06:52 16086
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-03-09 09:06:52 16086
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-03-09 09:06:52 16086
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-03-09 09:06:52 16086
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-03-09 09:06:52 16086
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-03-09 09:06:52 16086
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-03-09 09:06:53 16086
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-03-09 09:06:53 16086
#>        state          x1          x2           y        timestamp_xs   pid
#>       <char>       <num>       <num>       <num>              <POSc> <int>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  2: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  3: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  4: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  5: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  6: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  7: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  8: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#>  9: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 10: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 11: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 12: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 13: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 14: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 15: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 16: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 17: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 18: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:52
#> 19: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:53
#> 20: artsycraftsy_easteuropeanshepherd 2026-03-09 09:06:53
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 0770f180-f52a-4bd8-93e6-331c01f4c26f  0.79964108  4.44173718
#>  2: 981b0903-520a-44fb-8999-6f9e52f78192  1.97171934  0.98977706
#>  3: b14d6c9c-574b-4c9c-a48d-97d91d4e1c83 -8.74678495  2.85974125
#>  4: beebf12e-9d7c-425e-8cbb-41cc8a5a2ed5 -8.86620125 -0.52683197
#>  5: 0569598f-d9ed-4f4d-a81d-6277ea1c0fa8  0.07174052  2.66149936
#>  6: 5c84c571-0d28-4d7f-8637-3030ba0cde7b -7.51773958 -3.62287586
#>  7: 4116e809-5e1c-48ae-acbe-cb44ab133ffc  5.70333065 -4.08089324
#>  8: 24129e90-075b-4259-9e8c-5eae40f6d5d3 -6.10767685  3.07812258
#>  9: 7ecf1318-aa2f-4ba5-8de4-182eaaa8546c  9.84218962  4.26953198
#> 10: 8a7e3a3c-a3f8-4459-802e-2b87ebb65b9a -9.43527839  3.90120726
#> 11: 44f2cd51-0d67-4bca-bb5a-a028eb01b87f  7.50436097 -0.05695712
#> 12: fa72acdc-9b6c-4921-83f5-8c68358dfebf -0.84870267 -1.03129050
#> 13: 976a01a6-2f1e-4054-8f54-29f35df9d375 -0.03656525  0.22023930
#> 14: 9b8472d7-10a8-41cd-adba-f9c1cd98b772 -8.26350117  0.25491344
#> 15: fb09f648-2445-4a12-9a79-0a2bda396248 -2.40412588 -0.01124492
#> 16: b8c2e1ef-e3b1-4426-9f82-322cbd9503e7  2.25513226  4.70309719
#> 17: f2f145c8-c432-4f96-b708-f86a134e1347 -6.33460185 -3.98131188
#> 18: cee3e770-0f65-4928-a347-36ef2e9428c9 -7.94145157 -0.13848943
#> 19: 2dd38e32-06ab-4791-b4d9-7e1efbb7398f -9.00099977  2.14240782
#> 20: 21484570-3be4-4326-906f-318e6eb33b6e -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
