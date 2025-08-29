library(dplyr)

test_that("get_default_cache_dir() returns the correct directory on Linux", {
    grepl("linux", version$platform, fixed = TRUE) |>
        skip_if_not()

    "~/.cache/R/cellNexus" |>
        normalizePath() |>
        expect_equal(
            get_default_cache_dir(),
        )
})

test_that("sync_assay_files() syncs appropriate files", {
    temp <- tempfile()
    test_file <- "4164d0eb972ad5e12719b6858c9559ea___1.h5ad"
    
    atlas_name <- "cellxgene/19-12-2024"

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

    meta <- get_metadata() |> head(2)

    # The remote dataset should have many genes
    sce <- get_SingleCellExperiment(meta, cache_directory = temp) |> 
      filter(file_id_cellNexus_single_cell == test_file)
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

        meta <- get_metadata() |> head(2)
        
        atlas_name <- meta |> distinct(atlas_id) |> pull()
        
        assay_names <- c("counts", "cpm")
        
        temp <- tempfile()

        # If we request both assays, we get both assays
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = assay_names) |>
            assays() |>
            names() |>
            expect_setequal(assay_names)

        # If we request one assay, we get one assays
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = "counts") |>
            assays() |>
            names() |>
            expect_setequal("counts")
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = "cpm") |>
            assays() |>
            names() |>
            expect_setequal("cpm")
    }
)

test_that("The features argument to get_SingleCellExperiment subsets genes", {
    meta <- get_metadata() |> head(2)

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
    meta <- get_metadata() |> head(2)

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

test_that("get_SingleCellExperiment() assigns the right cell ID to each cell", {
    id = "a65bcc2d-4243-44c1-a262-ab7dcddfcf86"
    file_id_cellNexus_single_cell <- "7ddd6775d704d6826539abaee8d22f65___1.h5ad"
    
    # Retrieve atlas_id from metadata
    atlas_id = get_metadata() |>
      filter(dataset_id == id) |> distinct(atlas_id) |> pull()
    
    # Force the file to be cached
    get_metadata() |>
        filter(dataset_id == id) |>
        get_SingleCellExperiment()
    
    # Load the SCE from cache directly
    assay_1 = cellNexus:::get_default_cache_dir() |>
        file.path(atlas_id, "counts", file_id_cellNexus_single_cell ) |>
        zellkonverter::readH5AD(reader = "R", use_hdf5 = TRUE) |>
        assay("counts") |>
        as.matrix()
    
    # Make a SCE that has the right column names, but reversed
    assay_2 = 
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
        
    colnames(assay_2) = sub("_1", "", x=colnames(assay_2))

    expect_equal(
        assay_1,
        assay_2[, colnames(assay_1)]
    )
})

test_that("get_metadata() is cached", {
    table = get_metadata()
    table_2 = get_metadata()
    
    identical(table, table_2) |> expect_true()
})

test_that("database_url() expect character ", {
  get_metadata_url() |>
    expect_s3_class("character")
})

test_that("get_metadata_url() with split files returns multiple URLs", {
  urls <- get_metadata_url(use_split_files = TRUE)
  expect_length(urls, 3)
  expect_true(any(grepl("sample_metadata", urls)))
  expect_true(any(grepl("cell_metadata_census", urls)))
  expect_true(any(grepl("cell_metadata_new", urls)))
})

test_that("create_joined_metadata_table handles split files correctly", {
  skip_on_cran()
  skip_if_not_installed("arrow")
  
  # Create temporary test files
  temp_dir <- tempdir()
  
  # Create mock sample metadata
  sample_data <- data.frame(
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    donor_id = c("donor_1", "donor_2"),
    age_days = c(30*365, 25*365),
    sex = c("female", "male"),
    stringsAsFactors = FALSE
  )
  
  # Create mock census cell metadata
  census_data <- data.frame(
    cell_id = c("cell_1", "cell_2"),
    observation_joinid = c("obs_1", "obs_2"),
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    cell_type = c("T cell", "B cell"),
    stringsAsFactors = FALSE
  )
  
  # Create mock new cell metadata
  new_data <- data.frame(
    cell_id = c("cell_1", "cell_2"),
    observation_joinid = c("obs_1", "obs_2"),
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    cell_annotation_new = c("CD4+ T", "CD19+ B"),
    stringsAsFactors = FALSE
  )
  
  # Write test files
  sample_file <- file.path(temp_dir, "sample_metadata.1.0.12.parquet")
  census_file <- file.path(temp_dir, "cell_metadata_census.1.0.12.parquet")
  new_file <- file.path(temp_dir, "cell_metadata_new.1.0.12.parquet")
  
  arrow::write_parquet(sample_data, sample_file)
  arrow::write_parquet(census_data, census_file)
  arrow::write_parquet(new_data, new_file)
  
  # Test the create_joined_metadata_table function
  files <- c(sample_file, census_file, new_file)
  result_table <- cellNexus:::create_joined_metadata_table(files)
  
  # Verify the result
  expect_s3_class(result_table, "tbl_duckdb_connection")
  
  # Check that we can query the table
  result_df <- result_table |> as_tibble()
  expect_equal(nrow(result_df), 2)
  expect_true("cell_annotation_new" %in% colnames(result_df))
  expect_true("age_days" %in% colnames(result_df))
  expect_true("cell_type" %in% colnames(result_df))
  
  # Clean up
  unlink(c(sample_file, census_file, new_file))
})

test_that("get_metadata() with split files works correctly when files exist", {
  skip_on_cran()
  skip_if_not_installed("arrow")
  
  # Create temporary test files and cache directory
  temp_dir <- tempdir()
  cache_dir <- file.path(temp_dir, "cache_test")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  # Create mock sample metadata
  sample_data <- data.frame(
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    donor_id = c("donor_1", "donor_2"),
    age_days = c(30*365, 25*365),
    sex = c("female", "male"),
    stringsAsFactors = FALSE
  )
  
  # Create mock census cell metadata
  census_data <- data.frame(
    cell_id = c("cell_1", "cell_2"),
    observation_joinid = c("obs_1", "obs_2"),
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    cell_type = c("T cell", "B cell"),
    stringsAsFactors = FALSE
  )
  
  # Create mock new cell metadata
  new_data <- data.frame(
    cell_id = c("cell_1", "cell_2"),
    observation_joinid = c("obs_1", "obs_2"),
    sample_id = c("sample_1", "sample_2"),
    dataset_id = c("dataset_A", "dataset_B"),
    cell_annotation_new = c("CD4+ T", "CD19+ B"),
    stringsAsFactors = FALSE
  )
  
  # Write test files to cache directory (simulating downloaded files)
  sample_file <- file.path(cache_dir, "sample_metadata.1.0.12.parquet")
  census_file <- file.path(cache_dir, "cell_metadata_census.1.0.12.parquet")
  new_file <- file.path(cache_dir, "cell_metadata_new.1.0.12.parquet")
  
  arrow::write_parquet(sample_data, sample_file)
  arrow::write_parquet(census_data, census_file)
  arrow::write_parquet(new_data, new_file)
  
  # Test get_metadata with local files and use_split_files
  files <- c(sample_file, census_file, new_file)
  result_table <- get_metadata(
    cloud_metadata = NULL,
    local_metadata = files,
    cache_directory = cache_dir,
    use_split_files = TRUE,
    use_cache = FALSE
  )
  
  # Verify the result
  expect_s3_class(result_table, "tbl_duckdb_connection")
  
  # Check that we can query the table and join worked
  result_df <- result_table |> as_tibble()
  expect_equal(nrow(result_df), 2)
  expect_true("cell_annotation_new" %in% colnames(result_df))
  expect_true("age_days" %in% colnames(result_df))
  expect_true("cell_type" %in% colnames(result_df))
  
  # Clean up
  unlink(cache_dir, recursive = TRUE)
})

test_that("get_metadata() expect a unique cell_type `abnormal cell` is present", {
  n_cell <- get_metadata() |> filter(cell_type == 'abnormal cell') |> as_tibble() |> nrow()
  expect_true(n_cell > 0)
})

test_that("get_metadata() expect to combine local and cloud metadata", {
  data("sample_sce_obj")
  
  cache = tempfile()
  if (!dir.exists(cache)) dir.create(cache, recursive = TRUE)
  metadata(sample_sce_obj)$data |> arrow::write_parquet(glue("{cache}/my_metadata.parquet"))
  
  atlas_name <- metadata(sample_sce_obj)$data |> pull(atlas_id) |> unique()
  assay <- "counts"
  file_id_from_cloud <- "68aea852584d77f78e5c91204558316d___1.h5ad"
  file_path <- file.path(cache, atlas_name, assay)
  
  n_cell = get_metadata(local_metadata = glue("{cache}/my_metadata.parquet")) |>
    filter(file_id_cellNexus_single_cell %in% c("sample_sce_obj.h5ad",
                                                file_id_from_cloud)) |>
    dplyr::count() |> pull() |> as.integer()
  expect_gt(n_cell , 1)
})

test_that("get_metadata() expect to query local metadata only", {
  data("sample_sce_obj")
  
  cache = tempfile()
  if (!dir.exists(cache)) dir.create(cache, recursive = TRUE)
  metadata(sample_sce_obj)$data |> arrow::write_parquet(glue("{cache}/my_metadata.parquet"))
  
  n_cell = get_metadata(local_metadata = glue("{cache}/my_metadata.parquet"),
                        cloud_metadata = NULL) |>
    dplyr::count() |> pull() |> as.integer()
  expect_equal(n_cell, 2)
})

test_that("get_single_cell_experiment() expect to combine local and cloud counts", {
  data("sample_sce_obj")
  
  cache = tempfile()
  if (!dir.exists(cache)) dir.create(cache, recursive = TRUE)
  metadata(sample_sce_obj)$data |> arrow::write_parquet(glue("{cache}/my_metadata.parquet"))
  
  atlas_name <- metadata(sample_sce_obj)$data |> pull(atlas_id) |> unique()
  assay <- "counts"
  file_id_from_cloud <- "68aea852584d77f78e5c91204558316d___1.h5ad"
  file_path <- file.path(cache, atlas_name, assay)
  
  if (!dir.exists(file_path)) dir.create(file_path, recursive = TRUE)
  sample_sce_obj |> 
    zellkonverter::writeH5AD(glue("{cache}/{atlas_name}/{assay}/sample_sce_obj.h5ad"), 
                             compression = "gzip",
                             verbose = FALSE)
  
  sce = get_metadata(local_metadata = glue("{cache}/my_metadata.parquet")) |>
    filter(file_id_cellNexus_single_cell %in% c("sample_sce_obj.h5ad",
                                                file_id_from_cloud)) |>
    get_single_cell_experiment(cache = cache)
    
  expect_contains(colnames(sce), "Liver_cDNA_CCTATTAGTTTGTGAC-1_2" )
})

test_that("get_single_cell_experiment() expect to get local counts only", {
  data("sample_sce_obj")
  
  cache = tempfile()
  if (!dir.exists(cache)) dir.create(cache, recursive = TRUE)
  metadata(sample_sce_obj)$data |> arrow::write_parquet(glue("{cache}/my_metadata.parquet"))
  
  atlas_name <- metadata(sample_sce_obj)$data |> pull(atlas_id) |> unique()
  assay <- "counts"
  file_path <- file.path(cache, atlas_name, assay)
  
  if (!dir.exists(file_path)) dir.create(file_path, recursive = TRUE)
  sample_sce_obj |> 
    zellkonverter::writeH5AD(glue("{cache}/{atlas_name}/{assay}/sample_sce_obj.h5ad"), 
                             compression = "gzip",
                             verbose = FALSE)
  
  n_cell_in_sce = get_metadata(local_metadata = glue("{cache}/my_metadata.parquet"),
                     cloud_metadata = NULL) |> 
    get_single_cell_experiment(cache = cache) |>
    colnames() |> length()
  
  expect_equal(n_cell_in_sce, 2)
})

test_that("get_pseudobulk() syncs appropriate files", {
  temp <- tempfile()
  id <- "4329386e014727c59bcc66ed974e654c___1.h5ad"
  meta <- get_metadata(cache_directory = temp) |> 
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

test_that("get_metacell() syncs appropriate files", {
  cache = tempfile()
  id = "009b708ad5032c0b9a91165013999d5f___2.h5ad"
  sce = get_metadata(cache_directory = cache) |> filter(!is.na(metacell_64)) |> 
    filter(file_id_cellNexus_single_cell == id) |> 
    get_metacell(cache_directory = cache,
                 cell_aggregation = "metacell_64")
  
  sce |> colnames() |> length() |> expect_gt(1)
  
})

# unharmonised_data is not implemented yet
# test_that("get_unharmonised_dataset works with one ID", {
#     dataset_id = "838ea006-2369-4e2c-b426-b2a744a2b02b"
#     unharmonised_meta = get_unharmonised_dataset(dataset_id)
# 
#     expect_s3_class(unharmonised_meta, "tbl")
# })

# test_that("get_unharmonised_metadata() returns the appropriate data", {
#     harmonised <- get_metadata() |> dplyr::filter(tissue == "kidney blood vessel")
#     unharmonised <- get_unharmonised_metadata(harmonised)
#     
#     unharmonised |> is.data.frame() |> expect_true()
#     expect_setequal(colnames(unharmonised), c("file_id_cellNexus_single_cell", "unharmonised"))
#     
#     # The number of cells in both harmonised and unharmonised should be the same
#     expect_equal(
#         dplyr::collect(harmonised) |> nrow(),
#         unharmonised$unharmonised |> purrr::map_int(function(df) dplyr::tally(df) |> dplyr::pull(n)) |> sum()
#     )
#     
#     # The number of datasets in both harmonised and unharmonised should be the same
#     expect_equal(
#         harmonised |> dplyr::group_by(file_id_cellNexus_single_cell) |> dplyr::n_groups(),
#         nrow(unharmonised)
#     )
# })


# test_that("import_one_sce() loads metadata from a SingleCellExperiment object into a parquet file and generates pseudobulk", {
#   # Test both functionalities together because if import them independently,
#   # the sample data will be loaded into the cache, which causes the second import to fail the unique file check
#   data(sample_sce_obj)
#   temp <- tempfile()
#   dataset_id <- "GSE122999"
#   import_one_sce(sce_obj = sample_sce_obj,
#                          cache_dir = temp,
#                  pseudobulk = TRUE)
#   
#   dataset_id %in% (get_metadata(cache_directory = temp) |> 
#                     dplyr::distinct(dataset_id) |> 
#                     dplyr::pull()) |>
#     expect(failure_message = "The correct metadata was not created")
#   
#   sme <- get_metadata(cache_directory = temp) |> filter(file_id_cellNexus_single_cell == "id1") |>
#     get_pseudobulk(cache_directory = file.path(temp, "pseudobulk"))
#   sme |>
#     row.names() |>
#     length() |>
#     expect_gt(1)
# })
# 
# 
# test_that("get_single_cell_experiment() syncs prostate atlas", {
#   temp <- tempfile()
#   # A sample from prostate atlas
#   sample <- "GSM4089151"
#   meta <- get_metadata(cache_directory = temp) |> filter(sample_ == sample)
#   sce <- meta |> get_single_cell_experiment(cache_directory = temp)
#   sce |>
#     row.names() |>
#     length() |>
#     expect_gt(1)
# })
