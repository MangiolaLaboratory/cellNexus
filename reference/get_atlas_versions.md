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

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

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

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## See also

- CellxGene Census data releases (LTS):
  <https://chanzuckerberg.github.io/cellxgene-census/cellxgene_census_docsite_data_release_info.html>

## Examples

``` r
get_atlas_versions()
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/atlas_versions.parquet to /tmp/Rtmpj4oLu5/atlas_versions.parquet
#> # A tibble: 4 × 5
#>   atlas_id             census_version change_type description        modified_at
#>   <chr>                <chr>          <chr>       <chr>              <chr>      
#> 1 cellxgene_2024/0.1.0 01-07-2024     initial     Initial release l… 2026-03-26 
#> 2 hta_2025/0.1.0       21-10-2025     initial     Initial release i… 2026-03-26 
#> 3 cellxgene_2024/0.2.0 01-07-2024     minor       Changed file id c… 2026-04-16 
#> 4 cellxgene_2024/0.2.1 01-07-2024     bug         Fixed cell type m… 2026-04-21 
```
