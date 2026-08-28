test_that("show_tissues() lists distinct tissue mappings", {
  metadata <- tibble::tibble(
    tissue = c("lung", "lung", "blood"),
    tissue_groups = c("respiratory", "respiratory", "blood"),
    dataset_id = c("a", "b", "c")
  )

  expect_equal(
    show_tissues(metadata),
    tibble::tibble(
      tissue = c("blood", "lung"),
      tissue_groups = c("blood", "respiratory")
    )
  )
})

test_that("show_datasets() filters by tissue and tissue group", {
  metadata <- tibble::tibble(
    dataset_id = c("a", "b", "c", "d"),
    tissue = c("lung", "lung", "blood", "blood"),
    tissue_groups = c("respiratory", "respiratory", "blood", "blood")
  )

  expect_equal(
    show_datasets(tissue = "lung", metadata = metadata),
    metadata[1:2, ]
  )
  expect_equal(
    show_datasets(tissue_groups = "blood", metadata = metadata),
    metadata[3:4, ]
  )
})
