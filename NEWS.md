# bbotk 0.3.0

* Improved `TerminatorPerfRearched` documentation.
* Added `check_values` flag in `OptimInstance`, `OptimInstanceSingleCrit`, 
  `OptimInstanceMultiCrit`, `ObjectiveRFun` and `ObjectiveRFunDt`.
* Renamed `m` parameter to `batch` in `Archive$best()`.
* `ArchiveBest` stores no data but records the best scoring evaluation.
* Reduced runtime if `ObjectiveRFunDt` and a domain without trafo is used.
* `OptimizerDesignPoints` supports `ParamUty`.
* Start values for `OptimizerCmaes` abd `OptimizerNloptr` are created randomly
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

