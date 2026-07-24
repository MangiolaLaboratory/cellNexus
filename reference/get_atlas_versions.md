# Returns the atlas version changelog as a tibble

Downloads the `atlas_versions.parquet` registry from the cellNexus
metadata store, caches it locally, and returns it as an in-memory
tibble. Each row describes one atlas data release and its relationship
to a CellxGene Census snapshot.

## Usage

``` r
get_atlas_versions(cache = tempdir())
```

## Source

[Shen et
al.,2026](https://www.biorxiv.org/content/10.64898/2026.04.14.718336v3)

## Arguments

- cache:

  Optional character scalar. A local directory used to cache the
  downloaded parquet file. Defaults to a temporary directory to separate
  from the main cache directory.

## Value

A tibble with columns:

- atlas_id:

  Atlas version identifier, e.g. `"cellxgene_2024/0.1.0"`. Matches the
  `atlas_id` column in
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md).

- census_version:

  The CellxGene Census snapshot this atlas was built from, e.g.
  `"01-07-2024"`.

- change_type:

  One of `"initial"`, `"patch"`, `"minor"`, or `"major"`. See
  `ATLAS_VERSIONS.md` for the conventions standards.

- description:

  Summary text of what changed in this release.

- modified_at:

  Modification date as a character scalar (`"YYYY-MM-DD"`). By default
  use [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html)

## Details

The `atlas_id` column in this table corresponds directly to the
`atlas_id` column returned by
[`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md),
so you can join them to find which Census snapshot any cell in your
query came from.

## References

Shen, M., Y. Gao, N. Liu, D. Bhuva, M. Milton, J. Henao, J. Andrews, E.
Yang, C. Zhan, N. Liu, S. Si, J. W. Hutchison, M. H. Shakeel, M. Morgan,
A. T. Papenfuss, J. Iskander, J. M. Polo, and S. Mangiola. "cellNexus:
Quality control, annotation, aggregation and analytical layers for the
Human Cell Atlas data." bioRxiv (2026). doi:10.64898/2026.04.14.718336.

## See also

- CellxGene Census data releases (LTS):
  <https://chanzuckerberg.github.io/cellxgene-census/cellxgene_census_docsite_data_release_info.html>

## Examples

``` r
get_atlas_versions()
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/atlas_versions.parquet to /tmp/Rtmpvkb4hO/atlas_versions.parquet
#> # A tibble: 6 × 6
#>   atlas_id          census_version change_type description modified_at container
#>   <chr>             <chr>          <chr>       <chr>       <chr>       <chr>    
#> 1 cellxgene_2024/0… 01-07-2024     initial     Initial re… 2026-03-26  cellNexu…
#> 2 hta_2025/0.1.0    21-10-2025     initial     Initial re… 2026-03-26  cellNexu…
#> 3 cellxgene_2024/0… 01-07-2024     minor       Changed fi… 2026-04-16  cellNexu…
#> 4 cellxgene_2024/0… 01-07-2024     bug         Fixed cell… 2026-04-21  cellNexu…
#> 5 cellxgene_2024/0… 01-07-2024     minor       Updated tr… 2026-05-26  cellNexu…
#> 6 hca_2024/0.4.1    01-07-2024     minor       Updated th… 2026-07-22  cellNexu…
```
