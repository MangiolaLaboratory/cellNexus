# Create a Shiny app that allows users to generate filtering & retreival code for cellNexus

Create a Shiny app that allows users to generate filtering & retreival
code for cellNexus

## Usage

``` r
create_interface_app(metadata)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- metadata:

  cellNexus metadata as returned by
  [`get_metadata()`](https://mangiolalaboratory.github.io/cellNexus/reference/get_metadata.md).

## Value

A Shiny app that allows users to filter cellNexus metadata and generate
code for retrieval in the selected format.

## Author

Jared Andrews

## Examples

``` r
get_default_cache_dir()
#> [1] "/github/home/.cache/R/cellNexus"
if (FALSE) { # interactive()
# Create the interface app with metadata
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
app <- create_interface_app(metadata)
# Run the app
shiny::runApp(app)
}
```
