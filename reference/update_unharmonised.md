# Update the unharmonised parquet files

Update the unharmonised parquet files

## Usage

``` r
update_unharmonised(unharmonised_parquet_dir, ...)
```

## Arguments

- unharmonised_parquet_dir:

  The path to a directory containing parquet files, one for each
  dataset, e.g.
  /vast/projects/cellxgene_curated/metadata_non_harmonised_parquet_0.2

- ...:

  Arguments passed on to
  [`upload_swift`](https://mangiolalaboratory.github.io/cellNexus/reference/upload_swift.md)

  `source`

  :   A character scalar indicating the local path to the file to upload

  `container`

  :   A character scalar indicating the name of the container to upload
      to

  `name`

  :   An optional character scalar indicating the name the file should
      have after being uploaded. Defaults to being the basename of the
      source file.

  `credential_id`

  :   The OpenStack application credential secret as a character scalar

## Value

`NULL`, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
update_unharmonised(
    "/vast/projects/cellxgene_curated/metadata_non_harmonised_parquet_0.2", 
    credential_id = "ABCDEFGHIJK", 
    credential_secret = "ABCD1234EFGH-5678IJK"
)
} # }
```
