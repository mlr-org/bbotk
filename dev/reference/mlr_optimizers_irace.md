# Iterated Racing

`OptimizerBatchIrace` class that implements iterated racing. Calls
[`irace::irace()`](https://mlopez-ibanez.github.io/irace/reference/irace.html)
from package [irace](https://CRAN.R-project.org/package=irace).

## Source

Lopez-Ibanez M, Dubois-Lacoste J, Caceres LP, Birattari M, Stuetzle T
(2016). “The irace package: Iterated racing for automatic algorithm
configuration.” *Operations Research Perspectives*, **3**, 43–58.
[doi:10.1016/j.orp.2016.09.002](https://doi.org/10.1016/j.orp.2016.09.002)
.

## Parameters

- `instances`:

  [`list()`](https://rdrr.io/r/base/list.html)  
  A list of instances where the configurations executed on.

- `targetRunnerParallel`:

  `function()`  
  A function that executes the objective function with a specific
  parameter configuration and instance. A default function is provided,
  see section "Target Runner and Instances".

For the meaning of all other parameters, see
[`irace::defaultScenario()`](https://mlopez-ibanez.github.io/irace/reference/defaultScenario.html).

## Internal Termination Parameters

The algorithm can terminated with
[TerminatorEvals](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md).
Other
[Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)s do
not work with `OptimizerBatchIrace`. Additionally, the following
internal termination parameters can be used:

- `maxExperiments`:

  `integer(1)`  
  Maximum number of runs (invocations of targetRunner) that will be
  performed. It determines the maximum budget of experiments for the
  tuning. Default is 0.

- `minExperiments`:

  `integer(1)`  
  Minimum number of runs (invocations of targetRunner) that will be
  performed. It determines the minimum budget of experiments for the
  tuning. The actual budget depends on the number of parameters and
  minSurvival. Default is NA.

- `maxTime`:

  `integer(1)`  
  Maximum total execution time for the executions of targetRunner.
  targetRunner must return two values: cost and time. This value and the
  one returned by targetRunner must use the same units (seconds,
  minutes, iterations, evaluations, ...). Default is 0.

- `budgetEstimation`:

  `numeric(1)`  
  Fraction (smaller than 1) of the budget used to estimate the mean
  computation time of a configuration. Only used when maxTime \> 0
  Default is 0.05.

- `minMeasurableTime`:

  `numeric(1)`  
  Minimum time unit that is still (significantly) measurable. Default is
  0.01.

## Initial parameter values

- `digits`:

  - Adjusted default: 15.

  - This represents double parameters with a higher precision and avoids
    rounding errors.

## Target Runner and Instances

The irace package uses a `targetRunner` script or R function to evaluate
a configuration on a particular instance. Usually it is not necessary to
specify a `targetRunner` function when using `OptimizerBatchIrace`. A
default function is used that forwards several configurations and
instances to the user defined objective function. As usually, the user
defined function has a `xs`, `xss` or `xdt` parameter depending on the
used [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md)
class. For irace, the function needs an additional `instances`
parameter.

    fun = function(xs, instances) {
     # function to evaluate configuration in `xs` on instance `instances`
    }

## Archive

The [Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md) holds
the following additional columns:

- `"race"` (`integer(1)`)  
  Race iteration.

- `"step"` (`integer(1)`)  
  Step number of race.

- `"instance"` (`integer(1)`)  
  Identifies instances across races and steps.

- `"configuration"` (`integer(1)`)  
  Identifies configurations across races and steps.

## Result

The optimization result (`instance$result`) is the best performing elite
of the final race. The reported performance is the average performance
estimated on all used instances.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("irace")
    opt("irace")

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchIrace`

## Methods

### Public methods

- [`OptimizerBatchIrace$new()`](#method-OptimizerBatchIrace-initialize)

- [`OptimizerBatchIrace$clone()`](#method-OptimizerBatchIrace-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchIrace$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchIrace$new()

------------------------------------------------------------------------

### `OptimizerBatchIrace$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchIrace$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if irace is available
if (mlr3misc::require_namespaces("irace", quietly = TRUE)) {
# runtime of the example is too long
# \donttest{
library(data.table)

# set domain
domain = ps(
  x1 = p_dbl(-5, 10),
  x2 = p_dbl(0, 15)
)

# set codomain
codomain = ps(y = p_dbl(tags = "minimize"))

# branin function with noise
# the noise generates different instances of the branin function
# the noise values are passed via the `instances` parameter
fun = function(xdt, instances) {
  ys = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances))
  data.table(y = ys)
}

# define objective with instances as a constant
objective = ObjectiveRFunDt$new(
 fun = fun,
 domain = domain,
 codomain = codomain,
 constants = ps(instances = p_uty()))

instance = oi(
  objective = objective,
  terminator = trm("evals", n_evals = 96))

# create instances of branin function
instances = rnorm(10, mean = 0, sd = 0.1)

# load optimizer and set branin instances
optimizer = opt("irace", instances = instances)

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$result
# }
}
#> 
#> Attaching package: ‘data.table’
#> The following object is masked from ‘package:base’:
#> 
#>     %notin%
#> # 2026-09-03 11:36:46 UTC: Initialization
#> # Elitist race
#> # Elitist new instances: 1
#> # Elitist limit: 2
#> # nbIterations: 3
#> # minNbSurvival: 3
#> # nbParameters: 2
#> # seed: 357536202
#> # confidence level: 0.95
#> # budget: 96
#> # mu: 5
#> # deterministic: FALSE
#> 
#> # 2026-09-03 11:36:47 UTC: Iteration 1 of 3
#> # experimentsUsed: 0
#> # remainingBudget: 96
#> # currentBudget: 32
#> # nbConfigurations: 5
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          1|          5|          1|     3.784857955|          5|00:00:00|   NA|  NA|    NA|
#> |x|          2|          5|          1|     3.784857955|         10|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          5|          1|     3.784857955|         15|00:00:00|+1.00|1.00|0.0000|
#> |x|          4|          5|          1|     3.784857955|         20|00:00:00|+1.00|1.00|0.0000|
#> |-|          5|          1|          1|     3.784857955|         25|00:00:00|   NA|  NA|    NA|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:           1    mean value:      3.784857955
#> Description of the best-so-far configuration:
#>   .ID.                x1               x2 .PARENT.
#> 1    1 -2.84526661038399 9.85127627849579       NA
#> 
#> # 2026-09-03 11:36:47 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                  x1               x2
#> 1 -2.84526661038399 9.85127627849579
#> # 2026-09-03 11:36:47 UTC: Iteration 2 of 3
#> # experimentsUsed: 25
#> # remainingBudget: 71
#> # currentBudget: 35
#> # nbConfigurations: 5
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          6|          5|          6|     3.379337853|          5|00:00:00|   NA|  NA|    NA|
#> |x|          5|          5|          6|     3.379337853|          9|00:00:00|+1.00|1.00|0.0000|
#> |x|          1|          5|          6|     3.379337853|         13|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          5|          6|     3.379337853|         17|00:00:00|+1.00|1.00|0.0000|
#> |-|          4|          2|          6|     3.379337853|         21|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best configuration for the instances in this race: 6
#> Best-so-far configuration:           1    mean value:      3.784857955
#> Description of the best-so-far configuration:
#>   .ID.                x1               x2 .PARENT.
#> 1    1 -2.84526661038399 9.85127627849579       NA
#> 
#> # 2026-09-03 11:36:47 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                  x1                x2
#> 1 -2.84526661038399  9.85127627849579
#> 6 -2.86538501270542 10.00319424243212
#> # 2026-09-03 11:36:47 UTC: Iteration 3 of 3
#> # experimentsUsed: 46
#> # remainingBudget: 50
#> # currentBudget: 50
#> # nbConfigurations: 7
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          7|          7|         13|     2.859699541|          7|00:00:00|   NA|  NA|    NA|
#> |x|          3|          7|         13|     2.859699541|         12|00:00:00|+1.00|1.00|0.0000|
#> |x|          1|          7|         13|     2.859699541|         17|00:00:00|+1.00|1.00|0.0000|
#> |x|          6|          7|         13|     2.859699541|         22|00:00:00|+1.00|1.00|0.0000|
#> |-|          2|          3|         13|     2.859699541|         28|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best configuration for the instances in this race: 13
#> Best-so-far configuration:           6    mean value:      3.379337853
#> Description of the best-so-far configuration:
#>   .ID.                x1               x2 .PARENT.
#> 6    6 -2.86538501270542 10.0031942424321        1
#> 
#> # 2026-09-03 11:36:48 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                   x1                x2
#> 6  -2.86538501270542 10.00319424243212
#> 1  -2.84526661038399  9.85127627849579
#> 13 -2.92386521573537 10.26284282978285
#> # 2026-09-03 11:36:48 UTC: Iteration 4 of 4
#> # experimentsUsed: 74
#> # remainingBudget: 22
#> # currentBudget: 22
#> # nbConfigurations: 4
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          8|          4|         15|     1.562648737|          4|00:00:00|   NA|  NA|    NA|
#> |x|          1|          4|         15|     1.562648737|          5|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          4|         15|     1.562648737|          6|00:00:00|+1.00|1.00|0.0000|
#> |x|          2|          4|         15|     1.562648737|          7|00:00:00|+1.00|1.00|0.0000|
#> |!|          6|          4|         15|     1.562648737|          8|00:00:00|+1.00|1.00|0.0000|
#> |-|          7|          3|         15|     1.562648737|          9|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best configuration for the instances in this race: 15
#> Best-so-far configuration:           6    mean value:      3.379337853
#> Description of the best-so-far configuration:
#>   .ID.                x1               x2 .PARENT.
#> 6    6 -2.86538501270542 10.0031942424321        1
#> 
#> # 2026-09-03 11:36:48 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                   x1                x2
#> 6  -2.86538501270542 10.00319424243212
#> 1  -2.84526661038399  9.85127627849579
#> 15 -2.64584757705824 11.02151139618902
#> # 2026-09-03 11:36:48 UTC: Iteration 5 of 5
#> # experimentsUsed: 83
#> # remainingBudget: 13
#> # currentBudget: 13
#> # nbConfigurations: 4
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          7|          4|         15|     1.562648737|          1|00:00:00|   NA|  NA|    NA|
#> |x|          2|          4|         15|     1.562648737|          2|00:00:00|+1.00|1.00|0.0000|
#> |x|          1|          4|         15|     1.562648737|          3|00:00:00|+1.00|1.00|0.0000|
#> |x|          5|          4|         15|     1.562648737|          5|00:00:00|+1.00|1.00|0.0000|
#> |-|          4|          3|         15|     1.562648737|          7|00:00:00|+1.00|1.00|0.0000|
#> |.|          3|          3|         15|     1.562648737|          7|00:00:00|+1.00|1.00|0.0000|
#> |.|          8|          3|         15|     1.562648737|          7|00:00:00|+1.00|1.00|0.0000|
#> |.|          6|          3|         15|     1.562648737|          7|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:          15    mean value:      1.562648737
#> Description of the best-so-far configuration:
#>    .ID.                x1              x2 .PARENT.
#> 15   15 -2.64584757705824 11.021511396189        6
#> 
#> # 2026-09-03 11:36:48 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                   x1                x2
#> 15 -2.64584757705824 11.02151139618902
#> 6  -2.86538501270542 10.00319424243212
#> 1  -2.84526661038399  9.85127627849579
#> # 2026-09-03 11:36:48 UTC: Stopped because there is not enough budget left to race more than the minimum (3).
#> # You may either increase the budget or set 'minNbSurvival' to a lower value.
#> # Iteration: 6
#> # nbIterations: 6
#> # experimentsUsed: 90
#> # timeUsed: 0
#> # remainingBudget: 6
#> # currentBudget: 6
#> # number of elites: 3
#> # nbConfigurations: 3
#> # Total CPU user time: 2.008, CPU sys time: 0.011, Wall-clock time: 2.019
#> # 2026-09-03 11:36:49 UTC: Starting post-selection:
#> # Configurations selected: 15, 6, 1, 13.
#> # Pending instances: 1, 1, 1, 3.
#> # 2026-09-03 11:36:49 UTC: seed: 357536202
#> # Configurations: 4
#> # Available experiments: 6
#> # minSurvival: 1
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . Alive configurations were already evaluated on this instance and nothing is discarded.
#>      : All alive configurations are elite, but some need to be evaluated on this instance.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |.|          7|          4|         15|     1.562648737|          0|00:00:00|   NA|  NA|    NA|
#> |.|          6|          4|         15|     1.562648737|          0|00:00:00|+1.00|1.00|0.0000|
#> |.|          2|          4|         15|     1.562648737|          0|00:00:00|+1.00|1.00|0.0000|
#> |.|          8|          4|         15|     1.562648737|          0|00:00:00|+1.00|1.00|0.0000|
#> |.|          1|          4|         15|     1.562648737|          0|00:00:00|+1.00|1.00|0.0000|
#> |.|          3|          4|         15|     1.562648737|          0|00:00:00|+1.00|1.00|0.0000|
#> |x|          5|          4|         15|     1.562648737|          1|00:00:00|+1.00|1.00|0.0000|
#> |-|          4|          1|         15|     1.562648737|          2|00:00:00|   NA|  NA|    NA|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:          15    mean value:      1.562648737
#> Description of the best-so-far configuration:
#>    .ID.                x1              x2 .PARENT.
#> 15   15 -2.64584757705824 11.021511396189        6
#> 
#> # 2026-09-03 11:36:49 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                   x1              x2
#> 15 -2.64584757705824 11.021511396189
#> # Total CPU user time: 2.296, CPU sys time: 0.012, Wall-clock time: 2.308
#>           x1       x2 configuration  x_domain        y
#>        <num>    <num>         <int>    <list>    <num>
#> 1: -2.645848 11.02151            15 <list[2]> 1.562649
```
