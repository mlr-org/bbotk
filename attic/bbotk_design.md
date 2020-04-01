

# BLABOT design

## `Objective`

`Objective` represents the "objective function" to be optimized. It should give information about valid input values ("domain"), output values ("codomain"), and meta-info.

### Abstract Base Class

`Objective` is an "abstract" class that does not represent any function itself. Here I am a bit unsure about how a user should "create" an objective function. We could choose to have a class that gets initialized with a function ("A"), or we might choose to let the user inherit from this class ("B"). I am going to show both possible approaches here, but the ultimate design may choose to drop one of the possibilities.

We don't do encapsulation here. Instead, the functions must always return valid output for valid input and take care of "encapsulation" itself. 

```r
Objective = R6Class("Objective",
  public = list(
      id = NULL,
      properties = NULL,
      domain = NULL,
      codomain = NULL,
      packages = NULL,


      initialize = function(id, domain, codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize"))),
          properties = character(0), packages = character(0)) {

        self$id = assert_string(id)
        
        # `properties` of the function, e.g. "noisy"
        self$properties = assert_subset(properties, blabot_reflections$objective_properties)

        self$packages = assert_set(packages)

        assert_domain = function(x) assert_param_set(eval(x))
        assert_codomain = function(x) {
          x = eval(x)
          # check that "codomain" is
          # (1) all numeric and
          # (2) every parameter's tags contain at most one of 'minimize' or 'maximize' and
          # (3) there is at least one parameter with tag 'minimize' / 'maximize'
          assert_param_set(x)
          assert_true(all(x$is_number))
          assert_true(all(sapply(x$tags, function(x) sum(x %in% c("minimize", "maximize"))) <= 1))
          assert_true(any(c("minimize", "maximize") %in% unlist(x$tags)))
        }

        #-----
        # the following complication is necessary but not central.
        # just see it as
        # self$domain = domain ; self$codomain = codomain
        if (inherits(domain, "ParamSet")) {
          private$.domain = assert_domain(domain)
        } else {
          lapply(domain, assert_domain)
          private$.domain_source = domain
        }
        if (inherits(codomain, "ParamSet")) {
          private$.codomain = assert_codomain(codomain)
        } else {
          lapply(codomain, assert_codomain)
          private$.codomain_source = codomain
        }
        #-----
        # ignore until here
      },

      # "abstract" functions: overload either "evaluate" or "evaluate_parallel"
      evaluate = function(x) {
        self$evaluate_many(list(x))[[1]]
      },
      evaluate_many = function(x) {
        if ({use_dataframe = is.data.frame(x)}) {  # not sure if we want to handle df at all tbh
          x = transpose_list(x)
        }
        if (use_future()) {
          res = future.apply::future_lapply(x, self$evaluate)
        } else {
          res = lapply(x, self$evaluate)
        }
        if (use_dataframe) {
          # TODO:
          # - handle length(x) == 0
          res = do.call(rbind, res)
        }
        res
      },

      # helper functions that call evaluate and also do checks. Because in some cases
      # we may want to be fast we make the checks optional.
      #
      # If the functions are of a nature that they always check by themselves (e.g. learner
      # resampling, which does checks automatically when parameter sets are set) then
      # these functions can be overloaded, see below.
      evaluate_checked = function(x) {
        self$codomain$assert(self$evaluate(self$domain$assert(x)))
      },

      evaluate_many_checked = function(x) {
        if ({use_dataframe = is.data.frame(x)}) {
          x = transpose_list(x)
        }
        lapply(x, self$domain$assert)  # not having this parallelized is unfortunate :-/
        res = self$evaluate_many(x)
        lapply(res, self$codomain$assert)
        if (use_dataframe) {
          # TODO:
          # - use my cool paradox dataframe assert function
          # - handle length(x) == 0
          res = do.call(rbind, res)
        }
        res
      }
  ),
  #---------
  # again, ignore the following, it is necessary but not important here
  active = list(
    codomain = function(val) {
      if (is.null(private$.codomain)) {
        sourcelist = lapply(private$.codomain_source, function(x) eval(x))
        if (length(sourcelist) > 1) {
          private$.codomain = ParamSetCollection$new(sourcelist)
        } else {
          private$.codomain = sourcelist[[1]]
        }
        if (!is.null(self$id)) {
          private$.codomain$set_id = self$id
        }
      }
      if (!missing(val) && !identical(val, private$.codomain)) {
        stop("codomain is read-only.")
      }
      private$.codomain
    },
    domain = function(val) {
      if (is.null(private$.domain)) {
        sourcelist = lapply(private$.domain_source, function(x) eval(x))
        if (length(sourcelist) > 1) {
          private$.domain = ParamSetCollection$new(sourcelist)
        } else {
          private$.domain = sourcelist[[1]]
        }
        if (!is.null(self$id)) {
          private$.domain$set_id = self$id
        }
      }
      if (!missing(val) && !identical(val, private$.domain)) {
        stop("domain is read-only.")
      }
      private$.domain
    }
  ),
  private = list(
      .domain = NULL,
      .domain_source = NULL,
      .codomain = NULL,
      .codomain_source = NULL,

      deep_clone = function(name, value) {
        if (!is.null(private$.domain_source)) {
          private$.domain = NULL  # required to keep clone identical to original, otherwise tests get really ugly
          if (name == ".domain_source") {
            value = lapply(value, function(x) {
              if (inherits(x, "R6")) x$clone(deep = TRUE) else x
            })
          }
        }
        # basically a copy of the above to get "codomain"
        if (!is.null(private$.codomain_source)) {
          private$.codomain = NULL
          if (name == ".codomain_source") {
            value = lapply(value, function(x) {
              if (inherits(x, "R6")) x$clone(deep = TRUE) else x
            })
          }
        }
        if (is.environment(value) && !is.null(value[[".__enclos_env__"]])) {
          return(value$clone(deep = TRUE))
        }
        value
      }
  )
)
```

### Base Classes for Construction

There are two ways to construct a new objective: inherit from `Objective`, or instantiate the `ObjectiveFunction`.

```r
ObjectiveFunction = R6Class("ObjectiveFunction",
  inherits = Objective,
  public = list(

      initialize = function(fun, domain, codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize"))),
          id = "function", properties = character(0), packages = character(0), fun_is_many_to_many = FALSE) {
        private$.fun = assert_function(fun)
        private$.fun_is_many_to_many = assert_flag(fun_is_many_to_many)
        super$initialize(id = id, domain = domain, codomain = codomain, properties = properties, packages = packages)
      },

      evaluate = function(x) {
        if (private$.fun_is_many_to_many) {
          super$evaluate(x)
        } else {
          private$.fun(x)
        }
      },

      evaluate_many = function(x) {
        if (private$.fun_is_many_to_many) {
          private$.fun(x)
        } else {
          super$evaluate_many(x)
        }
      }
  },
  active = list(
      fun = function(lhs) {
        if (!missing(lhs) && !identical(lhs, private$.fun)) stop("fun is read-only")
        private$.fun
      }
  ),
  private = list(
      .fun = NLL,
      .fun_is_many_to_many = NULL
  )
)
```

### Objective Implementations

Implementing the function `x |-> ||x - offset||^2` in the two ways:

#### Through Inheritance

This is a bit silly for a light-weight function. 
```r
ObjDistance = R6Class("ObjDistance",
  inherits = Objective,
  public = list(
      offset = NULL,
      initialize = function(offset = 0) {
        self$offset = assert_numeric(offset, any.missing = FALSE)
        super$initialize(id = "parabola", domain = ParamDbl$new("x")$rep = length(offset),
          # -- the following is the default:
          # codomain = ParamSet$new(list(ParamDbl$new("x", tags = "minimize")))
          )
      },

      evaluate = function(x) {
        list(y = sum((unlist(x) - offset)^2))
      }
  }
)

obj_distance_from_1_1 = ObjDistance$new(c(1, 1))
```

#### Through instantiation of 

```r
obj_distance_from_1_1 = ObjectiveFunction$new(
  function(x) list(y = sum((unlist(x) - c(1, 1))^2)),
  domain = ParamDbl$new("x")$rep = 2)
```

#### Using the Objective

```r
obj_distance_from_1_1$evaluate(list(x_rep_1 = 1, x_rep_2 = 3))  # list(y = 4)
obj_distance_from_1_1$evaluate_checked(list(x_rep_1 = 1, x_rep_2 = 3))  # list(y = 4)
# BAD: The following would also work because no checks are performend
# > obj_distance_from_1_1$evaluate(c(1, 1))
# ERROR: input does not conform to `domain`
# > obj_distance_from_1_1$evaluate_checked(c(1, 1))

obj_distance_from_1_1$evaluate_many(list(
    list(x_rep_1 = 1, x_rep_2 = 2),
    list(x_rep_1 = 1, x_rep_2 = 3)
  ))  # list(list(y = 1), list(y = 4))

obj_distance_from_1_1$evaluate_many(
    data.table(x_rep_1 = c(1, 1), x_rep_2 = c(1, 2))
  )  # list(list(y = 1), list(y = 4))
```

### Machine Learning Objective

```r

# TODO: also return metadata

MLObjective = R6Class("MLObjective",
  public = list(
      task = NULL,
      learner = NULL,
      resampling = NULL,
      measures = NULL,

      initialize = function(task, learner, resampling, measures) {
        self$task = assert_task(as_task(task, clone = TRUE))
        self$learner = assert_learner(as_learner(learner, clone = TRUE), task = self$task)
        self$resampling = assert_resampling(as_resampling(resampling, clone = TRUE))
        self$measures = assert_measures(as_measures(measures, clone = TRUE), task = self$task, learner = self$learner)

        meas_ids = ids(self$measures)

        super$initialize(id = paste("ML", task$id, learner$id, resampling$id, str_collapse(meas_ids, sep = "-"), sep = "_"),
          domain = alist(self$learner$param_set),
          codomain = ParamSet$new(lapply(self$measures, function(m) {
            ParamDbl$new(m$id, tags = if (m$minimize) "minimize" else "maximize", lower = m$range[1], upper = m$range[2])
          })),
          properties = "noisy", packages = c(self$learner$packages, unlist(lapply(self$measures, function(m) m$packages))))
      },
      evaluate_many = function(x) {
        if ({use_dataframe = is.data.frame(x)}) {
          x = transpose_list(x)
        }
        lrns = lapply(x, function(x) {
          lrn = self$learner$clone(deep = TRUE)
          lrn$param_set$values = insert_named(lrn$param_set$values, x)
          lrn
        })
        
        d = data.table(task = list(self$task), learner = lrns, resampling = list(self$resampling))
        bmr = invoke(benchmark, design = d)  # TODO: , .args = self$bm_args)
        result = bmr$aggregate(measures = self$measures, ids = FALSE)[, mids]
        if (!use_dataframe) {
          result = transpose_list(result)
        }
        result
      }
  )
)
```

## `OptimInstance`

Basically what `TuningInstance` is in `mlr3tuning`

This does almost nothing, so I am not sure whether it shouldn't go into the tuning class. It is basically a container so that we can call `Optimizer$optimize(OptimInstance)`, instead of `Optimizer$Optimize(Objective, ParamSet, Terminator, database)`. 

```r
OptimInstance = R6Class("OptimInstance",
  public = list(
      param_set = NULL,
      terminator = NULL,
      objective = NULL,
      database = NULL,
      initialize = function(objective, param_set, terminator) {
        self$param_set = param_set
        self$terminator = terminator,
        self$objective = objective
      },

      eval_batch = function(dt) {
        if (self$terminator$is_terminated(self)) {
          return(NULL)
        }
        design = Design$new(self$param_set, dt, remove_dupl = FALSE)
        parlist_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
        result = self$objective$evaluate_many(dt)
        # TODO: also add things like parlist_trafo, parlist_untrafoed to result
        database = if (is.null(database)) result else rbind(database, result)  # collect the trace in some way
        result
      }
  )
)
```

## `Optimizer`

```r
Optimizer = R6Class("Optimizer",
  public = list(
      param_set = NULL,
      param_classes = NULL,
      properties = NULL,
      packages = NULL,
      initialize = function(param_set, param_classes, properties, packages = character(0)) {
        self$param_set = assert_param_set(param_set),
        self$param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty")),
        self$properties = assert_subset(properties, blabot_reflections$optimizer_properties),
        self$packages = assert_set(packages)
      },

      optimize = function(optinst) {
        assert_r6(optinst, "OptimInstance")
        require_namespace(self$packages)
        require_namespace(optinst$objective$packages)
        # check dependencies
        # check supported parameter class
        private$.optimize(optinst)
        private$.best(optinst)
      }
  ),

  private = list(
      .optimize = function(optinst) stop("abstract")
      .best = function(optinst) {
        # default method to get "best" instances; should respect optinst$objective$codomain$tags being "minimize" or "maximize"
        return(best_result_in_optinst)
      }
  )
)
```
