# Metadata Explore

## Why this page exists

This page is a standalone metadata guide for `cellNexus` and documents
the key fields used in downstream analysis.

``` r

library(cellNexus)
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
metadata
#> # Source:   SQL [?? x 36]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id dataset_id        sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>      <dbl> <chr>             <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>                          <int>      <dbl> <lgl>        
#>  1      15 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1701       8.99 FALSE        
#>  2      16 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2438       9.80 FALSE        
#>  3      17 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          2122       9.46 FALSE        
#>  4      18 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1894      10.3  FALSE        
#>  5      19 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1876       9.15 FALSE        
#>  6      20 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1441      10.3  FALSE        
#>  7      14 842c6f5d-4a94-4e… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast                          1547      10.5  FALSE        
#>  8       2 842c6f5d-4a94-4e… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1342       9.40 FALSE        
#>  9       3 842c6f5d-4a94-4e… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1808       9.80 FALSE        
#> 10       4 842c6f5d-4a94-4e… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast                          1514       9.30 FALSE        
#> # ℹ more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 24 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, scDblFinder.class <chr>, sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>
```

## Data-processing context

`cellNexus` metadata are harmonised to support cross-dataset analysis:

- Common ontology-backed labels are retained where possible.
- Additional curated columns support quality control and robust
  grouping.
- Expression retrieval APIs use metadata filters to provide
  analysis-ready objects.

## Metadata dictionary

| Column | Description |
|----|----|
| `cell_id` | Cell identifier. |
| `observation_joinid` | Cell ID join key linking metadata. |
| `dataset_id` | Primary dataset identifier in the atlas. |
| `sample_id` | Harmonised sample identifier. |
| `sample_` | Internal sample subdivision helper. |
| `experiment___` | Upstream experiment grouping variable. |
| `sample_heuristic` | Internal sample subdivision helper. |
| `age_days` | Donor age in days. |
| `tissue_groups` | Coarse tissue grouping for analysis. |
| `nFeature_expressed_in_sample` | Number of expressed features per cell. |
| `nCount_RNA` | Total RNA counts per cell (sample-aware). |
| `empty_droplet` | Quality-control flag for empty droplets. |
| `cell_type_unified_ensemble` | Consensus immune identity from Azimuth and `SingleR` (Blueprint, Monaco). |
| `is_immune` | Curated flag for immune-cell context. |
| `subsets_Mito_percent` | Percent of each cell’s total counts coming from mitochondrial genes in a sample. |
| `subsets_Ribo_percent` | Percent of each cell’s total counts coming from ribosomal genes in a sample. |
| `high_mitochondrion` | TRUE if the cell’s mitochondrial percent exceeds the QC cutoff. |
| `high_ribosome` | TRUE if the cell’s ribosomal percent exceeds the QC cutoff. |
| `scDblFinder.class` | Quality-control flag for doublet classification from `scDblFinder`. |
| `sample_chunk` | Internal sample subdivision chunks. |
| `cell_chunk` | Internal cell subdivision chunks. |
| `sample_pseudobulk_chunk` | Internal pseudobulk subdivision chunks. |
| `file_id_cellNexus_single_cell` | Internal file id for single-cell layers. |
| `file_id_cellNexus_pseudobulk` | Internal file id for pseudobulk layers. |
| `count_upper_bound` | Count capping threshold used in transformation. |
| `nfeature_expressed_thresh` | Threshold of the number of expressed features per cell. |
| `inverse_transform` | Transformation method used in pre-processing pipeline. |
| `alive` | Quality-control flag for viable cells (e.g. mitochondrial signal). |
| `cell_annotation_blueprint_singler` | `SingleR` annotation (Blueprint). |
| `cell_annotation_monaco_singler` | `SingleR` annotation (Monaco). |
| `cell_annotation_azimuth_l2` | Azimuth cell annotation. |
| `ethnicity_flagging_score` | Supporting score for ethnicity imputation. |
| `low_confidence_ethnicity` | Supporting flag for low-confidence ethnicity calls. |
| `.aggregated_cells` | Post-QC cells combined into each pseudobulk sample. |
| `imputed_ethnicity` | Imputed ethnicity label. |
| `atlas_id` | cellNexus atlas release identifier (internal use). |

## Practical exploration

``` r

# Which columns are available?
colnames(metadata)
#>  [1] "cell_id"                           "dataset_id"                        "sample_id"                         "sample_"                          
#>  [5] "experiment___"                     "run_from_cell_id"                  "sample_heuristic"                  "age_days"                         
#>  [9] "tissue_groups"                     "nFeature_expressed_in_sample"      "nCount_RNA"                        "empty_droplet"                    
#> [13] "cell_type_unified_ensemble"        "is_immune"                         "subsets_Mito_percent"              "subsets_Ribo_percent"             
#> [17] "high_mitochondrion"                "high_ribosome"                     "scDblFinder.class"                 "sample_chunk"                     
#> [21] "cell_chunk"                        "sample_pseudobulk_chunk"           "file_id_cellNexus_single_cell"     "file_id_cellNexus_pseudobulk"     
#> [25] "count_upper_bound"                 "nfeature_expressed_thresh"         "inverse_transform"                 "alive"                            
#> [29] "cell_annotation_blueprint_singler" "cell_annotation_monaco_singler"    "cell_annotation_azimuth_l2"        "ethnicity_flagging_score"         
#> [33] "low_confidence_ethnicity"          ".aggregated_cells"                 "imputed_ethnicity"                 "atlas_id"

# How many datasets per tissue group?
metadata |>
  dplyr::distinct(dataset_id, tissue_groups) |>
  dplyr::count(tissue_groups, sort = TRUE)
#> # Source:     SQL [?? x 2]
#> # Database:   DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#> # Ordered by: desc(n)
#>    tissue_groups                           n
#>    <chr>                               <dbl>
#>  1 blood                                  10
#>  2 respiratory system                      7
#>  3 bone marrow                             6
#>  4 renal system                            4
#>  5 thymus                                  3
#>  6 breast                                  3
#>  7 cerebral lobes and cortical areas       2
#>  8 female reproductive system              2
#>  9 spleen                                  2
#> 10 nasal, oral, and pharyngeal regions     2
#> 11 oesophagus                              1
#> 12 lymphatic system                        1
#> 13 epithelium and mucosal tissues          1
#> 14 stomach                                 1
#> 15 vasculature                             1
#> 16 small intestine                         1
#> 17 endocrine system                        1
#> 18 brainstem and cerebellar structures     1
#> 19 sensory-related structures              1

# Typical quality-control filtering
metadata_qc <- metadata |>
  dplyr::filter(
    empty_droplet == FALSE,
    alive == TRUE,
    scDblFinder.class != "doublet"
  )
```

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
