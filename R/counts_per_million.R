#' Generating counts per million from a SingleCellExperiment object
#'
#' @param sce A SingleCellExperiment object
#' @param output_file A character vector of CPM Anndata file path
#' @return A directory stores counts per million Anndata
#' @importFrom SingleCellExperiment SingleCellExperiment
#' @importFrom SummarizedExperiment assay assays assays<-
#' @importFrom purrr map
#' @importFrom anndataR write_h5ad
#' @examples
#' data(pbmc3k_sce)
#' get_counts_per_million(pbmc3k_sce, tempfile(fileext = ".h5ad"))
#' @export
get_counts_per_million <- function(sce, output_file) {
  
  # Avoid completely empty cells
  col_sums <- colSums(as.matrix(assay(sce)))
  selected_cols <- which(col_sums >0 & col_sums < Inf)
  
  assay_name <- assays(sce) |> names()
  sce <- SingleCellExperiment(list(cpm = scuttle::calculateCPM(sce[,selected_cols ,drop=FALSE ], assay.type = assay_name)))
  rownames(sce) <- rownames(sce[,selected_cols  ])
  colnames(sce) <- colnames(sce[,selected_cols  ])
  
  # Avoid scaling zeros
  sce_zero <- SingleCellExperiment(list(cpm = assay(sce)[, !selected_cols ,drop=FALSE ]))
  rownames(sce_zero) <- rownames(sce[, !selected_cols  ])
  colnames(sce_zero) <- colnames(sce[, !selected_cols ])
  
  sce <- sce |> cbind(sce_zero)
  
  sce <- sce[,colnames(sce)]
  
  # # Check if there is a memory issue 
  # assays(sce) <- assays(sce) |> map(DelayedArray::realize)
  
  sce |> write_h5ad(output_file, compression = "gzip")
} 

