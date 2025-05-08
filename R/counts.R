# Functions that relate to downloading count data into SingleCellExperiments

# We need to load utils now so it can be used at the top level
#' @include utils.R
# This is a hack to force Seurat packages to be loaded, and also to
# satisfy R CMD check. We don't need to attach them at all.
#' @importFrom Seurat as.SingleCellExperiment
NULL

# Maps user provided assay names to their corresponding paths in the repository
assay_map <- c(
  counts = "counts",
  cpm = "cpm",
  rank = "rank"
)

#' Base URL pointing to the count data at the current version
#' @noRd
COUNTS_URL <- single_line_str(
  "https://object-store.rc.nectar.org.au/v1/
    AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata"
)

#' @inherit get_single_cell_experiment
#' @inheritDotParams get_single_cell_experiment
#' @importFrom cli cli_alert_warning
#' @export
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_SingleCellExperiment <- function(...){
  single_line_str("This function name is deprecated. 
                    Please use `get_single_cell_experiment()` instead") |>
    cli_alert_warning()
  
  get_single_cell_experiment(...)
}

#' Gets a SingleCellExperiment from curated metadata
#' 
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SingleCellExperiment::SingleCellExperiment-class`] object
#' corresponding to the samples in that data frame
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_single_cell` 
#'   and `atlas_id` columns, which correspond to a single cell ID, file subdivision for internal use,
#'   and atlas name in format (e.g cellxgene/06-02-2025) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#' @param assays A character vector specifying the desired assay(s) to be requested. 
#'   Valid elements include "counts", "cpm", and "rank" for single-cell analyses, or 
#'   "counts" for pseudobulk analyses. 
#'   The default setting retrieves only the counts assay.
#'   If your analysis involves a smaller set of genes, consider using the "cpm" assay. 
#'   The "rank" assay is suited for signature calculations across millions of cells.
#' @param cell_aggregation A character vector that specifies which cell aggregation 
#'   strategy should be applied. This will create a corresponding subdirectory 
#'   in the cache directory. Single cell level is applied by default. 
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter as_tibble inner_join collect transmute
#' @importFrom tibble column_to_rownames
#' @importFrom purrr reduce map map_int imap pmap
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom assertthat assert_that has_name
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @examples
#' meta <- get_metadata() |> head(2)
#' sce <- get_single_cell_experiment(meta)
#' @export
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_single_cell_experiment <- function(data, 
                                       assays = "counts",
                                       cell_aggregation = "",
                                       cache_directory = get_default_cache_dir(),
                                       repository = COUNTS_URL,
                                       features = NULL){
  raw_data <- collect(data)
  assert_that(
    inherits(raw_data, "tbl"),
    has_name(raw_data, c("cell_id", "file_id_cellNexus_single_cell", "atlas_id"))
  )
  
  atlas_name <- raw_data |> distinct(atlas_id) |> pull()
  parameter_validation_list <- 
    validate_data(data, assays, cell_aggregation, cache_directory, 
                  repository, features)
  
  versioned_cache_directory <- parameter_validation_list$cache_directory
  atlas_name <- parameter_validation_list$atlas_name
  grouping_column <- "file_id_cellNexus_single_cell"
  
  subdirs <- assay_map[assays]
  
  # The repository is optional. If not provided we load only from the cache
  if (!is.null(repository)) {
    cli_alert_info("Synchronising files")
    parsed_repo <- parse_url(repository)
    parsed_repo$scheme |>
      `%in%`(c("http", "https")) |>
      assert_that()
    
    files_to_read <-
      raw_data |> 
      transmute(
        files = .data[[grouping_column]], 
        atlas_name = atlas_id, 
        cache_dir = cache_directory
      ) |>  distinct() |> 
      pmap(function(files, atlas_name, cache_dir) {
        sync_assay_files(
          files = files,
          atlas_name = atlas_name,
          cache_dir = cache_dir,
          url = parsed_repo,
          cell_aggregation = cell_aggregation,
          subdirs = subdirs
        )
      })
  }
  
  cli_alert_info("Reading files.")
  experiments <- subdirs |>
    imap(function(current_subdir, current_assay) {
      # Build up an experiment for each assay
      dir_prefix <- file.path(
        versioned_cache_directory,
        current_subdir
      )
      
      experiment_list <- raw_data |> 
        mutate(dir_prefix = file.path(cache_directory, atlas_id, current_subdir)) |>
        dplyr::group_by(.data[[grouping_column]], dir_prefix) |>
        dplyr::summarise(experiments = list(
          group_to_data_container(
            dplyr::cur_group_id(),
            dplyr::cur_data_all(),
            unique(dir_prefix),
            features,
            grouping_column
          )
        )) |>
        dplyr::pull(experiments)
      
      commonGenes <- experiment_list |> check_gene_overlap()
      experiment_list <- map(experiment_list, function(exp) {
        exp[commonGenes,]
      }) |>
        do.call(cbind, args = _)
    })
  
  cli_alert_info("Compiling Experiment.")
  
  # Combine all the assays
  # Get a donor SCE
  experiment <- experiments[[1]]
  
  SummarizedExperiment::assays(experiment) <- map(experiments, function(exp) {
    SummarizedExperiment::assays(exp)[[1]]
  })
  
  experiment
}

#' Gets a Pseudobulk from curated metadata
#' 
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SummarizedExperiment::SummarizedExperiment-class`] object
#' corresponding to the samples in that data frame
#' 
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_pseudobulk`, 
#'   `sample_id`, `cell_type_unified_ensemble`, `atlas_id` columns, which correspond to a single cell ID,
#'   file subdivision for internal use, a singlel cell sample ID, harmonised cell type, 
#'   and atlas name in format (e.g cellxgene/06-02-2025) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#' @param assays A character vector specifying the desired assay(s) to be requested. 
#'   Valid elements include "counts", "cpm", and "rank" for single-cell analyses, or 
#'   "counts" for pseudobulk analyses. 
#'   The default setting retrieves only the counts assay.
#'   If your analysis involves a smaller set of genes, consider using the "cpm" assay. 
#'   The "rank" assay is suited for signature calculations across millions of cells.
#' @param cell_aggregation A character vector that specifies which cell aggregation 
#'   strategy should be applied. This will create a corresponding subdirectory 
#'   in the cache directory. 
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter as_tibble inner_join collect transmute
#' @importFrom tibble column_to_rownames
#' @importFrom purrr reduce map map_int imap 
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom assertthat assert_that
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @examples
#' \dontrun{
#' meta <- get_metadata() |> filter(tissue_harmonised == "lung")
#' pseudobulk <- meta |> get_pseudobulk()
#' }
#' @export
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_pseudobulk <- function(data, 
                           assays = "counts",
                           cell_aggregation = "pseudobulk",
                           cache_directory = get_default_cache_dir(),
                           repository = COUNTS_URL,
                           features = NULL) {
  raw_data <- collect(data)
  assert_that(
    inherits(raw_data, "tbl"),
    has_name(raw_data, c("cell_id", "file_id_cellNexus_pseudobulk", "sample_id", "cell_type_unified_ensemble",
                         "atlas_id"))
  )
  atlas_name <- raw_data |> distinct(atlas_id) |> pull()
  parameter_validation_list <- 
    validate_data(data, assays, cell_aggregation, cache_directory, 
                  repository, features)
  
  versioned_cache_directory <- parameter_validation_list$cache_directory
  atlas_name <- parameter_validation_list$atlas_name
  grouping_column <- "file_id_cellNexus_pseudobulk"
  
  subdirs <- assay_map[assays]
  
  # The repository is optional. If not provided we load only from the cache
  if (!is.null(repository)) {
    cli_alert_info("Synchronising files")
    parsed_repo <- parse_url(repository)
    parsed_repo$scheme |>
      `%in%`(c("http", "https")) |>
      assert_that()
    
    files_to_read <-
      raw_data |> 
      transmute(
        files = .data[[grouping_column]], 
        atlas_name = atlas_id, 
        cache_dir = cache_directory
      ) |> distinct() |>
      pmap(function(files, atlas_name, cache_dir) {
        sync_assay_files(
          files = files,
          atlas_name = atlas_name,
          cache_dir = cache_dir,
          url = parsed_repo,
          cell_aggregation = cell_aggregation,
          subdirs = subdirs
        )
      })
  }
  
  cli_alert_info("Reading files.")
  experiments <- subdirs |>
    imap(function(current_subdir, current_assay) {
      # Build up an experiment for each assay
      dir_prefix <- file.path(
        versioned_cache_directory,
        current_subdir
      )
      experiment_list <- raw_data |>
        mutate(dir_prefix = dir_prefix) |>
        dplyr::group_by(.data[[grouping_column]], dir_prefix) |>
        dplyr::summarise(experiments = list(
          group_to_data_container(
            dplyr::cur_group_id(),
            dplyr::cur_data_all(),
            unique(dir_prefix),
            features,
            grouping_column
          )
        )) |>
        dplyr::pull(experiments)
      
      commonGenes <- experiment_list |> check_gene_overlap()
      experiment_list <- map(experiment_list, function(exp) {
        exp[commonGenes,]
      }) |>
        do.call(cbind, args = _)
    })
  
  cli_alert_info("Compiling Experiment.")
  
  # Combine all the assays
  # Get a donor SCE
  experiment <- experiments[[1]]
  
  SummarizedExperiment::assays(experiment) <- map(experiments, function(exp) {
    SummarizedExperiment::assays(exp)[[1]]
  })
  
  experiment
}

#' Gets a Metacell from curated metadata
#' 
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a [`SingleCellExperiment::SingleCellExperiment-class`] object
#' corresponding to the samples in that data frame
#' 
#' @param data A data frame containing, at minimum, `sample_id`, `file_id_cellNexus_single_cell`, 
#'   `atlas_id` and a metacell column (e.g `metacell_2`) columns, which correspond to sample ID
#'   file subdivision for internal use, atlas name in format (e.g cellxgene/06-02-2025) 
#'   for internal use, and metacell column to be queried.
#'   They can be obtained from the [get_metadata()] function.
#' @param assays A character vector of metacell counts. Default to "counts".
#' @param cell_aggregation A character vector representing the level of metacell aggregation. 
#'   It indicates a group of cells that can be divided into the number of metacells. 
#'   Each metacell comprises a minimum of ten single cells by default.
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter as_tibble inner_join collect transmute
#' @importFrom tibble column_to_rownames
#' @importFrom purrr reduce map map_int imap 
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom assertthat assert_that
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom rlang .data
#' @importFrom S4Vectors DataFrame
#' @examples
#' \dontrun{
#' meta <- get_metadata() |> filter(tissue_harmonised == "lung")
#' metacell <- meta |> filter(!is.na(metacell_2)) |> get_metacell(cell_aggregation = "metacell_2")
#' }
#' @export
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
get_metacell <- function(data, 
                         assays = "counts",
                         cell_aggregation,
                         cache_directory = get_default_cache_dir(),
                         repository = COUNTS_URL,
                         features = NULL
                         ) {
  raw_data <- collect(data)
  assert_that(
    inherits(raw_data, "tbl"),
    has_name(raw_data, c("sample_id", "file_id_cellNexus_single_cell", "atlas_id")),
    any(grepl("^metacell", names(raw_data)))
  )
  raw_data = raw_data |> 
    # This is to separate metacell and single_cell in group_to_data_container, also 
    #    not to produce repetitive column in the metadata
    mutate(file_id_cellNexus_metacell = file_id_cellNexus_single_cell)
  
  atlas_name <- raw_data |> distinct(atlas_id) |> pull()
  parameter_validation_list <- 
    validate_data(data, assays, cell_aggregation, cache_directory, 
                  repository, features)
  
  versioned_cache_directory <- parameter_validation_list$cache_directory
  atlas_name <- parameter_validation_list$atlas_name
  grouping_column <- "file_id_cellNexus_metacell"
  
  subdirs <- assay_map[assays]
  
  # The repository is optional. If not provided we load only from the cache
  if (!is.null(repository)) {
    cli_alert_info("Synchronising files")
    parsed_repo <- parse_url(repository)
    parsed_repo$scheme |>
      `%in%`(c("http", "https")) |>
      assert_that()
    
    files_to_read <-
      raw_data |> 
      transmute(
        files = .data[[grouping_column]], 
        atlas_name = atlas_id, 
        cache_dir = cache_directory
      ) |> distinct() |>
      pmap(function(files, atlas_name, cache_dir) {
        sync_assay_files(
          files = files,
          atlas_name = atlas_name,
          cache_dir = cache_dir,
          url = parsed_repo,
          cell_aggregation = cell_aggregation,
          subdirs = subdirs
        )
      })
  }
  
  cli_alert_info("Reading files.")
  experiments <- subdirs |>
    imap(function(current_subdir, current_assay) {
      # Build up an experiment for each assay
      dir_prefix <- file.path(
        versioned_cache_directory,
        current_subdir
      )
      experiment_list <- raw_data |>
        mutate(dir_prefix = dir_prefix) |>
        dplyr::group_by(.data[[grouping_column]], dir_prefix) |>
        dplyr::summarise(experiments = list(
          group_to_data_container(
            dplyr::cur_group_id(),
            dplyr::cur_data_all(),
            unique(dir_prefix),
            features,
            grouping_column,
            metacell_column = cell_aggregation
          )
        )) |>
        dplyr::pull(experiments)
      
      commonGenes <- experiment_list |> check_gene_overlap()
      experiment_list <- map(experiment_list, function(exp) {
        exp[commonGenes,]
      }) |>
        do.call(cbind, args = _)
    })
  
  cli_alert_info("Compiling Experiment.")
  
  # Combine all the assays
  # Get a donor SCE
  experiment <- experiments[[1]]
  
  SummarizedExperiment::assays(experiment) <- map(experiments, function(exp) {
    SummarizedExperiment::assays(exp)[[1]]
  })
  
  experiment
}

#' Validate data parameters
#' 
#' Given a data frame of Curated Atlas metadata obtained from [get_metadata()],
#' returns a list of parameters being validated.
#' @param data A data frame containing, at minimum, `cell_id`, `file_id_cellNexus_single_cell` 
#'   and/or `file_id_cellNexus_pseudobulk`, and `atlas_id` column, which correspond to a single cell ID, 
#'   file subdivision for internal use for single_cell and/or pseudobulk level, and 
#'   atlas name in format (e.g cellxgene/06-02-2025) for internal use.
#'   They can be obtained from the [get_metadata()] function.
#' @param assays A character vector specifying the desired assay(s) to be requested. 
#'   Valid elements include "counts", "cpm", and "rank" for single-cell analyses, or 
#'   "counts" for pseudobulk analyses. 
#'   The default setting retrieves only the counts assay.
#'   If your analysis involves a smaller set of genes, consider using the "cpm" assay. 
#'   The "rank" assay is suited for signature calculations across millions of cells.
#' @param cell_aggregation A character vector that specifies which cell aggregation strategy
#' should be applied. This will create  a corresponding subdirectory in the atlas cache.
#' Choose one of the following: single_cell, pseudobulk
#' @param cache_directory An optional character vector of length one. If
#'   provided, it should indicate a local file path where any remotely accessed
#'   files should be copied.
#' @param repository A character vector of length one. If provided, it should be
#'   an HTTP URL pointing to the location where the single cell data is stored.
#' @param features An optional character vector of features (ie genes) to return
#'   the counts for. By default counts for all features will be returned.
#' @importFrom dplyr pull filter as_tibble inner_join collect
#' @importFrom tibble column_to_rownames
#' @importFrom purrr reduce map map_int imap 
#' @importFrom BiocGenerics cbind
#' @importFrom glue glue
#' @importFrom SummarizedExperiment colData assayNames<-
#' @importFrom assertthat assert_that has_name
#' @importFrom cli cli_alert_info
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
validate_data <- function(
    data,
    assays = "counts",
    cell_aggregation,
    cache_directory = get_default_cache_dir(),
    repository = COUNTS_URL,
    features = NULL
    
) {
  # Parameter validation
  assays %in% names(assay_map) |>
    all() |>
    assert_that(
      msg = 'assays must be a character vector containing counts and/or
            "cpm" and/or "rank"'
    )
  assert_that(
    !anyDuplicated(assays),
    inherits(cache_directory, "character"),
    is.null(repository) || is.character(repository),
    is.null(features) || is.character(features)
  )
  
  # Data parameter validation (last, because it's slower)
  ## Evaluate the promise now so that we get a sensible error message
  force(data)
  ## We have to convert to an in-memory table here, or some of the dplyr
  ## operations will fail when passed a database connection
  cli_alert_info("Realising metadata.")
  raw_data <- collect(data)
  atlas_name <- raw_data |> distinct(atlas_id) |> pull()
  versioned_cache_directory <- file.path(cache_directory, atlas_name, cell_aggregation)
  
  versioned_cache_directory |> map(function(directory_path) {
    dir.create(
      directory_path,
      showWarnings = FALSE,
      recursive = TRUE
    )
  })
  
  subdirs <- assay_map[assays]
  
  result <- list(data = data,
                 repository = repository,
                 assays = assays,
                 cache_directory = versioned_cache_directory,
                 features = features,
                 cell_aggregation = cell_aggregation,
                 atlas_name = atlas_name)
}

#' Converts a data frame into a Summarized Experiment
#' 
#' This function converts a given data frame into a Summarized Experiment object,
#' allowing for handling of single-cell or pseudobulk data based on specified experiment
#' type. It requires specific columns for the data frame based on the type of
#' experiment data being processed.
#' 
#' @param i Suffix to be added to the column names, to make them unique
#' @param df The data frame to be converted
#' @param dir_prefix The path to the single cell experiment, minus the final
#'   segment
#' @param features The list of genes/rows of interest
#' @param grouping_column A character vector of metadata column for grouping
#' @param metacell_column A character vector of metacell column (e.g. "metacell_2", "metacell_4") from metadata.
#' @return A `SummarizedExperiment` object
#' @importFrom dplyr mutate filter
#' @importFrom zellkonverter readH5AD
#' @importFrom SummarizedExperiment colData<-
#' @importFrom tibble column_to_rownames
#' @importFrom utils head
#' @importFrom cli cli_alert_warning cli_abort
#' @importFrom glue glue
#' @importFrom stringr str_replace_all
#' @noRd
group_to_data_container <- function(i, df, dir_prefix, features, grouping_column,
                                    metacell_column = NULL) {
  # Set file name based on type
  experiment_path <- df[[grouping_column]] |>
    head(1) |>
    file.path(
      dir_prefix,
      suffix=_
    )
  
  # Check if file exists
  experiment_path |> map(function(path) {
    file_exists = file.exists(path)
    file_exists |> assert_that(
      msg = "Your cache does not contain the file {experiment_path} you
           attempted to query. Please provide the repository
           parameter so that files can be synchronised from the
           internet" |> glue()
    )
    })
  
  # Load experiment
  experiment <- readH5AD(experiment_path, reader = "R", use_hdf5 = TRUE) |> suppressMessages()
  
  # Fix for https://github.com/tidyverse/dplyr/issues/6746
  force(i)
  
  if (grouping_column == "file_id_cellNexus_single_cell") {
    # Process specific to SCE
    cells <- colnames(experiment) |> intersect(df$cell_id)
    
    if (length(cells) < nrow(df)){
      single_line_str(
        "The number of cells in the SingleCellExperiment will be less than the
                number of cells you have selected from the metadata.
                Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
                "
      ) |> cli_alert_warning()
      df <- filter(df, .data$cell_id %in% cells)
    }
    else if (length(cells) > nrow(df)){
      cli_abort("This should never happen")
    }
    
    new_coldata <- df |>
      mutate(original_cell_ = .data$cell_id, cell_id = glue("{cell_id}_{i}")) |>
      column_to_rownames("cell_id") |>
      as("DataFrame")
    
    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$original_cell_],
      {
        # Optionally subset the genes
        genes <- rownames(experiment) |> intersect(features)
        experiment[genes, new_coldata$original_cell_]
      }
    ) |>
      `colnames<-`(new_coldata$cell_id) |>
      `colData<-`(value = new_coldata)
  }
  else if (grouping_column == "file_id_cellNexus_pseudobulk") {
    # Process specific to Pseudobulk
    # remove cell-level annotations
    cell_level_anno <- c("cell_id", "cell_type", "file_id_cellNexus_single_cell",
                         "cell_type_ontology_term_id",
                         "observation_joinid", "ensemble_joinid",
                         "nFeature_RNA", "data_driven_ensemble", "cell_type_unified",
                         "empty_droplet", "observation_originalid", "alive", "scDblFinder.class")
    
    new_coldata <- df |>
      select(-dplyr::all_of(intersect(names(df), cell_level_anno))) |>
      # Remove metacell and single-cell level annotations in pseudobulk
      select(-contains("metacell"), -matches("azimuth|monaco|blueprint|subsets_|high_")) |> 
      distinct() |>
      mutate(
        sample_identifier = glue("{sample_id}___{cell_type_unified_ensemble}"),
        original_sample_id = .data$sample_identifier
      ) |>
      column_to_rownames("original_sample_id")

    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$sample_identifier],
      {
        genes <- rownames(experiment) |> intersect(features)
        experiment[genes, new_coldata$sample_identifier]
      }
    ) |>
        `colnames<-`(new_coldata$sample_identifier) |>
        `colData<-`(value = DataFrame(new_coldata))
    
    # Force renaming type class since zellkonverter::writeH5AD cannot save `SummarizedExperiment` object.
    experiment <- as(experiment, "SingleCellExperiment")
   
  }
  else if (grouping_column == "file_id_cellNexus_metacell") {
    # Select relevant annotations to remove single-cell level annotations
    annotations <- metacell_column |> 
      c( "dataset_id", "sample_id", "assay", "assay_ontology_term_id", 
         "development_stage", "development_stage_ontology_term_id", "disease", "disease_ontology_term_id", 
         "donor_id", "experiment___", "explorer_url", "feature_count", "is_primary_data", 
         "organism", "organism_ontology_term_id", "published_at", "raw_data_location", 
         "revised_at", "sample_heuristic", "schema_version", "self_reported_ethnicity", 
         "self_reported_ethnicity_ontology_term_id", "sex", "sex_ontology_term_id", "tissue", 
         "tissue_ontology_term_id", "tissue_type", "title", "tombstone", "url", "age_days", 
         "tissue_groups", "atlas_id", "sample_chunk", "file_id_cellNexus_single_cell", 
         "file_id_cellNexus_metacell", "dir_prefix") 
    
    new_coldata <- df |>
      select(annotations) |>
      distinct() |>
      mutate(
        metacell_identifier = glue("{sample_id}___{.data[[metacell_column]]}"),
        original_metacell_id = .data$metacell_identifier
      ) |>
      column_to_rownames("original_metacell_id")
    
    experiment <- `if`(
      is.null(features),
      experiment[, new_coldata$metacell_identifier],
      {
        # Optionally subset the genes
        genes <- rownames(experiment) |> intersect(features)
        experiment[genes, new_coldata$metacell_identifier]
      }
    ) |>
      `colnames<-`(new_coldata$metacell_identifier) |>
      `colData<-`(value = DataFrame(new_coldata))
  }
}

#' Synchronises one or more remote assays with a local copy
#' @param url A character vector of length one. The base HTTP URL from which to
#'   obtain the files.
#' @param cache_dir A character vector of length one. The local filepath to
#'   synchronise files to.
#' @param subdirs A character vector of subdirectories within the root URL to
#'   sync. These correspond to assays.
#' @param files A character vector containing one or more file_id_cellNexus_single_cell entries
#' @returns A character vector consisting of file paths to all the newly
#'   downloaded files
#' @return A character vector of files that have been downloaded
#' @importFrom purrr pmap_chr map_chr
#' @importFrom httr modify_url
#' @importFrom dplyr transmute filter
#' @importFrom httr parse_url
#' @noRd
sync_assay_files <- function(
    url = parse_url(COUNTS_URL),
    atlas_name,
    cell_aggregation,
    cache_dir,
    subdirs,
    files
) {
  # Find every combination of file name, sample id, and assay, since each
  # will be a separate file we need to download
  files <- expand.grid(
    atlas_name = atlas_name,
    cell_aggregation = cell_aggregation,
    sample_id = files,
    subdir = subdirs,
    stringsAsFactors = FALSE
  ) |>
    transmute(
      # Path to the file of interest from the root path. We use "/"
      # since URLs must use these regardless of OS
      full_url = paste0(
        url$path,
        "/",
        .data$atlas_name,
        "/",
        .data$cell_aggregation,
        "/",
        .data$subdir,
        "/",
        .data$sample_id
      ) |> map_chr(~ modify_url(url, path = .)),
      # Nectar cloud is strict to url slashes, thus we normalize the URLs 
      # by removing multiple slashes except in the protocol part.
      full_url = gsub("(?<!:)/{2,}", "/", full_url, perl = TRUE),
      # Path to save the file on local disk (and its parent directory)
      # We use file.path since the file separator will differ on other OSs
      output_file = file.path(
        cache_dir,
        .data$atlas_name,
        .data$cell_aggregation,
        .data$subdir,
        .data$sample_id
      )
    ) |>
    filter(
      # Don't bother downloading files that don't exist TODO: use some
      # kind of hashing to check if the remote file has changed, and
      # proceed with the download if it has. However this is low
      # importance as the repository is not likely to change often
      !file.exists(.data$output_file)
    )
  
  if (nrow(files) > 0) report_file_sizes(files$full_url)
  
  pmap_chr(files, function(full_url, output_dir, output_file) {
    sync_remote_file(full_url, output_file)
    output_file
    }, .progress = list(name = "Downloading files"))
}

#' Checks whether genes in a list of SummarizedExperiment objects overlap
#' @param obj_list A list of SummarizedExperiment objects
#' @return A character vector of genes intersection across objects
#' @importFrom purrr map reduce
#' @importFrom cli cli_alert_warning
#' @noRd
check_gene_overlap <- function(obj_list) {
  gene_lists <- map(obj_list, rownames)
  common_genes <- reduce(gene_lists, intersect)
  if (any(lengths(gene_lists) != length(common_genes))) {
    single_line_str(
      "cellNexus says: Not all genes completely overlap across the provided objects.
      Counts are generated by genes intersection. "
    ) |> cli_alert_warning()
  }
  
  common_genes
}

