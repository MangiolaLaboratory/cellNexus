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
#> # A query:  ?? x 36
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cell_id dataset_id           sample_id sample_ experiment___ run_from_cell_id
#>      <dbl> <chr>                <chr>     <chr>   <chr>         <chr>           
#>  1      15 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  2      16 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  3      17 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  4      18 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  5      19 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  6      20 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  7      14 842c6f5d-4a94-4eef-… 1119f482… 1119f4… ""            NA              
#>  8       2 842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            NA              
#>  9       3 842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            NA              
#> 10       4 842c6f5d-4a94-4eef-… 1f755b9b… 1f755b… ""            NA              
#> # ℹ more rows
#> # ℹ 30 more variables: sample_heuristic <chr>, age_days <int>,
#> #   tissue_groups <chr>, nFeature_expressed_in_sample <int>, nCount_RNA <dbl>,
#> #   empty_droplet <lgl>, cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, …
```
