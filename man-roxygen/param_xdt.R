#' @param xdt ([data.table::data.table()])\cr
#'   Set of untransformed points / points from the *search space*.
#'   One point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`.
#'   Column names have to match ids of the `search_space`.
#'   However, `xdt` can contain additional columns.
