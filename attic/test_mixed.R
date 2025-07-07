library(devtools)
library(paradox)
load_all(".")

set.seed(124)

loglevel = "warn"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)


ss = ps(
    x1 = p_dbl(-5, 5),
    x2 = p_fct(c("a", "b", "c")),
    x3 = p_int(1L, 2L),
    x4 = p_lgl()
)
ss$add_dep("x2", on = "x4", cond = CondEqual$new(TRUE))
fun = function(xs) {
    if (is.null(xs$x2)) {
        xs$x2 = "a"
    }
    list(y = (xs$x1 - switch(xs$x2, "a" = 0, "b" = 1, "c" = 2)) %% xs$x3 + (if (xs$x4) xs$x1 else pi))
}
obj = ObjectiveRFun$new(fun = fun, domain = ss, properties = "single-crit")
tt = trm("evals", n_evals = 150)
ii = OptimInstanceBatchSingleCrit$new(objective = obj, search_space = ss, terminator = tt)
oo = opt("local_search_2",  n_searches = 3L, n_neighbors = 10L, n_steps = 10L)
oo$optimize(ii)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(ii$result)
print(as.data.table(ii$archive$data))