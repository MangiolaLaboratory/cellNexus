# Given a data frame of HCA metadata, returns a Seurat object corresponding to the samples in that data frame

Given a data frame of HCA metadata, returns a Seurat object
corresponding to the samples in that data frame

## Usage

``` r
get_seurat(...)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- ...:

  Arguments passed on to
  [`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)

  `data`

  :   A data frame containing, at minimum, `cell_id`,
      `file_id_cellNexus_single_cell` and `atlas_id` columns, which
      correspond to a single cell ID, file subdivision for internal use,
      and atlas name in format (e.g cellxgene/06-02-2025) for internal
      use. They can be obtained from the
      [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
      function.

  `assays`

  :   A character vector specifying the desired assay(s) to be
      requested. Valid elements include "counts", "cpm", and "rank" for
      single-cell analyses, or "counts" for pseudobulk analyses. The
      default setting retrieves only the counts assay. If your analysis
      involves a smaller set of genes, consider using the "cpm" assay.
      The "rank" assay is suited for signature calculations across
      millions of cells.

  `cell_aggregation`

  :   A character vector that specifies which cell aggregation strategy
      should be applied. This will create a corresponding subdirectory
      in the cache directory. Single cell level is applied by default.

  `cache_directory`

  :   An optional character vector of length one. If provided, it should
      indicate a local file path where any remotely accessed files
      should be copied.

  `repository`

  :   A character vector of length one. If provided, it should be an
      HTTP URL pointing to the location where the single cell data is
      stored.

  `features`

  :   An optional character vector of features (ie genes) to return the
      counts for. By default counts for all features will be returned.
      When provided, the returned object will contain exactly the
      requested features (row order preserved), and any
      experiments/samples that do not contain all requested features are
      dropped. This preserves the full set of requested features at the
      cost of potentially fewer samples. A warning is emitted when
      samples are dropped. When provided, the returned object will
      contain exactly the requested features (row order preserved), and
      any experiments/samples that do not contain all requested features
      are dropped. This preserves the full set of requested features at
      the cost of potentially fewer samples. A warning is emitted when
      samples are dropped. When provided, the returned object will
      contain exactly the requested features (row order preserved), and
      any experiments/samples that do not contain all requested features
      are dropped. This preserves the full set of requested features at
      the cost of potentially fewer samples. A warning is emitted when
      samples are dropped. When provided, the returned object will
      contain exactly the requested features (row order preserved), and
      any experiments/samples that do not contain all requested features
      are dropped. This preserves the full set of requested features at
      the cost of potentially fewer samples. A warning is emitted when
      samples are dropped.

## Value

A Seurat object containing the same data as a call to
[`get_single_cell_experiment()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
# Use the lightweight sample database URL (for fast checks during development only)
meta <- get_metadata(cloud_metadata = cellNexus::SAMPLE_DATABASE_URL) |> head(2)
seurat <- get_seurat(meta)
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
```
