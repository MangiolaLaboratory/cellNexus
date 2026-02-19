# Converts a series of HDF5Array-serialized SingleCellExperiments to AnnData

Converts a series of HDF5Array-serialized SingleCellExperiments to
AnnData

## Usage

``` r
hdf5_to_anndata(input_directory, output_directory)
```

## Arguments

- input_directory:

  A character scalar. The path to a directory containing one or more
  directories created by
  [`HDF5Array::saveHDF5SummarizedExperiment()`](https://rdrr.io/pkg/HDF5Array/man/saveHDF5SummarizedExperiment.html).

- output_directory:

  A character scalar. The path to a directory in which to save the
  created anndata files.

## Value

A character vector of the newly-created anndata files

## Examples

``` r
if (FALSE) { # \dontrun{
hdf5_to_anndata(
    "/vast/projects/cellxgene_curated/splitted_DB2_data_0.2.1",
    "/vast/projects/cellxgene_curated/splitted_DB2_anndata_0.2.1"
)
hdf5_to_anndata(
    "/vast/projects/cellxgene_curated/splitted_DB2_data_scaled_0.2.1",
    "/vast/projects/cellxgene_curated/splitted_DB2_anndata_scaled_0.2.1"
)
} # }
```
