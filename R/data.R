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
#' @usage NULL
#' @examples
#' data(pbmc3k_sce)
#' pbmc3k_sce
#' # Access metadata
#' S4Vectors::metadata(pbmc3k_sce)$data
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
#' @usage NULL
#' @examples
#' data(single_cell_counts)
#' single_cell_counts
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
#' @usage NULL
#' @examples
#' data(single_cell_cpm)
#' single_cell_cpm
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
#' @usage NULL
#' @examples
#' data(pseudobulk_counts)
#' pseudobulk_counts
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
#' @usage NULL
#' @examples
#' data(metacell_counts)
#' metacell_counts
"metacell_counts"