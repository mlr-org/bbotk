#FIXME: create add_archive function


#' @title Map
#'
#' @description
#' Describes a function (domain) -> (codomain)
#'
#' domain, codomain: ParamSet
#' fun: function. takes 1 list argument and returns a list, with positions and names agreeing with
#' domain, codomain
#'
#' Like OkMap, only it has an additional param_set. Set values here to
#' change the behaviour of fun.
#'
#' fun must be given as a function of two arguments. The second is set from
#' the param_set. $fun will then only have one parameter.
#'
#' @export
Objective = R6Class("Objective",
  public = list(
    id = NULL,
    fun = NULL,
    domain = NULL,
    codomain = NULL,
    constants = NULL,

    initialize = function(fun, domain, ndim = 1L, minimize = TRUE, id = "f") {
      assert_function(fun)
      assert_param_set(domain)
      # assert_param_set(codomain)
      assert_logical(minimize, len = ndim, any.missing = FALSE)
      self$fun = fun
      self$domain = domain
      cod = ParamDbl$new("x")$rep(ndim)
      self$codomain = cod
      self$id = id
    },
    
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },
  
    print = function() {
      catf(self$format())
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
    }
  ),
  active = list(
    # fun = function(val) {
    #   if (!missing(val)) {
    #     stop("fun is read-only")
    #   }
    #   function(x) {
    #     private$.fun(x, self$param_set$values)
    #   }
    # },
    
    fun_assert = function(val) {
      if (!missing(val)) {
        stop("safe_fun is read-only")
      }
      function(x) {
        assert_list(x, names = "unique", len = self$domain$length)
        assert_names(names(x), identical.to = self$domain$ids())
        ret = self$fun(x)
        assert_list(ret, names = "unique", len = self$codomain$length)
        assert_names(names(ret), identical.to = self$codomain$ids())
        ret
      }
    },

    n_evals = function() nrow(self$archive),

    result = function() {
      tune_x = private$.result$tune_x
      perf = private$.result$perf
      # if ps has no trafo, just use the normal config
      trafo = if (is.null(self$param_set$trafo)) identity else self$param_set$trafo
      params = trafo(tune_x)
      params = insert_named(self$learner$param_set$values, params)
      list(tune_x = tune_x, params = params, perf = perf)
    }
  ),

  )
) 
  


