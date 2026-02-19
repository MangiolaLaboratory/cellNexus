# Returns a tibble from a parquet file path Since dbplyr 2.4.0, raw file paths aren't handled very well See: <https://github.com/duckdb/duckdb-r/issues/38> Hence the need for this method

Returns a tibble from a parquet file path Since dbplyr 2.4.0, raw file
paths aren't handled very well See:
<https://github.com/duckdb/duckdb-r/issues/38> Hence the need for this
method

## Usage

``` r
read_parquet(conn, path, filename_column = FALSE)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- filename_column:

  A column name to the metadata that indicates which row came from which
  file. By default it does not add the column.

## Value

An SQL data frame
