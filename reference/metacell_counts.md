# Sample Metacell SingleCellExperiment Object

A pre-made SingleCellExperiment object with metacell aggregated data for
vignette demonstration. This object is used in the vignette to avoid
downloading data during package build.

## Usage

``` r
metacell_counts
```

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
