# Sample Pseudobulk SingleCellExperiment Object

A pre-made SingleCellExperiment object with pseudobulk aggregated data
for vignette demonstration. This object is used in the vignette to avoid
downloading data during package build.

## Usage

``` r
pseudobulk_counts
```

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
