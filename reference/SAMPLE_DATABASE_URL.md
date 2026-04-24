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
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_sample_metadata.2.2.1.parquet to /tmp/RtmpyPrn4t/cellnexus_sample_metadata.2.2.1.parquet
#> # Source:   SQL [?? x 58]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.7.0/:memory:]
#>    cell_id observation_joinid dataset_id         sample_id sample_ experiment___
#>      <dbl> <chr>              <chr>              <chr>     <chr>   <chr>        
#>  1      14 qxl7HJjL$L         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  2      15 TjgA2vJ1;{         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  3      16 j}0<Y>a#X~         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  4      17 QRMCN*8*|#         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  5      18 h22!#$}SJ*         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  6      19 lNmuO5xs~3         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  7      20 6Eu5c&aEH;         842c6f5d-4a94-4ee… 1119f482… 1119f4… ""           
#>  8       5 N>_|{;6_6N         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#>  9       2 $jvBt8wHSK         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#> 10       3 5jp7Uu{#@#         842c6f5d-4a94-4ee… 1f755b9b… 1f755b… ""           
#> # ℹ more rows
#> # ℹ 52 more variables: run_from_cell_id <chr>, sample_heuristic <chr>,
#> #   age_days <int>, tissue_groups <chr>, nFeature_expressed_in_sample <int>,
#> #   nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>,
#> #   is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>, …
```
