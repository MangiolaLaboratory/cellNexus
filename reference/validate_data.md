# Validate data parameters

Given a data frame of Curated Atlas metadata obtained from
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
returns a list of parameters being validated.

## Usage

``` r
validate_data(
  data,
  assays = "counts",
  cell_aggregation,
  cache_directory = get_default_cache_dir(),
  repository = COUNTS_URL,
  features = NULL
)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- data:

  A data frame containing, at minimum, `cell_id`,
  `file_id_cellNexus_single_cell` and/or `file_id_cellNexus_pseudobulk`,
  and `atlas_id` column, which correspond to a single cell ID, file
  subdivision for internal use for single_cell and/or pseudobulk level,
  and atlas name in format (e.g cellxgene/06-02-2025) for internal use.
  They can be obtained from the
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
  function.

- assays:

  A character vector specifying the desired assay(s) to be requested.
  Valid elements include "counts", "cpm", and "rank" for single-cell
  analyses, or "counts" for pseudobulk analyses. The default setting
  retrieves only the counts assay. If your analysis involves a smaller
  set of genes, consider using the "cpm" assay. The "rank" assay is
  suited for signature calculations across millions of cells.

- cell_aggregation:

  A character vector that specifies which cell aggregation strategy
  should be applied. This will create a corresponding subdirectory in
  the atlas cache. Choose one of the following: single_cell, pseudobulk

- cache_directory:

  An optional character vector of length one. If provided, it should
  indicate a local file path where any remotely accessed files should be
  copied.

- repository:

  A character vector of length one. If provided, it should be an HTTP
  URL pointing to the location where the single cell data is stored.

- features:

  An optional character vector of features (ie genes) to return the
  counts for. By default counts for all features will be returned.

## Value

A list containing validated parameters including data, repository,
assays, cache_directory, features, cell_aggregation, and atlas_name.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.
