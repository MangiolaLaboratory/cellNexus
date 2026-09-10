# Metadata Explore

## Why this page exists

This page is a standalone metadata guide for `cellNexus` and documents
the key fields used in downstream analysis.

``` r

library(cellNexus)
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
metadata
#> # Source:   SQL [?? x 31]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id dataset_id                      sample_id feature_count age_days nFeature_expressed_i…¹ nCount_RNA empty_droplet
#>      <dbl> <chr>                           <chr>             <int>    <int>                  <int>      <dbl> <lgl>        
#>  1      14 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   1547      10.5  FALSE        
#>  2      15 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   1701       8.99 FALSE        
#>  3      16 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   2438       9.80 FALSE        
#>  4      17 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   2122       9.46 FALSE        
#>  5      18 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   1894      10.3  FALSE        
#>  6      19 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   1876       9.15 FALSE        
#>  7      20 842c6f5d-4a94-4eef-8510-8c792d… 1119f482…         33145    14600                   1441      10.3  FALSE        
#>  8       2 842c6f5d-4a94-4eef-8510-8c792d… 1f755b9b…         33145    14600                   1342       9.40 FALSE        
#>  9       5 842c6f5d-4a94-4eef-8510-8c792d… 1f755b9b…         33145    14600                   1820       9.25 FALSE        
#> 10       4 842c6f5d-4a94-4eef-8510-8c792d… 1f755b9b…         33145    14600                   1514       9.30 FALSE        
#> # ℹ more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 23 more variables: cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
#> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_threshold <dbl>, inversed_inferred_distribution <chr>, inferred_distribution <chr>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, …
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
| `donor_id` | Donor identifier. |
| `feature_count` | Number of features/genes for a dataset. |
| `age_days` | Donor age in days. |
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
| `file_id_cellNexus_single_cell` | Internal file id for single-cell layers. |
| `file_id_cellNexus_pseudobulk` | Internal file id for pseudobulk layers. |
| `count_upper_bound` | Count capping threshold used in transformation. |
| `nfeature_expressed_thresh` | Threshold of the number of expressed features per cell. |
| `inferred_distribution` | Inferred sample distribution. |
| `inversed_inferred_distribution` | Transformation method used in pre-processing pipeline for each sample. |
| `alive` | Quality-control flag for viable cells (e.g. mitochondrial signal). |
| `cell_annotation_blueprint_singler` | `SingleR` annotation (Blueprint). |
| `cell_annotation_monaco_singler` | `SingleR` annotation (Monaco). |
| `cell_annotation_azimuth_l2` | Azimuth cell annotation. |
| `ethnicity_flagging_score` | Supporting score for ethnicity imputation. |
| `low_confidence_ethnicity` | Supporting flag for low-confidence ethnicity calls. |
| `.aggregated_cells` | Post-QC cells combined into each pseudobulk sample. |
| `imputed_ethnicity` | Imputed ethnicity label. |
| `max_lt_10,min_lt_0,rounding_error` | Sample post-transformation count sanity-check flags. Identify samples with an unusually low maximum count (max_lt_10), negative values (min_lt_0), or non-integer count values beyond numerical tolerance (rounding_error). |
| `atlas_id` | cellNexus atlas release identifier (internal use). |

## Practical exploration

``` r

# Which columns are available?
colnames(metadata)
#>  [1] "cell_id"                           "dataset_id"                        "sample_id"                        
#>  [4] "feature_count"                     "age_days"                          "nFeature_expressed_in_sample"     
#>  [7] "nCount_RNA"                        "empty_droplet"                     "cell_type_unified_ensemble"       
#> [10] "is_immune"                         "subsets_Mito_percent"              "subsets_Ribo_percent"             
#> [13] "high_mitochondrion"                "high_ribosome"                     "alive"                            
#> [16] "scDblFinder.class"                 "file_id_cellNexus_single_cell"     "file_id_cellNexus_pseudobulk"     
#> [19] "count_upper_bound"                 "nfeature_expressed_threshold"      "inversed_inferred_distribution"   
#> [22] "inferred_distribution"             "cell_annotation_blueprint_singler" "cell_annotation_monaco_singler"   
#> [25] "cell_annotation_azimuth_l2"        "ethnicity_flagging_score"          "low_confidence_ethnicity"         
#> [28] ".aggregated_cells"                 "imputed_ethnicity"                 "max_lt_10,min_lt_0,rounding_error"
#> [31] "atlas_id"

# How many datasets per harmonised cell type?
metadata |>
  dplyr::distinct(dataset_id, cell_type_unified_ensemble) |>
  dplyr::count(cell_type_unified_ensemble, sort = TRUE)
#> # Source:     SQL [?? x 2]
#> # Database:   DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#> # Ordered by: desc(n)
#>    cell_type_unified_ensemble     n
#>    <chr>                      <dbl>
#>  1 nk                            22
#>  2 cd14 mono                     22
#>  3 monocytic                     17
#>  4 progenitor                    12
#>  5 cytotoxic                      9
#>  6 t cd4                          9
#>  7 Unknown                        9
#>  8 cd16 mono                      8
#>  9 other                          8
#> 10 granulocyte                    7
#> # ℹ more rows

# Typical quality-control filtering
metadata_qc <- metadata |>
  keep_quality_cells()
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
#> [1] BiocStyle_2.38.0  RcppSpdlog_0.0.28 ggplot2_4.0.2     dplyr_1.2.1       cellNexus_0.99.34
#> 
#> loaded via a namespace (and not attached):
#>   [1] fs_2.0.1                        matrixStats_1.5.0               spatstat.sparse_3.1-0          
#>   [4] fontawesome_0.5.3               httr_1.4.8                      RColorBrewer_1.1-3             
#>   [7] tools_4.5.3                     sctransform_0.4.3               backports_1.5.1                
#>  [10] utf8_1.2.6                      R6_2.6.1                        DT_0.34.0                      
#>  [13] HDF5Array_1.38.0                lazyeval_0.2.3                  uwot_0.2.4                     
#>  [16] rhdf5filters_1.22.0             withr_3.0.2                     sp_2.2-1                       
#>  [19] gridExtra_2.3                   nanoarrow_0.8.0                 progressr_0.19.0               
#>  [22] cli_3.6.6                       Biobase_2.70.0                  spatstat.explore_3.8-0         
#>  [25] fastDummies_1.7.5               sass_0.4.10                     Seurat_5.5.0.9002              
#>  [28] arrow_23.0.1.2                  S7_0.2.1-1                      spatstat.data_3.1-9            
#>  [31] ggridges_0.5.7                  pbapply_1.7-4                   commonmark_2.0.0               
#>  [34] parallelly_1.46.1               rstudioapi_0.18.0               generics_0.1.4                 
#>  [37] ica_1.0-3                       spatstat.random_3.4-5           Matrix_1.7-4                   
#>  [40] fansi_1.0.7                     S4Vectors_0.49.1-1              rclipboard_0.2.1               
#>  [43] abind_1.4-8                     lifecycle_1.0.5                 yaml_2.3.12                    
#>  [46] SummarizedExperiment_1.40.0     rhdf5_2.54.1                    SparseArray_1.10.10            
#>  [49] Rtsne_0.17                      grid_4.5.3                      blob_1.3.0                     
#>  [52] promises_1.5.0                  dir.expiry_1.18.0               miniUI_0.1.2                   
#>  [55] lattice_0.22-9                  cowplot_1.2.0                   pillar_1.11.1                  
#>  [58] knitr_1.51                      GenomicRanges_1.62.1            future.apply_1.20.2            
#>  [61] codetools_0.2-20                glue_1.8.0                      spatstat.univar_3.1-7          
#>  [64] tiledb_0.33.1                   data.table_1.18.2.1             tidySingleCellExperiment_1.20.1
#>  [67] vctrs_0.7.3                     png_0.1-9                       spam_2.11-3                    
#>  [70] gtable_0.3.6                    aws.s3_0.3.22                   assertthat_0.2.1               
#>  [73] cachem_1.1.0                    xfun_0.57                       S4Arrays_1.10.1                
#>  [76] mime_0.13                       Seqinfo_1.0.0                   survival_3.8-6                 
#>  [79] SingleCellExperiment_1.32.0     ellipsis_0.3.3                  fitdistrplus_1.2-6             
#>  [82] ROCR_1.0-12                     nlme_3.1-168                    tiledbsoma_2.1.2               
#>  [85] RcppCCTZ_0.2.14                 bit64_4.6.0-1                   filelock_1.0.3                 
#>  [88] RcppAnnoy_0.0.23                GenomeInfoDb_1.46.2             rprojroot_2.1.1                
#>  [91] bslib_0.10.0                    irlba_2.3.7                     KernSmooth_2.23-26             
#>  [94] otel_0.2.0                      BiocGenerics_0.56.0             DBI_1.3.0                      
#>  [97] zellkonverter_1.20.1            duckdb_1.4.3                    tidyselect_1.2.1               
#> [100] processx_3.8.7                  cellxgene.census_1.16.1         bit_4.6.0                      
#> [103] compiler_4.5.3                  curl_7.0.0                      rjsoncons_1.3.2                
#> [106] h5mread_1.2.1                   xml2_1.5.2                      nanotime_0.3.13                
#> [109] DelayedArray_0.36.1             plotly_4.12.0                   bookdown_0.46                  
#> [112] checkmate_2.3.4                 scales_1.4.0                    lmtest_0.9-40                  
#> [115] callr_3.7.6                     spdl_0.0.5                      stringr_1.6.0                  
#> [118] anndataR_1.3.1                  digest_0.6.39                   goftest_1.2-3                  
#> [121] spatstat.utils_3.2-2            rmarkdown_2.31                  basilisk_1.22.0                
#> [124] XVector_0.50.0                  htmltools_0.5.9                 pkgconfig_2.0.3                
#> [127] base64enc_0.1-6                 MatrixGenerics_1.22.0           dbplyr_2.5.2                   
#> [130] fastmap_1.2.0                   rlang_1.2.0                     htmlwidgets_1.6.4              
#> [133] UCSC.utils_1.6.1                shiny_1.13.0                    farver_2.1.2                   
#> [136] jquerylib_0.1.4                 zoo_1.8-15                      jsonlite_2.0.0                 
#> [139] magrittr_2.0.5                  dotCall64_1.2                   patchwork_1.3.2                
#> [142] Rhdf5lib_1.32.0                 Rcpp_1.1.1-1                    reticulate_1.46.0              
#> [145] stringi_1.8.7                   brio_1.1.5                      MASS_7.3-65                    
#> [148] plyr_1.8.9                      parallel_4.5.3                  listenv_0.10.1                 
#> [151] ggrepel_0.9.8                   forcats_1.0.1                   deldir_2.0-4                   
#> [154] splines_4.5.3                   tensor_1.5.1                    ps_1.9.2                       
#> [157] cellxgenedp_1.14.0              igraph_2.2.3                    spatstat.geom_3.7-3            
#> [160] RcppHNSW_0.6.0                  reshape2_1.4.5                  stats4_4.5.3                   
#> [163] evaluate_1.0.5                  ttservice_0.5.3                 SeuratObject_5.4.0             
#> [166] BiocManager_1.30.27             httpuv_1.6.17                   RANN_2.6.2                     
#> [169] tidyr_1.3.2                     purrr_1.2.2                     polyclip_1.10-7                
#> [172] future_1.70.0                   scattermore_1.2                 xtable_1.8-8                   
#> [175] RSpectra_0.16-2                 later_1.4.8                     viridisLite_0.4.3              
#> [178] tibble_3.3.1                    memoise_2.0.1                   aws.signature_0.6.0            
#> [181] IRanges_2.44.0                  cluster_2.1.8.2                 shinyWidgets_0.9.1             
#> [184] globals_0.19.1
```
