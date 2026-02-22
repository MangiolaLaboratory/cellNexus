#' Sample SingleCellExperiment Object
#'
#' A sample SingleCellExperiment object created from the pbmc3k dataset for testing and demonstration purposes.
#' The dataset contains 500 cells with gene expression data mapped to Ensembl gene IDs and formatted
#' with cellNexus-compatible metadata structure.
#' 
#' @format An object of class \code{SingleCellExperiment} with:
#' \describe{
#'   \item{assays}{Gene expression matrix with Ensembl gene IDs as rownames}
#'   \item{colData}{Cell metadata including sample_id, cell_type_unified_ensemble, nCount_RNA, etc.}
#'   \item{metadata}{List containing 'data' field with cellNexus-formatted metadata including:
#'     \itemize{
#'       \item cell_id: Unique cell identifier
#'       \item sample_id: Sample identifier
#'       \item cell_type_unified_ensemble: Cell type annotation
#'       \item nCount_RNA: Number of RNA molecules per cell
#'       \item ident: Seurat cluster identity
#'       \item dataset_id: Dataset identifier
#'       \item file_id_cellNexus_single_cell: Generated file ID for cellNexus
#'       \item atlas_id: Atlas identifier with date
#'     }
#'   }
#' }
#' 
#' @source Created from pbmc3k dataset (SeuratData package)
#' @details See \code{dev/create_pbmc3k_sce.R} for the complete creation script.
#' @references Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, 
#'   A. Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human 
#'   immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
#'   doi:10.1101/2023.06.08.542671.
#' @keywords datasets
#' @docType data
#' @examples
#' \dontrun{
#' # Load the sample dataset
#' data(pbmc3k_sce)
#' 
#' # View basic information
#' pbmc3k_sce
#' 
#' # Access metadata
#' metadata(pbmc3k_sce)$data
#' 
#' # View cell types
#' unique(metadata(pbmc3k_sce)$data$cell_type_unified_ensemble)
#' }
"pbmc3k_sce"


#' Sample SingleCellExperiment Object with Counts Assay
#'
#' A pre-made SingleCellExperiment object with counts assay for vignette demonstration.
#' This object is used in the vignette to avoid downloading data during package build.
#' 
#' @format An object of class \code{SingleCellExperiment} with:
#' \describe{
#'   \item{assays}{Gene expression matrix with counts assay}
#'   \item{colData}{Cell metadata including sample_id, cell_type_unified_ensemble, etc.}
#' }
#' 
#' @source Created from cellNexus datasets
#' @details See \code{dev/create_vignette_data.R} for the creation script.
#' @keywords datasets
#' @docType data
"single_cell_counts"

#' Sample SingleCellExperiment Object with CPM Assay
#'
#' A pre-made SingleCellExperiment object with counts-per-million (CPM) assay for vignette demonstration.
#' This object is used in the vignette to avoid downloading data during package build.
#' 
#' @format An object of class \code{SingleCellExperiment} with:
#' \describe{
#'   \item{assays}{Gene expression matrix with cpm assay}
#'   \item{colData}{Cell metadata including sample_id, cell_type_unified_ensemble, etc.}
#' }
#' 
#' @source Created from cellNexus datasets
#' @details See \code{dev/create_vignette_data.R} for the creation script.
#' @keywords datasets
#' @docType data
"single_cell_cpm"

#' Sample Pseudobulk SingleCellExperiment Object
#'
#' A pre-made SingleCellExperiment object with pseudobulk aggregated data for vignette demonstration.
#' This object is used in the vignette to avoid downloading data during package build.
#' 
#' @format An object of class \code{SingleCellExperiment} with:
#' \describe{
#'   \item{assays}{Gene expression matrix with counts assay aggregated by sample and cell type}
#'   \item{colData}{Sample metadata including sample_id, cell_type_unified_ensemble, etc.}
#' }
#' 
#' @source Created from cellNexus datasets
#' @details See \code{dev/create_vignette_data.R} for the creation script.
#' @keywords datasets
#' @docType data
"pseudobulk_counts"

#' Sample Metacell SingleCellExperiment Object
#'
#' A pre-made SingleCellExperiment object with metacell aggregated data for vignette demonstration.
#' This object is used in the vignette to avoid downloading data during package build.
#' 
#' @format An object of class \code{SingleCellExperiment} with:
#' \describe{
#'   \item{assays}{Gene expression matrix with counts assay aggregated into metacells}
#'   \item{colData}{Metacell metadata including metacell_2, etc.}
#' }
#' 
#' @source Created from cellNexus datasets
#' @details See \code{dev/create_vignette_data.R} for the creation script.
#' @keywords datasets
#' @docType data
"metacell_counts"

#' Pre-computed UI Choices for Interface App
#'
#' A list of unique values for each filterable column used in the cellNexus
#' Shiny interface app. Pre-computing these choices avoids slow metadata
#' queries when the app starts.
#' 
#' @format A named list where each element contains unique values for a column:
#' \describe{
#'   \item{cell_type_unified_ensemble}{Character vector of unified cell type labels}
#'   \item{cell_type}{Character vector of original cell type labels}
#'   \item{alive}{Logical values for cell viability}
#'   \item{scDblFinder.class}{Character vector of doublet classification results}
#'   \item{is_immune}{Logical values for immune cell classification}
#'   \item{empty_droplet}{Logical values for empty droplet detection}
#'   \item{development_stage}{Character vector of developmental stages}
#'   \item{disease}{Character vector of disease states}
#'   \item{self_reported_ethnicity}{Character vector of ethnicity labels}
#'   \item{sex}{Character vector of sex labels}
#'   \item{tissue}{Character vector of tissue types}
#'   \item{tissue_groups}{Character vector of tissue group labels}
#' }
#' 
#' @source Generated from cellNexus metadata
#' @details See \code{dev/generate_ui_choices.R} for the creation script.
#'   Run this script to regenerate the choices when metadata columns change.
#' @keywords datasets
#' @docType data
"ui_choices"