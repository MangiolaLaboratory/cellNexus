# Description:
# This script performs data management tasks involving three single-cell datasets:
# cellxgene, fibrosis, and prostate atlas. It reads metadata and dataset-specific information,
# cleans and renames columns, and writes updated data back to disk. The process involves
# connecting to databases in memory, executing SQL queries, and handling data in both
# Parquet and HDF5 formats. Additionally, it sets up directories and tests data conversion
# scripts for compatibility with Anndata structures. This is intended to unify metadata and
# streamline data handling in preparation for analysis.

library(duckdb)
library(dbplyr)
library(dplyr)
library(tidyr)
library(data.table)
library(HDF5Array)
library(SummarizedExperiment)
library(tidySingleCellExperiment)
library(stringr)
library(targets)
library(purrr)

DATE = "21-08-2025"
# read cellxgene
metadata <- tbl(dbConnect(duckdb::duckdb(), dbdir = ":memory:"),  
    sql("SELECT * FROM read_parquet('/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/cell_metadata_cell_type_consensus_v1_0_13_filtered_missing_cells_mengyuan.parquet')") )

# Function of supporting Read parquet by duckdb, then do something, then write parquet. This avoids converting to tibble
# @example
# con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
# tbl(con, sql(paste0("SELECT * FROM read_parquet('", path_parquet, "')"))) |>
#   mutate(c = "x") |>
#   duckdb_write_parquet(path = path_parquet,
#                        con = con)
duckdb_write_parquet <- function(.tbl_sql, path, con) {
  
  sql_tbl <- 
    .tbl_sql |>
    sql_render()
  
  # zstd 15 compresses faster than brotli for binary/scientific datasets, whereas brotli reduce could save 100Mb
  sql_call <- glue::glue("COPY ({sql_tbl}) TO '{path}' (FORMAT PARQUET, COMPRESSION 'brotli')")
  
  res <- dbExecute(con, sql_call)
  
  return(res)
}

# clean duplicated columns in cellxgene
metadata <- metadata |> select(
                   -cell_, 
                   -cell__1,
                   -dataset_id_1,
                   -dataset_id_1_1,
                   -cell__2,
                   -cell__3,
                   -dataset_id_2,
                   -dataset_id_3,
                   -sample_id_1,
                   -sample_id_2,
                   -sample_placeholder,
                   -cell_type_unified_ensemble_1,-cell_,
                   -cell__1,
                   -dataset_id_1,
                   -dataset_id_1_1,
                   -cell__2,
                   -cell__3,
                   -cell_type_1,
                   -dataset_id_2,
                   -observation_joinid_1,
                   -self_reported_ethnicity_1,
                   -donor_id_1,
                   -sample_id_1,
                   -assay_1,
                   -blueprint_first_labels_fine_1,
                   -azimuth_predicted_celltype_l2_1,
                   -monaco_first_labels_fine_1,
                   -dataset_id_3,
                   -cell_type_unified_ensemble_1,
                   -sample_id_2,
                   -atlas_id_1,
                   -tissue_1,
                   -is_primary_data_1,
                   -cell_type_ontology_term_id_1,
                   -azimuth,
                   -blueprint,
                   -monaco,
                   -matches("^scores"),
                   -matches("coarse$")) |> 
  dplyr::rename(cell_annotation_blueprint_singler = blueprint_first_labels_fine,
         cell_annotation_monaco_singler = monaco_first_labels_fine,
         cell_annotation_azimuth_l2 = azimuth_predicted_celltype_l2) |> 
  mutate(feature_count = as.integer(feature_count),
         published_at = as.character(published_at),
         revised_at = as.character(revised_at),
         nFeature_expressed_in_sample = as.integer(nFeature_expressed_in_sample),
         cell_count = as.integer(cell_count),
         
         # update metacell columns are integter to minimise file size
         across(contains("metacell_"), as.integer),
         across(contains("_chunk"), as.integer), 
         across(contains("subsets_"), as.integer))

# Add pseudobulk aggregated_cells column
sample_celltype_count <- metadata |> filter(empty_droplet == F,
                                            alive == T,
                                            scDblFinder.class != "doublet") |> dplyr::count(sample_id, 
                                                              cell_type_unified_ensemble, 
                                                              name = ".aggregated_cells") |> 
  mutate(.aggregated_cells = as.integer(.aggregated_cells))

metadata = metadata |> left_join(sample_celltype_count, by = c("sample_id", "cell_type_unified_ensemble"), copy=T)

# (THESE TWO DATASETS DOESNT contain meaningful data - no observation_joinid etc), thus was excluded in the final metadata.
metadata = metadata |> filter(!dataset_id %in% c("99950e99-2758-41d2-b2c9-643edcdf6d82", "9fcb0b73-c734-40a5-be9c-ace7eea401c9")) |> 
  mutate(atlas_id = paste0(atlas_id, "/", DATE) )

metadata_path = "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/metadata.1.2.13.parquet"

metadata |>
  duckdb_write_parquet(path = metadata_path,
                       con = dbConnect(duckdb::duckdb(), dbdir = ":memory:"))

# Strip sample annotation from cellnexus annotation doesn't save too much (less than 3Mb), thus keep in one.
remove_cols <- c("cell_chunk", "cell_type","cell_type_ontology_term_id",
                 "data_driven_ensemble", "default_embedding","ensemble_joinid", 
                 "observation_originalid", "run_from_cell_id", "suspension_type" )
  
# New metadata contains columns that cellnexus generated
metadata |> select(-any_of(remove_cols), -contains("metacell"),
                   -contains("subsets_"), -contains("high_")) |> 
  duckdb_write_parquet(path = "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/cellnexus_metadata.1.2.13.parquet",
                       con = dbConnect(duckdb::duckdb(), dbdir = ":memory:"))

# Old metadata from cellxgene and census
metadata |>  
  select(observation_joinid, dataset_id, sample_id, cell_type,
         cell_type_ontology_term_id,default_embedding, run_from_cell_id, suspension_type) |>
  duckdb_write_parquet(path = "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/census_cell_metadata.1.2.13.parquet",
                       con = dbConnect(duckdb::duckdb(), dbdir = ":memory:"))

# Metacell metadata
metadata |> 
  select(c("cell_id", "sample_id", "dataset_id"), contains("metacell")) |> 
  duckdb_write_parquet(path = "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/metacell_metadata.1.2.13.parquet",
                       con = dbConnect(duckdb::duckdb(), dbdir = ":memory:"))

# Check whether cellnexus_metadata parquet can be optimised further
source("~/git_control/cellNexus/dev/data_optimisation_script.R")



  

# # Exclude missing_cells
# job::job({
#   con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
#   
#   dbExecute(con, "
#   CREATE VIEW current_metadata AS
#   SELECT *
#   FROM read_parquet('/vast/scratch/users/shen.m/cellNexus/metadata.1.0.9.parquet')
# ")
#   
#   dbExecute(con, "
#   CREATE VIEW old_metadata_without_missing_cells AS
#   SELECT *
#   FROM read_parquet('/vast/scratch/users/shen.m/cache_temp/metadata.1.0.8.parquet')
# ")
#   
#   # Perform the left join and save to Parquet
#   copy_query <- "
#   COPY (
#      SELECT 
#         current_metadata.*,
#         old_metadata_without_missing_cells.cell_id AS cell_id_2
#       FROM current_metadata
#       LEFT JOIN old_metadata_without_missing_cells
#       ON current_metadata.cell_id = old_metadata_without_missing_cells.cell_id 
#       AND current_metadata.sample_id = old_metadata_without_missing_cells.sample_id
# 
#       
#   ) TO '/vast/scratch/users/shen.m/cellNexus/metadata.1.0.9_excluded_missing_cells.parquet'
#   (FORMAT PARQUET, COMPRESSION 'gzip');
# "
#   
#   # Execute the final query to write the result to a Parquet file
#   dbExecute(con, copy_query)
#   
#   # Disconnect from the database
#   dbDisconnect(con, shutdown = TRUE)
#   
#   print("Done.")
#   
# })
# 
# metadata = tbl(
#   dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
#   sql("SELECT * FROM read_parquet('/vast/scratch/users/shen.m/cellNexus/metadata.1.0.9_excluded_missing_cells.parquet')")
# ) |>filter(!is.na(cell_id_2)) |> select(-cell_id_2)
# 
# 
# metadata |> 
#   duckdb_write_parquet(path = metadata_path,
#                        con = dbConnect(duckdb::duckdb(), dbdir = ":memory:"))
# 
# file.copy(metadata_path,
#           to = "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/metadata.1.0.9.parquet")
# 


# Repeat similar steps for the fibrosis atlas
fibrosis <- tbl(dbConnect(duckdb::duckdb(), dbdir = ":memory:"),  
                sql("SELECT * FROM read_parquet('/vast/projects/cellxgene_curated/cellNexus/fibrosis.0.2.3.parquet')") )
fibrosis <- fibrosis |> dplyr::rename(file_id_cellNexus_single_cell = file_id_db) |> 
  mutate(file_id_cellNexus_single_cell = paste0(file_id_cellNexus_single_cell,".h5ad"))
#fibrosis |> as_tibble() |> arrow::write_parquet("/vast/scratch/users/shen.m/cellNexus/fibrosis.1.0.4.parquet")
fibrosis_path = "/vast/scratch/users/shen.m/cellNexus/fibrosis.1.0.4.parquet"
fibrosis |>  duckdb_write_parquet(path = fibrosis_path,
                                  con = con)

# Repeat similar steps for the Prostate atlas
prostate <- tbl(dbConnect(duckdb::duckdb(), dbdir = ":memory:"),  
                sql("SELECT * FROM read_parquet('/vast/scratch/users/shen.m/ProstateAtlas/prostate.0.1.0.parquet')") )
prostate <- prostate |> 
  mutate(file_id_cellNexus_single_cell = paste0(file_id_db,".h5ad"),
         cell_type_harmonised = NA)
#prostate |> as_tibble() |> arrow::write_parquet("/vast/scratch/users/shen.m/cellNexus/prostate.1.0.4.parquet")
prostate_path = "/vast/scratch/users/shen.m/cellNexus/prostate.1.0.4.parquet"
prostate |>  duckdb_write_parquet(path = prostate_path,
                                  con = con)

# Convert counts in HDF5 SCE to Anndata in atlas and rename gene symbols to ensembl IDs. This is done by Target parallelation:
# script: ~/git_control/CuratedAtlasQueryR/dev/convert_fibrosis_and_prostate_hdf5_to_anndata_targets.R
# store: scratch/cellNexus
original_hdf5_download_path = "/vast/scratch/users/shen.m/cellNexus/original_hdf5/"
cpm_hdf5_download_path = "/vast/scratch/users/shen.m/cellNexus/cpm_hdf5/"
if (!dir.exists(original_hdf5_download_path))  dir.create(original_hdf5_download_path, recursive = TRUE)
if (!dir.exists(cpm_hdf5_download_path))  dir.create(cpm_hdf5_download_path, recursive = TRUE)

# test fibrosis and prostate with anndata 
cache = "/vast/scratch/users/shen.m/cellNexus"
get_metadata(cache_directory = cache,
             get_metadata_url(databases = NULL)) |> 
  dplyr::filter(file_id_cellNexus %in% c( "0004e421765504041c8a460a83de2d01.h5ad", # this is from cellxgene
                                          "0a54b616d9afd26c9da310e8a504b541.h5ad", # this is from prostate atlas
                                          "12eb5fe25994253c1d320ca590a6e681.h5ad"  # this is from fibrosis atlas
                                          )
               ) |>
  cellNexus:::get_data_container(repository = NULL,
                                 cache_directory = cache,
                                 grouping_column = "file_id_cellNexus",
                                 #assays = "cpm"
                                 )
