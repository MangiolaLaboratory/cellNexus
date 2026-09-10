# cellNexus

[![Lifecycle:maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)

## Introduction

`cellNexus` extends the functionality of `CuratedAtlasQueryR` by
providing a unified interface for querying and accessing the harmonised,
curated, and reannotated CELLxGENE human cell atlas. It enables
reproducible, programmatic exploration of large-scale single-cell
datasets, supporting data retrieval at the cell, sample, and dataset
levels with flexible filtering based on tissue, cell type, experimental
condition, and other metadata. Retrieved data are returned in formats
ready for downstream analysis.

The package integrates over 44 million human cells processed through a
standardised pipeline, including consistent quality control,
normalisation, and unified abundance representations (e.g., single-cell,
counts-per-million, normalised expression, and pseudobulk). This
harmonisation facilitates efficient cross-dataset comparison and
integration.

Data are hosted on the ARDC Nectar Research Cloud, and most functions
access them via web requests; therefore, an active network connection is
required for typical use.

While both cellNexus and CuratedAtlasQueryR rely on precomputed
expression layers, cellNexus adopts a more standardised and transparent
processing workflow. This includes explicit removal of empty droplets
and dead cells, followed by harmonised quality control, normalisation,
and multi-layer data generation, ensuring alignment with evolving
CELLxGENE releases.

![plot of chunk fig-logo](../reference/figures/logo.png)

plot of chunk fig-logo

![plot of chunk fig-funders](../reference/figures/svcf_logo.jpeg)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/czi_logo.png)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/bioconductor_logo.jpg)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/vca_logo.png)

plot of chunk fig-funders

![plot of chunk fig-funders](../reference/figures/nectar_logo.png)

plot of chunk fig-funders

![plot of chunk
fig-funders](../reference/figures/CSL_Limited_logo.svg.png)

plot of chunk fig-funders

## Repositories

#### R API: [here](https://github.com/MangiolaLaboratory/cellNexus)

#### Python API: [here](https://github.com/MangiolaLaboratory/cellNexusPy/)

#### Article code: [here](https://github.com/MangiolaLaboratory/cellNexus_article)

## Query interface

### Installation

`devtools``::`[`install_github`](https://devtools.r-lib.org/reference/install-deprecated.html)`(``"MangiolaLaboratory/cellNexus"``)`

### Load the package

[`library`](https://rdrr.io/r/base/library.html)`(`[`cellNexus`](https://github.com/MangiolaLaboratory/cellNexus)`)`

### Load additional packages

[`suppressPackageStartupMessages`](https://rdrr.io/r/base/message.html)`(``{`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` ``}``)`

### Load and explore the metadata

#### Load the metadata

By default,
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)
loads harmonised annotations. Metadata is saved to
[`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md)
unless a custom path is provided via the cache_directory argument. The
`metadata` variable can then be re-used for all subsequent queries.

The unified pseudobulk AnnData object was pre-generated outside of this
vignette applying quality control and retaining at least 15,000
intersecting genes across samples and hosted on Zenodo to avoid lengthy
recompilation. Download the latest version:
[pseudobulk_se.h5ad](https://zenodo.org/records/22668580/files/pseudobulk_se.h5ad?download=1).
For all versions:
[10.5281/zenodo.22668580](https://zenodo.org/records/22668580).

The following sections demonstrate the metadata, quality control,
generation of raw and normalised counts, and pseudobulk construction for
the specified query.

`metadata`` ``<-`` `[`get_metadata`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)`(``)`` ``metadata`

    #> # Source:   SQL [?? x 33]
    #> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]
    #>    cell_id observation_joinid dataset_id        sample_id donor_id feature_count age_days nFeature_expressed_i…¹ nCount_RNA
    #>      <dbl> <chr>              <chr>             <chr>     <chr>            <int>    <int>                  <int>      <dbl>
    #>  1    7951 V^DVv&wmix         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                    670      9708.
    #>  2     430 bE&g|Ty{lq         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                    576      8940.
    #>  3   10537 +P10$OJbtq         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                   1846      9878.
    #>  4    4681 `rtxaAa~)4         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                    642      9520.
    #>  5   10538 YTZT;WA*H1         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                   1206      9817.
    #>  6   11685 q6&?h```1s         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                   1378      9663.
    #>  7   10539 {Ij`DT8SD?         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                    929      9834.
    #>  8    4682 s1e`j)^y54         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                   2611      9527.
    #>  9    4683 0G5XsAaJ&m         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                    517      9318.
    #> 10   10540 GPsK`oVmW=         ca46ffe6-0a26-4d… 86fbf754… Hs254            28675    14965                   1218      9649.
    #> # ℹ more rows
    #> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
    #> # ℹ 24 more variables: empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>, subsets_Mito_percent <int>,
    #> #   subsets_Ribo_percent <int>, high_mitochondrion <lgl>, high_ribosome <lgl>, alive <lgl>, scDblFinder.class <chr>,
    #> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>,
    #> #   nfeature_expressed_threshold <dbl>, inversed_inferred_distribution <chr>, inferred_distribution <chr>,
    #> #   cell_annotation_blueprint_singler <chr>, cell_annotation_monaco_singler <chr>, cell_annotation_azimuth_l2 <chr>, …

#### Quality control

cellNexus metadata applies standardised quality control to filter out
empty droplets, dead or damaged cells, doublets, and samples with low
gene counts.

`metadata`` ``<-`` ``metadata`` ``|>`` `` `[`keep_quality_cells`](https://mangiolalaboratory.github.io/cellNexus/reference/keep_quality_cells.md)`(``)`

#### Join Census metadata

Original Census annotations can be retrieved by the function
`get_census_metadata()`, and registered to lazy tibble format by
[DuckDB](https://duckdb.org/docs/current/clients/r)

`census_metadata`` ``<-`` ``cellNexus``:::``get_census_metadata``(``"2024-07-01"``)`` ``#> ℹ Opening Census version 2024-07-01.`` ``#> ℹ Reading Census obs table.`` `` ``con`` ``<-`` ``dbplyr``::`[`remote_con`](https://dbplyr.tidyverse.org/reference/remote_name.html)`(``metadata``)`` `` ``duckdb``::`[`duckdb_register_arrow`](https://r.duckdb.org/reference/duckdb_register_arrow.html)`(``con``, ``"census_metadata"``, ``census_metadata``)`` `` ``metadata`` ``<-`` ``metadata`` ``|>`` `` ``dplyr``::`[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(`[`tbl`](https://dplyr.tidyverse.org/reference/tbl.html)`(``con``, ``"census_metadata"``)`` ``|>`` `` `` ``dplyr``::`[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``observation_joinid``, ``dataset_id``, ``tissue``,`` `` ``self_reported_ethnicity``, ``cell_type``, ``assay``,`` `` ``disease``, ``sex``)``)`` ``` #> Joining with `by = join_by(observation_joinid, dataset_id)` ``

#### Explore tissues

`metadata`` ``|>`` `` ``dplyr``::`[`distinct`](https://dplyr.tidyverse.org/reference/distinct.html)`(``tissue``, ``cell_type_unified_ensemble``)`` ``#> # Source: SQL [?? x 2]`` ``#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]`` ``#> tissue cell_type_unified_ensemble`` ``#> <chr> <chr> `` ``#> 1 sigmoid colon b memory `` ``#> 2 sigmoid colon cdc `` ``#> 3 mesenteric lymph node t cd4 `` ``#> 4 mesenteric lymph node b `` ``#> 5 upper lobe of left lung pdc `` ``#> 6 upper lobe of left lung progenitor `` ``#> 7 upper lobe of left lung Unknown `` ``#> 8 upper lobe of left lung treg `` ``#> 9 upper lobe of left lung b naive `` ``#> 10 ascending colon cd4 tcm `` ``#> # ℹ more rows`

### Download single-cell RNA sequencing counts

#### Query raw counts

``` r
single_cell_counts <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> For native R and reading and writing of H5AD files, an R <AnnData> object, and conversion to <SingleCellExperiment> or
#> <Seurat> objects, check out the anndataR package:
#> ℹ Install it from Bioconductor with `BiocManager::install("anndataR")`
#> ℹ See more at <https://bioconductor.org/packages/anndataR/>
#> 
Reading counts ■■■■                              10% | ETA:  9s
#> 
Reading counts ■■■■■■■                           20% | ETA:  7s
#> 
Reading counts ■■■■■■■■■■                        30% | ETA:  6s
#> 
Reading counts ■■■■■■■■■■■■■                     40% | ETA:  4s
#> 
Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  4s
#> 
Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s
#> 
Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s
#> 
Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s
#> 
Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s
#> 
                                                                
#> ℹ Compiling Experiment.
#> 
#> This message is displayed once per session.

single_cell_counts
#> class: SingleCellExperiment 
#> dim: 33145 2794 
#> metadata(0):
#> assays(1): counts
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(2794): 73_1 74_1 ... 6_10 7_10
#> colData names(39): observation_joinid dataset_id ... sex original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```

#### Query counts scaled per million

``` r
single_cell_cpm <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "cpm")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■                           20% | ETA:  5s

Reading cpm ■■■■■■■■■■                        30% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> class: SingleCellExperiment 
#> dim: 33145 2794 
#> metadata(0):
#> assays(1): cpm
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(2794): 1_1 80_1 ... 9_10 10_10
#> colData names(39): observation_joinid dataset_id ... sex original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```

#### Query SCT normalised counts

``` r
single_cell_sct <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "sct")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading sct ■■■■■■■                           20% | ETA:  5s

Reading sct ■■■■■■■■■■                        30% | ETA:  4s

Reading sct ■■■■■■■■■■■■■                     40% | ETA:  4s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■                     40% | ETA:  4s

Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

                                                             
! The number of cells in the SingleCellExperiment will be less than the number of cells you have selected from the metadata. Are cell IDs duplicated? Or, do cell IDs correspond to the counts file?
#> Reading sct ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

Reading sct ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading sct ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
! cellNexus says: 1601 cell(s) from your metadata are absent from the SCT assay across 2 file(s). This is expected: SCT normalisation is run per sample and may fail for samples with very few cells or extreme count distributions. The returned object contains only cells from samples where SCT succeeded. Affected sample_id(s): 765554078ca8d1eaf2712000c0df0d6f, 8940e0767e7eca1b72d37b4138be2276, a79912cb9aaa8d8c0b1a3cdcc9294f8c.
#> ℹ Compiling Experiment.

single_cell_sct
#> class: SingleCellExperiment 
#> dim: 33145 1193 
#> metadata(0):
#> assays(1): sct
#> rownames(33145): ENSG00000243485 ENSG00000237613 ... ENSG00000277475 ENSG00000268674
#> rowData names(0):
#> colnames(1193): 80_1 81_1 ... 6_10 7_10
#> colData names(39): observation_joinid dataset_id ... sex original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```

#### Query pseudobulk

``` r
pseudobulk_counts <-
  metadata |>
  dplyr::filter(
    assay == "10x 5' v1" &
      tissue == "lung" &
      cell_type == "classical monocyte"
  ) |>
  get_pseudobulk()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■                             14% | ETA:  9s

Reading counts ■■■■■■■■■■                        29% | ETA:  9s

Reading counts ■■■■■■■■■■■■■■                    43% | ETA:  8s

Reading counts ■■■■■■■■■■■■■■■■■■                57% | ETA:  6s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            71% | ETA:  4s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% | ETA:  2s

                                                                
! cellNexus says: Not all genes completely overlap across the provided objects. Counts are generated by genes intersection.
#> ℹ Compiling Experiment.

pseudobulk_counts
#> class: SingleCellExperiment 
#> dim: 15888 146 
#> metadata(0):
#> assays(1): counts
#> rownames(15888): ENSG00000177757 ENSG00000225880 ... ENSG00000160307 ENSG00000160310
#> rowData names(0):
#> colnames(146): 2e8c9911c9bfbffc07288adef93d3cf2___cd14 mono 0d874636bc714a8d0146dfa0cbacadc5___cd14 mono ...
#>   1c7e90df93b48acabb013c8202830df5___cd14 mono 1c7e90df93b48acabb013c8202830df5___monocytic
#> colData names(31): sample_id cell_type_unified_ensemble ... sex sample_identifier
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```

### Download cell communication metadata

Cell communication metadata was generated based on post-QC cells per
sample using `CellChat v2` method. It uses our harmonised cell type
annotation (cell_type_unified_ensemble) to infer the communication. It
captures inferred communication at both the ligand–receptor pair level
and the signalling pathway level.

- interaction_count: The number of inferred interactions between each
  pair of cell groups.

- interaction_weight: The aggregated communication strength between each
  pair of cell groups.

For definitions of additional annotations, please refer to the CellChat
v2 documentation: <https://github.com/jinworks/CellChat>.

For demonstration purpose, read cell communication metadata from a demo
file here. Users do not need to specify cloud_metadata argument in this
case.

[`get_cell_communication_strength`](https://mangiolalaboratory.github.io/cellNexus/reference/get_cell_communication_strength.md)`(``cloud_metadata ``=`` `[`get_metadata_url`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata_url.md)`(``"cellNexus_lr_signaling_pathway_strength_DEMO.parquet"``)``)`` ``#> # Source: SQL [?? x 16]`` ``#> # Database: DuckDB 1.4.3 [unknown@Linux 5.14.0-570.123.1.el9_6.x86_64:R 4.5.3/:memory:]`` ``#> source target ligand receptor lr_prob lr_pval interaction_name interaction_name_2 pathway_name annotation evidence`` ``#> <chr> <chr> <chr> <chr> <dbl> <dbl> <chr> <chr> <chr> <chr> <chr> `` ``#> 1 b b TGFB1 TGFbR1_R2 0.000116 1 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> 2 b memory b TGFB1 TGFbR1_R2 0.000865 1 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> 3 b naive b TGFB1 TGFbR1_R2 0.000696 0.99 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> 4 cd14 mono b TGFB1 TGFbR1_R2 0.00240 0.81 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> 5 cd4 naive b TGFB1 TGFbR1_R2 0.000957 1 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> 6 cd4 tem b TGFB1 TGFbR1_R2 0.00242 0.76 TGFB1_TGFBR1_TGFB… TGFB1 - (TGFBR1+T… TGFb Secreted … KEGG: h…`` ``#> # ℹ 5 more variables: pathway_prob <dbl>, pathway_pval <dbl>, sample_id <chr>, interaction_count <dbl>,`` ``#> # interaction_weight <dbl>`

#### Extract only a subset of genes

This is helpful if just few genes are of interest (e.g ENSG00000134644
(PUM1)), as they can be compared across samples. cellNexus uses ENSEMBL
gene ID(s).

``` r
single_cell_cpm <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_single_cell_experiment(assays = "cpm", features = "ENSG00000134644")
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading cpm ■■■■■■■                           20% | ETA:  9s

Reading cpm ■■■■■■■■■■                        30% | ETA:  7s

Reading cpm ■■■■■■■■■■■■■                     40% | ETA:  5s

Reading cpm ■■■■■■■■■■■■■■■■                  50% | ETA:  4s

Reading cpm ■■■■■■■■■■■■■■■■■■■               60% | ETA:  3s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  2s

Reading cpm ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                             
ℹ Compiling Experiment.

single_cell_cpm
#> class: SingleCellExperiment 
#> dim: 1 2794 
#> metadata(0):
#> assays(1): cpm
#> rownames(1): ENSG00000134644
#> rowData names(0):
#> colnames(2794): 76_1 77_1 ... 7_10 12_10
#> colData names(39): observation_joinid dataset_id ... sex original_cell_
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
```

#### Extract the counts as a Seurat object

This convert the H5 SingleCellExperiment to Seurat so it might take long
time and occupy a lot of memory depending on how many cells you are
requesting.

``` r
seurat_counts <-
  metadata |>
  dplyr::filter(
    self_reported_ethnicity == "African American" &
      assay == "10x 3' v3" &
      tissue == "breast" &
      cell_type == "T cell"
  ) |>
  get_seurat()
#> ℹ Realising metadata.
#> ℹ Synchronising files
#> ℹ Reading files.
#> 
Reading counts ■■■■■■■                           20% | ETA:  5s

Reading counts ■■■■■■■■■■                        30% | ETA:  4s

Reading counts ■■■■■■■■■■■■■                     40% | ETA:  4s

Reading counts ■■■■■■■■■■■■■■■■                  50% | ETA:  3s

Reading counts ■■■■■■■■■■■■■■■■■■■               60% | ETA:  2s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  2s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA:  1s

Reading counts ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  1s

                                                                
ℹ Compiling Experiment.

seurat_counts
#> An object of class Seurat 
#> 33145 features across 2794 samples within 1 assay 
#> Active assay: counts (33145 features, 0 variable features)
#>  2 layers present: counts, data
```

By default, data is downloaded to
[`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md)
output. If memory is a concern, users can specify a custom path to
metadata and counts `cache_directory` argument. For example,
`get_metadata(cache_directory = "your_own_path")` and
`get_single_cell_experiment(cache_directory = "your_own_path")`.

Same strategy can be applied for functions `get_pseuodbulk()` and
[`get_seurat()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_seurat.md).

### Save your `SingleCellExperiment`

The returned `SingleCellExperiment` can be saved with three modalities,
as `.rds` or as `HDF5` or as `H5AD`.

#### Saving as RDS (fast saving, slow reading)

Saving as `.rds` has the advantage of being fast, and the `.rds` file
occupies very little disk space as it only stores the links to the files
in your cache.

However it has the disadvantage that for big `SingleCellExperiment`
objects, which merge a lot of HDF5 from your
`get_single_cell_experiment`, the display and manipulation is going to
be slow. In addition, an `.rds` saved in this way is not portable: you
will not be able to share it with other users.

`single_cell_counts`` ``|>`` `` `[`saveRDS`](https://rdrr.io/r/base/readRDS.html)`(``"single_cell_counts.rds"``)`

#### Saving as HDF5 (slow saving, fast reading)

Saving as `.hdf5` executes any computation on the `SingleCellExperiment`
and writes it to disk as a monolithic `HDF5`. Once this is done,
operations on the `SingleCellExperiment` will be comparatively very
fast. The resulting `.hdf5` file will also be totally portable and
sharable.

However this `.hdf5` has the disadvantage of being larger than the
corresponding `.rds` as it includes a copy of the count information, and
the saving process is going to be slow for large objects.

`# ! IMPORTANT if you save 200K+ cells`` ``HDF5Array``::``setAutoBlockSize``(``size ``=`` ``1e+09``)`` `` ``single_cell_counts`` ``|>`` `` ``HDF5Array``::`[`saveHDF5SummarizedExperiment`](https://rdrr.io/pkg/HDF5Array/man/saveHDF5SummarizedExperiment.html)`(`` `` ``"single_cell_counts"``,`` `` replace ``=`` ``TRUE``,`` `` as.sparse ``=`` ``TRUE``,`` `` verbose ``=`` ``TRUE`` `` ``)`

#### Saving as H5AD (slow saving, fast reading)

Saving as `.h5ad` executes any computation on the `SingleCellExperiment`
and writes it to disk as a monolithic `H5AD`. The `H5AD` format is the
HDF5 disk representation of the AnnData object and is well-supported in
Python.

However this `.h5ad` saving strategy has a bottleneck of handling
columns with only NA values of a `SingleCellExperiment` metadata.

`single_cell_counts`` ``|>`` `` ``anndataR``::`[`write_h5ad`](https://anndataR.scverse.org/reference/write_h5ad.html)`(``"single_cell_counts.h5ad"``,`` `` compression ``=`` ``"gzip"``,`` `` verbose ``=`` ``TRUE`` `` ``)`

### Visualise gene transcription

We can gather all CD14 monocytes cells and plot the distribution of
ENSG00000085265 (FCN1) across all tissues

`# Plots with styling`` ``counts`` ``<-`` ``metadata`` ``|>`` `` `` ``# Filter and subset`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``cell_type_unified_ensemble`` ``==`` ``"cd14 mono"``)`` ``|>`` `` `` ``# Get counts per million for FCN1 gene`` `` `[`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)`(``assays ``=`` ``"cpm"``, features ``=`` ``"ENSG00000085265"``)`` ``|>`` `` `[`suppressMessages`](https://rdrr.io/r/base/message.html)`(``)`` ``|>`` `` `` ``# Add feature to table`` `` ``tidySingleCellExperiment``::``join_features``(``"ENSG00000085265"``, shape ``=`` ``"wide"``)`` ``|>`` `` `` ``# Rank x axis`` `` ``tibble``::`[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)`(``)`` ``|>`` `` `` ``# Rename to gene symbol`` `` ``dplyr``::`[`rename`](https://dplyr.tidyverse.org/reference/rename.html)`(``FCN1 ``=`` ``ENSG00000085265``)`` `` ``# Plot by disease`` ``counts`` ``|>`` `` ``dplyr``::`[`with_groups`](https://dplyr.tidyverse.org/reference/with_groups.html)`(``disease``, ``~`` ``.x`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``median_count ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``` `FCN1` ```, rm.na ``=`` ``TRUE``)``)``)`` ``|>`` `` `` ``# Plot`` `` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``forcats``::`[`fct_reorder`](https://forcats.tidyverse.org/reference/fct_reorder.html)`(``disease``, ``median_count``, .desc ``=`` ``TRUE``)``, ``` `FCN1` ```, color ``=`` ``dataset_id``)``)`` ``+`` `` `[`geom_jitter`](https://ggplot2.tidyverse.org/reference/geom_jitter.html)`(``shape ``=`` ``"."``)`` ``+`` `` `` ``# Style`` `` `[`guides`](https://ggplot2.tidyverse.org/reference/guides.html)`(``color ``=`` ``"none"``)`` ``+`` `` `[`scale_y_log10`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``)`` ``+`` `` `[`theme_bw`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``angle ``=`` ``60``, vjust ``=`` ``1``, hjust ``=`` ``1``)``)`` ``+`` `` `[`xlab`](https://ggplot2.tidyverse.org/reference/labs.html)`(``"Disease"``)`` ``+`` `` `[`ggtitle`](https://ggplot2.tidyverse.org/reference/labs.html)`(``"FCN1 in CD14 monocytes by disease. Coloured by datasets"``)`` ``#> Warning in scale_y_log10(): log-10 transformation introduced infinite values.`

![plot of chunk plot-fcn1-disease](plot-fcn1-disease-1.png)

plot of chunk plot-fcn1-disease

`# Plot by tissue`` ``counts`` ``|>`` `` ``dplyr``::`[`with_groups`](https://dplyr.tidyverse.org/reference/with_groups.html)`(``tissue``, ``~`` ``.x`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``median_count ``=`` `[`median`](https://rdrr.io/r/stats/median.html)`(``` `FCN1` ```, rm.na ``=`` ``TRUE``)``)``)`` ``|>`` `` `` ``# Plot`` `` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(`` `` ``forcats``::`[`fct_reorder`](https://forcats.tidyverse.org/reference/fct_reorder.html)`(``tissue``,`` `` ``median_count``,`` `` .desc ``=`` ``TRUE`` `` ``)``,`` `` ``` `FCN1` ```,`` `` color ``=`` ``dataset_id`` `` ``)``)`` ``+`` `` `[`geom_jitter`](https://ggplot2.tidyverse.org/reference/geom_jitter.html)`(``shape ``=`` ``"."``)`` ``+`` `` `` ``# Style`` `` `[`guides`](https://ggplot2.tidyverse.org/reference/guides.html)`(``color ``=`` ``"none"``)`` ``+`` `` `[`scale_y_log10`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``)`` ``+`` `` `[`theme_bw`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``angle ``=`` ``60``, vjust ``=`` ``1``, hjust ``=`` ``1``)``)`` ``+`` `` `[`xlab`](https://ggplot2.tidyverse.org/reference/labs.html)`(``"Tissue"``)`` ``+`` `` `[`ggtitle`](https://ggplot2.tidyverse.org/reference/labs.html)`(``"FCN1 in CD14 monocytes by tissue. Colored by datasets"``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"none"``, axis.text.x ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``size ``=`` ``6.5``)``)`` ``#> Warning in scale_y_log10(): log-10 transformation introduced infinite values.`

![plot of chunk plot-fcn1-tissue](plot-fcn1-tissue-1.png)

plot of chunk plot-fcn1-tissue

### Integrate cloud and local metadata

`cellNexus` not only enables users to query our metadata but also allows
integration with your local metadata. Additionally, users can integrate
with your metadata stored in the cloud.

To enable this feature, users must include
`file_id_cellNexus_single_cell` and `atlas_id` (e.g cellxgene/dd-mm-yy)
columns in the metadata. See metadata structure in cellNexus::pbmc3k_sce

`# Set up local cache and paths`` ``local_cache`` ``<-`` `[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)`` ``layer`` ``<-`` ``"counts"`` ``meta_path`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``local_cache``, ``"pbmc3k_metadata.parquet"``)`` `[`data`](https://rdrr.io/r/utils/data.html)`(``pbmc3k_sce``)`` `` ``# Extract and prepare metadata`` ``pbmc3k_metadata`` ``<-`` ``pbmc3k_sce`` ``|>`` `` ``S4Vectors``::`[`metadata`](https://rdrr.io/pkg/S4Vectors/man/Annotated-class.html)`(``)`` ``|>`` `` ``purrr``::`[`pluck`](https://purrr.tidyverse.org/reference/pluck.html)`(``"data"``)`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` counts_directory ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``atlas_id``, ``layer``)``,`` `` sce_path ``=`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(``counts_directory``, ``file_id_cellNexus_single_cell``)`` `` ``)`` `` ``# Get unique paths`` ``counts_directory`` ``<-`` ``pbmc3k_metadata`` ``|>`` `` ``dplyr``::`[`pull`](https://dplyr.tidyverse.org/reference/pull.html)`(``counts_directory``)`` ``|>`` `` `[`unique`](https://rdrr.io/r/base/unique.html)`(``)`` `` ``sce_path`` ``<-`` ``pbmc3k_metadata`` ``|>`` `` ``dplyr``::`[`pull`](https://dplyr.tidyverse.org/reference/pull.html)`(``sce_path``)`` ``|>`` `` `[`unique`](https://rdrr.io/r/base/unique.html)`(``)`` `` ``# Create directory structure`` `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``counts_directory``, recursive ``=`` ``TRUE``, showWarnings ``=`` ``FALSE``)`` `` ``# Save data to disk`` ``pbmc3k_sce`` ``|>`` `` ``S4Vectors``::`[`metadata`](https://rdrr.io/pkg/S4Vectors/man/Annotated-class.html)`(``)`` ``|>`` `` ``purrr``::`[`pluck`](https://purrr.tidyverse.org/reference/pluck.html)`(``"data"``)`` ``|>`` `` ``arrow``::`[`write_parquet`](https://arrow.apache.org/docs/r/reference/write_parquet.html)`(``meta_path``)`` `` ``# Save SCE object`` ``pbmc3k_sce`` ``|>`` `` ``anndataR``::`[`write_h5ad`](https://anndataR.scverse.org/reference/write_h5ad.html)`(``sce_path``, compression ``=`` ``"gzip"``, mode ``=`` ``"w"``)`

`# A cellNexus file`` ``file_id_from_cloud`` ``<-`` ``"e52795dec7b626b6276b867d55328d9f___1.h5ad"`` ``file_id_local`` ``<-`` `[`basename`](https://rdrr.io/r/base/basename.html)`(``sce_path``)`` `` `[`get_metadata`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)`(`` `` cloud_metadata ``=`` ``cellNexus``::`[`SAMPLE_DATABASE_URL`](https://mangiolalaboratory.github.io/cellNexus/reference/SAMPLE_DATABASE_URL.md)`,`` `` local_metadata ``=`` ``meta_path``,`` `` cache_directory ``=`` ``local_cache`` ``)`` ``|>`` `` ``# For illustration purpose, only filter a selected cloud metadata and the saved metadata`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``file_id_cellNexus_single_cell`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``file_id_from_cloud``, ``file_id_local``)``)`` ``|>`` `` ``dplyr``::`[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``cell_id``, ``sample_id``, ``dataset_id``, ``cell_type_unified_ensemble``, ``atlas_id``, ``file_id_cellNexus_single_cell``)`` ``|>`` `` `[`get_single_cell_experiment`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)`(``cache_directory ``=`` ``local_cache``)`` ``#> ℹ Downloading 1 file, totalling 0 GB`` ``#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_hca2024_v2.4.0.parquet to /vast/scratch/users/shen.m/tmp/RtmpUOaoJG/sample_hca2024_v2.4.0.parquet`` ``#> ℹ Realising metadata.`` ``#> ℹ Synchronising files`` ``#> ℹ Reading files.`` ``#> ℹ Compiling Experiment.`` ``#> # A SingleCellExperiment-tibble abstraction: 500 × 7`` ``#> # ``Features=13132 | Cells=500 | Assays=counts`` ``#> .cell sample_id dataset_id cell_type_unified_ensemble atlas_id file_id_cellNexus_si…¹ original_cell_`` ``#> <chr> <chr> <chr> <chr> <chr> <chr> <chr> `` ``#> 1 AAACATACAACCAC_1 pbmc3k pbmc3k Memory CD4 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACATACAACCAC`` ``#> 2 AAACATTGAGCTAC_1 pbmc3k pbmc3k B cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACATTGAGCTAC`` ``#> 3 AAACATTGATCAGC_1 pbmc3k pbmc3k Memory CD4 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACATTGATCAGC`` ``#> 4 AAACCGTGCTTCCG_1 pbmc3k pbmc3k CD14+ Mono cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACCGTGCTTCCG`` ``#> 5 AAACCGTGTATGCG_1 pbmc3k pbmc3k NK cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACCGTGTATGCG`` ``#> 6 AAACGCACTGGTAC_1 pbmc3k pbmc3k Memory CD4 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACGCACTGGTAC`` ``#> 7 AAACGCTGACCAGT_1 pbmc3k pbmc3k CD8 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACGCTGACCAGT`` ``#> 8 AAACGCTGGTTCTT_1 pbmc3k pbmc3k CD8 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACGCTGGTTCTT`` ``#> 9 AAACGCTGTAGCCA_1 pbmc3k pbmc3k Naive CD4 T cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACGCTGTAGCCA`` ``#> 10 AAACGCTGTTTCTG_1 pbmc3k pbmc3k FCGR3A+ Mono cellxgene/03-10-… 67e196a3c4e145151fc9e… AAACGCTGTTTCTG`` ``#> # ℹ 490 more rows`` ``#> # ℹ abbreviated name: ¹​file_id_cellNexus_single_cell`

## Cell metadata

The complete metadata dictionary for the harmonised fields is available
on the documentation site: [cellNexus
documentation](https://cellnexus.org/).

## Annotational annotations

Optionally, you can explore CELLxGENE metadata to retrieve additional
information, such as the CELLxGENE URL (`explorer_url`), published paper
title (`title`), published date (`published at`), and other
dataset-level, file-level, or collection-level annotations.

This information can be joined with cellNexus metadata when needed. Note
that these additional annotations are not used to produce this vignette.

For example, to explore CELLxGENE dataset-level annotations.

`cellNexus``:::``get_cellxgene_metadata``(``"dataset"``)`` ``|>`` `` ``dplyr``::`[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``dplyr``::`[`where`](https://tidyselect.r-lib.org/reference/where.html)`(``~`` ``!`[`is.list`](https://rdrr.io/r/base/list.html)`(``.x``)``)``)`` ``#> # A tibble: 2,100 × 17`` ``#> dataset_id dataset_version_id collection_id cell_count citation default_embedding explorer_url feature_count`` ``#> <chr> <chr> <chr> <int> <chr> <chr> <chr> <int>`` ``#> 1 6cda3b13-7257-45b9-ac… 9349c6fb-758d-483… db468083-041… 59605 Publica… X_tsne https://cel… 32383`` ``#> 2 42b6a476-c51d-4f8b-b6… a4a32eaa-9828-417… db468083-041… 11243 Publica… X_tsne https://cel… 32383`` ``#> 3 ebc2e1ff-c8f9-466a-ac… 687c09ff-731a-4e3… 8f126edf-540… 836148 Publica… <NA> https://cel… 36306`` ``#> 4 60a29d0b-1a37-4447-ac… b6da1a8e-2d81-42e… 4cbb929b-b03… 97125 Publica… X_umap https://cel… 36030`` ``#> 5 09b518f9-da64-44cc-ae… a14c154d-b867-486… 4cbb929b-b03… 37717 Publica… X_umap_Spectral_… https://cel… 35475`` ``#> 6 3de0ad6d-4378-4f62-b3… b1ba366b-d63b-4fd… 625f6bf4-2f3… 46500 Publica… <NA> https://cel… 25799`` ``#> 7 30cd5311-6c09-46c9-94… 73024e1c-c5e4-48d… ed9185e3-5b8… 125117 Publica… <NA> https://cel… 30000`` ``#> 8 21d3e683-80a4-4d9b-bc… e6ef9f09-bf7f-49b… ed9185e3-5b8… 246964 Publica… <NA> https://cel… 30000`` ``#> 9 3f32121d-126b-4e8d-9f… cece25a7-9d37-475… 7651ac1a-f94… 36359 Publica… X_umap https://cel… 32383`` ``#> 10 3a8aec06-3309-4d37-b7… 281bf7bb-c74a-4da… c2879de0-aff… 26499 Dataset… <NA> https://cel… 27986`` ``#> # ℹ 2,090 more rows`` ``#> # ℹ 9 more variables: mean_genes_per_cell <dbl>, primary_cell_count <int>, raw_data_location <chr>, schema_version <chr>,`` ``#> # title <chr>, tombstone <lgl>, x_approximate_distribution <chr>, published_at <date>, revised_at <date>`

## RNA abundance

The `counts` assay represents RNA abundance on the positive real scale,
without non-linear transformations (e.g., log or square root). In the
original CELLxGENE data, values were provided using a mix of scales and
transformations. The method required to invert these transformations is
recorded in `inverse_transform` column.

The `cpm` assay includes counts per million.

The `sct` assay includes normalised counts by `sctranform`.

## Other representations

The `rank` assay is the representation of each cell’s gene expression
profile where genes are ranked by expression intensity using
`singscore`.

The `pseudobulk` assay includes aggregated RNA abundance for sample and
cell type combination.

The detailed documentation for RNA abundance is available on the
documentation site: [cellNexus documentation](https://cellnexus.org/).

## Session Info

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`` ``#> R version 4.5.3 (2026-03-11)`` ``#> Platform: x86_64-pc-linux-gnu`` ``#> Running under: Red Hat Enterprise Linux 9.6 (Plow)`` ``#> `` ``#> Matrix products: default`` ``#> BLAS: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRblas.so `` ``#> LAPACK: /stornext/System/data/software/rhel/9/base/tools/R/4.5.3/lib64/R/lib/libRlapack.so; LAPACK version 3.12.1`` ``#> `` ``#> locale:`` ``#> [1] LC_CTYPE=en_US.UTF-8 LC_NUMERIC=C LC_TIME=en_US.UTF-8 LC_COLLATE=en_US.UTF-8 `` ``#> [5] LC_MONETARY=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8 LC_PAPER=en_US.UTF-8 LC_NAME=C `` ``#> [9] LC_ADDRESS=C LC_TELEPHONE=C LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C `` ``#> `` ``#> time zone: Australia/Melbourne`` ``#> tzcode source: system (glibc)`` ``#> `` ``#> attached base packages:`` ``#> [1] stats graphics grDevices utils datasets methods base `` ``#> `` ``#> other attached packages:`` ``#> [1] RcppSpdlog_0.0.28 ggplot2_4.0.2 dplyr_1.2.1 cellNexus_0.99.34`` ``#> `` ``#> loaded via a namespace (and not attached):`` ``#> [1] fs_2.0.1 matrixStats_1.5.0 spatstat.sparse_3.1-0 `` ``#> [4] fontawesome_0.5.3 httr_1.4.8 RColorBrewer_1.1-3 `` ``#> [7] tools_4.5.3 sctransform_0.4.3 backports_1.5.1 `` ``#> [10] utf8_1.2.6 R6_2.6.1 DT_0.34.0 `` ``#> [13] HDF5Array_1.38.0 lazyeval_0.2.3 uwot_0.2.4 `` ``#> [16] rhdf5filters_1.22.0 withr_3.0.2 sp_2.2-1 `` ``#> [19] gridExtra_2.3 nanoarrow_0.8.0 progressr_0.19.0 `` ``#> [22] cli_3.6.6 Biobase_2.70.0 spatstat.explore_3.8-0 `` ``#> [25] fastDummies_1.7.5 sass_0.4.10 Seurat_5.5.0.9002 `` ``#> [28] arrow_23.0.1.2 S7_0.2.1-1 spatstat.data_3.1-9 `` ``#> [31] ggridges_0.5.7 pbapply_1.7-4 commonmark_2.0.0 `` ``#> [34] parallelly_1.46.1 rstudioapi_0.18.0 generics_0.1.4 `` ``#> [37] ica_1.0-3 spatstat.random_3.4-5 Matrix_1.7-4 `` ``#> [40] fansi_1.0.7 S4Vectors_0.49.1-1 rclipboard_0.2.1 `` ``#> [43] abind_1.4-8 lifecycle_1.0.5 yaml_2.3.12 `` ``#> [46] SummarizedExperiment_1.40.0 rhdf5_2.54.1 SparseArray_1.10.10 `` ``#> [49] Rtsne_0.17 grid_4.5.3 blob_1.3.0 `` ``#> [52] promises_1.5.0 dir.expiry_1.18.0 miniUI_0.1.2 `` ``#> [55] lattice_0.22-9 cowplot_1.2.0 pillar_1.11.1 `` ``#> [58] knitr_1.51 GenomicRanges_1.62.1 future.apply_1.20.2 `` ``#> [61] codetools_0.2-20 glue_1.8.0 spatstat.univar_3.1-7 `` ``#> [64] tiledb_0.33.1 data.table_1.18.2.1 tidySingleCellExperiment_1.20.1`` ``#> [67] vctrs_0.7.3 png_0.1-9 spam_2.11-3 `` ``#> [70] gtable_0.3.6 aws.s3_0.3.22 assertthat_0.2.1 `` ``#> [73] cachem_1.1.0 xfun_0.57 S4Arrays_1.10.1 `` ``#> [76] mime_0.13 Seqinfo_1.0.0 survival_3.8-6 `` ``#> [79] SingleCellExperiment_1.32.0 ellipsis_0.3.3 fitdistrplus_1.2-6 `` ``#> [82] ROCR_1.0-12 nlme_3.1-168 tiledbsoma_2.1.2 `` ``#> [85] RcppCCTZ_0.2.14 bit64_4.6.0-1 filelock_1.0.3 `` ``#> [88] RcppAnnoy_0.0.23 GenomeInfoDb_1.46.2 rprojroot_2.1.1 `` ``#> [91] bslib_0.10.0 irlba_2.3.7 KernSmooth_2.23-26 `` ``#> [94] otel_0.2.0 BiocGenerics_0.56.0 DBI_1.3.0 `` ``#> [97] zellkonverter_1.20.1 duckdb_1.4.3 tidyselect_1.2.1 `` ``#> [100] processx_3.8.7 cellxgene.census_1.16.1 bit_4.6.0 `` ``#> [103] compiler_4.5.3 curl_7.0.0 rjsoncons_1.3.2 `` ``#> [106] h5mread_1.2.1 xml2_1.5.2 nanotime_0.3.13 `` ``#> [109] DelayedArray_0.36.1 plotly_4.12.0 bookdown_0.46 `` ``#> [112] checkmate_2.3.4 scales_1.4.0 lmtest_0.9-40 `` ``#> [115] callr_3.7.6 spdl_0.0.5 stringr_1.6.0 `` ``#> [118] anndataR_1.3.1 digest_0.6.39 goftest_1.2-3 `` ``#> [121] spatstat.utils_3.2-2 rmarkdown_2.31 basilisk_1.22.0 `` ``#> [124] XVector_0.50.0 htmltools_0.5.9 pkgconfig_2.0.3 `` ``#> [127] base64enc_0.1-6 MatrixGenerics_1.22.0 dbplyr_2.5.2 `` ``#> [130] fastmap_1.2.0 rlang_1.2.0 htmlwidgets_1.6.4 `` ``#> [133] UCSC.utils_1.6.1 shiny_1.13.0 farver_2.1.2 `` ``#> [136] jquerylib_0.1.4 zoo_1.8-15 jsonlite_2.0.0 `` ``#> [139] magrittr_2.0.5 dotCall64_1.2 patchwork_1.3.2 `` ``#> [142] Rhdf5lib_1.32.0 Rcpp_1.1.1-1 reticulate_1.46.0 `` ``#> [145] stringi_1.8.7 brio_1.1.5 MASS_7.3-65 `` ``#> [148] plyr_1.8.9 parallel_4.5.3 listenv_0.10.1 `` ``#> [151] ggrepel_0.9.8 forcats_1.0.1 deldir_2.0-4 `` ``#> [154] splines_4.5.3 tensor_1.5.1 ps_1.9.2 `` ``#> [157] cellxgenedp_1.14.0 igraph_2.2.3 spatstat.geom_3.7-3 `` ``#> [160] RcppHNSW_0.6.0 reshape2_1.4.5 stats4_4.5.3 `` ``#> [163] evaluate_1.0.5 ttservice_0.5.3 SeuratObject_5.4.0 `` ``#> [166] BiocManager_1.30.27 httpuv_1.6.17 RANN_2.6.2 `` ``#> [169] tidyr_1.3.2 purrr_1.2.2 polyclip_1.10-7 `` ``#> [172] future_1.70.0 scattermore_1.2 xtable_1.8-8 `` ``#> [175] RSpectra_0.16-2 later_1.4.8 viridisLite_0.4.3 `` ``#> [178] tibble_3.3.1 memoise_2.0.1 aws.signature_0.6.0 `` ``#> [181] IRanges_2.44.0 cluster_2.1.8.2 shinyWidgets_0.9.1 `` ``#> [184] globals_0.19.1 BiocStyle_2.38.0`
