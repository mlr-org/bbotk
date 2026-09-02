test_that("Codomain supplies a narrow Paradox graph migration bridge", {
  inspect = getFromNamespace(".inspect_legacy_codomain", "bbotk")
  rebuild = getFromNamespace(".rebuild_legacy_codomain", "bbotk")

  inspected = inspect(new.env(parent = emptyenv()))
  expect_identical(
    inspected,
    list(
      state = NULL,
      dependencies = structure(list(), names = character())
    )
  )

  base = ps(
    loss = p_dbl(tags = "minimize"),
    time = p_dbl()
  )
  rebuilt = rebuild(base, inspected$state, inspected$dependencies)
  expect_s3_class(rebuilt, "Codomain")
  expect_identical(rebuilt$ids(), base$ids())
  expect_identical(rebuilt$target_ids, "loss")
})

test_that("Codomain keeps historical leanified targets cold", {
  codomain = Codomain$new(list(loss = p_dbl(tags = "minimize")))
  own_members = c(
    "clone", "direction", "is_target", "maximization_to_minimization",
    "target_ids", "target_length", "target_tags"
  )
  targets = paste0(".__Codomain__", c(
    "initialize", own_members
  ))

  expect_true(all(vapply(
    targets,
    exists,
    logical(1L),
    envir = asNamespace("bbotk"),
    inherits = FALSE
  )))
  expect_true(all(vapply(
    targets,
    function(target) is.function(get(target, asNamespace("bbotk"))),
    logical(1L)
  )))
  expect_match(
    paste(deparse(body(codomain$clone)), collapse = ""),
    ".__bbotkv2_Codomain__clone",
    fixed = TRUE
  )
  expect_identical(codomain$target_ids, "loss")
})
