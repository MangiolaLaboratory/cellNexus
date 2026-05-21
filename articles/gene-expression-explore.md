# Gene Expression Explore

## Overview

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r

library(cellNexus)
library(dplyr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])
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
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>        
#>  1      14 qxl7HJjL$L         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  2      16 j}0<Y>a#X~         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  3      19 lNmuO5xs~3         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  4       2 $jvBt8wHSK         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast       
#>  5      21 Mq^|(c<-#3         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  6      22 %vkLP;!cqY         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  7      24 I`4{4__f#J         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""            <NA>             0033e380-cba5-4…    14600 breast       
#>  8      11 gncTL3)pV~         842c6f5d-4a94-4ee… bd5f6876… bd5f68… ""            <NA>             c5d33ad8-c134-4…    14600 breast       
#>  9      25 rfOnkhfWl8         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast       
#> 10      24 =tj7A<!2TZ         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""            <NA>             68150f23-cfed-4…    14600 breast       
#> 11      13 Py{Fqs?~!!         842c6f5d-4a94-4ee… 30ea4b4f… 30ea4b… ""            <NA>             2f6cb696-f78d-4…    14600 breast       
#> 12       6 ?y4kdGGQ!^         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast       
#> 13       9 s$u5u14ye$         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""            <NA>             6fa99d77-112d-4…    14600 breast       
#> # ℹ 48 more variables: nFeature_expressed_in_sample <int>, nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>,
#> #   is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>,
#> #   scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>,
#> #   ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>,
#> #   citation <chr>, collection_id <chr>, dataset_version_id <chr>, default_embedding <chr>, published_at <chr>, …
```

## Retrieve expression by representation

### Single-cell counts

``` r
sce_counts <- query_metadata |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  2s

                                                                
ℹ Compiling Experiment.
```

### Counts per million

``` r
sce_cpm <- query_metadata |>
  get_single_cell_experiment(assays = "cpm")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  2s

                                                             
ℹ Compiling Experiment.
sce_cpm
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(58): observation_joinid dataset_id ... url original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
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
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(58): observation_joinid dataset_id ... url original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
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
#> 
Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

                                                             
ℹ Compiling Experiment.
sce_gene
#> class: SingleCellExperiment 
#> dim: 1 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(1): ENSG00000134644
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(58): observation_joinid dataset_id ... url original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
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
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  2s

                                                                
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
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Australia/Melbourne
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] cellNexus_0.99.22 dplyr_1.2.1      
#> 
#> loaded via a namespace (and not attached):
#>   [1] RcppAnnoy_0.0.23            splines_4.5.3               later_1.4.8                 filelock_1.0.3             
#>   [5] tibble_3.3.1                polyclip_1.10-7             fastDummies_1.7.5           lifecycle_1.0.5            
#>   [9] rprojroot_2.1.1             globals_0.19.1              lattice_0.22-9              MASS_7.3-65                
#>  [13] backports_1.5.1             magrittr_2.0.5              sass_0.4.10                 plotly_4.12.0              
#>  [17] rmarkdown_2.31              jquerylib_0.1.4             yaml_2.3.12                 httpuv_1.6.17              
#>  [21] otel_0.2.0                  Seurat_5.5.0.9002           sctransform_0.4.3           spam_2.11-3                
#>  [25] sp_2.2-1                    sessioninfo_1.2.3           pkgbuild_1.4.8              spatstat.sparse_3.1-0      
#>  [29] reticulate_1.46.0           cowplot_1.2.0               pbapply_1.7-4               DBI_1.3.0                  
#>  [33] RColorBrewer_1.1-3          abind_1.4-8                 pkgload_1.5.1               Rtsne_0.17                 
#>  [37] GenomicRanges_1.62.1        purrr_1.2.2                 BiocGenerics_0.56.0         IRanges_2.44.0             
#>  [41] S4Vectors_0.49.1-1          ggrepel_0.9.8               irlba_2.3.7                 listenv_0.10.1             
#>  [45] spatstat.utils_3.2-2        testthat_3.3.2              BiocStyle_2.38.0            goftest_1.2-3              
#>  [49] RSpectra_0.16-2             spatstat.random_3.4-5       fitdistrplus_1.2-6          parallelly_1.46.1          
#>  [53] commonmark_2.0.0            codetools_0.2-20            DelayedArray_0.36.1         xml2_1.5.2                 
#>  [57] tidyselect_1.2.1            rclipboard_0.2.1            UCSC.utils_1.6.1            farver_2.1.2               
#>  [61] shinyWidgets_0.9.1          matrixStats_1.5.0           stats4_4.5.3                spatstat.explore_3.8-0     
#>  [65] duckdb_1.4.3                Seqinfo_1.0.0               roxygen2_7.3.3              jsonlite_2.0.0             
#>  [69] ellipsis_0.3.3              progressr_0.19.0            ggridges_0.5.7              survival_3.8-6             
#>  [73] tools_4.5.3                 ica_1.0-3                   Rcpp_1.1.1-1                glue_1.8.0                 
#>  [77] gridExtra_2.3               SparseArray_1.10.10         xfun_0.57                   MatrixGenerics_1.22.0      
#>  [81] usethis_3.2.1               GenomeInfoDb_1.46.2         HDF5Array_1.38.0            withr_3.0.2                
#>  [85] BiocManager_1.30.27         fastmap_1.2.0               basilisk_1.22.0             rhdf5filters_1.22.0        
#>  [89] digest_0.6.39               R6_2.6.1                    mime_0.13                   scattermore_1.2            
#>  [93] tensor_1.5.1                spatstat.data_3.1-9         h5mread_1.2.1               utf8_1.2.6                 
#>  [97] tidyr_1.3.2                 generics_0.1.4              data.table_1.18.2.1         httr_1.4.8                 
#> [101] htmlwidgets_1.6.4           S4Arrays_1.10.1             uwot_0.2.4                  pkgconfig_2.0.3            
#> [105] gtable_0.3.6                rsconnect_1.8.0             blob_1.3.0                  lmtest_0.9-40              
#> [109] S7_0.2.1-1                  SingleCellExperiment_1.32.0 XVector_0.50.0              brio_1.1.5                 
#> [113] htmltools_0.5.9             dotCall64_1.2               SeuratObject_5.4.0          scales_1.4.0               
#> [117] Biobase_2.70.0              png_0.1-9                   spatstat.univar_3.1-7       knitr_1.51                 
#> [121] rstudioapi_0.18.0           reshape2_1.4.5              checkmate_2.3.4             nlme_3.1-168               
#> [125] curl_7.0.0                  anndataR_1.0.2              rhdf5_2.54.1                cachem_1.1.0               
#> [129] zoo_1.8-15                  stringr_1.6.0               KernSmooth_2.23-26          parallel_4.5.3             
#> [133] miniUI_0.1.2                zellkonverter_1.20.1        desc_1.4.3                  pillar_1.11.1              
#> [137] grid_4.5.3                  vctrs_0.7.3                 RANN_2.6.2                  promises_1.5.0             
#> [141] dbplyr_2.5.2                xtable_1.8-8                cluster_2.1.8.2             evaluate_1.0.5             
#> [145] cli_3.6.6                   compiler_4.5.3              rlang_1.2.0                 future.apply_1.20.2        
#> [149] plyr_1.8.9                  fs_2.0.1                    stringi_1.8.7               viridisLite_0.4.3          
#> [153] deldir_2.0-4                lazyeval_0.2.3              devtools_2.5.0              spatstat.geom_3.7-3        
#> [157] Matrix_1.7-4                dir.expiry_1.18.0           RcppHNSW_0.6.0              patchwork_1.3.2            
#> [161] future_1.70.0               Rhdf5lib_1.32.0             ggplot2_4.0.2               shiny_1.13.0               
#> [165] SummarizedExperiment_1.40.0 ROCR_1.0-12                 igraph_2.2.3                memoise_2.0.1              
#> [169] bslib_0.10.0
```
