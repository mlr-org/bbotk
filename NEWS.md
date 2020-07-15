# bbotk 0.2

- First version of bbotk released on CRAN
- API change: `OptimInstance` becomes an abstract base class for
`OptimInstanceSingleCrit` and `OptimInstanceMultiCrit`.
- API change: `Objective$eval_checked()` and `Objective$eval_many_checked()` are
removed and replaced by the `check_values` flag.
- API change:  `$eval()` and `$eval_many()` are private methods.
- `OptimizerNloptr` based on `nloptr::nloptr` added.
- Vignette added.

# bbotk 0.1.1

- API Change: `OptimInstance$param_set` becomes `OptimInstance$search_space` to
avoid confusion as the `param_set` usually contains the parameters that change
the behaviour of the object.
- New `Objective` subclass: `ObjectiveRFunDt` allows to connect functions that
expect a `data.frame` as input.

# bbotk 0.1.0

- First version of the Black-Box Optimization Toolkit
