# Gene Expression Explore

## Overview

The unified pseudobulk AnnData object was generated after quality
control and retaining at least 15,000 intersecting genes across samples,
and uploaded to Zenodo
[10.5281/zenodo.20500176](https://zenodo.org/records/20500176).

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
#> # Source:   SQL [?? x 58]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1      16 j}0<Y>a#X~         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438      7509.
#>  2      19 lNmuO5xs~3         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876      7018.
#>  3      14 qxl7HJjL$L         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      7929.
#>  4       2 $jvBt8wHSK         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342      6663.
#>  5      21 Mq^|(c<-#3         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      7367.
#>  6      24 I`4{4__f#J         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      7649.
#>  7      22 %vkLP;!cqY         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      7819.
#>  8      11 gncTL3)pV~         842c6f5d-4a94-4ee… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      7874.
#>  9      25 rfOnkhfWl8         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      6640.
#> 10      24 =tj7A<!2TZ         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      7389.
#> 11      13 Py{Fqs?~!!         842c6f5d-4a94-4ee… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      7811.
#> 12       9 s$u5u14ye$         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      7781.
#> 13       6 ?y4kdGGQ!^         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      7502.
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 46 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, published_at <chr>, raw_data_location <chr>, revised_at <chr>, primary_cell_count <chr>, schema_version <chr>, tissue_type <chr>, …
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
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438      7509.
#>  2 19_1  lNmuO5xs~3         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876      7018.
#>  3 14_1  qxl7HJjL$L         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      7929.
#>  4 2_1   $jvBt8wHSK         842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342      6663.
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      7367.
#>  6 24_1  I`4{4__f#J         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      7649.
#>  7 22_1  %vkLP;!cqY         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      7819.
#>  8 11_1  gncTL3)pV~         842c6f5d-4a94-4eef-… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      7874.
#>  9 25_2  rfOnkhfWl8         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      6640.
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      7389.
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4a94-4eef-… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      7811.
#> 12 9_2   s$u5u14ye$         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      7781.
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      7502.
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, published_at <chr>, raw_data_location <chr>, revised_at <chr>, primary_cell_count <chr>, schema_version <chr>, tissue_type <chr>, …
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
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438      7509.
#>  2 19_1  lNmuO5xs~3         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876      7018.
#>  3 14_1  qxl7HJjL$L         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      7929.
#>  4 2_1   $jvBt8wHSK         842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342      6663.
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      7367.
#>  6 24_1  I`4{4__f#J         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      7649.
#>  7 22_1  %vkLP;!cqY         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      7819.
#>  8 11_1  gncTL3)pV~         842c6f5d-4a94-4eef-… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      7874.
#>  9 25_2  rfOnkhfWl8         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      6640.
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      7389.
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4a94-4eef-… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      7811.
#> 12 9_2   s$u5u14ye$         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      7781.
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      7502.
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, published_at <chr>, raw_data_location <chr>, revised_at <chr>, primary_cell_count <chr>, schema_version <chr>, tissue_type <chr>, …
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
#> # A SingleCellExperiment-tibble abstraction: 13 × 59
#> # Features=1 | Cells=13 | Assays=cpm
#>    .cell observation_joinid dataset_id           sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA
#>    <chr> <chr>              <chr>                <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl>
#>  1 16_1  j}0<Y>a#X~         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438      7509.
#>  2 19_1  lNmuO5xs~3         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876      7018.
#>  3 14_1  qxl7HJjL$L         842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      7929.
#>  4 2_1   $jvBt8wHSK         842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342      6663.
#>  5 21_1  Mq^|(c<-#3         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1552      7367.
#>  6 24_1  I`4{4__f#J         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1800      7649.
#>  7 22_1  %vkLP;!cqY         842c6f5d-4a94-4eef-… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast                          1759      7819.
#>  8 11_1  gncTL3)pV~         842c6f5d-4a94-4eef-… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast                           399      7874.
#>  9 25_2  rfOnkhfWl8         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1324      6640.
#> 10 24_2  =tj7A<!2TZ         842c6f5d-4a94-4eef-… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast                          1254      7389.
#> 11 13_2  Py{Fqs?~!!         842c6f5d-4a94-4eef-… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast                          1368      7811.
#> 12 9_2   s$u5u14ye$         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1767      7781.
#> 13 6_2   ?y4kdGGQ!^         842c6f5d-4a94-4eef-… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast                          1771      7502.
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 47 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   alive <lgl>, cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, published_at <chr>, raw_data_location <chr>, revised_at <chr>, primary_cell_count <chr>, schema_version <chr>, tissue_type <chr>, …
```

## Seurat

``` r
# Seurat conversion
seurat_obj <- query_metadata |>
  get_seurat()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  1s

                                                                
ℹ Compiling Experiment.
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
#> [1] BiocStyle_2.38.0  RcppSpdlog_0.0.28 cellNexus_0.99.26 ggplot2_4.0.2     dplyr_1.2.1      
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
#> [111] desc_1.4.3                      nanotime_0.3.13                 DelayedArray_0.36.1             plotly_4.12.0                   bookdown_0.46                  
#> [116] checkmate_2.3.4                 scales_1.4.0                    lmtest_0.9-40                   spdl_0.0.5                      stringr_1.6.0                  
#> [121] anndataR_1.0.2                  digest_0.6.39                   goftest_1.2-3                   spatstat.utils_3.2-2            rmarkdown_2.31                 
#> [126] basilisk_1.22.0                 XVector_0.50.0                  htmltools_0.5.9                 pkgconfig_2.0.3                 base64enc_0.1-6                
#> [131] MatrixGenerics_1.22.0           dbplyr_2.5.2                    fastmap_1.2.0                   rlang_1.2.0                     htmlwidgets_1.6.4              
#> [136] UCSC.utils_1.6.1                shiny_1.13.0                    farver_2.1.2                    jquerylib_0.1.4                 zoo_1.8-15                     
#> [141] jsonlite_2.0.0                  magrittr_2.0.5                  dotCall64_1.2                   patchwork_1.3.2                 Rhdf5lib_1.32.0                
#> [146] Rcpp_1.1.1-1                    reticulate_1.46.0               stringi_1.8.7                   brio_1.1.5                      MASS_7.3-65                    
#> [151] plyr_1.8.9                      pkgbuild_1.4.8                  parallel_4.5.3                  listenv_0.10.1                  ggrepel_0.9.8                  
#> [156] forcats_1.0.1                   deldir_2.0-4                    splines_4.5.3                   tensor_1.5.1                    cellxgenedp_1.14.0             
#> [161] igraph_2.2.3                    spatstat.geom_3.7-3             RcppHNSW_0.6.0                  reshape2_1.4.5                  stats4_4.5.3                   
#> [166] pkgload_1.5.1                   evaluate_1.0.5                  ttservice_0.5.3                 SeuratObject_5.4.0              BiocManager_1.30.27            
#> [171] httpuv_1.6.17                   RANN_2.6.2                      tidyr_1.3.2                     purrr_1.2.2                     polyclip_1.10-7                
#> [176] future_1.70.0                   scattermore_1.2                 xtable_1.8-8                    RSpectra_0.16-2                 roxygen2_7.3.3                 
#> [181] later_1.4.8                     viridisLite_0.4.3               tibble_3.3.1                    memoise_2.0.1                   aws.signature_0.6.0            
#> [186] IRanges_2.44.0                  cluster_2.1.8.2                 shinyWidgets_0.9.1              globals_0.19.1
```
