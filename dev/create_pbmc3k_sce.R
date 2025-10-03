library(SeuratData)
library(SeuratObject)
library(Seurat)
library(AnnotationDbi)
library(EnsDb.Hsapiens.v86)
library(cellNexus)
library(SummarizedExperiment)
library(dplyr)
library(tibble)
pbmc3k = UpdateSeuratObject(pbmc3k)
pbmc3k_sce = pbmc3k |> as.SingleCellExperiment()
pbmc3k_sce = pbmc3k_sce[,1:500]

assay(pbmc3k_sce, "logcounts") <- NULL

ids = mapIds(
    EnsDb.Hsapiens.v86,
    keys=rownames(pbmc3k_sce),
    column="GENEID",
    keytype="SYMBOL",
    multiVals = "first"
  ) 

keep <- !is.na(ids)
pbmc3k_sce <- pbmc3k_sce[keep, ]
rownames(pbmc3k_sce) <- ids[keep]

# Transform colData
transformed_colData <- colData(pbmc3k_sce) |> 
  as.data.frame() |> 
  rownames_to_column("cell_id") |> 
  dplyr::rename(
    sample_id = orig.ident,
    cell_type_unified_ensemble = seurat_annotations
  ) |>
  mutate(
    sample_id = sample_id |> as.character(),
    nCount_RNA = nCount_RNA |> as.integer(),
    cell_type_unified_ensemble = ifelse(is.na(cell_type_unified_ensemble), "Unknown", as.character(cell_type_unified_ensemble)),
    ident = ident |> as.character(),
    dataset_id = "pbmc3k",
    file_id_cellNexus_single_cell = digest::digest(sample_id) |> 
      paste0(".h5ad"),
    atlas_id = file.path("cellxgene", format(Sys.Date(), "%d-%m-%Y"))
  )

# Update colData with transformed data
colData(pbmc3k_sce) <- DataFrame(transformed_colData |> column_to_rownames("cell_id"))

# Set metadata slot
metadata(pbmc3k_sce) <- list(
  data = transformed_colData
)

usethis::use_data(pbmc3k_sce, overwrite = TRUE, compress = "xz")

