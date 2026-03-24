# Join Census metadata to an existing data frame

Downloads and joins the Census metadata with cellNexus metadata. This
function creates indexed tables for efficient joining and returns a data
frame.

## Usage

``` r
join_census_table(
  tbl,
  cloud_metadata = get_metadata_url("census_cell_metadata.2.0.0.parquet"),
  cache_directory = get_default_cache_dir(),
  join_keys = c("sample_id", "dataset_id", "observation_joinid")
)
```

## Arguments

- tbl:

  A `tbl_sql` object (from get_metadata) or a database connection.

- cloud_metadata:

  HTTP URL/URLs pointing to the census parquet database name and
  location.

- cache_directory:

  A character string specifying the local cache directory where remote
  parquet files will be stored. Defaults to
  [`get_default_cache_dir()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_default_cache_dir.md).

- join_keys:

  A character vector of column names used for the join. Defaults to
  `c("sample_id", "dataset_id", "observation_joinid")`.

## Value

A lazy SQL table with Census metadata joined to the cellNexus metadata.

## Examples

``` r
library(dplyr)
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL) |> head(2) |>
  # You do not need to specify anything in cloud_metadata
  join_census_table(
    cloud_metadata = SAMPLE_DATABASE_URL,
    cache_directory = tempdir()
  )
#> # Source:   SQL [?? x 175]
#> # Database: DuckDB 1.5.0 [unknown@Linux 6.14.0-1017-azure:R 4.6.0/:memory:]
#>   cell_id.x dataset_id                  observation_joinid sample_id cell_type.x
#>       <dbl> <chr>                       <chr>              <chr>     <chr>      
#> 1        81 cda2c8cd-be1c-42e5-b2cd-16… *NUPW@J{c2         034f0fb1… monocyte   
#> 2        82 cda2c8cd-be1c-42e5-b2cd-16… KIV>qGFIS?         034f0fb1… monocyte   
#> # ℹ 170 more variables: cell_type_ontology_term_id.x <chr>, sample_.x <chr>,
#> #   assay.x <chr>, assay_ontology_term_id.x <chr>, cell_count.x <int>,
#> #   citation.x <chr>, collection_id.x <chr>, dataset_version_id.x <chr>,
#> #   default_embedding.x <chr>, development_stage.x <chr>,
#> #   development_stage_ontology_term_id.x <chr>, disease.x <chr>,
#> #   disease_ontology_term_id.x <chr>, donor_id.x <chr>, experiment___.x <chr>,
#> #   explorer_url.x <chr>, feature_count.x <int>, filesize.x <dbl>, …
```
