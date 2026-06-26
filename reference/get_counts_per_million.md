# Generating counts per million from a SingleCellExperiment object

Generating counts per million from a SingleCellExperiment object

## Usage

``` r
get_counts_per_million(sce, output_file)
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Arguments

- sce:

  A SingleCellExperiment object

- output_file:

  A character vector of CPM Anndata file path

## Value

A directory stores counts per million Anndata

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
data(pbmc3k_sce)
get_counts_per_million(pbmc3k_sce, tempfile(fileext = ".h5ad"))
```
