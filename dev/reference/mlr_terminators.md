# Dictionary of Terminators

A simple
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
storing objects of class
[Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Each terminator has an associated help page, see `mlr_terminators_[id]`.

This dictionary can get populated with additional terminators by add-on
packages.

For a more convenient way to retrieve and construct terminator, see
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md)/[`trms()`](https://bbotk.mlr-org.com/dev/reference/trm.md).

## Format

[R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) object
inheriting from
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html).

## Methods

See
[mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html).

## S3 methods

- `as.data.table(dict, ..., objects = FALSE)`  
  [mlr3misc::Dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  -\>
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Returns a
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  with fields "key", "label", "properties" and "unit" as columns. If
  `objects` is set to `TRUE`, the constructed objects are returned in
  the list column named `object`.

## See also

Sugar functions:
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md),
[`trms()`](https://bbotk.mlr-org.com/dev/reference/trm.md)

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)

## Examples

``` r
as.data.table(mlr_terminators)
#> Key: <key>
#>                       key                  label             properties
#>                    <char>                 <char>                 <list>
#> 1:             clock_time             Clock Time single-crit,multi-crit
#> 2:                  combo            Combination single-crit,multi-crit
#> 3:                  evals   Number of Evaluation single-crit,multi-crit
#> 4:                   none                   None single-crit,multi-crit
#> 5:           perf_reached      Performance Level            single-crit
#> 6:               run_time               Run Time single-crit,multi-crit
#> 7:             stagnation             Stagnation            single-crit
#> 8:       stagnation_batch       Stagnation Batch            single-crit
#> 9: stagnation_hypervolume Stagnation Hypervolume             multi-crit
#>           unit
#>         <char>
#> 1:     seconds
#> 2:     percent
#> 3: evaluations
#> 4:     percent
#> 5:     percent
#> 6:     seconds
#> 7:     percent
#> 8:     percent
#> 9:     percent
mlr_terminators$get("evals")
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=100, k=0
#> • Terminators:
trm("evals", n_evals = 10)
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=10, k=0
#> • Terminators:
```
