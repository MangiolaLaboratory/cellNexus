# Sample SingleCellExperiment Object with CPM Assay

A pre-made SingleCellExperiment object with counts-per-million (CPM)
assay for vignette demonstration. This object is used in the vignette to
avoid downloading data during package build.

## Format

An object of class `SingleCellExperiment` with:

- assays:

  Gene expression matrix with cpm assay

- colData:

  Cell metadata including sample_id, cell_type_unified_ensemble, etc.

## Source

Created from cellNexus datasets

## Details

See `dev/create_vignette_data.R` for the creation script.

## Examples

``` r
data(single_cell_cpm)
single_cell_cpm
#> class: SingleCellExperiment 
#> dim: 56239 6 
#> metadata(0):
#> assays(1): cpm
#> rownames(56239): ENSG00000121410 ENSG00000268895 ... ENSG00000135605
#>   ENSG00000109501
#> rowData names(0):
#> colnames(6):
#>   LAP92_CATTCTAGTGCGGATA-1_duong___9f222629-9e39-47d0-b83f-e08d610c7479_1
#>   LAP92_CTCATGCCACCTGATA-1_duong___9f222629-9e39-47d0-b83f-e08d610c7479_1
#>   ... GCTCCTAAGGGTATCG_F02607___9f222629-9e39-47d0-b83f-e08d610c7479_1
#>   AACACGTCACGCATCG_F01853___9f222629-9e39-47d0-b83f-e08d610c7479_2
#> colData names(98): dataset_id observation_joinid ... dir_prefix
#>   original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```
