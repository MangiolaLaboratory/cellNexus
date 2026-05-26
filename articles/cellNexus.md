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
loads harmonised annotations. Users can retrieve original Census
annotations by the function
[`join_census_table()`](https://mangiolalaboratory.github.io/cellNexus/reference/join_census_table.md).

``` r

metadata <- get_metadata() |>
  join_census_table()
#> ℹ Downloading 1 file, totalling 0.43 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/census_cell_metadata.2.3.0.parquet to /vast/scratch/users/shen.m/r_cache/R/cellNexus/census_cell_metadata.2.3.0.parquet
#> ℹ Downloading 1 file, totalling 0.9 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_metadata.2.3.0.parquet to /vast/scratch/users/shen.m/r_cache/R/cellNexus/cellnexus_metadata.2.3.0.parquet
metadata
#> # Source:   SQL [?? x 76]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id                       sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups
#>      <dbl> <chr>              <chr>                            <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>        
#>  1    3670 -08E8se6Ii         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  2     519 &7%VnKpYm6         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  3    3674 dz@)@k#<V#         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  4    3430 9v{tS;L+wQ         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  5    3471 Z*;~@?yoi(         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  6    3474 Qa9?c3UqN^         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  7    3477 7|N`hFx0Qr         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  8    3483 `!a(s{Z6^s         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#>  9    3748 (g+_FXEA&4         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#> 10    3500 _oid2*7KJQ         30cd5311-6c09-46c9-94f1-71fe4b9… 420ce6ff… 420ce6… ""            <NA>             HGR0000124___bl…    28835 blood        
#> # ℹ more rows
#> # ℹ 66 more variables: nFeature_expressed_in_sample <int>, nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>,
#> #   count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, cell_type <chr>, cell_type_ontology_term_id <chr>, assay <chr>, …
```

Metadata is saved to
[`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md)
unless a custom path is provided via the cache_directory argument. The
`metadata` variable can then be re-used for all subsequent queries.

#### Explore the tissue

``` r

metadata |>
  dplyr::distinct(tissue, cell_type_unified_ensemble)
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
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

### Quality control

cellNexus metadata applies standardised quality control to filter out
empty droplets, dead or damaged cells, doublets, and samples with low
gene counts.

``` r

metadata <- metadata |>
  keep_quality_cells()

metadata <- metadata |>
  dplyr::filter(feature_count >= 5000)
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
#> ℹ Downloading 10 files, totalling 0.03 GB
#> ℹ Downloading 10 files in parallel...
#> ℹ Reading files.
#> 
Reading counts ■■■■                              10% | ETA: 15s

Reading counts ■■■■■■■                           20% | ETA: 12s

Reading counts ■■■■■■■■■■                        30% | ETA: 12s

Reading counts ■■■■■■■■■■■■■                     40% | ETA: 10s

Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  8s

Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  6s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  5s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  3s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  2s

                                                                
ℹ Compiling Experiment.

single_cell_counts
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 77
#> #  [90mFeatures=33145 | Cells=2924 | Assays=counts [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 1_1   I8a42<8st4         842c6f5d-4… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395
#>  2 76_1  bTlx!HK=oS         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671
#>  3 77_1  E4g5+)v;AV         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340
#>  4 78_1  +q?29B%2nH         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714
#>  5 79_1  zuJ#MBMWy;         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1506
#>  6 72_1  8wGs7JgUjj         842c6f5d-4… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548
#>  7 75_1  F9G7A+GgjA         842c6f5d-4… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291
#>  8 73_1  z_=CTOs4{z         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866
#>  9 74_1  fNzorxA`Mf         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942
#> 10 80_1  zz-!e5_XAo         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 66 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, …
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
#> ℹ Downloading 10 files, totalling 0.03 GB
#> ℹ Downloading 10 files in parallel...
#> ℹ Reading files.
#> 
Reading cpm ■■■■                              10% | ETA: 12s

Reading cpm ■■■■■■■                           20% | ETA: 18s

Reading cpm ■■■■■■■■■■                        30% | ETA: 13s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA: 10s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  8s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  6s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  5s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 77
#> #  [90mFeatures=33145 | Cells=2924 | Assays=cpm [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 72_1  8wGs7JgUjj         842c6f5d-4… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548
#>  2 75_1  F9G7A+GgjA         842c6f5d-4… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291
#>  3 73_1  z_=CTOs4{z         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866
#>  4 74_1  fNzorxA`Mf         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942
#>  5 80_1  zz-!e5_XAo         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749
#>  6 81_1  -mb&DWckf(         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1993
#>  7 1_1   I8a42<8st4         842c6f5d-4… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395
#>  8 76_1  bTlx!HK=oS         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671
#>  9 77_1  E4g5+)v;AV         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340
#> 10 78_1  +q?29B%2nH         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 66 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, …
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
#> ℹ Downloading 10 files, totalling 0.03 GB
#> ℹ Downloading 10 files in parallel...
#> ℹ Reading files.
#> ! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> 
Reading sct ■■■■                              10% | ETA: 14s

Reading sct ■■■■■■■                           20% | ETA: 11s

Reading sct ■■■■■■■■■■                        30% | ETA: 11s

Reading sct ■■■■■■■■■■■■■                     40% | ETA:  9s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■                     40% | ETA:  9s

Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  7s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  7s

Reading sct ■■■■■■■■■■■■■■■■■■■               60% | ETA:  6s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  4s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  4s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  3s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_sct
#> # A SingleCellExperiment-tibble abstraction: 1,244 × 77
#> #  [90mFeatures=33145 | Cells=1244 | Assays=sct [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 72_1  8wGs7JgUjj         842c6f5d-4… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548
#>  2 75_1  F9G7A+GgjA         842c6f5d-4… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291
#>  3 1_1   I8a42<8st4         842c6f5d-4… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395
#>  4 73_1  z_=CTOs4{z         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866
#>  5 74_1  fNzorxA`Mf         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942
#>  6 80_1  zz-!e5_XAo         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749
#>  7 81_1  -mb&DWckf(         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1993
#>  8 22_2  2lQ`<&l3-A         842c6f5d-4… 30967738… 309677… ""            <NA>             7d4045ff-3f48-4…    14600 breast                          2058
#>  9 23_2  sqV-|vcI4R         842c6f5d-4… d8ecdd92… d8ecdd… ""            <NA>             bc909bba-be16-4…    14600 breast                          2375
#> 10 5_2   +p4uNj_7$S         842c6f5d-4… a91e6814… a91e68… ""            <NA>             700a819c-03f9-4…    14600 breast                          1870
#> # ℹ 1,234 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 66 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, …
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
#> ℹ Downloading 6 files, totalling 0.98 GB
#> ℹ Downloading 6 files in parallel...
#> ℹ Reading files.
#> 
Reading counts ■■■■■                             14% | ETA: 19s

Reading counts ■■■■■■■■■■                        29% | ETA: 20s

Reading counts ■■■■■■■■■■■■■■                    43% | ETA: 16s

Reading counts ■■■■■■■■■■■■■■■■■■                57% | ETA: 12s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            71% | ETA:  8s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% | ETA:  4s

                                                                
! cellNexus says: Not all genes completely overlap across the provided objects. Counts are generated by genes intersection.
#> ℹ Compiling Experiment.

pseudobulk_counts
#> # A SingleCellExperiment-tibble abstraction: 139 × 60
#> #  [90mFeatures=15888 | Cells=139 | Assays=counts [0m
#>    .cell        dataset_id sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups cell_type_unified_en…¹ sample_chunk
#>    <chr>        <chr>      <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>         <chr>                         <int>
#>  1 2e8c9911c9b… 0ba16f4b-… 2e8c9911… 2e8c99… ""            <NA>             HDBR15279,HDBR1…       NA respiratory … cd14 mono                         1
#>  2 f71af64a552… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … monocytic                         1
#>  3 f71af64a552… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … cd14 mono                         1
#>  4 f71af64a552… 1e6a6ef9-… f71af64a… f71af6… ""            <NA>             Leader_Merad_20…    27010 respiratory … cd8 tem                           1
#>  5 0d874636bc7… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … cd14 mono                         1
#>  6 0d874636bc7… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … monocytic                         1
#>  7 0d874636bc7… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … cd16 mono                         1
#>  8 0d874636bc7… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … macrophage                        1
#>  9 0d874636bc7… 1e6a6ef9-… 0d874636… 0d8746… ""            <NA>             Leader_Merad_20…    29930 respiratory … other                             1
#> 10 11721339cb1… 1e6a6ef9-… 11721339… 117213… ""            <NA>             Leader_Merad_20…    26645 respiratory … monocytic                         1
#> # ℹ 129 more rows
#> # ℹ abbreviated name: ¹​cell_type_unified_ensemble
#> # ℹ 49 more variables: cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>,
#> #   imputed_ethnicity <chr>, atlas_id <chr>, assay <chr>, assay_ontology_term_id <chr>, development_stage <chr>,
#> #   development_stage_ontology_term_id <chr>, disease <chr>, disease_ontology_term_id <chr>, donor_id <chr>, is_primary_data <chr>, organism <chr>,
#> #   organism_ontology_term_id <chr>, self_reported_ethnicity <chr>, self_reported_ethnicity_ontology_term_id <chr>, sex <chr>, …
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
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#>   source    target ligand receptor   lr_prob lr_pval interaction_name    interaction_name_2  pathway_name annotation evidence pathway_prob pathway_pval
#>   <chr>     <chr>  <chr>  <chr>        <dbl>   <dbl> <chr>               <chr>               <chr>        <chr>      <chr>           <dbl>        <dbl>
#> 1 b         b      TGFB1  TGFbR1_R2 0.000116    1    TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.000420        1    
#> 2 b memory  b      TGFB1  TGFbR1_R2 0.000865    1    TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.00185         1    
#> 3 b naive   b      TGFB1  TGFbR1_R2 0.000696    0.99 TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.00146         0.994
#> 4 cd14 mono b      TGFB1  TGFbR1_R2 0.00240     0.81 TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.00472         0.924
#> 5 cd4 naive b      TGFB1  TGFbR1_R2 0.000957    1    TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.00201         0.998
#> 6 cd4 tem   b      TGFB1  TGFbR1_R2 0.00242     0.76 TGFB1_TGFBR1_TGFBR2 TGFB1 - (TGFBR1+TG… TGFb         Secreted … KEGG: h…     0.00467         0.797
#> # ℹ 3 more variables: sample_id <chr>, interaction_count <dbl>, interaction_weight <dbl>
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
Reading cpm ■■■■                              10% | ETA: 12s

Reading cpm ■■■■■■■                           20% | ETA: 10s

Reading cpm ■■■■■■■■■■                        30% | ETA: 10s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA:  8s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  7s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  5s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> # A SingleCellExperiment-tibble abstraction: 2,924 × 77
#> #  [90mFeatures=1 | Cells=2924 | Assays=cpm [0m
#>    .cell observation_joinid dataset_id  sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <chr>              <chr>       <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>
#>  1 1_1   I8a42<8st4         842c6f5d-4… 184fa234… 184fa2… ""            <NA>             c2aa4d8d-e9df-4…    14600 breast                          3395
#>  2 76_1  bTlx!HK=oS         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1671
#>  3 77_1  E4g5+)v;AV         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          2340
#>  4 78_1  +q?29B%2nH         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1714
#>  5 79_1  zuJ#MBMWy;         842c6f5d-4… 52ab9222… 52ab92… ""            <NA>             7ce86149-8906-4…    14600 breast                          1506
#>  6 72_1  8wGs7JgUjj         842c6f5d-4… 6b194412… 6b1944… ""            <NA>             b3ff1aad-40fd-4…    14600 breast                          2548
#>  7 75_1  F9G7A+GgjA         842c6f5d-4… db5a69ed… db5a69… ""            <NA>             49beb83c-66a1-4…    14600 breast                          1291
#>  8 73_1  z_=CTOs4{z         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          2866
#>  9 74_1  fNzorxA`Mf         842c6f5d-4… 4b5e66fa… 4b5e66… ""            <NA>             04983012-bb56-4…    14600 breast                          1942
#> 10 80_1  zz-!e5_XAo         842c6f5d-4… 1de3f3ba… 1de3f3… ""            <NA>             7fabaf1c-52fd-4…    14600 breast                          1749
#> # ℹ 2,914 more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 66 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>,
#> #   sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, …
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
Reading counts ■■■■                              10% | ETA: 12s

Reading counts ■■■■■■■                           20% | ETA: 10s

Reading counts ■■■■■■■■■■                        30% | ETA:  9s

Reading counts ■■■■■■■■■■■■■                     40% | ETA:  8s

Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  7s

Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  5s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  4s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  3s

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
#> Error:
#> ! error in evaluating the argument '.data' in selecting a method for function 'join_features': ℹ In index: 1.
#> ℹ With name: cpm.
#> Caused by error in `map()` at cellNexus/R/counts.R:363:5:
#> ℹ In index: 1.
#> Caused by error in `group_to_data_container()` at cellNexus/R/counts.R:366:7:
#> ! Your cache does not contain the file
#>   /vast/scratch/users/shen.m/r_cache/R/cellNexus/cellxgene_2024/0.4.0/cpm/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad you attempted to query. Please
#>   provide the repository parameter so that files can be synchronised from the internet

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
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
#> # A SingleCellExperiment-tibble abstraction: 500 × 7
#> # Features=13132 | Cells=500 | Assays=counts
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
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8   
#>  [6] LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Australia/Melbourne
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] BiocStyle_2.38.0  ggplot2_4.0.2     dplyr_1.2.1       cellNexus_0.99.22
#> 
#> loaded via a namespace (and not attached):
#>   [1] RcppAnnoy_0.0.23                splines_4.5.3                   later_1.4.8                     filelock_1.0.3                 
#>   [5] tibble_3.3.1                    polyclip_1.10-7                 fastDummies_1.7.5               lifecycle_1.0.5                
#>   [9] rprojroot_2.1.1                 globals_0.19.1                  lattice_0.22-9                  MASS_7.3-65                    
#>  [13] backports_1.5.1                 magrittr_2.0.5                  sass_0.4.10                     plotly_4.12.0                  
#>  [17] rmarkdown_2.31                  jquerylib_0.1.4                 yaml_2.3.12                     httpuv_1.6.17                  
#>  [21] otel_0.2.0                      Seurat_5.5.0.9002               sctransform_0.4.3               spam_2.11-3                    
#>  [25] sp_2.2-1                        sessioninfo_1.2.3               pkgbuild_1.4.8                  spatstat.sparse_3.1-0          
#>  [29] reticulate_1.46.0               cowplot_1.2.0                   pbapply_1.7-4                   DBI_1.3.0                      
#>  [33] RColorBrewer_1.1-3              abind_1.4-8                     pkgload_1.5.1                   Rtsne_0.17                     
#>  [37] GenomicRanges_1.62.1            purrr_1.2.2                     BiocGenerics_0.56.0             tidySingleCellExperiment_1.20.1
#>  [41] IRanges_2.44.0                  S4Vectors_0.49.1-1              ggrepel_0.9.8                   irlba_2.3.7                    
#>  [45] listenv_0.10.1                  spatstat.utils_3.2-2            goftest_1.2-3                   RSpectra_0.16-2                
#>  [49] spatstat.random_3.4-5           fitdistrplus_1.2-6              parallelly_1.46.1               commonmark_2.0.0               
#>  [53] codetools_0.2-20                DelayedArray_0.36.1             xml2_1.5.2                      tidyselect_1.2.1               
#>  [57] rclipboard_0.2.1                UCSC.utils_1.6.1                farver_2.1.2                    shinyWidgets_0.9.1             
#>  [61] matrixStats_1.5.0               stats4_4.5.3                    spatstat.explore_3.8-0          duckdb_1.4.3                   
#>  [65] Seqinfo_1.0.0                   roxygen2_7.3.3                  jsonlite_2.0.0                  ellipsis_0.3.3                 
#>  [69] progressr_0.19.0                ggridges_0.5.7                  survival_3.8-6                  tools_4.5.3                    
#>  [73] ica_1.0-3                       Rcpp_1.1.1-1                    glue_1.8.0                      gridExtra_2.3                  
#>  [77] SparseArray_1.10.10             xfun_0.57                       MatrixGenerics_1.22.0           usethis_3.2.1                  
#>  [81] GenomeInfoDb_1.46.2             HDF5Array_1.38.0                withr_3.0.2                     BiocManager_1.30.27            
#>  [85] fastmap_1.2.0                   basilisk_1.22.0                 fansi_1.0.7                     rhdf5filters_1.22.0            
#>  [89] ttservice_0.5.3                 digest_0.6.39                   R6_2.6.1                        mime_0.13                      
#>  [93] scattermore_1.2                 tensor_1.5.1                    spatstat.data_3.1-9             h5mread_1.2.1                  
#>  [97] utf8_1.2.6                      tidyr_1.3.2                     generics_0.1.4                  data.table_1.18.2.1            
#> [101] httr_1.4.8                      htmlwidgets_1.6.4               S4Arrays_1.10.1                 uwot_0.2.4                     
#> [105] pkgconfig_2.0.3                 gtable_0.3.6                    rsconnect_1.8.0                 blob_1.3.0                     
#> [109] lmtest_0.9-40                   S7_0.2.1-1                      SingleCellExperiment_1.32.0     XVector_0.50.0                 
#> [113] htmltools_0.5.9                 bookdown_0.46                   dotCall64_1.2                   SeuratObject_5.4.0             
#> [117] scales_1.4.0                    Biobase_2.70.0                  png_0.1-9                       spatstat.univar_3.1-7          
#> [121] knitr_1.51                      rstudioapi_0.18.0               reshape2_1.4.5                  checkmate_2.3.4                
#> [125] nlme_3.1-168                    curl_7.0.0                      anndataR_1.0.2                  rhdf5_2.54.1                   
#> [129] cachem_1.1.0                    zoo_1.8-15                      stringr_1.6.0                   KernSmooth_2.23-26             
#> [133] parallel_4.5.3                  miniUI_0.1.2                    arrow_23.0.1.2                  zellkonverter_1.20.1           
#> [137] desc_1.4.3                      pillar_1.11.1                   grid_4.5.3                      vctrs_0.7.3                    
#> [141] RANN_2.6.2                      promises_1.5.0                  dbplyr_2.5.2                    xtable_1.8-8                   
#> [145] cluster_2.1.8.2                 evaluate_1.0.5                  cli_3.6.6                       compiler_4.5.3                 
#> [149] rlang_1.2.0                     future.apply_1.20.2             forcats_1.0.1                   plyr_1.8.9                     
#> [153] fs_2.0.1                        stringi_1.8.7                   viridisLite_0.4.3               deldir_2.0-4                   
#> [157] assertthat_0.2.1                lazyeval_0.2.3                  devtools_2.5.0                  spatstat.geom_3.7-3            
#> [161] Matrix_1.7-4                    dir.expiry_1.18.0               RcppHNSW_0.6.0                  patchwork_1.3.2                
#> [165] bit64_4.6.0-1                   future_1.70.0                   Rhdf5lib_1.32.0                 shiny_1.13.0                   
#> [169] SummarizedExperiment_1.40.0     ROCR_1.0-12                     igraph_2.2.3                    memoise_2.0.1                  
#> [173] bslib_0.10.0                    bit_4.6.0
```
