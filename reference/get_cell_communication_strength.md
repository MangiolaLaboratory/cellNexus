# Retrieve cellNexus cell communication ligand–receptor strength as a data frame.

Downloads a parquet database of the cell communication strength to a
local cache, and then opens it as a data frame. It can then be filtered.

## Usage

``` r
get_cell_communication_strength(
  cloud_metadata =
    get_metadata_url("cellNexus_lr_signaling_pathway_strength_DEMO.parquet"),
  local_metadata = NULL,
  cache_directory = get_default_cache_dir(),
  use_cache = TRUE
)
```

## Arguments

- cloud_metadata:

  Character vector of any length. HTTP URL/URLs pointing to the name and
  location of parquet database/databases. By default, it points to cell
  communication metadata in cellNexus ARDC Nectar Research Cloud. Assign
  `NULL` to query local_metadata only if exists.

- local_metadata:

  Optional character vector of any length representing the local path of
  parquet database(s).

- cache_directory:

  Optional character vector of length 1. A file path on your local
  system to a directory (not a file) that will be used to store
  `metadata.parquet`

- use_cache:

  Optional logical scalar. If `TRUE` (the default), and this function
  has been called before with the same parameters, then a cached
  reference to the table will be returned. If `FALSE`, a new
  connect138/4.7ion will be created no matter what.

## Value

A lazy data.frame subclass containing the metadata. You can interact
with this object using most standard dplyr functions. For string
matching, it is recommended that you use
[`stringr::str_like`](https://stringr.tidyverse.org/reference/str_like.html)
to filter character columns, as
[`stringr::str_match`](https://stringr.tidyverse.org/reference/str_match.html)
will not work.

## Details

The returned table integrates three levels of cell communication
inference from `CellChat`, for each sample: (i) ligand–receptor–level
communication (`lr_prob`, `lr_pval`), (ii) pathway-level aggregated
signaling (`pathway_prob`, `pathway_pval`), (iii) cell-pair–level
summaries of communication breadth (`interaction_count` - number of
significant LR interactions) and intensity (`interaction_weight` -
overall communication strength).

Together, these metrics allow simultaneous assessment of signaling
specificity, pathway dominance, and global communication structure
between cell populations.

## Examples

``` r
# For fast build purpose only, you do not need to specify anything in the function.
communication_meta <- get_cell_communication_strength(
  cloud_metadata = get_metadata_url(
    "cellNexus_lr_signaling_pathway_strength_DEMO.parquet"
  )
)
```
