# Sample SingleCellExperiment Object

A sample SingleCellExperiment object created from the pbmc3k dataset for
testing and demonstration purposes. The dataset contains 500 cells with
gene expression data mapped to Ensembl gene IDs and formatted with
cellNexus-compatible metadata structure.

## Usage

``` r
pbmc3k_sce
```

## Format

An object of class `SingleCellExperiment` with:

- assays:

  Gene expression matrix with Ensembl gene IDs as rownames

- colData:

  Cell metadata including sample_id, cell_type_unified_ensemble,
  nCount_RNA, etc.

- metadata:

  List containing 'data' field with cellNexus-formatted metadata
  including:

  - cell_id: Unique cell identifier

  - sample_id: Sample identifier

  - cell_type_unified_ensemble: Cell type annotation

  - nCount_RNA: Number of RNA molecules per cell

  - ident: Seurat cluster identity

  - dataset_id: Dataset identifier

  - file_id_cellNexus_single_cell: Generated file ID for cellNexus

  - atlas_id: Atlas identifier with date

## Source

Created from pbmc3k dataset (SeuratData package)

## Details

See `dev/create_pbmc3k_sce.R` for the complete creation script.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load the sample dataset
data(pbmc3k_sce)

# View basic information
pbmc3k_sce

# Access metadata
metadata(pbmc3k_sce)$data

# View cell types
unique(metadata(pbmc3k_sce)$data$cell_type_unified_ensemble)
} # }
```
