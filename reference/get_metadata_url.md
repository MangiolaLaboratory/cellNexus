# Returns the URLs for all metadata files

Returns the URLs for all metadata files

## Usage

``` r
get_metadata_url(
  databases = c("cellnexus_metadata.2.3.0.parquet", "census_cell_metadata.2.3.0.parquet")
)
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Arguments

- databases:

  A character vector specifying the names of the metadata files.
  Download the specific metadata by defining the metadata version.

## Value

A character vector of URLs to parquet files to download

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## Examples

``` r
get_metadata_url("cellnexus_metadata.2.3.0.parquet")
#> https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/cellnexus_metadata.2.3.0.parquet
```
