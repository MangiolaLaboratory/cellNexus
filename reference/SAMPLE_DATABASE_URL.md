# URL pointing to the sample metadata file, which is smaller and for test, demonstration, and vignette purposes only

URL pointing to the sample metadata file, which is smaller and for test,
demonstration, and vignette purposes only

## Usage

``` r
SAMPLE_DATABASE_URL
```

## Format

An object of class `character` of length 1.

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Value

A character scalar consisting of the URL

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
get_metadata(cloud_metadata = SAMPLE_DATABASE_URL, cache_directory = tempdir())
#> ℹ Downloading 1 file, totalling 0 GB
#> ℹ Downloading https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_metadata.1.3.0.parquet to /tmp/Rtmp8tBwgK/sample_metadata.1.3.0.parquet
#> # Source:   SQL [?? x 97]
#> # Database: DuckDB 1.4.3 [unknown@Linux 6.14.0-1017-azure:R 4.6.0/:memory:]
#>    cell_id                     dataset_id observation_joinid sample_id cell_type
#>    <chr>                       <chr>      <chr>              <chr>     <chr>    
#>  1 FCAImmP7528294-ACATACGAGTA… cda2c8cd-… p5e=WoIq0d         034f0fb1… monocyte 
#>  2 FCAImmP7528294-CATGACAGTCC… cda2c8cd-… lx`7Bo-&7n         034f0fb1… monocyte 
#>  3 FCAImmP7528294-AAGACCTAGCT… cda2c8cd-… *NUPW@J{c2         034f0fb1… monocyte 
#>  4 FCAImmP7528294-AATCGGTTCAA… cda2c8cd-… KIV>qGFIS?         034f0fb1… monocyte 
#>  5 FCAImmP7528294-TTTGGTTGTGG… cda2c8cd-… *_#lQ<oUnT         034f0fb1… monocyte 
#>  6 FCAImmP7528294-TCAGGTACAAT… cda2c8cd-… zHCZWNmUHu         034f0fb1… monocyte 
#>  7 FCAImmP7528294-GACGCGTAGGC… cda2c8cd-… -NL-OH3!IA         034f0fb1… monocyte 
#>  8 FCAImmP7528294-CTTGGCTGTTC… cda2c8cd-… 6mRCZW}rOM         034f0fb1… monocyte 
#>  9 FCAImmP7528294-CACTCCACACC… cda2c8cd-… I6>u{Gb-J_         034f0fb1… monocyte 
#> 10 FCAImmP7579218-TGTGGTAGTCT… cda2c8cd-… IdHwp1GBZm         03ddfd57… monocyte 
#> # ℹ more rows
#> # ℹ 92 more variables: cell_type_ontology_term_id <chr>, sample_ <chr>,
#> #   assay <chr>, assay_ontology_term_id <chr>, cell_count <int>,
#> #   citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, development_stage <chr>,
#> #   development_stage_ontology_term_id <chr>, disease <chr>,
#> #   disease_ontology_term_id <chr>, donor_id <chr>, experiment___ <chr>, …
```
