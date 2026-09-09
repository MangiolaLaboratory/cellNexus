library(testthat)
library(cellNexus)
library(dplyr)

test_that("get_pseudobulk() syncs appropriate files", {
  temp <- tempfile()
  id <- "91acbf94110b95b1e994fdb1e1322fd1___1.h5ad"
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
  id <- "91acbf94110b95b1e994fdb1e1322fd1___1.h5ad"
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
  id <- "91acbf94110b95b1e994fdb1e1322fd1___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |>
    keep_quality_cells() |>
    filter(file_id_cellNexus_pseudobulk == id)

  pb_sce <- get_pseudobulk(meta, cache_directory = temp)
  pb_se <- get_pseudobulk(meta, cache_directory = temp, as_SummarizedExperiment = TRUE)

  expect_s4_class(pb_sce, "SingleCellExperiment")
  expect_s4_class(pb_se, "SummarizedExperiment")
  expect_identical(rownames(pb_sce), rownames(pb_se))
})
