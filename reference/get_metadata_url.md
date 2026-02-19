# Returns the URLs for all metadata files

Returns the URLs for all metadata files

## Usage

``` r
get_metadata_url(databases = c("metadata.1.3.0.parquet"))
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- databases:

  A character vector specifying the names of the metadata files.
  Download the specific metadata by defining the metadata version. The
  default is metadata.1.3.0.parquet

## Value

A character vector of URLs to parquet files to download

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
get_metadata_url("metadata.1.3.0.parquet")
#> https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/metadata.1.3.0.parquet
```
