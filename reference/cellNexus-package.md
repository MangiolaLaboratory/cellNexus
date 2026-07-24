# cellNexus: Query Interface for the Human Cell Atlas

`cellNexus` provides a query interface for programmatic exploration and
retrieval of the harmonised, curated and reannotated CELLxGENE
single-cell Human Cell Atlas. The package allows users to query metadata
and download single-cell RNA sequencing data in various formats
including SingleCellExperiment, Seurat, and pseudobulk
SummarizedExperiment objects.

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Value

The cellNexus package (invisibly).

## Getting Started

To get started with `cellNexus`, first load the package and retrieve the
metadata:

    library(cellNexus)
    metadata <- get_metadata()

Then filter the metadata to find cells of interest and download the
data:

    filtered_metadata <- metadata |>
        dplyr::filter(
            tissue_groups == "blood" &
            cell_type_unified_ensemble %LIKE% "%cd4%"
        )

    sce <- get_single_cell_experiment(filtered_metadata)

## Main Functions

- [`get_metadata`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md):

  Retrieve and query the harmonised metadata

- [`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md):

  Download data as SingleCellExperiment objects

- [`get_seurat`](https://mangiolalaboratory.github.io/cellNexus/reference/get_seurat.md):

  Download data as Seurat objects

- [`get_pseudobulk`](https://mangiolalaboratory.github.io/cellNexus/reference/get_pseudobulk.md):

  Download aggregated pseudobulk data

## Data Licensing

**Important:** The Human Cell Atlas data accessed through this package
is subject to its own licensing terms, which differ from the package
license. The `cellNexus` package itself is licensed under GPL-3.
However, the underlying Human Cell Atlas data is typically licensed
under Creative Commons Attribution (CC-BY) or similar open data licenses
as specified by the Human Cell Atlas Data Use Agreement. Users should
review the specific licensing terms for any datasets they access through
this package. For more information, see the Human Cell Atlas Data
Portal: <https://data.humancellatlas.org/about>

## Vignettes

See
[`vignette("cellNexus", package = "cellNexus")`](https://mangiolalaboratory.github.io/cellNexus/articles/cellNexus.md)
for a comprehensive introduction to using the package.

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.
