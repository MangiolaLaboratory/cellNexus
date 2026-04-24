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
#> # Source:   SQL [?? x 76]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1010-azure:R 4.5.3/:memory:]
#>   cell_id observation_joinid dataset_id          sample_id sample_ experiment___
#>     <dbl> <chr>              <chr>               <chr>     <chr>   <chr>        
#> 1      14 qxl7HJjL$L         842c6f5d-4a94-4eef… 1119f482… 1119f4… ""           
#> 2      15 TjgA2vJ1;{         842c6f5d-4a94-4eef… 1119f482… 1119f4… ""           
#> # ℹ 70 more variables: run_from_cell_id <chr>, sample_heuristic <chr>,
#> #   age_days <int>, tissue_groups <chr>, nFeature_expressed_in_sample <int>,
#> #   nCount_RNA <dbl>, empty_droplet <lgl>, cell_type_unified_ensemble <chr>,
#> #   is_immune <lgl>, subsets_Mito_percent <int>, subsets_Ribo_percent <int>,
#> #   high_mitochondrion <lgl>, high_ribosome <lgl>, scDblFinder.class <chr>,
#> #   sample_chunk <int>, cell_chunk <int>, sample_pseudobulk_chunk <int>,
#> #   file_id_cellNexus_single_cell <chr>, file_id_cellNexus_pseudobulk <chr>, …
```
