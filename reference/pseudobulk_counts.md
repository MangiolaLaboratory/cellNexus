# Sample Pseudobulk SingleCellExperiment Object

A pre-made SingleCellExperiment object with pseudobulk aggregated data
for vignette demonstration. This object is used in the vignette to avoid
downloading data during package build.

## Format

An object of class `SingleCellExperiment` with:

- assays:

  Gene expression matrix with counts assay aggregated by sample and cell
  type

- colData:

  Sample metadata including sample_id, cell_type_unified_ensemble, etc.

## Source

Created from cellNexus datasets

## Details

See `dev/create_vignette_data.R` for the creation script.

## Examples

``` r
data(pseudobulk_counts)
pseudobulk_counts
#> class: SingleCellExperiment 
#> dim: 56239 3 
#> metadata(0):
#> assays(1): counts
#> rownames(56239): ENSG00000000003 ENSG00000000005 ... ENSG00000290292
#>   ENSG00000291237
#> rowData names(0):
#> colnames(3): a2459ad4272363e6eb775e8e99607c3e___cd4 th1 em
#>   9c8fa5a8d2ae37179b579a0217670512___LAP92_1_duong___cd4 th2 em
#>   e4d7f8162faf68a85f61bdbd81dae627___cd4 th2 em
#> colData names(59): dataset_id sample_id ... dir_prefix
#>   sample_identifier
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```
