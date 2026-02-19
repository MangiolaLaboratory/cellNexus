# Create a Shiny app that allows users to generate filtering & retreival code for cellNexus

Create a Shiny app that allows users to generate filtering & retreival
code for cellNexus

## Usage

``` r
create_interface_app(metadata)
```

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
if (FALSE) { # \dontrun{
# Create the interface app with metadata
# For fast build purpose only, you do not need to specify anything in cloud_metadata.
metadata <-get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
app <- create_interface_app(metadata)
# Run the app
shiny::runApp(app)
} # }
```
