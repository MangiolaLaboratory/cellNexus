# Import and process metadata and counts for a SingleCellExperiment object

Import and process metadata and counts for a SingleCellExperiment object

## Usage

``` r
import_one_sce(
  sce_obj,
  atlas_name,
  import_date,
  cell_aggregation,
  cache_dir = get_default_cache_dir(),
  pseudobulk = FALSE
)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- sce_obj:

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
  the atlas cache. Choose one of the following: single_cell, pseudobulk

- cache_dir:

  Optional character vector of length 1. A file path on your local
  system to a directory (not a file) that will be used to store
  `atlas_metadata.parquet`

- pseudobulk:

  Optional character. Set to TRUE for generating and importing
  pseudobulk, the metadata slot of which must contain
  `file_id_cellNexus_single_cell`, `cell_type_harmonised` and `sample_`

## Value

An user-defined atlas metadata.parquet from the SingleCellExperiment
object. Directories store counts and/or counts per million and/or
quantile_normalised in the provided cache directory.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
data(pbmc3k_sce)
import_one_sce(pbmc3k_sce,
               atlas_name = "pbmc3k_sce_atlas",
               import_date = format(Sys.Date(), "%d-%m-%Y"),
               cell_aggregation = "single_cell",
               cache_dir = get_default_cache_dir(),
               pseudobulk = FALSE)
#> ℹ Generating cpm from 18e65312747b3f1624c2f9240612579e. 
#> Error in generator$new(shape = rev(dim(sce)), ...): File
#> /github/home/.cache/R/cellNexus/pbmc3k_sce_atlas/19-02-2026/single_cell/counts/18e65312747b3f1624c2f9240612579e.h5ad
#> already exists but mode is set to "w-". If you want to overwrite the file, use
#> a different mode (e.g. 'w'). See `?read_h5ad()` or `?write_h5ad()` for more
#> information.
```
