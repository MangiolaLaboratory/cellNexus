# Join metacell metadata to an existing data frame

Downloads and joins the metacell metadata with cellNexus metadata. This
function creates indexed tables for efficient joining and returns a data
frame.

## Usage

``` r
join_metacell_table(
  tbl,
  cache_directory = get_default_cache_dir(),
  join_keys = c("sample_id", "dataset_id", "cell_id"),
  ...
)
```

## Arguments

- tbl:

  A `tbl_sql` object (from get_metadata) or a database connection

- cache_directory:

  A character string specifying the local cache directory where remote
  parquet files will be stored. Defaults to
  [`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md).

- join_keys:

  A character vector of column names used for the join. Defaults to
  `c("sample_id", "dataset_id", "cell_id")`.

- ...:

  Additional arguments passed to
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html).

## Value

A lazy SQL table with metacell metadata joined to the cellNexus
metadata.

## Examples

``` r
library(dplyr)
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |> head(2) |> 
  join_metacell_table(cache_directory = tempdir())
#> ℹ Downloading 1 file, totalling 0.44 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/metacell_metadata.2.0.0.parquet to /tmp/Rtmpm1TSCa/metacell_metadata.2.0.0.parquet
#> # Source:   SQL [?? x 105]
#> # Database: DuckDB 1.5.0 [unknown@Linux 6.14.0-1017-azure:R 4.6.0/:memory:]
#>   cell_id dataset_id                      observation_joinid sample_id cell_type
#>     <dbl> <chr>                           <chr>              <chr>     <chr>    
#> 1      81 cda2c8cd-be1c-42e5-b2cd-162caa… *NUPW@J{c2         034f0fb1… monocyte 
#> 2      82 cda2c8cd-be1c-42e5-b2cd-162caa… KIV>qGFIS?         034f0fb1… monocyte 
#> # ℹ 100 more variables: cell_type_ontology_term_id <chr>, sample_ <chr>,
#> #   assay <chr>, assay_ontology_term_id <chr>, cell_count <int>,
#> #   citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, development_stage <chr>,
#> #   development_stage_ontology_term_id <chr>, disease <chr>,
#> #   disease_ontology_term_id <chr>, donor_id <chr>, experiment___ <chr>,
#> #   explorer_url <chr>, feature_count <int>, filesize <dbl>, filetype <chr>, …
```
