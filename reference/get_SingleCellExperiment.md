# Gets a SingleCellExperiment from curated metadata

Given a data frame of Curated Atlas metadata obtained from
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
returns a
[`SingleCellExperiment::SingleCellExperiment`](https://rdrr.io/pkg/SingleCellExperiment/man/SingleCellExperiment.html)
object corresponding to the samples in that data frame

## Usage

``` r
get_SingleCellExperiment(...)
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
      and atlas name in format (e.g cellxgene_2024/0.1.0) for internal
      use. They can be obtained from the
      [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
      function. Use
      [`get_atlas_versions()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_atlas_versions.md)
      to download atlas versions data frame.

  `assays`

  :   A character vector specifying the desired assay(s) to be
      requested. Valid elements include "counts", "cpm", "rank", and
      "sct" for single-cell analyses The default setting retrieves only
      the counts assay. If your analysis involves a smaller set of
      genes, consider using the "cpm" assay. The "rank" assay is suited
      for signature calculations across millions of cells.

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

## Value

A `SingleCellExperiment` object.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
# Use the lightweight sample database URL (for fast checks during development only)
meta <- get_metadata(cloud_metadata = cellNexus::SAMPLE_DATABASE_URL) |> head(2)
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_metadata.2.1.0.parquet to /home/runner/.cache/R/cellNexus/sample_metadata.2.1.0.parquet
sce <- get_single_cell_experiment(meta)
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene/01-07-2024/counts/03319e4f54220f534de2c4e42e607126___1.h5ad to /home/runner/.cache/R/cellNexus/cellxgene/01-07-2024//counts/03319e4f54220f534de2c4e42e607126___1.h5ad
#> ℹ Reading files.
#> ℹ Compiling Experiment.
```
