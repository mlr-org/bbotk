# mlr3fselect

<details>

* Version: 0.4.1
* GitHub: https://github.com/mlr-org/mlr3fselect
* Source code: https://github.com/cran/mlr3fselect
* Date/Publication: 2020-10-30 05:20:02 UTC
* Number of recursive dependencies: 55

Run `revdep_details(, "mlr3fselect")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘mlr3fselect-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: AutoFSelector
    > ### Title: AutoFSelector
    > ### Aliases: AutoFSelector
    > 
    > ### ** Examples
    > 
    > library(mlr3)
    ...
    > terminator = trm("evals", n_evals = 3)
    > fselector = fs("exhaustive_search")
    > afs = AutoFSelector$new(learner, resampling, measure, terminator, fselector,
    +   store_fselect_instance = TRUE)
    > 
    > afs$train(task)
    Error in private$.objective_multiplicator <- ifelse(self$objective$codomain$tags ==  : 
      cannot add bindings to a locked environment
    Calls: <Anonymous> ... initialize -> .__FSelectInstanceSingleCrit__initialize
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       2.   └─FSelectInstanceSingleCrit$new(...) helper.R:60:2
       3.     └─mlr3fselect:::initialize(...)
       4.       └─mlr3fselect:::.__FSelectInstanceSingleCrit__initialize(...)
      ── Error (test_FSelectorRandomSearch.R:13:3): FSelectorRandomSearch works with multi-crit ──
      Error: cannot add bindings to a locked environment
      Backtrace:
          █
       1. └─mlr3fselect:::test_fselector_2D(...) test_FSelectorRandomSearch.R:13:2
       2.   └─FSelectInstanceMultiCrit$new(...) helper.R:109:2
       3.     └─mlr3fselect:::initialize(...)
       4.       └─mlr3fselect:::.__FSelectInstanceMultiCrit__initialize(...)
      
      [ FAIL 16 | WARN 0 | SKIP 8 | PASS 17 ]
      Error: Test failures
      Execution halted
    ```

# mlr3tuning

<details>

* Version: 0.5.0
* GitHub: https://github.com/mlr-org/mlr3tuning
* Source code: https://github.com/cran/mlr3tuning
* Date/Publication: 2020-12-07 21:50:02 UTC
* Number of recursive dependencies: 57

Run `revdep_details(, "mlr3tuning")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘mlr3tuning-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: TuningInstanceSingleCrit
    > ### Title: Single Criterion Tuning Instance
    > ### Aliases: TuningInstanceSingleCrit
    > 
    > ### ** Examples
    > 
    > library(data.table)
    ...
    INFO  [14:39:24.691] [bbotk]    x classif.ce                                uhash 
    INFO  [14:39:24.691] [bbotk]  0.2  0.6179849 12be3ad5-5b06-432e-8737-9b670bc56e05 
    INFO  [14:39:24.691] [bbotk]  0.4  0.6179849 840cc2cd-83bc-4cf9-9549-b9c9597edad1 
    INFO  [14:39:24.691] [bbotk]  0.6  0.6575330 a30cf725-feca-436c-8a0a-95bb73ef061a 
    INFO  [14:39:24.691] [bbotk]  0.8  0.6682674 6ffb8839-86cc-4961-8af6-e874f6db10f6 
    INFO  [14:39:24.691] [bbotk]  1.0  0.6179849 ba590a86-0dd2-485b-9c58-2cedaff7e1b5 
    > 
    > archive = inst$archive$data()
    Error: attempt to apply non-function
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       2.   └─checkmate::checkDataTable(...)
      ── Error (test_TuningInstanceSingleCrit.R:139:3): store_benchmark_result and store_models flag works ──
      Error: attempt to apply non-function
      Backtrace:
          █
       1. ├─testthat::expect_true("uhashes" %nin% colnames(inst$archive$data()))
       2. │ └─testthat::quasi_label(enquo(object), label, arg = "object")
       3. │   └─rlang::eval_bare(expr, quo_get_env(quo))
       4. ├─"uhashes" %nin% colnames(inst$archive$data())
       5. └─base::colnames(inst$archive$data())
       6.   └─base::is.data.frame(x)
      
      [ FAIL 25 | WARN 0 | SKIP 0 | PASS 196 ]
      Error: Test failures
      Execution halted
    ```

