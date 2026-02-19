# Update the metadata database in nectar using a newly created data frame

Update the metadata database in nectar using a newly created data frame

## Usage

``` r
update_database(metadata, version, ...)
```

## Arguments

- metadata:

  The data frame to upload

- version:

  The version for the new metadata as a character scalar, e.g. "0.2.3"

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
 metadata = cellNexus::get_metadata() |>
     head(10) |>
     dplyr::collect()
 update_database(
     metadata, 
     "0.2.3", 
     credential_id = "ABCDEFGHIJK", 
     credential_secret = "ABCD1234EFGH-5678IJK"
 )
 # Prints "metadata.0.2.3.parquet" if successful
} # }
```
