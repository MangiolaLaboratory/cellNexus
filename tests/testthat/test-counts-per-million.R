library(testthat)
library(cellNexus)
library(anndataR)

data(pbmc3k_sce)

test_that("get_counts_per_million() saves the file, names the assay 'cpm', and returns non-zero dimensions", {
  out <- tempfile(fileext = ".h5ad")
  get_counts_per_million(pbmc3k_sce, out)
  
  expect_true(file.exists(out))
  
  adata <- read_h5ad(out)
  expect_true("cpm" %in% names(adata$layers))
  expect_gt(nrow(adata), 0)
  expect_gt(ncol(adata), 0)
})
