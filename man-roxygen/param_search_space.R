#' @param search_space ([paradox::ParamSet])\cr
#' Specifies the search space for the [Optimizer]. The [paradox::ParamSet]
#' describes either a subset of the `domain` of the [Objective] or it describes
#' a set of parameters together with a `trafo` function that transforms values
#' from the search space to values of the domain. Depending on the context, this
#' value defaults to the domain of the objective.
