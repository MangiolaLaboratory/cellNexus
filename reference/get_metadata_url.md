# Returns the URLs for all metadata files

Returns the URLs for all metadata files

## Usage

``` r
get_metadata_url(databases = c("hca_2024", "hca_2025"))
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Arguments

- databases:

  A character vector of atlas aliases or raw parquet filenames.
  Recognised aliases are `"hca_2024"` and `"hca_2025"`. Raw filenames
  (e.g. `"atlas_versions.parquet"`) are passed through unchanged and are
  intended for internal package use.

## Value

A character vector of URLs to parquet files

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
get_metadata_url("hca_2024")
#> https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/hca2024_v2.3.1.parquet
```
