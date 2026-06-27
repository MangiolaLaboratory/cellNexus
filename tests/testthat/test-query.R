library(dplyr)

test_that("get_default_cache_dir() returns the correct directory on Linux", {
  grepl("linux", version$platform, fixed = TRUE) |>
    skip_if_not()
  skip_if(nzchar(Sys.getenv("R_USER_CACHE_DIR")))

  "~/.cache/R/cellNexus" |>
    normalizePath() |>
    expect_equal(
      get_default_cache_dir(),
    )
})

test_that("sync_assay_files() syncs appropriate files", {
  temp <- tempfile()

  test_file <- "72fd05df1f26137b07fd4f4fc799d61c___1.h5ad"
  atlas_name <- "cellxgene_2024/0.2.0"

  sync_assay_files(
    atlas_name = atlas_name,
    cell_aggregation = "",
    cache_dir = temp,
    files = test_file,
    subdirs = "cpm"
  )

  temp_subdir <- file.path(temp, atlas_name, "cpm")

  test_file %in% list.files(temp_subdir) |>
    expect(failure_message = "The file was not downloaded")
})

test_that("get_SingleCellExperiment() syncs appropriate files", {
  temp <- tempfile()
  test_file <- "4164d0eb972ad5e12719b6858c9559ea___1.h5ad"

  meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    head(2)

  # The remote dataset should have many genes
  sce <- get_SingleCellExperiment(meta, cache_directory = temp)

  sce <- sce[, sce$file_id_cellNexus_single_cell == test_file]

  sce |>
    row.names() |>
    length() |>
    expect_gt(1)
})

test_that(
  "The assays argument to get_SingleCellExperiment controls the number
  of returned assays",
  {
    # We need this for the assays() function
    library(SummarizedExperiment)

    meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
      head(2)

    atlas_name <- meta |>
      distinct(atlas_id) |>
      pull()

    assay_names <- c("counts", "cpm")

    temp <- tempfile()

    # If we request both assays, we get both assays
    get_SingleCellExperiment(meta,
      cache_directory = temp,
      assays = assay_names
    ) |>
      assays() |>
      names() |>
      expect_setequal(assay_names)

    # If we request one assay, we get one assays
    get_SingleCellExperiment(meta,
      cache_directory = temp,
      assays = "counts"
    ) |>
      assays() |>
      names() |>
      expect_setequal("counts")
    get_SingleCellExperiment(meta,
      cache_directory = temp,
      assays = "cpm"
    ) |>
      assays() |>
      names() |>
      expect_setequal("cpm")
  }
)

test_that("The features argument to get_SingleCellExperiment subsets genes", {
  meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    head(2)

  # The un-subset dataset should have many genes
  sce_full <- get_SingleCellExperiment(meta) |>
    row.names() |>
    length()
  expect_gt(sce_full, 1)

  # The subset dataset should only have one gene
  sce_subset <- get_SingleCellExperiment(meta, features = "ENSG00000010610") |>
    row.names() |>
    length()
  expect_equal(sce_subset, 1)

  expect_gt(sce_full, sce_subset)
})

test_that("get_seurat() returns the appropriate data in Seurat format", {
  meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    head(2)

  sce <- get_SingleCellExperiment(meta, features = "ENSG00000010610")
  seurat <- get_seurat(meta, features = "ENSG00000010610")

  # The output should be a Seurat object
  expect_s4_class(seurat, "Seurat")
  # Both methods should have appropriately subset genes
  expect_equal(
    rownames(sce),
    rownames(seurat)
  )
})

test_that("as.sparse() works on DelayedMatrix", {
  skip_if_not_installed("DelayedArray")
  skip_if_not_installed("Matrix")
  dm <- DelayedArray::DelayedArray(matrix(1:6, nrow = 2))
  sp <- SeuratObject::as.sparse(dm)
  expect_s4_class(sp, "dgCMatrix")
  expect_equivalent(as.matrix(sp), as.matrix(dm))
})

test_that("validate_data() returns list with expected names", {
  meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"], cache_directory = tempdir()) |>
    head(1)
  out <- cellNexus:::validate_data(meta, "counts", "single_cell", tempdir(), NULL, NULL)
  expect_type(out, "list")
  expect_setequal(
    names(out),
    c("data", "repository", "assays", "cache_directory", "features", "cell_aggregation", "atlas_name")
  )
  expect_identical(out$assays, "counts")
  expect_identical(out$cell_aggregation, "single_cell")
})

test_that("validate_data() errors on invalid assays", {
  meta <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"], cache_directory = tempdir()) |>
    head(1)
  expect_error(
    cellNexus:::validate_data(meta, "invalid_assay", "single_cell", tempdir(), NULL, NULL),
    "assays must be"
  )
})

test_that("get_SingleCellExperiment() assigns the right cell ID to each cell", {
  id <- "842c6f5d-4a94-4eef-8510-8c792d1124bc"
  file_id_cellNexus_single_cell <- "001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad"

  # Retrieve atlas_id from metadata
  atlas_id <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    filter(dataset_id == id) |>
    distinct(atlas_id) |>
    pull()

  # Force the file to be cached
  get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    filter(dataset_id == id) |>
    get_SingleCellExperiment()

  # Load the SCE from cache directly
  assay_1 <- cellNexus:::get_default_cache_dir() |>
    file.path(atlas_id, "counts", file_id_cellNexus_single_cell) |>
    zellkonverter::readH5AD(reader = "R", use_hdf5 = TRUE) |>
    assay("counts") |>
    as.matrix()

  # Make a SCE that has the right column names, but reversed
  assay_2 <-
    assay_1 |>
    colnames() |>
    tibble::tibble(
      file_id_cellNexus_single_cell = file_id_cellNexus_single_cell,
      dataset_id = id,
      cell_id = _,
      atlas_id = atlas_id
    ) |>
    arrange(-row_number()) |>
    get_SingleCellExperiment(assays = "counts") |>
    assay("counts") |>
    as.matrix()

  colnames(assay_2) <- sub("_1", "", x = colnames(assay_2))

  expect_equal(
    assay_1,
    assay_2[, colnames(assay_1)]
  )
})

test_that("get_metadata() is cached", {
  table <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])
  table_2 <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])

  identical(table, table_2) |>
    expect_true()
})

test_that("database_url() expect character ", {
  get_metadata_url() |>
    expect_s3_class("character")
})

test_that("get_metadata_url() returns URLs for given database names", {
  dbs <- c("metadata.TEST.parquet", "sample_metadata.TEST.parquet")
  urls <- get_metadata_url(dbs)
  expect_length(urls, length(dbs))
  expect_true(all(grepl("^https://", urls)))
  expect_true(all(grepl("cellNexus-metadata", urls, fixed = TRUE)))
  expect_true(all(vapply(dbs, \(d) any(grepl(d, urls, fixed = TRUE)), logical(1))))
})

test_that("get_metadata() expect a cell_type_unified_ensemble `t cd4` is present", {
  n_cell <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |>
    filter(cell_type_unified_ensemble == "t cd4") |>
    as_tibble() |>
    nrow()
  expect_true(n_cell > 0)
})

test_that("get_cell_communication_strength() returns metadata-like tbl with sample URL", {
  # For fast check purposes, use sample_database_url.
  tbl <- get_cell_communication_strength(
    cloud_metadata = get_metadata_url("cellNexus_lr_signaling_pathway_strength_DEMO.parquet"),
    cache_directory = tempdir()
  )
  expect_s3_class(tbl, "tbl_lazy")
  expect_true(ncol(dplyr::collect(tbl |>
    head(1))) >= 1L)
})

test_that("get_metadata() expect to combine local and cloud metadata", {
  data(pbmc3k_sce)
  cache <- tempdir()

  meta_path <- file.path(cache, "pbmc3k_metadata.parquet")
  assay <- "counts"

  pbmc3k_metadata <- pbmc3k_sce |>
    S4Vectors::metadata() |>
    purrr::pluck("data") |>
    dplyr::mutate(
      counts_directory = file.path(cache, atlas_id, assay),
      sce_path = file.path(counts_directory, file_id_cellNexus_single_cell)
    )

  sce_path <- pbmc3k_metadata |>
    dplyr::pull(sce_path) |>
    unique()

  # Save metadata and SCE object
  pbmc3k_sce |>
    S4Vectors::metadata() |>
    purrr::pluck("data") |>
    arrow::write_parquet(meta_path)

  # Test combining local and cloud metadata
  file_id_from_cloud <- "e52795dec7b626b6276b867d55328d9f___1.h5ad"
  file_id_local <- basename(sce_path)

  sample_id <- get_metadata(local_metadata = meta_path, cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    filter(file_id_cellNexus_single_cell %in% c(file_id_from_cloud, file_id_local)) |>
    pull(sample_id) |>
    unique()

  expect_contains(sample_id, "pbmc3k")

  n_cell_local <- get_metadata(local_metadata = meta_path, cloud_metadata = NULL) |>
    filter(file_id_cellNexus_single_cell == file_id_local) |>
    dplyr::count() |>
    pull() |>
    as.integer()

  n_cell_metadata <- pbmc3k_sce |>
    colnames() |>
    length()

  expect_equal(n_cell_metadata, n_cell_local)
})

test_that("get_single_cell_experiment() expect to combine local and cloud counts", {
  data(pbmc3k_sce)
  cache <- tempdir()

  meta_path <- file.path(cache, "pbmc3k_metadata.parquet")
  assay <- "counts"

  pbmc3k_metadata <- pbmc3k_sce |>
    S4Vectors::metadata() |>
    purrr::pluck("data") |>
    dplyr::mutate(
      counts_directory = file.path(cache, atlas_id, assay),
      sce_path = file.path(counts_directory, file_id_cellNexus_single_cell)
    )

  # Get unique paths
  counts_directory <- pbmc3k_metadata |>
    dplyr::pull(counts_directory) |>
    unique()

  sce_path <- pbmc3k_metadata |>
    dplyr::pull(sce_path) |>
    unique()

  dir.create(counts_directory, recursive = TRUE, showWarnings = FALSE)

  # Save metadata and SCE object
  pbmc3k_sce |>
    S4Vectors::metadata() |>
    purrr::pluck("data") |>
    arrow::write_parquet(meta_path)

  pbmc3k_sce |>
    anndataR::write_h5ad(sce_path, compression = "gzip")

  # Test combining local and cloud metadata
  file_id_from_cloud <- "e52795dec7b626b6276b867d55328d9f___1.h5ad"
  file_id_local <- basename(sce_path)

  sce <- get_metadata(local_metadata = meta_path, cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    filter(file_id_cellNexus_single_cell %in% c(file_id_from_cloud, file_id_local)) |>
    get_single_cell_experiment(cache_directory = cache)

  expect_contains(colData(sce)[, "sample_id"] |>
    unique(), "pbmc3k")
})

test_that("keep_quality_cells() return high quality cells", {
  cache <- tempfile()

  empty_droplet_col <- "empty_droplet"
  alive_col <- "alive"
  doublet_col <- "scDblFinder.class"

  meta_unfiltered <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])
  meta_filtered <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"]) |>
    keep_quality_cells()

  # Filtered should have fewer rows
  n_unfiltered <- meta_unfiltered |>
    dplyr::count() |>
    collect() |>
    pull(n)
  n_filtered <- meta_filtered |>
    dplyr::count() |>
    collect() |>
    pull(n)
  expect_gt(n_unfiltered, n_filtered)

  # No empty droplets remain
  expect_true(meta_filtered |>
    distinct(.data[[empty_droplet_col]]) |>
    collect() |>
    pull() |>
    identical(FALSE))

  # All cells are alive
  expect_true(meta_filtered |>
    distinct(.data[[alive_col]]) |>
    collect() |>
    pull() |>
    identical(TRUE))

  # No doublets present
  expect_false("doublet" %in% (meta_filtered |>
    distinct(.data[[doublet_col]]) |>
    collect() |>
    pull()))
})

test_that("get_atlas_versions() returns a registry-like data frame", {
  tbl <- get_atlas_versions()
  expect_s3_class(tbl, "data.frame")
  expect_true(ncol(tbl) >= 1L)
  expect_true("atlas_id" %in% colnames(tbl))
  expect_true("census_version" %in% colnames(tbl))
})
