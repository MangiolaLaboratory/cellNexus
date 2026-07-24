# URL pointing to the sample metadata file, which is smaller and for test, demonstration, and vignette purposes only

URL pointing to the sample metadata file, which is smaller and for test,
demonstration, and vignette purposes only

## Usage

``` r
SAMPLE_DATABASE_URL
```

## Format

An object of class `character` of length 1.

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Value

Character scalar consisting of the URL/URLs

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = tempdir())
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_hca2024_v2.3.1.parquet to /tmp/RtmpIS5BGy/sample_hca2024_v2.3.1.parquet
#> duckdb is keeping downloaded extensions in a temporary directory:
#> ℹ /tmp/RtmpIS5BGy/duckdb/extensions
#> This is removed when the R session ends, so extensions are re-downloaded each session.
#> ℹ To keep them, point `options(duckdb.extension_directory =)` or the `DUCKDB_EXTENSION_DIRECTORY` environment variable at a permanent path.
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
