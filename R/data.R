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
