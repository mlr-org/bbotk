# bbotk 0.1.1

- API Change: `OptimInstance$param_set` becomes `OptimInstance$search_space` to avoid confusion as the `param_set` usually contains the parameters that change the behaviour of the object.
- New `Objective` subclass: `ObjectiveRFunDt` allows to connect functions that expect a `data.frame` as input.

# bbotk 0.1.0

- First version of the Black-Box Optimization Toolkit
