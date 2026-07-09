# cellNexus

[![Lifecycle:maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)

## Introduction

`cellNexus` extends the functionality of `CuratedAtlasQueryR` by
providing a unified interface for querying and accessing the harmonised,
curated, and reannotated CELLxGENE human cell atlas. It enables
reproducible, programmatic exploration of large-scale single-cell
datasets, supporting data retrieval at the cell, sample, and dataset
levels with flexible filtering based on tissue, cell type, experimental
condition, and other metadata. Retrieved data are returned in formats
ready for downstream analysis.

The package integrates over 44 million human cells processed through a
standardised pipeline, including consistent quality control,
normalisation, and unified abundance representations (e.g., single-cell,
counts-per-million, normalised expression, and pseudobulk). This
harmonisation facilitates efficient cross-dataset comparison and
integration.

Data are hosted on the ARDC Nectar Research Cloud, and most functions
access them via web requests; therefore, an active network connection is
required for typical use.

While both cellNexus and CuratedAtlasQueryR rely on precomputed
expression layers, cellNexus adopts a more standardised and transparent
processing workflow. This includes explicit removal of empty droplets
and dead cells, followed by harmonised quality control, normalisation,
and multi-layer data generation, ensuring alignment with evolving
CELLxGENE releases.

![plot of chunk fig-logo](../reference/figures/logo.png)

plot of chunk fig-logo

![plot of chunk fig-funders](../reference/figures/svcf_logo.jpeg)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/czi_logo.png)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/bioconductor_logo.jpg)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/vca_logo.png)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/nectar_logo.png)

plot of chunk fig-funders

![plot of chunk
fig-funders](../reference/figures/CSL_Limited_logo.svg.png)

plot of chunk fig-funders

## Query interface

### Installation

``` r

devtools::install_github("MangiolaLaboratory/cellNexus")
```

### Load the package

``` r

library(cellNexus)
```

### Load additional packages

``` r

suppressPackageStartupMessages({
  library(ggplot2)
})
```

### Load and explore the metadata

#### Load the metadata

By default,
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
loads harmonised annotations. Metadata is saved to
[`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md)
unless a custom path is provided via the cache_directory argument. The
`metadata` variable can then be re-used for all subsequent queries.

The unified pseudobulk AnnData object was generated after quality
control and retaining at least 15,000 intersecting genes across samples,
and uploaded to Zenodo
[10.5281/zenodo.20500176](https://zenodo.org/records/20500176).

The following sections demonstrate the metadata, quality control,
generation of raw and normalised counts, and pseudobulk construction for
the specified query.

``` r

metadata <- get_metadata()
metadata
#> # Source:   SQL [?? x 37]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1    3670 -08E8se6Ii         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1826       8.46
#>  2     519 &7%VnKpYm6         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1554       9.39
#>  3    3674 dz@)@k#<V#         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1491       8.30
#>  4    3430 9v{tS;L+wQ         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1328       9.43
#>  5    3471 Z*;~@?yoi(         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1145       9.47
#>  6    3474 Qa9?c3UqN^         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1852       9.73
#>  7    3477 7|N`hFx0Qr         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           2411       9.35
#>  8    3483 `!a(s{Z6^s         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1166      10.2 
#>  9    3748 (g+_FXEA&4         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1075      10.6 
#> 10    3500 _oid2*7KJQ         30cd5311-6c09-46c… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood                           1536       9.64
#> # ℹ more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 25 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>
```

### Quality control

cellNexus metadata applies standardised quality control to filter out
empty droplets, dead or damaged cells, doublets, and samples with low
gene counts.

``` r

metadata <- metadata |>
  keep_quality_cells()

nfeatures_df <- cellNexus:::get_cellxgene_metadata("dataset") |>
  dplyr::select(dplyr::where(~ !is.list(.x)))
  
metadata <- metadata |>
  dplyr::left_join(nfeatures_df,
                   by = "dataset_id",
                   copy = TRUE) |>
  dplyr::filter(feature_count >= 5000)
```

### Join Census metadata

Original Census annotations can be retrieved by the function
`get_census_metadata()`, and registered to lazy tibble format by
[DuckDB](https://duckdb.org/docs/current/clients/r)

``` r

census_metadata <- cellNexus:::get_census_metadata("2024-07-01")
#> ℹ Opening Census version 2024-07-01.
#> ℹ Reading Census obs table.

con <- dbplyr::remote_con(metadata)

duckdb::duckdb_register_arrow(con, "census_metadata", census_metadata)

metadata <- metadata |>
  dplyr::left_join(tbl(con, "census_metadata") |> 
                   dplyr::select(observation_joinid, dataset_id, tissue, self_reported_ethnicity, cell_type, assay, disease))
#> Joining with `by = join_by(observation_joinid, dataset_id)`
```

#### Explore tissues

``` r

metadata |>
  dplyr::distinct(tissue, cell_type_unified_ensemble)
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    tissue     cell_type_unified_ensemble
#>    <chr>      <chr>                     
#>  1 cerebellum pericyte                  
#>  2 cerebellum endothelial               
#>  3 cerebellum other                     
#>  4 cerebellum dc                        
#>  5 cerebellum immune                    
#>  6 spleen     b                         
#>  7 spleen     nk                        
#>  8 spleen     b memory                  
#>  9 spleen     cdc                       
#> 10 spleen     t cd4                     
#> # ℹ more rows
```

### Download single-cell RNA sequencing counts

#### Query raw counts

``` r
single_cell_counts <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■                              10% | ETA: 12s

Reading counts ■■■■■■■                           20% | ETA:  9s

Reading counts ■■■■■■■■■■                        30% | ETA:  7s

Reading counts ■■■■■■■■■■■■■                     40% | ETA:  5s

Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  4s

Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                                
ℹ Compiling Experiment.

single_cell_counts
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 59
#> # [90mFeatures=33145 | Cells=2924 | Assays=counts[0m
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 76_1  bTlx!HK=oS         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671       9.65
#>  2 77_1  E4g5+)v;AV         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340      11.9 
#>  3 78_1  +q?29B%2nH         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714      13.2 
#>  4 79_1  zuJ#MBMWy;         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1506      12.3 
#>  5 72_1  8wGs7JgUjj         842c6f5d-4a94-4eef-… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548      13.1 
#>  6 75_1  F9G7A+GgjA         842c6f5d-4a94-4eef-… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291      10.2 
#>  7 1_1   I8a42<8st4         842c6f5d-4a94-4eef-… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395      11.8 
#>  8 73_1  z_=CTOs4{z         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866      10.3 
#>  9 74_1  fNzorxA`Mf         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942       7.58
#> 10 80_1  zz-!e5_XAo         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749      10.8 
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, dataset_version_id <chr>, collection_id <chr>, cell_count <int>, …
```

#### Query counts scaled per million

``` r
single_cell_cpm <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "cpm")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■                           20% | ETA:  4s

Reading cpm ■■■■■■■■■■                        30% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 59
#> # [90mFeatures=33145 | Cells=2924 | Assays=cpm[0m
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 76_1  bTlx!HK=oS         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671       9.65
#>  2 77_1  E4g5+)v;AV         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340      11.9 
#>  3 78_1  +q?29B%2nH         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714      13.2 
#>  4 79_1  zuJ#MBMWy;         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1506      12.3 
#>  5 1_1   I8a42<8st4         842c6f5d-4a94-4eef-… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395      11.8 
#>  6 72_1  8wGs7JgUjj         842c6f5d-4a94-4eef-… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548      13.1 
#>  7 75_1  F9G7A+GgjA         842c6f5d-4a94-4eef-… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291      10.2 
#>  8 73_1  z_=CTOs4{z         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866      10.3 
#>  9 74_1  fNzorxA`Mf         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942       7.58
#> 10 80_1  zz-!e5_XAo         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749      10.8 
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, dataset_version_id <chr>, collection_id <chr>, cell_count <int>, …
```

#### Query SCT normalised counts

``` r
single_cell_sct <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "sct")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> 
Reading sct ■■■■■■■                           20% | ETA:  5s

Reading sct ■■■■■■■■■■                        30% | ETA:  5s

Reading sct ■■■■■■■■■■■■■                     40% | ETA:  4s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■                     40% | ETA:  4s

Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

Reading sct ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
! cellNexus says: 1680 cell(s) from your metadata are absent from the SCT assay across 4 file(s). This is expected: SCT normalisation is run per sample and may fail for samples with very few cells or extreme count distributions. The returned object contains only cells from samples where SCT succeeded. Affected sample_id(s): 52ab92226337d36c306466eefe67f9c1, 8940e0767e7eca1b72d37b4138be2276, 765554078ca8d1eaf2712000c0df0d6f, a79912cb9aaa8d8c0b1a3cdcc9294f8c, 5e641a2218d1d8b91f638989626c89e0.
#> ℹ Compiling Experiment.

single_cell_sct
#> # A SingleCellExperiment-tibble abstraction: 1,244 × 59
#> # [90mFeatures=33145 | Cells=1244 | Assays=sct[0m
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 72_1  8wGs7JgUjj         842c6f5d-4a94-4eef-… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548      13.1 
#>  2 75_1  F9G7A+GgjA         842c6f5d-4a94-4eef-… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291      10.2 
#>  3 1_1   I8a42<8st4         842c6f5d-4a94-4eef-… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395      11.8 
#>  4 73_1  z_=CTOs4{z         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866      10.3 
#>  5 74_1  fNzorxA`Mf         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942       7.58
#>  6 80_1  zz-!e5_XAo         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749      10.8 
#>  7 81_1  -mb&DWckf(         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1993      12.4 
#>  8 5_2   +p4uNj_7$S         842c6f5d-4a94-4eef-… a91e6814… a91e68… ""            <NA>             700a819c-03f9-4…    14600 breast                          1870      11.1 
#>  9 22_2  2lQ`<&l3-A         842c6f5d-4a94-4eef-… 30967738… 309677… ""            <NA>             7d4045ff-3f48-4…    14600 breast                          2058       9.91
#> 10 23_2  sqV-|vcI4R         842c6f5d-4a94-4eef-… d8ecdd92… d8ecdd… ""            <NA>             bc909bba-be16-4…    14600 breast                          2375      13.7 
#> # ℹ 1,234 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, dataset_version_id <chr>, collection_id <chr>, cell_count <int>, …
```

#### Query pseudobulk

``` r
pseudobulk_counts <-
  metadata |>
  dplyr::filter(
    assay == "10x 5' v1" &
      tissue == "lung" &
      cell_type == "classical monocyte"
  ) |>
  get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■                             14% | ETA: 11s

Reading counts ■■■■■■■■■■                        29% | ETA: 10s

Reading counts ■■■■■■■■■■■■■■                    43% | ETA:  8s

Reading counts ■■■■■■■■■■■■■■■■■■                57% | ETA:  7s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            71% | ETA:  5s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% | ETA:  2s

                                                                
! cellNexus says: Not all genes completely overlap across the provided objects. Counts are generated by genes intersection.
#> ℹ Compiling Experiment.

pseudobulk_counts
#> # A SingleCellExperiment-tibble abstraction: 139 × 42
#> # [90mFeatures=15888 | Cells=139 | Assays=counts[0m
#>    .cell                 dataset_id sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups cell_type_unified_en…¹ sample_chunk cell_chunk
#>    <chr>                 <chr>      <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>         <chr>                         <int>      <int>
#>  1 2e8c9911c9bfbffc0728… 0ba16f4b-… 2e8c9911… 2e8c99… ""            <NA>             HDBR15279,HDBR1…       NA respiratory … cd14 mono                         1          1
#>  2 0d874636bc714a8d0146… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … monocytic                         1          5
#>  3 0d874636bc714a8d0146… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … cd14 mono                         1          5
#>  4 0d874636bc714a8d0146… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … cd16 mono                         1          5
#>  5 0d874636bc714a8d0146… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … macrophage                        1          5
#>  6 0d874636bc714a8d0146… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … other                             1          5
#>  7 f71af64a552d45f5904c… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … monocytic                         1          6
#>  8 f71af64a552d45f5904c… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … cd14 mono                         1          6
#>  9 f71af64a552d45f5904c… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … cd8 tem                           1          6
#> 10 11721339cb1dfc0a7c1e… 1e6a6ef9-… 11721339… 117213… ""            <NA>             Leader_Merad_20…    26645 respiratory … monocytic                         1          7
#> # ℹ 129 more rows
#> # ℹ abbreviated name: ¹​cell_type_unified_ensemble
#> # ℹ 30 more variables: sample_pseudobulk_chunk <int>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>,
#> #   inverse_transform <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>,
#> #   dataset_version_id <chr>, collection_id <chr>, cell_count <int>, citation <chr>, default_embedding <chr>, explorer_url <chr>, feature_count <int>,
#> #   mean_genes_per_cell <dbl>, primary_cell_count <int>, schema_version <chr>, title <chr>, tombstone <lgl>, x_approximate_distribution <chr>, published_at <date>,
#> #   revised_at <date>, tissue <chr>, self_reported_ethnicity <chr>, assay <chr>, disease <chr>, sample_identifier <chr>
```

### Download cell communication metadata

Cell communication metadata was generated based on post-QC cells per
sample using `CellChat v2` method. It uses our harmonised cell type
annotation (cell_type_unified_ensemble) to infer the communication. It
captures inferred communication at both the ligand–receptor pair level
and the signalling pathway level.

- interaction_count: The number of inferred interactions between each
  pair of cell groups.

- interaction_weight: The aggregated communication strength between each
  pair of cell groups.

For definitions of additional annotations, please refer to the CellChat
v2 documentation: <https://github.com/jinworks/CellChat>.

For demonstration purpose, read cell communication metadata from a demo
file here. Users do not need to specify cloud_metadata argument in this
case.

``` r

get_cell_communication_strength(cloud_metadata = get_metadata_url("cellNexus_lr_signaling_pathway_strength_DEMO.parquet"))
#> # Source:   SQL [?? x 16]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>   source  target ligand receptor lr_prob lr_pval interaction_name interaction_name_2 pathway_name annotation evidence pathway_prob pathway_pval sample_id interaction_count
#>   <chr>   <chr>  <chr>  <chr>      <dbl>   <dbl> <chr>            <chr>              <chr>        <chr>      <chr>           <dbl>        <dbl> <chr>                 <dbl>
#> 1 b       b      TGFB1  TGFbR1_… 1.16e-4    1    TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.000420        1     b290d7ef…                24
#> 2 b memo… b      TGFB1  TGFbR1_… 8.65e-4    1    TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.00185         1     b290d7ef…                27
#> 3 b naive b      TGFB1  TGFbR1_… 6.96e-4    0.99 TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.00146         0.994 b290d7ef…                19
#> 4 cd14 m… b      TGFB1  TGFbR1_… 2.40e-3    0.81 TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.00472         0.924 b290d7ef…                46
#> 5 cd4 na… b      TGFB1  TGFbR1_… 9.57e-4    1    TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.00201         0.998 b290d7ef…                21
#> 6 cd4 tem b      TGFB1  TGFbR1_… 2.42e-3    0.76 TGFB1_TGFBR1_TG… TGFB1 - (TGFBR1+T… TGFb         Secreted … KEGG: h…     0.00467         0.797 b290d7ef…                23
#> # ℹ 1 more variable: interaction_weight <dbl>
```

#### Extract only a subset of genes

This is helpful if just few genes are of interest (e.g ENSG00000134644
(PUM1)), as they can be compared across samples. cellNexus uses ENSEMBL
gene ID(s).

``` r
single_cell_cpm <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "cpm", features = "ENSG00000134644")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■                           20% | ETA:  5s

Reading cpm ■■■■■■■■■■                        30% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 59
#> # [90mFeatures=1 | Cells=2924 | Assays=cpm[0m
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 76_1  bTlx!HK=oS         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671       9.65
#>  2 77_1  E4g5+)v;AV         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340      11.9 
#>  3 78_1  +q?29B%2nH         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714      13.2 
#>  4 79_1  zuJ#MBMWy;         842c6f5d-4a94-4eef-… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1506      12.3 
#>  5 80_1  zz-!e5_XAo         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749      10.8 
#>  6 81_1  -mb&DWckf(         842c6f5d-4a94-4eef-… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1993      12.4 
#>  7 1_1   I8a42<8st4         842c6f5d-4a94-4eef-… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395      11.8 
#>  8 72_1  8wGs7JgUjj         842c6f5d-4a94-4eef-… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548      13.1 
#>  9 75_1  F9G7A+GgjA         842c6f5d-4a94-4eef-… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291      10.2 
#> 10 73_1  z_=CTOs4{z         842c6f5d-4a94-4eef-… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866      10.3 
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, dataset_version_id <chr>, collection_id <chr>, cell_count <int>, …
```

#### Extract the counts as a Seurat object

This convert the H5 SingleCellExperiment to Seurat so it might take long
time and occupy a lot of memory depending on how many cells you are
requesting.

``` r
seurat_counts <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_seurat()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■                           20% | ETA:  6s

Reading counts ■■■■■■■■■■                        30% | ETA:  6s

Reading counts ■■■■■■■■■■■■■                     40% | ETA:  5s

Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  4s

Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                                
ℹ Compiling Experiment.

seurat_counts
#> An object of class Seurat 
#> 33145 features across 2924 samples within 1 assay 
#> Active assay: originalexp (33145 features, 0 variable features)
#>  2 layers present: counts, data
```

By default, data is downloaded to
[`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md)
output. If memory is a concern, users can specify a custom path to
metadata and counts `cache_directory` argument. For example,
`get_metadata(cache_directory = "your_own_path")` and
`get_single_cell_experiment(cache_directory = "your_own_path")`.

Same strategy can be applied for functions `get_pseuodbulk()` and
[`get_seurat()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_seurat.md).

### Save your `SingleCellExperiment`

The returned `SingleCellExperiment` can be saved with three modalities,
as `.rds` or as `HDF5` or as `H5AD`.

#### Saving as RDS (fast saving, slow reading)

Saving as `.rds` has the advantage of being fast, and the `.rds` file
occupies very little disk space as it only stores the links to the files
in your cache.

However it has the disadvantage that for big `SingleCellExperiment`
objects, which merge a lot of HDF5 from your
`get_single_cell_experiment`, the display and manipulation is going to
be slow. In addition, an `.rds` saved in this way is not portable: you
will not be able to share it with other users.

``` r

single_cell_counts |>
  saveRDS("single_cell_counts.rds")
```

#### Saving as HDF5 (slow saving, fast reading)

Saving as `.hdf5` executes any computation on the `SingleCellExperiment`
and writes it to disk as a monolithic `HDF5`. Once this is done,
operations on the `SingleCellExperiment` will be comparatively very
fast. The resulting `.hdf5` file will also be totally portable and
sharable.

However this `.hdf5` has the disadvantage of being larger than the
corresponding `.rds` as it includes a copy of the count information, and
the saving process is going to be slow for large objects.

``` r

# ! IMPORTANT if you save 200K+ cells
HDF5Array::setAutoBlockSize(size = 1e+09)

single_cell_counts |>
  HDF5Array::saveHDF5SummarizedExperiment(
    "single_cell_counts",
    replace = TRUE,
    as.sparse = TRUE,
    verbose = TRUE
  )
```

#### Saving as H5AD (slow saving, fast reading)

Saving as `.h5ad` executes any computation on the `SingleCellExperiment`
and writes it to disk as a monolithic `H5AD`. The `H5AD` format is the
HDF5 disk representation of the AnnData object and is well-supported in
Python.

However this `.h5ad` saving strategy has a bottleneck of handling
columns with only NA values of a `SingleCellExperiment` metadata.

``` r

single_cell_counts |>
  anndataR::write_h5ad("single_cell_counts.h5ad",
    compression = "gzip",
    verbose = TRUE
  )
```

### Visualise gene transcription

We can gather all CD14 monocytes cells and plot the distribution of
ENSG00000085265 (FCN1) across all tissues

``` r

# Plots with styling
counts <- metadata |>

  # Filter and subset
  dplyr::filter(cell_type_unified_ensemble == "cd14 mono") |>

  # Get counts per million for FCN1 gene
  get_single_cell_experiment(assays = "cpm", features = "ENSG00000085265") |>
  suppressMessages() |>

  # Add feature to table
  tidySingleCellExperiment::join_features("ENSG00000085265", shape = "wide") |>

  # Rank x axis
  tibble::as_tibble() |>

  # Rename to gene symbol
  dplyr::rename(FCN1 = ENSG00000085265)

# Plot by disease
counts |>
  dplyr::with_groups(disease, ~ .x |>
    dplyr::mutate(median_count = median(`FCN1`, rm.na = TRUE))) |>

  # Plot
  ggplot(aes(forcats::fct_reorder(disease, median_count, .desc = TRUE), `FCN1`, color = dataset_id)) +
  geom_jitter(shape = ".") +

  # Style
  guides(color = "none") +
  scale_y_log10() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 60, vjust = 1, hjust = 1)) +
  xlab("Disease") +
  ggtitle("FCN1 in CD14 monocytes by disease. Coloured by datasets")
#> Warning in scale_y_log10(): log-10 transformation introduced infinite values.
```

![plot of chunk plot-fcn1-disease](plot-fcn1-disease-1.png)

plot of chunk plot-fcn1-disease

``` r

# Plot by tissue
counts |>
  dplyr::with_groups(tissue, ~ .x |>
    dplyr::mutate(median_count = median(`FCN1`, rm.na = TRUE))) |>

  # Plot
  ggplot(aes(
    forcats::fct_reorder(tissue,
      median_count,
      .desc = TRUE
    ),
    `FCN1`,
    color = dataset_id
  )) +
  geom_jitter(shape = ".") +

  # Style
  guides(color = "none") +
  scale_y_log10() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 60, vjust = 1, hjust = 1)) +
  xlab("Tissue") +
  ggtitle("FCN1 in CD14 monocytes by tissue. Colored by datasets") +
  theme(legend.position = "none", axis.text.x = element_text(size = 6.5))
#> Warning in scale_y_log10(): log-10 transformation introduced infinite values.
```

![plot of chunk plot-fcn1-tissue](plot-fcn1-tissue-1.png)

plot of chunk plot-fcn1-tissue

### Integrate cloud and local metadata

`cellNexus` not only enables users to query our metadata but also allows
integration with your local metadata. Additionally, users can integrate
with your metadata stored in the cloud.

To enable this feature, users must include
`file_id_cellNexus_single_cell` and `atlas_id` (e.g cellxgene/dd-mm-yy)
columns in the metadata. See metadata structure in cellNexus::pbmc3k_sce

``` r

# Set up local cache and paths
local_cache <- tempdir()
layer <- "counts"
meta_path <- file.path(local_cache, "pbmc3k_metadata.parquet")
data(pbmc3k_sce)

# Extract and prepare metadata
pbmc3k_metadata <- pbmc3k_sce |>
  S4Vectors::metadata() |>
  purrr::pluck("data") |>
  dplyr::mutate(
    counts_directory = file.path(tempdir(), atlas_id, layer),
    sce_path = file.path(counts_directory, file_id_cellNexus_single_cell)
  )

# Get unique paths
counts_directory <- pbmc3k_metadata |>
  dplyr::pull(counts_directory) |>
  unique()

sce_path <- pbmc3k_metadata |>
  dplyr::pull(sce_path) |>
  unique()

# Create directory structure
dir.create(counts_directory, recursive = TRUE, showWarnings = FALSE)

# Save data to disk
pbmc3k_sce |>
  S4Vectors::metadata() |>
  purrr::pluck("data") |>
  arrow::write_parquet(meta_path)

# Save SCE object
pbmc3k_sce |>
  anndataR::write_h5ad(sce_path, compression = "gzip", mode = "w")
```

``` r

# A cellNexus file
file_id_from_cloud <- "e52795dec7b626b6276b867d55328d9f___1.h5ad"
file_id_local <- basename(sce_path)

get_metadata(
  cloud_metadata = cellNexus::SAMPLE_DATABASE_URL,
  local_metadata = meta_path,
  cache_directory = local_cache
) |>
  # For illustration purpose, only filter a selected cloud metadata and the saved metadata
  dplyr::filter(file_id_cellNexus_single_cell %in% c(file_id_from_cloud, file_id_local)) |>
  dplyr::select(cell_id, sample_id, dataset_id, cell_type_unified_ensemble, atlas_id, file_id_cellNexus_single_cell) |>
  get_single_cell_experiment(cache_directory = local_cache)
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_hca2024_v2.3.0.parquet to /tmp/RtmpaoZZEo/sample_hca2024_v2.3.0.parquet
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
#> # A SingleCellExperiment-tibble abstraction: 500 × 7
#> # [90mFeatures=13132 | Cells=500 | Assays=counts[0m
#>    .cell            sample_id dataset_id cell_type_unified_ensemble atlas_id             file_id_cellNexus_single_cell         original_cell_
#>    <chr>            <chr>     <chr>      <chr>                      <chr>                <chr>                                 <chr>         
#>  1 AAACATACAACCAC_1 pbmc3k    pbmc3k     Memory CD4 T               cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACATACAACCAC
#>  2 AAACATTGAGCTAC_1 pbmc3k    pbmc3k     B                          cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACATTGAGCTAC
#>  3 AAACATTGATCAGC_1 pbmc3k    pbmc3k     Memory CD4 T               cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACATTGATCAGC
#>  4 AAACCGTGCTTCCG_1 pbmc3k    pbmc3k     CD14+ Mono                 cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACCGTGCTTCCG
#>  5 AAACCGTGTATGCG_1 pbmc3k    pbmc3k     NK                         cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACCGTGTATGCG
#>  6 AAACGCACTGGTAC_1 pbmc3k    pbmc3k     Memory CD4 T               cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACGCACTGGTAC
#>  7 AAACGCTGACCAGT_1 pbmc3k    pbmc3k     CD8 T                      cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACGCTGACCAGT
#>  8 AAACGCTGGTTCTT_1 pbmc3k    pbmc3k     CD8 T                      cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACGCTGGTTCTT
#>  9 AAACGCTGTAGCCA_1 pbmc3k    pbmc3k     Naive CD4 T                cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACGCTGTAGCCA
#> 10 AAACGCTGTTTCTG_1 pbmc3k    pbmc3k     FCGR3A+ Mono               cellxgene/03-10-2025 67e196a3c4e145151fc9e06c200e2f7f.h5ad AAACGCTGTTTCTG
#> # ℹ 490 more rows
```

## Cell metadata

The complete metadata dictionary for the harmonised fields is available
on the documentation site: [cellNexus
documentation](https://cellnexus.org/).

## RNA abundance

The `counts` assay represents RNA abundance on the positive real scale,
without non-linear transformations (e.g., log or square root). In the
original CELLxGENE data, values were provided using a mix of scales and
transformations. The method required to invert these transformations is
recorded in `inverse_transform` column.

The `cpm` assay includes counts per million.

The `sct` assay includes normalised counts by `sctranform`.

## Other representations

The `rank` assay is the representation of each cell’s gene expression
profile where genes are ranked by expression intensity using
`singscore`.

The `pseudobulk` assay includes aggregated RNA abundance for sample and
cell type combination.

The detailed documentation for RNA abundance is available on the
documentation site: [cellNexus documentation](https://cellnexus.org/).

## Session Info

``` r

sessionInfo()
#> R version 4.5.3 (2026-03-11)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Red Hat Enterprise Linux 9.6 (Plow)
#> 
#> Matrix products: default
#> BLAS:   /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRblas.so 
#> LAPACK: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRlapack.so;  LAPACK version 3.12.1
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Australia/Melbourne
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] RcppSpdlog_0.0.28 cellNexus_0.99.26 ggplot2_4.0.2     dplyr_1.2.1      
#> 
#> loaded via a namespace (and not attached):
#>   [1] fs_2.0.1                        matrixStats_1.5.0               spatstat.sparse_3.1-0           devtools_2.5.0                  httr_1.4.8                     
#>   [6] RColorBrewer_1.1-3              tools_4.5.3                     sctransform_0.4.3               backports_1.5.1                 DT_0.34.0                      
#>  [11] utf8_1.2.6                      R6_2.6.1                        HDF5Array_1.38.0                lazyeval_0.2.3                  uwot_0.2.4                     
#>  [16] rhdf5filters_1.22.0             withr_3.0.2                     sp_2.2-1                        gridExtra_2.3                   nanoarrow_0.8.0                
#>  [21] progressr_0.19.0                cli_3.6.6                       Biobase_2.70.0                  spatstat.explore_3.8-0          fastDummies_1.7.5              
#>  [26] sass_0.4.10                     Seurat_5.5.0.9002               arrow_23.0.1.2                  S7_0.2.1-1                      spatstat.data_3.1-9            
#>  [31] ggridges_0.5.7                  pbapply_1.7-4                   commonmark_2.0.0                parallelly_1.46.1               sessioninfo_1.2.3              
#>  [36] rstudioapi_0.18.0               generics_0.1.4                  ica_1.0-3                       spatstat.random_3.4-5           Matrix_1.7-4                   
#>  [41] fansi_1.0.7                     S4Vectors_0.49.1-1              rclipboard_0.2.1                abind_1.4-8                     lifecycle_1.0.5                
#>  [46] yaml_2.3.12                     SummarizedExperiment_1.40.0     rhdf5_2.54.1                    SparseArray_1.10.10             Rtsne_0.17                     
#>  [51] grid_4.5.3                      blob_1.3.0                      promises_1.5.0                  dir.expiry_1.18.0               miniUI_0.1.2                   
#>  [56] lattice_0.22-9                  cowplot_1.2.0                   pillar_1.11.1                   knitr_1.51                      GenomicRanges_1.62.1           
#>  [61] future.apply_1.20.2             codetools_0.2-20                glue_1.8.0                      spatstat.univar_3.1-7           tiledb_0.33.1                  
#>  [66] data.table_1.18.2.1             tidySingleCellExperiment_1.20.1 vctrs_0.7.3                     png_0.1-9                       spam_2.11-3                    
#>  [71] testthat_3.3.2                  gtable_0.3.6                    aws.s3_0.3.22                   assertthat_0.2.1                cachem_1.1.0                   
#>  [76] xfun_0.57                       S4Arrays_1.10.1                 mime_0.13                       Seqinfo_1.0.0                   rsconnect_1.8.0                
#>  [81] survival_3.8-6                  SingleCellExperiment_1.32.0     ellipsis_0.3.3                  fitdistrplus_1.2-6              ROCR_1.0-12                    
#>  [86] nlme_3.1-168                    tiledbsoma_2.1.2                RcppCCTZ_0.2.14                 usethis_3.2.1                   bit64_4.6.0-1                  
#>  [91] filelock_1.0.3                  RcppAnnoy_0.0.23                GenomeInfoDb_1.46.2             rprojroot_2.1.1                 bslib_0.10.0                   
#>  [96] irlba_2.3.7                     KernSmooth_2.23-26              otel_0.2.0                      BiocGenerics_0.56.0             DBI_1.3.0                      
#> [101] zellkonverter_1.20.1            duckdb_1.4.3                    tidyselect_1.2.1                cellxgene.census_1.16.1         bit_4.6.0                      
#> [106] compiler_4.5.3                  curl_7.0.0                      rjsoncons_1.3.2                 h5mread_1.2.1                   xml2_1.5.2                     
#> [111] desc_1.4.3                      nanotime_0.3.13                 DelayedArray_0.36.1             plotly_4.12.0                   checkmate_2.3.4                
#> [116] scales_1.4.0                    lmtest_0.9-40                   spdl_0.0.5                      stringr_1.6.0                   anndataR_1.0.2                 
#> [121] digest_0.6.39                   goftest_1.2-3                   spatstat.utils_3.2-2            rmarkdown_2.31                  basilisk_1.22.0                
#> [126] XVector_0.50.0                  htmltools_0.5.9                 pkgconfig_2.0.3                 base64enc_0.1-6                 MatrixGenerics_1.22.0          
#> [131] dbplyr_2.5.2                    fastmap_1.2.0                   rlang_1.2.0                     htmlwidgets_1.6.4               UCSC.utils_1.6.1               
#> [136] shiny_1.13.0                    farver_2.1.2                    jquerylib_0.1.4                 zoo_1.8-15                      jsonlite_2.0.0                 
#> [141] magrittr_2.0.5                  dotCall64_1.2                   patchwork_1.3.2                 Rhdf5lib_1.32.0                 Rcpp_1.1.1-1                   
#> [146] reticulate_1.46.0               stringi_1.8.7                   brio_1.1.5                      MASS_7.3-65                     plyr_1.8.9                     
#> [151] pkgbuild_1.4.8                  parallel_4.5.3                  listenv_0.10.1                  ggrepel_0.9.8                   forcats_1.0.1                  
#> [156] deldir_2.0-4                    splines_4.5.3                   tensor_1.5.1                    cellxgenedp_1.14.0              igraph_2.2.3                   
#> [161] spatstat.geom_3.7-3             RcppHNSW_0.6.0                  reshape2_1.4.5                  stats4_4.5.3                    pkgload_1.5.1                  
#> [166] evaluate_1.0.5                  ttservice_0.5.3                 SeuratObject_5.4.0              BiocManager_1.30.27             httpuv_1.6.17                  
#> [171] RANN_2.6.2                      tidyr_1.3.2                     purrr_1.2.2                     polyclip_1.10-7                 future_1.70.0                  
#> [176] scattermore_1.2                 xtable_1.8-8                    RSpectra_0.16-2                 roxygen2_7.3.3                  later_1.4.8                    
#> [181] viridisLite_0.4.3               tibble_3.3.1                    memoise_2.0.1                   aws.signature_0.6.0             IRanges_2.44.0                 
#> [186] cluster_2.1.8.2                 shinyWidgets_0.9.1              globals_0.19.1                  BiocStyle_2.38.0
```
