# Upload a file to the Nectar object store

Upload a file to the Nectar object store

## Usage

``` r
upload_swift(
  source,
  container,
  name = basename(source),
  credential_id = NULL,
  credential_secret = NULL
)
```

## Arguments

- source:

  A character scalar indicating the local path to the file to upload

- container:

  A character scalar indicating the name of the container to upload to

- name:

  An optional character scalar indicating the name the file should have
  after being uploaded. Defaults to being the basename of the source
  file.

- credential_id:

  The OpenStack application credential secret as a character scalar

## Value

`NULL`, invisibly
