# Gets the CellNexus metadata as a data frame.

Downloads a parquet database of the Human Cell Atlas metadata to a local
cache, and then opens it as a data frame. It can then be filtered and
passed into
[`get_single_cell_experiment()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_single_cell_experiment.md)
to obtain a
[`SingleCellExperiment::SingleCellExperiment`](https://rdrr.io/pkg/SingleCellExperiment/man/SingleCellExperiment.html)

## Usage

``` r
get_metadata(
  cloud_metadata = get_metadata_url("cellnexus_metadata.2.2.0.parquet"),
  local_metadata = NULL,
  cache_directory = get_default_cache_dir(),
  use_cache = TRUE
)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- cloud_metadata:

  Optional character vector of any length. HTTP URL/URLs pointing to the
  name and location of parquet database/databases. By default, it points
  to cellNexus ARDC Nectar Research Cloud. Assign `NULL` to query
  local_metadata only if exists.

- local_metadata:

  Optional character vector of any length representing the local path of
  parquet database(s).

- cache_directory:

  Optional character vector of length 1. A file path on your local
  system to a directory (not a file) that will be used to store
  metadata.

- use_cache:

  Optional logical scalar. If `TRUE` (the default), and this function
  has been called before with the same parameters, then a cached
  reference to the table will be returned. If `FALSE`, a new connection
  will be created no matter what.

## Value

A lazy data.frame subclass containing the metadata. You can interact
with this object using most standard dplyr functions. For string
matching, it is recommended that you use
[`stringr::str_like`](https://stringr.tidyverse.org/reference/str_like.html)
to filter character columns, as
[`stringr::str_match`](https://stringr.tidyverse.org/reference/str_match.html)
will not work.

## Details

The metadata was collected from the Bioconductor package `cellxgenedp`.
`vignette("using_cellxgenedp", package="cellxgenedp")` provides an
overview of the columns in the metadata. The data for which the column
`organism_name` included "Homo sapiens" was collected collected from
`cellxgenedp`.

The columns `dataset_id` and `file_id_cellNexus_single_cell` link the
datasets explorable through `cellNexus` and `cellxgenedp`to the
CELLxGENE portal.

Our representation, harmonises the metadata at dataset, sample and cell
levels, in a unique coherent database table.

Field definitions for the CELLxGENE schema follow the [CELLxGENE schema
5.1.0](https://github.com/chanzuckerberg/single-cell-curation/blob/main/schema/5.1.0/schema.md).

Dataset-specific columns: `dataset_id`, `collection_id`, `citation`,
`dataset_version_id`, `explorer_url`, `filesize`, `filetype`,
`published_at`, `raw_data_location`, `revised_at`, `schema_version`,
`suspension_type`, `title`, `url`, `donor_id`

Sample-specific columns: `assay`, `assay_ontology_term_id`,
`development_stage`, `development_stage_ontology_term_id`,
`self_reported_ethnicity`, `self_reported_ethnicity_ontology_term_id`,
`experiment___`, `organism`, `organism_ontology_term_id`, `sex`,
`sex_ontology_term_id`, `tissue`, `tissue_type`,
`tissue_ontology_term_id`, `disease`, `disease_ontology_term_id`,
`is_primary_data`

Cell-specific columns `cell_id`, `cell_type`,
`cell_type_ontology_term_id`, `observation_joinid`

Through harmonisation and curation we introduced custom columns not
present in the original CELLxGENE metadata:

`cell_count`: Number of cells in a dataset. `feature_count`: Number of
genes in a dataset. `age_days`: Donor age in days. `tissue_groups`:
Coarse tissue grouping for analysis. `empty_droplet`: Whether a cell is
called an empty droplet from expressed-gene count per sample (default
threshold 200; targeted panels may differ). `alive`: Whether a cell
passes viability / mitochondrial QC. `scDblFinder.class`: Doublet,
singlet, or unknown (`scDblFinder` default parameters).
`cell_type_unified_ensemble`: Consensus immune identity from Azimuth and
SingleR (Blueprint, Monaco). `cell_annotation_azimuth_l2`: Azimuth cell
annotation. `cell_annotation_blueprint_singler`: SingleR annotation
(Blueprint). `cell_annotation_blueprint_monaco`: SingleR annotation
(Monaco). `is_immune`: Whether a cell is an immune cell.
`sample_heuristic`: Internal sample subdivision helper.
`file_id_cellNexus_single_cell`: Internal file id for single-cell
layers. `file_id_cellNexus_pseudobulk`: Internal file id for pseudobulk
layers. `sample_id`: Harmonised sample identifier. `nCount_RNA`: Total
RNA counts per cell (sample-aware). `nFeature_expressed_in_sample`:
Number of expressed features per cell. `ethnicity_flagging_score`:
Supporting score for ethnicity imputation. `low_confidence_ethnicity`:
Supporting flag for low-confidence ethnicity calls. `.aggregated_cells`:
Post-QC cells combined into each pseudobulk sample. `imputed_ethnicity`:
Imputed ethnicity label. `atlas_id`: cellNexus atlas release identifier
(internal use).

For all fields definitions, please refer to our [documentation
site](https://cellnexus.org/)

**Possible cache path issues**

If your default R cache path includes non-standard characters (e.g. dash
because of your user or organisation name), the following error can
occur.

    Error in `db_query_fields.DBIConnection()`: ! Can't query fields. Caused by
    error: ! Parser Error: syntax error at or near "/" LINE 2: FROM
    /Users/bob/Library/Caches...

The solution is to choose a different cache, for example

    get_metadata(cache_directory = path.expand('~'))

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
library(dplyr)
# For fast build purpose only, you do not need to specify anything in cloud_metadata.
filtered_metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |>
  filter(
    self_reported_ethnicity == "African" &
      assay %LIKE% "%10x%" &
      tissue == "lung parenchyma" &
      cell_type %LIKE% "%CD4%"
  )
```
