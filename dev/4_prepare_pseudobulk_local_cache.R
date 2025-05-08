# hpcell_target_xxx | sample_A | dataset_A
# hpcell_target_yyy | sample_B | dataset_B
# 
# 
# 

# read_taget_a |> filter cell type nk
# 
# if you have 1000 file_id_pseudobulk in metadata, you will launch 1000 targets that
# 
# read a list of targat files
# loop over read targets and filter the right cell type
# cbind all filtered data
# 
# do.call(cbind, ...)
# 
# first step
# 
# make a function that accepts a fil_id_pseudobulk and outputs a anndata
# function(file_id) {
#   
# }

# Need to run step 3 before step 4
library(targets)
library(tidyverse)
library(cellNexus)
store_file_cellNexus = "/vast/scratch/users/shen.m/targets_prepare_database_split_datasets_chunked_1_0_11_pseudobulk"
my_store = "/vast/scratch/users/shen.m/Census_final_run/target_store_for_pseudobulk"

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
            memory_gigabytes_required = c(40, 60, 80, 120, 160), 
            #memory_gigabytes_required = c(200, 300, 350, 400, 500), 
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
            memory_gigabytes_required = c(40, 80, 100, 150, 240), 
            #memory_gigabytes_required = c(200, 250, 350, 450), 
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
get_dataset_id = function(target_name, my_store){
  sce = tar_read_raw(target_name, store = my_store)
  
  if(sce |> is.null()) return(tibble(sample_id = character(), dataset_id= character(), 
                                     target_name= target_name))
  
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
        distinct(sample_id, sample_pseudobulk_chunk, cell_chunk, 
                 cell_type_unified_ensemble,
                 file_id_cellNexus_pseudobulk) |> 
        as_tibble(), 
      copy=T
    )
}


cbind_sce_by_dataset_id = function(target_name_grouped_by_dataset_id, 
                                   file_id_db_file, my_store){
  
  #my_dataset_id = unique(target_name_grouped_by_dataset_id$dataset_id) 
  my_cell_type = unique(target_name_grouped_by_dataset_id$cell_type_unified_ensemble)
  
  file_id_db = 
    tbl(
      dbConnect(duckdb::duckdb(), dbdir = ":memory:"),
      sql(glue("SELECT * FROM read_parquet('{file_id_db_file}')"))
    ) |> 
    #dplyr::filter(dataset_id == my_dataset_id) |>
    dplyr::filter(cell_type_unified_ensemble %in% my_cell_type) |>
    select(sample_id, dataset_id, cell_type_unified_ensemble,
           file_id_cellNexus_pseudobulk) 

  
  file_id_db = 
    target_name_grouped_by_dataset_id |> 
    left_join(file_id_db, copy = TRUE)
  
  
  # Parallelise
  cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))
  bp <- MulticoreParam(workers = cores , progressbar = TRUE)  # Adjust the number of workers as needed
  
  # Begin processing the data pipeline with the initial dataset 'target_name_grouped_by_dataset_id'
  sce_df = 
    file_id_db |> 
    mutate(cell_id = paste(sample_id, cell_type_unified_ensemble, sep = "___")) |>
    nest(cells = cell_id) |> 
    # Step 1: Read raw data for each 'target_name' and store it in a new column 'sce'
    mutate(
      sce = bplapply(
        target_name,
        FUN = function(x) tar_read_raw(x, store = my_store) ,
        # |># Read the raw SingleCellExperiment object
        #   # Mengyuan : Temp fix (THIS SHOULD BE DONE IN PSEUDOBULK HPCELL)
        #   mutate(cell_type_unified_ensemble = ifelse(is.na(cell_type_unified_ensemble),
        #                                              "unknown",
        #                                              cell_type_unified_ensemble))
        #   },
          
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
  sce_df = sce_df |> 
    
    # THIS SHOULD HAVE BEEN DONE IN THE TRANFORM HPCell
    mutate(sce = map(sce, ~  SingleCellExperiment(assay = assays(.x), colData = colData(.x)) ))
   
  
  # Extra Step 1: Harmonize colData columns - Avoid column name mismatch, force cbind
  all_col_names <- sce_df$sce %>%
    map(~colnames(colData(.x))) %>% 
    unlist() %>% 
    unique()
  
  # Extra Step 2: Standardize colData to have the same columns in each SCE
  sce_df$sce <- map(sce_df$sce, function(sce) {
    current_cols <- colnames(colData(sce))
    missing_cols <- setdiff(all_col_names, current_cols)

    if (length(missing_cols) > 0) {
      
      # Fill missing colData columns with NA
      for (col in missing_cols) {
        # Handle sce with empty cells
        if (ncol(sce) == 0)  colData(sce)[, col] <- character(0)
        else if (ncol(sce) > 0) colData(sce)[, col] <- NA
      }
    }
    
    # Ensure the order of columns matches
    colData(sce) <- colData(sce)[, all_col_names]
    return(sce)
  })
  
  sce_df |>
    
    # Step 5: Combine all 'sce' objects within each group into a single 'sce' object
    group_by(file_id_cellNexus_pseudobulk) |>
    summarise( sce =  list(do.call(cbind, args = sce) ) ) 
  
}



save_anndata = function(dataset_id_sce, cache_directory){
  
  dir.create(cache_directory, showWarnings = FALSE, recursive = TRUE)
  
  .x = dataset_id_sce |> pull(sce) |> _[[1]]
  .y = dataset_id_sce |> pull(file_id_cellNexus_pseudobulk) |> _[[1]] |> str_remove("\\.h5ad")
  
  .x |> assays() |> names() = "counts"
  
  # Check if there is a memory issue 
  assays(.x) <- assays(.x) |> map(DelayedArray::realize)

  # Save the experiment data to the specified counts cache directory
  .x |> save_experiment_data(glue("{cache_directory}/{.y}"))
  
  return(TRUE)  # Indicate successful saving
  
}

# Because they have an inconsistent failure. If I start the pipeline again they might work. Strange.
insistent_save_anndata <- purrr::insistently(save_anndata, rate = purrr::rate_delay(pause = 60, max_times = 3), quiet = FALSE)

list(
  
  # The input DO NOT DELETE
  tar_target(my_store, "/vast/scratch/users/shen.m/Census_final_run/target_store_for_pseudobulk", deployment = "main"),
  tar_target(cache_directory, "/vast/scratch/users/shen.m/cellNexus/cellxgene/01-05-2025/pseudobulk", deployment = "main"),
  tar_target(
    cell_metadata,
    "/vast/scratch/users/shen.m/cellNexus_run/cell_metadata_cell_type_consensus_v1_0_11_mengyuan.parquet", 
    packages = c( "arrow","dplyr","duckdb")
    
  ),
  tar_target(
    target_name,
    tar_meta(
      starts_with("pseudobulk_se_iterated_"), 
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
      # filter(file_id_cellNexus_pseudobulk %in% c("9722bedfd71d069fe3665b4ae03fbeb9___2.h5ad",
      #                                            "2996bb4263f9fb301d8460f4f0450848___2.h5ad")) |>

      group_by(dataset_id,
               sample_pseudobulk_chunk, 
               # When using strategy file_id = dataset_id, dont group by cell_chunk as it will result in returning more than one SCEs for the same dataset_id
               #cell_chunk, 
               file_id_cellNexus_pseudobulk) |>
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
  tar_target(
    get_pseudobulk,
    insistent_save_anndata(dataset_id_sce, paste0(cache_directory, "/counts")),
    pattern = map(dataset_id_sce),
    packages = c("tidySingleCellExperiment", "SingleCellExperiment", "tidyverse", "glue", "digest", "HPCell", "digest", "scater", "arrow", "dplyr", "duckdb", "BiocParallel", "parallelly"),
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

# Then run 5_unify_and_update_sce_metadata.R
