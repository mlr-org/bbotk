# Data Table Storage

The `ArchiveBatch` stores all evaluated points and performance scores in
a
[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

## S3 Methods

- `as.data.table(archive)`  
  ArchiveBatch -\>
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Returns a tabular view of all performed function calls of the
  Objective. The `x_domain` column is unnested to separate columns.

## Super class

[`bbotk::Archive`](https://bbotk.mlr-org.com/reference/Archive.md) -\>
`ArchiveBatch`

## Public fields

- `data`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Contains all performed
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md) function
  calls.

- `data_extra`:

  (named `list`)  
  Data created by specific
  [`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)s that
  does not relate to any individual function evaluation and can
  therefore not be held in `$data`. Every optimizer should create and
  refer to its own entry in this list, named by its
  [`class()`](https://rdrr.io/r/base/class.html).

## Active bindings

- `n_evals`:

  (`integer(1)`)  
  Number of evaluations stored in the archive.

- `n_batch`:

  (`integer(1)`)  
  Number of batches stored in the archive.

## Methods

### Public methods

- [`ArchiveBatch$new()`](#method-ArchiveBatch-new)

- [`ArchiveBatch$add_evals()`](#method-ArchiveBatch-add_evals)

- [`ArchiveBatch$best()`](#method-ArchiveBatch-best)

- [`ArchiveBatch$nds_selection()`](#method-ArchiveBatch-nds_selection)

- [`ArchiveBatch$clear()`](#method-ArchiveBatch-clear)

- [`ArchiveBatch$clone()`](#method-ArchiveBatch-clone)

Inherited methods

- [`bbotk::Archive$format()`](https://bbotk.mlr-org.com/reference/Archive.html#method-format)
- [`bbotk::Archive$help()`](https://bbotk.mlr-org.com/reference/Archive.html#method-help)
- [`bbotk::Archive$print()`](https://bbotk.mlr-org.com/reference/Archive.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ArchiveBatch$new(search_space, codomain, check_values = FALSE)

#### Arguments

- `search_space`:

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

- `codomain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies codomain of function. Most importantly the tags of each
  output "Parameter" define whether it should be minimized or maximized.
  The default is to minimize each component.

- `check_values`:

  (`logical(1)`)  
  Should x-values that are added to the archive be checked for validity?
  Search space that is logged into archive.

------------------------------------------------------------------------

### Method `add_evals()`

Adds function evaluations to the archive table.

#### Usage

    ArchiveBatch$add_evals(xdt, xss_trafoed = NULL, ydt)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `xss_trafoed`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Transformed point(s) in the *domain space*.

- `ydt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Optimal outcome.

------------------------------------------------------------------------

### Method `best()`

Returns the best scoring evaluation(s). For single-crit optimization,
the solution that minimizes / maximizes the objective function. For
multi-crit optimization, the Pareto set / front.

#### Usage

    ArchiveBatch$best(batch = NULL, n_select = 1L, ties_method = "first")

#### Arguments

- `batch`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The batch number(s) to limit the best results to. Default is all
  batches.

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

[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)

------------------------------------------------------------------------

### Method [`nds_selection()`](https://bbotk.mlr-org.com/reference/nds_selection.md)

Calculate best points w.r.t. non dominated sorting with hypervolume
contribution.

#### Usage

    ArchiveBatch$nds_selection(batch = NULL, n_select = 1, ref_point = NULL)

#### Arguments

- `batch`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  The batch number(s) to limit the best points to. Default is all
  batches.

- `n_select`:

  (`integer(1L)`)  
  Amount of points to select.

- `ref_point`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Reference point for hypervolume.

#### Returns

[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)

------------------------------------------------------------------------

### Method `clear()`

Clear all evaluation results from archive.

#### Usage

    ArchiveBatch$clear()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ArchiveBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
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
optimizer = opt("random_search")

# trigger optimization
optimizer$optimize(instance)
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 4.706392 -3.040433 <list[2]> 2.673808

# all evaluated configuration
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:  -2.2  4.76   -68 2025-11-26 11:03:44        1        -2.2        4.76
#>  2:  -4.2  1.78   -51 2025-11-26 11:03:44        2        -4.2        1.78
#>  3:   4.7 -3.04     3 2025-11-26 11:03:44        3         4.7       -3.04
#>  4:   9.6  2.42   -77 2025-11-26 11:03:44        4         9.6        2.42
#>  5:  -9.0  0.30  -121 2025-11-26 11:03:44        5        -9.0        0.30
#>  6:   3.9  1.89   -18 2025-11-26 11:03:44        6         3.9        1.89
#>  7:  -9.4 -2.74  -119 2025-11-26 11:03:44        7        -9.4       -2.74
#>  8:  -4.0  1.36   -45 2025-11-26 11:03:44        8        -4.0        1.36
#>  9:  -0.4 -0.68    -1 2025-11-26 11:03:44        9        -0.4       -0.68
#> 10:   4.1  4.49   -51 2025-11-26 11:03:44       10         4.1        4.49
#> 11:  -6.4 -2.83   -60 2025-11-26 11:03:44       11        -6.4       -2.83
#> 12:   3.6 -0.01    -2 2025-11-26 11:03:44       12         3.6       -0.01
#> 13:   2.8  1.60   -12 2025-11-26 11:03:44       13         2.8        1.60
#> 14:  -8.1  2.66  -124 2025-11-26 11:03:44       14        -8.1        2.66
#> 15:   5.4  4.91   -64 2025-11-26 11:03:44       15         5.4        4.91
#> 16:   9.4 -1.11   -48 2025-11-26 11:03:44       16         9.4       -1.11
#> 17:  -0.8 -1.85     1 2025-11-26 11:03:44       17        -0.8       -1.85
#> 18:  -6.5  0.32   -73 2025-11-26 11:03:44       18        -6.5        0.32
#> 19:  -0.1  2.79   -28 2025-11-26 11:03:44       19        -0.1        2.79
#> 20:  -5.9  2.13   -79 2025-11-26 11:03:44       20        -5.9        2.13
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2

# best performing configuration
instance$archive$best()
#>          x1        x2        y  x_domain           timestamp batch_nr
#>       <num>     <num>    <num>    <list>              <POSc>    <int>
#> 1: 4.706392 -3.040433 2.673808 <list[2]> 2025-11-26 11:03:44        3

# covert to data.table
as.data.table(instance$archive)
#>             x1          x2            y           timestamp batch_nr
#>          <num>       <num>        <num>              <POSc>    <int>
#>  1: -2.2259737  4.75547835  -68.0062985 2025-11-26 11:03:44        1
#>  2: -4.2021541  1.78380427  -51.3514987 2025-11-26 11:03:44        2
#>  3:  4.7063920 -3.04043267    2.6738077 2025-11-26 11:03:44        3
#>  4:  9.6107935  2.41521529  -77.2487342 2025-11-26 11:03:44        4
#>  5: -8.9710745  0.30212464 -121.2685022 2025-11-26 11:03:44        5
#>  6:  3.9164776  1.88556003  -17.5415832 2025-11-26 11:03:44        6
#>  7: -9.3753935 -2.74437465 -119.4649214 2025-11-26 11:03:44        7
#>  8: -3.9833839  1.36465615  -44.8511059 2025-11-26 11:03:44        8
#>  9: -0.4195090 -0.67828742   -1.2443731 2025-11-26 11:03:44        9
#> 10:  4.1286768  4.48576576  -50.5679538 2025-11-26 11:03:44       10
#> 11: -6.3932246 -2.83100124  -60.4747804 2025-11-26 11:03:44       11
#> 12:  3.6032584 -0.01154389   -1.5013072 2025-11-26 11:03:44       12
#> 13:  2.8335870  1.60284349  -11.8810354 2025-11-26 11:03:44       13
#> 14: -8.0795168  2.65600164 -123.5870142 2025-11-26 11:03:44       14
#> 15:  5.3934961  4.90712312  -64.0384118 2025-11-26 11:03:44       15
#> 16:  9.4104181 -1.10817239  -48.4933075 2025-11-26 11:03:44       16
#> 17: -0.7762707 -1.84758248    0.9642548 2025-11-26 11:03:44       17
#> 18: -6.5064821  0.31573541  -73.3543394 2025-11-26 11:03:44       18
#> 19: -0.1272597  2.79308626  -28.0850822 2025-11-26 11:03:44       19
#> 20: -5.9164331  2.13397279  -79.0275903 2025-11-26 11:03:44       20
#>             x1          x2            y           timestamp batch_nr
#>     x_domain_x1 x_domain_x2
#>           <num>       <num>
#>  1:  -2.2259737  4.75547835
#>  2:  -4.2021541  1.78380427
#>  3:   4.7063920 -3.04043267
#>  4:   9.6107935  2.41521529
#>  5:  -8.9710745  0.30212464
#>  6:   3.9164776  1.88556003
#>  7:  -9.3753935 -2.74437465
#>  8:  -3.9833839  1.36465615
#>  9:  -0.4195090 -0.67828742
#> 10:   4.1286768  4.48576576
#> 11:  -6.3932246 -2.83100124
#> 12:   3.6032584 -0.01154389
#> 13:   2.8335870  1.60284349
#> 14:  -8.0795168  2.65600164
#> 15:   5.3934961  4.90712312
#> 16:   9.4104181 -1.10817239
#> 17:  -0.7762707 -1.84758248
#> 18:  -6.5064821  0.31573541
#> 19:  -0.1272597  2.79308626
#> 20:  -5.9164331  2.13397279
#>     x_domain_x1 x_domain_x2
```
