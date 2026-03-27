# Returns the default cache directory with a version number

Returns the default cache directory with a version number

## Usage

``` r
get_default_cache_dir()
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Value

A length one character vector.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = get_default_cache_dir())
#> # Source:   SQL [?? x 73]
#> # Database: DuckDB 1.5.1 [unknown@Linux 6.17.0-1008-azure:R 4.6.0/:memory:]
#>    cell_id dataset_id   observation_joinid sample_id sample_ cell_count citation
#>      <dbl> <chr>        <chr>              <chr>     <chr>        <int> <chr>   
#>  1      81 cda2c8cd-be… *NUPW@J{c2         034f0fb1… 034f0f…     255901 Publica…
#>  2      82 cda2c8cd-be… KIV>qGFIS?         034f0fb1… 034f0f…     255901 Publica…
#>  3      83 cda2c8cd-be… p5e=WoIq0d         034f0fb1… 034f0f…     255901 Publica…
#>  4      84 cda2c8cd-be… I6>u{Gb-J_         034f0fb1… 034f0f…     255901 Publica…
#>  5      85 cda2c8cd-be… lx`7Bo-&7n         034f0fb1… 034f0f…     255901 Publica…
#>  6      87 cda2c8cd-be… -NL-OH3!IA         034f0fb1… 034f0f…     255901 Publica…
#>  7      88 cda2c8cd-be… zHCZWNmUHu         034f0fb1… 034f0f…     255901 Publica…
#>  8      89 cda2c8cd-be… *_#lQ<oUnT         034f0fb1… 034f0f…     255901 Publica…
#>  9      86 cda2c8cd-be… 6mRCZW}rOM         034f0fb1… 034f0f…     255901 Publica…
#> 10      99 cda2c8cd-be… IdHwp1GBZm         03ddfd57… 03ddfd…     255901 Publica…
#> # ℹ more rows
#> # ℹ 66 more variables: collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, experiment___ <chr>, explorer_url <chr>,
#> #   feature_count <int>, filesize <dbl>, filetype <chr>,
#> #   mean_genes_per_cell <dbl>, primary_cell_count <chr>, published_at <chr>,
#> #   raw_data_location <chr>, revised_at <chr>, run_from_cell_id <chr>,
#> #   sample_heuristic <chr>, schema_version <chr>, suspension_type <chr>, …
```
