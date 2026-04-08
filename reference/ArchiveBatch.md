# Data Table Storage

The `ArchiveBatch` stores all evaluated points and performance scores in
a
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html).

## S3 Methods

- `as.data.table(archive)`  
  ArchiveBatch -\>
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Returns a tabular view of all performed function calls of the
  Objective. The `x_domain` column is unnested to separate columns.

## Super class

[`bbotk::Archive`](https://bbotk.mlr-org.com/reference/Archive.md) -\>
`ArchiveBatch`

## Public fields

- `data`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
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

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `xss_trafoed`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Transformed point(s) in the *domain space*.

- `ydt`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
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

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)

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

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)

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
#>  1:   4.7  2.73   -30 2026-04-08 06:02:39        1         4.7        2.73
#>  2:   7.5 -3.25   -20 2026-04-08 06:02:39        2         7.5       -3.25
#>  3:  -9.3 -1.80  -119 2026-04-08 06:02:39        3        -9.3       -1.80
#>  4:  -2.0 -3.04    -6 2026-04-08 06:02:39        4        -2.0       -3.04
#>  5:  -1.9 -4.36    -7 2026-04-08 06:02:39        5        -1.9       -4.36
#>  6:  -2.2  4.76   -68 2026-04-08 06:02:39        6        -2.2        4.76
#>  7:  -4.2  1.78   -51 2026-04-08 06:02:39        7        -4.2        1.78
#>  8:   4.7 -3.04     3 2026-04-08 06:02:39        8         4.7       -3.04
#>  9:   9.6  2.42   -77 2026-04-08 06:02:39        9         9.6        2.42
#> 10:  -9.0  0.30  -121 2026-04-08 06:02:39       10        -9.0        0.30
#> 11:   3.9  1.89   -18 2026-04-08 06:02:39       11         3.9        1.89
#> 12:  -9.4 -2.74  -119 2026-04-08 06:02:39       12        -9.4       -2.74
#> 13:  -4.0  1.36   -45 2026-04-08 06:02:39       13        -4.0        1.36
#> 14:  -0.4 -0.68    -1 2026-04-08 06:02:39       14        -0.4       -0.68
#> 15:   4.1  4.49   -51 2026-04-08 06:02:39       15         4.1        4.49
#> 16:  -6.4 -2.83   -60 2026-04-08 06:02:39       16        -6.4       -2.83
#> 17:   3.6 -0.01    -2 2026-04-08 06:02:39       17         3.6       -0.01
#> 18:   2.8  1.60   -12 2026-04-08 06:02:39       18         2.8        1.60
#> 19:  -8.1  2.66  -124 2026-04-08 06:02:39       19        -8.1        2.66
#> 20:   5.4  4.91   -64 2026-04-08 06:02:39       20         5.4        4.91
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$archive$best()
#>          x1        x2        y  x_domain           timestamp batch_nr
#>       <num>     <num>    <num>    <list>              <POSc>    <int>
#> 1: 4.706392 -3.040433 2.673808 <list[2]> 2026-04-08 06:02:39        8

# covert to data.table
as.data.table(instance$archive)
#>            x1          x2           y           timestamp batch_nr x_domain_x1
#>         <num>       <num>       <num>              <POSc>    <int>       <num>
#>  1:  4.657640  2.72521511  -29.841137 2026-04-08 06:02:39        1    4.657640
#>  2:  7.492013 -3.25059373  -20.225006 2026-04-08 06:02:39        2    7.492013
#>  3: -9.315173 -1.79614269 -119.482420 2026-04-08 06:02:39        3   -9.315173
#>  4: -1.953435 -3.04330165   -5.631525 2026-04-08 06:02:39        4   -1.953435
#>  5: -1.929238 -4.36338543   -7.297728 2026-04-08 06:02:39        5   -1.929238
#>  6: -2.225974  4.75547835  -68.006298 2026-04-08 06:02:39        6   -2.225974
#>  7: -4.202154  1.78380427  -51.351499 2026-04-08 06:02:39        7   -4.202154
#>  8:  4.706392 -3.04043267    2.673808 2026-04-08 06:02:39        8    4.706392
#>  9:  9.610793  2.41521529  -77.248734 2026-04-08 06:02:39        9    9.610793
#> 10: -8.971074  0.30212464 -121.268502 2026-04-08 06:02:39       10   -8.971074
#> 11:  3.916478  1.88556003  -17.541583 2026-04-08 06:02:39       11    3.916478
#> 12: -9.375393 -2.74437465 -119.464921 2026-04-08 06:02:39       12   -9.375393
#> 13: -3.983384  1.36465615  -44.851106 2026-04-08 06:02:39       13   -3.983384
#> 14: -0.419509 -0.67828742   -1.244373 2026-04-08 06:02:39       14   -0.419509
#> 15:  4.128677  4.48576576  -50.567954 2026-04-08 06:02:39       15    4.128677
#> 16: -6.393225 -2.83100124  -60.474780 2026-04-08 06:02:39       16   -6.393225
#> 17:  3.603258 -0.01154389   -1.501307 2026-04-08 06:02:39       17    3.603258
#> 18:  2.833587  1.60284349  -11.881035 2026-04-08 06:02:39       18    2.833587
#> 19: -8.079517  2.65600164 -123.587014 2026-04-08 06:02:39       19   -8.079517
#> 20:  5.393496  4.90712312  -64.038412 2026-04-08 06:02:39       20    5.393496
#>            x1          x2           y           timestamp batch_nr x_domain_x1
#>         <num>       <num>       <num>              <POSc>    <int>       <num>
#>     x_domain_x2
#>           <num>
#>  1:  2.72521511
#>  2: -3.25059373
#>  3: -1.79614269
#>  4: -3.04330165
#>  5: -4.36338543
#>  6:  4.75547835
#>  7:  1.78380427
#>  8: -3.04043267
#>  9:  2.41521529
#> 10:  0.30212464
#> 11:  1.88556003
#> 12: -2.74437465
#> 13:  1.36465615
#> 14: -0.67828742
#> 15:  4.48576576
#> 16: -2.83100124
#> 17: -0.01154389
#> 18:  1.60284349
#> 19:  2.65600164
#> 20:  4.90712312
#>     x_domain_x2
#>           <num>
```
