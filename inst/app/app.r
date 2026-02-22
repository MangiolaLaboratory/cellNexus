library(cellNexus)
library(shiny)

metadata <- get_metadata()

app <- create_interface_app(metadata)

shinyApp(ui = app$ui, server = app$server)