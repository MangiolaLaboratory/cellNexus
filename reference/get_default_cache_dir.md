# Returns the default cache directory with a version number

Returns the default cache directory with a version number

## Usage

``` r
get_default_cache_dir()
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Value

A length one character vector.

## Cache integrity checking

By default, every file in the cache is verified against its remote ETag
(MD5) before being reused. This catches partial downloads left by
interrupted sessions. You should only disable the check when the cache
is known to be intact.

    options(cellNexus.check_cache_integrity = FALSE)

To make this permanent, add the line to your `~/.Rprofile`.

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = get_default_cache_dir())
#> # A query:  ?? x 31
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cell_id dataset_id    sample_id feature_count age_days nFeature_expressed_i…¹
#>      <dbl> <chr>         <chr>             <int>    <int>                  <int>
#>  1      14 842c6f5d-4a9… 1119f482…         33145    14600                   1547
#>  2      15 842c6f5d-4a9… 1119f482…         33145    14600                   1701
#>  3      16 842c6f5d-4a9… 1119f482…         33145    14600                   2438
#>  4      17 842c6f5d-4a9… 1119f482…         33145    14600                   2122
#>  5      18 842c6f5d-4a9… 1119f482…         33145    14600                   1894
#>  6      19 842c6f5d-4a9… 1119f482…         33145    14600                   1876
#>  7      20 842c6f5d-4a9… 1119f482…         33145    14600                   1441
#>  8       2 842c6f5d-4a9… 1f755b9b…         33145    14600                   1342
#>  9       5 842c6f5d-4a9… 1f755b9b…         33145    14600                   1820
#> 10       4 842c6f5d-4a9… 1f755b9b…         33145    14600                   1514
#> # ℹ more rows
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 25 more variables: nCount_RNA <dbl>, empty_droplet <lgl>,
#> #   cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, alive <lgl>,
#> #   scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>, …
```
