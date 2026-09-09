library(testthat)
library(cellNexus)
library(dplyr)
library(tibble)
library(SummarizedExperiment)

# Lightweight sample metadata used across the package test suite
sample_meta <- function(cache = tempfile()) {
  get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = cache)
}

test_that("get_specific_annotation_columns keeps FD columns and drops cell-level", {
  # Controlled columns on a SAMPLE_DATABASE_URL subset for exact expectations
  df <- sample_meta() |>
    head(200) |>
    collect() |>
    mutate(
      batch = sample_id,
      ct_flag = paste(sample_id, cell_type_unified_ensemble, sep = "__"),
      cell_noise = cell_id
    ) |>
    select(
      sample_id,
      cell_type_unified_ensemble,
      batch,
      ct_flag,
      cell_noise,
      cell_id
    )

  expect_equal(
    sort(get_specific_annotation_columns(df, sample_id)),
    sort(c("sample_id", "batch"))
  )
  expect_equal(
    sort(get_specific_annotation_columns(
      df,
      sample_id,
      include_query_columns = FALSE
    )),
    "batch"
  )
  expect_equal(
    sort(get_specific_annotation_columns(
      df,
      c(sample_id, cell_type_unified_ensemble)
    )),
    sort(c(
      "sample_id", "cell_type_unified_ensemble", "batch", "ct_flag"
    ))
  )
  expect_equal(
    sort(get_specific_annotation_columns(
      df,
      c(sample_id, cell_type_unified_ensemble),
      include_query_columns = FALSE
    )),
    sort(c("batch", "ct_flag"))
  )
  expect_false("cell_noise" %in% get_specific_annotation_columns(
    df,
    c(sample_id, cell_type_unified_ensemble)
  ))
})

test_that("get_specific_annotation_columns works on lazy SAMPLE_DATABASE_URL", {
  meta <- sample_meta()
  cols <- get_specific_annotation_columns(
    meta,
    sample_id,
    sample_n = 2000L
  )
  expect_type(cols, "character")
  expect_true("sample_id" %in% cols)
  expect_false("cell_id" %in% cols)
})

test_that("get_specific_annotation_columns accepts tidyselect helpers", {
  meta <- sample_meta()
  cols_sample <- get_specific_annotation_columns(
    meta,
    contains("sample_id"),
    sample_n = 2000L
  )
  expect_true("sample_id" %in% cols_sample)
  expect_false("cell_id" %in% cols_sample)

  cols_ct <- get_specific_annotation_columns(
    meta,
    contains("cell_type"),
    sample_n = 2000L,
    include_query_columns = FALSE
  )
  expect_false("cell_id" %in% cols_ct)
})

test_that("keep_specific_annotation_columns selects keys and FD columns", {
  df <- sample_meta() |>
    head(200) |>
    collect() |>
    mutate(
      batch = sample_id,
      ct_flag = paste(sample_id, cell_type_unified_ensemble, sep = "__")
    )

  out <- keep_specific_annotation_columns(
    df,
    c(sample_id, cell_type_unified_ensemble)
  )
  expect_true(all(
    c("sample_id", "cell_type_unified_ensemble", "batch", "ct_flag") %in%
      colnames(out)
  ))
  expect_false("cell_id" %in% colnames(out))
  expect_equal(
    nrow(out),
    dplyr::n_distinct(df$sample_id, df$cell_type_unified_ensemble)
  )
})

test_that("keep_specific_annotation_columns preserves sample-grain user columns", {
  temp <- tempfile()
  meta <- sample_meta(temp) |>
    head(500) |>
    collect() |>
    mutate(
      my_sample_annotation = paste0("ann_", sample_id),
      my_cell_noise = cell_id
    )

  coldata_like <- meta |>
    keep_specific_annotation_columns(c(sample_id, cell_type_unified_ensemble))

  expect_true("my_sample_annotation" %in% colnames(coldata_like))
  expect_false("my_cell_noise" %in% colnames(coldata_like))
  expect_false("cell_id" %in% colnames(coldata_like))
})

test_that("get_pseudobulk() preserves sample-grain user columns", {
  temp <- tempfile()
  id <- "91acbf94110b95b1e994fdb1e1322fd1___1.h5ad"
  meta <- get_metadata(
    cloud_metadata = SAMPLE_DATABASE_URL,
    cache_directory = temp
  ) |>
    keep_quality_cells() |>
    filter(file_id_cellNexus_pseudobulk == id) |>
    collect() |>
    mutate(my_sample_annotation = paste0("ann_", sample_id))

  sme <- get_pseudobulk(meta, cache_directory = temp)
  expect_true("my_sample_annotation" %in% colnames(colData(sme)))
})

# Metacell grain is sample_id × metacell_* (same once-per-query selection pattern)
test_that("get_specific_annotation_columns supports metacell grain keys", {
  df <- tibble(
    sample_id = rep(c("s1", "s2"), each = 4),
    metacell_2 = rep(c("m1", "m1", "m2", "m2"), 2),
    batch = rep(c("b1", "b1", "b1", "b1", "b2", "b2", "b2", "b2")),
    metacell_score = c(1, 1, 2, 2, 3, 3, 4, 4),
    cell_id = paste0("c", 1:8)
  )

  cols <- get_specific_annotation_columns(
    df,
    all_of(c("sample_id", "metacell_2")),
    include_query_columns = TRUE
  )
  expect_true(all(c("sample_id", "metacell_2", "batch", "metacell_score") %in% cols))
  expect_false("cell_id" %in% cols)
})
