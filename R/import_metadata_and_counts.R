# Maps user provided assay names to their corresponding paths in the repository
assay_map <- c(
  counts = "counts",
  cpm = "cpm",
  rank = "rank"
)

# File extension
extension <- ".h5ad"

# Assertion of metadata
assert_single_cell_metadata <- function(sce_obj,
                                        cache_dir = get_default_cache_dir()
                                        ) {
  metadata_tbl <- metadata(sce_obj)$data_to_import 
  counts_matrix <- assay(sce_obj)
  
  # Check if the input contains only one dataset_id
  (metadata_tbl |> distinct(dataset_id) |> nrow() == 1) |>
    check_true() |> 
    assert("sce_obj metadata should contain one dataset_id at each time.")
  
  # Identify whether genes in SingleCellxExperiment object are in ensembl nomenclature
  genes <- rowData(sce_obj) |> rownames()
  assert(sce_obj |> inherits( "SingleCellExperiment"),
         "sce_obj is not identified as SingleCellExperiment object.")
  assert(grepl("^ENSG\\d+$", genes) |> all(), 
         "Genes in SingleCellExperiment object must be Ensembl gene ids.")
  assert(all(counts_matrix >= 0),
         "Counts for SingleCellExperiment cannot be negative.")
  
  
  # Check the metadata contains cell_id, file_id_cellNexus_single_cell, sample_ with correct types
  check_true("cell_id" %in% colnames(metadata_tbl))
  check_true("file_id_cellNexus_single_cell" %in% names(metadata_tbl)) 
  pull(metadata_tbl, .data$cell_id) |> class() |> check_character()
  select(metadata_tbl, .data$file_id_cellNexus_single_cell) |> class() |> check_character()
  
  # Check cell_id values in metadata_tbl is unique
  (anyDuplicated(metadata_tbl$cell_id) == 0 ) |> assert("Cell names (cell_id) in the metadata must be unique.")
  
  # Check cell_id values are not duplicated when join with parquet
  cells <- select(get_metadata(cache_directory = cache_dir), .data$cell_id)
  if (cells |> filter(cell_id %in% metadata_tbl$cell_id) |> collect() |> nrow() > 0) 
    cli_alert_warning(
      single_line_str(
        "Import API says:
        Cells in your SingleCellExperiment already exists in the atlas."
      )
    )
  
  # Check sex capitalisation then convert to lower case 
  if (any(colnames(metadata_tbl) == "sex")) {
    metadata_tbl <- metadata_tbl |> mutate(sex = tolower(.data$sex))
    distinct(metadata_tbl, .data$sex) |> pull(.data$sex) |> check_subset(c("female","male","unknown"))
  }
}

# Assert pseudobulk metadata
assert_pseudobulk_metadata <- function(sce_obj,
                                       pseudobulk = FALSE) {
  metadata_tbl <- metadata(sce_obj)$data
  # Pseudobulk checkpoint 
  pseudobulk_sample <- c("sample_id", "cell_type_unified_ensemble")
  if (isTRUE(pseudobulk)) {
    assert(
      all(pseudobulk_sample %in% (colData(sce_obj) |> colnames()) ),
      "sample_id and cell_type_unified_ensemble columns must be in the SingleCellExperiment colData")
    
    assert(c(pseudobulk_sample, "file_id_cellNexus_single_cell") %in% (names(metadata_tbl)) |> all() ,
           "SingleCellExperiment metadata must at least contain sample_id, cell_type_unified_ensemble,
           file_id_cellNexus_single_cell for pseudobulk generation"
    ) }
}

#' Import and process metadata and counts for a SingleCellExperiment object
#'
#' @param sce_obj A SingleCellExperiment object, the metadata slot of which
#' must contain `cell_id` and `dataset_id`
#' @param atlas_name A character string specifying the name of the atlas to import.
#' @param import_date A character vector that specifies the date of the import.
#' The date should be in the international format 'YYYY-MM-DD' for clarity and consistency.
#' @param cell_aggregation A character vector that specifies which cell aggregation strategy
#' should be applied. This will create  a corresponding subdirectory in the atlas cache.
#' Choose one of the following: single_cell, pseudobulk
#' @param cache_dir Optional character vector of length 1. A file path on
#'   your local system to a directory (not a file) that will be used to store
#'   `atlas_metadata.parquet`
#' @param pseudobulk Optional character. Set to TRUE for generating and importing pseudobulk,
#' the metadata slot of which must contain `file_id_cellNexus_single_cell`, `cell_type_harmonised` and `sample_`
#' @export
#' @return 
#' An user-defined atlas metadata.parquet from the SingleCellExperiment object. 
#' Directories store counts and/or counts per million and/or quantile_normalised 
#' in the provided cache directory.
#' @importFrom checkmate check_true check_character check_subset assert
#' @importFrom dplyr select distinct pull
#' @importFrom cli cli_alert_info cli_alert_warning
#' @importFrom rlang .data
#' @importFrom SingleCellExperiment reducedDims rowData reducedDims<-
#' @importFrom S4Vectors metadata metadata<-
#' @importFrom SummarizedExperiment assay assay<-
#' @examples
#' data(pbmc3k_sce)
#' import_one_sce(pbmc3k_sce,
#'                atlas_name = "pbmc3k_sce_atlas",
#'                import_date = format(Sys.Date(), "%d-%m-%Y"),
#'                cell_aggregation = "single_cell",
#'                cache_dir = get_default_cache_dir(),
#'                pseudobulk = FALSE)
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @source [Mangiola et al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)
import_one_sce <- function(
    sce_obj,  
    atlas_name,
    import_date,
    cell_aggregation,
    cache_dir = get_default_cache_dir(),
    pseudobulk = FALSE
  ) {
  # Create a new hierarchy for the imported metadata
  atlas_directory = file.path(cache_dir, atlas_name, import_date, cell_aggregation)
  
  # Identify metadata and counts matrix
  metadata_tbl <- metadata(sce_obj)$data
  counts_matrix <- assay(sce_obj)
  
  # Convert to tibble if not provided
  metadata_tbl <- metadata_tbl |> as_tibble()
  
  # Create file_id_cellNexus_single_cell from dataset_id
  file_id_cellNexus_single_cell <- metadata_tbl$dataset_id |> unique() |> openssl::md5() |> as.character()
  metadata_tbl <-
    metadata_tbl |> mutate(file_id_cellNexus_single_cell = paste0(file_id_cellNexus_single_cell, extension))
  metadata(sce_obj)$data_to_import <- metadata_tbl
  
  # Remove existing reducedDim slot to enable get_SCE API functionality 
  reducedDims(sce_obj) <- NULL
  
  # Check if metadata pass pseudobulk checkpoint if pseudobulk is TRUE
  sce_obj |> assert_pseudobulk_metadata(pseudobulk)
  
  # Check if metadata pass single cell checkpoint
  sce_obj |> assert_single_cell_metadata(cache_dir)

  # Create counts file directories
  original_dir <- file.path(atlas_directory, assay_map["counts"])
  cpm_dir <- file.path(atlas_directory, assay_map["cpm"])
  
  if (!dir.exists(original_dir)) dir.create(original_dir, recursive = TRUE)
  if (!dir.exists(cpm_dir)) dir.create(cpm_dir, recursive = TRUE)
  
  # Check whether count H5 directory has been generated
  if (any(file_id_cellNexus_single_cell %in% dir(original_dir))) {
    cli_alert_warning(
      single_line_str(
        "Import API says: The file you are trying to import is already present in the cache directory. "
      )
    )
  }
  
  # Create counts file name
  counts_file_path <- file.path(original_dir, basename(file_id_cellNexus_single_cell)) |> paste0(extension)
  cpm_file_path <- file.path(cpm_dir, basename(file_id_cellNexus_single_cell)) |> paste0(extension)

  # Generate cpm from counts
  cli_alert_info("Generating cpm from {file_id_cellNexus_single_cell}. ")
  get_counts_per_million(sce_obj,
                         counts_file_path, 
                         cpm_file_path)
  
  cli_alert_info("cpm are generated in {.path {cpm_dir}}. ")
  
  # convert metadata_tbl to parquet if above checkpoints pass
  arrow::write_parquet(metadata_tbl, file.path(cache_dir, glue("{atlas_name}_metadata.parquet")))
  
  # Generate pseudobulk
  if (isTRUE(pseudobulk)) sce_obj |> calculate_pseudobulk(atlas_name = atlas_name,
                                                          import_date = import_date,
                                                          cell_aggregation = "pseudobulk",
                                                          cache_dir = cache_dir)
}


#' Generate pseudobulk counts and quantile_normalised counts
#' @param sce_data A SingleCellExperiment object, the metadata slot of which
#' must contain `cell_id` and `dataset_id`
#' @param atlas_name A character string specifying the name of the atlas to import.
#' @param import_date A character vector that specifies the date of the import.
#' The date should be in the international format 'YYYY-MM-DD' for clarity and consistency.
#' @param cell_aggregation A character vector that specifies which cell aggregation strategy
#' should be applied. This will create  a corresponding subdirectory in the atlas cache.
#' Choose one of the following: single_cell, pseudobulk.
#' @param cache_dir Optional character vector of length 1. A file path on
#'   your local system to a directory (not a file) that will be used to store pseudobulk counts
#' @return Pseudobulk counts in `Anndata` format stored in the cache directory
#' @examples
#' data(pbmc3k_sce)
#' calculate_pseudobulk(pbmc3k_sce,
#'                    atlas_name = "pbmc3k_sce_atlas",
#'                    import_date = format(Sys.Date(), "%d-%m-%Y"),
#'                    cell_aggregation = "pseudobulk",
#'                    cache_dir = get_default_cache_dir())
#' @export
#' @importFrom S4Vectors metadata
#' @importFrom dplyr select distinct pull
#' @importFrom cli cli_alert_info cli_alert_warning
#' @importFrom S4Vectors metadata
#' @importFrom SummarizedExperiment assay assay<- assays
calculate_pseudobulk <- function(sce_data,
                                 atlas_name,
                                 import_date,
                                 cell_aggregation,
                                 cache_dir = get_default_cache_dir()) {
  # Create a new pseudobulk hierarchy
  pseudobulk_directory = file.path(cache_dir, atlas_name, import_date, cell_aggregation)
  
  metadata_tbl <- metadata(sce_data)$data
  file_id_cellNexus_single_cell <- metadata_tbl$file_id_cellNexus_single_cell |> unique() |> as.character()
  
  original_dir <- file.path(pseudobulk_directory, assay_map["counts"])
  quantile_normalised_dir <- file.path(pseudobulk_directory, assay_map["quantile_normalised"])
  
  if (!dir.exists(original_dir)) dir.create(original_dir, recursive = TRUE)
  if (!dir.exists(quantile_normalised_dir)) dir.create(quantile_normalised_dir, recursive = TRUE)
  
  cli_alert_info("Generating pseudobulk from {file_id_cellNexus_single_cell}. ")
  
  pseudobulk <- scuttle::aggregateAcrossCells(
    sce_data, 
    colData(sce_data)[,c("sample_id","cell_type_unified_ensemble")] |>
      as_tibble(rownames = ".cell") |> 
      mutate(aggregated_cells = paste(sample_id, cell_type_unified_ensemble, sep = "___")) |> 
      pull(aggregated_cells), 
    BPPARAM = BiocParallel::MulticoreParam(workers = 2)
  )
  
  # Handle column type cast correctly: https://github.com/scverse/anndata/issues/311
  colData(pseudobulk) <- as_tibble(colData(pseudobulk), rownames = "cell") |>
    mutate(across(everything(), as.character)) |>
    {\(x) DataFrame(x, row.names = x$cell)}()
  
  # Remove columns with compleletly NA
  colData(pseudobulk) <- colData(pseudobulk)[ , colSums(!is.na(colData(pseudobulk))) > 0, drop = FALSE ]
  
  assay_name <- pseudobulk |> assays() |> names()
  normalised_counts_best_distribution <- assay(pseudobulk, assay_name) |>
    preprocessCore::normalize.quantiles.determine.target()
  
  normalised_pseudobulk <- pseudobulk |> tidybulk::quantile_normalise_abundance(
    method="preprocesscore_normalize_quantiles_use_target",
    target_distribution = normalised_counts_best_distribution
  )
  
  # Keep quantile_normalised counts
  assay(normalised_pseudobulk, assay_name) <- NULL
  names(assays(normalised_pseudobulk)) <- "quantile_normalised"
  metadata(normalised_pseudobulk)$tidybulk <- NULL

  counts_file_path <- file.path(original_dir, basename(file_id_cellNexus_single_cell)) |> paste0(extension)
  qnorm_file_path <- file.path(quantile_normalised_dir, basename(file_id_cellNexus_single_cell)) |> paste0(extension)
  
  # Save pseudobulk counts
  zellkonverter::writeH5AD(pseudobulk, counts_file_path, compression = "gzip")
  zellkonverter::writeH5AD(normalised_pseudobulk, qnorm_file_path, compression = "gzip")
  
  cli_alert_info("pseudobulk are generated in {.path {pseudobulk_directory}}. ")
}


