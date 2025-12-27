library(testthat)
library(cellNexus)
library(dplyr)

test_that("get_pseudobulk() syncs appropriate files", {
  temp <- tempfile()
  id <- "8977a940f296898898d92461e71c8e0d___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |> 
    filter(empty_droplet == "FALSE",
           alive == "TRUE",
           scDblFinder.class !="doublet",
           file_id_cellNexus_pseudobulk == id)
  
  # The remote dataset should have many genes
  sme <- get_pseudobulk(meta, cache_directory = temp)
  sme |>
    row.names() |>
    length() |>
    expect_gt(1)
})

test_that("get_pseudobulk() subsets to requested gene ENSG00000065485", {
  temp <- tempfile()
  id <- "8977a940f296898898d92461e71c8e0d___1.h5ad"
  meta <- get_metadata(cache_directory = temp, cloud_metadata = SAMPLE_DATABASE_URL) |>
    filter(
      empty_droplet == "FALSE",
      alive == "TRUE",
      scDblFinder.class != "doublet",
      file_id_cellNexus_pseudobulk == id
    )
  
  # Ensure the gene exists in this dataset
  sme_full <- get_pseudobulk(meta, cache_directory = temp)
  expect_true("ENSG00000065485" %in% rownames(sme_full))
  
  # Subset to the specific feature and check result
  sme_sub <- get_pseudobulk(meta, cache_directory = temp, features = "ENSG00000065485")
  expect_equal(rownames(sme_sub), "ENSG00000065485")
  expect_equal(nrow(sme_sub), 1)
})


