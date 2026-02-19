# Returns unharmonised metadata for a metadata query

Various metadata fields are *not* common between datasets, so it does
not make sense for these to live in the main metadata table. This
function is a utility that allows easy fetching of this data if
necessary.

## Usage

``` r
get_unharmonised_metadata(metadata, ...)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- metadata:

  A lazy data frame obtained from
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
  filtered down to some cells of interest

- ...:

  Arguments passed on to
  [`get_unharmonised_dataset`](https://mangiolalaboratory.github.io/cellNexus/reference/get_unharmonised_dataset.md)

  `dataset_id`

  :   A character vector, where each entry is a dataset ID obtained from
      the `$file_id_cellNexus_single_cell` column of the table returned
      from
      [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)

  `cells`

  :   An optional character vector of cell IDs. If provided, only
      metadata for those cells will be returned.

  `conn`

  :   An optional DuckDB connection object. If provided, it will re-use
      the existing connection instead of opening a new one.

  `remote_url`

  :   Optional character vector of length 1. An HTTP URL pointing to the
      root URL under which all the unharmonised dataset files are
      located.

  `cache_directory`

  :   Optional character vector of length 1. A file path on your local
      system to a directory (not a file) that will be used to store the
      unharmonised metadata files.

## Value

A tibble with two columns:

- `file_id_cellNexus_single_cell`: the same
  `file_id_cellNexus_single_cell` as the main metadata table obtained
  from
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md)

- `unharmonised`: a nested tibble, with one row per cell in the input
  `metadata`, containing unharmonised metadata

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.
