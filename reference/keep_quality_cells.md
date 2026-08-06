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
#> # A query:  ?? x 29
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>   cell_id dataset_id     sample_id age_days tissue_groups nFeature_expressed_i…¹
#>     <dbl> <chr>          <chr>        <int> <chr>                          <int>
#> 1      18 842c6f5d-4a94… 1119f482…    14600 breast                          1894
#> 2      19 842c6f5d-4a94… 1119f482…    14600 breast                          1876
#> # ℹ abbreviated name: ¹​nFeature_expressed_in_sample
#> # ℹ 23 more variables: nCount_RNA <dbl>, empty_droplet <lgl>,
#> #   cell_type_unified_ensemble <chr>, is_immune <lgl>,
#> #   subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, alive <lgl>,
#> #   scDblFinder.class <chr>, file_id_cellNexus_single_cell <chr>,
#> #   file_id_cellNexus_pseudobulk <chr>, count_upper_bound <dbl>, …
```
