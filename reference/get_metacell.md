# Gets a Metacell from curated metadata

Given a data frame of Curated Atlas metadata obtained from
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
returns a
[`SingleCellExperiment::SingleCellExperiment`](https://rdrr.io/pkg/SingleCellExperiment/man/SingleCellExperiment.html)
object corresponding to the samples in that data frame

## Usage

``` r
get_metacell(
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

  A data frame containing, at minimum, `sample_id`,
  `file_id_cellNexus_single_cell`, `atlas_id` and a metacell column (e.g
  `metacell_2`) columns, which correspond to sample ID file subdivision
  for internal use, atlas name in format (e.g cellxgene/06-02-2025) for
  internal use, and metacell column to be queried. They can be obtained
  from the
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
  function.

- assays:

  A character vector of metacell counts. Default to "counts".

- cell_aggregation:

  A character vector representing the level of metacell aggregation. It
  indicates a group of cells that can be divided into the number of
  metacells. Each metacell comprises a minimum of ten single cells by
  default.

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
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_metadata.1.3.0.parquet to /home/runner/.cache/R/cellNexus/sample_metadata.1.3.0.parquet
metacell <- meta |> get_metacell(cell_aggregation = "metacell_2")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene/21-08-2025/metacell_2/counts/03319e4f54220f534de2c4e42e607126___1.h5ad to /home/runner/.cache/R/cellNexus/cellxgene/21-08-2025/metacell_2/counts/03319e4f54220f534de2c4e42e607126___1.h5ad
#> ℹ Reading files.
#> ℹ Compiling Experiment.
```
