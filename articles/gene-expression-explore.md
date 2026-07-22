# Gene Expression Explore

## Overview

The unified pseudobulk AnnData object was generated after quality
control and retaining at least 15,000 intersecting genes across samples,
and uploaded to Zenodo
[10.5281/zenodo.21388944](https://zenodo.org/records/21388944).

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r

library(cellNexus)
library(dplyr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
metadata <- metadata |>
  keep_quality_cells()
```

## Choose cells through metadata filters

``` r

query_metadata <- metadata |>
  dplyr::filter(
    age_days >= 40*365,
    cell_type_unified_ensemble == "cd16 mono",
    tissue_groups == "breast",
    imputed_ethnicity == "African American"
  )
query_metadata  
#> # Source:   SQL [?? x 36]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id dataset_id        sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>      <dbl> <chr>             <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl> <lgl>        
#>  1      16 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438       9.80 FALSE        
#>  2      19 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876       9.15 FALSE        
#>  3      14 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      10.5  FALSE        
#>  4       2 842c6f5d-4a94-4e… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342       9.40 FALSE        
#>  5      22 842c6f5d-4a94-4e… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      11.1  FALSE        
#>  6      21 842c6f5d-4a94-4e… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      10.2  FALSE        
#>  7      24 842c6f5d-4a94-4e… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      10.7  FALSE        
#>  8      11 842c6f5d-4a94-4e… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      11.2  FALSE        
#>  9      25 842c6f5d-4a94-4e… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      13.0  FALSE        
#> 10      24 842c6f5d-4a94-4e… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      13.8  FALSE        
#> 11      13 842c6f5d-4a94-4e… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      11.0  FALSE        
#> 12       9 842c6f5d-4a94-4e… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      12.3  FALSE        
#> 13       6 842c6f5d-4a94-4e… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      11.6  FALSE        
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 24 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>
```

## Retrieve expression by representation

### Single-cell counts

``` r

sce_counts <- query_metadata |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
```

### Counts per million

``` r

sce_cpm <- query_metadata |>
  get_single_cell_experiment(assays = "cpm")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
sce_cpm
#> # A SingleCellExperiment-tibble abstraction: 13 × 37
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell dataset_id          sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>    <chr> <chr>               <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl> <lgl>        
#>  1 16_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438       9.80 FALSE        
#>  2 19_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876       9.15 FALSE        
#>  3 14_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      10.5  FALSE        
#>  4 2_1   842c6f5d-4a94-4eef… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342       9.40 FALSE        
#>  5 22_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      11.1  FALSE        
#>  6 21_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      10.2  FALSE        
#>  7 24_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      10.7  FALSE        
#>  8 11_1  842c6f5d-4a94-4eef… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      11.2  FALSE        
#>  9 25_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      13.0  FALSE        
#> 10 24_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      13.8  FALSE        
#> 11 13_2  842c6f5d-4a94-4eef… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      11.0  FALSE        
#> 12 9_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      12.3  FALSE        
#> 13 6_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      11.6  FALSE        
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 25 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, original_cell_ <chr>
```

### Pseudobulk

``` r

pb_counts <- query_metadata |>
  get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
sce_cpm
#> # A SingleCellExperiment-tibble abstraction: 13 × 37
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell dataset_id          sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>    <chr> <chr>               <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl> <lgl>        
#>  1 16_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438       9.80 FALSE        
#>  2 19_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876       9.15 FALSE        
#>  3 14_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      10.5  FALSE        
#>  4 2_1   842c6f5d-4a94-4eef… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342       9.40 FALSE        
#>  5 22_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      11.1  FALSE        
#>  6 21_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      10.2  FALSE        
#>  7 24_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      10.7  FALSE        
#>  8 11_1  842c6f5d-4a94-4eef… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      11.2  FALSE        
#>  9 25_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      13.0  FALSE        
#> 10 24_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      13.8  FALSE        
#> 11 13_2  842c6f5d-4a94-4eef… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      11.0  FALSE        
#> 12 9_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      12.3  FALSE        
#> 13 6_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      11.6  FALSE        
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 25 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, original_cell_ <chr>
```

## Targeted gene queries

``` r

# ENSEMBL IDs are expected
sce_gene <- query_metadata |>
  get_single_cell_experiment(
    assays = "cpm",
    features = "ENSG00000134644"
  )
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
sce_gene
#> # A SingleCellExperiment-tibble abstraction: 13 × 37
#> # Features=1 | Cells=13 | Assays=cpm
#>    .cell dataset_id          sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>    <chr> <chr>               <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl> <lgl>        
#>  1 16_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438       9.80 FALSE        
#>  2 19_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876       9.15 FALSE        
#>  3 14_1  842c6f5d-4a94-4eef… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      10.5  FALSE        
#>  4 2_1   842c6f5d-4a94-4eef… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342       9.40 FALSE        
#>  5 22_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      11.1  FALSE        
#>  6 21_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      10.2  FALSE        
#>  7 24_1  842c6f5d-4a94-4eef… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      10.7  FALSE        
#>  8 11_1  842c6f5d-4a94-4eef… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      11.2  FALSE        
#>  9 25_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      13.0  FALSE        
#> 10 24_2  842c6f5d-4a94-4eef… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      13.8  FALSE        
#> 11 13_2  842c6f5d-4a94-4eef… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      11.0  FALSE        
#> 12 9_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      12.3  FALSE        
#> 13 6_2   842c6f5d-4a94-4eef… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      11.6  FALSE        
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 25 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, original_cell_ <chr>
```

## Seurat

``` r

# Seurat conversion
seurat_obj <- query_metadata |>
  get_seurat()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
seurat_obj
#> An object of class Seurat 
#> 33145 features across 13 samples within 1 assay 
#> Active assay: originalexp (33145 features, 0 variable features)
#>  2 layers present: counts, data
```

## Portable output examples

``` r

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
- Use `rank` for ranked signature.
- Use `sct` for normalized cross-cell comparison by
  [`Seurat::SCTransform`](https://satijalab.org/seurat/reference/SCTransform.html).
- Use `pseudobulk` for sample/cell-type aggregation analyses.

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
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] BiocStyle_2.38.0            RcppSpdlog_0.0.28           ggplot2_4.0.2               SummarizedExperiment_1.40.0 Biobase_2.70.0             
#>  [6] GenomicRanges_1.62.1        Seqinfo_1.0.0               IRanges_2.44.0              S4Vectors_0.49.1-1          BiocGenerics_0.56.0        
#> [11] generics_0.1.4              MatrixGenerics_1.22.0       matrixStats_1.5.0           shiny_1.13.0                anndataR_1.0.2             
#> [16] cellNexus_0.99.27           testthat_3.3.2              dplyr_1.2.1                
#> 
#> loaded via a namespace (and not attached):
#>   [1] fs_2.0.1                        spatstat.sparse_3.1-0           fontawesome_0.5.3               devtools_2.5.0                  httr_1.4.8                     
#>   [6] RColorBrewer_1.1-3              tools_4.5.3                     sctransform_0.4.3               backports_1.5.1                 utf8_1.2.6                     
#>  [11] R6_2.6.1                        DT_0.34.0                       HDF5Array_1.38.0                lazyeval_0.2.3                  uwot_0.2.4                     
#>  [16] rhdf5filters_1.22.0             withr_3.0.2                     sp_2.2-1                        gridExtra_2.3                   nanoarrow_0.8.0                
#>  [21] progressr_0.19.0                cli_3.6.6                       spatstat.explore_3.8-0          fastDummies_1.7.5               sass_0.4.10                    
#>  [26] Seurat_5.5.0.9002               arrow_23.0.1.2                  S7_0.2.1-1                      spatstat.data_3.1-9             ggridges_0.5.7                 
#>  [31] pbapply_1.7-4                   commonmark_2.0.0                R.utils_2.13.0                  parallelly_1.46.1               sessioninfo_1.2.3              
#>  [36] rstudioapi_0.18.0               ica_1.0-3                       spatstat.random_3.4-5           Matrix_1.7-4                    fansi_1.0.7                    
#>  [41] waldo_0.6.2                     rclipboard_0.2.1                abind_1.4-8                     R.methodsS3_1.8.2               lifecycle_1.0.5                
#>  [46] yaml_2.3.12                     rhdf5_2.54.1                    SparseArray_1.10.10             Rtsne_0.17                      grid_4.5.3                     
#>  [51] blob_1.3.0                      promises_1.5.0                  dir.expiry_1.18.0               miniUI_0.1.2                    lattice_0.22-9                 
#>  [56] cowplot_1.2.0                   pillar_1.11.1                   knitr_1.51                      future.apply_1.20.2             codetools_0.2-20               
#>  [61] glue_1.8.0                      tiledb_0.33.1                   spatstat.univar_3.1-7           data.table_1.18.2.1             tidySingleCellExperiment_1.20.1
#>  [66] vctrs_0.7.3                     png_0.1-9                       spam_2.11-3                     gtable_0.3.6                    aws.s3_0.3.22                  
#>  [71] assertthat_0.2.1                cachem_1.1.0                    xfun_0.57                       S4Arrays_1.10.1                 mime_0.13                      
#>  [76] rsconnect_1.8.0                 survival_3.8-6                  SingleCellExperiment_1.32.0     ellipsis_0.3.3                  fitdistrplus_1.2-6             
#>  [81] ROCR_1.0-12                     tiledbsoma_2.1.2                nlme_3.1-168                    RcppCCTZ_0.2.14                 usethis_3.2.1                  
#>  [86] bit64_4.6.0-1                   filelock_1.0.3                  RcppAnnoy_0.0.23                GenomeInfoDb_1.46.2             rprojroot_2.1.1                
#>  [91] R.cache_0.17.0                  bslib_0.10.0                    irlba_2.3.7                     KernSmooth_2.23-26              otel_0.2.0                     
#>  [96] DBI_1.3.0                       zellkonverter_1.20.1            duckdb_1.4.3                    tidyselect_1.2.1                cellxgene.census_1.16.1        
#> [101] bit_4.6.0                       compiler_4.5.3                  curl_7.0.0                      rjsoncons_1.3.2                 h5mread_1.2.1                  
#> [106] xml2_1.5.2                      nanotime_0.3.13                 desc_1.4.3                      DelayedArray_0.36.1             plotly_4.12.0                  
#> [111] bookdown_0.46                   checkmate_2.3.4                 scales_1.4.0                    lmtest_0.9-40                   spdl_0.0.5                     
#> [116] stringr_1.6.0                   digest_0.6.39                   goftest_1.2-3                   spatstat.utils_3.2-2            rmarkdown_2.31                 
#> [121] basilisk_1.22.0                 XVector_0.50.0                  htmltools_0.5.9                 pkgconfig_2.0.3                 base64enc_0.1-6                
#> [126] dbplyr_2.5.2                    fastmap_1.2.0                   rlang_1.2.0                     htmlwidgets_1.6.4               UCSC.utils_1.6.1               
#> [131] farver_2.1.2                    jquerylib_0.1.4                 zoo_1.8-15                      jsonlite_2.0.0                  R.oo_1.27.1                    
#> [136] magrittr_2.0.5                  dotCall64_1.2                   patchwork_1.3.2                 Rhdf5lib_1.32.0                 Rcpp_1.1.1-1                   
#> [141] reticulate_1.46.0               stringi_1.8.7                   brio_1.1.5                      MASS_7.3-65                     plyr_1.8.9                     
#> [146] pkgbuild_1.4.8                  parallel_4.5.3                  listenv_0.10.1                  ggrepel_0.9.8                   forcats_1.0.1                  
#> [151] deldir_2.0-4                    splines_4.5.3                   tensor_1.5.1                    igraph_2.2.3                    cellxgenedp_1.14.0             
#> [156] spatstat.geom_3.7-3             RcppHNSW_0.6.0                  reshape2_1.4.5                  pkgload_1.5.1                   ttservice_0.5.3                
#> [161] evaluate_1.0.5                  SeuratObject_5.4.0              BiocManager_1.30.27             httpuv_1.6.17                   RANN_2.6.2                     
#> [166] tidyr_1.3.2                     purrr_1.2.2                     polyclip_1.10-7                 future_1.70.0                   scattermore_1.2                
#> [171] xtable_1.8-8                    RSpectra_0.16-2                 roxygen2_7.3.3                  later_1.4.8                     viridisLite_0.4.3              
#> [176] tibble_3.3.1                    memoise_2.0.1                   aws.signature_0.6.0             cluster_2.1.8.2                 shinyWidgets_0.9.1             
#> [181] globals_0.19.1
```
