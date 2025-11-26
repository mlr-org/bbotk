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
[TerminatorEvals](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md).
Other [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)s
do not work with `OptimizerBatchIrace`. Additionally, the following
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
  Minimum time unit that is still (significantly) measureable. Default
  is 0.01.

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
used [Objective](https://bbotk.mlr-org.com/reference/Objective.md)
class. For irace, the function needs an additional `instances`
parameter.

    fun = function(xs, instances) {
     # function to evaluate configuration in `xs` on instance `instances`
    }

## Archive

The [Archive](https://bbotk.mlr-org.com/reference/Archive.md) holds the
following additional columns:

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

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("irace")
    opt("irace")

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
-\> `OptimizerBatchIrace`

## Methods

### Public methods

- [`OptimizerBatchIrace$new()`](#method-OptimizerBatchIrace-new)

- [`OptimizerBatchIrace$clone()`](#method-OptimizerBatchIrace-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchIrace$new()

------------------------------------------------------------------------

### Method `clone()`

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
#> # 2025-11-26 11:04:17 UTC: Initialization
#> # Elitist race
#> # Elitist new instances: 1
#> # Elitist limit: 2
#> # nbIterations: 3
#> # minNbSurvival: 3
#> # nbParameters: 2
#> # seed: 624162489
#> # confidence level: 0.95
#> # budget: 96
#> # mu: 5
#> # deterministic: FALSE
#> 
#> # 2025-11-26 11:04:18 UTC: Iteration 1 of 3
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
#>      . All alive configurations are elite and nothing is discarded.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          1|          5|          5|     18.55226488|          5|00:00:00|   NA|  NA|    NA|
#> |x|          2|          5|          5|     18.55226488|         10|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          5|          5|     18.55226488|         15|00:00:00|+1.00|1.00|0.0000|
#> |x|          4|          5|          5|     18.55226488|         20|00:00:00|+1.00|1.00|0.0000|
#> |-|          5|          1|          5|     18.55226488|         25|00:00:00|   NA|  NA|    NA|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:           5    mean value:      18.55226488
#> Description of the best-so-far configuration:
#>   .ID.               x1               x2 .PARENT.
#> 5    5 1.28557488322258 1.74866303801537       NA
#> 
#> # 2025-11-26 11:04:18 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                 x1               x2
#> 5 1.28557488322258 1.74866303801537
#> # 2025-11-26 11:04:18 UTC: Iteration 2 of 3
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
#>      . All alive configurations are elite and nothing is discarded.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          6|          5|          8|     3.515902613|          5|00:00:00|   NA|  NA|    NA|
#> |x|          4|          5|          8|     3.515902613|          9|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          5|          8|     3.515902613|         13|00:00:00|+1.00|1.00|0.0000|
#> |x|          5|          5|          8|     3.515902613|         17|00:00:00|+1.00|1.00|0.0000|
#> |-|          1|          2|          8|     3.515902613|         21|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best configuration for the instances in this race: 8
#> Best-so-far configuration:           5    mean value:      18.55226488
#> Description of the best-so-far configuration:
#>   .ID.               x1               x2 .PARENT.
#> 5    5 1.28557488322258 1.74866303801537       NA
#> 
#> # 2025-11-26 11:04:18 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                 x1               x2
#> 5 1.28557488322258 1.74866303801537
#> 8 3.70296034806964 3.16024788060649
#> # 2025-11-26 11:04:18 UTC: Iteration 3 of 3
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
#>      . All alive configurations are elite and nothing is discarded.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          7|          7|          8|     3.515902613|          7|00:00:00|   NA|  NA|    NA|
#> |x|          6|          7|          8|     3.515902613|         12|00:00:00|+1.00|1.00|0.0000|
#> |x|          5|          7|          8|     3.515902613|         17|00:00:00|+1.00|1.00|0.0000|
#> |x|          2|          7|          8|     3.515902613|         23|00:00:00|+1.00|1.00|0.0000|
#> |-|          1|          2|          8|     3.515902613|         28|00:00:00|+1.00|1.00|0.0000|
#> |.|          3|          2|          8|     3.515902613|         28|00:00:00|+1.00|1.00|0.0000|
#> |.|          4|          2|          8|     3.515902613|         28|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:           8    mean value:      3.515902613
#> Description of the best-so-far configuration:
#>   .ID.               x1               x2 .PARENT.
#> 8    8 3.70296034806964 3.16024788060649        5
#> 
#> # 2025-11-26 11:04:19 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                 x1               x2
#> 8 3.70296034806964 3.16024788060649
#> 5 1.28557488322258 1.74866303801537
#> # 2025-11-26 11:04:19 UTC: Iteration 4 of 4
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
#>      . All alive configurations are elite and nothing is discarded.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          8|          4|          8|     3.515902613|          4|00:00:00|   NA|  NA|    NA|
#> |x|          1|          4|          8|     3.515902613|          6|00:00:00|+1.00|1.00|0.0000|
#> |x|          5|          4|          8|     3.515902613|          8|00:00:00|+1.00|1.00|0.0000|
#> |x|          3|          4|          8|     3.515902613|         10|00:00:00|+1.00|1.00|0.0000|
#> |-|          2|          2|          8|     3.515902613|         12|00:00:00|+1.00|1.00|0.0000|
#> |.|          6|          2|          8|     3.515902613|         12|00:00:00|+1.00|1.00|0.0000|
#> |.|          4|          2|          8|     3.515902613|         12|00:00:00|+1.00|1.00|0.0000|
#> |.|          7|          2|          8|     3.515902613|         12|00:00:00|+1.00|1.00|0.0000|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:           8    mean value:      3.515902613
#> Description of the best-so-far configuration:
#>   .ID.               x1               x2 .PARENT.
#> 8    8 3.70296034806964 3.16024788060649        5
#> 
#> # 2025-11-26 11:04:19 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                 x1               x2
#> 8 3.70296034806964 3.16024788060649
#> 5 1.28557488322258 1.74866303801537
#> # 2025-11-26 11:04:19 UTC: Stopped because there is not enough budget left to race more than the minimum (3).
#> # You may either increase the budget or set 'minNbSurvival' to a lower value.
#> # Iteration: 5
#> # nbIterations: 5
#> # experimentsUsed: 86
#> # timeUsed: 0
#> # remainingBudget: 10
#> # currentBudget: 10
#> # number of elites: 2
#> # nbConfigurations: 3
#> # Total CPU user time: 1.562, CPU sys time: 0.009, Wall-clock time: 1.571
#> # 2025-11-26 11:04:19 UTC: Starting post-selection:
#> # Configurations selected: 8, 5, 1, 2.
#> # Pending instances: 1, 1, 4, 4.
#> # 2025-11-26 11:04:20 UTC: seed: 624162489
#> # Configurations: 4
#> # Available experiments: 10
#> # minSurvival: 1
#> # Markers:
#>      x No test is performed.
#>      c Configurations are discarded only due to capping.
#>      - The test is performed and some configurations are discarded.
#>      = The test is performed but no configuration is discarded.
#>      ! The test is performed and configurations could be discarded but elite configurations are preserved.
#>      . All alive configurations are elite and nothing is discarded.
#> 
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> | |   Instance|      Alive|       Best|       Mean best| Exp so far|  W time|  rho|KenW|  Qvar|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> |x|          6|          4|          8|     3.515902613|          2|00:00:00|   NA|  NA|    NA|
#> |.|          1|          4|          8|     3.515902613|          2|00:00:00|+1.00|1.00|0.0000|
#> |.|          2|          4|          8|     3.515902613|          2|00:00:00|+1.00|1.00|0.0000|
#> |.|          5|          4|          8|     3.515902613|          2|00:00:00|+1.00|1.00|0.0000|
#> |.|          3|          4|          8|     3.515902613|          2|00:00:00|+1.00|1.00|0.0000|
#> |.|          4|          4|          8|     3.515902613|          2|00:00:00|+1.00|1.00|0.0000|
#> |x|          8|          4|          8|     3.515902613|          4|00:00:00|+1.00|1.00|0.0000|
#> |-|          7|          1|          8|     3.515902613|          6|00:00:00|   NA|  NA|    NA|
#> +-+-----------+-----------+-----------+----------------+-----------+--------+-----+----+------+
#> Best-so-far configuration:           8    mean value:      3.515902613
#> Description of the best-so-far configuration:
#>   .ID.               x1               x2 .PARENT.
#> 8    8 3.70296034806964 3.16024788060649        5
#> 
#> # 2025-11-26 11:04:20 UTC: Elite configurations (first number is the configuration ID; listed from best to worst according to the sum of ranks):
#>                 x1               x2
#> 8 3.70296034806964 3.16024788060649
#> # Total CPU user time: 1.965, CPU sys time: 0.013, Wall-clock time: 1.978
#>         x1       x2 configuration  x_domain        y
#>      <num>    <num>         <int>    <list>    <num>
#> 1: 3.70296 3.160248             8 <list[2]> 3.515903
```
