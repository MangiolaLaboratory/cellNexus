# Metadata Explore

## Why this page exists

This page is a standalone metadata guide for `cellNexus` and documents
the key fields used in downstream analysis.

``` r

library(cellNexus)
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"])
metadata
#> # Source:   SQL [?? x 58]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id observation_joinid dataset_id                       sample_id sample_ experiment___ run_from_cell_id sample_heuristic age_days tissue_groups
#>      <dbl> <chr>              <chr>                            <chr>     <chr>   <chr>         <chr>            <chr>               <int> <chr>        
#>  1      17 QRMCN*8*|#         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  2      16 j}0<Y>a#X~         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  3      20 6Eu5c&aEH;         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  4      19 lNmuO5xs~3         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  5      15 TjgA2vJ1;{         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  6      18 h22!#$}SJ*         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  7      14 qxl7HJjL$L         842c6f5d-4a94-4eef-8510-8c792d1… 1119f482… 1119f4… ""            <NA>             182a61cc-b041-4…    14600 breast       
#>  8       3 5jp7Uu{#@#         842c6f5d-4a94-4eef-8510-8c792d1… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast       
#>  9       2 $jvBt8wHSK         842c6f5d-4a94-4eef-8510-8c792d1… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast       
#> 10       5 N>_|{;6_6N         842c6f5d-4a94-4eef-8510-8c792d1… 1f755b9b… 1f755b… ""            <NA>             9ca47fe5-873e-4…    14600 breast       
#> # ℹ more rows
#> # ℹ 48 more variables: nFeature_expressed_in_sample <int>, nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>,
#> #   count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, alive <lgl>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>,
#> #   .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, citation <chr>, collection_id <chr>, dataset_version_id <chr>, …
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
#>  [1] "cell_id"                           "observation_joinid"                "dataset_id"                        "sample_id"                        
#>  [5] "sample_"                           "experiment___"                     "run_from_cell_id"                  "sample_heuristic"                 
#>  [9] "age_days"                          "tissue_groups"                     "nFeature_expressed_in_sample"      "nCount_RNA"                       
#> [13] "empty_droplet"                     "cell_type_unified_ensemble"        "is_immune"                         "subsets_Mito_percent"             
#> [17] "subsets_Ribo_percent"              "high_mitochondrion"                "high_ribosome"                     "scDblFinder.class"                
#> [21] "sample_chunk"                      "cell_chunk"                        "sample_pseudobulk_chunk"           "file_id_cellNexus_single_cell"    
#> [25] "file_id_cellNexus_pseudobulk"      "count_upper_bound"                 "nfeature_expressed_thresh"         "inverse_transform"                
#> [29] "alive"                             "cell_annotation_blueprint_singler" "cell_annotation_monaco_singler"    "cell_annotation_azimuth_l2"       
#> [33] "ethnicity_flagging_score"          "low_confidence_ethnicity"          ".aggregated_cells"                 "imputed_ethnicity"                
#> [37] "atlas_id"                          "citation"                          "collection_id"                     "dataset_version_id"               
#> [41] "default_embedding"                 "published_at"                      "raw_data_location"                 "revised_at"                       
#> [45] "primary_cell_count"                "schema_version"                    "tissue_type"                       "title"                            
#> [49] "tombstone"                         "x_approximate_distribution"        "explorer_url"                      "cell_count"                       
#> [53] "feature_count"                     "filesize"                          "filetype"                          "mean_genes_per_cell"              
#> [57] "suspension_type"                   "url"

# How many datasets per tissue group?
metadata |>
  dplyr::distinct(dataset_id, tissue_groups) |>
  dplyr::count(tissue_groups, sort = TRUE)
#> # Source:     SQL [?? x 2]
#> # Database:   DuckDB 1.4.3 [unknown@Linux 5.14.0-570.112.1.el9_6.x86_64:R 4.5.3/:memory:]
#> # Ordered by: desc(n)
#>    tissue_groups                           n
#>    <chr>                               <dbl>
#>  1 blood                                   9
#>  2 respiratory system                      6
#>  3 bone marrow                             5
#>  4 renal system                            3
#>  5 thymus                                  3
#>  6 breast                                  3
#>  7 cerebral lobes and cortical areas       2
#>  8 nasal, oral, and pharyngeal regions     2
#>  9 female reproductive system              2
#> 10 lymphatic system                        2
#> 11 spleen                                  2
#> 12 integumentary system (skin)             1
#> 13 sensory-related structures              1
#> 14 oesophagus                              1
#> 15 brainstem and cerebellar structures     1
#> 16 small intestine                         1
#> 17 vasculature                             1
#> 18 epithelium and mucosal tissues          1
#> 19 gastrointestinal accessory organs       1
#> 20 stomach                                 1

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
