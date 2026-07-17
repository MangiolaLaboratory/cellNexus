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

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = get_default_cache_dir())
#> # A query:  ?? x 58
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>        
#>  1      17 QRMCN*8*|#         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  2      16 j}0<Y>a#X~         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  3      20 6Eu5c&aEH;         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  4      19 lNmuO5xs~3         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  5      15 TjgA2vJ1;{         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  6      18 h22!#$}SJ*         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  7      14 qxl7HJjL$L         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  8       3 5jp7Uu{#@#         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#>  9       2 $jvBt8wHSK         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#> 10       5 N>_|{;6_6N         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#> # ℹ more rows
#> # ℹ 52 more variables: run_from_cell_id <chr>, sample_heuristic <chr>,
#> #   age_days <int>, tissue_groups <chr>, nFeature_expressed_in_sample <int>,
#> #   nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>,
#> #   is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, …
```
