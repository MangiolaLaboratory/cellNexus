# cellNexus: Query Interface for the Human Cell Atlas

`cellNexus` provides a query interface for programmatic exploration and
retrieval of the harmonised, curated and reannotated CELLxGENE
single-cell Human Cell Atlas. The package allows users to query metadata
and download single-cell RNA sequencing data in various formats
including SingleCellExperiment, Seurat, and pseudobulk
SummarizedExperiment objects.

## Getting Started

To get started with `cellNexus`, first load the package and retrieve the
metadata:

    library(cellNexus)
    metadata <- get_metadata()

Then filter the metadata to find cells of interest and download the
data:

    filtered_metadata <- metadata |>
        dplyr::filter(
            tissue == "lung parenchyma" &
            cell_type %LIKE% "%CD4%"
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

- [`get_metacell`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metacell.md):

  Download metacell aggregated data

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

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.
