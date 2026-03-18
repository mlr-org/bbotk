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
#>  1: finished  0.79964108  4.44173718  -46.820314 2026-03-18 14:00:21
#>  2: finished  1.97171934  0.98977706   -5.919121 2026-03-18 14:00:21
#>  3: finished -8.74678495  2.85974125 -139.829954 2026-03-18 14:00:21
#>  4: finished -8.86620125 -0.52683197 -114.190890 2026-03-18 14:00:21
#>  5: finished  0.07174052  2.66149936  -25.770760 2026-03-18 14:00:21
#>  6: finished -7.51773958 -3.62287586  -80.975341 2026-03-18 14:00:21
#>  7: finished  5.70333065 -4.08089324   -4.882988 2026-03-18 14:00:22
#>  8: finished -6.10767685  3.07812258  -92.677998 2026-03-18 14:00:22
#>  9: finished  9.84218962  4.26953198 -104.346033 2026-03-18 14:00:22
#> 10: finished -9.43527839  3.90120726 -168.392253 2026-03-18 14:00:22
#> 11: finished  7.50436097 -0.05695712  -28.959491 2026-03-18 14:00:22
#> 12: finished -0.84870267 -1.03129050   -1.990924 2026-03-18 14:00:22
#> 13: finished -0.03656525  0.22023930   -4.517539 2026-03-18 14:00:22
#> 14: finished -8.26350117  0.25491344 -105.933918 2026-03-18 14:00:22
#> 15: finished -2.40412588 -0.01124492  -18.328982 2026-03-18 14:00:22
#> 16: finished  2.25513226  4.70309719  -49.402799 2026-03-18 14:00:22
#> 17: finished -6.33460185 -3.98131188  -60.428561 2026-03-18 14:00:22
#> 18: finished -7.94145157 -0.13848943  -97.020702 2026-03-18 14:00:22
#> 19: finished -9.00099977  2.14240782 -137.466354 2026-03-18 14:00:22
#> 20: finished -5.83602346 -2.01183452  -52.379735 2026-03-18 14:00:22
#>        state          x1          x2           y        timestamp_xs
#>       <char>       <num>       <num>       <num>              <POSc>
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>  1: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:21
#>  2: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:21
#>  3: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:21
#>  4: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:21
#>  5: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:21
#>  6: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#>  7: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#>  8: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#>  9: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 10: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 11: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 12: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 13: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 14: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 15: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 16: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 17: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 18: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 19: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#> 20: artsycraftsy_easteuropeanshepherd 2026-03-18 14:00:22
#>                             worker_id        timestamp_ys
#>                                <char>              <POSc>
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
#>  1: 49b57dc4-ff1c-410d-bb61-d1593e920b89  0.79964108  4.44173718
#>  2: 9b5e8da9-5517-4b91-b6ae-1781fedb1614  1.97171934  0.98977706
#>  3: 7437d736-4bee-4ec9-9829-f69d9aff414c -8.74678495  2.85974125
#>  4: 235e09df-923f-472c-a85c-d0dfe8effb41 -8.86620125 -0.52683197
#>  5: fe9af564-5743-4873-ba3b-de80f788fa87  0.07174052  2.66149936
#>  6: 090fd6d2-3da4-4b76-8f4b-af91046c29f3 -7.51773958 -3.62287586
#>  7: 74198808-2dee-4ce7-a98d-571815f15409  5.70333065 -4.08089324
#>  8: ef86096d-7d78-40e5-91dc-e242d68fe7bc -6.10767685  3.07812258
#>  9: 8fe52c28-f539-494f-a976-3e42fcfc9a53  9.84218962  4.26953198
#> 10: 8a456279-ffd8-4840-b746-611d552d9a47 -9.43527839  3.90120726
#> 11: 01c230e1-980e-44d0-bc44-54b94abcf111  7.50436097 -0.05695712
#> 12: 791aa882-5fc2-44da-8bb2-a9768b0d3a7b -0.84870267 -1.03129050
#> 13: 0af5e5ef-8be7-4d27-bc94-e79ff11ca14a -0.03656525  0.22023930
#> 14: 21f3ed12-8849-47be-a04c-56ce72b02908 -8.26350117  0.25491344
#> 15: de9c9cf7-e52a-4824-9310-cb9fdec15a1e -2.40412588 -0.01124492
#> 16: 87a8c94e-5b73-466b-82e8-5a0c686d1800  2.25513226  4.70309719
#> 17: a46ed716-41fd-4dbf-890d-1a90c689a45a -6.33460185 -3.98131188
#> 18: f082c062-8902-4909-ab73-805f24dfad91 -7.94145157 -0.13848943
#> 19: 6748ce69-6df5-4a9c-ac22-fdb7ebb3fc2b -9.00099977  2.14240782
#> 20: f518116a-9eef-4773-8f08-d126b3bc1531 -5.83602346 -2.01183452
#>                                     keys x_domain_x1 x_domain_x2
#>                                   <char>       <num>       <num>
```
