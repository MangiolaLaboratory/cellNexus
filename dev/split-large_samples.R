# R Script for Processing Sample Metadata in Cellxgene Data
# This script processes sample metadata related to Cellxgene datasets, focusing on Homo sapiens data.
# It filters datasets based on certain criteria like primary data, accepted assays, and large sample size thresholds.
# Additionally, it modifies cell identifiers and merges this information with related datasets to generate final outputs for further analysis.
# The script employs several R packages like arrow, targets, glue, dplyr, and more for data manipulation and storage operations.


library(arrow)
library(targets)
library(glue)
library(dplyr)
library(cellxgene.census)
library(stringr)
library(purrr)
library(duckdb)
result_directory = "/vast/projects/cellxgene_curated/metadata_cellxgenedp_Apr_2024"
# # Sample metadata
# sample_meta <- tar_read(metadata_dataset_id_common_sample_columns, store = glue("{result_directory}/_targets"))
# sample_meta |> arrow::write_parquet("~/scratch/Census/sample_meta.parquet", compression = "zstd")

# Sample to cell link
# sample_to_cell <- tar_read(metadata_dataset_id_cell_to_sample_mapping, store = glue("{result_directory}/_targets"))
# sample_to_cell_primary <- sample_to_cell |> filter(is_primary_data == TRUE)
# sample_to_cell_primary |> arrow::write_parquet("~/scratch/Census/sample_to_cell_primary.parquet", compression = "zstd")

sample_meta = 
  tbl(
    dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
    sql("SELECT * FROM read_parquet('~/scratch/Census/sample_meta.parquet')")
  )

sample_to_cell_primary = 
  tbl(
    dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
    sql("SELECT * FROM read_parquet('~/scratch/Census/sample_to_cell_primary.parquet')")
  )

sample_to_cell_primary_human <- sample_to_cell_primary |> 
  left_join(sample_meta |> filter(organism == "Homo sapiens"), 
            by = c("sample_","dataset_id", "donor_id", "is_primary_data", "sample_heuristic"),
            copy = T) |> 
  select(observation_joinid, cell_, sample_, 
         dataset_id, donor_id, is_primary_data, sample_heuristic,
         organism, tissue, development_stage, assay, collection_id,
         sex, self_reported_ethnicity, disease, cell_type)
gc()

# accepted_assays from census 
# accepted_assays <- read.csv("~/git_control/cellNexus/dev/census_accepted_assays_2024-07-01.csv", header=TRUE) this file was used to publish cellNexus, then Census updated assay acceptance 
# url <- "https://raw.githubusercontent.com/chanzuckerberg/cellxgene-census/d44bebd3e112ea41d00aa9b2509e2a606402c07d/docs/census_accepted_assays.csv"
# download.file(url, destfile = "./dev/census_accepted_assays_2025-01-30.csv")
accepted_assays  <- read.csv("~/git_control/cellNexus/dev/census_accepted_assays_2024-07-01.csv")
colnames(accepted_assays) <- c("id", "assay")

sample_to_cell_primary_human_accepted_assay <- sample_to_cell_primary_human |> filter(assay %in% accepted_assays$assay)

large_samples <- sample_to_cell_primary_human_accepted_assay |> 
  dplyr::count(sample_, assay, collection_id, dataset_id) |> 
  mutate(above_threshold = n > 15000)

large_samples_collection_id <- large_samples |> ungroup() |> 
  dplyr::count(collection_id) |> arrange(desc(n))

# function to discard nucleotide in cell_ ---------------------------------
# cell pattern repeated across samples. 
# Decision: use modified_cell and sample_ to split data

# drop cell ID if cell ID is a series of numbers
# ACGT more than 5, drops
# drop cellID if does not have special cahracter : - _
remove_nucleotides_and_separators <- function(x) {
  # convert integer cell ID or contain numerics surrounded by special characters to NA
  x[str_detect(x, "^[0-9:_\\-*]+$")] <- NA
  
  # drop sequence having a consistent stretch of 5 characters from ACGT 
  modified <- str_replace_all(x, "[ACGT]{5,}", "")
  
  #remove nucleotides surrounded by optional separators
  modified <- str_replace_all(modified, "[:_-]{2,}", "_")
}

# List of collection IDs
collection_ids <- large_samples_collection_id |> collect() |> pull(collection_id) 

gc()
process_collection <- function(id) {
  filtered_data <- sample_to_cell_primary_human_accepted_assay |>
    collect() |>
    filter(collection_id == id) |>
    select(cell_, sample_)
  
  #filtered_data <- filtered_data |> mutate(cell_modified = remove_nucleotides_and_separators(cell_))
  filtered_data$cell_modified <- remove_nucleotides_and_separators(filtered_data |> pull(cell_))
  filtered_data
}

final_result <- map(collection_ids, process_collection, .progress = T)
final_result <- reduce(final_result, union_all)

# conditional generating sample_2 based on whether number of cells > 15K.
sample_to_cell_primary_human_accepted_assay <- sample_to_cell_primary_human_accepted_assay |> 
  left_join(large_samples, by = c("sample_", "assay","collection_id","dataset_id"))

sample_to_cell_primary_human_accepted_assay_sample_2 <- 
  sample_to_cell_primary_human_accepted_assay |> 
  left_join(final_result, by = c("cell_","sample_")) |>
  # manual adjust 
  mutate(
    cell_modified = ifelse(dataset_id == "b2dda353-0c96-42df-8dcd-1ea7429a6feb" & sample_ == "5951a81f1d40153bab5d2b808e384f39",
                           "s14",
                           cell_modified),
    cell_modified = ifelse(dataset_id == "b2dda353-0c96-42df-8dcd-1ea7429a6feb" & sample_ == "7313173de022921da50c34ea2f87c7af",
                           "s3",
                           cell_modified)
  ) |>
  mutate(sample_2 = if_else(above_threshold,
                            paste(sample_, cell_modified, sep = "___"),
                            sample_)
  )
# save result
#sample_to_cell_primary_human_accepted_assay_sample_2 |> arrow::write_parquet("~/scratch/Census_rerun/sample_to_cell_primary_human_accepted_assay_sample_2_modify.parquet")

gc()

# Load Census census_version = "2024-07-01"
census <- open_soma(census_version = "stable")
metadata <- census$get("census_data")$get("homo_sapiens")$get("obs")
selected_columns <- c('assay', 'disease', 'donor_id', 'sex', 'self_reported_ethnicity', 'tissue', 'development_stage','is_primary_data','dataset_id','observation_joinid',
                      "cell_type", "cell_type_ontology_term_id")
samples <- metadata$read(column_names = selected_columns,
                         value_filter = "is_primary_data == 'TRUE'")$concat()
samples <- samples |> as.data.frame() |> distinct() 
#samples |> saveRDS("~/scratch/Census/cellxgene_to_census/census_samples_701.rds")

######## READ
sample_to_cell_primary_human_accepted_assay_sample_2 <- arrow::read_parquet("~/scratch/Census_rerun/sample_to_cell_primary_human_accepted_assay_sample_2.parquet")
samples <- readRDS("~/scratch/Census/cellxgene_to_census/census_samples_701.rds")

census_samples_to_download <- samples |> 
  left_join(sample_to_cell_primary_human_accepted_assay_sample_2,
            by = c("observation_joinid", "dataset_id"),
            relationship = "many-to-many") |>
  # Use annotation from census
  select(-donor_id.x,
         -is_primary_data.x,
         -tissue.y,
         -development_stage.y,
         -assay.y,
         -sex.y,
         -self_reported_ethnicity.y,
         -disease.y,
         -cell_type.y) |>
  rename(assay = assay.x,
         disease = disease.x,
         sex = sex.x,
         self_reported_ethnicity = self_reported_ethnicity.x,
         tissue = tissue.x,
         development_stage = development_stage.x,
         sample_heuristic = sample_heuristic.x,
         cell_type = cell_type.x
         ) |> 
  as_tibble() |>
  # remove space in the sample_2, as sample_2 will be regarded as filename 
  mutate(sample_2 = if_else(str_detect(sample_2, " "), str_replace_all(sample_2, " ",""), sample_2))

#census_samples_to_download |> arrow::write_parquet("/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/census_samples_to_download_MODIFIED.parquet")
con <- duckdb::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
parquet_file = "~/scratch/Census_rerun/census_samples_to_download.parquet"

census_samples_to_download <- tbl(con, sql(paste0("SELECT * FROM read_parquet('", parquet_file, "')")))

# This is important: please make sure observation_joinid and cell_ is unique per sample (sample_2) in census_samples_to_download
census_samples_to_download |> dplyr::count(observation_joinid, sample_2) |> dplyr::count(n)
census_samples_to_download |> dplyr::count(cell_, sample_2) |> dplyr::count(n)


census_samples_to_download |> group_by(dataset_id, sample_2)  |> 
  summarise(observation_joinid = list(observation_joinid), .groups = "drop") |> as_tibble() |> mutate(list_length = map_dbl(observation_joinid, length)) |>
  arrow::write_parquet("/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/census_samples_to_download_groups_MODIFIED.parquet")



# # census metadata
# files <- readRDS("~/git_control/HPCell/data/files_3.rds")
# metadata <- files |> left_join(census_samples_to_download, by = c("dataset_id", "sample_2")) |> filter(cell_number != 0)
# 
# # write to parquet
# metadata |> filter(is_primary_data == TRUE) |> select(-transformation_function) |> 
#   arrow::write_parquet("~/cellxgene_curated/census_samples/primary_metatadata.parquet")
# 
# # Calculate stats
# metadata |> filter(!is.na(is_primary_data), cell_number != 0) |> distinct(dataset_id)

