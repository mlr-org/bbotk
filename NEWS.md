# bbotk 0.3.2.9000

* Allows empty search space and domain.
* Extended `TerminatorEvals` with an additional hyperparameter `k` to define the
  budget depending on the dimension of the search space.
* Adds `bb_optimize()` function for quick optimization.
* Adds `OptimizerIrace` from irace package.

# bbotk 0.3.2

* Internal changes.

# bbotk 0.3.1

* `OptimInstance$clear()` methods resets the instance.
* Prettier printing methods.
* Assert overlapping and reserved names in domain and codomain.

# bbotk 0.3.0

* Improved `TerminatorPerfRearched` documentation.
* Added `check_values` flag in `OptimInstance`, `OptimInstanceSingleCrit`,
  `OptimInstanceMultiCrit`, `ObjectiveRFun` and `ObjectiveRFunDt`.
* `Archive$data` is a public field now.
* Renamed `m` parameter to `batch` in `Archive$best()`.
* `ArchiveBest` stores no data but records the best scoring evaluation.
* Reduced runtime if `ObjectiveRFunDt` and a domain without trafo is used.
* `OptimizerDesignPoints` supports `ParamUty`.
* Start values for `OptimizerCmaes` and `OptimizerNloptr` are created randomly
  or from center of search space.
* `Optimizer$optimize()` supports progress bars via the package `progressr`.

# bbotk 0.2.2

* Removed dependency on orphaned package `bibtex`.
* Improved documentation.
* Added `OptimizerCmaes` from adagio package.

# bbotk 0.2.1

* Compact in-memory representation of R6 objects to save space when
  saving mlr3 objects via saveRDS(), serialize() etc.
* Warning and error messages if external package for optimization is
  not installed.

# bbotk 0.2

* First version of the Black-Box Optimization Toolkit
