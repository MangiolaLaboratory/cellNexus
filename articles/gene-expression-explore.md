# Gene Expression Explore

## Overview

The unified pseudobulk AnnData object was pre-generated outside of this
vignette applying quality control and retaining at least 15,000
intersecting genes across samples and hosted on Zenodo to avoid lengthy
recompilation. Download the latest version:
[pseudobulk_se.h5ad](https://zenodo.org/records/21388944/files/pseudobulk_se.h5ad?download=1).
For all versions:
[10.5281/zenodo.21388944](https://zenodo.org/records/21388944).

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r

library(cellNexus)
#> Registered S3 method overwritten by 'zellkonverter':
#>   method                                             from      
#>   py_to_r.pandas.core.arrays.categorical.Categorical reticulate
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
#> # Source:   SQL [?? x 76]
#> # Database: DuckDB v1.2.2 [shen.m@Darwin 23.6.0:R 4.5.0/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>        
#>  1      16 j}0<Y>a#X~         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  2      19 lNmuO5xs~3         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  3      14 qxl7HJjL$L         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  4       2 $jvBt8wHSK         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#>  5      21 Mq^|(c<-#3         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""           
#>  6      24 I`4{4__f#J         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""           
#>  7      22 %vkLP;!cqY         842c6f5d-4a94-4ee… b0d0c16e… b0d0c1… ""           
#>  8      11 gncTL3)pV~         842c6f5d-4a94-4ee… bd5f6876… bd5f68… ""           
#>  9      25 rfOnkhfWl8         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""           
#> 10      24 =tj7A<!2TZ         842c6f5d-4a94-4ee… 04e410cb… 04e410… ""           
#> 11      13 Py{Fqs?~!!         842c6f5d-4a94-4ee… 30ea4b4f… 30ea4b… ""           
#> 12       9 s$u5u14ye$         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""           
#> 13       6 ?y4kdGGQ!^         842c6f5d-4a94-4ee… 49ef9551… 49ef95… ""           
#> # ℹ 70 more variables: run_from_cell_id <chr>, sample_heuristic <chr>,
#> #   age_days <int>, tissue_groups <chr>, nFeature_expressed_in_sample <int>,
#> #   nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>,
#> #   is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, …
```

## Retrieve expression by representation

### Single-cell counts

``` r

sce_counts <- query_metadata |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> For native R and reading and writing of H5AD files, an R <AnnData> object, and conversion to <SingleCellExperiment> or <Seurat> objects, check out the anndataR package:
#> ℹ Install it from Bioconductor with `BiocManager::install("anndataR")`
#> ℹ See more at <https://bioconductor.org/packages/anndataR/>
#> ℹ Compiling Experiment.
#> 
#> This message is displayed once per session.
sce_counts
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): counts
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475
#>   ENSG00000268674
#> rowData names(0):
#> colnames(13): 16_1 19_1 ... 9_2 6_2
#> colData names(76): observation_joinid dataset_id ...
#>   tissue_ontology_term_id original_cell_
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
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/cpm/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad to /Users/shen.m/Library/Caches/org.R-project.R/R/cellNexus/cellxgene_2024/0.2.1//cpm/001f82656d61ccb98f0ae26a2eb9e5ba___1.h5ad
#> ℹ Reading files.
#> ℹ Compiling Experiment.
sce_cpm
#> class: SingleCellExperiment 
#> dim: 33145 13 
#> metadata(0):
#> assays(1): cpm
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475
#>   ENSG00000268674
#> rowData names(0):
#> colnames(13): 16_1 19_1 ... 9_2 6_2
#> colData names(76): observation_joinid dataset_id ...
#>   tissue_ontology_term_id original_cell_
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
#> ℹ Downloading 1 file, totalling 0.26 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-anndata/cellxgene_2024/0.2.1/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad to /Users/shen.m/Library/Caches/org.R-project.R/R/cellNexus/cellxgene_2024/0.2.1/pseudobulk/counts/91acbf94110b95b1e994fdb1e1322fd1___1.h5ad
#> ℹ Reading files.
#> ℹ Compiling Experiment.
pb_counts
#> class: SingleCellExperiment 
#> dim: 33145 7 
#> metadata(0):
#> assays(1): counts
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475
#>   ENSG00000268674
#> rowData names(0):
#> colnames(7): 1119f4825edbcfb74341b89d9dec4ac8___cd16 mono
#>   1f755b9b59313f6c5e80caa696799ac2___cd16 mono ...
#>   30ea4b4f8922b4a6b35bf1a12be2d5e9___cd16 mono
#>   49ef9551c2ddf79b01c74f863ea6f556___cd16 mono
#> colData names(59): dataset_id sample_id ... tissue_ontology_term_id
#>   sample_identifier
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
#> colnames(13): 16_1 19_1 ... 9_2 6_2
#> colData names(76): observation_joinid dataset_id ...
#>   tissue_ontology_term_id original_cell_
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
#> R version 4.5.0 (2025-04-11)
#> Platform: aarch64-apple-darwin20
#> Running under: macOS Sonoma 14.8.7
#> 
#> Matrix products: default
#> BLAS:   /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib 
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> time zone: Australia/Melbourne
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] dplyr_1.2.1       cellNexus_0.99.23
#> 
#> loaded via a namespace (and not attached):
#>   [1] RColorBrewer_1.1-3          jsonlite_2.0.0             
#>   [3] magrittr_2.0.5              spatstat.utils_3.2-2       
#>   [5] farver_2.1.2                vctrs_0.7.3                
#>   [7] ROCR_1.0-12                 spatstat.explore_3.8-0     
#>   [9] htmltools_0.5.9             S4Arrays_1.10.1            
#>  [11] curl_7.1.0                  Rhdf5lib_1.32.0            
#>  [13] rhdf5_2.54.1                SparseArray_1.10.10        
#>  [15] sass_0.4.10                 sctransform_0.4.3          
#>  [17] parallelly_1.47.0           bslib_0.10.0               
#>  [19] KernSmooth_2.23-26          basilisk_1.20.0            
#>  [21] htmlwidgets_1.6.4           ica_1.0-3                  
#>  [23] plyr_1.8.9                  cachem_1.1.0               
#>  [25] plotly_4.12.0               zoo_1.8-15                 
#>  [27] igraph_2.3.0                mime_0.13                  
#>  [29] lifecycle_1.0.5             pkgconfig_2.0.3            
#>  [31] Matrix_1.7-3                R6_2.6.1                   
#>  [33] fastmap_1.2.0               anndataR_1.0.1             
#>  [35] MatrixGenerics_1.22.0       fitdistrplus_1.2-6         
#>  [37] future_1.70.0               shiny_1.13.0               
#>  [39] digest_0.6.39               patchwork_1.3.2            
#>  [41] S4Vectors_0.48.1            Seurat_5.5.0.9003          
#>  [43] tensor_1.5.1                RSpectra_0.16-2            
#>  [45] irlba_2.3.7                 GenomicRanges_1.62.1       
#>  [47] filelock_1.0.3              progressr_0.19.0           
#>  [49] spatstat.sparse_3.1-0       httr_1.4.8                 
#>  [51] polyclip_1.10-7             abind_1.4-8                
#>  [53] compiler_4.5.0              withr_3.0.2                
#>  [55] backports_1.5.1             S7_0.2.2                   
#>  [57] DBI_1.3.0                   fastDummies_1.7.6          
#>  [59] HDF5Array_1.38.0            duckdb_1.2.2               
#>  [61] MASS_7.3-65                 DelayedArray_0.36.1        
#>  [63] tools_4.5.0                 lmtest_0.9-40              
#>  [65] otel_0.2.0                  httpuv_1.6.17              
#>  [67] future.apply_1.20.2         goftest_1.2-3              
#>  [69] glue_1.8.1                  h5mread_1.2.1              
#>  [71] rhdf5filters_1.22.0         nlme_3.1-168               
#>  [73] promises_1.5.0              grid_4.5.0                 
#>  [75] checkmate_2.3.2             Rtsne_0.17                 
#>  [77] cluster_2.1.8.1             reshape2_1.4.5             
#>  [79] generics_0.1.4              gtable_0.3.6               
#>  [81] spatstat.data_3.1-9         tidyr_1.3.2                
#>  [83] data.table_1.18.2.1         utf8_1.2.6                 
#>  [85] sp_2.2-1                    XVector_0.50.0             
#>  [87] BiocGenerics_0.56.0         spatstat.geom_3.7-3        
#>  [89] RcppAnnoy_0.0.23            ggrepel_0.9.8              
#>  [91] RANN_2.6.2                  pillar_1.11.1              
#>  [93] stringr_1.6.0               spam_2.11-3                
#>  [95] RcppHNSW_0.6.0              later_1.4.8                
#>  [97] splines_4.5.0               lattice_0.22-6             
#>  [99] survival_3.8-3              deldir_2.0-4               
#> [101] tidyselect_1.2.1            SingleCellExperiment_1.32.0
#> [103] miniUI_0.1.2                pbapply_1.7-4              
#> [105] knitr_1.51                  gridExtra_2.3              
#> [107] IRanges_2.44.0              Seqinfo_1.0.0              
#> [109] SummarizedExperiment_1.40.0 scattermore_1.2            
#> [111] stats4_4.5.0                xfun_0.57                  
#> [113] Biobase_2.70.0              matrixStats_1.5.0          
#> [115] stringi_1.8.7               lazyeval_0.2.3             
#> [117] shinyWidgets_0.9.0          evaluate_1.0.5             
#> [119] codetools_0.2-20            tibble_3.3.1               
#> [121] cli_3.6.6                   uwot_0.2.4                 
#> [123] xtable_1.8-8                reticulate_1.46.0          
#> [125] jquerylib_0.1.4             zellkonverter_1.20.1       
#> [127] Rcpp_1.1.1-1.1              dir.expiry_1.16.0          
#> [129] globals_0.19.1              spatstat.random_3.4-5      
#> [131] dbplyr_2.5.2                png_0.1-9                  
#> [133] spatstat.univar_3.1-7       parallel_4.5.0             
#> [135] blob_1.3.0                  rclipboard_0.2.1           
#> [137] ggplot2_4.0.3               basilisk.utils_1.20.0      
#> [139] dotCall64_1.2               listenv_0.10.1             
#> [141] viridisLite_0.4.3           scales_1.4.0               
#> [143] ggridges_0.5.7              SeuratObject_5.4.0         
#> [145] purrr_1.2.2                 rlang_1.2.0                
#> [147] cowplot_1.2.0
```
