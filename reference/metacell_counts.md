# Sample Metacell SingleCellExperiment Object

A pre-made SingleCellExperiment object with metacell aggregated data for
vignette demonstration. This object is used in the vignette to avoid
downloading data during package build.

## Format

An object of class `SingleCellExperiment` with:

- assays:

  Gene expression matrix with counts assay aggregated into metacells

- colData:

  Metacell metadata including metacell_2, etc.

## Source

Created from cellNexus datasets

## Details

See `dev/create_vignette_data.R` for the creation script.

## Examples

``` r
data(metacell_counts)
metacell_counts
#> class: SingleCellExperiment 
#> dim: 56239 4 
#> metadata(0):
#> assays(1): counts
#> rownames(56239): ENSG00000121410 ENSG00000268895 ... ENSG00000135605
#>   ENSG00000109501
#> rowData names(0):
#> colnames(4): 9c8fa5a8d2ae37179b579a0217670512___LAP92_1_duong___1
#>   9c8fa5a8d2ae37179b579a0217670512___LAP92_1_duong___2
#>   e4d7f8162faf68a85f61bdbd81dae627___1
#>   a2459ad4272363e6eb775e8e99607c3e___1
#> colData names(39): metacell_2 dataset_id ... dir_prefix
#>   metacell_identifier
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```
