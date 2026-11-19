test_that("the folder structure is created with the seg template and without R project", {
  base <- tempfile("setup_")
  dir.create(base)
  on.exit(unlink(base, recursive = TRUE), add = TRUE)

  suppressMessages(ya_setup_folder_structure("proj", base_path = base, template = "seg"))
  proj <- file.path(base, "proj")
  expect_true(file.exists(file.path(proj, "02_scripts", "seg.R")))
  for (d in c("01_input/data/raw", "01_input/data/processed", "03_output/plots")) {
    expect_true(dir.exists(file.path(proj, d)), info = d)
  }
  expect_length(list.files(proj, pattern = "\\.Rproj$"), 0)
})

test_that("templates are available and unknown templates are rejected early", {
  expect_true(all(
    c("kda.R", "seg.R") %in% list.files(system.file("templates", package = "YouAnalyser"))
  ))

  base <- tempfile("setup_")
  dir.create(base)
  on.exit(unlink(base, recursive = TRUE), add = TRUE)
  expect_error(
    ya_setup_folder_structure("proj", base_path = base, template = "nope"),
    "not found"
  )
  expect_false(dir.exists(file.path(base, "proj")))
})

test_that("the seg template is valid R code", {
  expect_no_error(parse(system.file("templates", "seg.R", package = "YouAnalyser")))
})
