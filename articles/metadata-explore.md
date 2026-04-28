# Metadata Explore

## Why this page exists

This page is a standalone metadata guide for `cellNexus` and documents
the key fields used in downstream analysis.

``` r

library(cellNexus)
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
metadata
```

## Data-processing context

`cellNexus` metadata are harmonised to support cross-dataset analysis:

- Common ontology-backed labels are retained where possible.
- Additional curated columns support quality control and robust
  grouping.
- Expression retrieval APIs use metadata filters to provide
  analysis-ready objects.

## Metadata dictionary

### Dataset-level fields

| Column | Description |
|----|----|
| `dataset_id` | Primary dataset identifier used in the atlas. |
| `dataset_version_id` | Versioned identifier for a dataset release. |
| `collection_id` | Parent collection identifier grouping related datasets. |
| `cell_count` | Number of cells associated with the dataset. |
| `filetype` | Storage format of source expression files. |
| `is_primary_data` | Flags whether data are marked as primary observations. |
| `mean_genes_per_cell` | Mean detected genes per cell reported for the dataset. |
| `published_at` | Publication timestamp for dataset release. |
| `revised_at` | Last revision timestamp for the dataset metadata. |
| `schema_version` | CELLxGENE schema version associated with this record. |
| `tombstone` | Indicates whether a dataset has been retired/deprecated upstream. |
| `x_normalization` | Original normalization/scale annotation from source metadata. |
| `explorer_url` | URL to browse the dataset in a public explorer. |

### Sample-level fields

| Column | Description |
|----|----|
| `sample_id` | Harmonised sample identifier used in `cellNexus`. |
| `sample_` | Source sample label from upstream metadata. |
| `donor_id` | Donor or participant identifier linked to the sample. |
| `age_days` | Donor age represented in days (harmonised). |
| `sex` | Recorded biological sex label. |
| `sex_ontology_term_id` | Ontology identifier for `sex`. |
| `development_stage` | Developmental stage label. |
| `development_stage_ontology_term_id` | Ontology identifier for `development_stage`. |
| `self_reported_ethnicity` | Self-reported ancestry/ethnicity label where available. |
| `self_reported_ethnicity_ontology_term_id` | Ontology identifier for self-reported ethnicity. |
| `organism` | Organism name for the sample (for example, human). |
| `organism_ontology_term_id` | Ontology identifier for `organism`. |
| `assay` | Assay/platform label used for sequencing. |
| `assay_ontology_term_id` | Ontology identifier for `assay`. |
| `tissue` | Tissue label used for biological grouping. |
| `tissue_ontology_term_id` | Ontology identifier for `tissue`. |
| `tissue_type` | Tissue class (for example, tissue vs organoid context). |
| `tissue_groups` | Curated high-level grouping of tissues. |
| `disease` | Disease/condition annotation. |
| `disease_ontology_term_id` | Ontology identifier for `disease`. |
| `sample_placeholder` | Placeholder marker from upstream records where needed. |
| `experiment___` | Upstream experiment grouping variable. |
| `is_immune` | Curated flag indicating immune-cell context. |

### Cell-level fields

| Column | Description |
|----|----|
| `cell_id` | Unique cell barcode/identifier. |
| `observation_joinid` | Join key used to link metadata and expression records. |
| `cell_type` | Source/curated cell-type label. |
| `cell_type_ontology_term_id` | Ontology identifier for `cell_type`. |
| `cell_type_unified_ensemble` | `cellNexus` consensus immune-cell identity from multi-method annotation. |
| `cell_annotation_azimuth_l2` | Azimuth level-2 annotation used in harmonisation. |
| `cell_annotation_blueprint_singler` | SingleR annotation using Blueprint reference. |
| `cell_annotation_blueprint_monaco` | SingleR annotation using Monaco reference. |
| `empty_droplet` | Quality-control flag for probable empty droplets. |
| `alive` | Quality-control flag for viable/non-damaged cells. |
| `scDblFinder.class` | Doublet classification label from `scDblFinder`. |
| `nCount_RNA` | Total RNA counts detected in a cell (sample-aware). |
| `nFeature_expressed_in_sample` | Number of expressed features detected in a cell. |

### `cellNexus` infrastructure fields

| Column | Description |
|----|----|
| `sample_heuristic` | Internal sample subdivision/grouping helper. |
| `file_id_cellNexus_single_cell` | Internal file identifier for single-cell layers. |
| `file_id_cellNexus_pseudobulk` | Internal file identifier for pseudobulk layers. |

## Practical exploration

``` r

# Which columns are available?
colnames(metadata)

# How many datasets per tissue?
metadata |>
  dplyr::distinct(dataset_id, tissue) |>
  dplyr::count(tissue, sort = TRUE)

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
#> R version 4.6.0 (2026-04-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> loaded via a namespace (and not attached):
#>  [1] digest_0.6.39     desc_1.4.3        R6_2.6.1          fastmap_1.2.0    
#>  [5] xfun_0.57         cachem_1.1.0      knitr_1.51        htmltools_0.5.9  
#>  [9] rmarkdown_2.31    lifecycle_1.0.5   cli_3.6.6         sass_0.4.10      
#> [13] pkgdown_2.2.0     textshaping_1.0.5 jquerylib_0.1.4   systemfonts_1.3.2
#> [17] compiler_4.6.0    tools_4.6.0       ragg_1.5.2        bslib_0.10.0     
#> [21] evaluate_1.0.5    yaml_2.3.12       otel_0.2.0        jsonlite_2.0.0   
#> [25] rlang_1.2.0       fs_2.1.0          htmlwidgets_1.6.4
```
