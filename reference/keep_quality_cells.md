# Keep high-quality cells based on QC columns

Keep high-quality cells based on QC columns

## Usage

``` r
keep_quality_cells(
  data,
  empty_droplet_col = "empty_droplet",
  alive_col = "alive",
  doublet_col = "scDblFinder.class"
)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- data:

  A data frame or tibble containing single-cell metadata.

- empty_droplet_col:

  A string specifying the column name that indicates empty droplets
  (default: `"empty_droplet"`). Expected logical vector

- alive_col:

  A string specifying the column name that indicates whether cells are
  alive (default: `"alive"`). Expected logical vector

- doublet_col:

  A string specifying the column name that indicates doublets (default:
  `"scDblFinder.class"`). Expected character vector: `"doublet"` and/or
  `"singlet"` and/or `"unknown"`.

## Value

A filtered data frame containing only cells that pass all QC checks.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = tempdir()) |>
  head(2) |>
  keep_quality_cells()
#> # Source:   SQL [?? x 73]
#> # Database: DuckDB 1.5.1 [unknown@Linux 6.14.0-1017-azure:R 4.5.3/:memory:]
#>   cell_id dataset_id    observation_joinid sample_id sample_ cell_count citation
#>     <dbl> <chr>         <chr>              <chr>     <chr>        <int> <chr>   
#> 1      81 cda2c8cd-be1… *NUPW@J{c2         034f0fb1… 034f0f…     255901 Publica…
#> 2      82 cda2c8cd-be1… KIV>qGFIS?         034f0fb1… 034f0f…     255901 Publica…
#> # ℹ 66 more variables: collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, experiment___ <chr>, explorer_url <chr>,
#> #   feature_count <int>, filesize <dbl>, filetype <chr>,
#> #   mean_genes_per_cell <dbl>, primary_cell_count <chr>, published_at <chr>,
#> #   raw_data_location <chr>, revised_at <chr>, run_from_cell_id <chr>,
#> #   sample_heuristic <chr>, schema_version <chr>, suspension_type <chr>,
#> #   tissue_type <chr>, title <chr>, tombstone <lgl>, url <chr>, …
```
