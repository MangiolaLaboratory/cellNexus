# Gets a Pseudobulk from curated metadata

Given a data frame of Curated Atlas metadata obtained from
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
returns a
[`SummarizedExperiment::SummarizedExperiment`](https://rdrr.io/pkg/SummarizedExperiment/man/SummarizedExperiment-class.html)
object corresponding to the samples in that data frame

## Usage

``` r
get_pseudobulk(
  data,
  assays = "counts",
  cell_aggregation = "pseudobulk",
  cache_directory = get_default_cache_dir(),
  repository = COUNTS_URL,
  features = NULL,
  as_SummarizedExperiment = FALSE
)
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Arguments

- data:

  A data frame containing, at minimum, `cell_id`,
  `file_id_cellNexus_pseudobulk`, `sample_id`,
  `cell_type_unified_ensemble`, `atlas_id` columns, which correspond to
  a single cell ID, file subdivision for internal use, a singlel cell
  sample ID, harmonised cell type, and atlas name in format (e.g
  cellxgene_2024/0.1.0) for internal use. They can be obtained from the
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
  function. Use
  [`get_atlas_versions()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_atlas_versions.md)
  to download atlas versions data frame.

- assays:

  A character vector specifying the desired assay(s) to be requested.
  The default setting retrieves only the counts assay.

- cell_aggregation:

  A character vector that specifies which cell aggregation strategy
  should be applied. This will create a corresponding subdirectory in
  the cache directory.

- cache_directory:

  An optional character vector of length one. If provided, it should
  indicate a local file path where any remotely accessed files should be
  copied.

- repository:

  A character vector of length one. If provided, it should be an HTTP
  URL pointing to the location where the single cell data is stored.

- features:

  An optional character vector of features (ie genes) to return the
  counts for. By default counts for all features will be returned. When
  provided, the returned object will contain exactly the requested
  features (row order preserved), and any experiments/samples that do
  not contain all requested features are dropped. This preserves the
  full set of requested features at the cost of potentially fewer
  samples. A warning is emitted when samples are dropped.

- as_SummarizedExperiment:

  If `TRUE`, coerce the result to a `SummarizedExperiment`. Note that
  `as(x, "SummarizedExperiment")` drops feature rownames;
  `get_pseudobulk()` restores them after coercion.

## Value

By default, a `SingleCellExperiment` object. If
`as_SummarizedExperiment` is `TRUE`, a `SummarizedExperiment` object.

## Details

Columns in `data` that are constant within each `sample_id` ×
`cell_type_unified_ensemble` combination (including user-added
annotations) are retained in `colData`. Cell-level columns are dropped
via internal `keep_specific_annotation_columns()`.

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
# Use the lightweight sample database URL (for fast checks during development only)
meta <- get_metadata(cloud_metadata = cellNexus::SAMPLE_DATABASE_URL) |>
  keep_quality_cells() |>
  dplyr::filter(cell_type_unified_ensemble == "epithelial")
pseudobulk <- meta |> get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Downloading 2 files, totalling 0.02 GB
#> ℹ Downloading 2 files in parallel...
#> ℹ Reading files.
#> ℹ Compiling Experiment.
```
