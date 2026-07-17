library(testthat)
library(cellNexus)
library(dplyr)

test_that("get_pseudobulk() syncs appropriate files", {
  temp <- tempfile()
  id <- "a1c68b7b04c6f8c135b15db69c59fb38___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |>
    keep_quality_cells() |>
    filter(file_id_cellNexus_pseudobulk == id)

  # The remote dataset should have many genes
  sme <- get_pseudobulk(meta, cache_directory = temp)
  sme |>
    row.names() |>
    length() |>
    expect_gt(1)
})

test_that("get_pseudobulk() subsets to requested gene ENSG00000184009", {
  temp <- tempfile()
  id <- "a1c68b7b04c6f8c135b15db69c59fb38___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |>
    keep_quality_cells() |>
    filter(file_id_cellNexus_pseudobulk == id)

  # Ensure the gene exists in this dataset
  sme_full <- get_pseudobulk(meta, cache_directory = temp)
  expect_true("ENSG00000184009" %in% rownames(sme_full))

  # Subset to the specific feature and check result
  sme_sub <- get_pseudobulk(meta, cache_directory = temp, features = "ENSG00000184009")
  expect_equal(rownames(sme_sub), "ENSG00000184009")
  expect_equal(nrow(sme_sub), 1)
})

test_that("get_pseudobulk() as_SummarizedExperiment preserves rownames", {
  temp <- tempfile()
  id <- "a1c68b7b04c6f8c135b15db69c59fb38___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |>
    keep_quality_cells() |>
    filter(file_id_cellNexus_pseudobulk == id)

  pb_sce <- get_pseudobulk(meta, cache_directory = temp)
  pb_se <- get_pseudobulk(meta, cache_directory = temp, as_SummarizedExperiment = TRUE)

  expect_s4_class(pb_sce, "SingleCellExperiment")
  expect_s4_class(pb_se, "SummarizedExperiment")
  expect_identical(rownames(pb_sce), rownames(pb_se))
})

test_that("get_specific_annotation_columns() keeps pseudo-sample-wise columns", {
  meta <- tibble::tibble(
    sample_id = c("s1", "s1", "s2", "s2"),
    cell_type_unified_ensemble = c("ctA", "ctA", "ctA", "ctA"),
    donor = c("d1", "d1", "d2", "d2"),
    custom_pseudobulk_label = c("l1", "l1", "l2", "l2"),
    cell_id = c("c1", "c2", "c3", "c4"),
    nCount_RNA = c(100, 200, 300, 400)
  )

  columns <- cellNexus:::get_specific_annotation_columns(
    meta,
    key_columns = c("sample_id", "cell_type_unified_ensemble")
  )

  expect_true("custom_pseudobulk_label" %in% columns)
  expect_true("donor" %in% columns)
  expect_false("cell_id" %in% columns)
  expect_false("nCount_RNA" %in% columns)
})

test_that("get_specific_annotation_columns() handles edge cases", {
  empty_meta <- tibble::tibble(
    sample_id = character(),
    cell_type_unified_ensemble = character(),
    custom_label = character()
  )
  empty_columns <- cellNexus:::get_specific_annotation_columns(
    empty_meta,
    key_columns = c("sample_id", "cell_type_unified_ensemble")
  )
  expect_true("custom_label" %in% empty_columns)

  missing_key_columns <- cellNexus:::get_specific_annotation_columns(
    tibble::tibble(a = 1:3, b = c("x", "x", "y")),
    key_columns = c("sample_id", "cell_type_unified_ensemble")
  )
  expect_identical(missing_key_columns, character())

  keys_only <- cellNexus:::get_specific_annotation_columns(
    tibble::tibble(
      sample_id = c("s1", "s2"),
      cell_type_unified_ensemble = c("ct1", "ct2")
    ),
    key_columns = c("sample_id", "cell_type_unified_ensemble")
  )
  expect_identical(keys_only, character())

  na_meta <- tibble::tibble(
    sample_id = c("s1", "s1", "s2", "s2"),
    cell_type_unified_ensemble = c("ctA", "ctA", "ctA", "ctA"),
    stable_with_na = c(NA, NA, "x", "x"),
    unstable_with_na = c(NA, "y", "x", "x")
  )
  na_columns <- cellNexus:::get_specific_annotation_columns(
    na_meta,
    key_columns = c("sample_id", "cell_type_unified_ensemble")
  )
  expect_true("stable_with_na" %in% na_columns)
  expect_false("unstable_with_na" %in% na_columns)
})
