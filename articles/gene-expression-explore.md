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

[`library`](https://rdrr.io/r/base/library.html)`(`[`cellNexus`](https://github.com/MangiolaLaboratory/cellNexus)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `` ``metadata`` ``<-`` `[`get_metadata`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)`(``cloud_metadata ``=`` ``SAMPLE_DATABASE_URL``)`` ``metadata`` ``<-`` ``metadata`` ``|>`` `` `[`keep_quality_cells`](https://mangiolalaboratory.github.io/cellNexus/reference/keep_quality_cells.md)`(``)`

## Choose cells through metadata filters

`query_metadata`` ``<-`` ``metadata`` ``|>`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(`` `` ``age_days`` ``>=`` ``40``*``365``,`` `` ``cell_type_unified_ensemble`` ``==`` ``"cd16 mono"``,`` `` ``tissue`` ``|>`` ``stringr``::`[`str_detect`](https://stringr.tidyverse.org/reference/str_detect.html)`(``"breast"``)``,`` `` ``imputed_ethnicity`` ``==`` ``"African American"`` `` ``)`` ``` #> Error in `dplyr::filter()`: ``` ``` #> ℹ In argument: `stringr::str_detect(tissue, "breast")` ``` ``#> Caused by error:`` ``` #> ! Object `tissue` not found. ``` ``query_metadata`` `` ``#> Error:`` ``#> ! object 'query_metadata' not found`

## Retrieve expression by representation

### Single-cell counts

`sce_counts`` ``<-`` ``query_metadata`` ``|>`` `` `[`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)`(``)`` ``#> Error:`` ``#> ! object 'query_metadata' not found`` ``sce_counts`` ``#> Error:`` ``#> ! object 'sce_counts' not found`

### Counts per million

`sce_cpm`` ``<-`` ``query_metadata`` ``|>`` `` `[`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)`(``assays ``=`` ``"cpm"``)`` ``#> Error:`` ``#> ! object 'query_metadata' not found`` ``sce_cpm`` ``#> Error:`` ``#> ! object 'sce_cpm' not found`

### Pseudobulk

`pb_counts`` ``<-`` ``query_metadata`` ``|>`` `` `[`get_pseudobulk`](https://mangiolalaboratory.github.io/cellNexus/reference/get_pseudobulk.md)`(``)`` ``#> Error:`` ``#> ! object 'query_metadata' not found`` ``pb_counts`` ``#> Error:`` ``#> ! object 'pb_counts' not found`

## Targeted gene queries

`# ENSEMBL IDs are expected`` ``sce_gene`` ``<-`` ``query_metadata`` ``|>`` `` `[`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)`(`` `` assays ``=`` ``"cpm"``,`` `` features ``=`` ``"ENSG00000134644"`` `` ``)`` ``#> Error:`` ``#> ! object 'query_metadata' not found`` ``sce_gene`` ``#> Error:`` ``#> ! object 'sce_gene' not found`

## Seurat

`# Seurat conversion`` ``seurat_obj`` ``<-`` ``query_metadata`` ``|>`` `` `[`get_seurat`](https://mangiolalaboratory.github.io/cellNexus/reference/get_seurat.md)`(``)`` ``#> Error:`` ``#> ! object 'query_metadata' not found`` ``seurat_obj`` ``#> Error:`` ``#> ! object 'seurat_obj' not found`

## Portable output examples

[`saveRDS`](https://rdrr.io/r/base/readRDS.html)`(``sce_counts``, ``"single_cell_counts.rds"``)`` ``HDF5Array``::`[`saveHDF5SummarizedExperiment`](https://rdrr.io/pkg/HDF5Array/man/saveHDF5SummarizedExperiment.html)`(`` `` ``sce_counts``,`` `` ``"single_cell_counts"``,`` `` replace ``=`` ``TRUE``,`` `` as.sparse ``=`` ``TRUE`` ``)`` ``anndataR``::`[`write_h5ad`](https://anndataR.scverse.org/reference/write_h5ad.html)`(``sce_counts``, ``"single_cell_counts.h5ad"``)`

## Interpretation notes

- Use `counts` for raw-scale abundance.
- Use `cpm` for normalized cross-cell comparisons.
- Use `rank` for ranked signature.
- Use `sct` for normalized cross-cell comparison by
  [`Seurat::SCTransform`](https://satijalab.org/seurat/reference/SCTransform.html).
- Use `pseudobulk` for sample/cell-type aggregation analyses.

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`` ``#> R version 4.5.3 (2026-03-11)`` ``#> Platform: x86_64-pc-linux-gnu`` ``#> Running under: Red Hat Enterprise Linux 9.6 (Plow)`` ``#> `` ``#> Matrix products: default`` ``#> BLAS: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRblas.so `` ``#> LAPACK: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRlapack.so; LAPACK version 3.12.1`` ``#> `` ``#> locale:`` ``#> [1] LC_CTYPE=en_US.UTF-8 LC_NUMERIC=C LC_TIME=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 `` ``#> [5] LC_MONETARY=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8 LC_PAPER=en_US.UTF-8 LC_NAME=C `` ``#> [9] LC_ADDRESS=C LC_TELEPHONE=C LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C `` ``#> `` ``#> time zone: Australia/Melbourne`` ``#> tzcode source: system (glibc)`` ``#> `` ``#> attached base packages:`` ``#> [1] stats graphics grDevices utils datasets methods base `` ``#> `` ``#> other attached packages:`` ``#> [1] BiocStyle_2.38.0 RcppSpdlog_0.0.28 ggplot2_4.0.2 dplyr_1.2.1 cellNexus_0.99.34`` ``#> `` ``#> loaded via a namespace (and not attached):`` ``#> [1] fs_2.0.1 matrixStats_1.5.0 spatstat.sparse_3.1-0 `` ``#> [4] fontawesome_0.5.3 httr_1.4.8 RColorBrewer_1.1-3 `` ``#> [7] tools_4.5.3 sctransform_0.4.3 backports_1.5.1 `` ``#> [10] utf8_1.2.6 R6_2.6.1 DT_0.34.0 `` ``#> [13] HDF5Array_1.38.0 lazyeval_0.2.3 uwot_0.2.4 `` ``#> [16] rhdf5filters_1.22.0 withr_3.0.2 sp_2.2-1 `` ``#> [19] gridExtra_2.3 nanoarrow_0.8.0 progressr_0.19.0 `` ``#> [22] cli_3.6.6 Biobase_2.70.0 spatstat.explore_3.8-0 `` ``#> [25] fastDummies_1.7.5 sass_0.4.10 Seurat_5.5.0.9002 `` ``#> [28] arrow_23.0.1.2 S7_0.2.1-1 spatstat.data_3.1-9 `` ``#> [31] ggridges_0.5.7 pbapply_1.7-4 commonmark_2.0.0 `` ``#> [34] parallelly_1.46.1 rstudioapi_0.18.0 generics_0.1.4 `` ``#> [37] ica_1.0-3 spatstat.random_3.4-5 Matrix_1.7-4 `` ``#> [40] fansi_1.0.7 S4Vectors_0.49.1-1 rclipboard_0.2.1 `` ``#> [43] abind_1.4-8 lifecycle_1.0.5 yaml_2.3.12 `` ``#> [46] SummarizedExperiment_1.40.0 rhdf5_2.54.1 SparseArray_1.10.10 `` ``#> [49] Rtsne_0.17 grid_4.5.3 blob_1.3.0 `` ``#> [52] promises_1.5.0 dir.expiry_1.18.0 miniUI_0.1.2 `` ``#> [55] lattice_0.22-9 cowplot_1.2.0 pillar_1.11.1 `` ``#> [58] knitr_1.51 GenomicRanges_1.62.1 future.apply_1.20.2 `` ``#> [61] codetools_0.2-20 glue_1.8.0 spatstat.univar_3.1-7 `` ``#> [64] tiledb_0.33.1 data.table_1.18.2.1 tidySingleCellExperiment_1.20.1`` ``#> [67] vctrs_0.7.3 png_0.1-9 spam_2.11-3 `` ``#> [70] gtable_0.3.6 aws.s3_0.3.22 assertthat_0.2.1 `` ``#> [73] cachem_1.1.0 xfun_0.57 S4Arrays_1.10.1 `` ``#> [76] mime_0.13 Seqinfo_1.0.0 survival_3.8-6 `` ``#> [79] SingleCellExperiment_1.32.0 ellipsis_0.3.3 fitdistrplus_1.2-6 `` ``#> [82] ROCR_1.0-12 nlme_3.1-168 tiledbsoma_2.1.2 `` ``#> [85] RcppCCTZ_0.2.14 bit64_4.6.0-1 filelock_1.0.3 `` ``#> [88] RcppAnnoy_0.0.23 GenomeInfoDb_1.46.2 rprojroot_2.1.1 `` ``#> [91] bslib_0.10.0 irlba_2.3.7 KernSmooth_2.23-26 `` ``#> [94] otel_0.2.0 BiocGenerics_0.56.0 DBI_1.3.0 `` ``#> [97] zellkonverter_1.20.1 duckdb_1.4.3 tidyselect_1.2.1 `` ``#> [100] processx_3.8.7 cellxgene.census_1.16.1 bit_4.6.0 `` ``#> [103] compiler_4.5.3 curl_7.0.0 rjsoncons_1.3.2 `` ``#> [106] h5mread_1.2.1 xml2_1.5.2 nanotime_0.3.13 `` ``#> [109] DelayedArray_0.36.1 plotly_4.12.0 bookdown_0.46 `` ``#> [112] checkmate_2.3.4 scales_1.4.0 lmtest_0.9-40 `` ``#> [115] callr_3.7.6 spdl_0.0.5 stringr_1.6.0 `` ``#> [118] anndataR_1.3.1 digest_0.6.39 goftest_1.2-3 `` ``#> [121] spatstat.utils_3.2-2 rmarkdown_2.31 basilisk_1.22.0 `` ``#> [124] XVector_0.50.0 htmltools_0.5.9 pkgconfig_2.0.3 `` ``#> [127] base64enc_0.1-6 MatrixGenerics_1.22.0 dbplyr_2.5.2 `` ``#> [130] fastmap_1.2.0 rlang_1.2.0 htmlwidgets_1.6.4 `` ``#> [133] UCSC.utils_1.6.1 shiny_1.13.0 farver_2.1.2 `` ``#> [136] jquerylib_0.1.4 zoo_1.8-15 jsonlite_2.0.0 `` ``#> [139] magrittr_2.0.5 dotCall64_1.2 patchwork_1.3.2 `` ``#> [142] Rhdf5lib_1.32.0 Rcpp_1.1.1-1 reticulate_1.46.0 `` ``#> [145] stringi_1.8.7 brio_1.1.5 MASS_7.3-65 `` ``#> [148] plyr_1.8.9 parallel_4.5.3 listenv_0.10.1 `` ``#> [151] ggrepel_0.9.8 forcats_1.0.1 deldir_2.0-4 `` ``#> [154] splines_4.5.3 tensor_1.5.1 ps_1.9.2 `` ``#> [157] cellxgenedp_1.14.0 igraph_2.2.3 spatstat.geom_3.7-3 `` ``#> [160] RcppHNSW_0.6.0 reshape2_1.4.5 stats4_4.5.3 `` ``#> [163] evaluate_1.0.5 ttservice_0.5.3 SeuratObject_5.4.0 `` ``#> [166] BiocManager_1.30.27 httpuv_1.6.17 RANN_2.6.2 `` ``#> [169] tidyr_1.3.2 purrr_1.2.2 polyclip_1.10-7 `` ``#> [172] future_1.70.0 scattermore_1.2 xtable_1.8-8 `` ``#> [175] RSpectra_0.16-2 later_1.4.8 viridisLite_0.4.3 `` ``#> [178] tibble_3.3.1 memoise_2.0.1 aws.signature_0.6.0 `` ``#> [181] IRanges_2.44.0 cluster_2.1.8.2 shinyWidgets_0.9.1 `` ``#> [184] globals_0.19.1`
