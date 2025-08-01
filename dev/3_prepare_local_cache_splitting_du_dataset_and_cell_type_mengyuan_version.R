# Step3
# Group samples by dataset_id, cell_type

# This script sets up a robust and scalable data processing pipeline for single-cell RNA sequencing (scRNA-seq) datasets using the targets package in R, which facilitates reproducible and efficient workflows. Specifically, the code orchestrates the ingestion and preprocessing of multiple SingleCellExperiment objects corresponding to different datasets (dataset_id) and targets (target_name). It leverages high-performance computing resources through the crew package, configuring multiple SLURM-based controllers (tier_1 to tier_4) to handle varying computational loads efficiently.
# 
# The pipeline performs several key steps:
#   
#   1.	Data Retrieval: It reads raw SingleCellExperiment objects for each target, ensuring that only successfully loaded data proceeds further.
# 2.	Normalization: Calculates Counts Per Million (CPM) for each cell to normalize gene expression levels across cells and samples.
# 3.	Data Aggregation: Groups the data by dataset_id and tar_group, then combines the SingleCellExperiment objects within each group into a single object, effectively consolidating the data for each dataset.
# 4.	Metadata Integration: Joins additional metadata, such as cell types, by connecting to a DuckDB database and fetching relevant information from a Parquet file. This enriches the single-cell data with essential annotations.
# 5.	Cell Type Segmentation: Splits the combined SingleCellExperiment objects into separate objects based on cell_type, facilitating downstream analyses that are specific to each cell type.
# 6.	Data Saving with Error Handling: Generates unique identifiers for each cell type within a dataset and saves both the raw counts and CPM-normalized data to specified directories. It includes special handling for cases where a cell type has only one cell, duplicating the data to prevent errors during the saving process.
# 
# By integrating targets, crew, and various data manipulation packages (dplyr, tidyverse, SingleCellExperiment), this script ensures that large-scale scRNA-seq data processing is efficient, reproducible, and capable of leveraging parallel computing resources. It is designed to handle edge cases gracefully and provides a clear framework for preprocessing scRNA-seq data, which is essential for subsequent analyses such as clustering, differential expression, and cell type identification.


library(arrow)
library(dplyr)
library(duckdb)

#


# Get Dharmesh metadata consensus
#system("~/bin/rclone copy box_adelaide:/Mangiola_ImmuneAtlas/reannotation_consensus/cell_annotation_new_substitute_cell_type_na_to_unknown.parquet /vast/projects/cellxgene_curated/metadata_cellxgenedp_Apr_2024/")

job::job({
  
  get_file_ids = function(cell_annotation 
                          #cell_type_consensus_parquet
  ){
    
    # cell_consensus = 
    #   tbl(
    #     dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
    #     sql(glue::glue("SELECT * FROM read_parquet('{cell_type_consensus_parquet}')"))
    #   ) |>
    #   select(cell_, dataset_id, cell_type_unified_ensemble, cell_type_unified) 
    
    # This because f7c1c579-2dc0-47e2-ba19-8165c5a0e353 includes 13K samples
    # It affects only very few datasets
    sample_chunk_df = 
      tbl(
        dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
        sql(glue::glue("SELECT * FROM read_parquet('{cell_annotation}')"))
      ) |> 
      # Define chunks
      dplyr::count(dataset_id, sample_id, name = "cell_count") |>  # Ensure unique dataset_id and sample_id combinations
      distinct(dataset_id, sample_id, cell_count) |>  # Ensure unique dataset_id and sample_id combinations
      group_by(dataset_id) |> 
      dbplyr::window_order(dataset_id, cell_count, sample_id) |>  # Ensure order. Note: order cell_count only is not enough because it needs a secondary tie-breaker
      mutate(sample_index = row_number()) |>  # Create sequential index within each dataset
      mutate(sample_chunk = (sample_index - 1) %/% 1000 + 1) |>  # Assign chunks (up to 1000 samples per chunk)
      mutate(sample_pseudobulk_chunk = (sample_index - 1) %/% 250 + 1) |> # Max combination of dataset_id, sample_pseudobulk_chunk and file_id_pseudobulk up to 10000
      mutate(cell_chunk = cumsum(cell_count) %/% 100000 + 1) |> # max 20K cells per sample
      ungroup() 
    
    # Test whether cell_chunk and sample_chunk are unique for this sample
    run_chunk_once <- function(column_name, id) {
      sample_chunk_df |> filter(sample_id == id) |> pull(!!column_name)
    }
    
    sample_chunk_results <- replicate(20, run_chunk_once("sample_chunk", "d6e942a09a140ee8bb6f0c3da8defea4___exp7-human-150well."), simplify = FALSE)
    sample_chunk_identical <- all(sapply(sample_chunk_results[-1], function(x) identical(x, sample_chunk_results[[1]])))
    if (!sample_chunk_identical) {
      stop("Inconsistent sample chunk value was generated in multiple runs, this will lead to file id changes")
    }
    
    cell_chunk_results <- replicate(20, run_chunk_once("cell_chunk",  "d6e942a09a140ee8bb6f0c3da8defea4___exp7-human-150well."), simplify = FALSE)
    cell_chunk_identical <- all(sapply(cell_chunk_results[-1], function(x) identical(x, cell_chunk_results[[1]])))
    if (!cell_chunk_identical) {
      stop("Inconsistent cell chunk value was generated in multiple runs, this will lead to file id changes")
    }
    
    
    tbl(
      dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
      sql(glue::glue("SELECT * FROM read_parquet('{cell_annotation}')"))
    ) |> 
      # left_join(cell_consensus, copy=TRUE) |>
      
      # Cells in cell_annotation could be more than cells in cell_consensus. In order to avoid NA happens in cell_consensus cell_type column
      mutate(cell_type_unified_ensemble = ifelse(cell_type_unified_ensemble |> is.na(),
                                                 "Unknown",
                                                 cell_type_unified_ensemble)) |>
      
      left_join(sample_chunk_df |> select(dataset_id, sample_chunk, sample_pseudobulk_chunk, cell_chunk, sample_id), copy=TRUE) |> 
      # # Make sure I cover cell type even if consensus of harmonisation is not present (it should be the vast minority)
      # mutate(temp_cell_type_label_for_file_id = if_else(cell_type_unified_ensemble |> is.na(), cell_type, cell_type_unified)) |> 
      # mutate(temp_cell_type_label_for_file_id = if_else(temp_cell_type_label_for_file_id |> is.na(), cell_type, temp_cell_type_label_for_file_id)) |> 
      # 
      # Define chunks
      group_by(dataset_id, sample_chunk, cell_chunk, sample_pseudobulk_chunk, cell_type_unified_ensemble, sample_id) |>
      summarise(cell_count = n(), .groups = "drop") |>
      group_by(dataset_id, sample_chunk, cell_chunk, cell_type_unified_ensemble) |>
      dbplyr::window_order(desc(cell_count)) |>
      mutate(chunk = cumsum(cell_count) %/% 20000 + 1) |> # max 20K cells per sample
      ungroup() |> 
      as_tibble() |> 
      
      # Single cell file ID
      mutate(file_id_cellNexus_single_cell = 
               glue::glue("{dataset_id}___{sample_chunk}___{cell_chunk}___{cell_type_unified_ensemble}") |> 
               sapply(digest::digest) |> 
               paste0("___", chunk, ".h5ad") 
      ) |> 
      
      # seudobulk file id
      #mutate(file_id_cellNexus_pseudobulk = paste0(dataset_id, ".h5ad"))
      mutate(file_id_cellNexus_pseudobulk = 
               glue::glue("{dataset_id}___{sample_pseudobulk_chunk}") |> 
               sapply(digest::digest) |>
               paste0("___", chunk, ".h5ad"))
    
  }
  
  
  # FOR MENGYUAN CELL_METADATA COULD BE BIGGER THAN CELL_ANNOTATION
  
  get_file_ids(
    "/vast/scratch/users/shen.m/cellNexus_run/cell_annotation.parquet"
    # "/vast/scratch/users/shen.m/Census_final_run/cell_annotation_new_substitute_cell_type_na_to_unknown_2.parquet"
  )  |> 
    write_parquet("/vast/scratch/users/shen.m/cellNexus_run/file_id_cellNexus_single_cell.parquet")
  
  gc()
  
  con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  
  # Create a view for cell_annotation in DuckDB
  dbExecute(con, "
  CREATE VIEW cell_metadata AS
  SELECT 
    CONCAT(cell_, '___', dataset_id) AS cell_,
    dataset_id,
    *
  FROM read_parquet('/vast/scratch/users/shen.m/cellNexus_run/cell_metadata.parquet')
")
  
  # Create views for other tables
  #   dbExecute(con, "
  #   CREATE VIEW cell_consensus AS
  #   SELECT *
  #   FROM read_parquet('/vast/scratch/users/shen.m/Census_final_run/cell_annotation_new_substitute_cell_type_na_to_unknown_2.parquet')
  # ")
  
  dbExecute(con, "
  CREATE VIEW cell_annotation AS
  SELECT cell_, blueprint_first_labels_fine, monaco_first_labels_fine, azimuth_predicted_celltype_l2
  FROM read_parquet('/vast/scratch/users/shen.m/cellNexus_run/annotation_tbl_light.parquet')
")
  
  dbExecute(con, "
  CREATE VIEW empty_droplet_df AS
  SELECT *
  FROM read_parquet('/vast/scratch/users/shen.m/cellNexus_run/cell_annotation.parquet')
")
  
  dbExecute(con, "
  CREATE VIEW file_id_cellNexus_single_cell AS
  SELECT dataset_id, sample_chunk, cell_chunk, sample_pseudobulk_chunk, cell_type_unified_ensemble, sample_id, file_id_cellNexus_single_cell, file_id_cellNexus_pseudobulk
  FROM read_parquet('/vast/scratch/users/shen.m/cellNexus_run/file_id_cellNexus_single_cell.parquet')
")
  
  #   # This DF is needed to filter out unmatched sample-cell-type combo. Otherwise, cellNexus get_pseudobulk will slice cell names out of bounds.
  #   dbExecute(con, "
  #   CREATE VIEW sample_cell_type_combo AS
  #   SELECT dataset_id, sample_id, cell_type_unified_ensemble
  #   FROM read_parquet('/vast/scratch/users/shen.m/Census_final_run/cell_type_concensus_tbl_from_hpcell.parquet')
  # ")
  
  # Perform the left join and save to Parquet
  copy_query <- "
  COPY (
     SELECT 
        cell_metadata.cell_ AS cell_id, -- Rename cell_ to cell_id
        cell_metadata.*,              -- Include all other columns from cell_metadata
        cell_annotation.*,            -- Include all columns from cell_annotation
        empty_droplet_df.*,           -- Include all columns from empty_droplet_df
        file_id_cellNexus_single_cell.*, -- Include all columns from file_id_cellNexus_single_cell
        atlas_id                      -- Specify the atlas name 
      FROM cell_metadata
    
      LEFT JOIN cell_annotation
        ON cell_annotation.cell_ = cell_metadata.cell_
        
      LEFT JOIN empty_droplet_df
        ON empty_droplet_df.cell_ = cell_metadata.cell_
        AND empty_droplet_df.dataset_id = cell_metadata.dataset_id
    
      LEFT JOIN file_id_cellNexus_single_cell
        ON file_id_cellNexus_single_cell.sample_id = empty_droplet_df.sample_id
        AND file_id_cellNexus_single_cell.dataset_id = empty_droplet_df.dataset_id
        AND file_id_cellNexus_single_cell.cell_type_unified_ensemble = empty_droplet_df.cell_type_unified_ensemble
        
      WHERE cell_metadata.dataset_id NOT IN ('99950e99-2758-41d2-b2c9-643edcdf6d82', '9fcb0b73-c734-40a5-be9c-ace7eea401c9')  -- (THESE TWO DATASETS DOESNT contain meaningful data - no observation_joinid etc), thus was excluded in the final metadata.
        
  ) TO  '/vast/scratch/users/shen.m/cellNexus_run/test.parquet'
  -- '/vast/scratch/users/shen.m/cellNexus_run/cell_metadata_cell_type_consensus_v1_0_12_mengyuan.parquet'
  (FORMAT PARQUET, COMPRESSION 'gzip');
"
  
  # Execute the final query to write the result to a Parquet file
  dbExecute(con, copy_query)
  
  # Disconnect from the database
  dbDisconnect(con, shutdown = TRUE)
  
  #system("~/bin/rclone copy /vast/projects/cellxgene_curated/cellNexus/cell_metadata_cell_type_consensus_v1_0_4.parquet box_adelaide:/Mangiola_ImmuneAtlas/taskforce_shared_folder/")
  
  print("Done.")
})

cell_metadata = 
  tbl(
    dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
    sql("SELECT * FROM read_parquet('/vast/scratch/users/shen.m/cellNexus_run/cell_metadata_cell_type_consensus_v1_0_12_mengyuan.parquet')")
  )

library(targets)
library(tidyverse)
store_file_cellNexus = "/vast/scratch/users/shen.m/targets_prepare_database_split_datasets_chunked_1_0_12_single_cell"

tar_script({
  library(dplyr)
  library(magrittr)
  library(tibble)
  library(targets)
  library(tarchetypes)
  library(crew)
  library(crew.cluster)
  tar_option_set(
    memory = "transient", 
    garbage_collection = 100, 
    storage = "worker", 
    retrieval = "worker", 
    error = "continue", 
    cue = tar_cue(mode = "never"),
    #debug = "dataset_id_sce", 
    
    workspace_on_error = TRUE,
    controller = crew_controller_group(
      list(
        crew_controller_slurm(
          name = "elastic",
          workers = 300,
          tasks_max = 20,
          seconds_idle = 30,
          crashes_error = 10,
          options_cluster = crew_options_slurm(
            memory_gigabytes_required = c(10, 20, 40, 80, 160), 
            cpus_per_task = c(2, 2, 5, 10, 20), 
            time_minutes = c(30, 30, 30, 60*4, 60*24),
            verbose = T
          )
        ),
        
        crew_controller_slurm(
          name = "tier_1", 
          script_lines = "#SBATCH --mem 8G",
          slurm_cpus_per_task = 1, 
          workers = 300, 
          tasks_max = 50,
          verbose = T,
          crashes_error = 5, 
          seconds_idle = 30
        ),
        
        crew_controller_slurm(
          name = "tier_2",
          script_lines = "#SBATCH --mem 10G",
          slurm_cpus_per_task = 1,
          workers = 300,
          tasks_max = 10,
          verbose = T,
          crashes_error = 5, 
          seconds_idle = 30
        ),
        crew_controller_slurm(
          name = "tier_3",
          script_lines = "#SBATCH --mem 20G",
          slurm_cpus_per_task = 1,
          workers = 200,
          tasks_max = 10,
          verbose = T,
          crashes_error = 5, 
          seconds_idle = 30
        ),
        crew_controller_slurm(
          name = "tier_4",
          workers = 200,
          tasks_max = 10,
          crashes_error = 5, 
          seconds_idle = 30,
          options_cluster = crew_options_slurm(
            memory_gigabytes_required = c(40, 80, 160, 240), 
            cpus_per_task = c(2), 
            time_minutes = c(60*24),
            verbose = T
          )
        ),
        crew_controller_slurm(
          name = "tier_5",
          script_lines = "#SBATCH --mem 400G",
          slurm_cpus_per_task = 1,
          workers = 2,
          tasks_max = 10,
          verbose = T,
          crashes_error = 5, 
          seconds_idle = 30
        )
      )
    ), 
    trust_object_timestamps = TRUE
    #workspaces = "dataset_id_sce_52dbec3c15f98d66"
  )
  
  
  save_anndata = function(dataset_id_sce, cache_directory){
    
    dir.create(cache_directory, showWarnings = FALSE, recursive = TRUE)
    
    # # Parallelise
    # cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
    # bp <- MulticoreParam(workers = cores , progressbar = TRUE)  # Adjust the number of workers as needed
    # 
    
    
    
    .x = dataset_id_sce |> pull(sce) |> _[[1]]
    .y = dataset_id_sce |> pull(file_id_cellNexus_single_cell) |> _[[1]] |> str_remove("\\.h5ad")
    
    .x |> assays() |> names() = "counts"
    
    # # Check if the 'sce' has only one cell (column)
    # if(ncol(assay(.x)) == 1) {
    #   
    #   # Duplicate the assay to prevent saving errors due to single-column matrices
    #   my_assay = cbind(assay(.x), assay(.x))
    #   # Rename the second column to distinguish it
    #   colnames(my_assay)[2] = paste0("DUMMY", "___", colnames(my_assay)[2])
    #   
    #   cd = colData(.x)
    #   cd = cd |> rbind(cd)
    #   rownames(cd)[2] = paste0("DUMMY", "___", rownames(cd)[2])
    #   
    #   
    #   
    #   .x =  SingleCellExperiment(assay = list( counts = my_assay ), colData = cd) 
    # } 
    # 
    # 
    # # TEMPORARY FOR SOME REASON THE MIN COUNTS IS NOT 0 FOR SOME SAMPLES
    # .x = HPCell:::check_if_assay_minimum_count_is_zero_and_correct_TEMPORARY(.x, assays(.x) |> names() |> _[1], subset_up_to_number_of_cells = 100)
    # 
    # .x =  SingleCellExperiment(assay = list( counts = .x |> assay()), colData = colData(.x)) 
    
    
    # My attempt to save a integer, sparse, delayed matrix (with zellkonverter it is not possible to save integers)
    # .x |> assay() |> type() <- "integer"
    # .x |> saveHDF5SummarizedExperiment("~/temp", as.sparse = T, replace = T)
    
    # Save the experiment data to the specified counts cache directory
    .x |> save_experiment_data(glue("{cache_directory}/{.y}"))
    
    return(TRUE)  # Indicate successful saving
    
    
  }
  
  # Because they have an inconsistent failure. If I start the pipeline again they might work. Strange.
  insistent_save_anndata <- purrr::insistently(save_anndata, rate = purrr::rate_delay(pause = 60, max_times = 3), quiet = FALSE)
  
  save_anndata_cpm = function(dataset_id_sce, cache_directory){
    
    dir.create(cache_directory, showWarnings = FALSE, recursive = TRUE)
    
    # # Parallelise
    # cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
    # bp <- MulticoreParam(workers = cores , progressbar = TRUE)  # Adjust the number of workers as needed
    # 
    dataset_id_sce |> 
      purrr::transpose() |> 
      lapply(
        FUN = function(x) {
          
          .x = x[[2]]
          .y = x[[1]] |> str_remove("\\.h5ad")
          
          # Check if the 'sce' has only one cell (column)
          if(ncol(assay(.x)) == 1) {
            
            # Duplicate the assay to prevent saving errors due to single-column matrices
            my_assay = cbind(assay(.x), assay(.x))
            # Rename the second column to distinguish it
            colnames(my_assay)[2] = paste0("DUMMY", "___", colnames(my_assay)[2])
            
            cd = colData(.x)
            cd = cd |> rbind(cd)
            rownames(cd)[2] = paste0("DUMMY", "___", rownames(cd)[2])
            
            
            
            .x =  SingleCellExperiment(assay = list( my_assay ) |> set_names(names(assays(.x))[1]), colData = cd) 
          } 
          
          
          # TEMPORARY FOR SOME REASON THE MIN COUNTS IS NOT 0 FOR SOME SAMPLES
          .x = HPCell:::check_if_assay_minimum_count_is_zero_and_correct_TEMPORARY(.x, assays(.x) |> names() |> _[1], subset_up_to_number_of_cells = 100)
          
          # CALCULATE CPM
          .x =  SingleCellExperiment(assay = list( cpm = calculateCPM(.x, assay.type = names(assays(.x))[1])), colData = colData(.x)) 
          
          # My attempt to save a integer, sparse, delayed matrix (with zellkonverter it is not possible to save integers)
          # .x |> assay() |> type() <- "integer"
          # .x |> saveHDF5SummarizedExperiment("~/temp", as.sparse = T, replace = T)
          
          # Save the experiment data to the specified counts cache directory
          .x |> save_experiment_data(glue("{cache_directory}/{.y}"))
          
          return(TRUE)  # Indicate successful saving
        }
        #,
        #BPPARAM = bp  # Use the defined parallel backend
      )
    
    return("saved")
    
  }
  
  # Because they have an inconsistent failure. If I start the pipeline again they might work. Strange.
  insistent_save_anndata_cpm <- purrr::insistently(save_anndata_cpm, rate = purrr::rate_delay(pause = 60, max_times = 3), quiet = FALSE)
  
  
  # Function to process matrix in vertical slices
  process_matrix_in_slices <- function(h5_matrix, output_filepath, output_filepath_temp, chunk_size = 1000) {
    # Load the HDF5 matrix
    n_rows <- dim(h5_matrix)[1]
    n_cols <- dim(h5_matrix)[2]
    
    if (file.exists(output_filepath)) {
      file.remove(output_filepath)
      cat("Existing output file removed.\n")
    }
    if (file.exists(output_filepath_temp)) {
      file.remove(output_filepath_temp)
      cat("Existing output file removed.\n")
    }
    
    # Create an empty list to hold the slices
    slice_list <- list()
    
    # Loop through the matrix in chunks
    for (start_col in seq(1, n_cols, by = chunk_size)) {
      end_col <- min(start_col + chunk_size - 1, n_cols)
      cat("Processing columns", start_col, "to", end_col, "\n")
      
      # Extract a slice of the matrix
      matrix_slice <- as.matrix(h5_matrix[, start_col:end_col, drop=FALSE])
      
      # Calculate ranks for the slice
      ranked_slice <- singscore::rankGenes(matrix_slice)  %>% `-` (1) 
      
      # Convert the ranked slice to sparse format
      sparse_ranked_slice <- as(ranked_slice, "CsparseMatrix")
      
      # Write the slice to the output HDF5 file
      HDF5Array::writeHDF5Array(
        sparse_ranked_slice,
        filepath = output_filepath_temp,
        name = paste0("rank_", start_col, "_to_", end_col),
        as.sparse = TRUE,
        H5type = "H5T_STD_I32LE"
      ) 
      
      # Store the slice name for later binding
      slice_list[[length(slice_list) + 1]] <- paste0("rank_", start_col, "_to_", end_col)
    }
    
    
    slice_list |> map(~HDF5Array::HDF5Array(output_filepath_temp, name =.x)) |> do.call(cbind, args=_)
    
    # # Bind all slices into a single HDF5 dataset
    # for (i in seq_along(slice_list)) {
    #   slice <- HDF5Array::HDF5Array(output_filepath_temp, name = slice_list[[i]])
    #   if (i == 1) {
    #     final_matrix <- slice
    #   } else {
    #     final_matrix <- cbind(final_matrix, slice)
    #   }
    # }
    
    # # Save the final matrix back to the HDF5 file
    # result_matrix = 
    #   HDF5Array::writeHDF5Array(
    #     final_matrix,
    #     filepath = output_filepath,
    #     name = "final_ranked_matrix",
    #     as.sparse = TRUE,
    #     H5type = "H5T_STD_I32LE"
    #   )
    # 
    # file.remove(output_filepath_temp)
    # 
    # result_matrix
  }
  
  save_rank_per_cell = function(dataset_id_sce, cache_directory){
    
    dir.create(cache_directory, recursive = TRUE, showWarnings = FALSE)
    
    # # Parallelise
    # cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
    # bp <- MulticoreParam(workers = cores , progressbar = TRUE)  # Adjust the number of workers as needed
    # 
    
    .x = dataset_id_sce |> pull(sce) |> _[[1]]
    .y = dataset_id_sce |> pull(file_id_cellNexus_single_cell) |> _[[1]] |> str_remove("\\.h5ad")
    #.y = dataset_id_sce |> pull(file_id_cellNexus_pseudobulk) |> _[[1]] |> str_remove("\\.h5ad")
    
    # Check if the 'sce' has only one cell (column)
    if(ncol(assay(.x)) == 1) {
      
      # Duplicate the assay to prevent saving errors due to single-column matrices
      my_assay = cbind(assay(.x), assay(.x))
      # Rename the second column to distinguish it
      colnames(my_assay)[2] = paste0("DUMMY", "___", colnames(my_assay)[2])
      
      cd = colData(.x)
      cd = cd |> rbind(cd)
      rownames(cd)[2] = paste0("DUMMY", "___", rownames(cd)[2])
      
      
      
      .x =  SingleCellExperiment(assay = list( my_assay ) |> set_names(names(assays(.x))[1]), colData = cd) 
    } 
    
    
    # TEMPORARY FOR SOME REASON THE MIN COUNTS IS NOT 0 FOR SOME SAMPLES
    .x = HPCell:::check_if_assay_minimum_count_is_zero_and_correct_TEMPORARY(.x, assays(.x) |> names() |> _[1], subset_up_to_number_of_cells = 100)
    
    print("start ranking")
    
    # CALCULATE rank
    rank_assay = 
      .x |>
      assay() |> 
      
      # This because some datasets are still > 1M cells
      process_matrix_in_slices(
        paste(c(cache_directory, "/", .y, "_rank_matrix.HDF5Array"), collapse = ""), 
        paste(c(cache_directory, "/", .y, "_rank_matrix_temp.HDF5Array"), collapse = ""), 
        chunk_size = 1000
      )
    
    print("creating SCE")
    
    .x =  SingleCellExperiment(assay = list( rank = rank_assay), colData = colData(.x)) 
    
    print("saving")
    
    .x |> save_experiment_data(glue("{cache_directory}/{.y}"))
    
    return(TRUE)  # Indicate successful saving
    
    
    
    
  }
  
  # Because they have an inconsistent failure. If I start the pipeline again they might work. Strange.
  insistent_save_rank_per_cell <- purrr::insistently(save_rank_per_cell, rate = purrr::rate_delay(pause = 60, max_times = 3), quiet = FALSE)
  
  
  cbind_sce_by_dataset_id = function(target_name_grouped_by_dataset_id, file_id_db_file, my_store){
    
    my_dataset_id = unique(target_name_grouped_by_dataset_id$dataset_id) 
    
    file_id_db = 
      tbl(
        dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
        sql(glue("SELECT * FROM read_parquet('{file_id_db_file}')"))
      ) |> 
      filter(dataset_id == my_dataset_id) |>
      select(cell_id, sample_id, dataset_id, file_id_cellNexus_single_cell) 
    # |> 
    #   
    #   # Drop extension because it is added later 
    #   mutate(file_id_cellNexus_single_cell = file_id_cellNexus_single_cell |> str_remove("\\.h5ad")) |> 
    #   as_tibble()
    
    file_id_db = 
      target_name_grouped_by_dataset_id |> 
      left_join(file_id_db, copy = TRUE)
    
    
    # Parallelise
    cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
    bp <- MulticoreParam(workers = cores , progressbar = TRUE)  # Adjust the number of workers as needed
    
    # Begin processing the data pipeline with the initial dataset 'target_name_grouped_by_dataset_id'
    sce_df = 
      file_id_db |> 
      nest(cells = cell_id) |> 
      # Step 1: Read raw data for each 'target_name' and store it in a new column 'sce'
      mutate(
        sce = bplapply(
          target_name,
          FUN = function(x) tar_read_raw(x, store = my_store),  # Read the raw SingleCellExperiment object
          BPPARAM = bp  # Use the defined parallel backend
        )
      ) |>
      
      # This should not be needed, but there are some data sets with zero cells 
      filter(!map_lgl(sce, is.null)) |> 
      
      mutate(sce = map2(sce, cells, ~ .x |> filter(.cell %in% .y$cell_id) |>
                          
                          # TEMPORARY FIX. NEED TO INVESTIGATE WHY THE SUFFIX HAPPENS
                          mutate(sample_id = stringr::str_replace(sample_id, ".h5ad$","")),
                        
                        .progress = TRUE))
    
    
    
    if(nrow(sce_df) == 0) {
      warning("this chunk has no rows for somereason.")
      return(NULL)
    }
    
    # plan(multisession, workers = 20)
    sce_df |> 
      
      # # Step 4: Group the data by 'dataset_id' and 'tar_group' for further summarization
      # group_by(dataset_id, tar_group, chunk) |>
      # 
      
      # FORCEFULLY drop all but counts and metadata 
      # int_colData(.x) = DataFrame(row.names = colnames(.x))
      # Creates error
      # THIS SHOULD HAVE BEEN DONE IN THE TRANFORM HPCell
      mutate(sce = map(sce, ~  SingleCellExperiment(assay = assays(.x), colData = colData(.x)) )) |> 
      
      # Step 5: Combine all 'sce' objects within each group into a single 'sce' object
      group_by(file_id_cellNexus_single_cell) |> 
      summarise( sce =  list(do.call(cbind, args = sce) ),
                 
                 # A steo to check missing cells 
                 cells = list(do.call(rbind, args = cells))) 
    
    # mutate(sce = map(sce,
    #                  ~ { .x = 
    #                    .x  |> 
    #                    left_join(file_id_db, by = join_by(.cell==cell_id, dataset_id==dataset_id, sample_id==sample_id)) 
    #                  .x |> 
    #                    HPCell:::splitColData(colData(.x)$file_id_cellNexus_single_cell) |>  # Split 'sce' by 'cell_type'
    #                    enframe(name = "file_id_cellNexus_single_cell", value = "sce")  # Convert to tibble with 'cell_type' and 'sce' columns
    #                  })) |> 
    # Step 8: Unnest the list of 'sce' objects to have one row per 'cell_type'
    # unnest_single_cell_experiment(sce) 
    
    
  }
  
  get_dataset_id = function(target_name, my_store){
    sce = tar_read_raw(target_name, store = my_store)
    
    if(sce |> is.null()) return(tibble(sample_id = character(), dataset_id= character(), target_name= target_name))
    
    sce |> 
      
      # TEMPORARY FIX. NEED TO INVESTIGATE WHY THE SUFFIX HAPPENS
      mutate(sample_id = stringr::str_replace(sample_id, ".h5ad$","")) |> 
      
      distinct(sample_id, dataset_id) |> mutate(target_name = !!target_name)
  }
  
  create_chunks_for_reading_and_saving = function(dataset_id_sample_id, cell_metadata){
    
    # Solve sample_id mismatches because some end with .h5ad suffix while others dont 
    dataset_id_sample_id |> 
      
      # TEMPORARY FIX. NEED TO INVESTIGATE WHY THE SUFFIX HAPPENS
      mutate(sample_id = stringr::str_replace(sample_id, ".h5ad$", "")) |>
      
      left_join(
        tbl(
          dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
          sql(glue("SELECT * FROM read_parquet('{cell_metadata}')"))
        )   |> 
          distinct(dataset_id, sample_id, sample_chunk, cell_chunk, file_id_cellNexus_single_cell) |> 
          as_tibble(), 
        copy=T
      )
  }
  
  
  cbind_sce_by_dataset_id_get_missing_cells = function(dataset_id_sce){
    
    dataset_id_sce |>
      mutate(
        missing_cells = map2(
          sce, 
          cells, 
          ~{
            cells_in_sce <- .x |> colnames() |> sort()
            
            cells_in_query <- .y$cell_id |> unique() |> sort()
            
            # Find differences
            tibble(cell_id = setdiff(cells_in_query, cells_in_sce))
          }
        )
      ) |> 
      select(file_id_cellNexus_single_cell, missing_cells)
    
  }
  
  
  list(
    
    # The input DO NOT DELETE
    tar_target(my_store, "/vast/scratch/users/shen.m/Census_final_run/target_store_for_pseudobulk", deployment = "main"),
    tar_target(cache_directory, "/vast/scratch/users/shen.m/cellNexus/cellxgene/03-06-2025", deployment = "main"),
    # This is the store for retrieving missing cells between cellnexus metadata and sce. A different store as it was done separately
    #tar_target(cache_directory, "/vast/scratch/users/shen.m/debug2/cellxgene/19-12-2024", deployment = "main"),
    tar_target(
      cell_metadata,
      "/vast/scratch/users/shen.m/cellNexus_run/cell_metadata_cell_type_consensus_v1_0_12_mengyuan.parquet", 
      packages = c( "arrow","dplyr","duckdb")
      
    ),
    
    tar_target(
      target_name,
      tar_meta(
        starts_with("sce_transformed_"), 
        store = my_store) |> 
        filter(type=="branch") |> 
        pull(name),
      deployment = "main"
    ),
    tar_target(
      dataset_id_sample_id,
      get_dataset_id(target_name, my_store),
      packages = "tidySingleCellExperiment",
      pattern = map(target_name),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "elastic")
      )
    ),
    
    
    tar_target(
      target_name_grouped_by_dataset_id,
      create_chunks_for_reading_and_saving(dataset_id_sample_id, cell_metadata) |> 
        
        # # FOR TESTING PURPOSE ONLY
        # filter(sample_id %in% c("de79c3b20c3ce64b0e8295f40282b896___expr2-human-651well.",
        #                         "b35fd94682b123804a542a72fe2d5b9f___exp1-human-69.")) |>
        
        group_by(dataset_id, sample_chunk, cell_chunk, file_id_cellNexus_single_cell) |>
        tar_group(),
      iteration = "group",
      resources = tar_resources(
        crew = tar_resources_crew(controller = "elastic")
      ), 
      packages = c("arrow", "duckdb", "dplyr", "glue", "targets")
      
    ),
    
    tar_target(
      dataset_id_sce,
      cbind_sce_by_dataset_id(target_name_grouped_by_dataset_id, cell_metadata, my_store = my_store),
      pattern = map(target_name_grouped_by_dataset_id),
      packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb",  "BiocParallel", "parallelly"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "tier_4")
      )
    ),
    
    # This target was run for retrieving missing cells analysis only
    tar_target(
      missing_cells_tbl,
      cbind_sce_by_dataset_id_get_missing_cells(dataset_id_sce),
      pattern = map(dataset_id_sce),
      packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb",  "BiocParallel", "parallelly", "purrr"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "tier_4")
      )
    ),
    
    
    tar_target(
      save_anndata,
      insistent_save_anndata(dataset_id_sce, paste0(cache_directory, "/counts")),
      pattern = map(dataset_id_sce),
      packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb", "BiocParallel", "parallelly"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "tier_4")
      )
    ),
    
    tar_target(
      saved_dataset_cpm,
      insistent_save_anndata_cpm(dataset_id_sce, paste0(cache_directory, "/cpm")),
      pattern = map(dataset_id_sce),
      packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb", "BiocParallel", "parallelly"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "tier_4")
      )
    ),
    
    tar_target(
      saved_dataset_rank,
      insistent_save_rank_per_cell(dataset_id_sce, paste0(cache_directory, "/rank")),
      pattern = map(dataset_id_sce),
      packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb", "BiocParallel", "parallelly", "HDF5Array"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = "tier_4")
      )
    )
  )
  
}, script = paste0(store_file_cellNexus, "_target_script.R"), ask = FALSE)

job::job({
  
  tar_make(
    script = paste0(store_file_cellNexus, "_target_script.R"), 
    store = store_file_cellNexus, 
    reporter = "summary" #, callr_function = NULL
  )
  
})

missing_cells_tbl = tar_read(missing_cells_tbl, store = store_file_cellNexus)
missing_cells_tbl <- map(missing_cells_tbl$missing_cells, ~ {.x}) |> bind_rows()
missing_cells <- missing_cells_tbl |> pull(cell_id)

cell_metadata |> filter(!cell_id %in% missing_cells) |> 
  
  # This method of save parquet to parquet is faster 
  cellNexus:::duckdb_write_parquet(path = "/vast/scratch/users/shen.m/cellNexus_run/cell_metadata_cell_type_consensus_v1_0_12_filtered_missing_cells_mengyuan.parquet")


# Copy files from scratch to vast project
files_to_copy <- c("annotation_tbl_light.parquet",
                   "cell_annotation.parquet", "cell_metadata_cell_type_consensus_v1_0_12_mengyuan.parquet",
                   "cell_metadata_cell_type_consensus_v1_0_12_filtered_missing_cells_mengyuan.parquet",
                   "cell_metadata.parquet",
                   "file_id_cellNexus_single_cell.parquet")

source_dir <- "/vast/scratch/users/shen.m/cellNexus_run/"
destination_dir <- "/vast/projects/cellxgene_curated/metadata_cellxgene_mengyuan/"

# Copy each file
sapply(files_to_copy, function(file) {
  file.copy(from = paste0(source_dir, file), 
            to = paste0(destination_dir, file))
})
