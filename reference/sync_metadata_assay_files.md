# Synchronize metadata assay files with remote repository

Downloads and caches assay files from a remote repository based on
metadata specifications.

## Usage

``` r
sync_metadata_assay_files(
  data,
  assays = "counts",
  repository = COUNTS_URL,
  cell_aggregation = "",
  grouping_column,
  cache_directory = get_default_cache_dir()
)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- data:

  A data frame or tbl_sql containing metadata with required columns
  `cell_id`, `atlas_id`, and a grouping column

- assays:

  Character vector specifying which assays to sync

- repository:

  URL of the remote repository containing the assay files

- cell_aggregation:

  Character string specifying the cell aggregation strategy

- grouping_column:

  Column name in data used to group files for synchronization

- cache_directory:

  Local directory path where files will be cached. Uses default cache if
  not specified

## Value

`NULL`, invisibly. Progress messages are displayed for the downloads.
