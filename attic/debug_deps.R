library(bbotk)

# Create a search space with dependencies
domain = ps(
  x1 = p_dbl(-5, 5),
  x2 = p_fct(c("a", "b", "c")),
  x3 = p_int(1L, 2L),
  x4 = p_lgl()
)
domain$add_dep("x2", on = "x4", cond = CondEqual$new(TRUE))

# Debug the structure
cat("Search space IDs:\n")
print(domain$ids())

cat("\nDependencies:\n")
print(domain$deps)

cat("\nDependencies structure:\n")
str(domain$deps)

cat("\nDependencies 'on' column:\n")
print(domain$deps$on)

cat("\nDependencies 'on' column type:\n")
print(typeof(domain$deps$on))

cat("\nUnique parent parameters:\n")
print(unique(domain$deps$on)) 