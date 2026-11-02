# Gene Expression Explore

## Overview

The unified pseudobulk AnnData object was pre-generated outside of this
vignette applying quality control and retaining at least 15,000
intersecting genes across samples and hosted on Zenodo to avoid lengthy
recompilation. Download the latest version:
[pseudobulk_se.h5ad](https://zenodo.org/records/22668580/files/pseudobulk_se.h5ad?download=1).
For all versions:
[10.5281/zenodo.22668580](https://zenodo.org/records/22668580).

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
    imputed_ethnicity == "African American"
  )
query_metadata  
#> # Source:   SQL [?? x 31]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id dataset_id sample_id feature_count age_days nFeature_expressed_i…¹ nCount_RNA empty_droplet cell_type_unified_en…²
#>      <dbl> <chr>      <chr>             <int>    <int>                  <int>      <dbl> <lgl>         <chr>                 
#>  1      14 842c6f5d-… 1119f482…         33145    14600                   1547      10.5  FALSE         cd16 mono             
#>  2      16 842c6f5d-… 1119f482…         33145    14600                   2438       9.80 FALSE         cd16 mono             
#>  3      19 842c6f5d-… 1119f482…         33145    14600                   1876       9.15 FALSE         cd16 mono             
#>  4       2 842c6f5d-… 1f755b9b…         33145    14600                   1342       9.40 FALSE         cd16 mono             
#>  5      27 842c6f5d-… 22a18c38…         33145    14600                   1743      12.5  FALSE         cd16 mono             
#>  6      24 842c6f5d-… b0d0c16e…         33145    14600                   1800    7649.   FALSE         cd16 mono             
#>  7      22 842c6f5d-… b0d0c16e…         33145    14600                   1759    7819.   FALSE         cd16 mono             
#>  8      21 842c6f5d-… b0d0c16e…         33145    14600                   1552    7367.   FALSE         cd16 mono             
#>  9      11 842c6f5d-… bd5f6876…         33145    14600                    399      11.2  FALSE         cd16 mono             
#> 10      25 842c6f5d-… 04e410cb…         33145    14600                   1324    6640.   FALSE         cd16 mono             
#> 11      24 842c6f5d-… 04e410cb…         33145    14600                   1254    7389.   FALSE         cd16 mono             
#> 12       6 842c6f5d-… 49ef9551…         33145    14600                   1771      11.6  FALSE         cd16 mono             
#> 13       9 842c6f5d-… 49ef9551…         33145    14600                   1767      12.3  FALSE         cd16 mono             
#> # ℹ abbreviated names: ¹​nFeature_expressed_in_sample, ²​cell_type_unified_ensemble
#> # ℹ 22 more variables: is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_threshold <dbl>,
#> #   inversed_inferred_distribution <chr>, inferred_distribution <chr>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, …
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
sce_counts
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): counts
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(31): dataset_id sample_id ... atlas_id original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
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
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(31): dataset_id sample_id ... atlas_id original_cell_
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
#> ℹ Downloading 1 file, totalling 0.25 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/hca_2024/0.5.0/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad to /vast/scratch/users/shen.m/r_cache/R/cellNexus/hca_2024/0.5.0/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad
#> ℹ Reading files.
#> ℹ Compiling Experiment.
pb_counts
#> class: SingleCellExperiment 
#> dim: 33145 7 
#> metadata(0):
#> assays(1): counts
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(7): 1119f4825edbcfb74341b89d9dec4ac8___cd16 mono 1f755b9b59313f6c5e80caa696799ac2___cd16 mono ...
#>   04e410cbab17c7d05877161100a5d1e1___cd16 mono 49ef9551c2ddf79b01c74f863ea6f556___cd16 mono
#> colData names(26): sample_id cell_type_unified_ensemble ... atlas_id sample_identifier
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
#> ℹ Compiling Experiment.
sce_gene
#> class: SingleCellExperiment 
#> dim: 1 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(1): ENSG00000134644
#> rowData names(0):
#> colnames(13): 14_1 16_1 ... 6_2 9_2
#> colData names(31): dataset_id sample_id ... atlas_id original_cell_
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
#> ℹ Compiling Experiment.
seurat_obj
#> An object of class Seurat 
#> 33145 features across 13 samples within 1 assay 
#> Active assay: counts (33145 features, 0 variable features)
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
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] cellNexus_0.99.36           RcppSpdlog_0.0.28           tibble_3.3.1                SummarizedExperiment_1.40.0
#>  [5] Biobase_2.70.0              GenomicRanges_1.62.1        Seqinfo_1.0.0               IRanges_2.44.0             
#>  [9] S4Vectors_0.49.1-1          BiocGenerics_0.56.0         generics_0.1.4              MatrixGenerics_1.22.0      
#> [13] matrixStats_1.5.0           shiny_1.13.0                anndataR_1.3.1              dplyr_1.2.1                
#> [17] testthat_3.3.2             
#> 
#> loaded via a namespace (and not attached):
#>   [1] fs_2.0.1                    spatstat.sparse_3.1-0       xopen_1.0.1                 fontawesome_0.5.3          
#>   [5] devtools_2.5.0              httr_1.4.8                  RColorBrewer_1.1-3          tools_4.5.3                
#>   [9] sctransform_0.4.3           backports_1.5.1             utf8_1.2.6                  R6_2.6.1                   
#>  [13] DT_0.34.0                   HDF5Array_1.38.0            lazyeval_0.2.3              uwot_0.2.4                 
#>  [17] rhdf5filters_1.22.0         withr_3.0.2                 sp_2.2-1                    prettyunits_1.2.0          
#>  [21] gridExtra_2.3               nanoarrow_0.8.0             progressr_0.19.0            cli_3.6.6                  
#>  [25] spatstat.explore_3.8-0      fastDummies_1.7.5           sass_0.4.10                 Seurat_5.5.0.9002          
#>  [29] arrow_23.0.1.2              S7_0.2.1-1                  spatstat.data_3.1-9         ggridges_0.5.7             
#>  [33] pbapply_1.7-4               commonmark_2.0.0            parallelly_1.46.1           sessioninfo_1.2.3          
#>  [37] rstudioapi_0.18.0           ica_1.0-3                   spatstat.random_3.4-5       Matrix_1.7-4               
#>  [41] waldo_0.6.2                 rclipboard_0.2.1            abind_1.4-8                 lifecycle_1.0.5            
#>  [45] yaml_2.3.12                 rhdf5_2.54.1                SparseArray_1.10.10         Rtsne_0.17                 
#>  [49] grid_4.5.3                  blob_1.3.0                  promises_1.5.0              dir.expiry_1.18.0          
#>  [53] miniUI_0.1.2                lattice_0.22-9              cowplot_1.2.0               pillar_1.11.1              
#>  [57] knitr_1.51                  future.apply_1.20.2         codetools_0.2-20            glue_1.8.0                 
#>  [61] ggvenn_0.1.19               spatstat.univar_3.1-7       tiledb_0.33.1               data.table_1.18.2.1        
#>  [65] vctrs_0.7.3                 png_0.1-9                   spam_2.11-3                 rcmdcheck_1.4.0            
#>  [69] gtable_0.3.6                aws.s3_0.3.22               assertthat_0.2.1            cachem_1.1.0               
#>  [73] xfun_0.57                   S4Arrays_1.10.1             mime_0.13                   rsconnect_1.10.1           
#>  [77] survival_3.8-6              SingleCellExperiment_1.32.0 ellipsis_0.3.3              fitdistrplus_1.2-6         
#>  [81] ROCR_1.0-12                 nlme_3.1-168                tiledbsoma_2.1.2            RcppCCTZ_0.2.14            
#>  [85] usethis_3.2.1               bit64_4.6.0-1               filelock_1.0.3              RcppAnnoy_0.0.23           
#>  [89] GenomeInfoDb_1.46.2         rprojroot_2.1.1             bslib_0.10.0                irlba_2.3.7                
#>  [93] KernSmooth_2.23-26          otel_0.2.0                  DBI_1.3.0                   zellkonverter_1.20.1       
#>  [97] duckdb_1.4.3                processx_3.8.7              tidyselect_1.2.1            cellxgene.census_1.16.1    
#> [101] bit_4.6.0                   compiler_4.5.3              curl_7.0.0                  rjsoncons_1.3.2            
#> [105] h5mread_1.2.1               xml2_1.5.2                  desc_1.4.3                  nanotime_0.3.13            
#> [109] DelayedArray_0.36.1         plotly_4.12.0               checkmate_2.3.4             scales_1.4.0               
#> [113] lmtest_0.9-40               callr_3.7.6                 spdl_0.0.5                  stringr_1.6.0              
#> [117] digest_0.6.39               goftest_1.2-3               spatstat.utils_3.2-2        rmarkdown_2.31             
#> [121] basilisk_1.22.0             XVector_0.50.0              htmltools_0.5.9             pkgconfig_2.0.3            
#> [125] base64enc_0.1-6             dbplyr_2.5.2                fastmap_1.2.0               rlang_1.2.0                
#> [129] htmlwidgets_1.6.4           UCSC.utils_1.6.1            farver_2.1.2                jquerylib_0.1.4            
#> [133] zoo_1.8-15                  jsonlite_2.0.0              magrittr_2.0.5              dotCall64_1.2              
#> [137] patchwork_1.3.2             Rhdf5lib_1.32.0             Rcpp_1.1.1-1                reticulate_1.46.0          
#> [141] stringi_1.8.7               brio_1.1.5                  MASS_7.3-65                 plyr_1.8.9                 
#> [145] pkgbuild_1.4.8              parallel_4.5.3              listenv_0.10.1              ggrepel_0.9.8              
#> [149] deldir_2.0-4                splines_4.5.3               tensor_1.5.1                ps_1.9.2                   
#> [153] igraph_2.2.3                cellxgenedp_1.14.0          spatstat.geom_3.7-3         RcppHNSW_0.6.0             
#> [157] reshape2_1.4.5              pkgload_1.5.1               evaluate_1.0.5              SeuratObject_5.4.0         
#> [161] BiocManager_1.30.27         httpuv_1.6.17               RANN_2.6.2                  tidyr_1.3.2                
#> [165] purrr_1.2.2                 polyclip_1.10-7             future_1.70.0               scattermore_1.2            
#> [169] ggplot2_4.0.2               xtable_1.8-8                RSpectra_0.16-2             roxygen2_7.3.3             
#> [173] later_1.4.8                 viridisLite_0.4.3           memoise_2.0.1               aws.signature_0.6.0        
#> [177] cluster_2.1.8.2             shinyWidgets_0.9.1          globals_0.19.1              BiocStyle_2.38.0
```
