# Generating counts per million from a SingleCellExperiment object

Generating counts per million from a SingleCellExperiment object

## Usage

``` r
get_counts_per_million(sce, output_file)
```

## Arguments

- sce:

  A SingleCellExperiment object

- output_file:

  A character vector of CPM Anndata file path

## Value

A directory stores counts per million Anndata

## Examples

``` r
data(pbmc3k_sce)
get_counts_per_million(pbmc3k_sce, tempfile(fileext = ".h5ad"))
```
