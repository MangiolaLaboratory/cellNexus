# Sample SingleCellExperiment Object with CPM Assay

A pre-made SingleCellExperiment object with counts-per-million (CPM)
assay for vignette demonstration. This object is used in the vignette to
avoid downloading data during package build.

## Usage

``` r
single_cell_cpm
```

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
