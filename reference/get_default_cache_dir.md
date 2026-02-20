# Returns the default cache directory with a version number

Returns the default cache directory with a version number

## Usage

``` r
get_default_cache_dir()
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Value

A length one character vector.

## References

Mangiola, S., M. Milton, N. Ranathunga, C. S. N. Li-Wai-Suen, A.
Odainic, E. Yang, W. Hutchison et al. "A multi-organ map of the human
immune system across age, sex and ethnicity." bioRxiv (2023): 2023-06.
doi:10.1101/2023.06.08.542671.

## Examples

``` r
get_metadata(cache_directory = get_default_cache_dir())
#> # Source:   SQL [?? x 97]
#> # Database: DuckDB 1.4.3 [unknown@Linux 6.11.0-1018-azure:R 4.6.0/:memory:]
#>    cell_id                     dataset_id observation_joinid sample_id cell_type
#>    <chr>                       <chr>      <chr>              <chr>     <chr>    
#>  1 10X389_2:AATCGTGTCTGGGAGA_… 00476f9f-… 6Q`5Q?s8MG         9303a73f… neuron   
#>  2 10X389_2:ACCAAACGTCTCAGGC_… 00476f9f-… =rzn8n*;Bt         9303a73f… neuron   
#>  3 10X389_2:TCCGGGACACAGCGCT_… 00476f9f-… {UrC34cLRz         9303a73f… neuron   
#>  4 10X389_1:GTGACGCGTATCCCAA_… 00476f9f-… aX=h+H$b%3         9303a73f… neuron   
#>  5 10X389_2:ACTGCAACAAGAGATT_… 00476f9f-… yujwks<ZXP         9303a73f… neuron   
#>  6 10X389_2:AGGAGGTAGTTCCGTA_… 00476f9f-… `I`7=IHlhJ         9303a73f… neuron   
#>  7 10X389_2:GAAGGACGTATGACAA_… 00476f9f-… 9UR&U96Up(         9303a73f… neuron   
#>  8 10X389_2:GCCAGGTTCCCGAGAC_… 00476f9f-… GknSduSP`2         9303a73f… neuron   
#>  9 10X389_1:TTGGATGCAAGCGCAA_… 00476f9f-… U}{>K6!kF$         9303a73f… neuron   
#> 10 10X389_1:ACACGCGGTCCTGAAT_… 00476f9f-… A;nR~xd6D5         9303a73f… neuron   
#> # ℹ more rows
#> # ℹ 92 more variables: cell_type_ontology_term_id <chr>, sample_ <chr>,
#> #   assay <chr>, assay_ontology_term_id <chr>, cell_count <int>,
#> #   citation <chr>, collection_id <chr>, dataset_version_id <chr>,
#> #   default_embedding <chr>, development_stage <chr>,
#> #   development_stage_ontology_term_id <chr>, disease <chr>,
#> #   disease_ontology_term_id <chr>, donor_id <chr>, experiment___ <chr>, …
```
