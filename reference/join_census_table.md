# Join Census metadata to an existing data frame

Downloads and joins the Census metadata with cellNexus metadata. This
function creates indexed tables for efficient joining and returns a data
frame.

## Usage

``` r
join_census_table(
  tbl,
  cloud_metadata = get_metadata_url("census_cell_metadata.2.2.1.parquet"),
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
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/census_sample_metadata.2.2.1.parquet to /tmp/Rtmplftk0d/census_sample_metadata.2.2.1.parquet
#> # Source:   SQL [?? x 149]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.6.0/:memory:]
#>   cell_id.x observation_joinid dataset_id    sample_id sample_.x experiment___.x
#>       <dbl> <chr>              <chr>         <chr>     <chr>     <chr>          
#> 1        14 qxl7HJjL$L         842c6f5d-4a9… 1119f482… 1119f482… ""             
#> 2        15 TjgA2vJ1;{         842c6f5d-4a9… 1119f482… 1119f482… ""             
#> 3        14 qxl7HJjL$L         842c6f5d-4a9… 1119f482… 1119f482… ""             
#> 4        15 TjgA2vJ1;{         842c6f5d-4a9… 1119f482… 1119f482… ""             
#> # ℹ 143 more variables: run_from_cell_id.x <chr>, sample_heuristic.x <chr>,
#> #   age_days.x <int>, tissue_groups.x <chr>,
#> #   nFeature_expressed_in_sample.x <int>, nCount_RNA.x <dbl>,
#> #   empty_droplet.x <lgl>, cell_type_unified_ensemble.x <chr>,
#> #   is_immune.x <lgl>, subsets_Mito_percent.x <int>,
#> #   subsets_Ribo_percent.x <int>, high_mitochondrion.x <lgl>,
#> #   high_ribosome.x <lgl>, scDblFinder.class.x <chr>, sample_chunk.x <int>, …
```
