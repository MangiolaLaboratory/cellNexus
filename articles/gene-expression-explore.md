# Gene Expression Explore

## Overview

The unified pseudobulk AnnData object was pre-generated outside of this
vignette applying quality control and retaining at least 15,000
intersecting genes across samples and hosted on Zenodo to avoid lengthy
recompilation. Download the latest version:
[pseudobulk_se.h5ad](https://zenodo.org/records/21633607/files/pseudobulk_se.h5ad?download=1).
For all versions:
[10.5281/zenodo.21633607](https://zenodo.org/records/21633607).

This page focuses on expression-layer retrieval workflows after metadata
filtering.

``` r

library(cellNexus)
library(dplyr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_hca2024_v2.3.2.parquet to /vast/scratch/users/shen.m/r_cache/R/cellNexus/sample_hca2024_v2.3.2.parquet
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
#> # Source:   SQL [?? x 29]
#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
#>    cell_id dataset_id    sample_id age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet cell_type_unified_en…²
#>      <dbl> <chr>         <chr>        <int> <chr>                          <int>      <dbl> <lgl>         <chr>                 
#>  1      19 842c6f5d-4a9… 1119f482…    14600 breast                          1876       9.15 FALSE         cd16 mono             
#>  2      14 842c6f5d-4a9… 1119f482…    14600 breast                          1547      10.5  FALSE         cd16 mono             
#>  3      16 842c6f5d-4a9… 1119f482…    14600 breast                          2438       9.80 FALSE         cd16 mono             
#>  4       2 842c6f5d-4a9… 1f755b9b…    14600 breast                          1342       9.40 FALSE         cd16 mono             
#>  5      24 842c6f5d-4a9… b0d0c16e…    14600 breast                          1800      10.7  FALSE         cd16 mono             
#>  6      22 842c6f5d-4a9… b0d0c16e…    14600 breast                          1759      11.1  FALSE         cd16 mono             
#>  7      21 842c6f5d-4a9… b0d0c16e…    14600 breast                          1552      10.2  FALSE         cd16 mono             
#>  8      11 842c6f5d-4a9… bd5f6876…    14600 breast                           399      11.2  FALSE         cd16 mono             
#>  9      25 842c6f5d-4a9… 04e410cb…    14600 breast                          1324      13.0  FALSE         cd16 mono             
#> 10      24 842c6f5d-4a9… 04e410cb…    14600 breast                          1254      13.8  FALSE         cd16 mono             
#> 11      13 842c6f5d-4a9… 30ea4b4f…    14600 breast                          1368      11.0  FALSE         cd16 mono             
#> 12       6 842c6f5d-4a9… 49ef9551…    14600 breast                          1771      11.6  FALSE         cd16 mono             
#> 13       9 842c6f5d-4a9… 49ef9551…    14600 breast                          1767      12.3  FALSE         cd16 mono             
#> # ℹ abbreviated names: ¹​nFeature_expressed_in_sample, ²​cell_type_unified_ensemble
#> # ℹ 20 more variables: is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>,
#> #   ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>,
#> #   atlas_id <chr>
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
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  1s

                                                                
ℹ Compiling Experiment.
sce_counts
#> # A SingleCellExperiment-tibble abstraction: 13 × 30
#> #  [90mFeatures=33145 | Cells=13 | Assays=counts [0m
#>    .cell dataset_id      sample_id age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet cell_type_unified_en…²
#>    <chr> <chr>           <chr>        <int> <chr>                          <int>      <dbl> <lgl>         <chr>                 
#>  1 19_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1876       9.15 FALSE         cd16 mono             
#>  2 14_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1547      10.5  FALSE         cd16 mono             
#>  3 16_1  842c6f5d-4a94-… 1119f482…    14600 breast                          2438       9.80 FALSE         cd16 mono             
#>  4 2_1   842c6f5d-4a94-… 1f755b9b…    14600 breast                          1342       9.40 FALSE         cd16 mono             
#>  5 24_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1800      10.7  FALSE         cd16 mono             
#>  6 22_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1759      11.1  FALSE         cd16 mono             
#>  7 21_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1552      10.2  FALSE         cd16 mono             
#>  8 11_1  842c6f5d-4a94-… bd5f6876…    14600 breast                           399      11.2  FALSE         cd16 mono             
#>  9 25_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1324      13.0  FALSE         cd16 mono             
#> 10 24_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1254      13.8  FALSE         cd16 mono             
#> 11 13_2  842c6f5d-4a94-… 30ea4b4f…    14600 breast                          1368      11.0  FALSE         cd16 mono             
#> 12 6_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1771      11.6  FALSE         cd16 mono             
#> 13 9_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1767      12.3  FALSE         cd16 mono             
#> # ℹ abbreviated names: ¹​nFeature_expressed_in_sample, ²​cell_type_unified_ensemble
#> # ℹ 21 more variables: is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>,
#> #   ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>,
#> #   atlas_id <chr>, original_cell_ <chr>
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
#> # A SingleCellExperiment-tibble abstraction: 13 × 30
#> # Features=33145 | Cells=13 | Assays=cpm
#>    .cell dataset_id      sample_id age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet cell_type_unified_en…²
#>    <chr> <chr>           <chr>        <int> <chr>                          <int>      <dbl> <lgl>         <chr>                 
#>  1 19_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1876       9.15 FALSE         cd16 mono             
#>  2 14_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1547      10.5  FALSE         cd16 mono             
#>  3 16_1  842c6f5d-4a94-… 1119f482…    14600 breast                          2438       9.80 FALSE         cd16 mono             
#>  4 2_1   842c6f5d-4a94-… 1f755b9b…    14600 breast                          1342       9.40 FALSE         cd16 mono             
#>  5 24_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1800      10.7  FALSE         cd16 mono             
#>  6 22_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1759      11.1  FALSE         cd16 mono             
#>  7 21_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1552      10.2  FALSE         cd16 mono             
#>  8 11_1  842c6f5d-4a94-… bd5f6876…    14600 breast                           399      11.2  FALSE         cd16 mono             
#>  9 25_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1324      13.0  FALSE         cd16 mono             
#> 10 24_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1254      13.8  FALSE         cd16 mono             
#> 11 13_2  842c6f5d-4a94-… 30ea4b4f…    14600 breast                          1368      11.0  FALSE         cd16 mono             
#> 12 6_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1771      11.6  FALSE         cd16 mono             
#> 13 9_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1767      12.3  FALSE         cd16 mono             
#> # ℹ abbreviated names: ¹​nFeature_expressed_in_sample, ²​cell_type_unified_ensemble
#> # ℹ 21 more variables: is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>,
#> #   ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>,
#> #   atlas_id <chr>, original_cell_ <chr>
```

### Pseudobulk

``` r

pb_counts <- query_metadata |>
  get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> ℹ Compiling Experiment.
pb_counts
#> # A SingleCellExperiment-tibble abstraction: 7 × 25
#> # Features=33145 | Cells=7 | Assays=counts
#>   .cell      sample_id cell_type_unified_en…¹ dataset_id age_days tissue_groups empty_droplet is_immune high_mitochondrion alive
#>   <chr>      <chr>     <chr>                  <chr>         <int> <chr>         <lgl>         <lgl>     <lgl>              <lgl>
#> 1 1119f4825… 1119f482… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 2 1f755b9b5… 1f755b9b… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 3 b0d0c16ed… b0d0c16e… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 4 bd5f6876c… bd5f6876… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 5 04e410cba… 04e410cb… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 6 30ea4b4f8… 30ea4b4f… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> 7 49ef9551c… 49ef9551… cd16 mono              842c6f5d-…    14600 breast        FALSE         TRUE      FALSE              TRUE 
#> # ℹ abbreviated name: ¹​cell_type_unified_ensemble
#> # ℹ 15 more variables: scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>,
#> #   count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, sample_identifier <chr>
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
#> # A SingleCellExperiment-tibble abstraction: 13 × 30
#> # Features=1 | Cells=13 | Assays=cpm
#>    .cell dataset_id      sample_id age_days tissue_groups nFeature_expressed_i…¹ nCount_RNA empty_droplet cell_type_unified_en…²
#>    <chr> <chr>           <chr>        <int> <chr>                          <int>      <dbl> <lgl>         <chr>                 
#>  1 19_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1876       9.15 FALSE         cd16 mono             
#>  2 14_1  842c6f5d-4a94-… 1119f482…    14600 breast                          1547      10.5  FALSE         cd16 mono             
#>  3 16_1  842c6f5d-4a94-… 1119f482…    14600 breast                          2438       9.80 FALSE         cd16 mono             
#>  4 2_1   842c6f5d-4a94-… 1f755b9b…    14600 breast                          1342       9.40 FALSE         cd16 mono             
#>  5 24_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1800      10.7  FALSE         cd16 mono             
#>  6 22_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1759      11.1  FALSE         cd16 mono             
#>  7 21_1  842c6f5d-4a94-… b0d0c16e…    14600 breast                          1552      10.2  FALSE         cd16 mono             
#>  8 11_1  842c6f5d-4a94-… bd5f6876…    14600 breast                           399      11.2  FALSE         cd16 mono             
#>  9 25_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1324      13.0  FALSE         cd16 mono             
#> 10 24_2  842c6f5d-4a94-… 04e410cb…    14600 breast                          1254      13.8  FALSE         cd16 mono             
#> 11 13_2  842c6f5d-4a94-… 30ea4b4f…    14600 breast                          1368      11.0  FALSE         cd16 mono             
#> 12 6_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1771      11.6  FALSE         cd16 mono             
#> 13 9_2   842c6f5d-4a94-… 49ef9551…    14600 breast                          1767      12.3  FALSE         cd16 mono             
#> # ℹ abbreviated names: ¹​nFeature_expressed_in_sample, ²​cell_type_unified_ensemble
#> # ℹ 21 more variables: is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>,
#> #   high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, nfeature_expressed_thresh <dbl>, inverse_transform <chr>,
#> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>,
#> #   ethnicity_flagging_score <dbl>, low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>,
#> #   atlas_id <chr>, original_cell_ <chr>
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
#> Warning: `when()` was deprecated in purrr 1.0.0.
#> ℹ Please use `if` instead.
#> ℹ The deprecated feature was likely used in the tidyseurat package.
#>   Please report the issue at <https://github.com/stemangiola/tidyseurat/issues>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.
#> # A Seurat-tibble abstraction: 13 × 35
#> # Features=33145 | Cells=13 | Active assay=counts | Assays=counts
#>    .cell orig.ident nCount_originalexp nFeature_originalexp dataset_id   sample_id age_days tissue_groups nFeature_expressed_i…¹
#>    <chr> <fct>                   <dbl>                <int> <chr>        <chr>        <int> <chr>                          <int>
#>  1 19_1  19                       13.0                 1970 842c6f5d-4a… 1119f482…    14600 breast                          1876
#>  2 14_1  14                       13.1                 1633 842c6f5d-4a… 1119f482…    14600 breast                          1547
#>  3 16_1  16                       13.0                 2529 842c6f5d-4a… 1119f482…    14600 breast                          2438
#>  4 2_1   2                        14.0                 1430 842c6f5d-4a… 1f755b9b…    14600 breast                          1342
#>  5 24_1  24                       13.9                 1889 842c6f5d-4a… b0d0c16e…    14600 breast                          1800
#>  6 22_1  22                       14.0                 1850 842c6f5d-4a… b0d0c16e…    14600 breast                          1759
#>  7 21_1  21                       13.8                 1640 842c6f5d-4a… b0d0c16e…    14600 breast                          1552
#>  8 11_1  11                       14.1                  456 842c6f5d-4a… bd5f6876…    14600 breast                           399
#>  9 25_2  25                       18.9                 1416 842c6f5d-4a… 04e410cb…    14600 breast                          1324
#> 10 24_2  24                       18.3                 1342 842c6f5d-4a… 04e410cb…    14600 breast                          1254
#> 11 13_2  13                       14.0                 1456 842c6f5d-4a… 30ea4b4f…    14600 breast                          1368
#> 12 6_2   6                        15.3                 1861 842c6f5d-4a… 49ef9551…    14600 breast                          1771
#> 13 9_2   9                        15.6                 1857 842c6f5d-4a… 49ef9551…    14600 breast                          1767
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 26 more variables: nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, alive <lgl>,
#> #   scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
#> #   nfeature_expressed_thresh <dbl>, inverse_transform <chr>, cell_annotation_blueprint_singler <chr>,
#> #   cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, ethnicity_flagging_score <dbl>,
#> #   low_confidence_ethnicity <chr>, .aggregated_cells <int>, imputed_ethnicity <chr>, atlas_id <chr>, original_cell_ <chr>, …
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
#>  [1] RcppSpdlog_0.0.28               cellNexus_0.99.30               purrr_1.2.2                    
#>  [4] HPCell_0.6.0                    ggplot2_4.0.2                   tidyr_1.3.2                    
#>  [7] tidySingleCellExperiment_1.20.1 ttservice_0.5.3                 SingleCellExperiment_1.32.0    
#> [10] anndataR_1.3.1                  arrow_23.0.1.2                  SummarizedExperiment_1.40.0    
#> [13] Biobase_2.70.0                  GenomicRanges_1.62.1            Seqinfo_1.0.0                  
#> [16] IRanges_2.44.0                  S4Vectors_0.49.1-1              BiocGenerics_0.56.0            
#> [19] generics_0.1.4                  MatrixGenerics_1.22.0           matrixStats_1.5.0              
#> [22] dplyr_1.2.1                    
#> 
#> loaded via a namespace (and not attached):
#>   [1] igraph_2.2.3                    ica_1.0-3                       plotly_4.12.0                  
#>   [4] SingleR_2.12.0                  scater_1.38.1                   devtools_2.5.0                 
#>   [7] tidyselect_1.2.1                bit_4.6.0                       lattice_0.22-9                 
#>  [10] rjson_0.2.21                    blob_1.3.0                      stringr_1.6.0                  
#>  [13] S4Arrays_1.10.1                 rclipboard_0.2.1                parallel_4.5.3                 
#>  [16] png_0.1-9                       cli_3.6.6                       ProtGenerics_1.42.0            
#>  [19] askpass_1.2.1                   openssl_2.4.2                   goftest_1.2-3                  
#>  [22] BiocIO_1.20.0                   bluster_1.20.0                  BiocNeighbors_2.4.0            
#>  [25] tarchetypes_0.14.1              uwot_0.2.4                      curl_7.0.0                     
#>  [28] mime_0.13                       evaluate_1.0.5                  stringi_1.8.7                  
#>  [31] ids_1.0.1                       backports_1.5.1                 desc_1.4.3                     
#>  [34] XML_3.99-0.23                   httpuv_1.6.17                   AnnotationDbi_1.72.0           
#>  [37] magrittr_2.0.5                  rappdirs_0.3.4                  splines_4.5.3                  
#>  [40] nanonext_1.8.2                  aws.signature_0.6.0             DT_0.34.0                      
#>  [43] sctransform_0.4.3               ggbeeswarm_0.7.3                sessioninfo_1.2.3              
#>  [46] DBI_1.3.0                       HDF5Array_1.38.0                jquerylib_0.1.4                
#>  [49] withr_3.0.2                     reformulas_0.4.4                rprojroot_2.1.1                
#>  [52] xgboost_3.2.1.1                 tidySummarizedExperiment_1.20.1 lmtest_0.9-40                  
#>  [55] brio_1.1.5                      BiocManager_1.30.27             rtracklayer_1.70.1             
#>  [58] duckdb_1.4.3                    htmlwidgets_1.6.4               fs_2.0.1                       
#>  [61] biomaRt_2.66.2                  ggrepel_0.9.8                   SparseArray_1.10.10            
#>  [64] tidyseurat_0.8.10               h5mread_1.2.1                   reticulate_1.46.0              
#>  [67] zoo_1.8-15                      tiledbsoma_2.1.2                XVector_0.50.0                 
#>  [70] knitr_1.51                      RcppCCTZ_0.2.14                 UCSC.utils_1.6.1               
#>  [73] secretbase_1.2.1                fansi_1.0.7                     patchwork_1.3.2                
#>  [76] pak_0.11.1                      grid_4.5.3                      data.table_1.18.2.1            
#>  [79] rhdf5_2.54.1                    R.oo_1.27.1                     RSpectra_0.16-2                
#>  [82] irlba_2.3.7                     tiledb_0.33.1                   commonmark_2.0.0               
#>  [85] fastDummies_1.7.5               ellipsis_0.3.3                  base64url_1.4                  
#>  [88] lazyeval_0.2.3                  yaml_2.3.12                     conflicted_1.2.0               
#>  [91] survival_3.8-6                  scattermore_1.2                 crayon_1.5.3                   
#>  [94] mirai_2.6.1                     RcppAnnoy_0.0.23                RColorBrewer_1.1-3             
#>  [97] progressr_0.19.0                later_1.4.8                     ggridges_0.5.7                 
#> [100] codetools_0.2-20                base64enc_0.1-6                 tidybulk_2.1.0                 
#> [103] Seurat_5.5.0.9002               KEGGREST_1.50.0                 Rtsne_0.17                     
#> [106] limma_3.66.0                    Rsamtools_2.26.0                filelock_1.0.3                 
#> [109] pkgconfig_2.0.3                 xml2_1.5.2                      spatstat.univar_3.1-7          
#> [112] GenomicAlignments_1.46.0        spatstat.sparse_3.1-0           viridisLite_0.4.3              
#> [115] xtable_1.8-8                    plyr_1.8.9                      httr_1.4.8                     
#> [118] rbibutils_2.4.1                 tools_4.5.3                     globals_0.19.1                 
#> [121] SeuratObject_5.4.0              pkgbuild_1.4.8                  beeswarm_0.4.0                 
#> [124] checkmate_2.3.4                 nlme_3.1-168                    dbplyr_2.5.2                   
#> [127] assertthat_0.2.1                lme4_2.0-1                      digest_0.6.39                  
#> [130] Matrix_1.7-4                    dir.expiry_1.18.0               farver_2.1.2                   
#> [133] tzdb_0.5.0                      AnnotationFilter_1.34.0         reshape2_1.4.5                 
#> [136] viridis_0.6.5                   glue_1.8.0                      cachem_1.1.0                   
#> [139] BiocFileCache_3.0.0             polyclip_1.10-7                 rjsoncons_1.3.2                
#> [142] Biostrings_2.78.0               parallelly_1.46.1               aws.s3_0.3.22                  
#> [145] pkgload_1.5.1                   statmod_1.5.1                   here_1.0.2                     
#> [148] RcppHNSW_0.6.0                  ScaledMatrix_1.18.0             minqa_1.2.8                    
#> [151] pbapply_1.7-4                   httr2_1.2.2                     job_0.3.1                      
#> [154] spam_2.11-3                     dqrng_0.4.1                     utf8_1.2.6                     
#> [157] scDblFinder_1.24.10             basilisk_1.22.0                 crew_1.3.0                     
#> [160] gridExtra_2.3                   shiny_1.13.0                    R.utils_2.13.0                 
#> [163] rhdf5filters_1.22.0             RCurl_1.98-1.18                 memoise_2.0.1                  
#> [166] rmarkdown_2.31                  nanoarrow_0.8.0                 scales_1.4.0                   
#> [169] R.methodsS3_1.8.2               future_1.70.0                   RANN_2.6.2                     
#> [172] renv_1.2.1                      spatstat.data_3.1-9             rstudioapi_0.18.0              
#> [175] cluster_2.1.8.2                 zellkonverter_1.20.1            spatstat.utils_3.2-2           
#> [178] hms_1.1.4                       fitdistrplus_1.2-6              cowplot_1.2.0                  
#> [181] rlang_1.2.0                     GenomeInfoDb_1.46.2             crew.cluster_0.4.0             
#> [184] DelayedMatrixStats_1.32.0       sparseMatrixStats_1.22.0        shinyWidgets_0.9.1             
#> [187] dotCall64_1.2                   scuttle_1.20.0                  xfun_0.57                      
#> [190] abind_1.4-8                     spdl_0.0.5                      tibble_3.3.1                   
#> [193] EnsDb.Hsapiens.v86_2.99.0       Rhdf5lib_1.32.0                 readr_2.2.0                    
#> [196] bitops_1.0-9                    Rdpack_2.6.6                    ps_1.9.2                       
#> [199] promises_1.5.0                  RSQLite_2.4.6                   cellxgenedp_1.14.0             
#> [202] DelayedArray_0.36.1             proxy_0.4-29                    compiler_4.5.3                 
#> [205] prettyunits_1.2.0               boot_1.3-32                     beachmat_2.26.0                
#> [208] listenv_0.10.1                  Rcpp_1.1.1-1                    edgeR_4.8.2                    
#> [211] roxygen2_7.3.3                  BiocSingular_1.26.1             tensor_1.5.1                   
#> [214] usethis_3.2.1                   MASS_7.3-65                     progress_1.2.3                 
#> [217] uuid_1.2-2                      BiocParallel_1.44.0             ggupset_0.4.1                  
#> [220] nanotime_0.3.13                 spatstat.random_3.4-5           R6_2.6.1                       
#> [223] fastmap_1.2.0                   vipor_0.4.7                     ensembldb_2.34.0               
#> [226] ROCR_1.0-12                     targets_1.12.0                  rsvd_1.0.5                     
#> [229] gtable_0.3.6                    KernSmooth_2.23-26              miniUI_0.1.2                   
#> [232] deldir_2.0-4                    htmltools_0.5.9                 bit64_4.6.0-1                  
#> [235] spatstat.explore_3.8-0          lifecycle_1.0.5                 S7_0.2.1-1                     
#> [238] processx_3.8.7                  nloptr_2.2.1                    callr_3.7.6                    
#> [241] restfulr_0.0.16                 sass_0.4.10                     vctrs_0.7.3                    
#> [244] testthat_3.3.2                  rsconnect_1.10.1                spatstat.geom_3.7-3            
#> [247] scran_1.38.1                    sp_2.2-1                        future.apply_1.20.2            
#> [250] bslib_0.10.0                    pillar_1.11.1                   GenomicFeatures_1.62.0         
#> [253] DropletUtils_1.30.0             cellxgene.census_1.16.1         collections_0.3.12             
#> [256] metapod_1.18.0                  locfit_1.5-9.12                 otel_0.2.0                     
#> [259] BiocStyle_2.38.0                jsonlite_2.0.0                  cigarillo_1.0.0
```
