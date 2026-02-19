# cellNexus

`cellNexus` is a query interface for programmatic exploration and
retrieval of harmonised, curated, and reannotated CELLxGENE
human-cell-atlas data.

![cellNexus abstract overview](abstract.png)

This standalone documentation website provides:

- Detailed data-processing information (quality control, harmonisation,
  and expression representations).
- Complete explanations of metadata columns used in filtering and
  interpretation.
- Guided examples for metadata-first exploration and gene-expression
  analysis.

## Start Here

- **Home**: package purpose, architecture, and processing pipeline
  overview.
- **Metadata Explore**: field-by-field metadata dictionary, examples,
  and filtering strategy.
- **Gene Expression Explore**: practical workflows for querying
  single-cell, pseudobulk, and metacell expression.

## Data Processing Overview

The harmonisation pipeline standardises data across datasets so queries
are consistent across studies:

1.  Metadata are retrieved from cloud-hosted harmonised tables.
2.  Standardised quality control removes empty droplets, dead/damaged
    cells, and likely doublets.
3.  Cell-level data are served through common assay layers (`counts`,
    `cpm`, pseudobulk, metacell).
4.  Outputs are returned in analysis-ready R formats such as
    `SingleCellExperiment` and `Seurat`.

For implementation details and code examples, see the vignettes listed
in the top navigation.

## Client Usage Examples

### R client (`cellNexus`)

``` r

library(cellNexus)
library(dplyr)
library(stringr)

metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)

query <- metadata |>
  filter(
    empty_droplet == FALSE,
    alive == TRUE,
    scDblFinder.class != "doublet",
    self_reported_ethnicity == "African",
    str_like(assay, "%10x%"),
    tissue == "lung parenchyma",
    str_like(cell_type, "%CD4%")
  )

sce <- get_single_cell_experiment(query, assays = "cpm")
pb <- get_pseudobulk(query)
```

### Python client (`cellNexusPy`)

Python support is available in the companion repository:
[`MangiolaLaboratory/cellNexusPy`](https://github.com/MangiolaLaboratory/cellNexusPy).

``` python
from cellnexuspy import get_metadata, get_anndata

sample_dataset = "https://object-store.rc.nectar.org.au/v1/AUTH_06d6e008e3e642da99d806ba3ea629c5/cellNexus-metadata/sample_metadata.1.3.0.parquet"
conn, table = get_metadata(parquet_url=sample_dataset)

table = table.filter("""
    empty_droplet = 'false'
    AND alive = 'true'
    AND "scDblFinder.class" != 'doublet'
    AND feature_count >= 5000
""")

query = table.filter("""
    self_reported_ethnicity = 'African'
    AND assay LIKE '%10%'
    AND tissue = 'lung parenchyma'
    AND cell_type LIKE '%CD4%'
""")

adata = get_anndata(query, assay="cpm")
pb = get_anndata(query, aggregation="pseudobulk")
conn.close()
```
