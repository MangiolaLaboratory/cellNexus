# URL pointing to the sample metadata file, which is smaller and for test, demonstration, and vignette purposes only

URL pointing to the sample metadata file, which is smaller and for test,
demonstration, and vignette purposes only

## Usage

``` r
SAMPLE_DATABASE_URL
```

## Format

An object of class `character` of length 2.

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Value

Character scalar consisting of the URL/URLs

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL["cellnexus"], cache_directory = tempdir())
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_sample_metadata.2.2.0.parquet to /tmp/RtmpQWE1lc/cellnexus_sample_metadata.2.2.0.parquet
#> # Source:   SQL [?? x 55]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.7.0/:memory:]
#>    cell_id observation_joinid dataset_id   sample_id sample_ cell_count citation
#>      <dbl> <chr>              <chr>        <chr>     <chr>        <int> <chr>   
#>  1      15 TjgA2vJ1;{         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  2      19 lNmuO5xs~3         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  3      18 h22!#$}SJ*         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  4      17 QRMCN*8*|#         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  5      14 qxl7HJjL$L         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  6      20 6Eu5c&aEH;         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  7      16 j}0<Y>a#X~         842c6f5d-4a… 1119f482… 1119f4…     714331 Publica…
#>  8       5 N>_|{;6_6N         842c6f5d-4a… 1f755b9b… 1f755b…     714331 Publica…
#>  9       4 CVfj>iWZ&P         842c6f5d-4a… 1f755b9b… 1f755b…     714331 Publica…
#> 10       3 5jp7Uu{#@#         842c6f5d-4a… 1f755b9b… 1f755b…     714331 Publica…
#> # ℹ more rows
#> # ℹ 48 more variables: collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, experiment___ <chr>, explorer_url <chr>,
#> #   feature_count <int>, filesize <dbl>, filetype <chr>,
#> #   mean_genes_per_cell <dbl>, primary_cell_count <chr>, published_at <chr>,
#> #   raw_data_location <chr>, revised_at <chr>, run_from_cell_id <chr>,
#> #   sample_heuristic <chr>, schema_version <chr>, suspension_type <chr>, …
```
