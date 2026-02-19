# Generate pseudobulk counts and quantile_normalised counts

Generate pseudobulk counts and quantile_normalised counts

## Usage

``` r
calculate_pseudobulk(
  sce_data,
  atlas_name,
  import_date,
  cell_aggregation,
  cache_dir = get_default_cache_dir()
)
```

## Arguments

- sce_data:

  A SingleCellExperiment object, the metadata slot of which must contain
  `cell_id` and `dataset_id`

- atlas_name:

  A character string specifying the name of the atlas to import.

- import_date:

  A character vector that specifies the date of the import. The date
  should be in the international format 'YYYY-MM-DD' for clarity and
  consistency.

- cell_aggregation:

  A character vector that specifies which cell aggregation strategy
  should be applied. This will create a corresponding subdirectory in
  the atlas cache. Choose one of the following: single_cell, pseudobulk.

- cache_dir:

  Optional character vector of length 1. A file path on your local
  system to a directory (not a file) that will be used to store
  pseudobulk counts

## Value

Pseudobulk counts in `Anndata` format stored in the cache directory

## Examples

``` r
data(pbmc3k_sce)
calculate_pseudobulk(pbmc3k_sce,
                   atlas_name = "pbmc3k_sce_atlas",
                   import_date = format(Sys.Date(), "%d-%m-%Y"),
                   cell_aggregation = "pseudobulk",
                   cache_dir = get_default_cache_dir())
#> ℹ Generating pseudobulk from 67e196a3c4e145151fc9e06c200e2f7f.h5ad. 
#> ℹ pseudobulk are generated in /home/runner/.cache/R/cellNexus/pbmc3k_sce_atlas/19-02-2026/pseudobulk. 
```
