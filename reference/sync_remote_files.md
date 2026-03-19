# Synchronises multiple remote files with local paths in parallel

Uses curl::multi_download for concurrent async I/O downloads. Falls back
to sequential downloads if parallel downloads are disabled.

## Usage

``` r
sync_remote_files(urls, output_files, progress = TRUE)
```

## Arguments

- urls:

  A character vector of URLs to download

- output_files:

  A character vector of local file paths (same length as urls)

- progress:

  Whether to show a progress bar (default TRUE)

## Value

The output_files vector, invisibly
