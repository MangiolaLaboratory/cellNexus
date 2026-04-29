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

``` r

sessionInfo()
#> R version 4.5.3 (2026-03-11)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Red Hat Enterprise Linux 9.3 (Plow)
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
#> [1] cellNexus_0.99.22 BiocStyle_2.38.0  ggplot2_4.0.2     dplyr_1.2.1      
#> 
#> loaded via a namespace (and not attached):
#>   [1] bitops_1.0-9                    fs_2.0.1                        matrixStats_1.5.0               spatstat.sparse_3.1-0          
#>   [5] xopen_1.0.1                     devtools_2.5.0                  httr_1.4.8                      RColorBrewer_1.1-3             
#>   [9] tools_4.5.3                     sctransform_0.4.3               backports_1.5.1                 utf8_1.2.6                     
#>  [13] R6_2.6.1                        HDF5Array_1.38.0                lazyeval_0.2.3                  uwot_0.2.4                     
#>  [17] rhdf5filters_1.22.0             withr_3.0.2                     sp_2.2-1                        prettyunits_1.2.0              
#>  [21] gridExtra_2.3                   progressr_0.19.0                cli_3.6.6                       Biobase_2.70.0                 
#>  [25] spatstat.explore_3.8-0          fastDummies_1.7.5               sass_0.4.10                     Seurat_5.4.0                   
#>  [29] arrow_23.0.1.2                  S7_0.2.1-1                      spatstat.data_3.1-9             ggridges_0.5.7                 
#>  [33] pbapply_1.7-4                   commonmark_2.0.0                R.utils_2.13.0                  stringdist_0.9.17              
#>  [37] parallelly_1.46.1               sessioninfo_1.2.3               styler_1.11.0                   RSQLite_2.4.6                  
#>  [41] rstudioapi_0.18.0               generics_0.1.4                  ica_1.0-3                       spatstat.random_3.4-5          
#>  [45] Matrix_1.7-4                    fansi_1.0.7                     S4Vectors_0.49.1-1              rclipboard_0.2.1               
#>  [49] abind_1.4-8                     R.methodsS3_1.8.2               lifecycle_1.0.5                 yaml_2.3.12                    
#>  [53] SummarizedExperiment_1.40.0     BiocFileCache_3.0.0             biocViews_1.78.2                rhdf5_2.54.1                   
#>  [57] SparseArray_1.10.10             Rtsne_0.17                      grid_4.5.3                      blob_1.3.0                     
#>  [61] promises_1.5.0                  dir.expiry_1.18.0               miniUI_0.1.2                    lattice_0.22-9                 
#>  [65] cowplot_1.2.0                   pillar_1.11.1                   knitr_1.51                      GenomicRanges_1.62.1           
#>  [69] future.apply_1.20.2             codetools_0.2-20                glue_1.8.0                      spatstat.univar_3.1-7          
#>  [73] data.table_1.18.2.1             tidySingleCellExperiment_1.20.1 vctrs_0.7.3                     png_0.1-9                      
#>  [77] spam_2.11-3                     testthat_3.3.2                  rcmdcheck_1.4.0                 gtable_0.3.6                   
#>  [81] assertthat_0.2.1                cachem_1.1.0                    xfun_0.57                       S4Arrays_1.10.1                
#>  [85] mime_0.13                       Seqinfo_1.0.0                   rsconnect_1.8.0                 survival_3.8-6                 
#>  [89] SingleCellExperiment_1.32.0     ellipsis_0.3.3                  fitdistrplus_1.2-6              ROCR_1.0-12                    
#>  [93] nlme_3.1-168                    usethis_3.2.1                   bit64_4.6.0-1                   filelock_1.0.3                 
#>  [97] RcppAnnoy_0.0.23                GenomeInfoDb_1.46.2             rprojroot_2.1.1                 R.cache_0.17.0                 
#> [101] bslib_0.10.0                    irlba_2.3.7                     KernSmooth_2.23-26              otel_0.2.0                     
#> [105] BiocGenerics_0.56.0             DBI_1.3.0                       zellkonverter_1.20.1            duckdb_1.4.3                   
#> [109] processx_3.8.7                  tidyselect_1.2.1                bit_4.6.0                       compiler_4.5.3                 
#> [113] curl_7.0.0                      httr2_1.2.2                     graph_1.88.1                    BiocCheck_1.46.3               
#> [117] h5mread_1.2.1                   xml2_1.5.2                      desc_1.4.3                      DelayedArray_0.36.1            
#> [121] plotly_4.12.0                   bookdown_0.46                   checkmate_2.3.4                 scales_1.4.0                   
#> [125] lmtest_0.9-40                   RBGL_1.86.0                     callr_3.7.6                     rappdirs_0.3.4                 
#> [129] stringr_1.6.0                   anndataR_1.0.2                  digest_0.6.39                   goftest_1.2-3                  
#> [133] spatstat.utils_3.2-2            rmarkdown_2.31                  basilisk_1.22.0                 XVector_0.50.0                 
#> [137] htmltools_0.5.9                 pkgconfig_2.0.3                 MatrixGenerics_1.22.0           dbplyr_2.5.2                   
#> [141] fastmap_1.2.0                   rlang_1.2.0                     htmlwidgets_1.6.4               UCSC.utils_1.6.1               
#> [145] shiny_1.13.0                    farver_2.1.2                    jquerylib_0.1.4                 zoo_1.8-15                     
#> [149] jsonlite_2.0.0                  R.oo_1.27.1                     RCurl_1.98-1.18                 magrittr_2.0.5                 
#> [153] dotCall64_1.2                   patchwork_1.3.2                 Rhdf5lib_1.32.0                 Rcpp_1.1.1-1                   
#> [157] reticulate_1.46.0               stringi_1.8.7                   brio_1.1.5                      MASS_7.3-65                    
#> [161] plyr_1.8.9                      pkgbuild_1.4.8                  parallel_4.5.3                  listenv_0.10.1                 
#> [165] ggrepel_0.9.8                   forcats_1.0.1                   deldir_2.0-4                    splines_4.5.3                  
#> [169] tensor_1.5.1                    ps_1.9.2                        RUnit_0.4.33.1                  igraph_2.2.3                   
#> [173] spatstat.geom_3.7-3             RcppHNSW_0.6.0                  reshape2_1.4.5                  stats4_4.5.3                   
#> [177] pkgload_1.5.1                   XML_3.99-0.23                   evaluate_1.0.5                  ttservice_0.5.3                
#> [181] SeuratObject_5.4.0              BiocManager_1.30.27             httpuv_1.6.17                   RANN_2.6.2                     
#> [185] tidyr_1.3.2                     purrr_1.2.2                     polyclip_1.10-7                 future_1.70.0                  
#> [189] scattermore_1.2                 BiocBaseUtils_1.12.0            xtable_1.8-8                    RSpectra_0.16-2                
#> [193] roxygen2_7.3.3                  later_1.4.8                     viridisLite_0.4.3               tibble_3.3.1                   
#> [197] memoise_2.0.1                   IRanges_2.44.0                  cluster_2.1.8.2                 shinyWidgets_0.9.1             
#> [201] globals_0.19.1
```
