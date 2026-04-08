# Gene Expression Explore

## Overview

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r
library(cellNexus)
library(dplyr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
```

## Choose cells through metadata filters

``` r
query_metadata <- metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African",
    stringr::str_like(assay, "%10x%"),
    tissue == "lung parenchyma",
    stringr::str_like(cell_type, "%CD4%")
  )
```

## Retrieve expression by representation

### Single-cell counts

``` r
sce_counts <- query_metadata |>
  get_single_cell_experiment()
```

### Counts per million

``` r
sce_cpm <- query_metadata |>
  get_single_cell_experiment(assays = "cpm")
```

### Pseudobulk

``` r
pb_counts <- query_metadata |>
  get_pseudobulk()
```

### Metacell

``` r
mc_counts <- metadata |>
  dplyr::filter(!is.na(metacell_2)) |>
  dplyr::filter(
    self_reported_ethnicity == "African",
    stringr::str_like(assay, "%10x%"),
    tissue == "lung parenchyma",
    stringr::str_like(cell_type, "%CD4%")
  ) |>
  get_metacell(cell_aggregation = "metacell_2")
```

## Targeted gene queries

``` r
# ENSEMBL IDs are expected
sce_gene <- query_metadata |>
  get_single_cell_experiment(
    assays = "cpm",
    features = "ENSG00000134644"
  )
```

## Output options

``` r
# Seurat conversion
seurat_obj <- query_metadata |>
  get_seurat()

# Portable output examples
saveRDS(sce_counts, "single_cell_counts.rds")
HDF5Array::saveHDF5SummarizedExperiment(
  sce_counts,
  "single_cell_counts",
  replace = TRUE,
  as.sparse = TRUE
)
anndataR::write_h5ad(sce_counts, "single_cell_counts.h5ad")
```

## Interpretation notes

- Use `counts` for raw-scale abundance.
- Use `cpm` for normalized cross-cell comparisons.
- Use pseudobulk for sample/cell-type aggregation analyses.
- Use metacells for robust grouped-cell expression summarization.
