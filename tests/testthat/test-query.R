library(dplyr)

test_that("get_SingleCellExperiment() correctly handles duplicate cell IDs", {
    meta <- get_metadata() |>
        dplyr::filter(cell_ == "868417_1") |>
        dplyr::collect()
    sce <- get_SingleCellExperiment(meta)
    # This query should return multiple cells, despite querying only 1 cell ID
    nrow(meta) |> expect_gt(1)
    # Each of the two ambiguous cell IDs should now be unique
    colnames(sce) |> expect_equal(c("868417_1_1", "868417_1_2"))
    # We should have lots of column data, derived from the metadata
    SummarizedExperiment::colData(sce) |>
        dim() |>
        expect_equal(c(2, 56))
})

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
    COUNTS_DATE <- "26-11-2024"

    sync_assay_files(
      atlas_name = "cellxgene",
      cell_aggregation = "single_cell",
      version = COUNTS_DATE,
      cache_dir = temp,
      files = test_file,
      subdirs = "cpm"
    )
    
    temp_subdir <- file.path(temp, "cpm")
    
    test_file %in% list.files(temp_subdir) |>
        expect(failure_message = "The file was not downloaded")
})

test_that("get_SingleCellExperiment() syncs appropriate files", {
    temp <- tempfile()
    test_file <- "4164d0eb972ad5e12719b6858c9559ea___1.h5ad"

    meta <- get_metadata() |> head(2)

    # The remote dataset should have many genes
    sce <- get_SingleCellExperiment(meta, cache_directory = temp,
                                    atlas_name = "cellxgene")
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
      
        temp <- tempfile()

        meta <- get_metadata() |> head(2)

        # If we request both assays, we get both assays
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = c("X", "cpm"),
                                 atlas_name = "cellxgene") |>
            assays() |>
            names() |>
            expect_setequal(c("X", "cpm"))

        # If we request one assay, we get one assays
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = "X",
                                 atlas_name = "cellxgene") |>
            assays() |>
            names() |>
            expect_setequal("X")
        get_SingleCellExperiment(meta, cache_directory = temp,
                                 assays = "cpm",
                                 atlas_name = "cellxgene") |>
            assays() |>
            names() |>
            expect_setequal("cpm")
    }
)

test_that("The features argument to get_SingleCellExperiment subsets genes", {
    meta <- get_metadata() |> head(2)

    # The un-subset dataset should have many genes
    sce_full <- get_SingleCellExperiment(meta, atlas_name = "cellxgene") |>
        row.names() |>
        length()
    expect_gt(sce_full, 1)

    # The subset dataset should only have one gene
    sce_subset <- get_SingleCellExperiment(meta, features = "ENSG00000243485",
                                           atlas_name = "cellxgene") |>
        row.names() |>
        length()
    expect_equal(sce_subset, 1)

    expect_gt(sce_full, sce_subset)
})

test_that("get_seurat() returns the appropriate data in Seurat format", {
    meta <- get_metadata() |> head(2)

    sce <- get_SingleCellExperiment(meta, features = "ENSG00000243485",
                                    atlas_name = "cellxgene")
    seurat <- get_seurat(meta, features = "ENSG00000243485",
                         atlas_name = "cellxgene")

    # The output should be a Seurat object
    expect_s4_class(seurat, "Seurat")
    # Both methods should have appropriately subset genes
    expect_equal(
        rownames(sce),
        rownames(seurat)
    )
})

test_that("get_SingleCellExperiment() assigns the right cell ID to each cell", {
    id = "3214d8f8986c1e33a85be5322f2db4a9"
    file_id = "7eb6d9a1-a723-4d59-bdbc-03e0a263e836"
    
    # Force the file to be cached
    get_metadata() |>
        filter(file_id_db == id) |>
        get_SingleCellExperiment()
    
    # Load the SCE from cache directly
    assay_1 = cellNexus:::get_default_cache_dir() |>
        file.path("original", id) |>
        HDF5Array::loadHDF5SummarizedExperiment() |>
        assay("X") |>
        as.matrix()
    
    # Make a SCE that has the right column names, but reversed
    assay_2 = 
        assay_1 |>
        colnames() |>
        tibble::tibble(
            file_id_db = id,
            file_id = file_id,
            cell_ = _
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
#     expect_setequal(colnames(unharmonised), c("file_id", "unharmonised"))
#     
#     # The number of cells in both harmonised and unharmonised should be the same
#     expect_equal(
#         dplyr::collect(harmonised) |> nrow(),
#         unharmonised$unharmonised |> purrr::map_int(function(df) dplyr::tally(df) |> dplyr::pull(n)) |> sum()
#     )
#     
#     # The number of datasets in both harmonised and unharmonised should be the same
#     expect_equal(
#         harmonised |> dplyr::group_by(file_id) |> dplyr::n_groups(),
#         nrow(unharmonised)
#     )
# })

test_that("get_metadata() is cached", {
    table = get_metadata()
    table_2 = get_metadata()
    
    identical(table, table_2) |> expect_true()
})

test_that("database_url() expect character ", {
  get_database_url() |>
    expect_s3_class("character")
})

test_that("get_metadata() expect a unique cell_type `abnormal cell` is present", {
  n_cell <- get_metadata() |> filter(cell_type == 'abnormal cell') |> as_tibble() |> nrow()
  expect_true(n_cell > 0)
})
  
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
#   sme <- get_metadata(cache_directory = temp) |> filter(file_id == "id1") |>
#     get_pseudobulk(cache_directory = file.path(temp, "pseudobulk"))
#   sme |>
#     row.names() |>
#     length() |>
#     expect_gt(1)
# })
# 
# test_that("get_pseudobulk() syncs appropriate files", {
#   temp <- tempfile()
#   id <- "0273924c-0387-4f44-98c5-2292dbaab11e"
#   meta <- get_metadata(cache_directory = temp) |> filter(file_id == id)
#   
#   # The remote dataset should have many genes
#   sme <- get_pseudobulk(meta, cache_directory = temp)
#   sme |>
#     row.names() |>
#     length() |>
#     expect_gt(1)
# })
# 
# test_that("get_pseudobulk() syncs appropriate fixed file", {
#   temp <- tempfile()
#   ids <- c(
#     "b50b15f1-bf19-4775-ab89-02512ec941a6",
#     "bffedc04-5ba1-46d4-885c-989a294bedd4",
#     "cc3ff54f-7587-49ea-b197-1515b6d98c4c",
#     "0af763e1-0e2f-4de6-9563-5abb0ad2b01e",
#     "51f114ae-232a-4550-a910-934e175db814",
#     "327927c7-c365-423c-9ebc-07acb09a0c1a",
#     "3ae36927-c188-4511-88cc-572ee1edf906",
#     "6ed2cdc2-dda8-4908-ad6c-cead9afee85e",
#     "56e0359f-ee8d-4ba5-a51d-159a183643e5",
#     "5c64f247-5b7c-4842-b290-65c722a65952"
#   )
#   meta <- get_metadata(cache_directory = temp) |> dplyr::filter(file_id %in% ids)
#   
#   # The remote dataset should have many genes
#   sme <- get_pseudobulk(meta, cache_directory = temp)
#   sme |>
#     row.names() |>
#     length() |>
#     expect_gt(1)
# })
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
