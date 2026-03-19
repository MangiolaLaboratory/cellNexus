# Pre-computed UI Choices for Interface App

A list of unique values for each filterable column used in the cellNexus
Shiny interface app. Pre-computing these choices avoids slow metadata
queries when the app starts.

## Usage

``` r
data(ui_choices)
```

## Format

A named list where each element contains unique values for a column:

- cell_type_unified_ensemble:

  Character vector of unified cell type labels

- cell_type:

  Character vector of original cell type labels

- alive:

  Logical values for cell viability

- scDblFinder.class:

  Character vector of doublet classification results

- is_immune:

  Logical values for immune cell classification

- empty_droplet:

  Logical values for empty droplet detection

- development_stage:

  Character vector of developmental stages

- disease:

  Character vector of disease states

- self_reported_ethnicity:

  Character vector of ethnicity labels

- sex:

  Character vector of sex labels

- tissue:

  Character vector of tissue types

- tissue_groups:

  Character vector of tissue group labels

## Source

Generated from cellNexus metadata

## Details

See `dev/generate_ui_choices.R` for the creation script. Run this script
to regenerate the choices when metadata columns change.
