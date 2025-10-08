load_all()

ss = paradox::ps(
  A = paradox::p_fct(c("a1", "a2")),
  B = paradox::p_dbl(0, 1)
)
ss$add_dep("B", on = "A", cond = paradox::CondEqual$new("a1"))
pop = data.table::data.table(A = "a2", B = NA_real_)
print(pop)
set.seed(1)
neighs = .Call("c_test_generate_neighs", ss, pop, 1L, 0.1, PACKAGE = "bbotk")
print(neighs)
