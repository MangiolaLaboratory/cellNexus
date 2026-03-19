# Join Census metadata to an existing data frame

Downloads and joins the Census metadata with cellNexus metadata. This
function creates indexed tables for efficient joining and returns a data
frame.

## Usage

``` r
join_census_table(
  tbl,
  cache_directory = get_default_cache_dir(),
  join_keys = c("sample_id", "dataset_id", "observation_joinid"),
  ...
)
```

## Arguments

- tbl:

  A `tbl_sql` object (from get_metadata) or a database connection.

- cache_directory:

  A character string specifying the local cache directory where remote
  parquet files will be stored. Defaults to
  [`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md).

- join_keys:

  A character vector of column names used for the join. Defaults to
  `c("sample_id", "dataset_id", "observation_joinid")`.

- ...:

  Additional arguments passed to
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html).
  library(dplyr) get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) \|\>
  head(2) \|\> join_census_table(cache_directory = tempdir())

## Value

A lazy SQL table with Census metadata joined to the cellNexus metadata.
