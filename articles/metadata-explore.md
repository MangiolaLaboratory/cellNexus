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
