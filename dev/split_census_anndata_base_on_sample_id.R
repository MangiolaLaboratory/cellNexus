library(targets)
library(zellkonverter)
library(tibble)
library(dplyr)
library(SummarizedExperiment)
library(tidybulk)
library(tidySingleCellExperiment)
library(stringr)
library(arrow)
anndata_path_based_on_dataset_id_to_read <- "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/h5ad/"
anndata_path_based_on_sample_id_to_save <- "/vast/scratch/users/shen.m/Census_final_run/split_h5ad_based_on_sample_id/"
dir.create(anndata_path_based_on_sample_id_to_save, recursive = TRUE)

files <- list.files(anndata_path_based_on_dataset_id_to_read, pattern = "*h5ad", 
             full.names = TRUE)

save_data <- function(data, file_name) {
  filename <- paste0(file.path(anndata_path_based_on_sample_id_to_save), file_name, ".h5ad")
  if(ncol(assay(data)) == 1) {
    
    # Duplicate the assay to prevent saving errors due to single-column matrices
    my_assay = cbind(assay(data), assay(data))
    # Rename the second column to distinguish it
    colnames(my_assay)[2] = paste0("DUMMY", "___", colnames(my_assay)[2])
    
    cd = colData(data)
    cd = cd |> rbind(cd)
    rownames(cd)[2] = paste0("DUMMY", "___", rownames(cd)[2])
    
    
    
    data =  SingleCellExperiment(assay = list( X = my_assay ), colData = cd) 
  } 
  
  
  zellkonverter::writeH5AD(data, file = filename, compression = "gzip" )
}


#' This function subsets samples from a dataset based on specified join IDs.
#' It reads a single-cell expression dataset stored in the HDF5 AnnData format,
#' removes unneeded metadata to optimize memory usage, and extracts the subset of cells 
#' matching the provided observation join IDs.
subset_samples <- function(dataset_id, observation_joinid, sample_id) {
  
  
  # Construct the file path to the dataset
  file_path <- paste0(anndata_path_based_on_dataset_id_to_read, dataset_id, ".h5ad")
  
  # Read the dataset from HDF5 file using zellkonverter package
  sce <- zellkonverter::readH5AD(file_path, use_hdf5 = TRUE, reader = "R")
  
  # Extract the base name of the file and remove the '.h5ad' extension to get dataset_id
  sce$dataset_id = file_path |> basename() |> str_remove("\\.h5ad$")
  
  # Add original cell identifiers from column names to the dataset
  sce$observation_originalid = colnames(sce)
  
  # Create a new identifier by combining the original cell id with the dataset id
  cell_modified = paste(sce$observation_originalid, sce$dataset_id, sep = "___")
  
  # Update column names with the new combined identifier
  colnames(sce) <- cell_modified
  
  # Clear the metadata to reduce memory overhead
  S4Vectors::metadata(sce) <- list()
  
  # Add sample identifier to the dataset
  sce <- sce |> mutate(sample_id = !!sample_id) |>
    
    # Remove the ".h5ad" extension if there is
    mutate(sample_id = stringr::str_replace(sample_id, ".h5ad$", ""))
  
  # Identify cells that match the observation_joinid
  cells_to_subset <- which(colData(sce)$observation_joinid %in% unlist(observation_joinid))
  
  # Subset and return the SingleCellExperiment object with only the selected cells
  sce[, cells_to_subset]
}

# rename_features <- function(data) {
#   edb <- EnsDb.Hsapiens.v86
#   edb_df <- genes(edb,
#                   columns = c("gene_name", "entrezid", "gene_biotype"),
#                   filter = GeneIdFilter("ENSG", condition = "startsWith"),
#                   return.type = "data.frame") 
#   
#   gene_names_map <- rowData(data) |> as.data.frame() |> tibble::rownames_to_column(var = "gene_id") |>
#     dplyr::select(gene_id, feature_name) |>
#     mutate(current_gene_names = gsub("_", "-", feature_name)) |> dplyr::left_join(edb_df, by = "gene_id") |>
#     mutate(modified_gene_names = ifelse(stringr::str_like(current_gene_names, "%ENSG0%"), gene_name, current_gene_names))
#   
#   gene_names_map_tidy <- gene_names_map |>
#     dplyr::filter(!is.na(modified_gene_names))
#   
#   # delete ensemble IDs if cant be converted to gene symbols
#   rownames_to_delete <- gene_names_map |>
#     dplyr::filter(is.na(modified_gene_names)) |> pull(gene_id)
#   data <- data[!rownames(data) %in% rownames_to_delete, ]
#   
#   rownames(data) <- gene_names_map_tidy$modified_gene_names
#   # access assay name
#   assay_name <-  data@assays |> names() |> magrittr::extract2(1)
#   counts_slot <- assay(data, assay_name)
#   rownames(counts_slot) <- gene_names_map_tidy$modified_gene_names
#   
#   SummarizedExperiment::rowData(data)$feature_name <- NULL
#   SummarizedExperiment::rowData(data)$gene_name <- gene_names_map_tidy$modified_gene_names
#   
#   data
# }

computing_resources = crew.cluster::crew_controller_slurm(
  slurm_memory_gigabytes_per_cpu = 40, 
  slurm_cpus_per_task = 1,
  workers = 100,
  verbose = TRUE
)
tar_option_set(
  memory = "transient",
  garbage_collection = TRUE,
  storage = "worker",
  retrieval = "worker",
  format = "qs",
  cue = tar_cue(mode = "never"),
  error = "continue",
  #debug = "sliced_sce_9c40d298d224bab6",
  controller = computing_resources
)

list(
  tar_target(
    file_paths,
    list.files(anndata_path_based_on_dataset_id_to_read, pattern = "*h5ad",
               full.names = TRUE),
    deployment = "main"
  ),
  tar_target(
    grouped_observation_joinid_per_sample,
    # This should be run
    read_parquet("/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/census_samples_to_download_groups_MODIFIED.parquet") |>
      
      # Note: dataset_id "99950e99-2758-41d2-b2c9-643edcdf6d82" and "9fcb0b73-c734-40a5-be9c-ace7eea401c9" 
      #       from Census does not contain any meaningful data (no observation_joinid in colData), thus produced 
      #       not meaningful samples (0 cells). They need to be deleted.
      
      filter(!dataset_id %in% c("99950e99-2758-41d2-b2c9-643edcdf6d82", "9fcb0b73-c734-40a5-be9c-ace7eea401c9" ))
  ),
  tar_target(
    sliced_sce,
    subset_samples(grouped_observation_joinid_per_sample$dataset_id,
                   grouped_observation_joinid_per_sample$observation_joinid,
                   grouped_observation_joinid_per_sample$sample_2)  |>
      save_data(file_name = grouped_observation_joinid_per_sample$sample_2),
    pattern = map(grouped_observation_joinid_per_sample),
    format = "file"
  )
)

# tar_make(store = "~/scratch/Census_final_run/split_h5ad_based_on_sample_id_target_store/",
#          script = "~/git_control/cellNexus/dev/split_census_anndata_base_on_sample_id.R",
#          reporter = "summary")

# tar_errored(store = "~/scratch/Census_final_run/split_h5ad_based_on_sample_id_target_store/")
# tar_meta(store = "~/scratch/Census_final_run/split_h5ad_based_on_sample_id_target_store/") |>
#   filter(!is.na(error)) |> pull(error)

