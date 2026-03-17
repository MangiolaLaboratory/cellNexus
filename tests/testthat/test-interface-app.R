test_that("organize_inputs() returns layout structure for simple input", {
  library(shiny)
  ui.inputs <- tagList(
    textInput("name", "Name"),
    numericInput("age", "Age", value = 30)
  )
  out <- organize_inputs(ui.inputs, columns = 2, rows = 1)
  expect_true(is.list(out))
  expect_true(length(out) >= 1L)
})

test_that("organize_inputs() with named list returns tabsetPanel", {
  library(shiny)
  ui.inputs.tabs <- list(
    Tab1 = tagList(textInput("a", "A")),
    Tab2 = tagList(numericInput("b", "B", value = 1))
  )
  out <- organize_inputs(ui.inputs.tabs, columns = 1)
  expect_s3_class(out, "shiny.tag")
  expect_equal(out$name, "div")
})

test_that(".string_to_vector() splits comma/whitespace/newline delimited input", {
  out <- cellNexus:::.string_to_vector("a, b c\nd, e")
  expect_type(out, "character")
  expect_true(all(c("a", "b", "c", "d", "e") %in% out))
})

test_that("create_interface_app() builds an app and generated code updates", {
  library(shiny)
  # Minimal metadata containing the columns create_interface_app expects
  metadata <- data.frame(
    cell_type_unified_ensemble = c("T cell", "B cell"),
    cell_type = c("T", "B"),
    alive = c("TRUE", "TRUE"),
    scDblFinder.class = c("singlet", "singlet"),
    is_immune = c("TRUE", "TRUE"),
    empty_droplet = c("FALSE", "FALSE"),
    development_stage = c("adult", "adult"),
    disease = c("healthy", "healthy"),
    self_reported_ethnicity = c("NA", "NA"),
    sex = c("female", "male"),
    tissue = c("lung", "lung"),
    tissue_groups = c("respiratory", "respiratory")
  )

  app <- create_interface_app(metadata)
  expect_s3_class(app, "shiny.appobj")

  server <- app$serverFuncSource()
  testServer(server, {
    # set one filter (non-default selection) so filter code is generated
    session$setInputs(
      cell_type_unified_ensemble = "T cell",
      retrieval_type = "SingleCellExperiment",
      assay = "counts",
      features = ""
    )
    expect_silent(capture.output(full_code()))
    filters1 <- input_filters()
    expect_true("cell_type_unified_ensemble" %in% names(filters1))
    expect_equal(filters1$cell_type_unified_ensemble, "T cell")
    cond1 <- retrieval_condition()
    expect_match(cond1, "get_single_cell_experiment\\(")

    # Switch retrieval type to cover another branch
    session$setInputs(
      retrieval_type = "metacell",
      metacell_aggregation = "metacell_4",
      features = "ENSG1 ENSG2"
    )
    expect_silent(capture.output(full_code()))
    cond2 <- retrieval_condition()
    expect_match(cond2, "get_metacell\\(")
    expect_match(cond2, "cell_aggregation = ['\"]metacell_4['\"]")
    expect_match(cond2, "features = c\\(['\"]ENSG1['\"], ['\"]ENSG2['\"]\\)")
  })
})
