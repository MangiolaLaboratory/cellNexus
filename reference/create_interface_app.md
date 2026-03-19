# Create a Shiny app that allows users to generate filtering & retreival code for cellNexus

Create a Shiny app that allows users to generate filtering & retreival
code for cellNexus

## Usage

``` r
create_interface_app(ui_choices, return_as_list = FALSE)
```

## Source

[Mangiola et
al.,2023](https://www.biorxiv.org/content/10.1101/2023.06.08.542671v3)

## Arguments

- ui_choices:

  A list of pre-computed unique values for each filterable column in the
  metadata.

- return_as_list:

  If TRUE, returns a list with 'ui' and 'server' components instead of a
  Shiny app object.

## Value

A Shiny app that allows users to filter cellNexus metadata and generate
code for retrieval in the selected format.

## Author

Jared Andrews

## Examples

``` r
get_default_cache_dir()
#> [1] "/home/runner/.cache/R/cellNexus"
if (FALSE) { # interactive()
# Create the interface app with metadata
metadata <- get_metadata(cloud_metadata = SAMPLE_DATABASE_URL)
app <- create_interface_app(metadata)
# Run the app
shiny::runApp(app)
}
```
